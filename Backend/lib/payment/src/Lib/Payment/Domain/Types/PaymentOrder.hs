{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Lib.Payment.Domain.Types.PaymentOrder where

import Kernel.External.Encryption
import qualified Kernel.External.Payment.Interface as Payment
import Kernel.Prelude
import Kernel.Types.Common
import Kernel.Types.Id
import Lib.Payment.Domain.Types.Common

data PaymentOrderE e = PaymentOrder
  { id :: Id PaymentOrder,
    shortId :: ShortId PaymentOrder,
    requestId :: Maybe Text,
    service :: Maybe Text,
    clientId :: Maybe Text,
    description :: Maybe Text,
    returnUrl :: Maybe Text,
    action :: Maybe Text,
    paymentServiceOrderId :: Text, -- generated by Juspay service
    personId :: Id Person,
    merchantId :: Id Merchant,
    paymentMerchantId :: Maybe Text,
    amount :: Money,
    currency :: Payment.Currency,
    status :: Payment.TransactionStatus,
    paymentLinks :: Payment.PaymentLinks,
    clientAuthToken :: Maybe (EncryptedHashedField e Text),
    clientAuthTokenExpiry :: Maybe UTCTime,
    getUpiDeepLinksOption :: Maybe Bool,
    environment :: Maybe Text,
    createMandate :: Maybe Payment.MandateType,
    mandateMaxAmount :: Maybe HighPrecMoney,
    mandateStartDate :: Maybe UTCTime,
    mandateEndDate :: Maybe UTCTime,
    bankErrorMessage :: Maybe Text,
    bankErrorCode :: Maybe Text,
    createdAt :: UTCTime,
    updatedAt :: UTCTime
  }
  deriving (Generic)

data PaymentOrderAPIEntity = PaymentOrderAPIEntity
  { id :: Id PaymentOrder,
    shortId :: ShortId PaymentOrder,
    requestId :: Maybe Text,
    service :: Maybe Text,
    clientId :: Maybe Text,
    description :: Maybe Text,
    returnUrl :: Maybe Text,
    action :: Maybe Text,
    personId :: Id Person,
    merchantId :: Id Merchant,
    amount :: Money,
    currency :: Payment.Currency,
    status :: Payment.TransactionStatus,
    paymentLinks :: Payment.PaymentLinks,
    clientAuthToken :: Maybe Text,
    clientAuthTokenExpiry :: Maybe UTCTime,
    getUpiDeepLinksOption :: Maybe Bool,
    environment :: Maybe Text,
    createMandate :: Maybe Payment.MandateType,
    mandateMaxAmount :: Maybe HighPrecMoney,
    mandateStartDate :: Maybe UTCTime,
    mandateEndDate :: Maybe UTCTime,
    createdAt :: UTCTime,
    updatedAt :: UTCTime
  }
  deriving (Generic, ToJSON, FromJSON, ToSchema)

type PaymentOrder = PaymentOrderE 'AsEncrypted
