{-# OPTIONS_GHC -Wno-type-defaults #-}

module SharedLogic.Allocator.Jobs.Overlay.SendOverlay where

import qualified Data.Text as T
import Data.Time hiding (getCurrentTime)
import qualified Domain.Types.DriverFee as DDF
import qualified Domain.Types.DriverInformation as DTDI
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Merchant.Overlay as DOverlay
import Domain.Types.Merchant.TransporterConfig
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Plan as DPlan
import EulerHS.Prelude hiding (id)
import Kernel.External.Types
import qualified Kernel.Storage.Esqueleto as Esq
import qualified Kernel.Storage.Hedis.Queries as Hedis
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import Lib.Scheduler
import SharedLogic.Allocator
import qualified SharedLogic.DriverFee as SLDriverFee
import qualified Storage.CachedQueries.Merchant.Overlay as CMP
import qualified Storage.Queries.DriverFee as QDF
import qualified Storage.Queries.DriverInformation as QDI
import qualified Storage.Queries.Person as QP
import qualified Tools.Notifications as TN

sendOverlayToDriver ::
  ( CacheFlow m r,
    EsqDBFlow m r,
    MonadFlow m,
    Esq.EsqDBReplicaFlow m r,
    ServiceFlow m r,
    Esq.Transactionable m,
    EncFlow m r,
    HasShortDurationRetryCfg r c
  ) =>
  Job 'SendOverlay ->
  m ExecutionResult
sendOverlayToDriver (Job {id, jobInfo}) = withLogTag ("JobId-" <> id.getId) do
  let jobData = jobInfo.jobData
      merchantId = jobData.merchantId
      jobId = id

  driverIds <- getBatchedDriverIds merchantId jobId jobData.condition jobData.freeTrialDays jobData.timeDiffFromUtc jobData.driverPaymentCycleDuration jobData.driverPaymentCycleStartTime
  logInfo $ show driverIds
  driverIdsLength <- getSendOverlaySchedulerDriverIdsLength merchantId jobId

  if driverIdsLength > 0
    then do
      mapM_ (sendOverlayAccordingToCondition jobData.condition jobData.overlayKey jobData.udf1) driverIds
      ReSchedule . addUTCTime 180 <$> getCurrentTime -- 3 minutes
    else do
      unless (null driverIds) $ mapM_ (sendOverlayAccordingToCondition jobData.condition jobData.overlayKey jobData.udf1) driverIds
      case jobData.rescheduleInterval of
        Just interval -> do
          lastScheduledTime <- getLastScheduledJobTime merchantId jobId jobData.scheduledTime jobData.timeDiffFromUtc
          let newScheduledTime = addUTCTime (fromIntegral interval) lastScheduledTime
          setLastScheduledJobTime merchantId jobId newScheduledTime
          pure (ReSchedule newScheduledTime)
        Nothing -> return Complete
  where
    sendOverlayAccordingToCondition condition overlayKey udf1 driverId = do
      driver <- QP.findById driverId >>= fromMaybeM (PersonDoesNotExist driverId.getId)
      case condition of
        DOverlay.PaymentOverdueGreaterThan limit -> do
          manualDues <- getManualDues driverId
          when (manualDues > fromIntegral limit) $ sendOverlay driver overlayKey udf1 0
        DOverlay.PaymentOverdueBetween rLimit lLimit -> do
          manualDues <- getManualDues driverId
          when ((fromIntegral rLimit <= manualDues) && (manualDues <= fromIntegral lLimit)) $ sendOverlay driver overlayKey udf1 0
        DOverlay.InvoiceGenerated _ -> do
          manualDues <- getManualDues driverId
          sendOverlay driver overlayKey udf1 manualDues
        DOverlay.FreeTrialDaysLeft _ -> do
          driverInfo <- QDI.findById driverId >>= fromMaybeM (PersonDoesNotExist driverId.getId)
          currUdf1 <- getCurrentAutoPayStatusUDF driverInfo
          when (currUdf1 == udf1) $ sendOverlay driver overlayKey udf1 0
        _ -> pure ()

    getCurrentAutoPayStatusUDF driverInfo = do
      case driverInfo.autoPayStatus of
        Nothing -> return $ Just "PLAN_NOT_SELECTED"
        Just DTDI.ACTIVE -> return $ Just ""
        Just DTDI.PENDING -> return $ Just ""
        _ -> return $ Just "AUTOPAY_NOT_SET"

    getManualDues driverId = do
      pendingDriverFees <- QDF.findAllOverdueDriverFeeByDriverId driverId
      return $ sum $ map (\dueInvoice -> SLDriverFee.roundToHalf (fromIntegral dueInvoice.govtCharges + dueInvoice.platformFee.fee + dueInvoice.platformFee.cgst + dueInvoice.platformFee.sgst)) pendingDriverFees

getRescheduledTime :: (MonadTime m) => TransporterConfig -> m UTCTime
getRescheduledTime tc = addUTCTime tc.mandateNotificationRescheduleInterval <$> getCurrentTime

sendOverlay :: (CacheFlow m r, EsqDBFlow m r) => DP.Person -> Text -> Maybe Text -> HighPrecMoney -> m ()
sendOverlay driver overlayKey udf1 amount = do
  mOverlay <- CMP.findByMerchantIdPNKeyLangaugeUdf driver.merchantId overlayKey (fromMaybe ENGLISH driver.language) udf1
  whenJust mOverlay $ \overlay -> do
    let okButtonText = T.replace (templateText "dueAmount") (show amount) <$> overlay.okButtonText
    TN.sendOverlay driver.merchantId driver.id driver.deviceToken overlay.title overlay.description overlay.imageUrl okButtonText overlay.cancelButtonText overlay.actions overlay.link overlay.endPoint overlay.method overlay.reqBody

getSendOverlaySchedulerDriverIdsLength :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> m Integer
getSendOverlaySchedulerDriverIdsLength merchantId jobId = Hedis.lLen $ makeSendOverlaySchedulerDriverIdsKey merchantId jobId

getFirstNSendOverlaySchedulerDriverIds :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> Integer -> m [Id DP.Person]
getFirstNSendOverlaySchedulerDriverIds merchantId jobId num = Hedis.lRange (makeSendOverlaySchedulerDriverIdsKey merchantId jobId) 0 (num -1)

deleteNSendOverlaySchedulerDriverIds :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> Integer -> m ()
deleteNSendOverlaySchedulerDriverIds merchantId jobId num = Hedis.lTrim (makeSendOverlaySchedulerDriverIdsKey merchantId jobId) num (-1)

addSendOverlaySchedulerDriverIds :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> NonEmpty (Id DP.Person) -> m ()
addSendOverlaySchedulerDriverIds merchantId jobId = Hedis.rPush (makeSendOverlaySchedulerDriverIdsKey merchantId jobId)

makeSendOverlaySchedulerDriverIdsKey :: Id DM.Merchant -> Id AnyJob -> Text
makeSendOverlaySchedulerDriverIdsKey merchantId jobId = "SendOverlayScheduler:merchantId-" <> merchantId.getId <> ":jobId-" <> jobId.getId

getLastScheduledJobTime :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> TimeOfDay -> Seconds -> m UTCTime
getLastScheduledJobTime merchantId jobId scheduledTime timeDiffFromUtc = do
  Hedis.get (makeLastScheduledTimeJobKey merchantId jobId) >>= \case
    Nothing -> do
      now <- getLocalCurrentTime timeDiffFromUtc
      let lastScheduledTime = addUTCTime (fromIntegral $ -1 * timeDiffFromUtc) (UTCTime (utctDay now) (timeOfDayToTime scheduledTime))
      setLastScheduledJobTime merchantId jobId lastScheduledTime
      pure lastScheduledTime
    Just lastScheduledTime -> pure lastScheduledTime

setLastScheduledJobTime :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> UTCTime -> m ()
setLastScheduledJobTime merchantId jobId = Hedis.set (makeLastScheduledTimeJobKey merchantId jobId)

makeLastScheduledTimeJobKey :: Id DM.Merchant -> Id AnyJob -> Text
makeLastScheduledTimeJobKey merchantId jobId = "SendOverlayScheduler:lastScheduledTime:merchantId-" <> merchantId.getId <> ":jobId" <> jobId.getId

getBatchedDriverIds :: (CacheFlow m r, EsqDBFlow m r) => Id DM.Merchant -> Id AnyJob -> DOverlay.OverlayCondition -> Int -> Seconds -> NominalDiffTime -> NominalDiffTime -> m [Id DP.Person]
getBatchedDriverIds merchantId jobId condition freeTrialDays timeDiffFromUtc driverPaymentCycleDuration driverPaymentCycleStartTime = do
  driverIdsLength <- getSendOverlaySchedulerDriverIdsLength merchantId jobId
  when (driverIdsLength < 1) do
    driverIds <- case condition of
      DOverlay.PaymentOverdueGreaterThan _ -> QDI.fetchAllDriversWithPaymentPending merchantId <&> (<&> (.driverId))
      DOverlay.PaymentOverdueBetween _ _ -> QDI.fetchAllDriversWithPaymentPending merchantId <&> (<&> (.driverId))
      DOverlay.InvoiceGenerated paymentMode -> do
        now <- getLocalCurrentTime timeDiffFromUtc
        let potentialStartToday = addUTCTime driverPaymentCycleStartTime (UTCTime (utctDay now) (secondsToDiffTime 0))
            startTime = addUTCTime (-1 * driverPaymentCycleDuration) potentialStartToday
            endTime = addUTCTime 120 potentialStartToday
        QDF.findWindowsWithFeeType merchantId startTime endTime (getFeeType paymentMode) <&> (<&> (.driverId))
      DOverlay.FreeTrialDaysLeft numOfDays -> do
        now <- getCurrentTime
        let startTime = addUTCTime (-1 * fromIntegral timeDiffFromUtc) $ addUTCTime (-1 * 86400 * fromIntegral (freeTrialDays - (numOfDays - 1))) (UTCTime (utctDay now) (secondsToDiffTime 0))
            endTime = addUTCTime 86400 startTime
        QDI.findAllByEnabledAtInWindow merchantId (Just startTime) (Just endTime) <&> (<&> (.driverId))
      _ -> return []
    whenJust (nonEmpty driverIds) $ addSendOverlaySchedulerDriverIds merchantId jobId
  batchedDriverIds <- getFirstNSendOverlaySchedulerDriverIds merchantId jobId 50
  deleteNSendOverlaySchedulerDriverIds merchantId jobId 50
  return batchedDriverIds
  where
    getFeeType paymentMode = case paymentMode of
      DPlan.AUTOPAY -> DDF.RECURRING_EXECUTION_INVOICE
      DPlan.MANUAL -> DDF.RECURRING_INVOICE

templateText :: Text -> Text
templateText txt = "{#" <> txt <> "#}"
