{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingVia #-}

module Domain.Types.SearchRequest where

import Data.Aeson
import qualified Data.ByteString.Lazy as BSL
import qualified Data.Text as T
import qualified Data.Text.Encoding as DT
import qualified Data.Time.Clock.POSIX as Time
import qualified Domain.Types.Estimate as DEst
import qualified Domain.Types.Location as DLoc
import qualified Domain.Types.LocationMapping as DLocationMapping
import qualified Domain.Types.Merchant as DM
import Domain.Types.SearchRequestSpecialZone
import qualified Domain.Types.Vehicle.Variant as Variant
import Kernel.Prelude
import Kernel.Types.Common
import Kernel.Types.Id
import Kernel.Utils.GenericPretty
import Servant hiding (throwError)

data SearchRequest = SearchRequest
  { id :: Id SearchRequest,
    estimateId :: Id DEst.Estimate,
    transactionId :: Text,
    messageId :: Text,
    startTime :: UTCTime,
    validTill :: UTCTime,
    providerId :: Id DM.Merchant,
    fromLocation :: DLoc.Location,
    toLocation :: [DLoc.Location],
    bapId :: Text,
    bapUri :: BaseUrl,
    estimatedDistance :: Meters,
    estimatedDuration :: Seconds,
    customerExtraFee :: Maybe Money,
    device :: Maybe Text,
    createdAt :: UTCTime,
    updatedAt :: UTCTime,
    vehicleVariant :: Variant.Variant,
    status :: SearchRequestStatus,
    autoAssignEnabled :: Bool,
    searchRepeatCounter :: Int
  }
  deriving (Generic, PrettyShow, Show)

data SearchRequestStatus = ACTIVE | CANCELLED | REPEATITION
  deriving (Show, Eq, Ord, Read, Generic, ToJSON, FromJSON, ToSchema)
  deriving (PrettyShow) via Showable SearchRequestStatus

instance FromHttpApiData SearchRequestStatus where
  parseUrlPiece = parseHeader . DT.encodeUtf8
  parseQueryParam = parseUrlPiece
  parseHeader = left T.pack . eitherDecode . BSL.fromStrict

instance ToHttpApiData SearchRequestStatus where
  toUrlPiece = DT.decodeUtf8 . toHeader
  toQueryParam = toUrlPiece
  toHeader = BSL.toStrict . encode

data SearchRequestTable = SearchRequestTable
  { id :: Id SearchRequest,
    transactionId :: Text,
    messageId :: Text,
    estimateId :: Id DEst.Estimate,
    startTime :: UTCTime,
    validTill :: UTCTime,
    providerId :: Id DM.Merchant,
    bapId :: Text,
    bapUri :: BaseUrl,
    estimatedDistance :: Meters,
    estimatedDuration :: Seconds,
    customerExtraFee :: Maybe Money,
    device :: Maybe Text,
    status :: SearchRequestStatus,
    vehicleVariant :: Variant.Variant,
    searchRepeatCounter :: Int,
    autoAssignEnabled :: Bool,
    createdAt :: UTCTime,
    updatedAt :: UTCTime
  }

locationMappingMakerForSearch :: (MonadFlow m) => SearchRequest -> m [DLocationMapping.LocationMapping]
locationMappingMakerForSearch search = do
  let searchWithIndexes = zip ([1 ..] :: [Int]) search.toLocation
  toLocationMappers <- mapM (locationMappingMakerForSearchInstanceMaker search) searchWithIndexes
  fromLocationMapping <- locationMappingMakerForSearchInstanceMaker search (0, search.fromLocation)
  return $ fromLocationMapping : toLocationMappers

locationMappingMakerForSearchInstanceMaker :: (MonadFlow m) => SearchRequest -> (Int, DLoc.Location) -> m DLocationMapping.LocationMapping
locationMappingMakerForSearchInstanceMaker SearchRequest {..} location = do
  locationMappingId <- generateGUID
  let getIntEpochTime = round `fmap` Time.getPOSIXTime
  epochVersion <- liftIO getIntEpochTime
  let epochVersionLast5Digits = epochVersion `mod` 100000 :: Integer
  let locationMapping =
        DLocationMapping.LocationMapping
          { id = Id locationMappingId,
            tag = DLocationMapping.SearchRequest,
            order = fst location,
            version = show epochVersionLast5Digits,
            tagId = getId id,
            location = snd location,
            ..
          }
  return locationMapping

locationMappingMakerForSearchSP :: (MonadFlow m) => SearchRequestSpecialZone -> m [DLocationMapping.LocationMapping]
locationMappingMakerForSearchSP search = do
  let searchWithIndexes = zip ([1 ..] :: [Int]) search.toLocation
  toLocationMappers <- mapM (locationMappingMakerSPForSearchSPInstanceMaker search) searchWithIndexes
  fromLocationMapping <- locationMappingMakerSPForSearchSPInstanceMaker search (0, search.fromLocation)
  return $ fromLocationMapping : toLocationMappers

locationMappingMakerSPForSearchSPInstanceMaker :: (MonadFlow m) => SearchRequestSpecialZone -> (Int, DLoc.Location) -> m DLocationMapping.LocationMapping
locationMappingMakerSPForSearchSPInstanceMaker SearchRequestSpecialZone {..} location = do
  locationMappingId <- generateGUID
  let getIntEpochTime = round `fmap` Time.getPOSIXTime
  epochVersion <- liftIO getIntEpochTime
  let epochVersionLast5Digits = epochVersion `mod` 100000 :: Integer
  let locationMapping =
        DLocationMapping.LocationMapping
          { id = Id locationMappingId,
            tag = DLocationMapping.SearchRequest,
            order = fst location,
            version = show epochVersionLast5Digits,
            tagId = getId id,
            location = snd location,
            ..
          }
  return locationMapping
