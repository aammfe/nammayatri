{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Beam.SosMedia where

import qualified Data.Aeson as A
import qualified Data.HashMap.Internal as HM
import qualified Data.Map.Strict as M
import Data.Serialize
import qualified Data.Time as Time
import qualified Database.Beam as B
import Database.Beam.Backend
import Database.Beam.MySQL ()
import Database.Beam.Postgres
  ( Postgres,
  )
import Database.PostgreSQL.Simple.FromField (FromField, fromField)
import qualified Domain.Types.Sos as Domain
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Beam.Lib.UtilsTH
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common hiding (id)
import Lib.Utils ()
import Sequelize

data SosMediaT f = SosMediaT
  { id :: B.C f Text,
    fileType :: B.C f Domain.MediaType,
    url :: B.C f Text,
    createdAt :: B.C f Time.LocalTime
  }
  deriving (Generic, B.Beamable)

instance B.Table SosMediaT where
  data PrimaryKey SosMediaT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

instance ModelMeta SosMediaT where
  modelFieldModification = sosMediaTMod
  modelTableName = "sos_media"
  modelSchemaName = Just "atlas_app"

type SosMedia = SosMediaT Identity

instance FromJSON SosMedia where
  parseJSON = A.genericParseJSON A.defaultOptions

instance ToJSON SosMedia where
  toJSON = A.genericToJSON A.defaultOptions

deriving stock instance Show SosMedia

instance FromField Domain.MediaType where
  fromField = fromFieldEnum

deriving stock instance Ord Domain.MediaType

deriving stock instance Eq Domain.MediaType

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Domain.MediaType

instance FromBackendRow Postgres Domain.MediaType

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Domain.MediaType where
  sqlValueSyntax = autoSqlValueSyntax

sosMediaTMod :: SosMediaT (B.FieldModification (B.TableField SosMediaT))
sosMediaTMod =
  B.tableModification
    { id = B.fieldNamed "id",
      fileType = B.fieldNamed "type",
      url = B.fieldNamed "url",
      createdAt = B.fieldNamed "created_at"
    }

psToHs :: HM.HashMap Text Text
psToHs = HM.empty

sosMediaToHSModifiers :: M.Map Text (A.Value -> A.Value)
sosMediaToHSModifiers =
  M.empty

sosMediaToPSModifiers :: M.Map Text (A.Value -> A.Value)
sosMediaToPSModifiers =
  M.empty

instance IsString Domain.MediaType where
  fromString = show

instance Serialize SosMedia where
  put = error "undefined"
  get = error "undefined"

$(enableKVPG ''SosMediaT ['id] [])
