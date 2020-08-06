module MockAppBackend.Fixtures where

import qualified "beckn-gateway" App as GatewayBE
import qualified "mock-app-backend" App as MockAppBE
import qualified "mock-provider-backend" App as MockProviderBE
import "mock-app-backend" App.Routes as MockAppRoutes
import Beckn.Types.Common as Common
import Beckn.Types.Core.Context
import Beckn.Types.FMD.API.Confirm
import Beckn.Types.FMD.API.Init
import Beckn.Types.FMD.API.Search
import Beckn.Types.FMD.API.Select
import Beckn.Utils.Common
import Data.Time
import EulerHS.Prelude
import qualified EulerHS.Types as T
import qualified "mock-app-backend" Product.Trigger as MockAppTrigger
import Servant.Client

buildContext :: Text -> Text -> UTCTime -> Context
buildContext act tid utcTime =
  Context
    { _domain = "FINAL-MILE-DELIVERY",
      _action = act,
      _country = Nothing,
      _city = Nothing,
      _core_version = Just "0.8.0",
      _domain_version = Just "0.7.0",
      _bap_id = Nothing,
      _bg_id = Nothing,
      _bpp_id = Nothing,
      _bap_nw_address = Nothing,
      _bg_nw_address = Nothing,
      _bpp_nw_address = Nothing,
      _request_transaction_id = tid,
      _timestamp = utcTime,
      _token = Nothing
    }

mockAppBaseUrl :: BaseUrl
mockAppBaseUrl =
  BaseUrl
    { baseUrlScheme = Http,
      baseUrlHost = "localhost",
      baseUrlPort = 8016,
      baseUrlPath = "/v1"
    }

mockProviderBaseUrl :: BaseUrl
mockProviderBaseUrl =
  BaseUrl
    { baseUrlScheme = Http,
      baseUrlHost = "localhost",
      baseUrlPort = 8017,
      baseUrlPath = "/v1"
    }

runClient :: ClientEnv -> ClientM a -> IO (Either ClientError a)
runClient clientEnv x = runClientM x clientEnv

getLoggerConfig :: String -> T.LoggerConfig
getLoggerConfig t =
  T.defaultLoggerConfig
    { T._logToFile = True,
      T._logFilePath = "/tmp/log-" <> t,
      T._isAsync = False
    }

startServers :: IO (ThreadId, ThreadId, ThreadId)
startServers = do
  mockAppTid <- forkIO MockAppBE.runMockApp
  mockProvTid <- forkIO MockProviderBE.runMockProvider
  gatewayTid <- forkIO GatewayBE.runGateway
  return (mockAppTid, mockProvTid, gatewayTid)

triggerSearchReq :: MockAppTrigger.TriggerFlow -> ClientM Common.AckResponse
triggerSearchReq = client (Proxy :: Proxy MockAppRoutes.TriggerAPI)

onSearchFlow :: Text -> OnSearchReq -> ClientM Common.AckResponse
onSearchFlow = client (Proxy :: Proxy MockAppRoutes.OnSearchAPI)

buildOnSearchReq :: Context -> OnSearchReq
buildOnSearchReq context =
  OnSearchReq
    { context,
      message = OnSearchServices example,
      error = Nothing
    }

onSelectFlow :: Text -> OnSelectReq -> ClientM Common.AckResponse
onSelectFlow = client (Proxy :: Proxy MockAppRoutes.OnSelectAPI)

buildOnSelectReq :: Context -> OnSelectReq
buildOnSelectReq context =
  OnSelectReq
    { context,
      message = OnSelectMessage example example,
      error = Nothing
    }

onInitFlow :: Text -> OnInitReq -> ClientM Common.AckResponse
onInitFlow = client (Proxy :: Proxy MockAppRoutes.OnInitAPI)

buildOnInitReq :: Context -> OnInitReq
buildOnInitReq context =
  OnInitReq
    { context,
      message = InitResMessage example,
      error = Nothing
    }

onConfirmFlow :: Text -> OnConfirmReq -> ClientM Common.AckResponse
onConfirmFlow = client (Proxy :: Proxy MockAppRoutes.OnConfirmAPI)

buildOnConfirmReq :: Context -> OnConfirmReq
buildOnConfirmReq context =
  OnConfirmReq
    { context,
      message = ConfirmResMessage example,
      error = Nothing
    }

