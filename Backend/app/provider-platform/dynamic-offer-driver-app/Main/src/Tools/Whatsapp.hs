{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Tools.Whatsapp
  ( module Reexport,
    whatsAppOptAPI,
  )
where

import Domain.Types.Merchant.MerchantOperatingCity (MerchantOperatingCity)
import qualified Domain.Types.Merchant.MerchantServiceConfig as DMSC
import Kernel.External.Types (ServiceFlow)
import Kernel.External.Whatsapp.Interface as Reexport hiding
  ( whatsAppOptApi,
  )
import qualified Kernel.External.Whatsapp.Interface as GupShup
import Kernel.Prelude
import Kernel.Types.APISuccess (APISuccess (Success))
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant.MerchantServiceConfig as QMSC
import qualified Storage.CachedQueries.Merchant.MerchantServiceUsageConfig as QMSUC

whatsAppOptAPI :: ServiceFlow m r => Id MerchantOperatingCity -> GupShup.OptApiReq -> m APISuccess
whatsAppOptAPI merchantOpCityId req = do
  void $ GupShup.whatsAppOptApi handler req
  return Success
  where
    handler = GupShup.WhatsappHandler {..}

    getProvidersPriorityList = do
      merchantConfig <- QMSUC.findByMerchantOpCityId merchantOpCityId >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantOpCityId.getId)
      let whatsappServiceProviders = merchantConfig.whatsappProvidersPriorityList
      when (null whatsappServiceProviders) $ throwError $ InternalError ("No whatsapp service provider configured for the merchant, merchantOpCityId:" <> merchantOpCityId.getId)
      pure whatsappServiceProviders

    getProviderConfig provider = do
      merchantWhatsappServiceConfig <-
        QMSC.findByMerchantOpCityIdAndService merchantOpCityId (DMSC.WhatsappService provider)
          >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantOpCityId.getId)
      case merchantWhatsappServiceConfig.serviceConfig of
        DMSC.WhatsappServiceConfig msc -> pure msc
        _ -> throwError $ InternalError "Unknown Service Config"
