{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Storage.Beam.Ride where

import Data.Serialize
import qualified Data.Time as Time
import qualified Database.Beam as B
import Database.Beam.MySQL ()
import qualified Domain.Types.Ride as Domain
import qualified Domain.Types.VehicleVariant as VehVar (VehicleVariant (..))
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common hiding (id)
import Lib.Utils ()
import Sequelize
import Tools.Beam.UtilsTH

data RideT f = RideT
  { id :: B.C f Text,
    bppRideId :: B.C f Text,
    bookingId :: B.C f Text,
    shortId :: B.C f Text,
    merchantId :: B.C f (Maybe Text),
    status :: B.C f Domain.RideStatus,
    driverName :: B.C f Text,
    driverRating :: B.C f (Maybe Centesimal),
    driverMobileNumber :: B.C f Text,
    driverMobileCountryCode :: B.C f (Maybe Text),
    driverRegisteredAt :: B.C f Time.UTCTime,
    vehicleNumber :: B.C f Text,
    vehicleModel :: B.C f Text,
    vehicleColor :: B.C f Text,
    vehicleVariant :: B.C f VehVar.VehicleVariant,
    otp :: B.C f Text,
    trackingUrl :: B.C f (Maybe Text),
    fare :: B.C f (Maybe HighPrecMoney),
    totalFare :: B.C f (Maybe HighPrecMoney),
    chargeableDistance :: B.C f (Maybe HighPrecMeters),
    traveledDistance :: B.C f (Maybe HighPrecMeters),
    driverArrivalTime :: B.C f (Maybe Time.UTCTime),
    rideStartTime :: B.C f (Maybe Time.UTCTime),
    rideEndTime :: B.C f (Maybe Time.UTCTime),
    rideRating :: B.C f (Maybe Int),
    createdAt :: B.C f Time.UTCTime,
    updatedAt :: B.C f Time.UTCTime,
    driverImage :: B.C f (Maybe Text),
    safetyCheckStatus :: B.C f Text
  }
  deriving (Generic, B.Beamable)

instance B.Table RideT where
  data PrimaryKey RideT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type Ride = RideT Identity

$(enableKVPG ''RideT ['id] [['bppRideId], ['bookingId]])

$(mkTableInstances ''RideT "ride")
