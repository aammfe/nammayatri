{-# LANGUAGE DataKinds #-}

module Types.API.Person where

import Beckn.External.Encryption (encrypt)
import Beckn.External.FCM.Types as FCM
import Beckn.TypeClass.Transform
import Beckn.Types.Common hiding (id)
import Beckn.Types.Id
import Beckn.Types.Predicate
import qualified Beckn.Types.Storage.Location as SL
import qualified Beckn.Types.Storage.Organization as Org
import qualified Beckn.Types.Storage.Person as SP
import Beckn.Utils.JSON
import qualified Beckn.Utils.Predicates as P
import Beckn.Utils.Validation
import Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Data.Text.Encoding as DT
import Data.Time (UTCTime)
import EulerHS.Prelude hiding (id, state)
import Servant.API
import qualified Storage.Queries.Location as QL
import Types.API.Registration
import Types.Error
import Utils.Common

data EntityType = VEHICLE | PASS | TICKET
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON)

instance FromHttpApiData EntityType where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = first T.pack . eitherDecode . BSL.fromStrict

data UpdatePersonReq = UpdatePersonReq
  { firstName :: Maybe Text,
    middleName :: Maybe Text,
    lastName :: Maybe Text,
    fullName :: Maybe Text,
    role :: Maybe SP.Role,
    gender :: Maybe SP.Gender,
    email :: Maybe Text,
    identifier :: Maybe Text,
    rating :: Maybe Text,
    deviceToken :: Maybe FCM.FCMRecipientToken,
    udf1 :: Maybe Text,
    udf2 :: Maybe Text,
    description :: Maybe Text,
    locationType :: Maybe SL.LocationType,
    lat :: Maybe Double,
    long :: Maybe Double,
    ward :: Maybe Text,
    district :: Maybe Text,
    city :: Maybe Text,
    state :: Maybe Text,
    country :: Maybe Text,
    pincode :: Maybe Text,
    address :: Maybe Text,
    bound :: Maybe Text
  }
  deriving (Generic, ToJSON, FromJSON)

validateUpdatePersonReq :: Validate UpdatePersonReq
validateUpdatePersonReq UpdatePersonReq {..} =
  sequenceA_
    [ validateField "firstName" firstName $ InMaybe $ MinLength 3 `And` P.name,
      validateField "middleName" middleName $ InMaybe $ NotEmpty `And` P.name,
      validateField "lastName" lastName $ InMaybe $ NotEmpty `And` P.name,
      validateField "fullName" fullName $ InMaybe $ MinLength 3 `And` P.name,
      validateField "district" district $ InMaybe $ NotEmpty `And` P.name,
      validateField "state" state $ InMaybe $ NotEmpty `And` P.name
    ]

instance DBFlow m r => ModifyTransform UpdatePersonReq SP.Person m where
  modifyTransform req person = do
    location <- updateOrCreateLocation req $ person.locationId
    return
      -- only these below will be updated in the person table. if you want to add something extra please add in queries also
      person{firstName = ifJust (req.firstName) (person.firstName),
             middleName = ifJust (req.middleName) (person.middleName),
             lastName = ifJust (req.lastName) (person.lastName),
             fullName = ifJust (req.fullName) (person.fullName),
             role = ifJustExtract (req.role) (person.role),
             gender = ifJustExtract (req.gender) (person.gender),
             email = ifJust (req.email) (person.email),
             identifier = ifJust (req.identifier) (person.identifier),
             rating = ifJust (req.rating) (person.rating),
             deviceToken = ifJust (req.deviceToken) (person.deviceToken),
             udf1 = ifJust (req.udf1) (person.udf1),
             udf2 = ifJust (req.udf2) (person.udf2),
             organizationId = person.organizationId,
             description = ifJust (req.description) (person.description),
             locationId = Just (SL.id location)
            }

updateOrCreateLocation :: DBFlow m r => UpdatePersonReq -> Maybe (Id SL.Location) -> m SL.Location
updateOrCreateLocation req Nothing = do
  location <- createLocation req
  QL.createFlow location
  return location
updateOrCreateLocation req (Just locId) = do
  location <-
    QL.findLocationById locId
      >>= fromMaybeM LocationDoesNotExist
  QL.updateLocationRec locId $ transformToLocation req location
  return location

transformToLocation :: UpdatePersonReq -> SL.Location -> SL.Location
transformToLocation req location =
  location
    { SL.locationType = fromMaybe SL.PINCODE $ req.locationType,
      SL.lat = req.lat,
      SL.long = req.long,
      SL.ward = req.ward,
      SL.district = req.district,
      SL.city = req.city,
      SL.state = req.state,
      SL.country = req.country,
      SL.pincode = req.pincode,
      SL.address = req.address,
      SL.bound = req.bound
    }

createLocation :: DBFlow m r => UpdatePersonReq -> m SL.Location
createLocation UpdatePersonReq {..} = do
  id <- generateGUID
  createdAt <- getCurrentTime
  pure
    SL.Location
      { locationType = fromMaybe SL.PINCODE locationType,
        updatedAt = createdAt,
        point = SL.Point,
        ..
      }

ifJust :: Maybe a -> Maybe a -> Maybe a
ifJust a b = if isJust a then a else b

ifJustExtract :: Maybe a -> a -> a
ifJustExtract a b = fromMaybe b a

newtype UpdatePersonRes = UpdatePersonRes
  {user :: UserInfoRes}
  deriving (Generic, ToJSON, FromJSON)

data PersonReqEntity = PersonReqEntity
  { firstName :: Maybe Text,
    middleName :: Maybe Text,
    lastName :: Maybe Text,
    fullName :: Maybe Text,
    role :: Maybe SP.Role,
    gender :: Maybe SP.Gender,
    email :: Maybe Text,
    identifier :: Maybe Text,
    identifierType :: Maybe SP.IdentifierType,
    rating :: Maybe Text,
    deviceToken :: Maybe FCM.FCMRecipientToken,
    mobileNumber :: Maybe Text,
    mobileCountryCode :: Maybe Text,
    udf1 :: Maybe Text,
    udf2 :: Maybe Text,
    description :: Maybe Text,
    locationType :: Maybe SL.LocationType,
    lat :: Maybe Double,
    long :: Maybe Double,
    ward :: Maybe Text,
    district :: Maybe Text,
    city :: Maybe Text,
    state :: Maybe Text,
    country :: Maybe Text,
    pincode :: Maybe Text,
    address :: Maybe Text,
    bound :: Maybe Text
  }
  deriving (Generic, FromJSON, ToJSON)

validatePersonReqEntity :: Validate PersonReqEntity
validatePersonReqEntity PersonReqEntity {..} =
  sequenceA_
    [ validateField "firstName" firstName . InMaybe $ NotEmpty `And` P.name,
      validateField "mobileNumber" mobileNumber $ InMaybe P.mobileNumber,
      validateField "mobileCountryCode" mobileCountryCode $ InMaybe P.mobileCountryCode
    ]

instance (DBFlow m r, EncFlow m r) => CreateTransform PersonReqEntity SP.Person m where
  createTransform req = do
    pid <- generateGUID
    now <- getCurrentTime
    location <- createLocationT req
    mobileNumber <- encrypt req.mobileNumber
    return
      SP.Person
        { -- only these below will be updated in the person table. if you want to add something extra please add in queries also
          SP.id = pid,
          SP.firstName = req.firstName,
          SP.middleName = req.middleName,
          SP.lastName = req.lastName,
          SP.fullName = req.fullName,
          SP.role = ifJustExtract (req.role) SP.USER,
          SP.gender = ifJustExtract (req.gender) SP.UNKNOWN,
          SP.email = req.email,
          SP.passwordHash = Nothing,
          SP.identifier = req.identifier,
          SP.identifierType = fromMaybe SP.MOBILENUMBER $ req.identifierType,
          SP.mobileNumber = mobileNumber,
          SP.mobileCountryCode = req.mobileCountryCode,
          SP.verified = False,
          SP.rating = req.rating,
          SP.status = SP.INACTIVE,
          SP.deviceToken = req.deviceToken,
          SP.udf1 = req.udf1,
          SP.udf2 = req.udf2,
          SP.organizationId = Nothing,
          SP.description = req.description,
          SP.locationId = Just location.id,
          SP.createdAt = now,
          SP.updatedAt = now
        }

createLocationT :: DBFlow m r => PersonReqEntity -> m SL.Location
createLocationT req = do
  location <- createLocationRec req
  QL.createFlow location
  return location

-- FIXME? This is to silence hlint reusing as much code from `createLocation`
--   as possible, still we need fake organizationId here ...
-- Better solution in he long run is to factor out common data reducing this
--   enormous amount of duplication ...
createLocationRec :: DBFlow m r => PersonReqEntity -> m SL.Location
createLocationRec PersonReqEntity {..} = createLocation UpdatePersonReq {..}

newtype ListPersonRes = ListPersonRes
  {users :: [PersonEntityRes]}
  deriving (Generic, ToJSON, FromJSON)

newtype PersonRes = PersonRes
  {user :: UserInfoRes}
  deriving (Generic, ToJSON, FromJSON)

newtype DeletePersonRes = DeletePersonRes
  {personId :: Text}
  deriving (Generic, ToJSON, FromJSON)

data LinkedEntity = LinkedEntity
  { entityType :: EntityType,
    entityValue :: Maybe Text
  }
  deriving (Show, Generic)

instance FromJSON LinkedEntity where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON LinkedEntity where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

data PersonEntityRes = PersonEntityRes
  { id :: Id SP.Person,
    firstName :: Maybe Text,
    middleName :: Maybe Text,
    lastName :: Maybe Text,
    fullName :: Maybe Text,
    role :: SP.Role,
    gender :: SP.Gender,
    identifierType :: SP.IdentifierType,
    email :: Maybe Text,
    mobileNumber :: Maybe Text,
    mobileCountryCode :: Maybe Text,
    identifier :: Maybe Text,
    rating :: Maybe Text,
    verified :: Bool,
    udf1 :: Maybe Text,
    udf2 :: Maybe Text,
    status :: SP.Status,
    organizationId :: Maybe (Id Org.Organization),
    locationId :: Maybe (Id SL.Location),
    deviceToken :: Maybe FCM.FCMRecipientToken,
    description :: Maybe Text,
    createdAt :: UTCTime,
    updatedAt :: UTCTime,
    linkedEntity :: Maybe LinkedEntity
  }
  deriving (Show, Generic)

instance FromJSON PersonEntityRes where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON PersonEntityRes where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

data GetPersonDetailsRes = GetPersonDetailsRes
  { id :: Id SP.Person,
    firstName :: Maybe Text,
    middleName :: Maybe Text,
    lastName :: Maybe Text,
    fullName :: Maybe Text,
    role :: SP.Role,
    gender :: SP.Gender,
    email :: Maybe Text
  }
  deriving (Generic, ToJSON, FromJSON)
