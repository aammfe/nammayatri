module FmdWrapper.Server where

import Beckn.Types.Core.Ack
import qualified Beckn.Utils.SignatureAuth as HttpSig
import EulerHS.Prelude
import FmdWrapper.Common
import Runner
import Servant
import "fmd-wrapper" Types.Beckn.API.Search (OnSearchCatalog)
import qualified "fmd-wrapper" Types.Beckn.API.Types as API

newtype CallbackData = CallbackData
  { onSearchTVar :: TVar [CallbackResult (API.BecknCallbackReq OnSearchCatalog)]
  }

withCallbackApp :: (CallbackData -> IO ()) -> IO ()
withCallbackApp action = do
  callbackData <- mkCallbackData
  withApp fmdTestAppPort (pure (callbackApp callbackData)) (action callbackData)

type CallbackAPI =
  "v1"
    :> OnSearchAPI

type OnSearchAPI =
  "on_search"
    :> Header "Authorization" HttpSig.SignaturePayload
    :> ReqBody '[JSON] (API.BecknCallbackReq OnSearchCatalog)
    :> Post '[JSON] AckResponse

callbackApp :: CallbackData -> Application
callbackApp callbackData = serve (Proxy :: Proxy CallbackAPI) $ callbackServer callbackData

callbackServer :: CallbackData -> Server CallbackAPI
callbackServer = onSearch

onSearch :: CallbackData -> Maybe HttpSig.SignaturePayload -> (API.BecknCallbackReq OnSearchCatalog) -> Handler AckResponse
onSearch callbackData sPayload req = do
  atomically $ modifyTVar (onSearchTVar callbackData) (CallbackResult (sPayload <&> (.params.keyId.subscriberId)) req :)
  pure Ack

mkCallbackData :: IO CallbackData
mkCallbackData = do
  onSearchTVar <- newTVarIO []
  pure $ CallbackData onSearchTVar

waitForCallback :: IO ()
waitForCallback = do
  threadDelay 5e6
