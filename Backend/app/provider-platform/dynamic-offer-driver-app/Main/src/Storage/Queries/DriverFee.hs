{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.DriverFee where

import Domain.Types.DriverFee
import qualified Domain.Types.DriverFee as Domain
import Domain.Types.Person
import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Types.Common (HighPrecMoney, MonadFlow, Money)
import Kernel.Types.Id
import Kernel.Types.Time
import qualified Sequelize as Se
import qualified Storage.Beam.DriverFee as BeamDF

create :: MonadFlow m => DriverFee -> m ()
create = createWithKV

findById :: MonadFlow m => Id DriverFee -> m (Maybe DriverFee)
findById (Id driverFeeId) = findOneWithKV [Se.Is BeamDF.id $ Se.Eq driverFeeId]

findPendingFeesByDriverFeeId :: MonadFlow m => Id DriverFee -> m (Maybe DriverFee)
findPendingFeesByDriverFeeId (Id driverFeeId) =
  findOneWithKV
    [ Se.And
        [ Se.Is BeamDF.id $ Se.Eq driverFeeId,
          Se.Is BeamDF.status $ Se.In [PAYMENT_PENDING, PAYMENT_OVERDUE]
        ]
    ]

findPendingFeesByDriverId :: MonadFlow m => Id Driver -> m [DriverFee]
findPendingFeesByDriverId (Id driverId) =
  findAllWithKV
    [ Se.And
        [ Se.Is BeamDF.driverId $ Se.Eq driverId,
          Se.Is BeamDF.status $ Se.In [PAYMENT_PENDING, PAYMENT_OVERDUE],
          Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE
        ]
    ]

findLatestFeeByDriverId :: MonadFlow m => Id Driver -> m (Maybe DriverFee)
findLatestFeeByDriverId (Id driverId) =
  findAllWithOptionsKV
    [Se.Is BeamDF.driverId $ Se.Eq driverId]
    (Se.Desc BeamDF.createdAt)
    (Just 1)
    Nothing
    <&> listToMaybe

findLatestRegisterationFeeByDriverId :: MonadFlow m => Id Driver -> m (Maybe DriverFee)
findLatestRegisterationFeeByDriverId (Id driverId) =
  findAllWithOptionsKV
    [ Se.And
        [ Se.Is BeamDF.driverId (Se.Eq driverId),
          Se.Is BeamDF.feeType (Se.Eq MANDATE_REGISTRATION),
          Se.Is BeamDF.status (Se.Eq PAYMENT_PENDING)
        ]
    ]
    (Se.Desc BeamDF.createdAt)
    (Just 1)
    Nothing
    <&> listToMaybe

findOldestFeeByStatus :: MonadFlow m => Id Driver -> DriverFeeStatus -> m (Maybe DriverFee)
findOldestFeeByStatus (Id driverId) status =
  findAllWithOptionsKV
    [ Se.And
        [ Se.Is BeamDF.driverId $ Se.Eq driverId,
          Se.Is BeamDF.status $ Se.Eq status
        ]
    ]
    (Se.Asc BeamDF.createdAt)
    (Just 1)
    Nothing
    <&> listToMaybe

findFeesInRangeWithStatus :: MonadFlow m => UTCTime -> UTCTime -> DriverFeeStatus -> m [DriverFee]
findFeesInRangeWithStatus startTime endTime status =
  findAllWithKV
    [ Se.And
        [ Se.Is BeamDF.startTime $ Se.GreaterThanOrEq startTime,
          Se.Is BeamDF.endTime $ Se.LessThanOrEq endTime,
          Se.Is BeamDF.status $ Se.Eq status,
          Se.Or [Se.Is BeamDF.status (Se.Eq ONGOING), Se.Is BeamDF.payBy (Se.LessThanOrEq endTime)],
          Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE
        ]
    ]

findWindowsWithStatus :: MonadFlow m => Id Person -> UTCTime -> UTCTime -> Maybe DriverFeeStatus -> Int -> Int -> m [DriverFee]
findWindowsWithStatus (Id driverId) from to mbStatus limitVal offsetVal =
  findAllWithOptionsKV
    [ Se.And $
        [ Se.Is BeamDF.driverId $ Se.Eq driverId,
          Se.Is BeamDF.endTime $ Se.GreaterThanOrEq from,
          Se.Is BeamDF.endTime $ Se.LessThanOrEq to,
          Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE
        ]
          <> [Se.Is BeamDF.status $ Se.Eq $ fromJust mbStatus | isJust mbStatus]
    ]
    (Se.Desc BeamDF.createdAt)
    (Just limitVal)
    (Just offsetVal)

findOngoingAfterEndTime :: MonadFlow m => Id Person -> UTCTime -> m (Maybe DriverFee)
findOngoingAfterEndTime (Id driverId) now =
  findOneWithKV
    [ Se.And
        [ Se.Is BeamDF.driverId $ Se.Eq driverId,
          Se.Is BeamDF.status $ Se.Eq ONGOING,
          Se.Is BeamDF.endTime $ Se.LessThanOrEq now,
          Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE
        ]
    ]

findUnpaidAfterPayBy :: MonadFlow m => Id Person -> UTCTime -> m (Maybe DriverFee)
findUnpaidAfterPayBy (Id driverId) now =
  findOneWithKV
    [ Se.And
        [ Se.Is BeamDF.driverId $ Se.Eq driverId,
          Se.Is BeamDF.status $ Se.In [PAYMENT_PENDING, PAYMENT_OVERDUE],
          Se.Is BeamDF.payBy $ Se.LessThanOrEq now,
          Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE
        ]
    ]

updateFee :: MonadFlow m => Id DriverFee -> Maybe Money -> Money -> Money -> HighPrecMoney -> HighPrecMoney -> UTCTime -> m ()
updateFee driverFeeId mbFare govtCharges platformFee cgst sgst now = do
  driverFeeObject <- findById driverFeeId
  case driverFeeObject of
    Just df -> do
      let govtCharges' = df.govtCharges
      let platformFee' = df.platformFee.fee
      let cgst' = df.platformFee.cgst
      let sgst' = df.platformFee.sgst
      let totalEarnings = df.totalEarnings
      let numRides = df.numRides
      let fare = fromMaybe 0 mbFare
      updateOneWithKV
        [ Se.Set BeamDF.govtCharges $ govtCharges' + govtCharges,
          Se.Set BeamDF.platformFee $ platformFee' + platformFee,
          Se.Set BeamDF.cgst $ cgst' + cgst,
          Se.Set BeamDF.sgst $ sgst' + sgst,
          Se.Set BeamDF.status ONGOING,
          Se.Set BeamDF.totalEarnings $ totalEarnings + fare,
          Se.Set BeamDF.numRides $ numRides + 1, -- in the api, num_rides needed without cost contribution?
          Se.Set BeamDF.updatedAt now
        ]
        [Se.Is BeamDF.id (Se.Eq (getId driverFeeId))]
    Nothing -> pure ()

updateStatusByIds :: MonadFlow m => DriverFeeStatus -> [Id DriverFee] -> UTCTime -> m ()
updateStatusByIds status driverFeeIds now =
  updateWithKV
    [Se.Set BeamDF.status status, Se.Set BeamDF.updatedAt now]
    [Se.Is BeamDF.id $ Se.In (getId <$> driverFeeIds)]

findAllPendingAndDueDriverFeeByDriverId :: MonadFlow m => Id Person -> m [DriverFee]
findAllPendingAndDueDriverFeeByDriverId (Id driverId) = findAllWithKV [Se.And [Se.Is BeamDF.feeType $ Se.Eq RECURRING_INVOICE, Se.Or [Se.Is BeamDF.status $ Se.Eq PAYMENT_OVERDUE, Se.Is BeamDF.status $ Se.Eq PAYMENT_PENDING], Se.Is BeamDF.driverId $ Se.Eq driverId]]

findLatestByFeeTypeAndStatus :: MonadFlow m => Domain.FeeType -> [Domain.DriverFeeStatus] -> Id Person -> m (Maybe DriverFee)
findLatestByFeeTypeAndStatus feeType status driverId = do
  findAllWithOptionsKV
    [ Se.And
        [ Se.Is BeamDF.feeType $ Se.Eq feeType,
          Se.Is BeamDF.status $ Se.In status,
          Se.Is BeamDF.driverId $ Se.Eq driverId.getId
        ]
    ]
    (Se.Desc BeamDF.updatedAt)
    (Just 1)
    Nothing
    <&> listToMaybe

updateStatus :: MonadFlow m => DriverFeeStatus -> Id DriverFee -> UTCTime -> m ()
updateStatus status (Id driverFeeId) now = do
  updateOneWithKV
    [Se.Set BeamDF.status status, Se.Set BeamDF.updatedAt now]
    [Se.Is BeamDF.id (Se.Eq driverFeeId)]

updateRegisterationFeeStatusByDriverId :: MonadFlow m => DriverFeeStatus -> Id Person -> m ()
updateRegisterationFeeStatusByDriverId status (Id driverId) = do
  now <- getCurrentTime
  updateOneWithKV
    [Se.Set BeamDF.status status, Se.Set BeamDF.updatedAt now]
    [Se.And [Se.Is BeamDF.driverId (Se.Eq driverId), Se.Is BeamDF.feeType (Se.Eq MANDATE_REGISTRATION), Se.Is BeamDF.status (Se.Eq PAYMENT_PENDING)]]

updateCollectedPaymentStatus :: MonadFlow m => DriverFeeStatus -> Maybe Text -> UTCTime -> Id DriverFee -> m ()
updateCollectedPaymentStatus status collectorId now (Id driverFeeId) = do
  updateOneWithKV
    [Se.Set BeamDF.status status, Se.Set BeamDF.updatedAt now, Se.Set BeamDF.collectedBy collectorId, Se.Set BeamDF.collectedAt (Just now)]
    [Se.Is BeamDF.id (Se.Eq driverFeeId)]

instance FromTType' BeamDF.DriverFee DriverFee where
  fromTType' BeamDF.DriverFeeT {..} = do
    pure $
      Just
        DriverFee
          { id = Id id,
            merchantId = Id merchantId,
            driverId = Id driverId,
            govtCharges = govtCharges,
            platformFee = Domain.PlatformFee platformFee cgst sgst,
            numRides = numRides,
            payBy = payBy,
            totalEarnings = totalEarnings,
            startTime = startTime,
            endTime = endTime,
            status = status,
            feeType = feeType,
            collectedBy = collectedBy,
            collectedAt = collectedAt,
            createdAt = createdAt,
            updatedAt = updatedAt
          }

instance ToTType' BeamDF.DriverFee DriverFee where
  toTType' DriverFee {..} = do
    BeamDF.DriverFeeT
      { BeamDF.id = getId id,
        BeamDF.merchantId = getId merchantId,
        BeamDF.driverId = getId driverId,
        BeamDF.govtCharges = govtCharges,
        BeamDF.platformFee = platformFee.fee,
        BeamDF.cgst = platformFee.cgst,
        BeamDF.sgst = platformFee.sgst,
        BeamDF.numRides = numRides,
        BeamDF.payBy = payBy,
        BeamDF.totalEarnings = totalEarnings,
        BeamDF.startTime = startTime,
        BeamDF.endTime = endTime,
        BeamDF.status = status,
        BeamDF.feeType = feeType,
        BeamDF.collectedBy = collectedBy,
        BeamDF.collectedAt = collectedAt,
        BeamDF.createdAt = createdAt,
        BeamDF.updatedAt = updatedAt
      }
