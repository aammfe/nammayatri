{-# LANGUAGE DuplicateRecordFields #-}

module Beckn.Types.FMD.API.Search where

import Beckn.Types.Common
import Beckn.Types.Core.Context
import Beckn.Types.Core.Error
import Beckn.Types.FMD.Intent
import Beckn.Types.FMD.Service
import Beckn.Utils.Servant.HeaderAuth
import Data.Generics.Labels ()
import EulerHS.Prelude
import Servant (JSON, Post, ReqBody, (:>))

type SearchAPI v =
  "search"
    :> APIKeyAuth v
    :> ReqBody '[JSON] SearchReq
    :> Post '[JSON] AckResponse

searchAPI :: Proxy (SearchAPI v)
searchAPI = Proxy

type OnSearchAPI v =
  "on_search"
    :> APIKeyAuth v
    :> ReqBody '[JSON] OnSearchReq
    :> Post '[JSON] OnSearchRes

onSearchAPI :: Proxy (OnSearchAPI v)
onSearchAPI = Proxy

data SearchReq = SearchReq
  { context :: Context,
    message :: SearchIntent
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type SearchRes = AckResponse

data OnSearchReq = OnSearchReq
  { context :: Context,
    message :: OnSearchServices,
    error :: Maybe Error
  }
  deriving (Generic, Show, FromJSON, ToJSON)

newtype OnSearchServices = OnSearchServices
  { services :: [Service]
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type OnSearchRes = AckResponse

newtype SearchIntent = SearchIntent
  { intent :: Intent
  }
  deriving (Generic, Show, ToJSON, FromJSON)
