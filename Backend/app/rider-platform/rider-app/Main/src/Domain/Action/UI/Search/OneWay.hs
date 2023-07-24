{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE OverloadedLists #-}

module Domain.Action.UI.Search.OneWay
  ( OneWaySearchReq (..),
    OneWaySearchRes (..),
    DSearch.SearchReqLocation (..),
    oneWaySearch,
  )
where

import Control.Monad
import Domain.Action.UI.HotSpot
import qualified Domain.Action.UI.Search.Common as DSearch
import Domain.Types.HotSpot
import Domain.Types.HotSpotConfig
import Domain.Types.Merchant
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Person as Person
import qualified Domain.Types.Person.PersonFlowStatus as DPFS
import Domain.Types.SavedReqLocation
import qualified Domain.Types.SearchRequest as DSearchReq
import Kernel.External.Maps
import Kernel.Prelude
import Kernel.Serviceability
import qualified Kernel.Storage.Esqueleto as DB
import Kernel.Storage.Esqueleto.Config (EsqDBReplicaFlow)
import Kernel.Storage.Hedis (HedisFlow)
import Kernel.Types.Common hiding (id)
import Kernel.Types.Id
import Kernel.Types.Version (Version)
import Kernel.Utils.Common
import qualified Lib.Queries.SpecialLocation as QSpecialLocation
import Lib.SessionizerMetrics.Types.Event
import SharedLogic.DirectionsCache as SDC
import qualified SharedLogic.MerchantConfig as SMC
import Storage.CachedQueries.CacheConfig
import qualified Storage.CachedQueries.HotSpotConfig as QHotSpotConfig
import qualified Storage.CachedQueries.Merchant as QMerc
import qualified Storage.CachedQueries.MerchantConfig as QMC
import qualified Storage.CachedQueries.Person.PersonFlowStatus as QPFS
import qualified Storage.CachedQueries.SavedLocation as CSavedLocation
import Storage.Queries.Geometry
import qualified Storage.Queries.Person as QP
import qualified Storage.Queries.SearchRequest as QSearchRequest
import Tools.Error
import Tools.Event
import qualified Tools.Maps as Maps
import Tools.Metrics
import qualified Tools.Metrics as Metrics

data OneWaySearchReq = OneWaySearchReq
  { origin :: DSearch.SearchReqLocation,
    destination :: DSearch.SearchReqLocation,
    isSourceManuallyMoved :: Maybe Bool,
    isSpecialLocation :: Maybe Bool
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)

data OneWaySearchRes = OneWaySearchRes
  { origin :: DSearch.SearchReqLocation,
    destination :: DSearch.SearchReqLocation,
    searchId :: Id DSearchReq.SearchRequest,
    now :: UTCTime,
    gatewayUrl :: BaseUrl,
    searchRequestExpiry :: UTCTime,
    merchant :: DM.Merchant,
    customerLanguage :: Maybe Maps.Language,
    device :: Maybe Text,
    shortestRouteInfo :: Maybe Maps.RouteInfo
  }

hotSpotUpdate ::
  ( HasCacheConfig r,
    CoreMetrics m,
    HedisFlow m r,
    EsqDBFlow m r
  ) =>
  Id Merchant ->
  Maybe SavedReqLocation ->
  OneWaySearchReq ->
  m ()
hotSpotUpdate merchantId mbFavourite req = case mbFavourite of
  Just SavedReqLocation {..} ->
    frequencyUpdator merchantId req.origin.gps (bool NonManualSaved ManualSaved (isMoved == Just True))
  Nothing ->
    frequencyUpdator merchantId req.origin.gps (bool NonManualPickup ManualPickup (req.isSourceManuallyMoved == Just True))

updateForSpecialLocation ::
  ( MonadFlow m,
    EsqDBFlow m r,
    HasCacheConfig r,
    EncFlow m r,
    HedisFlow m r,
    CoreMetrics m,
    EventStreamFlow m r
  ) =>
  Id Merchant ->
  OneWaySearchReq ->
  m ()
updateForSpecialLocation merchantId req = do
  case req.isSpecialLocation of
    Just isSpecialLocation -> do
      when isSpecialLocation $ frequencyUpdator merchantId req.origin.gps SpecialLocation
    Nothing -> do
      specialLocationBody <- QSpecialLocation.findSpecialLocationByLatLong req.origin.gps
      case specialLocationBody of
        Just _ -> frequencyUpdator merchantId req.origin.gps SpecialLocation
        Nothing -> return ()

oneWaySearch ::
  ( HasCacheConfig r,
    EncFlow m r,
    EsqDBReplicaFlow m r,
    HasFlowEnv m r '["searchRequestExpiry" ::: Maybe Seconds],
    HedisFlow m r,
    EsqDBFlow m r,
    HedisFlow m r,
    CoreMetrics m,
    HasBAPMetrics m r,
    EventStreamFlow m r
  ) =>
  Id Person.Person ->
  OneWaySearchReq ->
  Maybe Version ->
  Maybe Version ->
  Maybe Text ->
  m OneWaySearchRes
oneWaySearch personId req bundleVersion clientVersion device = do
  person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  merchant <- QMerc.findById person.merchantId >>= fromMaybeM (MerchantNotFound person.merchantId.getId)
  mbFavourite <- CSavedLocation.findByLatLonAndRiderId personId req.origin.gps
  HotSpotConfig {..} <- QHotSpotConfig.findConfigByMerchantId merchant.id >>= fromMaybeM (InternalError "config not found for merchant")

  when shouldTakeHotSpot do
    _ <- hotSpotUpdate person.merchantId mbFavourite req
    updateForSpecialLocation person.merchantId req
  validateServiceability merchant.geofencingConfig

  let sourceLatlong = req.origin.gps
  let destinationLatLong = req.destination.gps
  let request =
        Maps.GetRoutesReq
          { waypoints = [sourceLatlong, destinationLatLong],
            calcPoints = True,
            mode = Just Maps.CAR
          }
  routeResponse <- SDC.getRoutes person.merchantId request
  let shortestRouteInfo = getRouteInfoWithShortestDuration routeResponse
  let longestRouteDistance = (.distance) =<< getLongestRouteDistance routeResponse
  let shortestRouteDistance = (.distance) =<< shortestRouteInfo
  let shortestRouteDuration = (.duration) =<< shortestRouteInfo

  fromLocation <- DSearch.buildSearchReqLoc req.origin
  toLocation <- DSearch.buildSearchReqLoc req.destination
  now <- getCurrentTime
  searchRequest <-
    DSearch.buildSearchRequest
      person
      fromLocation
      (Just toLocation)
      (metersToHighPrecMeters <$> longestRouteDistance)
      (metersToHighPrecMeters <$> shortestRouteDistance)
      now
      bundleVersion
      clientVersion
      device
      shortestRouteDuration
  Metrics.incrementSearchRequestCount merchant.name
  let txnId = getId (searchRequest.id)
  Metrics.startSearchMetrics merchant.name txnId
  triggerSearchEvent SearchEventData {searchRequest = searchRequest}
  DB.runTransaction $ do
    QSearchRequest.create searchRequest
    QPFS.updateStatus person.id DPFS.SEARCHING {requestId = searchRequest.id, validTill = searchRequest.validTill}
  QPFS.clearCache person.id
  let dSearchRes =
        OneWaySearchRes
          { origin = req.origin,
            destination = req.destination,
            searchId = searchRequest.id,
            now = now,
            gatewayUrl = merchant.gatewayUrl,
            searchRequestExpiry = searchRequest.validTill,
            customerLanguage = searchRequest.language,
            device,
            shortestRouteInfo,
            ..
          }
  fork "updating search counters" $ do
    merchantConfigs <- QMC.findAllByMerchantId person.merchantId
    SMC.updateSearchFraudCounters personId merchantConfigs
    mFraudDetected <- SMC.anyFraudDetected personId person.merchantId merchantConfigs
    whenJust mFraudDetected $ \mc -> SMC.blockCustomer personId (Just mc.id)
  return dSearchRes
  where
    validateServiceability geoConfig =
      unlessM (rideServiceable geoConfig someGeometriesContain req.origin.gps (Just req.destination.gps)) $
        throwError RideNotServiceable

getLongestRouteDistance :: [Maps.RouteInfo] -> Maybe Maps.RouteInfo
getLongestRouteDistance [] = Nothing
getLongestRouteDistance (routeInfo : routeInfoArray) =
  if null routeInfoArray
    then Just routeInfo
    else do
      restRouteresult <- getLongestRouteDistance routeInfoArray
      Just $ comparator' routeInfo restRouteresult
  where
    comparator' route1 route2 =
      if route1.distance > route2.distance
        then route1
        else route2

getRouteInfoWithShortestDuration :: [Maps.RouteInfo] -> Maybe Maps.RouteInfo
getRouteInfoWithShortestDuration (routeInfo : routeInfoArray) =
  if null routeInfoArray
    then Just routeInfo
    else do
      restRouteresult <- getRouteInfoWithShortestDuration routeInfoArray
      Just $ comparator routeInfo restRouteresult
getRouteInfoWithShortestDuration [] = Nothing

comparator :: Maps.RouteInfo -> Maps.RouteInfo -> Maps.RouteInfo
comparator route1 route2 =
  if route1.duration < route2.duration
    then route1
    else route2
