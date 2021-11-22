{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE UndecidableInstances #-}

module Beckn.Utils.Servant.Server where

import Beckn.Types.App (EnvR (..), FlowHandlerR, FlowServerR)
import Beckn.Types.Flow
import Beckn.Types.Logging
import Beckn.Types.Time
import Beckn.Utils.App
import Beckn.Utils.FlowLogging
import Beckn.Utils.Logging
import qualified Beckn.Utils.Monitoring.Prometheus.Metrics as Metrics
import qualified Beckn.Utils.Monitoring.Prometheus.Servant as Metrics
import qualified Data.Text as T
import EulerHS.Prelude
import qualified EulerHS.Runtime as E
import GHC.Records.Extra (HasField)
import Network.Wai.Handler.Warp
  ( Port,
    Settings,
    defaultSettings,
    runSettings,
    setGracefulShutdownTimeout,
    setInstallShutdownHandler,
    setPort,
  )
import Servant
import Servant.Server.Internal.DelayedIO (DelayedIO, delayedFailFatal)
import System.Environment

class HasEnvEntry r (context :: [Type]) | context -> r where
  getEnvEntry :: Context context -> EnvR r

instance {-# OVERLAPPABLE #-} HasEnvEntry r xs => HasEnvEntry r (notIt ': xs) where
  getEnvEntry (_ :. xs) = getEnvEntry xs

instance {-# OVERLAPPING #-} HasEnvEntry r (EnvR r ': xs) where
  getEnvEntry (x :. _) = x

run ::
  forall a r ctx.
  ( HasContextEntry (ctx .++ '[ErrorFormatters]) ErrorFormatters,
    HasServer a (EnvR r ': ctx)
  ) =>
  Proxy (a :: Type) ->
  FlowServerR r a ->
  Context ctx ->
  EnvR r ->
  Application
run apis server ctx env =
  serveWithContext apis (env :. ctx) $
    hoistServerWithContext apis (Proxy @(EnvR r ': ctx)) f server
  where
    f :: FlowHandlerR r m -> Handler m
    f r = do
      eResult <- liftIO . try $ runReaderT r env
      case eResult of
        Left err ->
          print @String ("exception thrown: " <> show err) *> throwError err
        Right res -> pure res

runFlowRDelayedIO :: EnvR r -> FlowR r b -> DelayedIO b
runFlowRDelayedIO env f =
  liftIO (try . runFlowR (flowRuntime env) (appEnv env) $ f)
    >>= either delayedFailFatal pure

runServerService ::
  forall env config (api :: Type) ctx.
  ( HasField "config" env config,
    HasField "graceTerminationPeriod" config Seconds,
    HasField "isShuttingDown" env (MVar ()),
    HasField "loggerConfig" config LoggerConfig,
    HasField "port" config Port,
    HasServer api '[EnvR env],
    Metrics.SanitizedUrl api,
    HasContextEntry (ctx .++ '[ErrorFormatters]) ErrorFormatters,
    HasServer api (EnvR env ': ctx)
  ) =>
  env ->
  Proxy api ->
  FlowServerR env api ->
  (Application -> Application) ->
  (Settings -> Settings) ->
  Context ctx ->
  IO ()
runServerService appEnv serverAPI serverHandler waiMiddleware waiSettings servantCtx = do
  let port = appEnv.config.port
  hostname <- fmap T.pack <$> lookupEnv "POD_NAME"
  let loggerRt = getEulerLoggerRuntime hostname $ appEnv.config.loggerConfig
  let settings =
        defaultSettings
          & setGracefulShutdownTimeout (Just $ getSeconds appEnv.config.graceTerminationPeriod)
          & setInstallShutdownHandler (handleShutdownMVar $ appEnv.isShuttingDown)
          & setPort port
          & waiSettings
  let healthCheck = pure "App is UP"
  let server = withModifiedEnv $ \modifiedEnv ->
        run (Proxy @(HealthCheckAPI :<|> api)) (healthCheck :<|> serverHandler) servantCtx modifiedEnv
          & logRequestAndResponse modifiedEnv
          & Metrics.addServantInfo serverAPI
          & waiMiddleware
  E.withFlowRuntime (Just loggerRt) $ \flowRt -> do
    runFlowR flowRt appEnv $ logInfo $ "Runtime created. Starting server at port " <> show port
    runSettings settings $ server (EnvR flowRt appEnv)

type HealthCheckAPI = Get '[JSON] Text
