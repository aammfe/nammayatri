{-# LANGUAGE OverloadedLabels #-}

module Types.API.Transporter where

import App.Types
import Beckn.TypeClass.Transform
import Beckn.Types.Common
import Beckn.Types.Id
import qualified Beckn.Types.Storage.Location as SL
import qualified Beckn.Types.Storage.Organization as SO
import qualified Beckn.Types.Storage.Person as SP
import EulerHS.Prelude
import qualified Storage.Queries.Location as QL

data TransporterReq = TransporterReq
  { _name :: Text,
    _description :: Maybe Text,
    _mobileNumber :: Text,
    _mobileCountryCode :: Text,
    _gstin :: Maybe Text,
    _headCount :: Maybe Int,
    _locationType :: Maybe SL.LocationType,
    _lat :: Maybe Double,
    _long :: Maybe Double,
    _ward :: Maybe Text,
    _district :: Text,
    _city :: Text,
    _state :: Maybe Text,
    _country :: Text,
    _pincode :: Maybe Text,
    _address :: Maybe Text
  }
  deriving (Generic)

instance FromJSON TransporterReq where
  parseJSON = genericParseJSON stripAllLensPrefixOptions

instance CreateTransform TransporterReq SO.Organization Flow where
  createTransform req = do
    oid <- generateGUID
    let shortId = ShortId $ getId oid
    now <- getCurrentTime
    location <- transformToLocation req
    QL.createFlow location
    return $
      SO.Organization
        { SO._id = oid,
          SO._name = req ^. #_name,
          SO._shortId = shortId,
          SO._description = req ^. #_description,
          SO._mobileNumber = Just $ req ^. #_mobileNumber,
          SO._mobileCountryCode = Just $ req ^. #_mobileCountryCode,
          SO._gstin = req ^. #_gstin,
          SO._locationId = Just (getId $ SL._id location),
          SO._type = SO.PROVIDER,
          SO._domain = Just SO.MOBILITY,
          SO._fromTime = Nothing,
          SO._toTime = Nothing,
          SO._headCount = req ^. #_headCount,
          SO._apiKey = Nothing,
          SO._callbackUrl = Nothing,
          SO._status = SO.PENDING_VERIFICATION,
          SO._verified = False,
          SO._enabled = True,
          SO._createdAt = now,
          SO._updatedAt = now,
          SO._callbackApiKey = Nothing,
          SO._info = Nothing
        }

transformToLocation :: TransporterReq -> Flow SL.Location
transformToLocation req = do
  locId <- generateGUID
  now <- getCurrentTime
  return $
    SL.Location
      { SL._id = locId,
        SL._locationType = fromMaybe SL.PINCODE $ req ^. #_locationType,
        SL._lat = req ^. #_lat,
        SL._long = req ^. #_long,
        SL._ward = req ^. #_ward,
        SL._district = Just $ req ^. #_district,
        SL._city = Just $ req ^. #_city,
        SL._state = req ^. #_state,
        SL._country = Just $ req ^. #_country,
        SL._pincode = req ^. #_pincode,
        SL._address = req ^. #_address,
        SL._bound = Nothing,
        SL._point = SL.Point,
        SL._createdAt = now,
        SL._updatedAt = now
      }

data TransporterRes = TransporterRes
  { user :: SP.Person,
    organization :: SO.Organization
  }
  deriving (Generic, ToJSON)

newtype TransporterRec = TransporterRec
  { organization :: SO.Organization
  }
  deriving (Generic, ToJSON)

data UpdateTransporterReq = UpdateTransporterReq
  { name :: Maybe Text,
    description :: Maybe Text,
    headCount :: Maybe Int,
    enabled :: Maybe Bool
  }
  deriving (Generic, Show, FromJSON)

instance ModifyTransform UpdateTransporterReq SO.Organization Flow where
  modifyTransform req org = do
    now <- getCurrentTime
    return $
      org
        { SO._name = fromMaybe (org ^. #_name) (req ^. #name),
          SO._description = (req ^. #description) <|> (org ^. #_description),
          SO._headCount = (req ^. #headCount) <|> (org ^. #_headCount),
          SO._enabled = fromMaybe (org ^. #_enabled) (req ^. #enabled),
          SO._updatedAt = now
        }
