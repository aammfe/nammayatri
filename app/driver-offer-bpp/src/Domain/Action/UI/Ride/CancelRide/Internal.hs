module Domain.Action.UI.Ride.CancelRide.Internal (cancelRideImpl) where

import qualified Beckn.Storage.Esqueleto as Esq
import Beckn.Storage.Hedis (HedisFlow)
import Beckn.Types.Id
import qualified Beckn.Types.SlidingWindowCounters as SW
import Beckn.Utils.Common
import qualified Domain.Types.Booking as SRB
import qualified Domain.Types.BookingCancellationReason as SBCR
import qualified Domain.Types.Ride as SRide
import EulerHS.Prelude hiding (id)
import qualified SharedLogic.CallBAP as BP
import qualified SharedLogic.DriverLocation as SDrLoc
import qualified SharedLogic.DriverPool as DP
import qualified SharedLogic.Ride as SRide
import Storage.CachedQueries.CacheConfig
import qualified Storage.CachedQueries.Merchant as CQM
import qualified Storage.Queries.Booking as QRB
import qualified Storage.Queries.BookingCancellationReason as QBCR
import qualified Storage.Queries.DriverInformation as DriverInformation
import qualified Storage.Queries.DriverStats as QDriverStats
import qualified Storage.Queries.Person as QPerson
import qualified Storage.Queries.Ride as QRide
import Tools.Error
import Tools.Metrics
import qualified Tools.Notifications as Notify

cancelRideImpl ::
  ( HasCacheConfig r,
    EsqDBFlow m r,
    EncFlow m r,
    HasField "windowOptions" r SW.SlidingWindowOptions,
    HedisFlow m r,
    HasHttpClientOptions r c,
    HasFlowEnv m r '["nwAddress" ::: BaseUrl],
    HasHttpClientOptions r c,
    CoreMetrics m
  ) =>
  Id SRide.Ride ->
  SBCR.BookingCancellationReason ->
  m ()
cancelRideImpl rideId bookingCReason = do
  ride <- QRide.findById rideId >>= fromMaybeM (RideDoesNotExist rideId.getId)
  booking <- QRB.findById ride.bookingId >>= fromMaybeM (BookingNotFound ride.bookingId.getId)
  let transporterId = booking.providerId
  transporter <-
    CQM.findById transporterId
      >>= fromMaybeM (MerchantNotFound transporterId.getId)
  cancelRideTransaction booking.id ride bookingCReason
  logTagInfo ("rideId-" <> getId rideId) ("Cancellation reason " <> show bookingCReason.source)
  fork "cancelRide - Notify BAP" $ do
    BP.sendBookingCancelledUpdateToBAP booking transporter bookingCReason.source
  fork "cancelRide - Notify driver" $ do
    driver <- QPerson.findById ride.driverId >>= fromMaybeM (PersonNotFound ride.driverId.getId)
    when (bookingCReason.source == SBCR.ByDriver) $
      DP.incrementCancellationCount driver.id
    Notify.notifyOnCancel transporterId booking driver.id driver.deviceToken bookingCReason.source

cancelRideTransaction ::
  ( EsqDBFlow m r,
    CacheFlow m r
  ) =>
  Id SRB.Booking ->
  SRide.Ride ->
  SBCR.BookingCancellationReason ->
  m ()
cancelRideTransaction bookingId ride bookingCReason = do
  Esq.runTransaction $ do
    updateDriverInfo ride.driverId
    QRide.updateStatus ride.id SRide.CANCELLED
    QRB.updateStatus bookingId SRB.CANCELLED
    QBCR.create bookingCReason
  SRide.clearCache $ cast ride.driverId
  SDrLoc.clearDriverInfoCache $ cast ride.driverId
  where
    updateDriverInfo personId = do
      let driverId = cast personId
      DriverInformation.updateOnRide driverId False
      when (bookingCReason.source == SBCR.ByDriver) $ QDriverStats.updateIdleTime driverId
