{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module SharedLogic.MessageBuilder
  ( BuildSendOTPMessageReq (..),
    BuildSOSAlertMessageReq (..),
    buildSendOTPMessage,
    BuildSendBookingOTPMessageReq (..),
    buildSendBookingOTPMessage,
    buildSOSAlertMessage,
    BuildMarkRideAsSafeMessageReq (..),
    buildMarkRideAsSafeMessage,
  )
where

import qualified Data.Text as T
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Merchant.MerchantMessage as DMM
import Kernel.Prelude
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant.MerchantMessage as QMM
import Tools.Error

templateText :: Text -> Text
templateText txt = "{#" <> txt <> "#}"

data BuildSendOTPMessageReq = BuildSendOTPMessageReq
  { otp :: Text,
    hash :: Text
  }
  deriving (Generic)

buildSendOTPMessage :: (EsqDBFlow m r, CacheFlow m r) => Id DM.Merchant -> BuildSendOTPMessageReq -> m Text
buildSendOTPMessage merchantId req = do
  merchantMessage <-
    QMM.findByMerchantIdAndMessageKey merchantId DMM.SEND_OTP
      >>= fromMaybeM (MerchantMessageNotFound merchantId.getId (show DMM.SEND_OTP))
  return $
    merchantMessage.message
      & T.replace (templateText "otp") req.otp
      & T.replace (templateText "hash") req.hash

data BuildSendBookingOTPMessageReq = BuildSendBookingOTPMessageReq
  { otp :: Text,
    amount :: Text
  }
  deriving (Generic)

buildSendBookingOTPMessage :: (EsqDBFlow m r, CacheFlow m r) => Id DM.Merchant -> BuildSendBookingOTPMessageReq -> m Text
buildSendBookingOTPMessage merchantId req = do
  merchantMessage <-
    QMM.findByMerchantIdAndMessageKey merchantId DMM.SEND_BOOKING_OTP
      >>= fromMaybeM (MerchantMessageNotFound merchantId.getId (show DMM.SEND_BOOKING_OTP))
  return $
    merchantMessage.message
      & T.replace (templateText "otp") req.otp
      & T.replace (templateText "amount") req.amount

data BuildSOSAlertMessageReq = BuildSOSAlertMessageReq
  { userName :: Text,
    rideLink :: Text
  }
  deriving (Generic)

buildSOSAlertMessage :: (EsqDBFlow m r, CacheFlow m r) => Id DM.Merchant -> BuildSOSAlertMessageReq -> m Text
buildSOSAlertMessage merchantId req = do
  merchantMessage <-
    QMM.findByMerchantIdAndMessageKey merchantId DMM.SEND_SOS_ALERT
      >>= fromMaybeM (MerchantMessageNotFound merchantId.getId (show DMM.SEND_SOS_ALERT))
  return $
    merchantMessage.message
      & T.replace (templateText "userName") req.userName
      & T.replace (templateText "rideLink") req.rideLink

newtype BuildMarkRideAsSafeMessageReq = BuildMarkRideAsSafeMessageReq
  { userName :: Text
  }
  deriving (Generic)

buildMarkRideAsSafeMessage :: (EsqDBFlow m r, CacheFlow m r) => Id DM.Merchant -> BuildMarkRideAsSafeMessageReq -> m Text
buildMarkRideAsSafeMessage merchantId req = do
  merchantMessage <-
    QMM.findByMerchantIdAndMessageKey merchantId DMM.MARK_RIDE_AS_SAFE
      >>= fromMaybeM (MerchantMessageNotFound merchantId.getId (show DMM.MARK_RIDE_AS_SAFE))
  return $
    merchantMessage.message
      & T.replace (templateText "userName") req.userName
