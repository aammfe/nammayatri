{-# LANGUAGE TypeApplications #-}

module External.Gateway.Flow where

import App.Types
import qualified Beckn.Types.API.Cancel as Cancel
import qualified Beckn.Types.API.Confirm as Confirm
import Beckn.Types.API.Search
import qualified Beckn.Types.API.Status as Status
import qualified Beckn.Types.API.Track as Track
import qualified Data.Text as T (pack)
import qualified EulerHS.Language as L
import EulerHS.Prelude
import qualified External.Gateway.Types as API
import Servant.Client
import System.Environment
import Types.API.Location
import Utils.Common

search ::
  BaseUrl -> SearchReq -> Flow (Either Text ())
search url req = do
  apiKey <- L.runIO $ lookupEnv "BG_API_KEY"
  res <- callAPI url (API.search (maybe "mobility-app-key" T.pack apiKey) req) "search"
  whenRight res $ \_ ->
    L.logInfo @Text "Search" "Search successfully delivered"
  whenLeft res $ \err ->
    L.logError @Text "Search" ("error occurred while search: " <> show err)
  return $ first show res

confirm :: BaseUrl -> Confirm.ConfirmReq -> Flow (Either Text ())
confirm url req = do
  res <- callAPI url (API.confirm req) "confirm"
  whenLeft res $ \err ->
    L.logError @Text "error occurred while confirm: " (show err)
  whenLeft res $ \err ->
    L.logError @Text "Confirm" ("error occurred while confirm: " <> show err)
  return $ first show res

location :: BaseUrl -> Text -> Flow (Either Text GetLocationRes)
location url req = do
  res <- callAPI url (API.location req) "location"
  whenLeft res $ \err ->
    L.logError @Text "error occurred while confirm: " (show err)
  whenLeft res $ \err ->
    L.logError @Text "Location" ("error occurred while getting location: " <> show err)
  return $ first show res

track :: BaseUrl -> Track.TrackTripReq -> Flow (Either Text ())
track url req = do
  res <- callAPI url (API.trackTrip req) "track"
  case res of
    Left err -> L.logError @Text "error occurred while track trip: " (show err)
    Right _ -> L.logInfo @Text "Track" "Track successfully delivered"
  return $ first show res

cancel :: BaseUrl -> Cancel.CancelReq -> Flow (Either Text ())
cancel url req = do
  res <- callAPI url (API.cancel req) "cancel"
  case res of
    Left err -> L.logError @Text "error occurred while cancel trip: " (show err)
    Right _ -> L.logInfo @Text "Cancel" "Cancel successfully delivered"
  return $ first show res

status :: BaseUrl -> Status.StatusReq -> Flow (Either Text ())
status url req = do
  res <- callAPI url (API.status req) "status"
  case res of
    Left err -> L.logError @Text "error occurred while getting status: " (show err)
    Right _ -> L.logInfo @Text "Status" "Status successfully delivered"
  return $ first show res

getGatewayBaseUrl :: Flow BaseUrl
getGatewayBaseUrl = L.runIO $ do
  host <- fromMaybe "localhost" <$> lookupEnv "BECKN_GATEWAY_HOST"
  port <- fromMaybe 8015 . (>>= readMaybe) <$> lookupEnv "BECKN_GATEWAY_PORT"
  path <- fromMaybe "/v1" <$> lookupEnv "BECKN_GATEWAY_PATH"
  return $
    BaseUrl Http host port path

getProviderBaseUrl :: Flow BaseUrl
getProviderBaseUrl = L.runIO $ do
  host <- fromMaybe "localhost" <$> lookupEnv "BECKN_PROVIDER_HOST"
  port <- fromMaybe 8014 . (>>= readMaybe) <$> lookupEnv "BECKN_PROVIDER_PORT"
  path <- fromMaybe "/v1" <$> lookupEnv "BECKN_PROVIDER_PATH"
  return $
    BaseUrl Http host port path
