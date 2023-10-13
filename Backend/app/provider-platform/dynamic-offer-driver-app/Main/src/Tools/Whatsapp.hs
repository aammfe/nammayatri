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
    whatsAppSendMessageWithTemplateIdAPI,
  )
where

import Domain.Types.Merchant
import qualified Domain.Types.Merchant.MerchantServiceConfig as DMSC
import Kernel.External.Types (ServiceFlow)
import Kernel.External.Whatsapp.Interface as Reexport hiding
  ( whatsAppOptApi,
    whatsAppSendMessageWithTemplateIdAPI,
  )
import qualified Kernel.External.Whatsapp.Interface as GupShup
import Kernel.Prelude
import Kernel.Types.APISuccess (APISuccess (Success))
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant.MerchantServiceConfig as QMSC
import qualified Storage.CachedQueries.Merchant.MerchantServiceUsageConfig as QMSUC

whatsAppOptAPI :: ServiceFlow m r => Id Merchant -> GupShup.OptApiReq -> m APISuccess
whatsAppOptAPI merchantId req = do
  void $ GupShup.whatsAppOptApi handler req
  return Success
  where
    handler = GupShup.WhatsappHandler {..}

    getProvidersPriorityList = do
      merchantConfig <- QMSUC.findByMerchantId merchantId >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantId.getId)
      let whatsappServiceProviders = merchantConfig.whatsappProvidersPriorityList
      when (null whatsappServiceProviders) $ throwError $ InternalError ("No whatsapp service provider configured for the merchant, merchantId:" <> merchantId.getId)
      pure whatsappServiceProviders

    getProviderConfig provider = do
      merchantWhatsappServiceConfig <-
        QMSC.findByMerchantIdAndService merchantId (DMSC.WhatsappService provider)
          >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantId.getId)
      case merchantWhatsappServiceConfig.serviceConfig of
        DMSC.WhatsappServiceConfig msc -> pure msc
        _ -> throwError $ InternalError "Unknown Service Config"

whatsAppSendMessageWithTemplateIdAPI :: ServiceFlow m r => Id Merchant -> GupShup.SendWhatsAppMessageWithTemplateIdApIReq -> m SendOtpApiResp
whatsAppSendMessageWithTemplateIdAPI merchantId = GupShup.whatsAppSendMessageWithTemplateIdAPI handler
  where
    handler = GupShup.WhatsappHandler {..}

    getProvidersPriorityList = do
      merchantConfig <- QMSUC.findByMerchantId merchantId >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantId.getId)
      let whatsappServiceProviders = merchantConfig.whatsappProvidersPriorityList
      when (null whatsappServiceProviders) $ throwError $ InternalError ("No whatsapp service provider configured for the merchant, merchantId:" <> merchantId.getId)
      pure whatsappServiceProviders

    getProviderConfig provider = do
      merchantWhatsappServiceConfig <-
        QMSC.findByMerchantIdAndService merchantId (DMSC.WhatsappService provider)
          >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantId.getId)
      case merchantWhatsappServiceConfig.serviceConfig of
        DMSC.WhatsappServiceConfig msc -> pure msc
        _ -> throwError $ InternalError "Unknown Service Config"
