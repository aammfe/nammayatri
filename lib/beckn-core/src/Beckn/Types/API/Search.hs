{-# LANGUAGE DuplicateRecordFields #-}

module Beckn.Types.API.Search where

import Beckn.Types.API.Auth
import Beckn.Types.API.Callback
import Beckn.Types.Common
import Beckn.Types.Core.Context
import Beckn.Types.Mobility.Catalog
import Beckn.Types.Mobility.Intent
import Beckn.Utils.Common
import Beckn.Utils.Servant.HeaderAuth
import Data.Generics.Labels ()
import EulerHS.Prelude
import Servant (Header, JSON, Post, ReqBody, (:>))

type SearchAPI sig apiKey =
  BecknAuth
    sig
    apiKey
    ( "search"
        :> ReqBody '[JSON] SearchReq
        :> Post '[JSON] AckResponse
    )

searchAPI :: Proxy (SearchAPI vSig vApiKey)
searchAPI = Proxy

type NSDLSearchAPI =
  "search"
    :> Header "userid" Text
    :> Header "Password" Text
    :> ReqBody '[JSON] SearchReq
    :> Post '[JSON] AckResponse

nsdlSearchAPI :: Proxy NSDLSearchAPI
nsdlSearchAPI = Proxy

type OnSearchAPI v =
  "on_search"
    :> APIKeyAuth v
    :> ReqBody '[JSON] OnSearchReq
    :> Post '[JSON] OnSearchRes

onSearchAPI :: Proxy (OnSearchAPI v)
onSearchAPI = Proxy

type NSDLOnSearchAPI =
  "on_search"
    :> Header "userid" Text
    :> Header "Password" Text
    :> ReqBody '[JSON] OnSearchReq
    :> Post '[JSON] OnSearchRes

nsdlOnSearchAPI :: Proxy NSDLOnSearchAPI
nsdlOnSearchAPI = Proxy

data SearchReq = SearchReq
  { context :: Context,
    message :: SearchIntent
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type SearchRes = AckResponse

type OnSearchReq = CallbackReq OnSearchServices

newtype OnSearchServices = OnSearchServices
  { catalog :: Catalog
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type OnSearchRes = AckResponse

newtype SearchIntent = SearchIntent
  { intent :: Intent
  }
  deriving (Generic, Show, ToJSON, FromJSON)

instance Example OnSearchServices where
  example =
    OnSearchServices
      { catalog = example
      }

type OnSearchEndAPI v =
  "on_search"
    :> "end"
    :> APIKeyAuth v
    :> ReqBody '[JSON] OnSearchEndReq
    :> Post '[JSON] OnSearchEndRes

onSearchEndAPI :: Proxy (OnSearchEndAPI v)
onSearchEndAPI = Proxy

newtype OnSearchEndReq = OnSearchEndReq {context :: Context}
  deriving (Generic, Show, FromJSON, ToJSON)

type OnSearchEndRes = AckResponse
