module Product.Feedback where

import qualified App.Types as App
import Beckn.Types.APISuccess (APISuccess (Success))
import qualified Beckn.Types.Core.ReqTypes as Common
import qualified Beckn.Types.Core.Taxi.Common.Context as Context
import qualified Beckn.Types.Core.Taxi.Rating as Rating
import Beckn.Types.Id
import Beckn.Utils.Logging
import qualified Domain.Types.Person as Person
import EulerHS.Prelude hiding (product)
import qualified ExternalAPI.Flow as ExternalAPI
import qualified Storage.Queries.Ride as QRide
import qualified Storage.Queries.RideBooking as QRB
import qualified Types.API.Feedback as API
import Types.Error
import Utils.Common

feedback :: Id Person.Person -> API.FeedbackReq -> App.FlowHandler API.FeedbackRes
feedback personId request = withFlowHandlerAPI . withPersonIdLogTag personId $ do
  let ratingValue = request.rating
  unless (ratingValue `elem` [1 .. 5]) $ throwError InvalidRatingValue
  let rideId = request.rideId
  ride <- QRide.findById rideId >>= fromMaybeM (RideDoesNotExist rideId.getId)
  rideBooking <- QRB.findById ride.bookingId >>= fromMaybeM (RideBookingNotFound ride.bookingId.getId)
  let txnId = getId rideBooking.requestId
  bppRideBookingId <- rideBooking.bppBookingId & fromMaybeM (RideBookingFieldNotPresent "bppBookingId")
  bapURIs <- asks (.bapSelfURIs)
  bapIDs <- asks (.bapSelfIds)
  context <- buildTaxiContext Context.RATING txnId bapIDs.cabs bapURIs.cabs (Just rideBooking.providerId) (Just rideBooking.providerUrl)
  void $ ExternalAPI.feedback rideBooking.providerUrl (Common.BecknReq context (Rating.RatingMessage bppRideBookingId.getId ratingValue))
  return Success
