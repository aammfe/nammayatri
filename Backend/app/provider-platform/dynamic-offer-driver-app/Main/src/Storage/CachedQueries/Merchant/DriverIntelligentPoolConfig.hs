{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-deprecations #-}

module Storage.CachedQueries.Merchant.DriverIntelligentPoolConfig
  ( clearCache,
    findByMerchantOpCityId,
    update,
  )
where

import Data.Coerce (coerce)
import Domain.Types.Common
import Domain.Types.Merchant.DriverIntelligentPoolConfig
import Domain.Types.Merchant.MerchantOperatingCity
import Kernel.Prelude
import qualified Kernel.Storage.Hedis as Hedis
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.Queries.Merchant.DriverIntelligentPoolConfig as Queries

findByMerchantOpCityId :: (CacheFlow m r, EsqDBFlow m r) => Id MerchantOperatingCity -> m (Maybe DriverIntelligentPoolConfig)
findByMerchantOpCityId id =
  Hedis.withCrossAppRedis (Hedis.safeGet $ makeMerchantOpCityIdKey id) >>= \case
    Just a -> return . Just $ coerce @(DriverIntelligentPoolConfigD 'Unsafe) @DriverIntelligentPoolConfig a
    Nothing -> flip whenJust cacheDriverIntelligentPoolConfig /=<< Queries.findByMerchantOpCityId id

cacheDriverIntelligentPoolConfig :: CacheFlow m r => DriverIntelligentPoolConfig -> m ()
cacheDriverIntelligentPoolConfig cfg = do
  expTime <- fromIntegral <$> asks (.cacheConfig.configsExpTime)
  let merchantIdKey = makeMerchantOpCityIdKey cfg.merchantOperatingCityId
  Hedis.withCrossAppRedis $ Hedis.setExp merchantIdKey (coerce @DriverIntelligentPoolConfig @(DriverIntelligentPoolConfigD 'Unsafe) cfg) expTime

makeMerchantOpCityIdKey :: Id MerchantOperatingCity -> Text
makeMerchantOpCityIdKey id = "driver-offer:CachedQueries:DriverIntelligentPoolConfig:MerchantOperatingCityId-" <> id.getId

-- Call it after any update
clearCache :: Hedis.HedisFlow m r => Id MerchantOperatingCity -> m ()
clearCache = Hedis.withCrossAppRedis . Hedis.del . makeMerchantOpCityIdKey

update :: MonadFlow m => DriverIntelligentPoolConfig -> m ()
update = Queries.update
