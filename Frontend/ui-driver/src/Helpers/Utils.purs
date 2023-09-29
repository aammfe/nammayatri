{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Helpers.Utils
    ( module Helpers.Utils
    , module ReExport
    ) where

-- import Prelude (Unit, bind, discard, identity, pure, show, unit, void, ($), (<#>), (<$>), (<*>), (<<<), (<>), (>>=))
import Screens.Types (AllocationData, YoutubeData, LeaderBoardDay, LeaderBoardWeek)
import Language.Strings (getString)
import Language.Types(STR(..))
import Data.Array ((!!), elemIndex) as DA
import Data.String (Pattern(..), split) as DS
import Data.Number (pi, sin, cos, asin, sqrt)

import MerchantConfig.Utils

import Common.Types.App (LazyCheck(..))
import Types.App (FlowBT)
import Control.Monad.Except (runExcept)
import Data.Array ((!!)) as DA
import Data.Array.NonEmpty (fromArray)
import Data.Either (Either(..), hush)
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.Show.Generic (genericShow)
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Maybe (Maybe(..))
import Data.Number (pi, sin, cos, asin, sqrt)
import Data.Show.Generic (genericShow)
import Data.String (Pattern(..), split) as DS
import Data.String as DS
import Data.Traversable (traverse)
import Effect (Effect)
import Effect.Aff (error, killFiber, launchAff, launchAff_, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Engineering.Helpers.Commons (parseFloat, setText, getCurrentUTC) as ReExport
import Foreign (Foreign)
import Foreign.Class (class Decode, class Encode, decode)
import Juspay.OTP.Reader (initiateSMSRetriever)
import Juspay.OTP.Reader as Readers
import Juspay.OTP.Reader.Flow as Reader
import Language.Strings (getString)
import Language.Types (STR(..))
import Prelude (class EuclideanRing, Unit, bind, discard, identity, pure, unit, void, ($), (+), (<#>), (<*>), (<>), (*>), (>>>), ($>), (/=), (&&), (<=), show)
import Prelude (class Eq, class Show, (<<<))
import Prelude (map, (*), (-), (/))
import Presto.Core.Utils.Encoding (defaultEnumDecode, defaultEnumEncode)
import Data.Function.Uncurried (Fn4(..), Fn3(..), runFn4, runFn3)
import Effect.Uncurried (EffectFn1(..))
import Screens.Types (AllocationData, LeaderBoardWeek, YoutubeData, LeaderBoardDay)
import Common.Types.App (OptionButtonList)
import Engineering.Helpers.Commons (parseFloat, setText, convertUTCtoISC, getCurrentUTC) as ReExport
import Services.API(PaymentPagePayload)
import Presto.Core.Types.Language.Flow (Flow, doAff, loadS)
import Control.Monad.Except.Trans (lift)
import Foreign.Generic (Foreign, decodeJSON, encodeJSON)
import Data.Newtype (class Newtype)
import Presto.Core.Types.API (class StandardEncode, standardEncode)
import Services.API (PaymentPagePayload, PromotionPopupConfig)
import Storage (KeyStore) 
import JBridge (getCurrentPositionWithTimeout)
import Effect.Uncurried(EffectFn1, EffectFn4)
import Storage (KeyStore(..))
import Styles.Colors as Color

foreign import shuffle :: forall a. Array a -> Array a
foreign import generateUniqueId :: Unit -> String
foreign import storeCallBackTime :: forall action. (action -> Effect Unit) -> (String -> String -> String -> action)  -> Effect Unit
foreign import getTime :: Unit -> Int
foreign import countDown :: forall action. Int -> String -> (action -> Effect Unit) -> (Int -> String -> String -> String-> action)  -> Effect Unit
foreign import hideSplash :: Effect Unit
foreign import startTimer :: forall action. Int -> Boolean -> (action -> Effect Unit) -> (String -> action) -> Effect Unit
foreign import convertKmToM :: String -> String
foreign import clearTimer :: String -> Unit
foreign import clearPopUpTimer :: String -> Unit
foreign import clearAllTimer :: String -> Unit
foreign import toString :: forall a. a-> String
foreign import toInt :: forall a. a -> String
foreign import setRefreshing :: String -> Boolean -> Unit
foreign import setEnabled :: String -> Boolean -> Unit
foreign import decodeErrorCode :: String -> String
foreign import decodeErrorMessage :: String -> String
foreign import storeCallBackForNotification :: forall action. (action -> Effect Unit) -> (String -> action) -> Effect Unit
foreign import secondsLeft :: String -> Int
foreign import objectToAllocationType :: String -> AllocationData
foreign import getcurrentdate :: String -> String
foreign import getDatebyCount :: Int -> String
foreign import launchAppSettings :: Unit -> Effect Unit
foreign import setYoutubePlayer :: YoutubeData -> String -> String -> Unit
foreign import getTimeStampString :: String -> String
foreign import addMediaPlayer :: String -> String -> Effect Unit
foreign import getVideoID :: String -> String
foreign import getImageUrl :: String -> String
foreign import parseNumber :: Int -> String

foreign import isYesterday :: String -> Boolean

-- -- ####### MAP FFI ######## -----
foreign import currentPosition  :: String -> Effect Unit
foreign import getPastDays :: Int -> Array LeaderBoardDay
foreign import getPastWeeks :: Int -> Array LeaderBoardWeek
foreign import getZoneTagConfig :: forall f a. Fn4 (f -> Maybe f) (Maybe f) String String (Maybe String)
foreign import getPeriod :: String -> Period
foreign import clampNumber :: Number -> Number -> Int -> Int
foreign import getPopupObject :: forall f a. Fn3 (f -> Maybe f) (Maybe f) String (Maybe PromotionPopupConfig)


getPopupObjectFromSharedPrefs :: KeyStore -> Maybe PromotionPopupConfig
getPopupObjectFromSharedPrefs key = runFn3 getPopupObject Just Nothing (show key) 

type Period
  = { period :: Int
    , periodType :: String
    }


otpRule :: Reader.OtpRule
otpRule = Reader.OtpRule {
  matches : {
    sender : [],
    message : (getValueFromConfig "OTP_MESSAGE_REGEX")
  },
  otp : "\\d{4}",
  group : Nothing
}

startOtpReciever :: forall action. (String -> action) -> (action -> Effect Unit) -> Effect (Effect Unit)
startOtpReciever action push = do
  fiber <- launchAff $ do
    otpListener <- traverse Readers.getOtpListener $ fromArray [ Readers.smsRetriever ]
    _ <- traverse identity $ (otpListener <#> _.setOtpRules) <*> Just [otpRule]
    message <- traverse identity $ (otpListener <#> _.getNextOtp)
    case message of
      Just (Readers.Otp val _ _) -> liftEffect $ push $ action val
      _ -> pure unit
    void $ initiateSMSRetriever
    liftEffect $ startOtpReciever action push
  pure $ launchAff_ $ killFiber (error "Failed to Cancel") fiber

-- -- type Locations = {
-- --     paths :: Array Paths
-- -- }


-- -- type Paths = {
-- --     points :: Points
-- -- }

-- -- type Points = {
-- --     type :: String
-- -- ,   coordinates :: Array Point
-- -- }

-- -- type Point = Array Number

-- -- type Markers = {
-- --     markerObject :: Array MarkerObject
-- -- }

-- -- type MarkerObject = {
-- --     type :: String,
-- --     title :: String,
-- --     coordinates :: Array Number
-- -- }

-- -- newtype LocationLatLong = LocationLatLong
-- --   { lat :: String
-- --   , long :: String
-- --   }

-- -- derive instance genericLocationLatLong :: Generic LocationLatLong _
-- -- derive instance newtypeLocationLatLong :: Newtype LocationLatLong _
-- -- instance encodeLocationLatLong :: Encode LocationLatLong where encode = defaultEncode
-- -- instance decodeLocationLatLong :: Decode LocationLatLong where decode = defaultDecode

getDistanceBwCordinates :: Number -> Number -> Number -> Number -> Number
getDistanceBwCordinates lat1 long1 lat2 long2 = do
    let latPoint1 = toRad (lat1)
    let lngPoint1 = toRad (long1)
    let latPoint2 = toRad (lat2)
    let lngPoint2 = toRad (long2)
    let dlong = toRad (long2 - (long1))
    let lati1 = toRad (lat1)
    let lati2 = toRad (lat2)
    let dist = sin ((latPoint2 - latPoint1) / 2.0 ) * sin ((latPoint2 - latPoint1) / 2.0 ) + cos(latPoint1) * cos(latPoint2) * sin ((lngPoint2 - lngPoint1) / 2.0 ) * sin ((lngPoint2 - lngPoint1) / 2.0 )
    let dist1 = (2.0 * 6371.0 * asin ( sqrt dist))
    dist1

toRad :: Number -> Number
toRad n = (n * pi) / 180.0

getDowngradeOptions :: String -> Array String
getDowngradeOptions vehicleType = case vehicleType of
  "SEDAN" -> ["HATCHBACK"]
  "SUV" -> ["HATCHBACK", "SEDAN"]
  "TAXI_PLUS" -> ["TAXI"]
  _ -> []

getVehicleType :: String -> String
getVehicleType vehicleType =
  case vehicleType of
    "SEDAN" -> (getString SEDAN )
    "SUV"   -> (getString SUV)
    "HATCHBACK" -> (getString HATCHBACK)
    "AUTO_RICKSHAW" -> (getString AUTO_RICKSHAW)
    "TAXI" -> (getString TAXI)
    "TAXI_PLUS" -> (getString TAXI_PLUS)
    _ -> ""

getSpecialZoneConfig :: String -> Maybe String -> String
getSpecialZoneConfig prop tag = do
  case getRequiredTag prop tag of
    Nothing -> ""
    Just tag' -> tag'

getRequiredTag :: String -> Maybe String -> Maybe String
getRequiredTag prop tag = do
  case tag of
    Nothing -> Nothing
    Just tag' -> do
        let arr = DS.split (DS.Pattern "_") tag'
        let pickup = fromMaybe "" (arr DA.!! 0)
        let drop = fromMaybe "" (arr DA.!! 1)
        let priority = fromMaybe "" (arr DA.!! 2)
        case priority of
          "PriorityPickup" -> case (runFn4 getZoneTagConfig Just Nothing prop (pickup <> "_Pickup")) of
                                Nothing -> Nothing
                                Just val -> Just val
          "PriorityDrop" -> case (runFn4 getZoneTagConfig Just Nothing prop (drop <> "_Drop")) of
                                Nothing -> Nothing
                                Just val -> Just val
          _ -> Nothing

getGenderIndex :: String -> Array OptionButtonList -> Maybe Int
getGenderIndex req arr = do
  let reqArray = map(\ele -> ele.reasonCode) arr
      reqIndex = DA.elemIndex req reqArray
  reqIndex

getMerchantVehicleSize :: Unit -> Int
getMerchantVehicleSize unit = 
  case getMerchant FunctionCall of 
    _ -> 90

getAssetStoreLink :: LazyCheck -> String
getAssetStoreLink lazy = case (getMerchant lazy) of
  NAMMAYATRI -> "https://assets.juspay.in/beckn/nammayatri/driver/images/"
  YATRISATHI -> "https://assets.juspay.in/beckn/jatrisaathi/driver/images/"
  YATRI -> "https://assets.juspay.in/beckn/yatri/driver/images/"
  MOBILITY_PM -> "https://assets.juspay.in/beckn/mobilitypaytm/driver/"
  PASSCULTURE -> "https://assets.juspay.in/beckn/passculture/driver/images"
  MOBILITY_RS -> "https://assets.juspay.in/beckn/passculture/driver/images"

getAssetsBaseUrl :: LazyCheck -> String
getAssetsBaseUrl lazy = case (getMerchant lazy) of
  NAMMAYATRI -> "https://assets.juspay.in/beckn/nammayatri/driver/"
  YATRISATHI -> "https://assets.juspay.in/beckn/jatrisaathi/driver/"
  YATRI -> "https://assets.juspay.in/beckn/yatri/driver/"
  MOBILITY_PM -> "https://assets.juspay.in/beckn/mobilitypaytm/"
  PASSCULTURE -> "https://assets.juspay.in/beckn/passculture/driver"
  MOBILITY_RS -> "https://assets.juspay.in/beckn/passculture/driver"

getCommonAssetStoreLink :: LazyCheck -> String
getCommonAssetStoreLink lazy = case (getMerchant lazy) of
  NAMMAYATRI -> "https://assets.juspay.in/beckn/nammayatri/nammayatricommon/images/"
  YATRISATHI -> "https://assets.juspay.in/beckn/jatrisaathi/jatrisaathicommon/images/"
  YATRI -> "https://assets.juspay.in/beckn/yatri/yatricommon/images/"
  MOBILITY_PM -> "https://assets.juspay.in/beckn/mobilitypaytm/mobilitypaytmcommon/"
  PASSCULTURE -> "https://assets.juspay.in/beckn/passculture/passculturecommon/"
  MOBILITY_RS -> "https://assets.juspay.in/beckn/passculture/passculturecommon/"


type AffSuccess s = (s -> Effect Unit)
type MicroAPPInvokeSignature = String -> (AffSuccess String) ->  Effect Unit


foreign import startPP :: MicroAPPInvokeSignature

foreign import initiatePP :: EffectFn1 Unit Unit

foreign import checkPPInitiateStatus :: EffectFn1 (Unit -> Effect Unit) Unit

foreign import killPP :: Effect Unit

foreign import consumeBP :: EffectFn1 Unit Unit

paymentPageUI :: PaymentPagePayload -> FlowBT String String
paymentPageUI payload = lift $ lift $ doAff $ makeAff (\cb -> (startPP (encodeJSON payload) (Right >>> cb) ) *> pure nonCanceler)

getNegotiationUnit :: String -> String
getNegotiationUnit varient = case varient of
  "AUTO_RICKSHAW" -> "10"
  _ -> "20"
  
getValueBtwRange :: forall a. EuclideanRing a => a -> a -> a -> a -> a -> a
getValueBtwRange  x  in_min  in_max  out_min  out_max = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min 

data LatLon = LatLon String String

getCurrentLocation :: Number -> Number -> Number -> Number -> Int -> FlowBT String LatLon
getCurrentLocation currentLat currentLon sourceLat sourceLon timeOut = do
  (LatLon startRideCurrentLat startRideCurrentLong) <- (lift $ lift $ doAff $ makeAff \cb -> getCurrentPositionWithTimeout (cb <<< Right) LatLon timeOut $> nonCanceler)
  if(startRideCurrentLat /= "0.0" && startRideCurrentLong /= "0.0") then
    pure (LatLon startRideCurrentLat startRideCurrentLong)
  else do
    if sourceLat /= 0.0 && sourceLon /= 0.0 && currentLat /= 0.0 && currentLon /= 0.0 then do
      let distanceDiff = (getDistanceBwCordinates currentLat currentLon sourceLat sourceLon)
          rideLat = show $ if distanceDiff <= 0.10 then  currentLat else sourceLat
          rideLong = show $ if distanceDiff <= 0.10 then currentLon else sourceLon
      pure (LatLon rideLat rideLong)
      else do
        rideLat <- lift $ lift $ loadS $ show LAST_KNOWN_LAT 
        rideLong <- lift $ lift $ loadS $ show LAST_KNOWN_LON
        case rideLat,rideLong of
          Just lat, Just lon -> pure (LatLon lat lon)
          _,_ -> pure (LatLon "0.0" "0.0")

getRideTypeColor :: Maybe String -> String
getRideTypeColor variant = case getCategorizedVariant variant of
    "AC Taxi" -> Color.blue800
    "Non AC" -> Color.orange900
    _ -> Color.black800

getCategorizedVariant :: Maybe String -> String
getCategorizedVariant variant = case variant of
  Just var -> case (getMerchant FunctionCall) of
    YATRISATHI -> case var of
      "SEDAN"  -> "AC Taxi"
      "HATCHBACK"  -> "AC Taxi"
      "TAXI_PLUS"  -> "AC Taxi"
      "SUV" -> "AC Taxi"
      _ -> "Non AC"
    _ -> case var of
      "SEDAN"  -> "Sedan"
      "HATCHBACK"  -> "Hatchback"
      "TAXI_PLUS"  -> "AC Taxi"
      "SUV" -> "Suv"
      "AUTO_RICKSHAW" -> "Auto Rickshaw"
      _ -> var
  Nothing -> ""
