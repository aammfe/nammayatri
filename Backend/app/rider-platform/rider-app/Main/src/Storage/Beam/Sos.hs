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

module Storage.Beam.Sos where

import Data.Serialize
import qualified Data.Time as Time
import qualified Database.Beam as B
import Database.Beam.MySQL ()
import qualified Domain.Types.Sos as Domain
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Beam.Lib.UtilsTH
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common ()
import Lib.Utils ()
import Sequelize

data SosT f = SosT
  { id :: B.C f Text,
    personId :: B.C f Text,
    rideId :: B.C f Text,
    flow :: B.C f Domain.SosType,
    status :: B.C f Domain.SosStatus,
    createdAt :: B.C f Time.UTCTime,
    updatedAt :: B.C f Time.UTCTime,
    ticketId :: B.C f Text
  }
  deriving (Generic, B.Beamable)

instance B.Table SosT where
  data PrimaryKey SosT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type Sos = SosT Identity

sosTMod :: SosT (B.FieldModification (B.TableField SosT))
sosTMod =
  B.tableModification
    { id = B.fieldNamed "id",
      personId = B.fieldNamed "person_id",
      rideId = B.fieldNamed "ride_id",
      flow = B.fieldNamed "flow",
      status = B.fieldNamed "status",
      createdAt = B.fieldNamed "created_at",
      updatedAt = B.fieldNamed "updated_at",
      ticketId = B.fieldNamed "ticket_id"
    }

$(enableKVPG ''SosT ['id] [])

$(mkTableInstances ''SosT "sos" "atlas_app")
