{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.Merchant.MerchantMessage
  {-# WARNING
    "This module contains direct calls to the table. \
  \ But most likely you need a version from CachedQueries with caching results feature."
    #-}
where

import Data.Aeson (fromJSON)
import qualified Data.Aeson as A
import Data.Default.Class (Default (..))
import Domain.Types.Merchant as DOrg
import Domain.Types.Merchant.MerchantMessage
import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Types.Common
import Kernel.Types.Id
import qualified Sequelize as Se
import qualified Storage.Beam.Merchant.MerchantMessage as BeamMM

findByMerchantIdAndMessageKey :: MonadFlow m => Id Merchant -> MessageKey -> m (Maybe MerchantMessage)
findByMerchantIdAndMessageKey (Id merchantId) messageKey = findOneWithKV [Se.And [Se.Is BeamMM.merchantId $ Se.Eq merchantId, Se.Is BeamMM.messageKey $ Se.Eq messageKey]]

instance FromTType' BeamMM.MerchantMessage MerchantMessage where
  fromTType' BeamMM.MerchantMessageT {..} = do
    pure $
      Just
        MerchantMessage
          { merchantId = Id merchantId,
            messageKey = messageKey,
            message = message,
            templateId = fromMaybe "" templateId,
            jsonData = fromMaybe def (valueToJsonData =<< jsonData),
            containsUrlButton = containsUrlButton,
            updatedAt = updatedAt,
            createdAt = createdAt
          }
    where
      valueToJsonData :: A.Value -> Maybe MerchantMessageDefaultDataJSON
      valueToJsonData value = case fromJSON value of
        A.Error _ -> Nothing
        A.Success a -> Just a

instance ToTType' BeamMM.MerchantMessage MerchantMessage where
  toTType' MerchantMessage {..} = do
    BeamMM.MerchantMessageT
      { BeamMM.merchantId = getId merchantId,
        BeamMM.messageKey = messageKey,
        BeamMM.message = message,
        BeamMM.templateId = Just templateId,
        BeamMM.jsonData = Just $ toJSON jsonData,
        BeamMM.containsUrlButton = containsUrlButton,
        BeamMM.updatedAt = updatedAt,
        BeamMM.createdAt = createdAt
      }
