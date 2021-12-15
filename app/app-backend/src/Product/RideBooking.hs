module Product.RideBooking where

import App.Types
import Beckn.Types.Id
import EulerHS.Prelude hiding (id)
import qualified Storage.Queries.Ride as QRide
import qualified Storage.Queries.RideBooking as QRB
import qualified Storage.Queries.SearchReqLocation as QLoc
import qualified Types.API.RideBooking as API
import Types.Error
import qualified Types.Storage.Person as Person
import qualified Types.Storage.Ride as SRide
import qualified Types.Storage.RideBooking as SRB
import qualified Types.Storage.SearchReqLocation as SLoc
import Utils.Common

rideBookingStatus :: Id SRB.RideBooking -> Id Person.Person -> FlowHandler API.RideBookingStatusRes
rideBookingStatus rideBookingId personId = withFlowHandlerAPI $ do
  rideBooking <- QRB.findById rideBookingId >>= fromMaybeM RideBookingDoesNotExist
  unless (rideBooking.requestorId == personId) $ throwError AccessDenied
  buildRideBookingStatusRes rideBooking

rideBookingList :: Id Person.Person -> Maybe Integer -> Maybe Integer -> Maybe Bool -> FlowHandler API.RideBookingListRes
rideBookingList personId mbLimit mbOffset mbOnlyActive = withFlowHandlerAPI $ do
  rbList <- QRB.findAllByRequestorId personId mbLimit mbOffset mbOnlyActive
  API.RideBookingListRes <$> traverse buildRideBookingStatusRes rbList

buildRideBookingStatusRes :: DBFlow m r => SRB.RideBooking -> m API.RideBookingStatusRes
buildRideBookingStatusRes rideBooking = do
  fromLocation <- QLoc.findLocationById rideBooking.fromLocationId >>= fromMaybeM LocationNotFound
  toLocation <- QLoc.findLocationById rideBooking.toLocationId >>= fromMaybeM LocationNotFound
  let rbStatus = rideBooking.status
  mbRideAPIEntity <-
    QRide.findByRBId rideBooking.id
      <&> fmap SRide.makeRideAPIEntity

  return $
    API.RideBookingStatusRes
      { id = rideBooking.id,
        status = rbStatus,
        agencyName = rideBooking.providerName,
        agencyNumber = rideBooking.providerMobileNumber,
        estimatedFare = rideBooking.estimatedFare,
        discount = rideBooking.discount,
        estimatedTotalFare = rideBooking.estimatedTotalFare,
        toLocation = SLoc.makeSearchReqLocationAPIEntity toLocation,
        fromLocation = SLoc.makeSearchReqLocationAPIEntity fromLocation,
        ride = mbRideAPIEntity,
        createdAt = rideBooking.createdAt,
        updatedAt = rideBooking.updatedAt
      }
