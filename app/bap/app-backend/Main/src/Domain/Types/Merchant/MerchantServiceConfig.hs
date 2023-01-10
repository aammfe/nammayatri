module Domain.Types.Merchant.MerchantServiceConfig where

import qualified Beckn.External.Maps as Maps
import Beckn.External.Maps.Interface.Types
import Beckn.External.SMS as Sms
import Beckn.Prelude
import Beckn.Types.Id
import qualified Data.List as List
import Domain.Types.Common (UsageSafety (..))
import Domain.Types.Merchant (Merchant)
import qualified Text.Show as Show

data ServiceName = MapsService Maps.MapsService | SmsService Sms.SmsService
  deriving (Generic)

instance Show ServiceName where
  show (MapsService s) = "Maps_" <> show s
  show (SmsService s) = "Sms_" <> show s

instance Read ServiceName where
  readsPrec d' r' =
    readParen
      (d' > app_prec)
      ( \r ->
          [ (MapsService v1, r2)
            | r1 <- stripPrefix "Maps_" r,
              (v1, r2) <- readsPrec (app_prec + 1) r1
          ]
            ++ [ (SmsService v1, r2)
                 | r1 <- stripPrefix "Sms_" r,
                   (v1, r2) <- readsPrec (app_prec + 1) r1
               ]
      )
      r'
    where
      app_prec = 10
      stripPrefix pref r = bool [] [List.drop (length pref) r] $ List.isPrefixOf pref r

data ServiceConfigD (s :: UsageSafety) = MapsServiceConfig !MapsServiceConfig | SmsServiceConfig !SmsServiceConfig
  deriving (Generic, Eq)

type ServiceConfig = ServiceConfigD 'Safe

instance FromJSON (ServiceConfigD 'Unsafe)

instance ToJSON (ServiceConfigD 'Unsafe)

data MerchantServiceConfigD (s :: UsageSafety) = MerchantServiceConfig
  { merchantId :: Id Merchant,
    serviceConfig :: ServiceConfigD s,
    updatedAt :: UTCTime,
    createdAt :: UTCTime
  }
  deriving (Generic)

type MerchantServiceConfig = MerchantServiceConfigD 'Safe

instance FromJSON (MerchantServiceConfigD 'Unsafe)

instance ToJSON (MerchantServiceConfigD 'Unsafe)

getServiceName :: MerchantServiceConfig -> ServiceName
getServiceName msc = case msc.serviceConfig of
  MapsServiceConfig mapsCfg -> case mapsCfg of
    Maps.GoogleConfig _ -> MapsService Maps.Google
    Maps.OSRMConfig _ -> MapsService Maps.OSRM
    Maps.MMIConfig _ -> MapsService Maps.MMI
  SmsServiceConfig smsCfg -> case smsCfg of
    Sms.ExotelSmsConfig _ -> SmsService Sms.ExotelSms
    Sms.MyValueFirstConfig _ -> SmsService Sms.MyValueFirst
