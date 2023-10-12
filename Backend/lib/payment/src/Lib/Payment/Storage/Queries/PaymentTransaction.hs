{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Lib.Payment.Storage.Queries.PaymentTransaction where

import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Kernel.Utils.Common (getCurrentTime)
import Lib.Payment.Domain.Types.PaymentOrder (PaymentOrder)
import Lib.Payment.Domain.Types.PaymentTransaction as DTransaction
import qualified Lib.Payment.Storage.Beam.PaymentTransaction as BeamPT
import Lib.Payment.Storage.Tabular.PaymentTransaction

create :: PaymentTransaction -> SqlDB ()
create = Esq.create

updateMultiple :: PaymentTransaction -> SqlDB ()
updateMultiple transaction = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ PaymentTransactionStatusId =. val transaction.statusId,
        PaymentTransactionStatus =. val transaction.status,
        PaymentTransactionPaymentMethodType =. val transaction.paymentMethodType,
        PaymentTransactionPaymentMethod =. val transaction.paymentMethod,
        PaymentTransactionRespMessage =. val transaction.respMessage,
        PaymentTransactionRespCode =. val transaction.respCode,
        PaymentTransactionGatewayReferenceId =. val transaction.gatewayReferenceId,
        PaymentTransactionAmount =. val transaction.amount,
        PaymentTransactionCurrency =. val transaction.currency,
        PaymentTransactionJuspayResponse =. val transaction.juspayResponse,
        PaymentTransactionMandateStatus =. val transaction.mandateStatus,
        PaymentTransactionMandateStartDate =. val transaction.mandateStartDate,
        PaymentTransactionMandateEndDate =. val transaction.mandateEndDate,
        PaymentTransactionMandateId =. val transaction.mandateId,
        PaymentTransactionMandateFrequency =. val transaction.mandateFrequency,
        PaymentTransactionMandateMaxAmount =. val transaction.mandateMaxAmount,
        PaymentTransactionUpdatedAt =. val now
      ]
    where_ $ tbl ^. PaymentTransactionId ==. val transaction.id.getId

findByTxnUUID :: Transactionable m => Text -> m (Maybe PaymentTransaction)
findByTxnUUID txnUUID =
  findOne $ do
    transaction <- from $ table @PaymentTransactionT
    where_ $ transaction ^. PaymentTransactionTxnUUID ==. val (Just txnUUID)
    return transaction

findAllByOrderId :: Transactionable m => Id PaymentOrder -> m [PaymentTransaction]
findAllByOrderId orderId =
  findAll $ do
    transaction <- from $ table @PaymentTransactionT
    where_ $ transaction ^. PaymentTransactionOrderId ==. val (toKey orderId)
    orderBy [desc $ transaction ^. PaymentTransactionCreatedAt]
    return transaction

findNewTransactionByOrderId :: Transactionable m => Id PaymentOrder -> m (Maybe PaymentTransaction)
findNewTransactionByOrderId orderId =
  findOne $ do
    transaction <- from $ table @PaymentTransactionT
    where_ $
      Esq.isNothing (transaction ^. PaymentTransactionTxnUUID)
        &&. transaction ^. PaymentTransactionOrderId ==. val (toKey orderId)
    limit 1
    return transaction

instance FromTType' BeamPT.PaymentTransaction PaymentTransaction where
  fromTType' BeamPT.PaymentTransactionT {..} = do
    pure $
      Just
        PaymentTransaction
          { id = Id id,
            orderId = Id orderId,
            merchantId = Id merchantId,
            ..
          }

instance ToTType' BeamPT.PaymentTransaction PaymentTransaction where
  toTType' PaymentTransaction {..} =
    BeamPT.PaymentTransactionT
      { id = getId id,
        orderId = getId orderId,
        merchantId = merchantId.getId,
        ..
      }
