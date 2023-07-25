{-# HLINT ignore "Use tuple-section" #-}
{-# HLINT ignore "Redundant bracket" #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE InstanceSigs #-}
{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-missing-methods #-}
{-# OPTIONS_GHC -Wno-orphans #-}
{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

module Storage.Queries.Ride where

import Control.Applicative (liftA2)
import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Ride as Common
import Data.Either
import Data.Int
import Data.List (zip7)
import Data.Time hiding (getCurrentTime)
import qualified Database.Beam as B
import Database.Beam.Backend (autoSqlValueSyntax)
import qualified Database.Beam.Backend as BeamBackend
import Database.Beam.Postgres
import Domain.Types.Booking as Booking
import Domain.Types.Booking as DBooking
import Domain.Types.DriverInformation
import Domain.Types.Merchant
import Domain.Types.Person
import Domain.Types.Ride as DR
import Domain.Types.Ride as Ride
import Domain.Types.RideDetails as RideDetails
import Domain.Types.RiderDetails as RiderDetails
import EulerHS.KVConnector.Utils (meshModelTableEntity)
import qualified EulerHS.Language as L
import Kernel.External.Encryption
import Kernel.External.Maps.Types (LatLong (..), lat, lon)
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Common ()
import Kernel.Types.Id
import Kernel.Utils.Common
import Lib.Utils
  ( FromTType' (fromTType'),
    ToTType' (toTType'),
    createWithKV,
    findAllWithKV,
    findAllWithOptionsKV,
    findOneWithKV,
    getMasterBeamConfig,
    updateOneWithKV,
    updateWithKV,
  )
import qualified Sequelize as Se
import qualified Storage.Beam.Booking as BeamB
import qualified Storage.Beam.Common as BeamCommon
import qualified Storage.Beam.DriverInformation as BeamDI
import qualified Storage.Beam.Ride.Table as BeamR
import qualified Storage.Beam.RideDetails as BeamRD
import qualified Storage.Beam.RiderDetails as BeamRDR
import Storage.Queries.Booking ()
import Storage.Queries.Instances.DriverInformation ()
import Storage.Queries.RideDetails ()
import Storage.Queries.RiderDetails ()
import Storage.Tabular.Booking as Booking
import Storage.Tabular.Ride as Ride
import Storage.Tabular.RideDetails as RideDetails
import Storage.Tabular.RiderDetails as RiderDetails

data DatabaseWith2 table1 table2 f = DatabaseWith2
  { dwTable1 :: f (B.TableEntity table1),
    dwTable2 :: f (B.TableEntity table2)
  }
  deriving (Generic, B.Database be)

data DatabaseWith4 table1 table2 table3 table4 f = DatabaseWith4
  { dwTable1 :: f (B.TableEntity table1),
    dwTable2 :: f (B.TableEntity table2),
    dwTable3 :: f (B.TableEntity table3),
    dwTable4 :: f (B.TableEntity table4)
  }
  deriving (Generic, B.Database be)

create :: (L.MonadFlow m, Log m) => Ride.Ride -> m ()
create = createWithKV

findById :: (L.MonadFlow m, Log m) => Id Ride -> m (Maybe Ride)
findById (Id rideId) = findOneWithKV [Se.Is BeamR.id $ Se.Eq rideId]

findAllRidesByDriverId ::
  (L.MonadFlow m, Log m) =>
  Id Person ->
  m [Ride]
findAllRidesByDriverId (Id driverId) = findAllWithKV [Se.Is BeamR.driverId $ Se.Eq driverId]

findActiveByRBId :: (L.MonadFlow m, Log m) => Id Booking -> m (Maybe Ride)
findActiveByRBId (Id rbId) = findOneWithKV [Se.And [Se.Is BeamR.bookingId $ Se.Eq rbId, Se.Is BeamR.status $ Se.Eq Ride.CANCELLED]]

findAllRidesWithSeConditionsCreatedAtDesc :: (L.MonadFlow m, Log m) => [Se.Clause Postgres BeamR.RideT] -> m [Ride]
findAllRidesWithSeConditionsCreatedAtDesc conditions = findAllWithOptionsKV conditions (Se.Desc BeamR.createdAt) Nothing Nothing

findAllDriverInfromationFromRides :: (L.MonadFlow m, Log m) => [Ride] -> m [DriverInformation]
findAllDriverInfromationFromRides rides = findAllWithKV [Se.And [Se.Is BeamDI.driverId $ Se.In $ getId . DR.driverId <$> rides]]

findAllBookingsWithSeConditions :: (L.MonadFlow m, Log m) => [Se.Clause Postgres BeamB.BookingT] -> m [Booking]
findAllBookingsWithSeConditions = findAllWithKV

findAllBookingsWithSeConditionsCreatedAtDesc :: (L.MonadFlow m, Log m) => [Se.Clause Postgres BeamB.BookingT] -> m [Booking]
findAllBookingsWithSeConditionsCreatedAtDesc conditions = findAllWithOptionsKV conditions (Se.Desc BeamB.createdAt) Nothing Nothing

findAllRidesWithSeConditions :: (L.MonadFlow m, Log m) => [Se.Clause Postgres BeamR.RideT] -> m [Ride]
findAllRidesWithSeConditions = findAllWithKV

findAllRidesBookingsByRideId :: (L.MonadFlow m, Log m) => Id Merchant -> [Id Ride] -> m [(Ride, Booking)]
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

findAllByDriverId :: (L.MonadFlow m, Log m) => Id Person -> Maybe Integer -> Maybe Integer -> Maybe Bool -> Maybe Ride.RideStatus -> Maybe Day -> m [(Ride, Booking)]
findAllByDriverId (Id driverId) mbLimit mbOffset mbOnlyActive mbRideStatus mbDay = do
  let limitVal = maybe 10 fromInteger mbLimit
      offsetVal = maybe 0 fromInteger mbOffset
      isOnlyActive = Just True == mbOnlyActive
  rides <-
    findAllWithOptionsKV
      [ Se.And
          ( [Se.Is BeamR.driverId $ Se.Eq driverId]
              <> if isOnlyActive
                then [Se.Is BeamR.status $ Se.Not $ Se.In [Ride.COMPLETED, Ride.CANCELLED]]
                else
                  []
                    <> ([Se.Is BeamR.status $ Se.Eq (fromJust mbRideStatus) | isJust mbRideStatus])
                    <> ([Se.And [Se.Is BeamR.tripEndTime $ Se.GreaterThanOrEq (Just (minDayTime (fromJust mbDay))), Se.Is BeamR.tripEndTime $ Se.LessThanOrEq (Just (maxDayTime (fromJust mbDay)))] | isJust mbDay])
          )
      ]
      (Se.Desc BeamR.createdAt)
      Nothing
      Nothing
  bookings <- findAllWithOptionsKV [Se.Is BeamB.id $ Se.In $ getId . DR.bookingId <$> rides] (Se.Desc BeamB.createdAt) Nothing Nothing

  let rideWithBooking = foldl' (getRideWithBooking bookings) [] rides
  pure $ take limitVal (drop offsetVal rideWithBooking)
  where
    getRideWithBooking bookings acc ride =
      let bookings' = filter (\b -> b.id == ride.bookingId) bookings
       in acc <> ((\b -> (ride, b)) <$> bookings')
    minDayTime date = UTCTime (addDays (-1) date) 66600
    maxDayTime date = UTCTime date 66600

-- findAllByDriverId ::
--   Transactionable m =>
--   Id Person ->
--   Maybe Integer ->
--   Maybe Integer ->
--   Maybe Bool ->
--   Maybe Ride.RideStatus ->
--   Maybe Day ->
--   m [(Ride, Booking)]
-- findAllByDriverId driverId mbLimit mbOffset mbOnlyActive mbRideStatus mbDay = Esq.buildDType $ do
--   let limitVal = fromIntegral $ fromMaybe 10 mbLimit
--       offsetVal = fromIntegral $ fromMaybe 0 mbOffset
--       isOnlyActive = Just True == mbOnlyActive
--   res <- Esq.findAll' $ do
--     (booking :& ride) <-
--       from $
--         table @BookingT
--           `innerJoin` table @RideT
--             `Esq.on` ( \(booking :& ride) ->
--                          ride ^. Ride.RideBookingId ==. booking ^. Booking.BookingTId
--                      )
--     where_ $
--       ride ^. RideDriverId ==. val (toKey driverId)
--         &&. whenTrue_ isOnlyActive (not_ $ ride ^. RideStatus `in_` valList [Ride.COMPLETED, Ride.CANCELLED])
--         &&. whenJust_ mbRideStatus (\status -> ride ^. RideStatus ==. val status)
--         &&. whenJust_ mbDay (\date -> ride ^. RideTripEndTime >=. val (Just (minDayTime date)) &&. ride ^. RideTripEndTime <. val (Just (maxDayTime date)))
--     orderBy [desc $ ride ^. RideCreatedAt]
--     limit limitVal
--     offset offsetVal
--     return (booking, ride)

--   catMaybes
--     <$> forM
--       res
--       ( \(bookingT, rideT) -> runMaybeT do
--           booking <- MaybeT $ buildFullBooking bookingT
--           return (extractSolidType @Ride rideT, booking)
--       )
--   where
--     minDayTime date = UTCTime (addDays (-1) date) 66600
--     maxDayTime date = UTCTime date 66600

findOneByDriverId :: (L.MonadFlow m, Log m) => Id Person -> m (Maybe Ride)
findOneByDriverId (Id personId) = findOneWithKV [Se.Is BeamR.driverId $ Se.Eq personId]

getInProgressByDriverId :: (L.MonadFlow m, Log m) => Id Person -> m (Maybe Ride)
getInProgressByDriverId (Id personId) = findOneWithKV [Se.And [Se.Is BeamR.driverId $ Se.Eq personId, Se.Is BeamR.status $ Se.Eq Ride.INPROGRESS]]

getInProgressOrNewRideIdAndStatusByDriverId :: (L.MonadFlow m, Log m) => Id Person -> m (Maybe (Id Ride, RideStatus))
getInProgressOrNewRideIdAndStatusByDriverId (Id driverId) = do
  ride' <- findOneWithKV [Se.And [Se.Is BeamR.driverId $ Se.Eq driverId, Se.Is BeamR.status $ Se.In [Ride.INPROGRESS, Ride.NEW]]]
  let rideData = (,) <$> (DR.id <$> ride') <*> (DR.status <$> ride')
  pure rideData

getActiveByDriverId :: (L.MonadFlow m, Log m) => Id Person -> m (Maybe Ride)
getActiveByDriverId (Id personId) =
  findOneWithKV [Se.And [Se.Is BeamR.driverId $ Se.Eq personId, Se.Is BeamR.status $ Se.In [Ride.INPROGRESS, Ride.NEW]]]

updateStatus :: (L.MonadFlow m, MonadTime m, Log m) => Id Ride -> RideStatus -> m ()
updateStatus rideId status = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamR.status status,
      Se.Set BeamR.updatedAt now
    ]
    [Se.Is BeamR.id (Se.Eq $ getId rideId)]

updateStartTimeAndLoc :: (L.MonadFlow m, MonadTime m, Log m) => Id Ride -> LatLong -> m ()
updateStartTimeAndLoc rideId point = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamR.tripStartTime $ Just now,
      Se.Set BeamR.tripStartLat $ Just point.lat,
      Se.Set BeamR.tripStartLon $ Just point.lon,
      Se.Set BeamR.updatedAt now
    ]
    [Se.Is BeamR.id (Se.Eq $ getId rideId)]

updateStatusByIds :: (L.MonadFlow m, MonadTime m, Log m) => [Id Ride] -> RideStatus -> m ()
updateStatusByIds rideIds status = do
  now <- getCurrentTime
  updateWithKV
    [ Se.Set BeamR.status status,
      Se.Set BeamR.updatedAt now
    ]
    [Se.Is BeamR.id (Se.In $ getId <$> rideIds)]

updateDistance :: (L.MonadFlow m, MonadTime m, Log m) => Id Person -> HighPrecMeters -> m ()
updateDistance driverId distance = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamR.traveledDistance distance,
      Se.Set BeamR.updatedAt now
    ]
    [Se.Is BeamR.driverId (Se.Eq $ getId driverId)]

updateAll :: (L.MonadFlow m, MonadTime m, Log m) => Id Ride -> Ride -> m ()
updateAll rideId ride = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamR.chargeableDistance ride.chargeableDistance,
      Se.Set BeamR.fare ride.fare,
      Se.Set BeamR.tripEndTime ride.tripEndTime,
      Se.Set BeamR.tripStartLat (ride.tripEndPos <&> (.lat)),
      Se.Set BeamR.tripStartLon (ride.tripEndPos <&> (.lon)),
      Se.Set BeamR.fareParametersId (getId <$> ride.fareParametersId),
      Se.Set BeamR.distanceCalculationFailed ride.distanceCalculationFailed,
      Se.Set BeamR.pickupDropOutsideOfThreshold ride.pickupDropOutsideOfThreshold,
      Se.Set BeamR.updatedAt now,
      Se.Set BeamR.numberOfDeviation ride.numberOfDeviation
    ]
    [Se.Is BeamR.id (Se.Eq $ getId rideId)]

getCountByStatus :: (L.MonadFlow m) => Id Merchant -> m [(RideStatus, Int)]
getCountByStatus merchantId = do
  -- Tricky query to be able to insert meaningful Point
  dbConf <- getMasterBeamConfig
  resp <- L.runDB dbConf $
    L.findRows $
      B.select $
        B.aggregate_ (\(ride, _) -> (B.group_ (BeamR.status ride), B.as_ @Int B.countAll_)) $
          B.filter_' (\(_, BeamB.BookingT {..}) -> providerId B.==?. B.val_ (getId merchantId)) $
            do
              ride <- B.all_ (meshModelTableEntity @BeamR.RideT @Postgres @(DatabaseWith2 BeamR.RideT BeamB.BookingT))
              booking <- B.join_' (meshModelTableEntity @BeamB.BookingT @Postgres @(DatabaseWith2 BeamR.RideT BeamB.BookingT)) (\booking -> BeamB.id booking B.==?. BeamR.bookingId ride)
              pure (ride, booking)
  pure (fromRight [] resp)

getRidesForDate :: (L.MonadFlow m, MonadTime m, Log m) => Id Person -> Day -> Seconds -> m [Ride]
getRidesForDate driverId date diffTime = do
  let minDayTime = UTCTime (addDays (-1) date) (86400 - secondsToDiffTime (toInteger diffTime.getSeconds))
  let maxDayTime = UTCTime date (secondsToDiffTime $ toInteger diffTime.getSeconds)
  findAllWithKV
    [ Se.And
        [ Se.Is BeamR.driverId $ Se.Eq $ getId driverId,
          Se.Is BeamR.tripEndTime $ Se.GreaterThanOrEq $ Just minDayTime,
          Se.Is BeamR.tripEndTime $ Se.LessThan $ Just maxDayTime,
          Se.Is BeamR.status $ Se.Eq Ride.COMPLETED
        ]
    ]

updateArrival :: (L.MonadFlow m, MonadTime m, Log m) => Id Ride -> m ()
updateArrival rideId = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamR.driverArrivalTime $ Just now,
      Se.Set BeamR.updatedAt now
    ]
    [Se.Is BeamR.id (Se.Eq $ getId rideId)]

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
findAllRideItems' ::
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
findAllRideItems' merchantId limitVal offsetVal mbBookingStatus mbRideShortId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now mbFrom mbTo = do
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
      booking ^. BookingProviderId ==. val (toKey merchantId) -- d
        &&. whenJust_ mbFrom (\defaultFrom -> ride ^. RideCreatedAt >=. val defaultFrom) -- d
        &&. whenJust_ mbTo (\defaultTo -> ride ^. RideCreatedAt <=. val defaultTo) -- d
        &&. whenJust_ mbBookingStatus (\bookingStatus -> bookingStatusVal ==. val bookingStatus)
        &&. whenJust_ mbRideShortId (\rideShortId -> ride ^. Ride.RideShortId ==. val rideShortId.getShortId) -- d
        &&. whenJust_ mbDriverPhoneDBHash (\hash -> rideDetails ^. RideDetailsDriverNumberHash ==. val (Just hash)) -- d
        &&. whenJust_ mbCustomerPhoneDBHash (\hash -> riderDetails ^. RiderDetailsMobileNumberHash ==. val hash) -- d
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

instance Num Money => Num (Maybe Money) where
  (-) :: Maybe Money -> Maybe Money -> Maybe Money
  Nothing - Nothing = Nothing
  Just a - Just b = Just (a - b)
  Nothing - (Just _) = Nothing
  Just _ - Nothing = Nothing

instance BeamBackend.BeamSqlBackend be => B.HasSqlEqualityCheck be Common.BookingStatus

instance BeamBackend.HasSqlValueSyntax be String => BeamBackend.HasSqlValueSyntax be Common.BookingStatus where
  sqlValueSyntax = autoSqlValueSyntax

findAllRideItems ::
  (L.MonadFlow m, Log m) =>
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
  dbConf <- getMasterBeamConfig
  res <- L.runDB dbConf $
    L.findRows $
      B.select $
        B.limit_ (fromIntegral limitVal) $
          B.offset_ (fromIntegral offsetVal) $
            B.filter_'
              ( \(booking, ride, rideDetails, riderDetails) ->
                  booking.providerId B.==?. B.val_ (getId merchantId)
                    B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\rideShortId -> ride.shortId B.==?. B.val_ (getShortId rideShortId)) mbRideShortId
                    -- B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> person.mobileNumberHash B.==?. B.val_ (Just hash)) mbCustomerPhoneDBHash
                    B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> riderDetails.mobileNumberHash B.==?. B.val_ (hash)) mbCustomerPhoneDBHash
                    B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> rideDetails.driverNumberHash B.==?. B.val_ (Just hash)) mbDriverPhoneDBHash
                    -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\driverMobileNumber -> ride.driverMobileNumber B.==?. B.val_ (driverMobileNumber)) mbDriverPhone)
                    B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\defaultFrom -> B.sqlBool_ $ ride.createdAt B.>=. B.val_ (defaultFrom)) mbFrom)
                    B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\defaultTo -> B.sqlBool_ $ ride.createdAt B.<=. B.val_ (defaultTo)) mbTo)
                    -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\fareDiff_ -> B.sqlBool_ $ ride.fare B.<=. booking.estimatedFare) mbFareDiff)
                    B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\bookingStatus -> mkBookingStatusVal ride B.==?. B.val_ (bookingStatus)) mbBookingStatus)
                    B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\fareDiff_ -> B.sqlBool_ $ (ride.fare - (B.just_ booking.estimatedFare)) B.>=. (B.val_ $ Just fareDiff_))) mbFareDiff
              )
              -- B.&&?. B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW) (booking.status B.val_ Common.RCOMPLETED) (B.val_ Common.RCANCELLED)) $
              do
                booking' <- B.all_ (BeamCommon.booking BeamCommon.atlasDB)
                ride' <- B.join_' (BeamCommon.ride BeamCommon.atlasDB) (\ride'' -> BeamR.bookingId ride'' B.==?. BeamB.id booking')
                rideDetails' <- B.join_' (BeamCommon.rideDetails BeamCommon.atlasDB) (\rideDetails'' -> ride'.id B.==?. (BeamRD.id rideDetails''))
                riderDetails' <- B.join_' (BeamCommon.rDetails BeamCommon.atlasDB) (\riderDetails'' -> (B.just_ (BeamRDR.id riderDetails'')) B.==?. (BeamB.riderId booking'))
                pure (booking', ride', rideDetails', riderDetails')
  res' <- case res of
    Right x -> do
      let bookings = fst' <$> x
          rides = snd' <$> x
          rideDetails = thd' <$> x
          riderDetails = fth' <$> x
      b <- catMaybes <$> (mapM fromTType' (bookings))
      r <- catMaybes <$> (mapM fromTType' (rides))
      rd <- catMaybes <$> (mapM fromTType' (rideDetails))
      rdr <- catMaybes <$> (mapM fromTType' (riderDetails))
      pure $ zip7 (DR.shortId <$> r) (DR.createdAt <$> r) rd rdr (DBooking.riderName <$> b) (liftA2 (-) (DR.fare <$> r) (Just . DBooking.estimatedFare <$> b)) (mkBookingStatus now <$> r)
    Left _ -> pure []
  pure $ mkRideItem <$> res'
  where
    mkBookingStatusVal ride =
      ( B.ifThenElse_ (ride.status B.==. B.val_ Ride.COMPLETED) (B.val_ Common.COMPLETED) $
          B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW B.&&. B.not_ (ride.createdAt B.<=. (B.val_ (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.UPCOMING) $
            B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW B.&&. (ride.createdAt B.<=. (B.val_ (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.UPCOMING_6HRS) $
              B.ifThenElse_ (ride.status B.==. B.val_ Ride.INPROGRESS B.&&. B.not_ (ride.tripStartTime B.<=. (B.val_ (Just $ addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.ONGOING) $
                B.ifThenElse_ (ride.status B.==. B.val_ Ride.CANCELLED) (B.val_ Common.CANCELLED) (B.val_ Common.ONGOING_6HRS)
      )
    fst' (x, _, _, _) = x
    snd' (_, y, _, _) = y
    thd' (_, _, z, _) = z
    fth' (_, _, _, r) = r
    mkBookingStatus now' ride
      | ride.status == Ride.COMPLETED = Common.COMPLETED
      | ride.status == Ride.NEW && not (ride.createdAt <= (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.UPCOMING
      | ride.status == Ride.NEW && (ride.createdAt <= (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.UPCOMING_6HRS
      | ride.status == Ride.INPROGRESS && not (ride.tripStartTime <= (Just $ addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.ONGOING
      | ride.status == Ride.CANCELLED = Common.CANCELLED
      | otherwise = Common.COMPLETED
    mkRideItem (rideShortId, rideCreatedAt, rideDetails, riderDetails, customerName, fareDiff, bookingStatus) = do
      RideItem {..}

-- findAllRideItems'' ::
--   (L.MonadFlow m, Log m) =>
--   Id Merchant ->
--   Int ->
--   Int ->
--   Maybe Common.BookingStatus ->
--   Maybe (ShortId Ride) ->
--   Maybe DbHash ->
--   Maybe DbHash ->
--   Maybe Money ->
--   UTCTime ->
--   Maybe UTCTime ->
--   Maybe UTCTime ->
--   m [RideItem]
-- findAllRideItems'' merchantId limitVal offsetVal mbBookingStatus mbRideShortId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now mbFrom mbTo = do
--   dbConf <- getMasterBeamConfig
--   res <- L.runDB dbConf $
--     L.findRows $
--       B.select $
--           B.limit_ (fromIntegral limitVal) $
--           B.offset_ (fromIntegral offsetVal) $
--           B.filter_' (\(booking, ride) ->
--                                           booking.providerId B.==?. B.val_ (getId merchantId))
--                                           -- B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\rideShortId -> ride.shortId B.==?. B.val_ (getShortId rideShortId)) mbRideShortId
--                                           -- -- B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> person.mobileNumberHash B.==?. B.val_ (Just hash)) mbCustomerPhoneDBHash
--                                           -- B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> riderDetails.mobileNumberHash B.==?. B.val_ (hash)) mbCustomerPhoneDBHash
--                                           -- B.&&?. maybe (B.sqlBool_ $ B.val_ True) (\hash -> rideDetails.driverNumberHash B.==?. B.val_ (Just hash)) mbDriverPhoneDBHash
--                                           -- -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\driverMobileNumber -> ride.driverMobileNumber B.==?. B.val_ (driverMobileNumber)) mbDriverPhone)
--                                           -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\defaultFrom -> B.sqlBool_ $ ride.createdAt B.>=. B.val_ (defaultFrom)) mbFrom)
--                                           -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\defaultTo -> B.sqlBool_ $ ride.createdAt B.<=. B.val_ (defaultTo)) mbTo)
--                                           -- -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\fareDiff_ -> B.sqlBool_ $ ride.fare B.<=. booking.estimatedFare) mbFareDiff)
--                                           -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\bookingStatus -> mkBookingStatusVal ride B.==?. B.val_ (bookingStatus)) mbBookingStatus)
--                                           -- B.&&?. (maybe (B.sqlBool_ $ B.val_ True) (\fareDiff_ -> B.sqlBool_ $ (ride.fare - (B.just_ booking.estimatedFare)) B.>=. (B.val_ $ Just fareDiff_)) ) mbFareDiff)

--                                           -- B.&&?. B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW) (booking.status B.val_ Common.RCOMPLETED) (B.val_ Common.RCANCELLED)) $
--             do
--               booking' <- B.all_ (meshModelTableEntity @BeamB.BookingT @Postgres @(DatabaseWith2 BeamB.BookingT BeamR.RideT))
--               ride' <- B.join_' (meshModelTableEntity @BeamR.RideT @Postgres @(DatabaseWith2 BeamB.BookingT BeamR.RideT)) (\ride'' -> BeamR.bookingId ride'' B.==?. BeamB.id booking')
--               pure (booking', ride')
--   pure []
-- res' <- case res of
--               Right x -> do
--                 let bookings = fst' <$> x
--                     rides = snd' <$> x
--                     rideDetails = thd' <$> x
--                     riderDetails = fth' <$> x
--                 b <- catMaybes <$> (mapM fromTType' (bookings))
--                 r <- catMaybes <$> (mapM fromTType' (rides))
--                 rd <- catMaybes <$> (mapM fromTType' (rideDetails))
--                 rdr <- catMaybes <$> (mapM fromTType' (riderDetails))
--                 pure $ zip7 (DR.shortId <$> r) (DR.createdAt <$> r) rd rdr (DBooking.riderName <$> b) (liftA2 (-) (DR.fare <$> r) (Just . DBooking.estimatedFare <$> b)) (mkBookingStatus now <$> r)
--               Left _ -> pure []
-- pure $ mkRideItem <$> res'
-- where
--   mkBookingStatusVal ride = (B.ifThenElse_ (ride.status B.==. B.val_ Ride.COMPLETED) (B.val_ Common.COMPLETED) $
--                               B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW B.&&. B.not_ (ride.createdAt B.<=. (B.val_ (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.UPCOMING) $
--                               B.ifThenElse_ (ride.status B.==. B.val_ Ride.NEW B.&&. (ride.createdAt B.<=. (B.val_ (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.UPCOMING_6HRS) $
--                               B.ifThenElse_ (ride.status B.==. B.val_ Ride.INPROGRESS B.&&. B.not_ (ride.tripStartTime B.<=. (B.val_ (Just $ addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now)))) (B.val_ Common.ONGOING) $
--                               B.ifThenElse_ (ride.status B.==. B.val_ Ride.CANCELLED) (B.val_ Common.CANCELLED) (B.val_ Common.ONGOING_6HRS))
--   fst' (x, _, _, _) = x
--   snd' (_, y, _, _) = y
--   thd' (_, _, z, _) = z
--   fth' (_, _, _, r) = r
--   mkBookingStatus now' ride
--                     | ride.status == Ride.COMPLETED = Common.COMPLETED
--                     | ride.status == Ride.NEW && not (ride.createdAt <= (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.UPCOMING
--                     | ride.status == Ride.NEW && (ride.createdAt <= (addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.UPCOMING_6HRS
--                     | ride.status == Ride.INPROGRESS && not (ride.tripStartTime <= (Just $ addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now')) = Common.ONGOING
--                     | ride.status == Ride.CANCELLED = Common.CANCELLED
--                     | otherwise = Common.COMPLETED
--   mkRideItem (rideShortId, rideCreatedAt, rideDetails, riderDetails, customerName, fareDiff, bookingStatus) = do
--     RideItem {..}
-- where condition implementation remaining
-- findAllRideItems' ::( MonadFlow m, MonadTime m) => Id Merchant -> Int -> Int -> Maybe Common.BookingStatus -> Maybe (ShortId Ride) -> Maybe DbHash -> Maybe DbHash -> Maybe Money -> UTCTime -> m [RideItem]
-- findAllRideItems' (Id merchantId) limitVal offsetVal mbBookingStatus mbRideShortId mbCustomerPhoneDBHash mbDriverPhoneDBHash mbFareDiff now = do
--   dbConf <- L.getOption KBT.PsqlDbCfg
-- let modelName = Se.modelTableName @BeamR.RideT
-- updatedMeshConfig <- setMeshConfig modelName
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

findStuckRideItems :: (L.MonadFlow m, MonadTime m, Log m) => Id Merchant -> [Id Booking] -> UTCTime -> m [StuckRideItem]
findStuckRideItems (Id merchantId) bookingIds now = do
  let now6HrBefore = addUTCTime (- (6 * 60 * 60) :: NominalDiffTime) now
  rides <-
    findAllWithKV
      [ Se.And
          [ Se.Is BeamR.status $ Se.Eq Ride.NEW,
            Se.Is BeamR.createdAt $ Se.LessThanOrEq now6HrBefore
          ]
      ]
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
  where
    getRideWithBooking bookings acc ride' =
      let bookings' = filter (\x -> x.id == ride'.bookingId) bookings
       in acc <> ((\x -> (ride', x.id)) <$> bookings')

    getRideWithBookingDriverInfo driverInfos acc (ride', booking') =
      let driverInfos' = filter (\x -> x.driverId == ride'.driverId) driverInfos
       in acc <> ((\x -> (ride'.id, booking', x.driverId, x.active)) <$> driverInfos')

    mkStuckRideItem (rideId, bookingId, driverId, driverActive) = StuckRideItem {..}

instance FromTType' BeamR.Ride Ride where
  fromTType' BeamR.RideT {..} = do
    tUrl <- parseBaseUrl trackingUrl
    pure $
      Just
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
            updatedAt = updatedAt,
            numberOfDeviation = numberOfDeviation
          }

instance ToTType' BeamR.Ride Ride where
  toTType' Ride {..} =
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
        BeamR.updatedAt = updatedAt,
        BeamR.numberOfDeviation = numberOfDeviation
      }
