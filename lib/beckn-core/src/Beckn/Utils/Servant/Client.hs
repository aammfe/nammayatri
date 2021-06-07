module Beckn.Utils.Servant.Client where

import Beckn.Types.Common
import Beckn.Types.Error.CallAPIError
import Beckn.Types.Error.FromResponse
import Beckn.Types.Monitoring.Prometheus.Metrics (HasCoreMetrics)
import Beckn.Utils.Error.Throwing
import Beckn.Utils.Logging (logInfo)
import Beckn.Utils.Monitoring.Prometheus.Metrics as Metrics
import qualified Data.Aeson as A
import qualified Data.Text as T
import qualified EulerHS.Language as L
import EulerHS.Prelude hiding (id)
import qualified EulerHS.Types as ET
import qualified Servant.Client as S
import Servant.Client.Core

type CallAPI env a a' =
  ( HasCallStack,
    HasCoreMetrics env,
    ET.JSONEx a,
    ToJSON a
  ) =>
  BaseUrl ->
  ET.EulerClient a ->
  Text ->
  FlowR env a'

callAPI :: CallAPI env a (Either ClientError a)
callAPI = callAPI' Nothing

callAPI' ::
  Maybe ET.ManagerSelector ->
  CallAPI env a (Either ClientError a)
callAPI' mbManagerSelector baseUrl eulerClient desc = do
  withLogTag "callAPI" $ do
    endTracking <- Metrics.startRequestLatencyTracking (T.pack $ showBaseUrl baseUrl) desc
    res <- L.callAPI' mbManagerSelector baseUrl eulerClient
    case res of
      Right r -> logInfo $ "Ok response: " <> decodeUtf8 (A.encode r)
      Left err -> logInfo $ "Error occured during client call: " <> show err
    _ <- endTracking $ getResponseCode res
    return res
  where
    getResponseCode res =
      case res of
        Right _ -> "200"
        Left (FailureResponse _ (Response code _ _ _)) -> T.pack $ show code
        Left (DecodeFailure _ (Response code _ _ _)) -> T.pack $ show code
        Left (InvalidContentTypeHeader (Response code _ _ _)) -> T.pack $ show code
        Left (UnsupportedContentType _ (Response code _ _ _)) -> T.pack $ show code
        Left (ConnectionError _) -> "Connection error"

parseBaseUrl :: MonadThrow m => Text -> m S.BaseUrl
parseBaseUrl = S.parseBaseUrl . T.unpack

callApiExtractingApiError ::
  FromResponse err =>
  Maybe ET.ManagerSelector ->
  CallAPI env a (Either (CallAPIError err) a)
callApiExtractingApiError mbManagerSelector baseUrl eulerClient desc =
  callAPI' mbManagerSelector baseUrl eulerClient desc
    <&> extractApiError

callApiUnwrappingApiError ::
  ( FromResponse err,
    IsAPIException exc
  ) =>
  (err -> exc) ->
  Maybe ET.ManagerSelector ->
  Maybe Text ->
  CallAPI env a a
callApiUnwrappingApiError toAPIException mbManagerSelector errorCodeMb baseUrl eulerClient desc =
  callApiExtractingApiError mbManagerSelector baseUrl eulerClient desc
    >>= unwrapEitherCallAPIError errorCodeMb baseUrl toAPIException
