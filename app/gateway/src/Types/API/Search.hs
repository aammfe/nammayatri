module Types.API.Search
  ( OnSearchReq,
    SearchReq (..),
    OnSearchAPI,
    SearchAPI,
    onSearchAPI,
    searchAPI,
  )
where

import Beckn.Types.API.Auth
import Beckn.Types.API.Callback
import Beckn.Types.Common (AckResponse (..))
import Beckn.Types.Core.Context
import Beckn.Utils.Servant.HeaderAuth (APIKeyAuth)
import Data.Aeson (Value)
import EulerHS.Prelude
import Servant hiding (Context)
import Utils.Auth (LookupRegistry, VerifyAPIKey)

data SearchReq = SearchReq
  { context :: Context,
    message :: Value
  }
  deriving (Generic, Show, FromJSON, ToJSON)

type OnSearchReq = CallbackReq Value

type SearchAPI =
  BecknAuth
    LookupRegistry
    VerifyAPIKey
    ( "search"
        :> ReqBody '[JSON] SearchReq
        :> Post '[JSON] AckResponse
    )

searchAPI :: Proxy SearchAPI
searchAPI = Proxy

type OnSearchAPI =
  "on_search"
    :> APIKeyAuth VerifyAPIKey
    :> ReqBody '[JSON] OnSearchReq
    :> Post '[JSON] AckResponse

onSearchAPI :: Proxy OnSearchAPI
onSearchAPI = Proxy
