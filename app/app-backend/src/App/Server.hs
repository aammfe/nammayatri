{-# OPTIONS_GHC -Wno-deprecations #-}

module App.Server where

import API
import App.Types
import Beckn.Tools.Metrics.Init
import Beckn.Types.Flow
import Beckn.Utils.App
import qualified Beckn.Utils.Servant.Server as BU
import Core.Beckn (logBecknRequest)
import EulerHS.Prelude
import Servant
import Utils.Auth

run :: Env -> Application
run = withModifiedEnv $ \modifiedEnv ->
  BU.run appAPI API.handler context modifiedEnv
    & logRequestAndResponse modifiedEnv
    & logBecknRequest modifiedEnv.appEnv
    & addServantInfo appAPI
    & hashBodyForSignature
    & supportProxyAuthorization
  where
    appAPI = Proxy @API.API
    context =
      verifyPersonAction @(FlowR AppEnv)
        :. verifyDashboardAction @(FlowR AppEnv)
        :. EmptyContext
