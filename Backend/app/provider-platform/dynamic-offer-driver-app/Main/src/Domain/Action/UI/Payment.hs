{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Domain.Action.UI.Payment
  ( DPayment.PaymentStatusResp (..),
    createOrder,
    getStatus,
    getOrder,
    juspayWebhookHandler,
    pdnNotificationStatus,
  )
where

import Domain.Action.UI.Ride.EndRide.Internal
import Domain.Types.DriverFee
import qualified Domain.Types.DriverInformation as DI
import qualified Domain.Types.Invoice as INV
import qualified Domain.Types.Mandate as DM
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Merchant.MerchantServiceConfig as DMSC
import Domain.Types.Notification (Notification)
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Plan as DP
import Environment
import Kernel.Beam.Functions as B (runInReplica)
import Kernel.External.Encryption
import qualified Kernel.External.Payment.Interface as DPayments
import qualified Kernel.External.Payment.Interface.Juspay as Juspay
import qualified Kernel.External.Payment.Interface.Types as Payment
import qualified Kernel.External.Payment.Juspay.Types as Juspay
import qualified Kernel.External.Payment.Types as Payment
import Kernel.Prelude
import qualified Kernel.Storage.Hedis as Redis
import qualified Kernel.Storage.Hedis.Queries as Hedis
import Kernel.Types.Common hiding (id)
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Lib.Payment.Domain.Action as DPayment
import qualified Lib.Payment.Domain.Types.Common as DPayment
import qualified Lib.Payment.Domain.Types.PaymentOrder as DOrder
import qualified Lib.Payment.Storage.Queries.PaymentOrder as QOrder
import Servant (BasicAuthData)
import SharedLogic.Merchant
import qualified SharedLogic.Payment as SPayment
import qualified Storage.CachedQueries.Merchant.MerchantServiceConfig as CQMSC
import qualified Storage.CachedQueries.Merchant.TransporterConfig as SCT
import qualified Storage.Queries.Driver.DriverFlowStatus as QDFS
import qualified Storage.Queries.DriverFee as QDF
import qualified Storage.Queries.DriverInformation as DI
import Storage.Queries.DriverPlan (findByDriverId)
import qualified Storage.Queries.DriverPlan as QDP
import qualified Storage.Queries.Invoice as QIN
import qualified Storage.Queries.Mandate as QM
import qualified Storage.Queries.Notification as QNTF
import qualified Storage.Queries.Person as QP
import Tools.Error
import Tools.Notifications
import qualified Tools.Payment as Payment

-- create order -----------------------------------------------------
createOrder :: (Id DP.Person, Id DM.Merchant) -> Id INV.Invoice -> Flow Payment.CreateOrderResp
createOrder (driverId, merchantId) invoiceId = do
  invoices <- B.runInReplica $ QIN.findAllByInvoiceId invoiceId
  driverFees <- (B.runInReplica . QDF.findById . (.driverFeeId)) `mapM` invoices
  (createOrderResp, _) <- SPayment.createOrder (driverId, merchantId) (catMaybes driverFees, []) Nothing INV.MANUAL_INVOICE (getIdAndShortId <$> listToMaybe invoices)
  return createOrderResp
  where
    getIdAndShortId inv = (inv.id, inv.invoiceShortId)

getOrder :: (Id DP.Person, Id DM.Merchant) -> Id DOrder.PaymentOrder -> Flow DOrder.PaymentOrderAPIEntity
getOrder (personId, _) orderId = do
  order <- QOrder.findById orderId >>= fromMaybeM (PaymentOrderNotFound orderId.getId)
  unless (order.personId == cast personId) $ throwError NotAnExecutor
  mkOrderAPIEntity order

mkOrderAPIEntity :: EncFlow m r => DOrder.PaymentOrder -> m DOrder.PaymentOrderAPIEntity
mkOrderAPIEntity DOrder.PaymentOrder {..} = do
  clientAuthToken_ <- decrypt `mapM` clientAuthToken
  return $ DOrder.PaymentOrderAPIEntity {clientAuthToken = clientAuthToken_, ..}

-- order status -----------------------------------------------------

getStatus :: (Id DP.Person, Id DM.Merchant) -> Id DOrder.PaymentOrder -> Flow DPayment.PaymentStatusResp
getStatus (personId, merchantId) orderId = do
  let commonPersonId = cast @DP.Person @DPayment.Person personId
      orderStatusCall = Payment.orderStatus merchantId -- api call
  mOrder <- QOrder.findById orderId
  order <-
    case mOrder of -- handling backward compatibility case of jatri saathi
      Just _order -> return _order
      Nothing -> do
        invoices <- QIN.findById (cast orderId)
        invoice <- listToMaybe invoices & fromMaybeM (PaymentOrderNotFound orderId.getId)
        QOrder.findById (cast invoice.id) >>= fromMaybeM (PaymentOrderNotFound invoice.id.getId)

  paymentStatus <- DPayment.orderStatusService commonPersonId order.id orderStatusCall

  case paymentStatus of
    DPayment.MandatePaymentStatus {..} -> do
      unless (order.status /= Payment.CHARGED) $ do
        processPayment merchantId (cast order.personId) order.id (shouldSendSuccessNotification mandateStatus)
      processMandate (cast order.personId) mandateStatus mandateStartDate mandateEndDate (Id mandateId) mandateMaxAmount payerVpa upi
      QIN.updateBankErrorsByInvoiceId bankErrorMessage bankErrorCode (cast order.id)
    DPayment.PaymentStatus _ -> do
      unless (order.status /= Payment.CHARGED) $ do
        processPayment merchantId (cast order.personId) order.id True
    DPayment.PDNNotificationStatusResp {..} ->
      processNotification notificationId notificationStatus
  notifyAndUpdateInvoiceStatusIfPaymentFailed personId order.id order.status Nothing
  pure paymentStatus

-- webhook ----------------------------------------------------------

juspayWebhookHandler ::
  ShortId DM.Merchant ->
  BasicAuthData ->
  Value ->
  Flow AckResponse
juspayWebhookHandler merchantShortId authData value = do
  merchant <- findMerchantByShortId merchantShortId
  let merchantId = merchant.id
  merchantServiceConfig <-
    CQMSC.findByMerchantIdAndService merchantId (DMSC.PaymentService Payment.Juspay)
      >>= fromMaybeM (MerchantServiceConfigNotFound merchantId.getId "Payment" (show Payment.Juspay))
  case merchantServiceConfig.serviceConfig of
    DMSC.PaymentServiceConfig psc -> do
      orderStatusResp <- Juspay.orderStatusWebhook psc DPayment.juspayWebhookService authData value
      case orderStatusResp of
        Nothing -> throwError $ InternalError "Order Contents not found."
        Just osr -> do
          case osr of
            Payment.OrderStatusResp {..} -> do
              order <- QOrder.findByShortId (ShortId orderShortId) >>= fromMaybeM (PaymentOrderNotFound orderShortId)
              unless (transactionStatus /= Payment.CHARGED) $ do
                processPayment merchantId (cast order.personId) order.id True
              notifyAndUpdateInvoiceStatusIfPaymentFailed (cast order.personId) order.id transactionStatus eventName
              QIN.updateBankErrorsByInvoiceId bankErrorMessage bankErrorCode (cast order.id)
            Payment.MandateOrderStatusResp {..} -> do
              order <- QOrder.findByShortId (ShortId orderShortId) >>= fromMaybeM (PaymentOrderNotFound orderShortId)
              unless (transactionStatus /= Payment.CHARGED) $ do
                processPayment merchantId (cast order.personId) order.id (shouldSendSuccessNotification mandateStatus)
              processMandate (cast order.personId) mandateStatus mandateStartDate mandateEndDate (Id mandateId) mandateMaxAmount payerVpa upi
              notifyAndUpdateInvoiceStatusIfPaymentFailed (cast order.personId) order.id transactionStatus eventName
              QIN.updateBankErrorsByInvoiceId bankErrorMessage bankErrorCode (cast order.id)
            ---- to do add FCM for insufficient funds  -----
            Payment.MandateStatusResp {..} -> do
              order <- QOrder.findByShortId (ShortId orderShortId) >>= fromMaybeM (PaymentOrderNotFound orderShortId)
              processMandate (cast order.personId) status mandateStartDate mandateEndDate (Id mandateId) mandateMaxAmount Nothing Nothing
            Payment.PDNNotificationStatusResp {..} ->
              processNotification notificationId notificationStatus
            Payment.BadStatusResp -> pure ()
      pure Ack
    _ -> throwError $ InternalError "Unknown Service Config"

processPayment :: Id DM.Merchant -> Id DP.Person -> Id DOrder.PaymentOrder -> Bool -> Flow ()
processPayment merchantId driverId orderId sendNotification = do
  driver <- B.runInReplica $ QP.findById driverId >>= fromMaybeM (PersonDoesNotExist driverId.getId)
  driverInfo <- DI.findById (cast driverId) >>= fromMaybeM (PersonNotFound driverId.getId)
  transporterConfig <- SCT.findByMerchantId merchantId >>= fromMaybeM (TransporterConfigNotFound merchantId.getId)
  now <- getLocalCurrentTime transporterConfig.timeDiffFromUtc
  invoices <- QIN.findAllByInvoiceId (cast orderId)
  let driverFeeIds = (.driverFeeId) <$> invoices
  Redis.whenWithLockRedis (paymentProcessingLockKey driverId.getId) 60 $ do
    QDF.updateStatusByIds CLEARED driverFeeIds now
    QDFS.clearPaymentStatus driverId driverInfo.active
    QIN.updateInvoiceStatusByInvoiceId INV.SUCCESS (cast orderId)
    updatePaymentStatus driverId merchantId
    when sendNotification $ notifyPaymentSuccessIfNotNotified driver orderId

updatePaymentStatus :: Id DP.Person -> Id DM.Merchant -> Flow ()
updatePaymentStatus driverId merchantId = do
  dueInvoices <- runInReplica $ QDF.findAllPendingAndDueDriverFeeByDriverId (cast driverId)
  let totalDue = sum $ map (\dueInvoice -> fromIntegral dueInvoice.govtCharges + dueInvoice.platformFee.fee + dueInvoice.platformFee.cgst + dueInvoice.platformFee.sgst) dueInvoices
  when (totalDue <= 0) $ DI.updatePendingPayment False (cast driverId)
  mbDriverPlan <- findByDriverId (cast driverId) -- what if its changed? needed inside lock?
  plan <- getPlan mbDriverPlan merchantId
  case plan of
    Nothing -> DI.updateSubscription True (cast driverId)
    Just plan_ -> when (totalDue < plan_.maxCreditLimit) $ DI.updateSubscription True (cast driverId)

notifyPaymentSuccessIfNotNotified :: DP.Person -> Id DOrder.PaymentOrder -> Flow ()
notifyPaymentSuccessIfNotNotified driver orderId = do
  let key = "driver-offer:SuccessNotif-" <> orderId.getId
  sendNotificationIfNotSent key $ do
    notifyPaymentSuccess driver.merchantId driver.id driver.deviceToken orderId

shouldSendSuccessNotification :: Payment.MandateStatus -> Bool
shouldSendSuccessNotification mandateStatus = mandateStatus `notElem` [Payment.REVOKED, Payment.FAILURE, Payment.EXPIRED, Payment.PAUSED]

notifyAndUpdateInvoiceStatusIfPaymentFailed :: Id DP.Person -> Id DOrder.PaymentOrder -> Payment.TransactionStatus -> Maybe Juspay.PaymentStatus -> Flow ()
notifyAndUpdateInvoiceStatusIfPaymentFailed driverId orderId orderStatus eventName = do
  activeExecutionInvoice <- QIN.findByIdWithPaymenModeAndStatus (cast orderId) INV.AUTOPAY_INVOICE INV.ACTIVE_INVOICE
  now <- getCurrentTime
  when (toNotifyFailure (isJust activeExecutionInvoice) eventName orderStatus) $ do
    QIN.updateInvoiceStatusByInvoiceId INV.FAILED (cast orderId)
    case activeExecutionInvoice of
      Just invoice' -> do
        QDF.updateStatus PAYMENT_OVERDUE now invoice'.driverFeeId
        QDF.updateFeeType RECURRING_INVOICE now invoice'.driverFeeId
        QDF.updateAutopayPaymentStageById (Just EXECUTION_FAILED) invoice'.driverFeeId
      Nothing -> pure ()
    let key = "driver-offer:FailedNotif-" <> orderId.getId
    sendNotificationIfNotSent key $ do
      driver <- B.runInReplica $ QP.findById driverId >>= fromMaybeM (PersonDoesNotExist driverId.getId)
      notifyPaymentFailed driver.merchantId driver.id driver.deviceToken orderId
  where
    toNotifyFailure isActiveExecutionInvoice_ eventName_ orderStatus_ = do
      let validStatus = orderStatus_ `elem` [Payment.AUTHENTICATION_FAILED, Payment.AUTHORIZATION_FAILED, Payment.JUSPAY_DECLINED]
      case (isActiveExecutionInvoice_, eventName_ == Just Juspay.ORDER_FAILED) of
        (True, False) -> False
        (_, _) -> validStatus

sendNotificationIfNotSent :: Text -> Flow () -> Flow ()
sendNotificationIfNotSent key actions = do
  isNotificationSent <- fromMaybe False <$> Hedis.get key
  unless isNotificationSent $ do
    Hedis.setExp key True 86400 -- 24 hours
    actions

pdnNotificationStatus :: (Id DP.Person, Id DM.Merchant) -> Id Notification -> Flow DPayments.NotificationStatusResp
pdnNotificationStatus (_, merchantId) notificationId = do
  pdnNotification <- QNTF.findById notificationId >>= fromMaybeM (InternalError $ "No Notification Sent With Id" <> notificationId.getId)
  resp <- Payment.mandateNotificationStatus merchantId (mkNotificationRequest pdnNotification.shortId)
  processNotification pdnNotification.shortId resp.status
  return resp
  where
    mkNotificationRequest shortNotificationId =
      DPayments.NotificationStatusReq
        { notificationId = shortNotificationId
        }

processNotification :: Text -> Payment.NotificationStatus -> Flow ()
processNotification notificationId notificationStatus = do
  notification <- QNTF.findByShortId notificationId >>= fromMaybeM (InternalError "notification not found")
  let driverFeeId = notification.driverFeeId
  now <- getCurrentTime
  case notificationStatus of
    Juspay.NOTIFICATION_FAILURE -> do
      --- here based on notification status failed update driver fee to payment_overdue and reccuring invoice----
      QDF.updateStatus PAYMENT_OVERDUE now driverFeeId
      QDF.updateFeeType RECURRING_INVOICE now driverFeeId
      QIN.updateInvoiceStatusByDriverFeeIds INV.INACTIVE [driverFeeId]
    Juspay.SUCCESS -> do
      --- based on notification status Success udpate driver fee autoPayPaymentStage to Execution scheduled -----
      QDF.updateAutopayPaymentStageById (Just EXECUTION_SCHEDULED) driverFeeId
    _ -> pure ()
  QNTF.updateNotificationStatusById notification.id notificationStatus

processMandate :: Id DP.Person -> Payment.MandateStatus -> UTCTime -> UTCTime -> Id DM.Mandate -> HighPrecMoney -> Maybe Text -> Maybe Payment.Upi -> Flow ()
processMandate driverId mandateStatus startDate endDate mandateId maxAmount payerVpa upiDetails = do
  let payerApp = upiDetails >>= (.payerApp)
      payerAppName = upiDetails >>= (.payerAppName)
      mandatePaymentFlow = upiDetails >>= (.txnFlowType)
  mbExistingMandate <- QM.findById mandateId
  when (isNothing mbExistingMandate) $ QM.create =<< mkMandate payerApp payerAppName mandatePaymentFlow
  QDP.updateMandateIdByDriverId driverId mandateId
  when (mandateStatus == Payment.ACTIVE) $ do
    driverPlan <- QDP.findByMandateId mandateId >>= fromMaybeM (NoDriverPlanForMandate mandateId.getId)
    Redis.whenWithLockRedis (mandateProcessingLockKey mandateId.getId) 60 $ do
      QM.updateMandateDetails mandateId DM.ACTIVE payerVpa payerApp payerAppName mandatePaymentFlow
      QDP.updatePaymentModeByDriverId (cast driverPlan.driverId) DP.AUTOPAY
      QDP.updateMandateSetupDateByDriverId (cast driverPlan.driverId)
      DI.updateSubscription True (cast driverPlan.driverId)
      DI.updateAutoPayStatusAndPayerVpa (castAutoPayStatus mandateStatus) payerVpa (cast driverPlan.driverId)
  when (mandateStatus `elem` [Payment.REVOKED, Payment.FAILURE, Payment.EXPIRED, Payment.PAUSED]) $ do
    driverPlan <- QDP.findByMandateId mandateId >>= fromMaybeM (NoDriverPlanForMandate mandateId.getId)
    driver <- B.runInReplica $ QP.findById driverPlan.driverId >>= fromMaybeM (PersonDoesNotExist driverPlan.driverId.getId)
    Redis.whenWithLockRedis (mandateProcessingLockKey mandateId.getId) 60 $ do
      QM.updateMandateDetails mandateId DM.INACTIVE Nothing Nothing Nothing mandatePaymentFlow --- did this because only update payer vpa on transaction charged
      QDP.updatePaymentModeByDriverId (cast driverPlan.driverId) DP.MANUAL
      DI.updateAutoPayStatusAndPayerVpa (castAutoPayStatus mandateStatus) Nothing (cast driverPlan.driverId)
      when (mandateStatus == Payment.PAUSED) $ do
        QDF.updateAllExecutionPendingToManualOverdueByDriverId (cast driver.id)
        notifyPaymentModeManualOnPause driver.merchantId driver.id driver.deviceToken
      when (mandateStatus == Payment.REVOKED) $ do
        QDF.updateAllExecutionPendingToManualOverdueByDriverId (cast driver.id)
        notifyPaymentModeManualOnCancel driver.merchantId driver.id driver.deviceToken
  where
    castAutoPayStatus = \case
      Payment.CREATED -> Just DI.PENDING
      Payment.ACTIVE -> Just DI.ACTIVE
      Payment.REVOKED -> Just DI.CANCELLED_PSP
      Payment.PAUSED -> Just DI.PAUSED_PSP
      Payment.FAILURE -> Just DI.MANDATE_FAILED
      Payment.EXPIRED -> Just DI.MANDATE_EXPIRED
    mkMandate payerApp payerAppName mandatePaymentFlow = do
      now <- getCurrentTime
      return $
        DM.Mandate
          { id = mandateId,
            status = DM.INACTIVE,
            createdAt = now,
            updatedAt = now,
            payerApp,
            payerAppName,
            mandatePaymentFlow,
            ..
          }
