module Domain.Action.UI.Init where

import Beckn.Prelude
import qualified Beckn.Storage.Esqueleto as DB
import Beckn.Types.Id
import Beckn.Types.MapSearch (LatLong (..))
import qualified Domain.Types.BookingLocation as DLoc
import qualified Domain.Types.Quote as SQuote
import qualified Domain.Types.RideBooking as SRB
import Domain.Types.VehicleVariant (VehicleVariant)
import qualified Storage.Queries.BookingLocation as QBLoc
import qualified Storage.Queries.Quote as QQuote
import qualified Storage.Queries.RideBooking as QRideB
import qualified Storage.Queries.SearchReqLocation as QSRLoc
import qualified Storage.Queries.SearchRequest as QSReq
import Types.Error
import Utils.Common

newtype InitReq = InitReq
  { quoteId :: Id SQuote.Quote
  }
  deriving (Show, Generic, FromJSON, ToJSON, ToSchema)

data InitRes = InitRes
  { messageId :: Text,
    providerId :: Text,
    providerUrl :: BaseUrl,
    fromLoc :: LatLong,
    toLoc :: Maybe LatLong,
    vehicleVariant :: VehicleVariant,
    quoteDetails :: SQuote.QuoteDetails,
    startTime :: UTCTime
  }
  deriving (Show, Generic)

init :: EsqDBFlow m r => InitReq -> m InitRes
init req = do
  now <- getCurrentTime
  quote <- QQuote.findById req.quoteId >>= fromMaybeM (QuoteDoesNotExist req.quoteId.getId)
  searchRequest <- QSReq.findById quote.requestId >>= fromMaybeM (SearchRequestNotFound quote.requestId.getId)
  fromLocation <- QSRLoc.findById searchRequest.fromLocationId >>= fromMaybeM LocationNotFound
  mbToLocation <- searchRequest.toLocationId `forM` (QSRLoc.findById >=> fromMaybeM LocationNotFound)
  bFromLocation <- buildBLoc fromLocation now
  mbBToLocation <- (`buildBLoc` now) `mapM` mbToLocation
  rideBooking <- buildRideBooking searchRequest quote bFromLocation.id (mbBToLocation <&> (.id)) now
  DB.runTransaction $ do
    QBLoc.create bFromLocation
    whenJust mbBToLocation $ \loc -> QBLoc.create loc
    QRideB.create rideBooking
  return $
    InitRes
      { messageId = rideBooking.id.getId,
        providerId = quote.providerId,
        providerUrl = quote.providerUrl,
        fromLoc = LatLong {lat = fromLocation.lat, lon = fromLocation.lon},
        toLoc = mbToLocation <&> \toLocation -> LatLong {lat = toLocation.lat, lon = toLocation.lon},
        vehicleVariant = quote.vehicleVariant,
        quoteDetails = quote.quoteDetails,
        startTime = searchRequest.startTime
      }
  where
    buildBLoc searchReqLocation now = do
      locId <- generateGUID
      return
        DLoc.BookingLocation
          { id = locId,
            lat = searchReqLocation.lat,
            lon = searchReqLocation.lon,
            street = Nothing,
            door = Nothing,
            city = Nothing,
            state = Nothing,
            country = Nothing,
            building = Nothing,
            areaCode = Nothing,
            area = Nothing,
            createdAt = now,
            updatedAt = now
          }
    buildRideBooking searchRequest quote fromLocId toLocId now = do
      id <- generateGUID
      return $
        SRB.RideBooking
          { id = Id id,
            bppBookingId = Nothing,
            status = SRB.NEW,
            providerId = quote.providerId,
            providerUrl = quote.providerUrl,
            providerName = quote.providerName,
            providerMobileNumber = quote.providerMobileNumber,
            startTime = searchRequest.startTime,
            riderId = searchRequest.riderId,
            fromLocationId = fromLocId,
            toLocationId = toLocId,
            estimatedFare = quote.estimatedFare,
            discount = quote.discount,
            estimatedTotalFare = quote.estimatedTotalFare,
            distance = searchRequest.distance,
            vehicleVariant = quote.vehicleVariant,
            createdAt = now,
            updatedAt = now
          }
