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
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Beam.RentalSlab where

import Data.Serialize
import qualified Database.Beam as B
import Database.Beam.Backend
import Database.Beam.MySQL ()
import Database.Beam.Postgres
  ( Postgres,
  )
import Database.PostgreSQL.Simple.FromField (FromField, fromField)
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common hiding (id)
import Lib.Utils ()
import Lib.UtilsTH
import Sequelize

instance FromField Hours where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Hours where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Hours

instance FromBackendRow Postgres Hours

instance IsString Hours where
  fromString = show

instance FromField Kilometers where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Kilometers where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Kilometers

instance FromBackendRow Postgres Kilometers

instance IsString Kilometers where
  fromString = show

data RentalSlabT f = RentalSlabT
  { id :: B.C f Text,
    baseDistance :: B.C f Kilometers,
    baseDuration :: B.C f Hours
  }
  deriving (Generic, B.Beamable)

instance B.Table RentalSlabT where
  data PrimaryKey RentalSlabT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type RentalSlab = RentalSlabT Identity

rentalSlabTMod :: RentalSlabT (B.FieldModification (B.TableField RentalSlabT))
rentalSlabTMod =
  B.tableModification
    { id = B.fieldNamed "id",
      baseDistance = B.fieldNamed "base_distance",
      baseDuration = B.fieldNamed "base_duration"
    }

$(enableKVPG ''RentalSlabT ['id] [])

$(mkTableInstances ''RentalSlabT "rental_slab" "atlas_app")
