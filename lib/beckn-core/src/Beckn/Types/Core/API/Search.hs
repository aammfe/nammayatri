{-# LANGUAGE DuplicateRecordFields #-}

module Beckn.Types.Core.API.Search
  ( module Beckn.Types.Core.API.Search,
    module Beckn.Types.Core.API.Callback,
  )
where

import Beckn.Types.Core.API.Callback
import Beckn.Types.Core.Ack
import Beckn.Types.Core.Context
import Beckn.Types.Mobility.Catalog
import Beckn.Types.Mobility.Intent
import Beckn.Utils.Example
import Data.Generics.Labels ()
import Data.OpenApi (ToSchema)
import EulerHS.Prelude
import Servant (JSON, Post, ReqBody, (:>))

type SearchAPI =
  "search"
    :> ReqBody '[JSON] SearchReq
    :> Post '[JSON] AckResponse

search :: Proxy SearchAPI
search = Proxy

type OnSearchAPI =
  "on_search"
    :> ReqBody '[JSON] OnSearchReq
    :> Post '[JSON] OnSearchRes

onSearch :: Proxy OnSearchAPI
onSearch = Proxy

data SearchReq = SearchReq
  { context :: Context,
    message :: SearchIntent
  }
  deriving (Generic, Show, FromJSON, ToJSON, ToSchema)

type SearchRes = AckResponse

type OnSearchReq = CallbackReq OnSearchServices

newtype OnSearchServices = OnSearchServices
  { catalog :: Catalog
  }
  deriving (Generic, Show, FromJSON, ToJSON, ToSchema)

type OnSearchRes = AckResponse

newtype SearchIntent = SearchIntent
  { intent :: Intent
  }
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema)

instance Example SearchIntent where
  example = SearchIntent example

instance Example OnSearchServices where
  example =
    OnSearchServices
      { catalog = example
      }

type OnSearchEndAPI =
  "on_search"
    :> "end"
    :> ReqBody '[JSON] OnSearchEndReq
    :> Post '[JSON] OnSearchEndRes

onSearchEndAPI :: Proxy OnSearchEndAPI
onSearchEndAPI = Proxy

newtype OnSearchEndReq = OnSearchEndReq {context :: Context}
  deriving (Generic, Show, FromJSON, ToJSON)

type OnSearchEndRes = AckResponse
