{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Tabular.RideDeviations where

import qualified Domain.Types.Ride as RD
import qualified Domain.Types.RideDeviations as Domain
import Kernel.Prelude
import Kernel.Storage.Esqueleto
import Kernel.Types.Id
import Storage.Tabular.Ride (RideTId)

mkPersist
  defaultSqlSettings
  [defaultQQ|
    RideDeviationsT sql=ride_deviations
      id RideTId
      numberOfDeviation Double Maybe
      Primary id
      deriving Generic
    |]

instance TEntityKey RideDeviationsT where
  type DomainKey RideDeviationsT = Id RD.Ride
  fromKey (RideDeviationsTKey _id) = fromKey _id
  toKey id = RideDeviationsTKey $ toKey id

instance FromTType RideDeviationsT Domain.RideDeviations where
  fromTType RideDeviationsT {..} = do
    return $
      Domain.RideDeviations
        { id = fromKey id,
          ..
        }

instance ToTType RideDeviationsT Domain.RideDeviations where
  toTType Domain.RideDeviations {..} =
    RideDeviationsT
      { id = toKey id,
        ..
      }
