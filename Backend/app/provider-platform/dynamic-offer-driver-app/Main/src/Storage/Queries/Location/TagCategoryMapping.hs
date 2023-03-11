{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Storage.Queries.Location.TagCategoryMapping where

import qualified Domain.Types.Location.TagCategoryMapping as D
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Storage.Tabular.Location.TagCategoryMapping

create :: D.TagCategoryMapping -> SqlDB ()
create = Esq.create

findById :: Transactionable m => Id D.TagCategoryMapping -> m (Maybe D.TagCategoryMapping)
findById = Esq.findById

findByTag :: Transactionable m => Text -> m (Maybe D.TagCategoryMapping)
findByTag tag = findOne $ do
  tagCatMapping <- from $ table @TagCategoryMappingT
  where_ $ tagCatMapping ^. TagCategoryMappingTag ==. val tag
  pure tagCatMapping
