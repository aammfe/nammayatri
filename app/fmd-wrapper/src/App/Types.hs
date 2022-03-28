module App.Types
  ( AppCfg (),
    AppEnv (..),
    Env,
    FlowHandler,
    FlowServer,
    Flow,
    buildAppEnv,
    releaseAppEnv,
  )
where

import Beckn.Storage.DB.Config (DBConfig)
import Beckn.Storage.Esqueleto.Config
import Beckn.Types.App
import Beckn.Types.Cache
import Beckn.Types.Common
import Beckn.Types.Flow
import Beckn.Types.Registry
import Beckn.Utils.CacheRedis as Cache
import Beckn.Utils.Dhall (FromDhall)
import Beckn.Utils.IOLogging
import qualified Beckn.Utils.Registry as Registry
import Beckn.Utils.Servant.Client (HttpClientOptions)
import Beckn.Utils.Servant.SignatureAuth
import qualified Data.Text as T
import EulerHS.Prelude
import qualified EulerHS.Types as T
import System.Environment (lookupEnv)
import Tools.Metrics
import Types.Wrapper (DunzoConfig)

data AppCfg = AppCfg
  { dbCfg :: DBConfig,
    esqDBCfg :: EsqDBConfig,
    redisCfg :: T.RedisConfig,
    port :: Int,
    metricsPort :: Int,
    hostName :: Text,
    selfId :: Text,
    migrationPath :: Maybe FilePath,
    autoMigrate :: Bool,
    loggerConfig :: LoggerConfig,
    coreVersion :: Text,
    dzConfig :: DunzoConfig,
    authEntity :: AuthenticatingEntity',
    graceTerminationPeriod :: Seconds,
    httpClientOptions :: HttpClientOptions,
    nwAddress :: BaseUrl,
    registryUrl :: BaseUrl,
    registrySecrets :: RegistrySecrets,
    disableSignatureAuth :: Bool
  }
  deriving (Generic, FromDhall)

data AppEnv = AppEnv
  { dbCfg :: DBConfig,
    hostName :: Text,
    selfId :: Text,
    loggerConfig :: LoggerConfig,
    coreVersion :: Text,
    dzConfig :: DunzoConfig,
    authEntity :: AuthenticatingEntity',
    graceTerminationPeriod :: Seconds,
    httpClientOptions :: HttpClientOptions,
    nwAddress :: BaseUrl,
    registryUrl :: BaseUrl,
    registrySecrets :: RegistrySecrets,
    disableSignatureAuth :: Bool,
    esqDBEnv :: EsqDBEnv,
    isShuttingDown :: TMVar (),
    coreMetrics :: CoreMetricsContainer,
    loggerEnv :: LoggerEnv
  }
  deriving (Generic)

buildAppEnv :: AppCfg -> IO AppEnv
buildAppEnv AppCfg {..} = do
  hostname <- map T.pack <$> lookupEnv "POD_NAME"
  isShuttingDown <- newEmptyTMVarIO
  coreMetrics <- registerCoreMetricsContainer
  loggerEnv <- prepareLoggerEnv loggerConfig hostname
  esqDBEnv <- prepareEsqDBEnv esqDBCfg loggerEnv
  return $ AppEnv {..}

releaseAppEnv :: AppEnv -> IO ()
releaseAppEnv AppEnv {..} =
  releaseLoggerEnv loggerEnv

type Env = EnvR AppEnv

type FlowHandler = FlowHandlerR AppEnv

type FlowServer api = FlowServerR AppEnv api

type Flow = FlowR AppEnv

instance AuthenticatingEntity AppEnv where
  getSigningKey = (.authEntity.signingKey)
  getSignatureExpiry = (.authEntity.signatureExpiry)

instance Registry Flow where
  registryLookup = Registry.withSubscriberCache Registry.registryLookup

instance Cache Subscriber Flow where
  type CacheKey Subscriber = SimpleLookupRequest
  getKey = Cache.getKey "fmd-wrapper:registry" . lookupRequestToRedisKey
  setKey = Cache.setKey "fmd-wrapper:registry" . lookupRequestToRedisKey
  delKey = Cache.delKey "fmd-wrapper:registry" . lookupRequestToRedisKey

instance CacheEx Subscriber Flow where
  setKeyEx ttl = Cache.setKeyEx "fmd-wrapper:registry" ttl . lookupRequestToRedisKey
