{-# OPTIONS_GHC -Wno-orphans #-}

module Beckn.Types.Flow (FlowR, HasFlowEnv, runFlowR) where

import Beckn.Types.Field
import Beckn.Types.Logging
import Beckn.Types.Monitoring.Prometheus.Metrics
import Beckn.Utils.Logging
import qualified Beckn.Utils.Monitoring.Prometheus.Metrics as Metrics
import qualified EulerHS.Interpreters as I
import qualified EulerHS.Language as L
import EulerHS.Prelude
import qualified EulerHS.Runtime as R

type FlowR r = ReaderT r L.Flow

runFlowR :: R.FlowRuntime -> r -> FlowR r a -> IO a
runFlowR flowRt r x = I.runFlow flowRt . runReaderT x $ r

-- | Require monad to be Flow-based and have specified fields in Reader env.
type HasFlowEnv m r fields =
  ( L.MonadFlow m,
    MonadReader r m,
    HasFields r fields
  )

instance Log (FlowR r) where
  logOutput = logOutputImplementation
  withLogTag = withLogTagImplementation

instance HasCoreMetrics r => CoreMetrics (FlowR r) where
  startRequestLatencyTracking host serviceName = do
    cmContainer <- (.coreMetrics) <$> ask
    Metrics.startRequestLatencyTracking cmContainer host serviceName

  incrementErrorCounter err = do
    cmContainer <- (.coreMetrics) <$> ask
    Metrics.incrementErrorCounter cmContainer err
