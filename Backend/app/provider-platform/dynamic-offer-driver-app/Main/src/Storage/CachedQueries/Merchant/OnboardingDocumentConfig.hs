{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module Storage.CachedQueries.Merchant.OnboardingDocumentConfig
  ( findAllByMerchantOpCityId,
    findByMerchantOpCityIdAndDocumentType,
    clearCache,
    create,
    update,
  )
where

import Domain.Types.Merchant.MerchantOperatingCity
import Domain.Types.Merchant.OnboardingDocumentConfig as DTO
import Kernel.Prelude
import qualified Kernel.Storage.Hedis as Hedis
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.Queries.Merchant.OnboardingDocumentConfig as Queries

create :: MonadFlow m => OnboardingDocumentConfig -> m ()
create = Queries.create

findAllByMerchantOpCityId :: (CacheFlow m r, EsqDBFlow m r) => Id MerchantOperatingCity -> m [DTO.OnboardingDocumentConfig]
findAllByMerchantOpCityId id =
  Hedis.withCrossAppRedis (Hedis.safeGet $ makeMerchantOpCityIdKey id) >>= \case
    Just a -> return a
    Nothing -> cacheOnboardingDocumentConfigs id /=<< Queries.findAllByMerchantOpCityId id

findByMerchantOpCityIdAndDocumentType :: (CacheFlow m r, EsqDBFlow m r) => Id MerchantOperatingCity -> DocumentType -> m (Maybe DTO.OnboardingDocumentConfig)
findByMerchantOpCityIdAndDocumentType merchantOpCityId documentType = find (\config -> config.documentType == documentType) <$> findAllByMerchantOpCityId merchantOpCityId

cacheOnboardingDocumentConfigs :: (CacheFlow m r) => Id MerchantOperatingCity -> [DTO.OnboardingDocumentConfig] -> m ()
cacheOnboardingDocumentConfigs merchantOpCityId configs = do
  expTime <- fromIntegral <$> asks (.cacheConfig.configsExpTime)
  let key = makeMerchantOpCityIdKey merchantOpCityId
  Hedis.withCrossAppRedis $ Hedis.setExp key configs expTime

makeMerchantOpCityIdKey :: Id MerchantOperatingCity -> Text
makeMerchantOpCityIdKey merchantOpCityId = "driver-offer:CachedQueries:OnboardingDocumentConfig:MerchantOpCityId-" <> merchantOpCityId.getId

-- Call it after any update
clearCache :: Hedis.HedisFlow m r => Id MerchantOperatingCity -> m ()
clearCache = Hedis.withCrossAppRedis . Hedis.del . makeMerchantOpCityIdKey

update :: MonadFlow m => OnboardingDocumentConfig -> m ()
update = Queries.update
