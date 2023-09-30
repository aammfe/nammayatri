{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.ACL.OnConfirm (buildOnConfirmMessage) where

import qualified Beckn.ACL.Common as Common
import qualified Beckn.Types.Core.Taxi.OnConfirm as OnConfirm
import qualified Domain.Action.Beckn.Confirm as DConfirm
import qualified Domain.Types.Booking as DConfirm
import qualified Domain.Types.Booking.BookingLocation as DBL
import Kernel.Prelude
import Kernel.Types.Beckn.DecimalValue
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import SharedLogic.FareCalculator

buildOnConfirmMessage :: MonadFlow m => DConfirm.DConfirmRes -> m OnConfirm.OnConfirmMessage
buildOnConfirmMessage res = do
  let booking = res.booking
  let vehicleVariant = Common.castVariant res.booking.vehicleVariant
  let itemId = Common.mkItemId res.transporter.shortId.getShortId res.booking.vehicleVariant
      fareParams = booking.fareParams
      totalFareDecimal = fromIntegral booking.estimatedFare
      currency = "INR"
  fulfillmentDetails <- case booking.bookingType of
    DConfirm.SpecialZoneBooking -> do
      otpCode <- booking.specialZoneOtpCode & fromMaybeM (OtpNotFoundForSpecialZoneBooking booking.id.getId)
      return $ mkSpecialZoneFulfillmentInfo res.fromLocation res.toLocation otpCode booking.quoteId OnConfirm.RIDE_OTP res.riderPhoneNumber res.riderMobileCountryCode res.riderName vehicleVariant
    DConfirm.NormalBooking -> return $ mkFulfillmentInfo res.fromLocation res.toLocation booking.quoteId OnConfirm.RIDE res.driverName res.riderPhoneNumber res.riderMobileCountryCode res.riderName vehicleVariant
  return $
    OnConfirm.OnConfirmMessage
      { order =
          OnConfirm.Order
            { id = getId booking.id,
              state = "ACTIVE",
              items = [mkOrderItem itemId booking.quoteId currency totalFareDecimal],
              fulfillment = fulfillmentDetails,
              quote =
                OnConfirm.Quote
                  { price =
                      OnConfirm.QuotePrice
                        { currency,
                          value = totalFareDecimal,
                          offered_value = totalFareDecimal
                        },
                    breakup =
                      Just $
                        mkBreakupList
                          (OnConfirm.BreakupItemPrice currency . fromIntegral)
                          OnConfirm.BreakupItem
                          fareParams
                  },
              provider =
                res.driverId >>= \dId ->
                  Just $
                    OnConfirm.Provider
                      { id = dId
                      },
              payment =
                OnConfirm.Payment
                  { params =
                      OnConfirm.PaymentParams
                        { collected_by = OnConfirm.BPP,
                          instrument = Nothing,
                          currency = currency,
                          amount = Just totalFareDecimal
                        },
                    _type = OnConfirm.ON_FULFILLMENT,
                    uri = booking.paymentUrl
                  }
            }
      }

mkOrderItem :: Text -> Text -> Text -> DecimalValue -> OnConfirm.OrderItem
mkOrderItem itemId fulfillmentId currency totalFareDecimal =
  OnConfirm.OrderItem
    { id = itemId,
      fulfillment_id = fulfillmentId,
      price =
        OnConfirm.Price
          { currency,
            value = totalFareDecimal
          },
      descriptor =
        OnConfirm.Descriptor
          { short_desc = Just itemId,
            code = Nothing
          }
    }

mklocation :: DBL.BookingLocation -> OnConfirm.Location
mklocation loc =
  OnConfirm.Location
    { gps =
        OnConfirm.Gps
          { lat = loc.lat,
            lon = loc.lon
          },
      address = castAddress loc.address
    }
  where
    castAddress DBL.LocationAddress {..} = OnConfirm.Address {area_code = areaCode, locality = area, ward = Nothing, ..}

mkFulfillmentInfo :: DBL.BookingLocation -> DBL.BookingLocation -> Text -> OnConfirm.FulfillmentType -> Maybe Text -> Text -> Text -> Maybe Text -> OnConfirm.VehicleVariant -> OnConfirm.FulfillmentInfo
mkFulfillmentInfo fromLoc toLoc fulfillmentId fulfillmentType driverName riderPhoneNumber riderMobileCountryCode mbRiderName vehicleVariant =
  OnConfirm.FulfillmentInfo
    { id = fulfillmentId,
      _type = fulfillmentType,
      state =
        OnConfirm.FulfillmentState
          { descriptor =
              OnConfirm.Descriptor
                { short_desc = Nothing,
                  code = Just "TRIP_ASSIGNED"
                }
          },
      start =
        OnConfirm.StartInfo
          { location = mklocation fromLoc,
            authorization = Nothing
          },
      end =
        Just
          OnConfirm.StopInfo
            { location = mklocation toLoc
            },
      vehicle =
        OnConfirm.Vehicle
          { category = vehicleVariant
          },
      customer =
        OnConfirm.Customer
          { contact =
              OnConfirm.Contact
                { phone =
                    OnConfirm.Phone
                      { phoneNumber = riderPhoneNumber,
                        phoneCountryCode = riderMobileCountryCode
                      }
                },
            person =
              mbRiderName <&> \riderName ->
                OnConfirm.OrderPerson
                  { name = riderName,
                    tags = Nothing
                  }
          },
      agent =
        driverName >>= \dName ->
          Just
            OnConfirm.Agent
              { name = dName,
                rateable = True,
                tags = Nothing,
                phone = Nothing,
                image = Nothing
              }
    }

mkSpecialZoneFulfillmentInfo :: DBL.BookingLocation -> DBL.BookingLocation -> Text -> Text -> OnConfirm.FulfillmentType -> Text -> Text -> Maybe Text -> OnConfirm.VehicleVariant -> OnConfirm.FulfillmentInfo
mkSpecialZoneFulfillmentInfo fromLoc toLoc otp fulfillmentId fulfillmentType riderPhoneNumber riderMobileCountryCode mbRiderName vehicleVariant = do
  let authorization =
        Just $
          OnConfirm.Authorization
            { _type = "OTP",
              token = otp
            }
  OnConfirm.FulfillmentInfo
    { id = fulfillmentId,
      _type = fulfillmentType,
      state =
        OnConfirm.FulfillmentState
          { descriptor =
              OnConfirm.Descriptor
                { code = Just "NEW",
                  short_desc = Nothing
                }
          },
      start =
        OnConfirm.StartInfo
          { location = mklocation fromLoc,
            authorization = authorization
          },
      end =
        Just
          OnConfirm.StopInfo
            { location = mklocation toLoc
            },
      vehicle =
        OnConfirm.Vehicle
          { category = vehicleVariant
          },
      customer =
        OnConfirm.Customer
          { contact =
              OnConfirm.Contact
                { phone =
                    OnConfirm.Phone
                      { phoneNumber = riderPhoneNumber,
                        phoneCountryCode = riderMobileCountryCode
                      }
                },
            person =
              mbRiderName <&> \riderName ->
                OnConfirm.OrderPerson
                  { name = riderName,
                    tags = Nothing
                  }
          },
      agent = Nothing
    }
