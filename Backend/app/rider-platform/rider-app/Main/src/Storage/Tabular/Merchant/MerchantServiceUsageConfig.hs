{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Tabular.Merchant.MerchantServiceUsageConfig where

import qualified Domain.Types.Merchant.MerchantOperatingCity as Domain
import qualified Domain.Types.Merchant.MerchantServiceUsageConfig as Domain
import Kernel.External.Call.Types (CallService)
import Kernel.External.Maps.Types
import Kernel.External.Notification.Types (NotificationService)
import Kernel.External.SMS (SmsService)
import Kernel.External.Whatsapp.Types (WhatsappService)
import Kernel.Prelude
import Kernel.Storage.Esqueleto
import Kernel.Types.Id
import Storage.Tabular.Merchant.MerchantOperatingCity (MerchantOperatingCityTId)

mkPersist
  defaultSqlSettings
  [defaultQQ|
    MerchantServiceUsageConfigT sql=merchant_service_usage_config
      merchantOperatingCityId MerchantOperatingCityTId
      initiateCall CallService
      getDistances MapsService
      getRoutes MapsService
      snapToRoad MapsService
      getPlaceName MapsService
      getPickupRoutes MapsService
      getTripRoutes MapsService
      getPlaceDetails MapsService
      autoComplete MapsService
      getDistancesForCancelRide MapsService
      notifyPerson NotificationService
      useFraudDetection Bool
      smsProvidersPriorityList (PostgresList SmsService)
      whatsappProvidersPriorityList (PostgresList WhatsappService)
      updatedAt UTCTime
      createdAt UTCTime
      Primary merchantOperatingCityId
      deriving Generic
    |]

instance TEntityKey MerchantServiceUsageConfigT where
  type DomainKey MerchantServiceUsageConfigT = Id Domain.MerchantOperatingCity
  fromKey (MerchantServiceUsageConfigTKey _id) = fromKey _id
  toKey id = MerchantServiceUsageConfigTKey $ toKey id

instance FromTType MerchantServiceUsageConfigT Domain.MerchantServiceUsageConfig where
  fromTType MerchantServiceUsageConfigT {..} = do
    return $
      Domain.MerchantServiceUsageConfig
        { merchantOperatingCityId = fromKey merchantOperatingCityId,
          smsProvidersPriorityList = unPostgresList smsProvidersPriorityList,
          whatsappProvidersPriorityList = unPostgresList whatsappProvidersPriorityList,
          ..
        }

instance ToTType MerchantServiceUsageConfigT Domain.MerchantServiceUsageConfig where
  toTType Domain.MerchantServiceUsageConfig {..} = do
    MerchantServiceUsageConfigT
      { merchantOperatingCityId = toKey merchantOperatingCityId,
        smsProvidersPriorityList = PostgresList smsProvidersPriorityList,
        whatsappProvidersPriorityList = PostgresList whatsappProvidersPriorityList,
        ..
      }
