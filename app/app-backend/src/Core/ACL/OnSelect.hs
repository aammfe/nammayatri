module Core.ACL.OnSelect where

import Beckn.Prelude
import Beckn.Product.Validation.Context
import Beckn.Types.Common
import qualified Beckn.Types.Core.Context as Context
import qualified Beckn.Types.Core.Taxi.API.OnSelect as OnSelect
import qualified Beckn.Types.Core.Taxi.OnSelect as OnSelect
import Beckn.Types.Id
import Core.ACL.Common
import qualified Domain.Action.Beckn.OnSelect as DOnSelect
import Domain.Types.VehicleVariant
import Types.Error
import Utils.Common

buildOnSelectReq ::
  HasFlowEnv m r ["coreVersion" ::: Text, "domainVersion" ::: Text] =>
  OnSelect.OnSelectReq ->
  m (Maybe DOnSelect.DOnSelectReq)
buildOnSelectReq req = do
  logDebug $ "on_select request: " <> show req
  let context = req.context
  validateContext Context.ON_SELECT context
  handleError req.contents $ \message -> do
    providerId <- context.bpp_id & fromMaybeM (InvalidRequest "Missing bpp_id")
    providerUrl <- context.bpp_uri & fromMaybeM (InvalidRequest "Missing bpp_uri")
    let provider = message.order.provider
    let items = provider.items
    quotesInfo <- traverse buildQuoteInfo items
    let providerInfo =
          DOnSelect.ProviderInfo
            { providerId = providerId,
              name = provider.descriptor.name,
              url = providerUrl,
              mobileNumber = provider.contacts,
              ridesCompleted = provider.tags.rides_completed
            }
    pure
      DOnSelect.DOnSelectReq
        { estimateId = Id context.message_id,
          ..
        }

handleError ::
  (MonadFlow m) =>
  Either Error OnSelect.OnSelectMessage ->
  (OnSelect.OnSelectMessage -> m DOnSelect.DOnSelectReq) ->
  m (Maybe DOnSelect.DOnSelectReq)
handleError etr action =
  case etr of
    Right msg -> do
      Just <$> action msg
    Left err -> do
      logTagError "on_select req" $ "on_select error: " <> show err
      pure Nothing

buildQuoteInfo ::
  (MonadThrow m, Log m) =>
  OnSelect.Item ->
  m DOnSelect.QuoteInfo
buildQuoteInfo item = do
  quoteDetails <- case item.category_id of
    OnSelect.ONE_WAY_TRIP -> throwError $ InvalidRequest "select not supported for one way trip"
    OnSelect.RENTAL_TRIP -> throwError $ InvalidRequest "select not supported for rental trip"
    OnSelect.DRIVER_OFFER -> buildDriverOfferQuoteDetails item
    OnSelect.DRIVER_OFFER_ESTIMATE -> throwError $ InvalidRequest "Estimates are only supported in on_search"
  let itemCode = item.descriptor.code
      vehicleVariant = itemCode.vehicleVariant
      estimatedFare = roundToIntegral item.price.value
      estimatedTotalFare = roundToIntegral item.price.offered_value
      descriptions = item.quote_terms
  validatePrices estimatedFare estimatedTotalFare
  -- if we get here, the discount >= 0, estimatedFare >= estimatedTotalFare
  let discount = if estimatedTotalFare == estimatedFare then Nothing else Just $ estimatedFare - estimatedTotalFare
  pure
    DOnSelect.QuoteInfo
      { vehicleVariant = castVehicleVariant vehicleVariant,
        ..
      }
  where
    castVehicleVariant = \case
      OnSelect.SEDAN -> SEDAN
      OnSelect.SUV -> SUV
      OnSelect.HATCHBACK -> HATCHBACK
      OnSelect.AUTO_RICKSHAW -> AUTO_RICKSHAW

buildDriverOfferQuoteDetails ::
  (MonadThrow m, Log m) =>
  OnSelect.Item ->
  m DOnSelect.DriverOfferQuoteDetails
buildDriverOfferQuoteDetails item = do
  driverName <- item.driver_name & fromMaybeM (InvalidRequest "Missing driver_name in driver offer select item")
  durationToPickup <- item.duration_to_pickup & fromMaybeM (InvalidRequest "Missing duration_to_pickup in driver offer select item")
  distanceToPickup' <-
    (item.tags <&> (.distance_to_nearest_driver))
      & fromMaybeM (InvalidRequest "Trip type is DRIVER_OFFER, but distance_to_nearest_driver is Nothing")
  validTill <- item.valid_till & fromMaybeM (InvalidRequest "Missing valid_till in driver offer select item")
  let rating = item.rating
  let bppQuoteId = item.id
  pure $
    DOnSelect.DriverOfferQuoteDetails
      { distanceToPickup = realToFrac distanceToPickup',
        bppDriverQuoteId = Id bppQuoteId,
        ..
      }
