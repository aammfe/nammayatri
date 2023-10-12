{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.Merchant.MerchantServiceUsageConfig
  {-# WARNING
    "This module contains direct calls to the table. \
  \ But most likely you need a version from CachedQueries with caching results feature."
    #-}
where

import Domain.Types.Merchant.MerchantOperatingCity
import Domain.Types.Merchant.MerchantServiceUsageConfig
import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Types.Common (MonadFlow, MonadTime (getCurrentTime))
import Kernel.Types.Id
import qualified Sequelize as Se
import qualified Storage.Beam.Merchant.MerchantServiceUsageConfig as BeamMSUC

findByMerchantOpCityId :: MonadFlow m => Id MerchantOperatingCity -> m (Maybe MerchantServiceUsageConfig)
findByMerchantOpCityId (Id merchantOperatingCityId) = findOneWithKV [Se.Is BeamMSUC.merchantOperatingCityId $ Se.Eq merchantOperatingCityId]

updateMerchantServiceUsageConfig :: MonadFlow m => MerchantServiceUsageConfig -> m ()
updateMerchantServiceUsageConfig MerchantServiceUsageConfig {..} = do
  now <- getCurrentTime
  updateOneWithKV
    [ Se.Set BeamMSUC.getDistances getDistances,
      Se.Set BeamMSUC.getEstimatedPickupDistances getEstimatedPickupDistances,
      Se.Set BeamMSUC.getRoutes getRoutes,
      Se.Set BeamMSUC.snapToRoad snapToRoad,
      Se.Set BeamMSUC.getPlaceName getPlaceName,
      Se.Set BeamMSUC.getPlaceDetails getPlaceDetails,
      Se.Set BeamMSUC.autoComplete autoComplete,
      Se.Set BeamMSUC.smsProvidersPriorityList smsProvidersPriorityList,
      Se.Set BeamMSUC.updatedAt now
    ]
    [Se.Is BeamMSUC.merchantOperatingCityId (Se.Eq $ getId merchantOperatingCityId)]

instance FromTType' BeamMSUC.MerchantServiceUsageConfig MerchantServiceUsageConfig where
  fromTType' BeamMSUC.MerchantServiceUsageConfigT {..} = do
    pure $
      Just
        MerchantServiceUsageConfig
          { merchantOperatingCityId = Id merchantOperatingCityId,
            initiateCall = initiateCall,
            getDistances = getDistances,
            getEstimatedPickupDistances = getEstimatedPickupDistances,
            getRoutes = getRoutes,
            getPickupRoutes = getPickupRoutes,
            getTripRoutes = getTripRoutes,
            snapToRoad = snapToRoad,
            getPlaceName = getPlaceName,
            getPlaceDetails = getPlaceDetails,
            autoComplete = autoComplete,
            getDistancesForCancelRide = getDistancesForCancelRide,
            smsProvidersPriorityList = smsProvidersPriorityList,
            whatsappProvidersPriorityList = whatsappProvidersPriorityList,
            verificationService = verificationService,
            faceVerificationService = faceVerificationService,
            aadhaarVerificationService = aadhaarVerificationService,
            issueTicketService = issueTicketService,
            getExophone = getExophone,
            updatedAt = updatedAt,
            createdAt = createdAt
          }

instance ToTType' BeamMSUC.MerchantServiceUsageConfig MerchantServiceUsageConfig where
  toTType' MerchantServiceUsageConfig {..} = do
    BeamMSUC.MerchantServiceUsageConfigT
      { BeamMSUC.merchantOperatingCityId = getId merchantOperatingCityId,
        BeamMSUC.initiateCall = initiateCall,
        BeamMSUC.getDistances = getDistances,
        BeamMSUC.getEstimatedPickupDistances = getEstimatedPickupDistances,
        BeamMSUC.getRoutes = getRoutes,
        BeamMSUC.getPickupRoutes = getPickupRoutes,
        BeamMSUC.getTripRoutes = getTripRoutes,
        BeamMSUC.snapToRoad = snapToRoad,
        BeamMSUC.getPlaceName = getPlaceName,
        BeamMSUC.getPlaceDetails = getPlaceDetails,
        BeamMSUC.autoComplete = autoComplete,
        BeamMSUC.getDistancesForCancelRide = getDistancesForCancelRide,
        BeamMSUC.smsProvidersPriorityList = smsProvidersPriorityList,
        BeamMSUC.whatsappProvidersPriorityList = whatsappProvidersPriorityList,
        BeamMSUC.verificationService = verificationService,
        BeamMSUC.faceVerificationService = faceVerificationService,
        BeamMSUC.aadhaarVerificationService = aadhaarVerificationService,
        BeamMSUC.issueTicketService = issueTicketService,
        BeamMSUC.getExophone = getExophone,
        BeamMSUC.updatedAt = updatedAt,
        BeamMSUC.createdAt = createdAt
      }
