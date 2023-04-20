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

module Storage.Tabular.Rewards where

import qualified Domain.Types.Rewards as Domain
import Kernel.Prelude
import Kernel.Storage.Esqueleto
import Kernel.Types.Id


mkPersist
  defaultSqlSettings
  [defaultQQ|
    RewardsT sql=rewards
      id Text
      name Text
      provider Text
      createdAt UTCTime
      updatedAt UTCTime

      Primary id
      deriving Generic
    |]

instance TEntityKey RewardsT where
  type DomainKey RewardsT = Id Domain.Reward
  fromKey (RewardsTKey _id) = Id _id
  toKey (Id id) = RewardsTKey id

instance FromTType RewardsT Domain.Reward where
  fromTType RewardsT {..} = do
    return $
      Domain.Reward
        { id = Id id,
          ..
        }

instance ToTType RewardsT Domain.Reward where
  toTType Domain.Reward {..} =
    RewardsT
      { id = getId id,
        ..
      }
