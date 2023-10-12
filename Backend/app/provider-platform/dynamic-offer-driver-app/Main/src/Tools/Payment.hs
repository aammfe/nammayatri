{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Tools.Payment where

import qualified Domain.Types.Merchant.MerchantOperatingCity as DMOC
import qualified Domain.Types.Merchant.MerchantServiceConfig as DMOC
import qualified Kernel.External.Payment.Interface as Payment
import Kernel.External.Types (ServiceFlow)
import Kernel.Prelude
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant.MerchantServiceConfig as CQMSC

createOrder :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.CreateOrderReq -> m Payment.CreateOrderResp
createOrder = runWithServiceConfig Payment.createOrder

orderStatus :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.OrderStatusReq -> m Payment.OrderStatusResp
orderStatus = runWithServiceConfig Payment.orderStatus

offerList :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.OfferListReq -> m Payment.OfferListResp
offerList = runWithServiceConfig Payment.offerList

offerApply :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.OfferApplyReq -> m Payment.OfferApplyResp
offerApply = runWithServiceConfig Payment.offerApply

mandateRevoke :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.MandateRevokeReq -> m Payment.MandateRevokeRes
mandateRevoke = runWithServiceConfig Payment.mandateRevoke

mandateNotification :: (ServiceFlow m r) => Id DMOC.MerchantOperatingCity -> Payment.MandateNotificationReq -> m Payment.MandateNotificationRes
mandateNotification = runWithServiceConfig Payment.mandateNotification

mandateNotificationStatus :: (ServiceFlow m r) => Id DMOC.MerchantOperatingCity -> Payment.NotificationStatusReq -> m Payment.NotificationStatusResp
mandateNotificationStatus = runWithServiceConfig Payment.mandateNotificationStatus

mandateExecution :: ServiceFlow m r => Id DMOC.MerchantOperatingCity -> Payment.MandateExecutionReq -> m Payment.MandateExecutionRes
mandateExecution = runWithServiceConfig Payment.mandateExecution

runWithServiceConfig ::
  ServiceFlow m r =>
  (Payment.PaymentServiceConfig -> req -> m resp) ->
  Id DMOC.MerchantOperatingCity ->
  req ->
  m resp
runWithServiceConfig func merchantOpCityId req = do
  merchantServiceConfig <-
    CQMSC.findByMerchantOpCityIdAndService merchantOpCityId (DMOC.PaymentService Payment.Juspay)
      >>= fromMaybeM (MerchantServiceConfigNotFound merchantOpCityId.getId "Payment" (show Payment.Juspay))
  case merchantServiceConfig.serviceConfig of
    DMOC.PaymentServiceConfig vsc -> func vsc req
    _ -> throwError $ InternalError "Unknown Service Config"
