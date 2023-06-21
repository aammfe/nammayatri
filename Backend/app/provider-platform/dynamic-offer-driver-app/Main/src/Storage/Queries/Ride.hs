{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use tuple-section" #-}
{-# HLINT ignore "Use fromRight" #-}

module Storage.Queries.Ride where

import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Ride as Common
import Data.Int
import Data.Time hiding (getCurrentTime)
import qualified Database.Beam as B
import Database.Beam.Postgres
import Domain.Types.Booking as Booking
import Domain.Types.DriverInformation
import Domain.Types.Merchant
import Domain.Types.Person
import Domain.Types.Ride as DR
import Domain.Types.Ride as Ride
import Domain.Types.RideDetails as RideDetails
import Domain.Types.RiderDetails as RiderDetails
import qualified EulerHS.KVConnector.Flow as KV
import EulerHS.KVConnector.Types
import EulerHS.KVConnector.Utils (meshModelTableEntity)
import qualified EulerHS.Language as L
import qualified Kernel.Beam.Types as KBT
import Kernel.External.Encryption
import Kernel.External.Maps.Types (LatLong (..), lat, lon)
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Kernel.Utils.Common
import Lib.Utils (setMeshConfig)
import qualified Sequelize as Se
import qualified Storage.Beam.Booking as BeamB
import qualified Storage.Beam.DriverInformation as BeamDI
import qualified Storage.Beam.Ride.Table as BeamR
import qualified Storage.Queries.Booking as QB
import qualified Storage.Queries.DriverInformation as QDI
import Storage.Tabular.Booking as Booking
import Storage.Tabular.Ride as Ride
import Storage.Tabular.RideDetails as RideDetails
import Storage.Tabular.RiderDetails as RiderDetails
import qualified Prelude

data DatabaseWith2 table1 table2 f = DatabaseWith2
  { dwTable1 :: f (B.TableEntity table1),
    dwTable2 :: f (B.TableEntity table2)
  }
  deriving (Generic, B.Database be)

create :: L.MonadFlow m => Ride.Ride -> m (MeshResult ())
create ride = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> KV.createWoReturingKVConnector dbConf' updatedMeshConfig (transformDomainRideToBeam ride)
    Nothing -> pure (Left $ MKeyNotFound "DB Config not found")

findById :: L.MonadFlow m => Id Ride -> m (Maybe Ride)
findById (Id rideId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.Is BeamR.id $ Se.Eq rideId]
      case result of
        Right ride -> traverse transformBeamRideToDomain ride
        Left _ -> pure Nothing
    Nothing -> pure Nothing

findAllRidesByDriverId ::
  L.MonadFlow m =>
  Id Person ->
  m [Ride]
findAllRidesByDriverId (Id driverId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findAllWithKVConnector dbConf' updatedMeshConfig [Se.Is BeamR.driverId $ Se.Eq driverId]
      case result of
        Right ride -> mapM transformBeamRideToDomain ride
        Left _ -> pure []
    Nothing -> pure []

findActiveByRBId :: L.MonadFlow m => Id Booking -> m (Maybe Ride)
findActiveByRBId (Id rbId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.And [Se.Is BeamR.bookingId $ Se.Eq rbId, Se.Is BeamR.status $ Se.Eq Ride.CANCELLED]]
      case result of
        Right ride -> traverse transformBeamRideToDomain ride
        Left _ -> pure Nothing
    Nothing -> pure Nothing

findAllRidesBookingsByRideId :: L.MonadFlow m => Id Merchant -> [Id Ride] -> m [(Ride, Booking)]
findAllRidesBookingsByRideId (Id merchantId) rideIds = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      res <-
        KV.findAllWithKVConnector
          dbConf'
          updatedMeshConfig
          conditions
      case res of
        Right x -> traverse transformBeamRideToDomain x
        Left _ -> pure []
    Nothing -> pure []

findAllRidesWithSeConditionsCreatedAtDesc :: L.MonadFlow m => [Se.Clause Postgres BeamR.RideT] -> m [Ride]
findAllRidesWithSeConditionsCreatedAtDesc conditions = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      res <-
        KV.findAllWithOptionsKVConnector
          dbConf'
          updatedMeshConfig
          conditions
          (Se.Desc BeamR.createdAt)
          Nothing
          Nothing
      case res of
        Right x -> traverse transformBeamRideToDomain x
        Left _ -> pure []
    Nothing -> pure []

findAllRidesBookingsByRideId :: L.MonadFlow m => Id Merchant -> [Id Ride] -> m [(Ride, Booking)]
findAllRidesBookingsByRideId (Id merchantId) rideIds = do
  rides <- findAllRidesWithSeConditions [Se.Is BeamR.id $ Se.In $ getId <$> rideIds]
  let bookingSeCondition =
        [ Se.And
            [ Se.Is BeamB.id $ Se.In $ getId . DR.bookingId <$> rides,
              Se.Is BeamB.providerId $ Se.Eq merchantId
            ]
        ]
  bookings <- findAllBookingsWithSeConditions bookingSeCondition
  let rideBooking = foldl' (getRideWithBooking bookings) [] rides
  pure rideBooking
  where
    getRideWithBooking bookings acc ride' =
      let bookings' = filter (\x -> x.id == ride'.bookingId) bookings
       in acc <> ((\x -> (ride', x)) <$> bookings')

findAllByDriverId :: (L.MonadFlow m, Log m) => Id Person -> Maybe Integer -> Maybe Integer -> Maybe Bool -> Maybe Ride.RideStatus -> m [(Ride, Booking)]
findAllByDriverId (Id driverId) mbLimit mbOffset mbOnlyActive mbRideStatus = do
  let limitVal = maybe 10 fromInteger mbLimit
      offsetVal = maybe 0 fromInteger mbOffset
      isOnlyActive = Just True == mbOnlyActive
  let rideSeConditions =
        [ Se.And
            ( [Se.Is BeamR.driverId $ Se.Eq driverId]
                <> if isOnlyActive
                  then [Se.Is BeamR.status $ Se.Not $ Se.In [Ride.COMPLETED, Ride.CANCELLED]]
                  else
                    []
                      <> ([Se.Is BeamR.status $ Se.Eq (fromJust mbRideStatus) | isJust mbRideStatus])
            )
        ]
  rides <- findAllRidesWithSeConditionsCreatedAtDesc rideSeConditions
  bookings <- findAllBookingsWithSeConditionsCreatedAtDesc [Se.Is BeamB.id $ Se.In $ getId . DR.bookingId <$> rides]
  let rideWithBooking = foldl' (getRideWithBooking bookings) [] rides
  pure $ take limitVal (drop offsetVal rideWithBooking)
  where
    getRideWithBooking bookings acc ride =
      let bookings' = filter (\b -> b.id == ride.bookingId) bookings
       in acc <> ((\b -> (ride, b)) <$> bookings')

findOneByDriverId :: L.MonadFlow m => Id Person -> m (Maybe Ride)
findOneByDriverId (Id personId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.Is BeamR.driverId $ Se.Eq personId]
      case result of
        Right ride -> traverse transformBeamRideToDomain ride
        Left _ -> pure Nothing
    Nothing -> pure Nothing

getInProgressByDriverId :: L.MonadFlow m => Id Person -> m (Maybe Ride)
getInProgressByDriverId (Id personId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.And [Se.Is BeamR.driverId $ Se.Eq personId, Se.Is BeamR.status $ Se.Eq Ride.INPROGRESS]]
      case result of
        Right ride -> traverse transformBeamRideToDomain ride
        Left _ -> pure Nothing
    Nothing -> pure Nothing

getInProgressOrNewRideIdAndStatusByDriverId :: L.MonadFlow m => Id Person -> m (Maybe (Id Ride, RideStatus))
getInProgressOrNewRideIdAndStatusByDriverId (Id driverId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbCOnf' -> do
      ride <- KV.findWithKVConnector dbCOnf' updatedMeshConfig [Se.And [Se.Is BeamR.driverId $ Se.Eq driverId, Se.Is BeamR.status $ Se.In [Ride.INPROGRESS, Ride.NEW]]]
      case ride of
        Left _ -> pure Nothing
        Right x -> do
          ride' <- traverse transformBeamRideToDomain x
          let rideData = (,) <$> (DR.id <$> ride') <*> (DR.status <$> ride')
          pure rideData
    Nothing -> pure Nothing

getActiveByDriverId :: L.MonadFlow m => Id Person -> m (Maybe Ride)
getActiveByDriverId (Id personId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.And [Se.Is BeamR.driverId $ Se.Eq personId, Se.Is BeamR.status $ Se.In [Ride.INPROGRESS, Ride.NEW]]]
      case result of
        Right ride -> traverse transformBeamRideToDomain ride
        Left _ -> pure Nothing
    Nothing -> pure Nothing

updateStatus :: (L.MonadFlow m, MonadTime m) => Id Ride -> RideStatus -> m (MeshResult ())
updateStatus rideId status = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.status status,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.id (Se.Eq $ getId rideId)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

updateStartTimeAndLoc :: (L.MonadFlow m, MonadTime m) => Id Ride -> LatLong -> m (MeshResult ())
updateStartTimeAndLoc rideId point = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.tripStartTime $ Just now,
          Se.Set BeamR.tripStartLat $ Just point.lat,
          Se.Set BeamR.tripStartLon $ Just point.lon,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.id (Se.Eq $ getId rideId)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

updateStatusByIds :: (L.MonadFlow m, MonadTime m) => [Id Ride] -> RideStatus -> m (MeshResult ())
updateStatusByIds rideIds status = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.status status,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.id (Se.In $ getId <$> rideIds)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

updateDistance :: (L.MonadFlow m, MonadTime m) => Id Person -> HighPrecMeters -> m (MeshResult ())
updateDistance driverId distance = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.traveledDistance distance,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.driverId (Se.Eq $ getId driverId)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

updateAll :: (L.MonadFlow m, MonadTime m) => Id Ride -> Ride -> m (MeshResult ())
updateAll rideId ride = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.chargeableDistance ride.chargeableDistance,
          Se.Set BeamR.fare ride.fare,
          Se.Set BeamR.tripEndTime ride.tripEndTime,
          Se.Set BeamR.tripStartLat (ride.tripEndPos <&> (.lat)),
          Se.Set BeamR.tripStartLon (ride.tripEndPos <&> (.lon)),
          Se.Set BeamR.fareParametersId (getId <$> ride.fareParametersId),
          Se.Set BeamR.distanceCalculationFailed ride.distanceCalculationFailed,
          Se.Set BeamR.pickupDropOutsideOfThreshold ride.pickupDropOutsideOfThreshold,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.id (Se.Eq $ getId rideId)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

getCountByStatus :: (L.MonadFlow m) => Id Merchant -> m [(RideStatus, Int)]
getCountByStatus merchantId = do
  -- Tricky query to be able to insert meaningful Point
  dbConf <- L.getOption KBT.PsqlDbCfg
  conn <- L.getOrInitSqlConn (fromJust dbConf)
  case conn of
    Right c -> do
      resp <- L.runDB c $
        L.findRows $
          B.select $
            B.aggregate_ (\(ride, _) -> (B.group_ (BeamR.status ride), B.as_ @Int B.countAll_)) $
              B.filter_' (\(_, BeamB.BookingT {..}) -> providerId B.==?. B.val_ (getId merchantId)) $
                do
                  ride <- B.all_ (meshModelTableEntity @BeamR.RideT @Postgres @(DatabaseWith2 BeamR.RideT BeamB.BookingT))
                  booking <- B.join_' (meshModelTableEntity @BeamB.BookingT @Postgres @(DatabaseWith2 BeamR.RideT BeamB.BookingT)) (\booking -> BeamB.id booking B.==?. BeamR.bookingId ride)
                  pure (ride, booking)
      pure (either (const []) Prelude.id resp)
    Left _ -> pure []

getRidesForDate :: (L.MonadFlow m, MonadTime m) => Id Person -> Day -> m [Ride]
getRidesForDate driverId date = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  let minDayTime = UTCTime (addDays (-1) date) 66600
  let maxDayTime = UTCTime date 66600
  case dbConf of
    Just dbConf' -> do
      ridesResult <-
        KV.findAllWithKVConnector
          dbConf'
          updatedMeshConfig
          [ Se.And
              [ Se.Is BeamR.driverId $ Se.Eq $ getId driverId,
                Se.Is BeamR.tripEndTime $ Se.GreaterThanOrEq $ Just minDayTime,
                Se.Is BeamR.tripEndTime $ Se.LessThan $ Just maxDayTime,
                Se.Is BeamR.status $ Se.Eq Ride.COMPLETED
              ]
          ]
      case ridesResult of
        Left _ -> pure []
        Right rides -> mapM transformBeamRideToDomain rides
    Nothing -> pure []

updateArrival :: (L.MonadFlow m, MonadTime m) => Id Ride -> m (MeshResult ())
updateArrival rideId = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.driverArrivalTime $ Just now,
          Se.Set BeamR.updatedAt now
        ]
        [Se.Is BeamR.id (Se.Eq $ getId rideId)]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

data RideItem = RideItem
  { rideShortId :: ShortId Ride,
    rideCreatedAt :: UTCTime,
    rideDetails :: RideDetails,
    riderDetails :: RiderDetails,
    customerName :: Maybe Text,
    fareDiff :: Maybe Money,
    bookingStatus :: Common.BookingStatus
  }

-- being used in dashboard so need to create a beam query for this
findAllRideItems ::
  Transactionable m =>
  Id Merchant ->
  Int ->
  Int ->
  Maybe Common.BookingStatus ->
  Maybe (ShortId Ride) ->
  Maybe DbHash ->
  Maybe DbHash ->
  Maybe Money ->
  UTCTime ->
  Maybe UTCTime ->
  Maybe UTCTime ->
  m [RideItem]
findAllRideItems merchantId limitVal offsetVal mbBookingStatus mbRideShortId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now mbFrom mbTo = do
  res <- Esq.findAll $ do
    booking :& ride :& rideDetails :& riderDetails <-
      from $
        table @BookingT
          `innerJoin` table @RideT
            `Esq.on` ( \(booking :& ride) ->
                         ride ^. Ride.RideBookingId ==. booking ^. Booking.BookingTId
                     )
          `innerJoin` table @RideDetailsT
            `Esq.on` ( \(_ :& ride :& rideDetails) ->
                         ride ^. Ride.RideTId ==. rideDetails ^. RideDetails.RideDetailsId
                     )
          `innerJoin` table @RiderDetailsT
            `Esq.on` ( \(booking :& _ :& _ :& riderDetails) ->
                         booking ^. Booking.BookingRiderId ==. just (riderDetails ^. RiderDetails.RiderDetailsTId)
                     )
    let bookingStatusVal = mkBookingStatusVal ride
    where_ $
      booking ^. BookingProviderId ==. val (toKey merchantId)
        &&. whenJust_ mbFrom (\defaultFrom -> ride ^. RideCreatedAt >=. val defaultFrom)
        &&. whenJust_ mbTo (\defaultTo -> ride ^. RideCreatedAt <=. val defaultTo)
        &&. whenJust_ mbBookingStatus (\bookingStatus -> bookingStatusVal ==. val bookingStatus)
        &&. whenJust_ mbRideShortId (\rideShortId -> ride ^. Ride.RideShortId ==. val rideShortId.getShortId)
        &&. whenJust_ mbDriverPhoneDBHash (\hash -> rideDetails ^. RideDetailsDriverNumberHash ==. val (Just hash))
        &&. whenJust_ mbCustomerPhoneDBHash (\hash -> riderDetails ^. RiderDetailsMobileNumberHash ==. val hash)
        &&. whenJust_ mbFareDiff (\fareDiff_ -> (ride ^. Ride.RideFare -. just (booking ^. Booking.BookingEstimatedFare) >. val (Just fareDiff_)) ||. (just (booking ^. Booking.BookingEstimatedFare) -. ride ^. Ride.RideFare) >. val (Just fareDiff_))
    limit $ fromIntegral limitVal
    offset $ fromIntegral offsetVal
    return
      ( ride ^. RideShortId,
        ride ^. RideCreatedAt,
        rideDetails,
        riderDetails,
        booking ^. BookingRiderName,
        ride ^. Ride.RideFare -. just (booking ^. Booking.BookingEstimatedFare),
        bookingStatusVal
      )
  pure $ mkRideItem <$> res
  where
    mkBookingStatusVal ride = do
      -- ride considered as ONGOING_6HRS if ride.status = INPROGRESS, but somehow ride.tripStartTime = Nothing
      let ongoing6HrsCond =
            ride ^. Ride.RideTripStartTime +. just (Esq.interval [Esq.HOUR 6]) <=. val (Just now)
      case_
        [ when_ (ride ^. Ride.RideStatus ==. val Ride.NEW &&. not_ (upcoming6HrsCond ride now)) then_ $ val Common.UPCOMING,
          when_ (ride ^. Ride.RideStatus ==. val Ride.NEW &&. upcoming6HrsCond ride now) then_ $ val Common.UPCOMING_6HRS,
          when_ (ride ^. Ride.RideStatus ==. val Ride.INPROGRESS &&. not_ ongoing6HrsCond) then_ $ val Common.ONGOING,
          when_ (ride ^. Ride.RideStatus ==. val Ride.COMPLETED) then_ $ val Common.COMPLETED,
          when_ (ride ^. Ride.RideStatus ==. val Ride.CANCELLED) then_ $ val Common.CANCELLED
        ]
        (else_ $ val Common.ONGOING_6HRS)

    mkRideItem (rideShortId, rideCreatedAt, rideDetails, riderDetails, customerName, fareDiff, bookingStatus) = do
      RideItem {rideShortId = ShortId rideShortId, ..}

-- where condition implementation remaining
-- findAllRideItems' ::( MonadFlow m, MonadTime m) => Id Merchant -> Int -> Int -> Maybe Common.BookingStatus -> Maybe (ShortId Ride) -> Maybe DbHash -> Maybe DbHash -> Maybe Money -> UTCTime -> m [RideItem]
-- findAllRideItems' (Id merchantId) limitVal offsetVal mbBookingStatus mbRideShortId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now = do
--   dbConf <- L.getOption KBT.PsqlDbCfg
-- let modelName = Se.modelTableName @BeamR.RideT
-- let updatedMeshConfig = setMeshConfig modelName
--   let now6HrBefore = addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now
--   case dbConf of
--     Just dbCOnf' -> do
--       rides <- do
--         ride' <- KV.findAllWithKVConnector dbCOnf' updatedMeshConfig ([] <> ([Se.Is BeamR.shortId $ Se.Eq $ maybe "" getShortId mbRideShortId | isJust mbRideShortId]))
--         case ride' of
--           Left _ -> pure []
--           Right x -> traverse transformBeamRideToDomain x

--       bookings <- do
--         booking' <- KV.findAllWithKVConnector dbCOnf' updatedMeshConfig [Se.And [Se.Is BeamB.id $ Se.In $ getId . DR.bookingId <$> rides,
--           Se.Is BeamB.providerId $ Se.Eq merchantId ]]
--         case booking' of
--           Left _ -> pure []
--           Right x -> traverse QB.transformBeamBookingToDomain x

--       rideDetails <- either (pure []) (QRD.transformBeamRideDetailsToDomain <$>) <$> KV.findAllWithKVConnector dbCOnf' updatedMeshConfig [Se.And ([Se.Is BeamRD.id $ Se.In $ getId . DR.id <$> rides]
--         <> ([Se.Is BeamRD.driverNumberHash $ Se.Eq mbDriverPhoneDBHash | isJust mbDriverPhoneDBHash]))]

--       riderDetails <- either (pure []) (QRRD.transformBeamRiderDetailsToDomain <$>) <$> KV.findAllWithKVConnector dbCOnf' updatedMeshConfig [Se.And ([Se.Is BeamRRD.id $ Se.In $ maybe "" getId . DB.riderId <$> bookings]
--         <> ([Se.Is BeamRRD.mobileNumberHash $ Se.Eq (fromJust mbCustomerPhoneDBHash) | isJust mbCustomerPhoneDBHash]))]

--       let rideWithBooking = foldl' (getRideWithBooking bookings) [] rides
--       -- let filteredRideWithBooking = if isJust mbFareDiff then filter (\(ride, booking) -> ((\fareDiff_ -> (((-) <$> (ride.fare) <*> Just (booking.estimatedFare)) > fareDiff_ || ((Just booking.estimatedFare -) <*> ride.fare) > fareDiff_) mbFareDiff)) rideWithBooking else rideWithBooking
--       let filteredRideWithBooking = if isJust mbFareDiff then filter (\(ride, booking) -> ( ( (fromJust ride.fare) - booking.estimatedFare) > fromJust mbFareDiff) || ((booking.estimatedFare - (fromJust ride.fare)) > fromJust mbFareDiff) ) rideWithBooking else rideWithBooking
--       let filterRideBookingStatus = if isJust mbBookingStatus then filter (\(ride, booking) ->
--               booking.status == fromJust mbBookingStatus) filteredRideWithBooking else filteredRideWithBooking

--       pure []

--     Nothing -> pure []

--   where
--   getRideWithBooking bookings acc ride =
--       let bookings' = filter (\b -> b.id == ride.bookingId) bookings
--        in acc <> ((\b -> (ride, b)) <$> bookings')
--   getStatus ride bookingStatus = case ride.status of
--     Ride.NEW -> if ride.tripStartTime < Just now6HrBefore then Common.UPCOMING_6HRS else Common.UPCOMING
--     Ride.INPROGRESS -> Common.ONGOING
--     Ride.COMPLETED -> Common.COMPLETED
--     Ride.CANCELLED -> Common.CANCELLED

upcoming6HrsCond :: SqlExpr (Entity RideT) -> UTCTime -> SqlExpr (Esq.Value Bool)
upcoming6HrsCond ride now = ride ^. Ride.RideCreatedAt +. Esq.interval [Esq.HOUR 6] <=. val now

data StuckRideItem = StuckRideItem
  { rideId :: Id Ride,
    bookingId :: Id Booking,
    driverId :: Id Person,
    driverActive :: Bool
  }

findStuckRideItems :: (L.MonadFlow m, MonadTime m) => Id Merchant -> [Id Booking] -> UTCTime -> m [StuckRideItem]
findStuckRideItems (Id merchantId) bookingIds now = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RideT
  let updatedMeshConfig = setMeshConfig modelName
  let now6HrBefore = addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now
  case dbConf of
    Just dbCOnf' -> do
      rides <- do
        res <-
          KV.findAllWithKVConnector
            dbCOnf'
            updatedMeshConfig
            [ Se.And
                [ Se.Is BeamR.status $ Se.Eq Ride.NEW,
                  Se.Is BeamR.createdAt $ Se.LessThanOrEq now6HrBefore
                ]
            ]
        case res of
          Left _ -> pure []
          Right x -> traverse transformBeamRideToDomain x
      let bookingSeCondition =
            [ Se.And
                [ Se.Is BeamB.id $ Se.In $ getId . DR.bookingId <$> rides,
                  Se.Is BeamB.providerId $ Se.Eq merchantId,
                  Se.Is BeamB.id $ Se.In $ getId <$> bookingIds
                ]
            ]
      bookings <- findAllBookingsWithSeConditions bookingSeCondition
      driverInfos <- findAllDriverInfromationFromRides rides
      let rideBooking = foldl' (getRideWithBooking bookings) [] rides
      let rideBookingDriverInfo = foldl' (getRideWithBookingDriverInfo driverInfos) [] rideBooking

      pure $ mkStuckRideItem <$> rideBookingDriverInfo
    Nothing -> pure []
  where
    getRideWithBooking bookings acc ride' =
      let bookings' = filter (\x -> x.id == ride'.bookingId) bookings
       in acc <> ((\x -> (ride', x.id)) <$> bookings')

    getRideWithBookingDriverInfo driverInfos acc (ride', booking') =
      let driverInfos' = filter (\x -> x.driverId == ride'.driverId) driverInfos
       in acc <> ((\x -> (ride'.id, booking', x.driverId, x.active)) <$> driverInfos')

    mkStuckRideItem (rideId, bookingId, driverId, driverActive) = StuckRideItem {..}

transformBeamRideToDomain :: L.MonadFlow m => BeamR.Ride -> m Ride
transformBeamRideToDomain BeamR.RideT {..} = do
  tUrl <- parseBaseUrl trackingUrl
  pure
    Ride
      { id = Id id,
        bookingId = Id bookingId,
        shortId = ShortId shortId,
        merchantId = Id <$> merchantId,
        status = status,
        driverId = Id driverId,
        otp = otp,
        trackingUrl = tUrl,
        fare = fare,
        traveledDistance = traveledDistance,
        chargeableDistance = chargeableDistance,
        driverArrivalTime = driverArrivalTime,
        tripStartTime = tripStartTime,
        tripEndTime = tripEndTime,
        tripStartPos = LatLong <$> tripStartLat <*> tripStartLon,
        tripEndPos = LatLong <$> tripEndLat <*> tripEndLon,
        pickupDropOutsideOfThreshold = pickupDropOutsideOfThreshold,
        fareParametersId = Id <$> fareParametersId,
        distanceCalculationFailed = distanceCalculationFailed,
        createdAt = createdAt,
        updatedAt = updatedAt
      }

transformDomainRideToBeam :: Ride -> BeamR.Ride
transformDomainRideToBeam Ride {..} =
  BeamR.RideT
    { BeamR.id = getId id,
      BeamR.bookingId = getId bookingId,
      BeamR.shortId = getShortId shortId,
      BeamR.merchantId = getId <$> merchantId,
      BeamR.status = status,
      BeamR.driverId = getId driverId,
      BeamR.otp = otp,
      BeamR.trackingUrl = showBaseUrl trackingUrl,
      BeamR.fare = fare,
      BeamR.traveledDistance = traveledDistance,
      BeamR.chargeableDistance = chargeableDistance,
      BeamR.driverArrivalTime = driverArrivalTime,
      BeamR.tripStartTime = tripStartTime,
      BeamR.tripEndTime = tripEndTime,
      BeamR.tripStartLat = lat <$> tripStartPos,
      BeamR.tripEndLat = lat <$> tripEndPos,
      BeamR.tripStartLon = lon <$> tripStartPos,
      BeamR.tripEndLon = lon <$> tripEndPos,
      pickupDropOutsideOfThreshold = pickupDropOutsideOfThreshold,
      BeamR.fareParametersId = getId <$> fareParametersId,
      BeamR.distanceCalculationFailed = distanceCalculationFailed,
      BeamR.createdAt = createdAt,
      BeamR.updatedAt = updatedAt
    }
