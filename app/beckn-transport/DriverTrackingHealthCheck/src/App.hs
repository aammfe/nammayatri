module App where

import API
import qualified Beckn.Tools.Metrics.Init as Metrics
import qualified Beckn.Types.App as App
import Beckn.Types.Flow
import Beckn.Utils.App
import Beckn.Utils.Common
import Beckn.Utils.Dhall (readDhallConfigDefault)
import qualified Beckn.Utils.FlowLogging as L
import qualified Beckn.Utils.Servant.Server as Server
import Beckn.Utils.Shutdown
import Control.Concurrent
import Environment
import EulerHS.Prelude hiding (exitSuccess)
import qualified EulerHS.Runtime as R
import Network.Wai.Handler.Warp
import Servant
import qualified Service.Runner as Service

runDriverHealthcheck :: (AppCfg -> AppCfg) -> IO ()
runDriverHealthcheck configModifier = do
  config <- configModifier <$> readDhallConfigDefault "driver-tracking-healthcheck-service"
  Metrics.serve config.metricsPort
  hostname <- getPodName
  let loggerRt = L.getEulerLoggerRuntime hostname config.loggerConfig
  appEnv <- buildAppEnv config

  R.withFlowRuntime (Just loggerRt) \flowRt -> do
    flowRt' <- runFlowR flowRt appEnv do
      managers <- createManagers mempty -- default manager is created
      pure $ flowRt {R._httpClientManagers = managers}

    let settings =
          defaultSettings
            & setGracefulShutdownTimeout (Just $ getSeconds config.graceTerminationPeriod)
            & setInstallShutdownHandler (handleShutdown appEnv.isShuttingDown (releaseAppEnv appEnv))
            & setPort config.healthcheckPort
    void . forkIO . runSettings settings $
      Server.run healthCheckAPI healthCheck EmptyContext (App.EnvR flowRt' appEnv)

    runFlowR flowRt' appEnv Service.driverTrackingHealthcheckService
    waitForShutdown appEnv.isShuttingDown
