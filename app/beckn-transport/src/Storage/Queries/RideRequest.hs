module Storage.Queries.RideRequest where

import App.Types (AppEnv (dbCfg), Flow)
import qualified Beckn.Storage.Common as Storage
import qualified Beckn.Storage.Queries as DB
import Beckn.Types.Id
import Beckn.Types.Schema
import Database.Beam ((==.))
import qualified Database.Beam as B
import EulerHS.Prelude hiding (id)
import qualified Types.Storage.DB as DB
import qualified Types.Storage.RideRequest as RideRequest

getDbTable :: (HasSchemaName m, Functor m) => m (B.DatabaseEntity be DB.TransporterDb (B.TableEntity RideRequest.RideRequestT))
getDbTable =
  DB._rideRequest . DB.transporterDb <$> getSchemaName

createFlow :: RideRequest.RideRequest -> Flow ()
createFlow =
  DB.runSqlDB . create

create :: RideRequest.RideRequest -> DB.SqlDB ()
create rideRequest = do
  dbTable <- getDbTable
  DB.createOne' dbTable (Storage.insertExpression rideRequest)

fetchOldest :: Integer -> Flow [RideRequest.RideRequest]
fetchOldest limit = do
  dbTable <- getDbTable
  let order RideRequest.RideRequest {..} = B.asc_ _createdAt
  DB.findAll dbTable (B.limit_ limit . B.orderBy_ order) (const $ B.val_ True)

removeRequest :: Id RideRequest.RideRequest -> Flow ()
removeRequest requestId = do
  dbTable <- getDbTable
  DB.delete dbTable (predicate requestId)
  where
    predicate id RideRequest.RideRequest {..} = _id ==. B.val_ id
