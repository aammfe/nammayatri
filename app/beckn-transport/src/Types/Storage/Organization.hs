{-# LANGUAGE UndecidableInstances #-}

module Types.Storage.Organization where

import Beckn.Storage.DB.Utils (fromBackendRowEnum)
import Beckn.Types.Id
import Beckn.Utils.JSON
import Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import Data.OpenApi (ToSchema)
import qualified Data.Text as T
import qualified Data.Text.Encoding as DT
import Data.Time
import qualified Database.Beam as B
import Database.Beam.Backend.SQL
import Database.Beam.Postgres
import EulerHS.Prelude hiding (id)
import Servant.API

data Status = PENDING_VERIFICATION | APPROVED | REJECTED
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON, ToSchema)

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Status where
  sqlValueSyntax = autoSqlValueSyntax

instance B.HasSqlEqualityCheck Postgres Status

instance FromBackendRow Postgres Status where
  fromBackendRow = fromBackendRowEnum "Status"

instance FromHttpApiData Status where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = first T.pack . eitherDecode . BSL.fromStrict

--------------------------------------------------------------------------------------

data OrganizationType
  = PROVIDER
  | APP
  | GATEWAY
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON)

instance HasSqlValueSyntax be String => HasSqlValueSyntax be OrganizationType where
  sqlValueSyntax = autoSqlValueSyntax

instance B.HasSqlEqualityCheck Postgres OrganizationType

instance FromBackendRow Postgres OrganizationType where
  fromBackendRow = fromBackendRowEnum "OrganizationType"

instance FromHttpApiData OrganizationType where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = first T.pack . eitherDecode . BSL.fromStrict

data OrganizationDomain
  = MOBILITY
  | FINAL_MILE_DELIVERY
  | LOCAL_RETAIL
  | FOOD_AND_BEVERAGE
  | HEALTHCARE
  deriving (Show, Eq, Read, Generic)

instance ToJSON OrganizationDomain where
  toJSON = genericToJSON constructorsWithHyphens

instance FromJSON OrganizationDomain where
  parseJSON = genericParseJSON constructorsWithHyphens

instance HasSqlValueSyntax be String => HasSqlValueSyntax be OrganizationDomain where
  sqlValueSyntax = autoSqlValueSyntax

instance B.HasSqlEqualityCheck Postgres OrganizationDomain

instance FromBackendRow Postgres OrganizationDomain where
  fromBackendRow = fromBackendRowEnum "OrganizationDomain"

instance FromHttpApiData OrganizationDomain where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = first T.pack . eitherDecode . BSL.fromStrict

data OrganizationT f = Organization
  { id :: B.C f (Id Organization),
    name :: B.C f Text,
    description :: B.C f (Maybe Text),
    shortId :: B.C f (ShortId Organization),
    uniqueKeyId :: B.C f Text,
    mobileNumber :: B.C f (Maybe Text),
    mobileCountryCode :: B.C f (Maybe Text),
    gstin :: B.C f (Maybe Text),
    _type :: B.C f OrganizationType,
    domain :: B.C f (Maybe OrganizationDomain),
    fromTime :: B.C f (Maybe UTCTime),
    toTime :: B.C f (Maybe UTCTime),
    headCount :: B.C f (Maybe Int),
    status :: B.C f Status,
    verified :: B.C f Bool,
    enabled :: B.C f Bool,
    createdAt :: B.C f UTCTime,
    updatedAt :: B.C f UTCTime,
    info :: B.C f (Maybe Text)
  }
  deriving (Generic, B.Beamable)

type Organization = OrganizationT Identity

type OrganizationPrimaryKey = B.PrimaryKey OrganizationT Identity

instance B.Table OrganizationT where
  data PrimaryKey OrganizationT f = OrganizationPrimaryKey (B.C f (Id Organization))
    deriving (Generic, B.Beamable)
  primaryKey = OrganizationPrimaryKey . (.id)

deriving instance Show Organization

deriving instance Eq Organization

instance ToJSON Organization where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

instance FromJSON Organization where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

fieldEMod ::
  B.EntityModification (B.DatabaseEntity be db) be (B.TableEntity OrganizationT)
fieldEMod =
  B.modifyTableFields
    B.tableModification
      { shortId = "short_id",
        uniqueKeyId = "unique_key_id",
        createdAt = "created_at",
        updatedAt = "updated_at",
        mobileNumber = "mobile_number",
        mobileCountryCode = "mobile_country_code",
        headCount = "head_count",
        fromTime = "from_time",
        toTime = "to_time"
      }

data OrganizationAPIEntity = OrganizationAPIEntity
  { name :: Text,
    description :: Maybe Text,
    contactNumber :: Text,
    status :: Status,
    enabled :: Bool
  }
  deriving (Generic, Show, FromJSON, ToJSON, ToSchema)

makeOrganizationAPIEntity :: Organization -> OrganizationAPIEntity
makeOrganizationAPIEntity Organization {..} =
  OrganizationAPIEntity
    { contactNumber = fromMaybe "Unknown" $ mobileCountryCode <> mobileNumber,
      ..
    }
