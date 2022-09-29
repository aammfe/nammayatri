module API (healthCheckAPI, healthCheck, iAmAlive) where

import qualified Beckn.Storage.Redis.Queries as Redis
import Beckn.Types.Common
import Beckn.Utils.Common
import Beckn.Utils.IOLogging (LoggerEnv)
import EulerHS.Prelude
import Servant (Get, JSON)
import Tools.Error
import Tools.Metrics (CoreMetricsContainer)

type HealthCheckAPI = Get '[JSON] Text

healthCheckAPI :: Proxy HealthCheckAPI
healthCheckAPI = Proxy

healthCheck ::
  ( HasField "coreMetrics" r CoreMetricsContainer,
    HasField "isShuttingDown" r Shutdown,
    HasField "loggerEnv" r LoggerEnv
  ) =>
  FlowHandlerR r Text
healthCheck = withFlowHandlerAPI do
  mbTime <- Redis.getKeyRedis key
  maybe markAsDead checkLastUpdateTime mbTime
  where
    markAsDead = throwError ServiceUnavailable
    checkLastUpdateTime lastUpdateTime = do
      now <- getCurrentTime
      let diffTime = diffUTCTime now lastUpdateTime
      if diffTime > 10
        then markAsDead
        else return "Service is up!"

key :: Text
key = "beckn:driver-tracking-healthcheck:service"

--TODO: Make ServiceHealthChecker util in shared-kernel
iAmAlive :: MonadFlow m => m ()
iAmAlive = getCurrentTime >>= Redis.setKeyRedis key
