module Fixtures.Ride where

import Beckn.External.Maps.Types
import Beckn.Types.Id
import qualified Domain.Types.Ride as Ride
import EulerHS.Prelude
import qualified Fixtures.Time as Fixtures
import Servant.Client

defaultRide :: Ride.Ride
defaultRide =
  Ride.Ride
    { id = Id "1",
      bookingId = Id "1",
      driverId = Id "1",
      otp = "1234",
      trackingUrl = BaseUrl Https "dummyUrl.wut" 0 "",
      shortId = "",
      fare = Nothing,
      totalFare = Nothing,
      status = Ride.COMPLETED,
      traveledDistance = 20100,
      chargeableDistance = Nothing,
      tripStartTime = Just Fixtures.defaultTime,
      tripEndTime = Nothing,
      tripStartPos = Just $ LatLong 9.95 9.95,
      tripEndPos = Nothing,
      driverArrivalTime = Nothing,
      rideRating = Nothing,
      createdAt = Fixtures.defaultTime,
      updatedAt = Fixtures.defaultTime
    }
