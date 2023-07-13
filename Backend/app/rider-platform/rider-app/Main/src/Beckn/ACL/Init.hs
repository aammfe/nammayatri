{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.ACL.Init (buildInitReq) where

import qualified Beckn.ACL.Common as Common
import qualified Beckn.Types.Core.Taxi.Init as Init
import qualified Domain.Types.Booking.BookingLocation as DBL
import qualified Domain.Types.LocationAddress as DLA
import qualified Domain.Types.Merchant.MerchantPaymentMethod as DMPM
import qualified Domain.Types.VehicleVariant as VehVar
import Environment
import Kernel.Prelude
import Kernel.Types.App
import qualified Kernel.Types.Beckn.Context as Context
import Kernel.Types.Beckn.ReqTypes
import Kernel.Types.Logging
import Kernel.Utils.Common (HighPrecMeters)
import Kernel.Utils.Context (buildTaxiContext)
import qualified SharedLogic.Confirm as SConfirm

buildInitReq ::
  (HasBapInfo r m, MonadFlow m) =>
  SConfirm.DConfirmRes ->
  m (BecknReq Init.InitMessage)
buildInitReq res = do
  let transactionId = res.searchRequestId.getId
  bapURIs <- asks (.bapSelfURIs)
  bapIDs <- asks (.bapSelfIds)
  context <- buildTaxiContext Context.INIT res.booking.id.getId (Just transactionId) bapIDs.cabs bapURIs.cabs (Just res.providerId) (Just res.providerUrl) res.city False
  initMessage <- buildInitMessage res
  pure $ BecknReq context initMessage

buildInitMessage :: (MonadThrow m, Log m) => SConfirm.DConfirmRes -> m Init.InitMessage
buildInitMessage res = do
  let (fulfillmentType, mbBppFullfillmentId, mbDriverId) = case res.quoteDetails of
        SConfirm.ConfirmOneWayDetails -> (Init.RIDE, Nothing, Nothing)
        SConfirm.ConfirmRentalDetails _ -> (Init.RIDE, Nothing, Nothing)
        SConfirm.ConfirmAutoDetails estimateId driverId -> (Init.RIDE, Just estimateId, driverId)
        SConfirm.ConfirmOneWaySpecialZoneDetails quoteId -> (Init.RIDE_OTP, Just quoteId, Nothing) --need to be  checked
  let vehicleVariant = castVehicleVariant res.vehicleVariant
  pure
    Init.InitMessage
      { order =
          Init.Order
            { items = [mkOrderItem res.itemId],
              quote = Nothing,
              fulfillment = mkFulfillmentInfo fulfillmentType mbBppFullfillmentId res.fromLoc res.toLoc res.maxEstimatedDistance vehicleVariant,
              payment = mkPayment res.paymentMethodInfo,
              provider = mkProvider mbDriverId
            }
      }
  where
    castVehicleVariant = \case
      VehVar.SEDAN -> Init.SEDAN
      VehVar.SUV -> Init.SUV
      VehVar.HATCHBACK -> Init.HATCHBACK
      VehVar.AUTO_RICKSHAW -> Init.AUTO_RICKSHAW
      VehVar.TAXI -> Init.TAXI
      VehVar.TAXI_PLUS -> Init.TAXI_PLUS

mkProvider :: Maybe Text -> Maybe Init.Provider
mkProvider driverId =
  driverId >>= \dId ->
    Just
      Init.Provider
        { id = dId
        }

mkOrderItem :: Text -> Init.OrderItem
mkOrderItem itemId =
  Init.OrderItem
    { id = itemId,
      price = Nothing
    }

mkFulfillmentInfo :: Init.FulfillmentType -> Maybe Text -> DBL.BookingLocation -> Maybe DBL.BookingLocation -> Maybe HighPrecMeters -> Init.VehicleVariant -> Init.FulfillmentInfo
mkFulfillmentInfo fulfillmentType mbBppFullfillmentId fromLoc mbToLoc maxDistance vehicleVariant =
  Init.FulfillmentInfo
    { id = mbBppFullfillmentId,
      _type = fulfillmentType,
      tags =
        Init.TG
          [ Init.TagGroup
              { display = True,
                code = "estimations",
                name = "Estimations",
                list =
                  [ Init.Tag
                      { display = Just True,
                        code = Just "max_estimated_distance",
                        name = Just "Max Estimated Distance",
                        value = Just $ show maxDistance
                      }
                  ]
              }
          ],
      start =
        Init.StartInfo
          { location =
              Init.Location
                { gps =
                    Init.Gps
                      { lat = fromLoc.lat,
                        lon = fromLoc.lon
                      },
                  address = mkAddress fromLoc.address
                },
            authorization = Nothing
          },
      end =
        mbToLoc >>= \toLoc ->
          Just
            Init.StopInfo
              { location =
                  Init.Location
                    { gps =
                        Init.Gps
                          { lat = toLoc.lat,
                            lon = toLoc.lon
                          },
                      address = mkAddress toLoc.address
                    }
              },
      vehicle =
        Init.Vehicle
          { category = vehicleVariant
          }
    }

mkAddress :: DLA.LocationAddress -> Init.Address
mkAddress DLA.LocationAddress {..} =
  Init.Address
    { area_code = areaCode,
      locality = area,
      ward = ward,
      door = door,
      ..
    }

mkPayment :: Maybe DMPM.PaymentMethodInfo -> Init.Payment
mkPayment (Just DMPM.PaymentMethodInfo {..}) =
  Init.Payment
    { _type = Common.castDPaymentType paymentType,
      time = Init.TimeDuration "P2A", -- FIXME: what is this?
      params =
        Init.PaymentParams
          { collected_by = Common.castDPaymentCollector collectedBy,
            instrument = Just $ Common.castDPaymentInstrument paymentInstrument,
            currency = Nothing,
            amount = Nothing
          },
      uri = Nothing
    }
-- for backward compatibility
mkPayment Nothing =
  Init.Payment
    { _type = Init.ON_FULFILLMENT,
      time = Init.TimeDuration "P2A", -- FIXME: what is this?
      params =
        Init.PaymentParams
          { collected_by = Init.BAP,
            instrument = Nothing,
            currency = Nothing,
            amount = Nothing
          },
      uri = Nothing
    }
