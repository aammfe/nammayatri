{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.ACL.OnInit where

import qualified Beckn.ACL.Common as Common
import Beckn.Types.Core.Taxi.OnInit as OnInit
import Domain.Action.Beckn.Init as DInit
import qualified Domain.Types.Booking as DRB
import qualified Domain.Types.FareParameters as DFParams
import qualified Domain.Types.Location as DL
import qualified Domain.Types.Vehicle.Variant as VehVar
import Kernel.Prelude
import SharedLogic.FareCalculator

mkOnInitMessage :: DInit.InitRes -> OnInit.OnInitMessage
mkOnInitMessage res = do
  let rb = res.booking
      vehicleVariant = castVehicleVariant res.booking.vehicleVariant
      itemId = Common.mkItemId res.transporter.shortId.getShortId res.booking.vehicleVariant
      fareDecimalValue = fromIntegral rb.estimatedFare
      currency = "INR"
      breakup_ =
        mkBreakupList (OnInit.BreakupItemPrice currency . fromIntegral) OnInit.BreakupItem rb.fareParams
          & filter (filterRequiredBreakups $ DFParams.getFareParametersType rb.fareParams) -- TODO: Remove after roll out
  OnInit.OnInitMessage
    { order =
        OnInit.Order
          { id = res.booking.id.getId,
            items =
              [ OnInit.OrderItem
                  { id = itemId,
                    fulfillment_id = res.booking.quoteId,
                    price =
                      OnInit.Price
                        { currency,
                          value = fareDecimalValue
                        },
                    descriptor =
                      OnInit.Descriptor
                        { short_desc = Just itemId,
                          code = Nothing,
                          name = Nothing,
                          images = Nothing
                        }
                  }
              ],
            fulfillment =
              OnInit.FulfillmentInfo
                { id = res.booking.quoteId,
                  _type = buildFulfillmentType res.booking.bookingType,
                  start =
                    OnInit.StartInfo
                      { location =
                          OnInit.Location
                            { gps =
                                OnInit.Gps
                                  { lat = res.booking.fromLocation.lat,
                                    lon = res.booking.fromLocation.lon
                                  },
                              address = Just $ castAddress res.booking.fromLocation.address,
                              descriptor = Nothing
                            },
                        authorization = Nothing
                      },
                  end =
                    Just
                      OnInit.StopInfo
                        { location =
                            OnInit.Location
                              { gps =
                                  OnInit.Gps
                                    { lat = res.booking.toLocation.lat,
                                      lon = res.booking.toLocation.lon
                                    },
                                address = Just $ castAddress res.booking.toLocation.address,
                                descriptor = Nothing
                              }
                        },
                  vehicle =
                    OnInit.Vehicle
                      { category = vehicleVariant
                      },
                  agent =
                    res.driverName >>= \driverName ->
                      Just
                        OnInit.Agent
                          { name = driverName,
                            rateable = True,
                            tags = Nothing,
                            phone = Nothing,
                            image = Nothing
                          },
                  tracking = Nothing,
                  tags = Nothing
                },
            state = OnInit.NEW,
            quote =
              OnInit.Quote
                { price =
                    OnInit.QuotePrice
                      { currency,
                        value = fareDecimalValue,
                        offered_value = Just fareDecimalValue
                      },
                  breakup = Just breakup_
                },
            provider =
              res.driverId >>= \dId ->
                Just
                  OnInit.Provider
                    { id = dId,
                      descriptor = Nothing
                    },
            payment =
              OnInit.Payment
                { params =
                    Just
                      OnInit.PaymentParams
                        { collected_by = OnInit.BPP, --maybe OnInit.BPP (Common.castDPaymentCollector . (.collectedBy)) res.paymentMethodInfo,
                          instrument = Common.castDPaymentInstrument . (.paymentInstrument) <$> res.paymentMethodInfo,
                          currency = currency,
                          amount = Just fareDecimalValue,
                          transaction_id = Nothing
                        },
                  _type = maybe OnInit.ON_FULFILLMENT (Common.castDPaymentType . (.paymentType)) res.paymentMethodInfo,
                  uri = res.booking.paymentUrl,
                  tl_method = Nothing,
                  status = Nothing
                },
            billing = Nothing
          }
    }
  where
    castAddress DL.LocationAddress {..} = OnInit.Address {area_code = areaCode, locality = area, ward = Nothing, ..}
    castVehicleVariant = \case
      VehVar.SEDAN -> OnInit.SEDAN
      VehVar.SUV -> OnInit.SUV
      VehVar.HATCHBACK -> OnInit.HATCHBACK
      VehVar.AUTO_RICKSHAW -> OnInit.AUTO_RICKSHAW
      VehVar.TAXI -> OnInit.TAXI
      VehVar.TAXI_PLUS -> OnInit.TAXI_PLUS
      VehVar.BUS -> OnInit.BUS
    buildFulfillmentType = \case
      DRB.NormalBooking -> OnInit.RIDE
      DRB.SpecialZoneBooking -> OnInit.RIDE_OTP
    filterRequiredBreakups fParamsType breakup = do
      case fParamsType of
        DFParams.Progressive ->
          breakup.title == "BASE_FARE"
            || breakup.title == "DEAD_KILOMETER_FARE"
            || breakup.title == "EXTRA_DISTANCE_FARE"
            || breakup.title == "DRIVER_SELECTED_FARE"
            || breakup.title == "CUSTOMER_SELECTED_FARE"
            || breakup.title == "TOTAL_FARE"
            || breakup.title == "WAITING_OR_PICKUP_CHARGES"
        DFParams.Slab ->
          breakup.title == "BASE_FARE"
            || breakup.title == "SERVICE_CHARGE"
            || breakup.title == "WAITING_OR_PICKUP_CHARGES"
            || breakup.title == "PLATFORM_FEE"
            || breakup.title == "SGST"
            || breakup.title == "CGST"
            || breakup.title == "FIXED_GOVERNMENT_RATE"
            || breakup.title == "CUSTOMER_SELECTED_FARE"
            || breakup.title == "TOTAL_FARE"
            || breakup.title == "NIGHT_SHIFT_CHARGE"
