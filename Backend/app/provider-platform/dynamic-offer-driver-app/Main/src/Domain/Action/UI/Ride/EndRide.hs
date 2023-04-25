{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}

module Domain.Action.UI.Ride.EndRide
  ( ServiceHandle (..),
    DriverEndRideReq (..),
    CallBasedEndRideReq (..),
    DashboardEndRideReq (..),
    callBasedEndRide,
    buildEndRideHandle,
    driverEndRide,
    dashboardEndRide,
  )
where

import qualified Domain.Action.UI.Ride.EndRide.Internal as RideEndInt
import qualified Domain.Types.Booking as SRB
import qualified Domain.Types.DriverLocation as DrLoc
import Domain.Types.FareParameters as Fare
import Domain.Types.FarePolicy (FarePolicy)
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Merchant.TransporterConfig as DTConf
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Ride as DRide
import qualified Domain.Types.RiderDetails as RD
import Domain.Types.SlabFarePolicy (SlabFarePolicy)
import Domain.Types.Vehicle.Variant (Variant)
import Environment (Flow)
import EulerHS.Prelude hiding (pi)
import Kernel.External.Maps
import Kernel.Prelude (roundToIntegral)
import qualified Kernel.Types.APISuccess as APISuccess
import Kernel.Types.Common
import Kernel.Types.Id
import Kernel.Utils.CalculateDistance (distanceBetweenInMeters)
import Kernel.Utils.Common
import qualified Lib.LocationUpdates as LocUpd
import qualified SharedLogic.CallBAP as CallBAP
import qualified SharedLogic.DriverLocation as DrLoc
import qualified SharedLogic.FareCalculator as Fare
import qualified Storage.CachedQueries.FarePolicy as FarePolicyS
import qualified Storage.CachedQueries.Merchant as MerchantS
import qualified Storage.CachedQueries.Merchant.TransporterConfig as QTConf
import qualified Storage.CachedQueries.SlabFarePolicy as SFarePolicyS
import qualified Storage.Queries.Booking as QRB
import qualified Storage.Queries.Ride as QRide
import Tools.Error

data EndRideReq = DriverReq DriverEndRideReq | DashboardReq DashboardEndRideReq | CallBasedReq CallBasedEndRideReq

data DriverEndRideReq = DriverEndRideReq
  { point :: LatLong,
    requestor :: DP.Person
  }

data DashboardEndRideReq = DashboardEndRideReq
  { point :: Maybe LatLong,
    merchantId :: Id DM.Merchant
  }

newtype CallBasedEndRideReq = CallBasedEndRideReq
  { requestor :: DP.Person
  }

data ServiceHandle m = ServiceHandle
  { findBookingById :: Id SRB.Booking -> m (Maybe SRB.Booking),
    findRideById :: Id DRide.Ride -> m (Maybe DRide.Ride),
    getMerchant :: Id DM.Merchant -> m (Maybe DM.Merchant),
    endRideTransaction :: Id DP.Driver -> Id SRB.Booking -> DRide.Ride -> Maybe FareParameters -> Maybe (Id RD.RiderDetails) -> m (),
    notifyCompleteToBAP :: SRB.Booking -> DRide.Ride -> Fare.FareParameters -> m (),
    getFarePolicy :: Id DM.Merchant -> Variant -> Maybe Meters -> m (Either FarePolicy SlabFarePolicy),
    calculateFare ::
      Id DM.Merchant ->
      Either FarePolicy SlabFarePolicy ->
      Meters ->
      UTCTime ->
      Maybe Money ->
      Maybe Money ->
      Maybe Money ->
      m Fare.FareParameters,
    putDiffMetric :: Id DM.Merchant -> Money -> Meters -> m (),
    findDriverLoc :: Id DP.Person -> m (Maybe DrLoc.DriverLocation),
    isDistanceCalculationFailed :: Id DP.Person -> m Bool,
    finalDistanceCalculation :: Id DRide.Ride -> Id DP.Person -> LatLong -> m (),
    findConfig :: m (Maybe DTConf.TransporterConfig),
    whenWithLocationUpdatesLock :: Id DP.Person -> m () -> m (),
    getDistanceBetweenPoints :: LatLong -> LatLong -> m Meters
  }

buildEndRideHandle :: Id DM.Merchant -> Flow (ServiceHandle Flow)
buildEndRideHandle merchantId = do
  defaultRideInterpolationHandler <- LocUpd.buildRideInterpolationHandler merchantId True
  return $
    ServiceHandle
      { findBookingById = QRB.findById,
        findRideById = QRide.findById,
        getMerchant = MerchantS.findById,
        getFarePolicy = getFarePolicyByMerchantIdAndVariant,
        notifyCompleteToBAP = CallBAP.sendRideCompletedUpdateToBAP,
        endRideTransaction = RideEndInt.endRideTransaction,
        calculateFare = Fare.calculateFare,
        putDiffMetric = RideEndInt.putDiffMetric,
        findDriverLoc = DrLoc.findById,
        isDistanceCalculationFailed = LocUpd.isDistanceCalculationFailed defaultRideInterpolationHandler,
        finalDistanceCalculation = LocUpd.finalDistanceCalculation defaultRideInterpolationHandler,
        findConfig = QTConf.findByMerchantId merchantId,
        whenWithLocationUpdatesLock = LocUpd.whenWithLocationUpdatesLock,
        getDistanceBetweenPoints = RideEndInt.getDistanceBetweenPoints merchantId
      }

getFarePolicyByMerchantIdAndVariant :: Id DM.Merchant -> Variant -> Maybe Meters -> Flow (Either FarePolicy SlabFarePolicy)
getFarePolicyByMerchantIdAndVariant merchantId variant mbDistance = do
  merchant <- MerchantS.findById merchantId >>= fromMaybeM (MerchantNotFound merchantId.getId)
  case merchant.farePolicyType of
    Fare.SLAB -> do
      slabFarePolicy <- SFarePolicyS.findByMerchantIdAndVariant merchantId variant >>= fromMaybeM (InternalError "Slab fare policy not found")
      return $ Right slabFarePolicy
    Fare.NORMAL -> do
      farePolicy <- FarePolicyS.findByMerchantIdAndVariant merchantId variant mbDistance >>= fromMaybeM (InternalError "Normal fare policy not found")
      return $ Left farePolicy

driverEndRide ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) =>
  ServiceHandle m ->
  Id DRide.Ride ->
  DriverEndRideReq ->
  m APISuccess.APISuccess
driverEndRide handle rideId req =
  withLogTag ("requestorId-" <> req.requestor.id.getId)
    . endRide handle rideId
    $ DriverReq req

callBasedEndRide ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) =>
  ServiceHandle m ->
  Id DRide.Ride ->
  CallBasedEndRideReq ->
  m APISuccess.APISuccess
callBasedEndRide handle rideId = endRide handle rideId . CallBasedReq

dashboardEndRide ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) =>
  ServiceHandle m ->
  Id DRide.Ride ->
  DashboardEndRideReq ->
  m APISuccess.APISuccess
dashboardEndRide handle rideId req =
  withLogTag ("merchantId-" <> req.merchantId.getId)
    . endRide handle rideId
    $ DashboardReq req

endRide ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) =>
  ServiceHandle m ->
  Id DRide.Ride ->
  EndRideReq ->
  m APISuccess.APISuccess
endRide handle@ServiceHandle {..} rideId req = withLogTag ("rideId-" <> rideId.getId) do
  rideOld <- findRideById (cast rideId) >>= fromMaybeM (RideDoesNotExist rideId.getId)
  let driverId = rideOld.driverId
  booking <- findBookingById rideOld.bookingId >>= fromMaybeM (BookingNotFound rideOld.bookingId.getId)
  case req of
    DriverReq driverReq -> do
      let requestor = driverReq.requestor
      case requestor.role of
        DP.DRIVER -> unless (requestor.id == driverId) $ throwError NotAnExecutor
        _ -> throwError AccessDenied
    DashboardReq dashboardReq -> do
      unless (booking.providerId == dashboardReq.merchantId) $ throwError (RideDoesNotExist rideOld.id.getId)
    CallBasedReq callBasedEndRideReq -> do
      let requestor = callBasedEndRideReq.requestor
      case requestor.role of
        DP.DRIVER -> unless (requestor.id == driverId) $ throwError NotAnExecutor
        _ -> throwError AccessDenied

  unless (rideOld.status == DRide.INPROGRESS) $ throwError $ RideInvalidStatus "This ride cannot be ended"

  tripEndPoint <- case req of
    DriverReq driverReq -> do
      logTagInfo "driver -> endRide : " ("DriverId " <> getId driverId <> ", RideId " <> getId rideOld.id)
      pure driverReq.point
    DashboardReq dashboardReq -> do
      logTagInfo "dashboard -> endRide : " ("DriverId " <> getId driverId <> ", RideId " <> getId rideOld.id)
      case dashboardReq.point of
        Just point -> pure point
        Nothing -> do
          driverLocation <- findDriverLoc driverId >>= fromMaybeM LocationNotFound
          pure $ getCoordinates driverLocation
    CallBasedReq _ -> do
      pure $ getCoordinates booking.toLocation

  whenWithLocationUpdatesLock driverId $ do
    -- here we update the current ride, so below we fetch the updated version
    finalDistanceCalculation rideOld.id driverId tripEndPoint
    ride <- findRideById (cast rideId) >>= fromMaybeM (RideDoesNotExist rideId.getId)

    now <- getCurrentTime

    distanceCalculationFailed <- isDistanceCalculationFailed driverId
    when distanceCalculationFailed $ logWarning $ "Failed to calculate distance for this ride: " <> ride.id.getId

    pickupDropOutsideOfThreshold <- isPickupDropOutsideOfThreshold handle booking ride tripEndPoint
    (chargeableDistance, finalFare, mbUpdatedFareParams) <-
      if distanceCalculationFailed
        then calculateFinalValuesForFailedDistanceCalculations handle booking ride tripEndPoint now pickupDropOutsideOfThreshold
        else calculateFinalValuesForCorrectDistanceCalculations handle booking ride now booking.maxEstimatedDistance pickupDropOutsideOfThreshold
    let newFareParams = fromMaybe booking.fareParams mbUpdatedFareParams
    let updRide =
          ride{tripEndTime = Just now,
               chargeableDistance = Just chargeableDistance,
               fare = Just finalFare,
               tripEndPos = Just tripEndPoint,
               fareParametersId = Just newFareParams.id,
               distanceCalculationFailed = Just distanceCalculationFailed
              }
    -- we need to store fareParams only when they changed
    endRideTransaction (cast @DP.Person @DP.Driver driverId) booking.id updRide mbUpdatedFareParams booking.riderId

    notifyCompleteToBAP booking updRide newFareParams
  return APISuccess.Success

recalculateFareForDistance :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> Meters -> Bool -> m (Meters, Money, Maybe FareParameters)
recalculateFareForDistance handle@ServiceHandle {..} booking ride recalcDistance hasRideEndedEarly = do
  let transporterId = booking.providerId
      oldDistance = booking.estimatedDistance
      estimatedFare = Fare.fareSum booking.fareParams
  farePolicy <- getFarePolicy transporterId booking.vehicleVariant (Just booking.estimatedDistance)
  let penaltyFare = bool Nothing (Just $ getEndRidePenaltyFare booking recalcDistance farePolicy) hasRideEndedEarly
  fareParams <- calculateFare transporterId farePolicy recalcDistance booking.startTime booking.fareParams.driverSelectedFare booking.fareParams.customerExtraFee penaltyFare
  waitingCharge <- case farePolicy of
    Left normalFarePolicy -> getWaitingFare handle ride.tripStartTime ride.driverArrivalTime normalFarePolicy.waitingChargePerMin
    Right _ -> pure 0
  let updatedFare = Fare.fareSum fareParams
      finalFare = updatedFare + waitingCharge
      distanceDiff = recalcDistance - oldDistance
      fareDiff = abs (finalFare - estimatedFare) -- fareDiff is the penalty we are imposing on half of the remaining distance which user did not travelled than estimated.
  logTagInfo "Fare recalculation" $
    "Fare difference: "
      <> show (realToFrac @_ @Double fareDiff)
      <> ", Distance difference: "
      <> show distanceDiff
      <> ", Final Fare: "
      <> show finalFare
  return (recalcDistance, finalFare, Just fareParams)

getWaitingFare :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> Maybe UTCTime -> Maybe UTCTime -> Maybe Money -> m Money
getWaitingFare ServiceHandle {..} mbTripStartTime mbDriverArrivalTime waitingChargePerMin = do
  thresholdConfig <- findConfig >>= fromMaybeM (InternalError "TransportConfigNotFound")
  let waitingTimeThreshold = thresholdConfig.waitingTimeEstimatedThreshold
      driverWaitingTime = fromMaybe 0 (diffUTCTime <$> mbTripStartTime <*> mbDriverArrivalTime)
      fareableWaitingTime = max 0 (driverWaitingTime / 60 - fromIntegral waitingTimeThreshold)
  pure $ roundToIntegral fareableWaitingTime * fromMaybe 0 waitingChargePerMin

isPickupDropOutsideOfThreshold :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> LatLong -> m Bool
isPickupDropOutsideOfThreshold ServiceHandle {..} booking ride tripEndPoint = do
  let mbTripStartLoc = ride.tripStartPos
  thresholdConfig <- findConfig >>= fromMaybeM (InternalError "TransportConfigNotFound")
  -- for old trips with mbTripStartLoc = Nothing we always recalculate fare
  case mbTripStartLoc of
    Nothing -> pure True
    Just tripStartLoc -> do
      let pickupLocThreshold = metersToHighPrecMeters thresholdConfig.pickupLocThreshold
      let dropLocThreshold = metersToHighPrecMeters thresholdConfig.dropLocThreshold
      let pickupDifference = abs $ distanceBetweenInMeters (getCoordinates booking.fromLocation) tripStartLoc
      let dropDifference = abs $ distanceBetweenInMeters (getCoordinates booking.toLocation) tripEndPoint
      let pickupDropOutsideOfThreshold = (pickupDifference >= pickupLocThreshold) || (dropDifference >= dropLocThreshold)

      logTagInfo "Locations differences" $
        "Pickup difference: "
          <> show pickupDifference
          <> ", Drop difference: "
          <> show dropDifference
          <> ", Locations outside of thresholds: "
          <> show pickupDropOutsideOfThreshold
      pure pickupDropOutsideOfThreshold

getDistanceDiff :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => SRB.Booking -> Meters -> m HighPrecMeters
getDistanceDiff booking distance = do
  let rideDistanceDifference = distance - booking.estimatedDistance
  logTagInfo "RideDistance differences" $
    "Distance Difference: "
      <> show rideDistanceDifference
  pure $ metersToHighPrecMeters rideDistanceDifference

isTimeOutsideOfThreshold :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> UTCTime -> m Bool
isTimeOutsideOfThreshold ServiceHandle {..} booking ride now = do
  thresholdConfig <- findConfig >>= fromMaybeM (InternalError "TransportConfigNotFound")
  case ride.tripStartTime of
    Nothing -> pure False
    Just tripStartTime -> do
      let rideTimeEstimatedThreshold = thresholdConfig.rideTimeEstimatedThreshold
      let estimatedRideDuration = booking.estimatedDuration
      let actualRideDuration = nominalDiffTimeToSeconds $ tripStartTime `diffUTCTime` now
      let rideTimeDifference = actualRideDuration - estimatedRideDuration
      let timeOutsideOfThreshold = (rideTimeDifference >= rideTimeEstimatedThreshold) && (ride.traveledDistance > metersToHighPrecMeters booking.estimatedDistance)
      logTagInfo "endRide" ("timeOutsideOfThreshold: " <> show timeOutsideOfThreshold)
      logTagInfo "RideTime differences" $
        "Time Difference: "
          <> show rideTimeDifference
          <> ", estimatedRideDuration: "
          <> show estimatedRideDuration
          <> ", actualRideDuration: "
          <> show actualRideDuration
      pure timeOutsideOfThreshold

calculateFinalValuesForCorrectDistanceCalculations ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> UTCTime -> Maybe HighPrecMeters -> Bool -> m (Meters, Money, Maybe FareParameters)
calculateFinalValuesForCorrectDistanceCalculations handle booking ride now mbMaxDistance pickupDropOutsideOfThreshold = do
  distanceDiff <- getDistanceDiff booking (highPrecMetersToMeters ride.traveledDistance)
  thresholdConfig <- handle.findConfig >>= fromMaybeM (InternalError "TransportConfigNotFound")
  let maxDistance = fromMaybe ride.traveledDistance mbMaxDistance + thresholdConfig.upwardsRecomputeBuffer
  if not pickupDropOutsideOfThreshold
    then
      if distanceDiff > thresholdConfig.actualRideDistanceDiffThreshold
        then recalculateFareForDistance handle booking ride (roundToIntegral $ min ride.traveledDistance maxDistance) False
        else returnEstimatesAsFinalValues handle booking ride
    else
      if distanceDiff < 0
        then
          if ride.traveledDistance > metersToHighPrecMeters thresholdConfig.pickupLocThreshold
            then recalculateFareForDistance handle booking ride (roundToIntegral ride.traveledDistance) True
            else recalculateFareForDistance handle booking ride (roundToIntegral ride.traveledDistance) False
        else
          if distanceDiff < thresholdConfig.actualRideDistanceDiffThreshold
            then do
              timeOutsideOfThreshold <- isTimeOutsideOfThreshold handle booking ride now
              if timeOutsideOfThreshold
                then recalculateFareForDistance handle booking ride (booking.estimatedDistance) False
                else returnEstimatesAsFinalValues handle booking ride
            else recalculateFareForDistance handle booking ride (roundToIntegral ride.traveledDistance) False

calculateFinalValuesForFailedDistanceCalculations ::
  (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> LatLong -> UTCTime -> Bool -> m (Meters, Money, Maybe FareParameters)
calculateFinalValuesForFailedDistanceCalculations handle@ServiceHandle {..} booking ride tripEndPoint now pickupDropOutsideOfThreshold = do
  let tripStartPoint = case ride.tripStartPos of
        Nothing -> getCoordinates booking.fromLocation
        Just tripStartPos -> tripStartPos
  approxTraveledDistance <- getDistanceBetweenPoints tripStartPoint tripEndPoint
  distanceDiff <- getDistanceDiff booking approxTraveledDistance
  thresholdConfig <- findConfig >>= fromMaybeM (InternalError "TransportConfigNotFound")

  if not pickupDropOutsideOfThreshold
    then returnEstimatesAsFinalValues handle booking ride
    else
      if distanceDiff < 0
        then
          if approxTraveledDistance > thresholdConfig.pickupLocThreshold
            then recalculateFareForDistance handle booking ride approxTraveledDistance True
            else recalculateFareForDistance handle booking ride approxTraveledDistance False
        else
          if distanceDiff < thresholdConfig.actualRideDistanceDiffThreshold
            then do
              timeOutsideOfThreshold <- isTimeOutsideOfThreshold handle booking ride now
              if timeOutsideOfThreshold
                then recalculateFareForDistance handle booking ride (booking.estimatedDistance) False
                else returnEstimatesAsFinalValues handle booking ride
            else do
              if distanceDiff < thresholdConfig.approxRideDistanceDiffThreshold
                then recalculateFareForDistance handle booking ride approxTraveledDistance False
                else recalculateFareForDistance handle booking ride (booking.estimatedDistance + highPrecMetersToMeters thresholdConfig.approxRideDistanceDiffThreshold) False

returnEstimatesAsFinalValues :: (MonadThrow m, Log m, MonadTime m, MonadGuid m) => ServiceHandle m -> SRB.Booking -> DRide.Ride -> m (Meters, Money, Maybe FareParameters)
returnEstimatesAsFinalValues handle booking ride = do
  waitingCharge <- getWaitingFare handle ride.tripStartTime ride.driverArrivalTime booking.fareParams.waitingChargePerMin
  pure (booking.estimatedDistance, booking.estimatedFare + waitingCharge, Nothing)

getEndRidePenaltyFare :: SRB.Booking -> Meters -> Either FarePolicy SlabFarePolicy -> Money
getEndRidePenaltyFare _ _ (Right _) = Money 0
getEndRidePenaltyFare booking travelledDistance (Left normalFarePolicy) = do
  let halfUntraveledDistance = (booking.estimatedDistance - travelledDistance) `div` 2
  let penaltyDistance =
        if travelledDistance < normalFarePolicy.baseDistanceMeters
          then max (travelledDistance + halfUntraveledDistance - normalFarePolicy.baseDistanceMeters) 0
          else halfUntraveledDistance
  let penaltyFare :: Money = roundToIntegral $ realToFrac ((realToFrac penaltyDistance :: Rational) / 1000) * normalFarePolicy.perExtraKmFare
  min (Money 50) (maybe penaltyFare (\selectedFare -> max (penaltyFare - selectedFare) (Money 0)) booking.fareParams.driverSelectedFare)
