{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Lib.Payment.Storage.Queries.PaymentOrder where

import Kernel.Beam.Functions
import Kernel.External.Encryption
import qualified Kernel.External.Payment.Interface as Payment
import Kernel.Prelude
import Kernel.Storage.Esqueleto hiding (findById)
import qualified Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Kernel.Utils.Common (getCurrentTime)
import qualified Lib.Payment.Domain.Types.PaymentOrder as DOrder
import qualified Lib.Payment.Storage.Beam.PaymentOrder as BeamPO
import Lib.Payment.Storage.Tabular.PaymentOrder hiding (parsePaymentLinks)

findById :: Transactionable m => Id DOrder.PaymentOrder -> m (Maybe DOrder.PaymentOrder)
findById = Esq.findById

findByShortId :: Transactionable m => ShortId DOrder.PaymentOrder -> m (Maybe DOrder.PaymentOrder)
findByShortId shortId =
  findOne $ do
    order <- from $ table @PaymentOrderT
    where_ $ order ^. PaymentOrderShortId ==. val (getShortId shortId)
    return order

findLatestByPersonId :: Transactionable m => Text -> m (Maybe DOrder.PaymentOrder)
findLatestByPersonId personId =
  findOne $ do
    order <- from $ table @PaymentOrderT
    where_ $ order ^. PaymentOrderPersonId ==. val personId
    orderBy [desc $ order ^. PaymentOrderCreatedAt]
    limit 1
    return order

create :: DOrder.PaymentOrder -> SqlDB ()
create = Esq.create

updateStatusAndError :: DOrder.PaymentOrder -> Maybe Text -> Maybe Text -> SqlDB ()
updateStatusAndError order bankErrorMessage bankErrorCode = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ PaymentOrderStatus =. val order.status,
        PaymentOrderBankErrorMessage =. val bankErrorMessage,
        PaymentOrderBankErrorCode =. val bankErrorCode,
        PaymentOrderUpdatedAt =. val now
      ]
    where_ $ tbl ^. PaymentOrderId ==. val order.id.getId

updateStatusToExpired :: Id DOrder.PaymentOrder -> SqlDB ()
updateStatusToExpired orderId = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ PaymentOrderStatus =. val Payment.CLIENT_AUTH_TOKEN_EXPIRED,
        PaymentOrderUpdatedAt =. val now
      ]
    where_ $ tbl ^. PaymentOrderId ==. val orderId.getId

updateStatus :: Id DOrder.PaymentOrder -> Text -> Payment.TransactionStatus -> SqlDB ()
updateStatus orderId paymentServiceOrderId status = do
  now <- getCurrentTime
  mOrder <- findById orderId
  let newStatus = maybe status (\order -> if order.status == Payment.CHARGED then order.status else status) mOrder -- don't change if status is already charged
  Esq.update $ \tbl -> do
    set
      tbl
      [ PaymentOrderStatus =. val newStatus,
        PaymentOrderPaymentServiceOrderId =. val paymentServiceOrderId,
        PaymentOrderUpdatedAt =. val now
      ]
    where_ $ tbl ^. PaymentOrderId ==. val orderId.getId

instance FromTType' BeamPO.PaymentOrder DOrder.PaymentOrder where
  fromTType' orderT@BeamPO.PaymentOrderT {..} = do
    paymentLinks <- parsePaymentLinks orderT
    pure $
      Just
        DOrder.PaymentOrder
          { id = Id id,
            shortId = ShortId shortId,
            personId = Id personId,
            merchantId = Id merchantId,
            clientAuthToken = case (clientAuthTokenEncrypted, clientAuthTokenHash) of
              (Just encryptedToken, Just hash) -> Just $ EncryptedHashed (Encrypted encryptedToken) hash
              (_, _) -> Nothing,
            ..
          }
    where
      parsePaymentLinks :: MonadThrow m => BeamPO.PaymentOrder -> m Payment.PaymentLinks
      parsePaymentLinks paymentOrder = do
        web <- parseBaseUrl `mapM` paymentOrder.webPaymentLink
        iframe <- parseBaseUrl `mapM` paymentOrder.iframePaymentLink
        mobile <- parseBaseUrl `mapM` paymentOrder.mobilePaymentLink
        pure Payment.PaymentLinks {..}

instance ToTType' BeamPO.PaymentOrder DOrder.PaymentOrder where
  toTType' DOrder.PaymentOrder {..} =
    BeamPO.PaymentOrderT
      { id = getId id,
        shortId = getShortId shortId,
        personId = personId.getId,
        merchantId = merchantId.getId,
        webPaymentLink = showBaseUrl <$> paymentLinks.web,
        iframePaymentLink = showBaseUrl <$> paymentLinks.iframe,
        mobilePaymentLink = showBaseUrl <$> paymentLinks.mobile,
        clientAuthTokenEncrypted = clientAuthToken <&> unEncrypted . (.encrypted),
        clientAuthTokenHash = clientAuthToken <&> (.hash),
        ..
      }
