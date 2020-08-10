module App.Server
  ( run,
  )
where

import App.Routes (gatewayAPI, gatewayServer)
import App.Types
import Beckn.Types.App
import Beckn.Utils.Common
import Beckn.Utils.Monitoring.Prometheus.Metrics (addServantInfo)
import qualified Beckn.Utils.Servant.Server as BU
import qualified Beckn.Utils.Servant.Trail.Handler as Trail
import qualified Beckn.Utils.Servant.Trail.Server as Trail
import qualified Data.Vault.Lazy as V
import EulerHS.Prelude
import Servant
import Utils.Auth

run :: V.Key (HashMap Text Text) -> EnvR AppEnv -> Application
run key env =
  addServantInfo gatewayAPI $
    Trail.traceRequests traceHandler $
      BU.run gatewayAPI (gatewayServer key) context env
  where
    context = verifyAPIKeyAction :. EmptyContext
    traceHandler =
      Trail.hoistTraceHandler (runFlowR (runTime env) (appEnv env)) Trail.traceHandler
