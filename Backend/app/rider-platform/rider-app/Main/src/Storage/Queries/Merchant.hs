{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Storage.Queries.Merchant
  {-# WARNING
    "This module contains direct calls to the table. \
  \ But most likely you need a version from CachedQueries with caching results feature."
    #-}
where

import Domain.Types.Merchant as DOrg
import Kernel.Prelude
import Kernel.Storage.Esqueleto hiding (findById)
import qualified Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Kernel.Types.Registry (Subscriber)
import Kernel.Utils.Common
import Storage.Tabular.Merchant

findById :: Transactionable m => Id Merchant -> m (Maybe Merchant)
findById = Esq.findById

findByShortId :: Transactionable m => ShortId Merchant -> m (Maybe Merchant)
findByShortId shortId_ = do
  findOne $ do
    merchant <- from $ table @MerchantT
    where_ $ merchant ^. MerchantShortId ==. val (getShortId shortId_)
    return merchant

findBySubscriberId :: Transactionable m => ShortId Subscriber -> m (Maybe Merchant)
findBySubscriberId subscriberId = do
  findOne $ do
    merchant <- from $ table @MerchantT
    where_ $ merchant ^. MerchantSubscriberId ==. val (getShortId subscriberId)
    return merchant

findAll :: Transactionable m => m [Merchant]
findAll =
  Esq.findAll $ do from $ table @MerchantT

update :: Merchant -> SqlDB ()
update merchant = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ MerchantName =. val merchant.name,
        MerchantGatewayUrl =. val (showBaseUrl merchant.gatewayUrl),
        MerchantRegistryUrl =. val (showBaseUrl merchant.registryUrl),
        MerchantUpdatedAt =. val now
      ]
    where_ $ tbl ^. MerchantTId ==. val (toKey merchant.id)
