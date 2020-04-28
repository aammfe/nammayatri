{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE UndecidableInstances #-}

module Beckn.Types.Storage.PassApplication where

import           Servant.Swagger
import Data.Swagger
import Beckn.Types.App
import Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Data.Text.Encoding as DT
import Data.Time.LocalTime
import qualified Database.Beam as B
import Database.Beam.Backend.SQL
import Database.Beam.MySQL
import EulerHS.Prelude
import Servant.API

data Status
  = PENDING
  | APPROVED
  | REJECTED
  | EXPIRED
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON, ToSchema)

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Status where
  sqlValueSyntax = autoSqlValueSyntax

instance FromBackendRow MySQL Status where
  fromBackendRow = read . T.unpack <$> fromBackendRow

instance FromHttpApiData Status where
  parseUrlPiece = parseHeader . DT.encodeUtf8
    --case T.toLower x of
      --"pending" -> Right PENDING
      --"approved" -> Right APPROVED
      --"rejected" -> Righ REJECTED
      --"expired" -> Right EXPIRED
      --_ -> Left x
  parseQueryParam = parseUrlPiece
  parseHeader = bimap T.pack id . eitherDecode . BSL.fromStrict

instance ToParamSchema Status

data PassType
  = INDIVIDUAL
  | ORGANIZATION
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON, ToSchema)

instance HasSqlValueSyntax be String => HasSqlValueSyntax be PassType where
  sqlValueSyntax = autoSqlValueSyntax

instance FromBackendRow MySQL PassType where
  fromBackendRow = read . T.unpack <$> fromBackendRow

instance ToParamSchema PassType

instance FromHttpApiData PassType where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = bimap T.pack id . eitherDecode . BSL.fromStrict

data PassApplicationT f =
  PassApplication
    { _id :: B.C f PassApplicationId
    , _CustomerId :: B.C f CustomerId
    , _status :: B.C f Status
    , _fromDate :: B.C f LocalTime
    , _toDate :: B.C f LocalTime
    , _type :: B.C f PassType
    , _FromLocationId :: B.C f LocationId
    , _ToLocationId :: B.C f LocationId
    , _CreatedBy :: B.C f CustomerId
    , _AssignedTo :: B.C f UserId
    , _count :: B.C f Int
    , _approvedCount :: B.C f Int
    , _remarks :: B.C f Text
    , _info :: B.C f Text
    , _createdAt :: B.C f LocalTime
    , _updatedAt :: B.C f LocalTime
    }
  deriving (Generic, B.Beamable)

type PassApplication = PassApplicationT Identity

type PassApplicationPrimaryKey = B.PrimaryKey PassApplicationT Identity

instance B.Table PassApplicationT where
  data PrimaryKey PassApplicationT f = PassApplicationPrimaryKey (B.C
                                                                  f
                                                                  PassApplicationId)
                                       deriving (Generic, B.Beamable)
  primaryKey = PassApplicationPrimaryKey . _id

deriving instance Show PassApplication

deriving instance Eq PassApplication

instance ToSchema PassApplication

instance ToJSON PassApplication where
  toJSON = genericToJSON stripAllLensPrefixOptions

instance FromJSON PassApplication where
  parseJSON = genericParseJSON stripAllLensPrefixOptions

insertExpression customer = insertExpressions [customer]

insertExpressions customers = B.insertValues customers

fieldEMod ::
     B.EntityModification (B.DatabaseEntity be db) be (B.TableEntity PassApplicationT)
fieldEMod =
  B.modifyTableFields
    B.tableModification
      { _CustomerId = "customer_id"
      , _fromDate = "from_date"
      , _toDate = "to_date"
      , _FromLocationId = "from_locationId"
      , _ToLocationId = "to_locationId"
      , _AssignedTo = "assigned_to"
      , _approvedCount = "approved_count"
      , _CreatedBy = "created_by"
      , _createdAt = "created_at"
      , _updatedAt = "updated_at"
      }
