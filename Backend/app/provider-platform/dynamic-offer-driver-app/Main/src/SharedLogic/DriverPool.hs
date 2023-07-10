{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingVia #-}

module SharedLogic.DriverPool
  ( calculateDriverPool,
    calculateDriverPoolWithActualDist,
    calculateDriverCurrentlyOnRideWithActualDist,
    calculateDriverPoolCurrentlyOnRide,
    changeIntoDriverPoolResult,
    incrementTotalQuotesCount,
    incrementQuoteAcceptedCount,
    decrementTotalQuotesCount,
    getTotalQuotesSent,
    getLatestAcceptanceRatio,
    incrementTotalRidesCount,
    isThresholdRidesCompleted,
    incrementCancellationCount,
    getLatestCancellationRatio,
    getCurrentWindowAvailability,
    getQuotesCount,
    getPopupDelay,
    getValidSearchRequestCount,
    removeSearchReqIdFromMap,
    updateDriverSpeedInRedis,
    getDriverAverageSpeed,
    mkAvailableTimeKey,
    mkBlockListedDriversKey,
    PoolCalculationStage (..),
    module Reexport,
  )
where

import Data.Fixed
import Data.List (partition)
import Data.List.Extra (notNull)
import qualified Data.List.NonEmpty as NE
import qualified Domain.Types.Merchant as DM
import Domain.Types.Merchant.DriverIntelligentPoolConfig (IntelligentScores (IntelligentScores))
import qualified Domain.Types.Merchant.DriverIntelligentPoolConfig as DIPC
import Domain.Types.Merchant.DriverPoolConfig
import qualified Domain.Types.Person as DP
import Domain.Types.SearchRequest
import Domain.Types.SearchTry
import Domain.Types.Vehicle.Variant (Variant)
import qualified EulerHS.Language as L
import EulerHS.Prelude hiding (id)
import qualified Kernel.Storage.Esqueleto as Esq
import Kernel.Storage.Esqueleto.Config (EsqLocRepDBFlow)
import Kernel.Storage.Hedis
import qualified Kernel.Storage.Hedis as Redis
import Kernel.Types.Error
import Kernel.Types.Id
import qualified Kernel.Types.SlidingWindowCounters as SWC
import qualified Kernel.Utils.CalculateDistance as CD
import Kernel.Utils.Common
import qualified Kernel.Utils.SlidingWindowCounters as SWC
import SharedLogic.DriverPool.Config as Reexport
import SharedLogic.DriverPool.Types as Reexport
import Storage.CachedQueries.CacheConfig (CacheFlow)
import qualified Storage.CachedQueries.Merchant.DriverIntelligentPoolConfig as DIP
import qualified Storage.CachedQueries.Merchant.TransporterConfig as CTC
import qualified Storage.Queries.Person as QP
import Tools.Maps as Maps
import Tools.Metrics

data PoolCalculationStage = Estimate | DriverSelection

mkTotalQuotesKey :: Text -> Text
mkTotalQuotesKey driverId = "driver-offer:DriverPool:Total-quotes:DriverId-" <> driverId

mkQuotesAcceptedKey :: Text -> Text
mkQuotesAcceptedKey driverId = "driver-offer:DriverPool:Quote-accepted:DriverId-" <> driverId

mkTotalRidesKey :: Text -> Text
mkTotalRidesKey driverId = "driver-offer:DriverPool:Total-Rides:DriverId-" <> driverId

mkRideCancelledKey :: Text -> Text
mkRideCancelledKey driverId = "driver-offer:DriverPool:Ride-cancelled:DriverId-" <> driverId

mkOldRatioKey :: Text -> Text -> Text
mkOldRatioKey driverId ratioType = "driver-offer:DriverPool:" <> ratioType <> ":DriverId-" <> driverId

mkAvailableTimeKey :: Text -> Text
mkAvailableTimeKey driverId = "driver-offer:DriverPool:Available-Time:DriverId-" <> driverId

windowFromIntelligentPoolConfig :: (L.MonadFlow m, EsqDBFlow m r, CacheFlow m r) => Id DM.Merchant -> (DIPC.DriverIntelligentPoolConfig -> SWC.SlidingWindowOptions) -> m SWC.SlidingWindowOptions
windowFromIntelligentPoolConfig merchantId windowKey = maybe defaultWindow windowKey <$> DIP.findByMerchantId merchantId
  where
    defaultWindow = SWC.SlidingWindowOptions 7 SWC.Days

withAcceptanceRatioWindowOption ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  (SWC.SlidingWindowOptions -> m a) ->
  m a
withAcceptanceRatioWindowOption merchantId fn = windowFromIntelligentPoolConfig merchantId (.acceptanceRatioWindowOption) >>= fn

withCancellationRatioWindowOption ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  (SWC.SlidingWindowOptions -> m a) ->
  m a
withCancellationRatioWindowOption merchantId fn = windowFromIntelligentPoolConfig merchantId (.cancellationRatioWindowOption) >>= fn

withAvailabilityTimeWindowOption ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  (SWC.SlidingWindowOptions -> m a) ->
  m a
withAvailabilityTimeWindowOption merchantId fn = windowFromIntelligentPoolConfig merchantId (.availabilityTimeWindowOption) >>= fn

withMinQuotesToQualifyIntelligentPoolWindowOption ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  (SWC.SlidingWindowOptions -> m a) ->
  m a
withMinQuotesToQualifyIntelligentPoolWindowOption merchantId fn = windowFromIntelligentPoolConfig merchantId (.minQuotesToQualifyForIntelligentPoolWindowOption) >>= fn

decrementTotalQuotesCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  Id SearchTry ->
  m ()
decrementTotalQuotesCount merchantId driverId sreqId = do
  mbSreqCounted <- find (\(srId, (_, isCounted)) -> srId == sreqId.getId && isCounted) <$> getSearchRequestInfoMap merchantId driverId
  whenJust mbSreqCounted $
    const . Redis.withCrossAppRedis $ withAcceptanceRatioWindowOption merchantId $ SWC.decrementWindowCount (mkTotalQuotesKey driverId.getId)

incrementTotalQuotesCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  SearchRequest ->
  UTCTime ->
  ExpirationTime ->
  m ()
incrementTotalQuotesCount merchantId driverId searchReq validTill singleBatchProcessTime = do
  now <- getCurrentTime
  srCount <- getValidSearchRequestCount merchantId (cast driverId) now
  Redis.withCrossAppRedis $ withMinQuotesToQualifyIntelligentPoolWindowOption merchantId $ SWC.incrementWindowCount (mkQuotesCountKey driverId.getId) -- total quotes sent count in different sliding window (used in driver pool for random vs intelligent filtering)
  let shouldCount = srCount < 1
  addSearchRequestInfoToCache searchReq.id merchantId (cast driverId) (validTill, shouldCount) singleBatchProcessTime
  when shouldCount $
    Redis.withCrossAppRedis $ withAcceptanceRatioWindowOption merchantId $ SWC.incrementWindowCount (mkTotalQuotesKey driverId.getId) -- for acceptance ratio calculation

mkParallelSearchRequestKey :: Id DM.Merchant -> Id DP.Driver -> Text
mkParallelSearchRequestKey mId dId = "driver-offer:DriverPool:Search-Req-Validity-Map-" <> mId.getId <> dId.getId

addSearchRequestInfoToCache ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id SearchRequest ->
  Id DM.Merchant ->
  Id DP.Driver ->
  (UTCTime, Bool) ->
  Redis.ExpirationTime ->
  m ()
addSearchRequestInfoToCache searchReqId merchantId driverId valueToPut singleBatchProcessTime = do
  Redis.withCrossAppRedis $ Redis.hSetExp (mkParallelSearchRequestKey merchantId driverId) searchReqId.getId valueToPut singleBatchProcessTime

getSearchRequestInfoMap ::
  ( Redis.HedisFlow m r,
    MonadReader r m
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m [(Text, (UTCTime, Bool))]
getSearchRequestInfoMap mId dId = Redis.withCrossAppRedis $ Redis.hGetAll $ mkParallelSearchRequestKey mId dId

getValidSearchRequestCount ::
  ( Redis.HedisFlow m r,
    MonadReader r m
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  UTCTime ->
  m Int
getValidSearchRequestCount merchantId driverId now = Redis.withCrossAppRedis $ do
  searchRequestValidityMap <- getSearchRequestInfoMap merchantId driverId
  let (valid, old) = partition ((> now) . fst . snd) searchRequestValidityMap
  when (notNull old) $ Redis.hDel (mkParallelSearchRequestKey merchantId driverId) (map fst old)
  pure $ length valid

removeSearchReqIdFromMap ::
  ( Redis.HedisFlow m r,
    MonadTime m
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  Id SearchTry ->
  m ()
removeSearchReqIdFromMap merchantId driverId = Redis.withCrossAppRedis . Redis.hDel (mkParallelSearchRequestKey merchantId $ cast driverId) . (: []) .(.getId)

incrementQuoteAcceptedCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  m ()
incrementQuoteAcceptedCount merchantId driverId = Redis.withCrossAppRedis . withAcceptanceRatioWindowOption merchantId $ SWC.incrementWindowCount (mkQuotesAcceptedKey driverId.getId)

getTotalQuotesSent ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  m Int
getTotalQuotesSent merchantId driverId =
  sum . catMaybes <$> (Redis.withCrossAppRedis . withAcceptanceRatioWindowOption merchantId $ SWC.getCurrentWindowValues (mkTotalQuotesKey driverId.getId))

getLatestAcceptanceRatio ::
  ( EsqDBFlow m r,
    CacheFlow m r,
    Redis.HedisFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m Double
getLatestAcceptanceRatio merchantId driverId = Redis.withCrossAppRedis . withAcceptanceRatioWindowOption merchantId $ SWC.getLatestRatio (getId driverId) mkQuotesAcceptedKey mkTotalQuotesKey (mkOldRatioKey "AcceptanceRatio")

incrementTotalRidesCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  m ()
incrementTotalRidesCount merchantId driverId = Redis.withCrossAppRedis . withCancellationRatioWindowOption merchantId $ SWC.incrementWindowCount (mkTotalRidesKey driverId.getId)

getTotalRidesCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m Int
getTotalRidesCount merchantId driverId = sum . catMaybes <$> (Redis.withCrossAppRedis . withCancellationRatioWindowOption merchantId $ SWC.getCurrentWindowValues (mkTotalRidesKey driverId.getId))

incrementCancellationCount ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  m ()
incrementCancellationCount merchantId driverId = Redis.withCrossAppRedis . withCancellationRatioWindowOption merchantId $ SWC.incrementWindowCount (mkRideCancelledKey driverId.getId)

getLatestCancellationRatio' ::
  ( EsqDBFlow m r,
    CacheFlow m r,
    Redis.HedisFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m Double
getLatestCancellationRatio' merchantId driverId = Redis.withCrossAppRedis . withCancellationRatioWindowOption merchantId $ SWC.getLatestRatio driverId.getId mkRideCancelledKey mkTotalRidesKey (mkOldRatioKey "CancellationRatio")

getLatestCancellationRatio ::
  ( EsqDBFlow m r,
    CacheFlow m r,
    Redis.HedisFlow m r
  ) =>
  CancellationScoreRelatedConfig ->
  Id DM.Merchant ->
  Id DP.Driver ->
  m Double
getLatestCancellationRatio cancellationScoreRelatedConfig merchantId driverId = do
  isThresholdRidesDone <- isThresholdRidesCompleted driverId merchantId cancellationScoreRelatedConfig
  if isThresholdRidesDone
    then getLatestCancellationRatio' merchantId driverId
    else pure 0

getCurrentWindowAvailability ::
  ( Redis.HedisFlow m r,
    EsqDBFlow m r,
    CacheFlow m r,
    FromJSON a
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m [Maybe a]
getCurrentWindowAvailability merchantId driverId = Redis.withCrossAppRedis . withAvailabilityTimeWindowOption merchantId $ SWC.getCurrentWindowValues (mkAvailableTimeKey driverId.getId)

mkQuotesCountKey :: Text -> Text
mkQuotesCountKey driverId = "driver-offer:DriverPool:Total-quotes-sent:DriverId-" <> driverId

getQuotesCount ::
  ( FromJSON a,
    CacheFlow m r,
    EsqDBFlow m r,
    Num a
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  m a
getQuotesCount merchantId driverId = sum . catMaybes <$> (Redis.withCrossAppRedis . withMinQuotesToQualifyIntelligentPoolWindowOption merchantId $ SWC.getCurrentWindowValues (mkQuotesCountKey driverId.getId))

isThresholdRidesCompleted ::
  ( CacheFlow m r,
    EsqDBFlow m r
  ) =>
  Id DP.Driver ->
  Id DM.Merchant ->
  CancellationScoreRelatedConfig ->
  m Bool
isThresholdRidesCompleted driverId merchantId cancellationScoreRelatedConfig = do
  let minRidesForCancellationScore = fromMaybe 5 cancellationScoreRelatedConfig.minRidesForCancellationScore
  totalRides <- getTotalRidesCount merchantId driverId
  pure $ totalRides >= minRidesForCancellationScore

getPopupDelay ::
  ( CacheFlow m r,
    EsqDBFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Driver ->
  Double ->
  CancellationScoreRelatedConfig ->
  Seconds ->
  m Seconds
getPopupDelay merchantId driverId cancellationRatio cancellationScoreRelatedConfig defaultPopupDelay = do
  let cancellationRatioThreshold = fromIntegral $ fromMaybe 40 cancellationScoreRelatedConfig.thresholdCancellationScore
  (defaultPopupDelay +)
    <$> if cancellationRatio * 100 > cancellationRatioThreshold
      then do
        isThresholdRidesDone <- isThresholdRidesCompleted driverId merchantId cancellationScoreRelatedConfig
        pure $
          if isThresholdRidesDone
            then fromMaybe (Seconds 0) cancellationScoreRelatedConfig.popupDelayToAddAsPenalty
            else Seconds 0
      else pure $ Seconds 0

mkDriverLocationUpdatesKey :: Id DM.Merchant -> Id DP.Person -> Text
mkDriverLocationUpdatesKey mId dId = "driver-offer:DriverPool:mId-" <> mId.getId <> ":dId:" <> dId.getId

updateDriverSpeedInRedis ::
  ( CacheFlow m r,
    EsqDBFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  LatLong ->
  UTCTime ->
  m ()
updateDriverSpeedInRedis merchantId driverId points timeStamp = Redis.withCrossAppRedis $ do
  locationUpdateSampleTime <- maybe 3 (.locationUpdateSampleTime) <$> DIP.findByMerchantId merchantId
  now <- getCurrentTime
  let driverLocationUpdatesKey = mkDriverLocationUpdatesKey merchantId driverId
  locationUpdatesList :: [(LatLong, UTCTime)] <-
    sortOn (Down . snd)
      . ((points, timeStamp) :)
      . filter
        ( \(_, time) ->
            time > addUTCTime (fromIntegral $ (-60) * locationUpdateSampleTime.getMinutes) now
        )
      . concat
      <$> Redis.safeGet driverLocationUpdatesKey
  Redis.set driverLocationUpdatesKey locationUpdatesList

getDriverAverageSpeed ::
  ( CacheFlow m r,
    EsqDBFlow m r
  ) =>
  Id DM.Merchant ->
  Id DP.Person ->
  m Double
getDriverAverageSpeed merchantId driverId = Redis.withCrossAppRedis $ do
  intelligentPoolConfig <- DIP.findByMerchantId merchantId
  let minLocationUpdates = maybe 3 (.minLocationUpdates) intelligentPoolConfig
      defaultDriverSpeed = maybe 27.0 (.defaultDriverSpeed) intelligentPoolConfig
  let driverLocationUpdatesKey = mkDriverLocationUpdatesKey merchantId driverId
  locationUpdatesList :: [(LatLong, UTCTime)] <- concat <$> Redis.safeGet driverLocationUpdatesKey
  let locationUpdatesCount = length locationUpdatesList
  if locationUpdatesCount > minLocationUpdates
    then do
      let locationUpdatesPairs = zip (drop 1 locationUpdatesList) (take (locationUpdatesCount - 1) locationUpdatesList)
          (totalDistanceTravelled, totalTimeTaken) :: (HighPrecMeters, Centi) =
            foldr
              ( \((locationA, timeA), (locationB, timeB)) (accDis, accTime) -> do
                  let distance = CD.distanceBetweenInMeters locationB locationA
                      timeTaken = fromInteger . floor $ diffUTCTime timeB timeA
                  (accDis + distance, accTime + timeTaken)
              )
              (0, 0)
              locationUpdatesPairs
      pure . fromRational . toRational $ totalDistanceTravelled.getHighPrecMeters.getCenti / totalTimeTaken
    else pure defaultDriverSpeed

mkBlockListedDriversKey :: Id SearchRequest -> Text
mkBlockListedDriversKey searchReqId = "Block-Listed-Drivers-Key:SearchRequestId-" <> searchReqId.getId

calculateDriverPool ::
  ( EncFlow m r,
    CacheFlow m r,
    EsqDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    EsqLocRepDBFlow m r,
    CoreMetrics m,
    L.MonadFlow m,
    HasCoordinates a
  ) =>
  PoolCalculationStage ->
  DriverPoolConfig ->
  Maybe Variant ->
  a ->
  Id DM.Merchant ->
  Bool ->
  Maybe PoolRadiusStep ->
  m [DriverPoolResult]
calculateDriverPool poolStage driverPoolCfg mbVariant pickup merchantId onlyNotOnRide mRadiusStep = do
  let radius = getRadius mRadiusStep
  let coord = getCoordinates pickup
  now <- getCurrentTime
  approxDriverPool <-
    measuringDurationToLog INFO "calculateDriverPool" $
      QP.getNearestDrivers
        mbVariant
        coord
        radius
        merchantId
        onlyNotOnRide
        driverPoolCfg.driverPositionInfoExpiry
  driversWithLessThanNParallelRequests <- case poolStage of
    DriverSelection -> filterM (fmap (< driverPoolCfg.maxParallelSearchRequests) . getParallelSearchRequestCount now) approxDriverPool
    Estimate -> pure approxDriverPool --estimate stage we dont need to consider actual parallel request counts
  pure $ makeDriverPoolResult <$> driversWithLessThanNParallelRequests
  where
    getParallelSearchRequestCount now dObj = getValidSearchRequestCount merchantId (cast dObj.driverId) now
    getRadius mRadiusStep_ = do
      let maxRadius = fromIntegral driverPoolCfg.maxRadiusOfSearch
      case mRadiusStep_ of
        Just radiusStep -> do
          let minRadius = fromIntegral driverPoolCfg.minRadiusOfSearch
          let radiusStepSize = fromIntegral driverPoolCfg.radiusStepSize
          min (minRadius + radiusStepSize * radiusStep) maxRadius
        Nothing -> maxRadius
    makeDriverPoolResult :: QP.NearestDriversResult -> DriverPoolResult
    makeDriverPoolResult QP.NearestDriversResult {..} = do
      DriverPoolResult
        { distanceToPickup = distanceToDriver,
          variant = variant,
          ..
        }

calculateDriverPoolWithActualDist ::
  ( EncFlow m r,
    CacheFlow m r,
    EsqDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    EsqLocRepDBFlow m r,
    CoreMetrics m,
    HasCoordinates a
  ) =>
  PoolCalculationStage ->
  DriverPoolConfig ->
  Maybe Variant ->
  a ->
  Id DM.Merchant ->
  Bool ->
  Maybe PoolRadiusStep ->
  m [DriverPoolWithActualDistResult]
calculateDriverPoolWithActualDist poolCalculationStage driverPoolCfg mbVariant pickup merchantId onlyNotOnRide mRadiusStep = do
  driverPool <- calculateDriverPool poolCalculationStage driverPoolCfg mbVariant pickup merchantId onlyNotOnRide mRadiusStep
  case driverPool of
    [] -> return []
    (a : pprox) -> do
      driverPoolWithActualDist <- computeActualDistance merchantId pickup (a :| pprox)
      let filtDriverPoolWithActualDist = case driverPoolCfg.actualDistanceThreshold of
            Nothing -> NE.toList driverPoolWithActualDist
            Just threshold -> NE.filter (filterFunc threshold) driverPoolWithActualDist
      logDebug $ "secondly filtered driver pool" <> show filtDriverPoolWithActualDist
      return filtDriverPoolWithActualDist
  where
    filterFunc threshold estDist = getMeters estDist.actualDistanceToPickup <= fromIntegral threshold

calculateDriverPoolCurrentlyOnRide ::
  ( EncFlow m r,
    CacheFlow m r,
    EsqDBFlow m r,
    EsqLocRepDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    CoreMetrics m,
    L.MonadFlow m,
    HasCoordinates a
  ) =>
  PoolCalculationStage ->
  DriverPoolConfig ->
  Maybe Variant ->
  a ->
  Id DM.Merchant ->
  Maybe PoolRadiusStep ->
  Int ->
  m [DriverPoolResultCurrentlyOnRide]
calculateDriverPoolCurrentlyOnRide poolStage driverPoolCfg mbVariant pickup merchantId mRadiusStep reduceRadiusValue = do
  let radius = getRadius mRadiusStep
  let coord = getCoordinates pickup
  now <- getCurrentTime
  approxDriverPool <-
    measuringDurationToLog INFO "calculateDriverPoolCurrentlyOnRide" $
      -- Esq.runInReplica $
      QP.getNearestDriversCurrentlyOnRide
        mbVariant
        coord
        radius
        merchantId
        driverPoolCfg.driverPositionInfoExpiry
        reduceRadiusValue
  driversWithLessThanNParallelRequests <- case poolStage of
    DriverSelection -> filterM (fmap (< driverPoolCfg.maxParallelSearchRequests) . getParallelSearchRequestCount now) approxDriverPool
    Estimate -> pure approxDriverPool --estimate stage we dont need to consider actual parallel request counts
  pure $ makeDriverPoolResult <$> driversWithLessThanNParallelRequests
  where
    getParallelSearchRequestCount now dObj = getValidSearchRequestCount merchantId (cast dObj.driverId) now
    getRadius mRadiusStep_ = do
      let maxRadius = fromIntegral driverPoolCfg.maxRadiusOfSearch
      case mRadiusStep_ of
        Just radiusStep -> do
          let minRadius = fromIntegral driverPoolCfg.minRadiusOfSearch
          let radiusStepSize = fromIntegral driverPoolCfg.radiusStepSize
          min (minRadius + radiusStepSize * radiusStep) maxRadius
        Nothing -> maxRadius
    makeDriverPoolResult :: QP.NearestDriversResultCurrentlyOnRide -> DriverPoolResultCurrentlyOnRide
    makeDriverPoolResult QP.NearestDriversResultCurrentlyOnRide {..} =
      DriverPoolResultCurrentlyOnRide
        { distanceToPickup = distanceToDriver,
          ..
        }

calculateDriverCurrentlyOnRideWithActualDist ::
  ( EncFlow m r,
    CacheFlow m r,
    EsqDBFlow m r,
    Esq.EsqDBReplicaFlow m r,
    EsqLocRepDBFlow m r,
    CoreMetrics m,
    HasCoordinates a
  ) =>
  PoolCalculationStage ->
  DriverPoolConfig ->
  Maybe Variant ->
  a ->
  Id DM.Merchant ->
  Maybe PoolRadiusStep ->
  Int ->
  m [DriverPoolWithActualDistResult]
calculateDriverCurrentlyOnRideWithActualDist poolCalculationStage driverPoolCfg mbVariant pickup merchantId mRadiusStep reduceRadiusValue = do
  driverPool <- calculateDriverPoolCurrentlyOnRide poolCalculationStage driverPoolCfg mbVariant pickup merchantId mRadiusStep reduceRadiusValue
  case driverPool of
    [] -> return []
    (a : pprox) -> do
      let driverPoolResultsWithDriverLocationAsDestinationLocation = driverResultFromDestinationLocation <$> (a :| pprox)
          driverToDestinationDistanceThreshold = driverPoolCfg.driverToDestinationDistanceThreshold
      driverPoolWithActualDistFromDestinationLocation <- computeActualDistance merchantId pickup driverPoolResultsWithDriverLocationAsDestinationLocation
      driverPoolWithActualDistFromCurrentLocation <- traverse (calculateActualDistanceCurrently driverToDestinationDistanceThreshold) (a :| pprox)
      let driverPoolWithActualDist = NE.zipWith (curry combine) driverPoolWithActualDistFromDestinationLocation driverPoolWithActualDistFromCurrentLocation
          filtDriverPoolWithActualDist = case driverPoolCfg.actualDistanceThreshold of
            Nothing -> NE.toList driverPoolWithActualDist
            Just threshold -> NE.filter (filterFunc threshold) driverPoolWithActualDist
      logDebug $ "secondly filtered driver pool result currently on ride" <> show filtDriverPoolWithActualDist
      return filtDriverPoolWithActualDist
  where
    filterFunc threshold estDist = getMeters estDist.actualDistanceToPickup <= fromIntegral threshold
    driverResultFromDestinationLocation DriverPoolResultCurrentlyOnRide {..} =
      DriverPoolResult
        { driverId = driverId,
          language = language,
          driverDeviceToken = driverDeviceToken,
          distanceToPickup = distanceToPickup,
          variant = variant,
          lat = destinationLat,
          lon = destinationLon,
          mode = mode
        }
    calculateActualDistanceCurrently driverToDestinationDistanceThreshold DriverPoolResultCurrentlyOnRide {..} = do
      let temp = DriverPoolResult {..}
      if distanceFromDriverToDestination < driverToDestinationDistanceThreshold
        then do
          transporter <- CTC.findByMerchantId merchantId >>= fromMaybeM (TransporterConfigNotFound merchantId.getId)
          let defaultPopupDelay = fromMaybe 2 transporter.popupDelayToAddAsPenalty
          let time = driverPoolCfg.driverToDestinationDuration
          pure
            DriverPoolWithActualDistResult
              { driverPoolResult = temp,
                actualDistanceToPickup = distanceFromDriverToDestination,
                actualDurationToPickup = time,
                intelligentScores = IntelligentScores Nothing Nothing Nothing Nothing Nothing defaultPopupDelay,
                isPartOfIntelligentPool = False,
                keepHiddenForSeconds = Seconds 0
              }
        else computeActualDistanceOneToOne merchantId (LatLong destinationLat destinationLon) temp
    combine (DriverPoolWithActualDistResult {actualDistanceToPickup = x, actualDurationToPickup = y}, DriverPoolWithActualDistResult {..}) =
      DriverPoolWithActualDistResult
        { actualDistanceToPickup = x + actualDistanceToPickup,
          actualDurationToPickup = y + actualDurationToPickup,
          ..
        }

computeActualDistanceOneToOne ::
  ( CoreMetrics m,
    CacheFlow m r,
    EsqDBFlow m r,
    EncFlow m r,
    HasCoordinates a
  ) =>
  Id DM.Merchant ->
  a ->
  DriverPoolResult ->
  m DriverPoolWithActualDistResult
computeActualDistanceOneToOne merchantId pickup driverPoolResult = do
  (ele :| _) <- computeActualDistance merchantId pickup (driverPoolResult :| [])
  pure ele

computeActualDistance ::
  ( CoreMetrics m,
    CacheFlow m r,
    EsqDBFlow m r,
    EncFlow m r,
    HasCoordinates a
  ) =>
  Id DM.Merchant ->
  a ->
  NonEmpty DriverPoolResult ->
  m (NonEmpty DriverPoolWithActualDistResult)
computeActualDistance orgId pickup driverPoolResults = do
  let pickupLatLong = getCoordinates pickup
  transporter <- CTC.findByMerchantId orgId >>= fromMaybeM (TransporterConfigDoesNotExist orgId.getId)
  getDistanceResults <-
    Maps.getEstimatedPickupDistances orgId $
      Maps.GetDistancesReq
        { origins = driverPoolResults,
          destinations = pickupLatLong :| [],
          travelMode = Just Maps.CAR
        }
  logDebug $ "get distance results" <> show getDistanceResults
  return $ mkDriverPoolWithActualDistResult transporter.defaultPopupDelay <$> getDistanceResults
  where
    mkDriverPoolWithActualDistResult defaultPopupDelay distDur = do
      DriverPoolWithActualDistResult
        { driverPoolResult = distDur.origin,
          actualDistanceToPickup = distDur.distance,
          actualDurationToPickup = distDur.duration,
          intelligentScores = IntelligentScores Nothing Nothing Nothing Nothing Nothing defaultPopupDelay,
          isPartOfIntelligentPool = False,
          keepHiddenForSeconds = Seconds 0
        }

changeIntoDriverPoolResult :: DriverPoolResultCurrentlyOnRide -> DriverPoolResult
changeIntoDriverPoolResult DriverPoolResultCurrentlyOnRide {..} = DriverPoolResult {..}
