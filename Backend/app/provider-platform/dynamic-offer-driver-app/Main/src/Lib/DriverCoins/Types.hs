{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
module Lib.DriverCoins.Types
  ( DriverCoinsEventType (..),
    DriverCoinsFunctionType (..),
  )
where

import Kernel.Prelude
import Kernel.Types.Common (Meters)
import Tools.Beam.UtilsTH (mkBeamInstancesForEnum)

data DriverCoinsFunctionType
  = OneOrTwoStarRating
  | RideCompleted
  | FiveStarRating
  | BookingCancellation
  | CustomerReferral
  | DriverReferral
  | EightPlusRidesInOneDay
  | PurpleRideCompleted
  | LeaderBoardTopFiveHundred
  | TrainingCompleted
  deriving (Show, Eq, Read, Generic, FromJSON, ToSchema, ToJSON, Ord, Typeable)

data DriverCoinsEventType
  = Rating {ratingValue :: Int, chargeableDistance :: Maybe Meters}
  | EndRide {isDisabled :: Bool, chargeableDistance_ :: Meters}
  | Cancellation {rideStartTime :: UTCTime, intialDisToPickup :: Maybe Meters, cancellationDisToPickup :: Maybe Meters}
  | Referral {_type :: Text, chargeableDistance :: Maybe Meters}
  | LeaderBoard
  | Training
  deriving (Show, Eq, Read, Generic, FromJSON, ToSchema, ToJSON, Ord, Typeable)

$(mkBeamInstancesForEnum ''DriverCoinsEventType)

$(mkBeamInstancesForEnum ''DriverCoinsFunctionType)
