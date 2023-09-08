{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Tools.Maps
  ( module Reexport,
    autoComplete,
    getDistance,
    getDistances,
    getPlaceDetails,
    getPlaceName,
    getRoutes,
    snapToRoad,
    getPickupRoutes,
    getTripRoutes,
    getDistanceForCancelRide,
  )
where

import Domain.Types.Merchant.MerchantOperatingCity (MerchantOperatingCity)
import qualified Domain.Types.Merchant.MerchantServiceConfig as DMSC
import Domain.Types.Merchant.MerchantServiceUsageConfig (MerchantServiceUsageConfig)
import Kernel.External.Maps as Reexport hiding
  ( autoComplete,
    getDistance,
    getDistances,
    getPlaceDetails,
    getPlaceName,
    getRoutes,
    snapToRoad,
  )
import qualified Kernel.External.Maps as Maps
import Kernel.External.Types (ServiceFlow)
import Kernel.Prelude
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant.MerchantServiceConfig as QMSC
import qualified Storage.CachedQueries.Merchant.MerchantServiceUsageConfig as QMSUC
import Tools.Error

getDistance ::
  ( ServiceFlow m r,
    HasCoordinates a,
    HasCoordinates b
  ) =>
  Id MerchantOperatingCity ->
  GetDistanceReq a b ->
  m (GetDistanceResp a b)
getDistance = runWithServiceConfig Maps.getDistance (.getDistances)

getDistanceForCancelRide ::
  ( ServiceFlow m r,
    HasCoordinates a,
    HasCoordinates b
  ) =>
  Id MerchantOperatingCity ->
  GetDistanceReq a b ->
  m (GetDistanceResp a b)
getDistanceForCancelRide = runWithServiceConfig Maps.getDistance (.getDistancesForCancelRide)

getDistances ::
  ( ServiceFlow m r,
    HasCoordinates a,
    HasCoordinates b
  ) =>
  Id MerchantOperatingCity ->
  GetDistancesReq a b ->
  m (GetDistancesResp a b)
getDistances = runWithServiceConfig Maps.getDistances (.getDistances)

getRoutes :: ServiceFlow m r => Id MerchantOperatingCity -> GetRoutesReq -> m GetRoutesResp
getRoutes = runWithServiceConfig Maps.getRoutes (.getRoutes)

getPickupRoutes :: ServiceFlow m r => Id MerchantOperatingCity -> GetRoutesReq -> m GetRoutesResp
getPickupRoutes = runWithServiceConfig Maps.getRoutes (.getPickupRoutes)

getTripRoutes :: ServiceFlow m r => Id MerchantOperatingCity -> GetRoutesReq -> m GetRoutesResp
getTripRoutes = runWithServiceConfig Maps.getRoutes (.getTripRoutes)

snapToRoad ::
  ( ServiceFlow m r,
    HasFlowEnv m r '["snapToRoadSnippetThreshold" ::: HighPrecMeters]
  ) =>
  Id MerchantOperatingCity ->
  SnapToRoadReq ->
  m SnapToRoadResp
snapToRoad = runWithServiceConfig Maps.snapToRoad (.snapToRoad)

autoComplete :: ServiceFlow m r => Id MerchantOperatingCity -> AutoCompleteReq -> m AutoCompleteResp
autoComplete = runWithServiceConfig Maps.autoComplete (.autoComplete)

getPlaceName :: ServiceFlow m r => Id MerchantOperatingCity -> GetPlaceNameReq -> m GetPlaceNameResp
getPlaceName = runWithServiceConfig Maps.getPlaceName (.getPlaceName)

getPlaceDetails :: ServiceFlow m r => Id MerchantOperatingCity -> GetPlaceDetailsReq -> m GetPlaceDetailsResp
getPlaceDetails = runWithServiceConfig Maps.getPlaceDetails (.getPlaceDetails)

runWithServiceConfig ::
  ServiceFlow m r =>
  (MapsServiceConfig -> req -> m resp) ->
  (MerchantServiceUsageConfig -> MapsService) ->
  Id MerchantOperatingCity ->
  req ->
  m resp
runWithServiceConfig func getCfg merchantOperatingCityId req = do
  merchantConfig <- QMSUC.findByMerchantOperatingCityId merchantOperatingCityId >>= fromMaybeM (MerchantServiceUsageConfigNotFound merchantOperatingCityId.getId)
  merchantMapsServiceConfig <-
    QMSC.findByMerchantOperatingCityIdAndService merchantOperatingCityId (DMSC.MapsService $ getCfg merchantConfig)
      >>= fromMaybeM (MerchantServiceConfigNotFound merchantOperatingCityId.getId "Maps" (show $ getCfg merchantConfig))
  case merchantMapsServiceConfig.serviceConfig of
    DMSC.MapsServiceConfig msc -> func msc req
    _ -> throwError $ InternalError "Unknown Service Config"
