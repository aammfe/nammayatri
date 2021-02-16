module Product.Services.GoogleMaps where

import App.Types (AppEnv (..), FlowHandler)
import qualified Beckn.External.GoogleMaps.Client as ClientGoogleMaps
import qualified Beckn.External.GoogleMaps.Types as GoogleMaps
import qualified Beckn.Types.Storage.Person as Person
import Beckn.Utils.Common (withFlowHandler)
import EulerHS.Prelude

autoComplete :: Person.Person -> Text -> Text -> Integer -> FlowHandler GoogleMaps.SearchLocationResp
autoComplete _auth input location radius = withFlowHandler $ do
  url <- googleMapsUrl <$> ask
  apiKey <- googleMapsKey <$> ask
  let components = "country:in"
  ClientGoogleMaps.autoComplete url apiKey input location radius components

placeDetails :: Person.Person -> Text -> FlowHandler GoogleMaps.PlaceDetailsResp
placeDetails _auth placeId = withFlowHandler $ do
  url <- googleMapsUrl <$> ask
  apiKey <- googleMapsKey <$> ask
  let fields = "geometry"
  ClientGoogleMaps.placeDetails url apiKey placeId fields

getPlaceName :: Person.Person -> Text -> FlowHandler GoogleMaps.GetPlaceNameResp
getPlaceName _auth latLng = withFlowHandler $ do
  url <- googleMapsUrl <$> ask
  apiKey <- googleMapsKey <$> ask
  ClientGoogleMaps.getPlaceName url latLng apiKey
