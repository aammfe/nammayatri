module Domain.Action.UI.Search.Rental where

import App.Types
import Beckn.Serviceability
import qualified Beckn.Storage.Esqueleto as DB
import Beckn.Types.Common hiding (id)
import Beckn.Types.Id
import qualified Domain.Action.UI.Search.Common as DSearch
import qualified Domain.Types.Person as Person
import qualified Domain.Types.SearchRequest as DSearchReq
import EulerHS.Prelude hiding (id, state)
import Storage.Queries.Geometry
import qualified Storage.Queries.Merchant as QMerchant
import qualified Storage.Queries.Person as QPerson
import qualified Storage.Queries.SearchRequest as QSearchRequest
import qualified Tools.Metrics as Metrics
import qualified Types.API.Search as API
import Types.Error
import Utils.Common

data DSearchReq = DSearchReq
  { origin :: API.SearchReqLocation,
    searchId :: Id DSearchReq.SearchRequest,
    startTime :: UTCTime,
    --TODO: This supposed to be temporary solution. Check if we still need it
    gatewayUrl :: BaseUrl
  }

search :: Id Person.Person -> API.RentalSearchReq -> Flow (API.SearchRes, DSearchReq)
search personId req = do
  person <- QPerson.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  merchant <-
    QMerchant.findById person.merchantId
      >>= fromMaybeM (MerchantNotFound person.merchantId.getId)
  validateServiceability merchant.geofencingConfig
  fromLocation <- DSearch.buildSearchReqLoc req.origin
  now <- getCurrentTime
  searchRequest <- DSearch.buildSearchRequest person fromLocation Nothing Nothing now
  Metrics.incrementSearchRequestCount
  let txnId = getId (searchRequest.id)
  Metrics.startSearchMetrics txnId
  DB.runTransaction $ do
    QSearchRequest.create searchRequest
  let dSearchReq =
        DSearchReq
          { origin = req.origin,
            searchId = searchRequest.id,
            startTime = req.startTime,
            gatewayUrl = merchant.gatewayUrl
          }
  return (API.SearchRes $ searchRequest.id, dSearchReq)
  where
    validateServiceability geoConfig = do
      unlessM (rideServiceable geoConfig someGeometriesContain req.origin.gps Nothing) $
        throwError RideNotServiceable
