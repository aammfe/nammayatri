{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}

{-# HLINT ignore "Use lambda-case" #-}
module SharedLogic.DirectionsCache
  ( Maps.GetRoutesReq,
    Maps.GetRoutesResp,
    getRoutes,
  )
where

import Data.Geohash as DG
import Data.List.NonEmpty as NE
import Data.Text (pack)
import Data.Time as DT
  ( LocalTime (localTimeOfDay),
    TimeZone (TimeZone),
    utcToLocalTime,
  )
import Domain.Types.Maps.DirectionsCache as DC
import Domain.Types.Merchant (Slot)
import qualified Domain.Types.Merchant as Merchant
import qualified Domain.Types.Merchant.MerchantOperatingCity as DMOC
import Kernel.Prelude
import Kernel.Storage.Esqueleto (EsqDBReplicaFlow)
import qualified Kernel.Storage.Esqueleto as Esq
import Kernel.Storage.Esqueleto.Config (EsqDBEnv)
import Kernel.Types.Error (MerchantError (MerchantNotFound))
import Kernel.Types.Id
import Kernel.Utils.Common
import Storage.CachedQueries.CacheConfig (CacheFlow)
import Storage.CachedQueries.Maps.DirectionsCache as DCC
import qualified Storage.CachedQueries.Maps.DirectionsCache as DQ
import Storage.CachedQueries.Merchant as M
import qualified Storage.CachedQueries.Merchant as QMerchant
import Tools.Error (GenericError (..))
import qualified Tools.Maps as Maps
import Tools.Metrics (CoreMetrics)

getRoutes :: (EncFlow m r, CacheFlow m r, EsqDBFlow m r, CoreMetrics m, HasField "esqDBReplicaEnv" r EsqDBEnv) => Id Merchant.Merchant -> Id DMOC.MerchantOperatingCity -> Maps.GetRoutesReq -> m Maps.GetRoutesResp
getRoutes merchantId merchantOperatingCityId req = do
  merchant <- QMerchant.findById merchantId >>= fromMaybeM (MerchantNotFound merchantId.getId)
  let origin = NE.head req.waypoints
  let dest = NE.last req.waypoints
  originGeoHash <- fmap pack $ fromMaybeM (InternalError "Failed to compute Origin GeoHash") $ DG.encode merchant.geoHashPrecisionValue (origin.lat, origin.lon) -- This default case will never happen as we are getting lat long from Google and hence a valid geo hash will always be possible for a valid lat long.
  destGeoHash <- fmap pack $ fromMaybeM (InternalError "Failed to compute Destination GeoHash") $ DG.encode merchant.geoHashPrecisionValue (dest.lat, dest.lon) -- This default case will never happen as we are getting lat long from Google and hence a valid geo hash will always be possible for a valid lat long.
  timeSlot <- getSlot merchantId
  case timeSlot of
    Just tmeSlt ->
      do
        cachedResp <- DQ.findRoute originGeoHash destGeoHash tmeSlt
        case cachedResp of
          Just resp -> return [resp.response]
          Nothing -> callDirectionsApi merchantOperatingCityId req originGeoHash destGeoHash tmeSlt
    Nothing ->
      Maps.getRoutes merchantOperatingCityId req

callDirectionsApi :: (EncFlow m r, CacheFlow m r, EsqDBFlow m r, CoreMetrics m) => Id DMOC.MerchantOperatingCity -> Maps.GetRoutesReq -> Text -> Text -> Int -> m Maps.GetRoutesResp
callDirectionsApi merchantOperatingCityId req originGeoHash destGeoHash timeSlot = do
  resp <- Maps.getRoutes merchantOperatingCityId req
  if null resp
    then throwError $ InternalError "Null response from Directions API" -- This case will never occure unless Google's Direction API Fails.
    else do
      let (cachedResp : _) = resp
      directionsCache <- convertToDirCache originGeoHash destGeoHash timeSlot cachedResp
      Esq.runTransaction $ DQ.create directionsCache
      DCC.cacheDirectionsResponse directionsCache
      return resp

getSlot :: (MonadIO m, CacheFlow m r, EsqDBFlow m r, EsqDBReplicaFlow m r, EncFlow m r) => Id Merchant.Merchant -> m (Maybe Int)
getSlot merchantId = do
  utcTime <- getLocalCurrentTime 19800
  let istTime = utcToLocalTime (TimeZone 0 False "") utcTime
  let timeOfDay = localTimeOfDay istTime
  slots <- fmap (.dirCacheSlot) $ M.findById merchantId >>= fromMaybeM (InternalError "Error in fetching configs from Database")
  return $ matchSlot timeOfDay slots

matchSlot :: TimeOfDay -> [Slot] -> Maybe Int
matchSlot _ [] = Nothing
matchSlot currTime (slot : slots)
  | slot.startTime <= currTime && currTime < slot.endTime = Just $ slot.slot
  | otherwise = matchSlot currTime slots

convertToDirCache :: (MonadGuid m, MonadTime m) => Text -> Text -> Int -> Maps.RouteInfo -> m DirectionsCache
convertToDirCache originGeoHash destGeoHash timeSlot cachedResp = do
  id <- generateGUID
  localTime <- getLocalCurrentTime 19800
  let res =
        DC.DirectionsCache
          { id,
            originHash = originGeoHash,
            destHash = destGeoHash,
            slot = timeSlot,
            response = cachedResp,
            createdAt = localTime
          }
  return res
