{-# LANGUAGE StandaloneDeriving   #-}
{-# LANGUAGE UndecidableInstances #-}

module Beckn.Types.Storage.PassApplication where

import           Beckn.Types.App
import           Beckn.Types.Common        (Bound (..), LocationType (..),
                                            PassType (..))
import           Data.Aeson
import qualified Data.ByteString.Lazy      as BSL
import           Data.Swagger
import qualified Data.Text                 as T
import qualified Data.Text.Encoding        as DT
import           Data.Time.LocalTime
import qualified Database.Beam             as B
import           Database.Beam.Backend.SQL
import           Database.Beam.MySQL
import           EulerHS.Prelude
import           Servant.API
import           Servant.Swagger

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
  parseUrlPiece  = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = bimap T.pack id . eitherDecode . BSL.fromStrict

data PassApplicationT f =
  PassApplication
    { _id               :: B.C f PassApplicationId
    , _CustomerId       :: B.C f CustomerId
    , _status           :: B.C f Status
    , _fromDate         :: B.C f LocalTime
    , _toDate           :: B.C f LocalTime
    , _type             :: B.C f PassType
    , _fromLocationType :: B.C f (Maybe LocationType)
    , _fromLat          :: B.C f (Maybe Double)
    , _fromLong         :: B.C f (Maybe Double)
    , _fromWard         :: B.C f (Maybe Text)
    , _fromDistrict     :: B.C f (Maybe Text)
    , _fromCity         :: B.C f (Maybe Text)
    , _fromState        :: B.C f (Maybe Text)
    , _fromCountry      :: B.C f (Maybe Text)
    , _fromPincode      :: B.C f (Maybe Text)
    , _fromAddress      :: B.C f (Maybe Text)
    , _fromBound        :: B.C f (Maybe Bound)
    , _toLocationType   :: B.C f (Maybe LocationType)
    , _toLat            :: B.C f (Maybe Double)
    , _toLong           :: B.C f (Maybe Double)
    , _toWard           :: B.C f (Maybe Text)
    , _toDistrict       :: B.C f (Maybe Text)
    , _toCity           :: B.C f (Maybe Text)
    , _toState          :: B.C f (Maybe Text)
    , _toCountry        :: B.C f (Maybe Text)
    , _toPincode        :: B.C f (Maybe Text)
    , _toAddress        :: B.C f (Maybe Text)
    , _toBound          :: B.C f (Maybe Bound)
    , _CreatedBy        :: B.C f CustomerId
    , _AssignedTo       :: B.C f UserId
    , _count            :: B.C f Int
    , _approvedCount    :: B.C f Int
    , _remarks          :: B.C f Text
    , _info             :: B.C f Text
    , _createdAt        :: B.C f LocalTime
    , _updatedAt        :: B.C f LocalTime
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
      , _fromLocationType = "from_locationId"
      , _fromLat = "from_lat"
      , _fromLong = "from_long"
      , _fromWard = "from_ward"
      , _fromDistrict = "from_district"
      , _fromCity = "from_city"
      , _fromState = "from_state"
      , _fromCountry = "from_country"
      , _fromPincode = "from_pincode"
      , _fromAddress = "from_address"
      , _fromBound = "from_bound"
      , _toLocationType = "to_locationId"
      , _toLat = "to_lat"
      , _toLong = "to_long"
      , _toWard = "to_ward"
      , _toDistrict = "to_district"
      , _toCity = "to_city"
      , _toState = "to_state"
      , _toCountry = "to_country"
      , _toPincode = "to_pincode"
      , _toAddress = "to_address"
      , _toBound = "to_bound"
      , _AssignedTo = "assigned_to"
      , _approvedCount = "approved_count"
      , _CreatedBy = "created_by"
      , _createdAt = "created_at"
      , _updatedAt = "updated_at"
      }
