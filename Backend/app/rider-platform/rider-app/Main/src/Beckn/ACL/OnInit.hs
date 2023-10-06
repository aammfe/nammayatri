{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.ACL.OnInit (buildOnInitRideReq) where

import Beckn.ACL.Common
import qualified Beckn.Types.Core.Taxi.API.OnInit as OnInit
import qualified Beckn.Types.Core.Taxi.OnInit as OnInit
import qualified Domain.Action.Beckn.OnInit as DOnInit
import Kernel.Prelude
import Kernel.Product.Validation.Context
import qualified Kernel.Types.Beckn.Context as Context
import Kernel.Types.Id
import Kernel.Utils.Common

buildOnInitRideReq ::
  ( HasFlowEnv m r '["coreVersion" ::: Text]
  ) =>
  OnInit.OnInitReq ->
  m (Maybe DOnInit.OnInitReq)
buildOnInitRideReq req = do
  validateContext Context.ON_INIT $ req.context
  handleError req.contents $ \message -> do
    let bookingId = Just $ Id req.context.message_id
        bppBookingId = Just $ Id message.order.id
        estimatedFare = message.order.quote.price.value
        estimatedTotalFare = fromMaybe estimatedFare message.order.quote.price.offered_value
    validatePrices estimatedFare estimatedTotalFare
    -- if we get here, the discount >= 0
    let discount = if estimatedTotalFare == estimatedFare then Nothing else Just $ estimatedFare - estimatedTotalFare
    return $
      DOnInit.OnInitReq
        { estimatedFare = roundToIntegral estimatedFare,
          estimatedTotalFare = roundToIntegral estimatedTotalFare,
          discount = roundToIntegral <$> discount,
          paymentUrl = message.order.payment.uri,
          ticketId = Nothing,
          fareBreakup = Nothing,
          ..
        }

-- buildOnInitBusReq ::
--   ( HasFlowEnv m r '["coreVersion" ::: Text]
--   ) =>
--   OnInit.OnInitReq ->
--   m (Maybe DOnInit.OnInitReq)
-- buildOnInitBusReq req = do
--   validateBusContext Context.ON_INIT $ req.context
--   handleErrorFRFS req.contents $ \message -> do
--     let ticketId = Just $ Id req.context.message_id
--         -- bppTicketId = Id message.order.id
--         estimatedFare = message.order.quote.price.value
--     -- estimatedTotalFare = message.order.quote.price.offered_value
--     -- validatePrices estimatedFare estimatedTotalFare
--         bppBookingId = Nothing
--         bookingId = Nothing
--     let discount = Money 0
--     return $
--       DOnInit.OnInitReq
--         { estimatedFare = roundToIntegral estimatedFare,
--           estimatedTotalFare = roundToIntegral estimatedFare,
--           discount = Just discount,
--           paymentUrl = message.order.payment.uri,
--           ..
--         }

handleError ::
  (MonadFlow m) =>
  Either Error OnInit.OnInitMessage ->
  (OnInit.OnInitMessage -> m DOnInit.OnInitReq) ->
  m (Maybe DOnInit.OnInitReq)
handleError etr action =
  case etr of
    Right msg -> do
      Just <$> action msg
    Left err -> do
      logTagError "on_init req" $ "on_init error: " <> show err
      pure Nothing

-- handleErrorFRFS ::
--   (MonadFlow m) =>
--   Either Error OnInit.OnInitMessage ->
--   (OnInit.OnInitMessage -> m DOnInit.OnInitReq) ->
--   m (Maybe DOnInit.OnInitReq)
-- handleErrorFRFS etr action =
--   case etr of
--     Right msg -> do
--       Just <$> action msg
--     Left err -> do
--       logTagError "on_init req" $ "on_init error: " <> show err
--       pure Nothing
