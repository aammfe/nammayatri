module Core.ACL.OnConfirm (mkOnConfirmMessage) where

import Beckn.Prelude
import Beckn.Types.Core.Taxi.Common.DecimalValue (DecimalValue)
import qualified Beckn.Types.Core.Taxi.OnConfirm as OnConfirm
import Beckn.Types.Id
import qualified Domain.Action.Beckn.Confirm as DConfirm
import qualified Domain.Types.Booking.BookingLocation as DBL
import qualified Domain.Types.Vehicle as Veh

mkOnConfirmMessage :: DConfirm.DConfirmRes -> OnConfirm.OnConfirmMessage
mkOnConfirmMessage res = do
  let booking = res.booking
  OnConfirm.OnConfirmMessage
    { order =
        OnConfirm.Order
          { id = getId booking.id,
            state = "ACTIVE",
            items = [mkOrderItem itemCode],
            fulfillment = mkFulfillmentInfo res.fromLocation res.toLocation booking.startTime,
            quote =
              OnConfirm.Quote
                { price = mkPrice (fromIntegral booking.estimatedFare) (fromIntegral booking.estimatedTotalFare),
                  breakup = mkBreakup (fromIntegral booking.estimatedFare) (fromIntegral <$> booking.discount)
                },
            payment = mkPayment $ fromIntegral booking.estimatedTotalFare
          }
    }
  where
    itemCode = do
      let (fpType, mbDistance, mbDuration) = case res.bDetails of
            DConfirm.OneWayDetails -> (OnConfirm.ONE_WAY_TRIP, Nothing, Nothing)
            DConfirm.RentalDetails {baseDistance, baseDuration} -> (OnConfirm.RENTAL_TRIP, Just baseDistance, Just baseDuration)
          vehicleVariant = case res.booking.vehicleVariant of
            Veh.SEDAN -> OnConfirm.SEDAN
            Veh.SUV -> OnConfirm.SUV
            Veh.HATCHBACK -> OnConfirm.HATCHBACK
      OnConfirm.ItemCode fpType vehicleVariant mbDistance mbDuration

mkOrderItem :: OnConfirm.ItemCode -> OnConfirm.OrderItem
mkOrderItem code =
  OnConfirm.OrderItem
    { descriptor =
        OnConfirm.Descriptor
          { code = code
          }
    }

mkFulfillmentInfo :: DBL.BookingLocation -> Maybe DBL.BookingLocation -> UTCTime -> OnConfirm.FulfillmentInfo
mkFulfillmentInfo fromLoc mbToLoc startTime =
  OnConfirm.FulfillmentInfo
    { state = OnConfirm.FulfillmentState "SEARCHING_FOR_DRIVERS",
      start =
        OnConfirm.StartInfo
          { location =
              OnConfirm.Location
                { gps =
                    OnConfirm.Gps
                      { lat = fromLoc.lat,
                        lon = fromLoc.lon
                      },
                  address = castAddress fromLoc.address
                },
            time = OnConfirm.TimeTimestamp startTime
          },
      end =
        mbToLoc >>= \toLoc ->
          Just
            OnConfirm.StopInfo
              { location =
                  OnConfirm.Location
                    { gps =
                        OnConfirm.Gps
                          { lat = toLoc.lat,
                            lon = toLoc.lon
                          },
                      address = castAddress toLoc.address
                    }
              }
    }
  where
    castAddress DBL.LocationAddress {..} = OnConfirm.Address {area_code = areaCode, ..}

mkPrice :: DecimalValue -> DecimalValue -> OnConfirm.QuotePrice
mkPrice estimatedFare estimatedTotalFare =
  OnConfirm.QuotePrice
    { currency = "INR",
      value = estimatedFare,
      offered_value = estimatedTotalFare
    }

mkBreakup :: DecimalValue -> Maybe DecimalValue -> [OnConfirm.BreakupItem]
mkBreakup estimatedFare mbDiscount = [estimatedFareBreakupItem] <> maybeToList mbDiscountBreakupItem
  where
    estimatedFareBreakupItem =
      OnConfirm.BreakupItem
        { title = "Estimated trip fare",
          price =
            OnConfirm.BreakupItemPrice
              { currency = "INR",
                value = estimatedFare
              }
        }

    mbDiscountBreakupItem =
      mbDiscount <&> \discount ->
        OnConfirm.BreakupItem
          { title = "Discount",
            price =
              OnConfirm.BreakupItemPrice
                { currency = "INR",
                  value = discount
                }
          }

mkPayment :: DecimalValue -> OnConfirm.Payment
mkPayment estimatedTotalFare =
  OnConfirm.Payment
    { collected_by = "BAP",
      params =
        OnConfirm.PaymentParams
          { amount = estimatedTotalFare,
            currency = "INR"
          },
      time = OnConfirm.TimeDuration "P2D",
      _type = OnConfirm.ON_FULFILLMENT
    }
