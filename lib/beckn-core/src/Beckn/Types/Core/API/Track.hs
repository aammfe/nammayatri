{-# LANGUAGE DuplicateRecordFields #-}

module Beckn.Types.Core.API.Track where

import Beckn.Types.Core.API.Callback
import Beckn.Types.Core.Ack (AckResponse (..))
import Beckn.Types.Core.Context
import Beckn.Types.Core.Tracking
import EulerHS.Prelude
import Servant (JSON, Post, ReqBody, (:>))

type TrackAPI =
  "track"
    :> ReqBody '[JSON] TrackTripReq
    :> Post '[JSON] TrackTripRes

data TrackTripReq = TrackTripReq
  { context :: Context,
    message :: TrackReqMessage
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type TrackTripRes = AckResponse

type OnTrackTripReq = CallbackReq OnTrackReqMessage

type OnTrackTripRes = AckResponse

data TrackReqMessage = TrackReqMessage
  { order_id :: Text,
    callback_url :: Maybe Text
  }
  deriving (Generic, Show, FromJSON, ToJSON)

newtype OnTrackReqMessage = OnTrackReqMessage
  { tracking :: Maybe Tracking
  }
  deriving (Generic, Show, FromJSON, ToJSON)
