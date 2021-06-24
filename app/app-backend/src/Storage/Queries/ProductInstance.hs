module Storage.Queries.ProductInstance where

import qualified Beckn.Storage.Common as Storage
import Beckn.Storage.DB.Config
import qualified Beckn.Storage.Queries as DB
import Beckn.Types.Common hiding (id)
import Beckn.Types.Id
import Beckn.Types.Schema
import qualified Beckn.Types.Storage.Case as Case
import qualified Beckn.Types.Storage.Person as Person
import qualified Beckn.Types.Storage.ProductInstance as Storage
import Beckn.Types.Storage.Products
import Beckn.Utils.Common
import Data.Time (UTCTime)
import Database.Beam ((&&.), (<-.), (==.), (||.))
import qualified Database.Beam as B
import EulerHS.Prelude hiding (id)
import qualified Types.Storage.DB as DB

getDbTable :: (HasSchemaName m, Functor m) => m (B.DatabaseEntity be DB.AppDb (B.TableEntity Storage.ProductInstanceT))
getDbTable = DB.productInstance . DB.appDb <$> getSchemaName

createFlow :: DBFlow m r => Storage.ProductInstance -> m ()
createFlow = DB.runSqlDB . create

create :: Storage.ProductInstance -> DB.SqlDB ()
create productInstance = do
  dbTable <- getDbTable
  DB.createOne' dbTable (Storage.insertExpression productInstance)

findById :: DBFlow m r => Id Storage.ProductInstance -> m (Maybe Storage.ProductInstance)
findById pid = do
  dbTable <- getDbTable
  DB.findOne dbTable (predicate pid)
  where
    predicate piid Storage.ProductInstance {..} = id ==. B.val_ piid

findAllByCaseId :: DBFlow m r => Id Case.Case -> m [Storage.ProductInstance]
findAllByCaseId caseId_ = do
  dbTable <- getDbTable
  DB.findAll dbTable identity predicate
  where
    predicate Storage.ProductInstance {..} =
      caseId ==. B.val_ caseId_

findByProductId :: DBFlow m r => Id Products -> m (Maybe Storage.ProductInstance)
findByProductId pId = do
  dbTable <- getDbTable
  DB.findOne dbTable predicate
  where
    predicate Storage.ProductInstance {..} =
      productId ==. B.val_ pId

findAllByPerson :: DBFlow m r => Id Person.Person -> m [Storage.ProductInstance]
findAllByPerson perId = do
  dbTable <- getDbTable
  DB.findAll dbTable identity predicate
  where
    predicate Storage.ProductInstance {..} = personId ==. B.val_ (Just perId)

updateCaseId ::
  DBFlow m r =>
  Id Storage.ProductInstance ->
  Id Case.Case ->
  m ()
updateCaseId piId caseId_ = do
  dbTable <- getDbTable
  (currTime :: UTCTime) <- getCurrentTime
  DB.update
    dbTable
    (setClause caseId_ currTime)
    (predicate piId)
  where
    predicate piid Storage.ProductInstance {..} = id ==. B.val_ piid
    setClause cid currTime Storage.ProductInstance {..} =
      mconcat
        [ updatedAt <-. B.val_ currTime,
          caseId <-. B.val_ cid
        ]

updateStatus ::
  DBFlow m r =>
  Id Storage.ProductInstance ->
  Storage.ProductInstanceStatus ->
  m ()
updateStatus piId status_ = do
  dbTable <- getDbTable
  (currTime :: UTCTime) <- getCurrentTime
  DB.update
    dbTable
    (setClause status_ currTime)
    (predicate piId)
  where
    predicate piid Storage.ProductInstance {..} = id ==. B.val_ piid
    setClause scStatus currTime Storage.ProductInstance {..} =
      mconcat
        [ updatedAt <-. B.val_ currTime,
          status <-. B.val_ scStatus
        ]

updateAllProductInstancesByCaseId ::
  DBFlow m r =>
  Id Case.Case ->
  Storage.ProductInstanceStatus ->
  m ()
updateAllProductInstancesByCaseId caseId_ status_ = do
  dbTable <- getDbTable
  (currTime :: UTCTime) <- getCurrentTime
  DB.update
    dbTable
    (setClause status_ currTime)
    (predicate caseId_)
  where
    predicate cid Storage.ProductInstance {..} = caseId ==. B.val_ cid
    setClause scStatus currTime Storage.ProductInstance {..} =
      mconcat
        [ updatedAt <-. B.val_ currTime,
          status <-. B.val_ scStatus
        ]

listAllProductInstanceWithOffset ::
  DBFlow m r =>
  Integer ->
  Integer ->
  Storage.ListById ->
  [Storage.ProductInstanceStatus] ->
  [Case.CaseType] ->
  m [Storage.ProductInstance]
listAllProductInstanceWithOffset limit offset lbid stats csTypes = do
  dbTable <- getDbTable
  DB.findAll dbTable (B.limit_ limit . B.offset_ offset . B.orderBy_ orderBy) (predicate lbid stats)
  where
    predicate (Storage.ByApplicationId i) s Storage.ProductInstance {..} =
      caseId ==. B.val_ i
        &&. (status `B.in_` (B.val_ <$> s) ||. complementVal s)
        &&. (_type `B.in_` (B.val_ <$> csTypes) ||. complementVal csTypes)
    predicate (Storage.ByCustomerId i) s Storage.ProductInstance {..} =
      personId ==. B.val_ (Just i)
        &&. (status `B.in_` (B.val_ <$> s) ||. complementVal s)
        &&. (_type `B.in_` (B.val_ <$> csTypes) ||. complementVal csTypes)
    predicate (Storage.ById i) s Storage.ProductInstance {..} =
      productId ==. B.val_ i
        &&. (status `B.in_` (B.val_ <$> s) ||. complementVal s)
        &&. (_type `B.in_` (B.val_ <$> csTypes) ||. complementVal csTypes)
    orderBy Storage.ProductInstance {..} = B.desc_ updatedAt

listAllProductInstance ::
  DBFlow m r =>
  Storage.ListById ->
  [Storage.ProductInstanceStatus] ->
  m [Storage.ProductInstance]
listAllProductInstance piId status_ = do
  dbTable <- getDbTable
  DB.findAll dbTable identity (predicate piId status_)
  where
    predicate (Storage.ByApplicationId i) [] Storage.ProductInstance {..} = caseId ==. B.val_ i
    predicate (Storage.ByApplicationId i) s Storage.ProductInstance {..} = caseId ==. B.val_ i &&. B.in_ status (B.val_ <$> s)
    predicate (Storage.ByCustomerId i) [] Storage.ProductInstance {..} = personId ==. B.val_ (Just i)
    predicate (Storage.ByCustomerId i) s Storage.ProductInstance {..} = personId ==. B.val_ (Just i) &&. B.in_ status (B.val_ <$> s)
    predicate (Storage.ById i) [] Storage.ProductInstance {..} = productId ==. B.val_ i
    predicate (Storage.ById i) s Storage.ProductInstance {..} = productId ==. B.val_ i &&. B.in_ status (B.val_ <$> s)

updateMultipleFlow ::
  DBFlow m r =>
  Id Storage.ProductInstance ->
  Storage.ProductInstance ->
  m ()
updateMultipleFlow id prdInst = DB.runSqlDB (updateMultiple id prdInst)

updateMultiple :: Id Storage.ProductInstance -> Storage.ProductInstance -> DB.SqlDB ()
updateMultiple piId prdInst = do
  dbTable <- getDbTable
  currTime <- asks DB.currentTime
  DB.update' dbTable (setClause currTime prdInst) (predicate piId)
  where
    predicate piid Storage.ProductInstance {..} = id ==. B.val_ piid
    setClause now prodInst Storage.ProductInstance {..} =
      mconcat
        [ updatedAt <-. B.val_ now,
          status <-. B.val_ (Storage.status prodInst),
          --personId <-. B.val_ (Storage.personId prd),
          fromLocation <-. B.val_ (Storage.fromLocation prodInst),
          toLocation <-. B.val_ (Storage.toLocation prodInst),
          info <-. B.val_ (Storage.info prodInst),
          udf4 <-. B.val_ (Storage.udf4 prodInst)
        ]

findByParentIdType ::
  DBFlow m r =>
  Id Storage.ProductInstance ->
  Case.CaseType ->
  m (Maybe Storage.ProductInstance)
findByParentIdType mparentId csType = do
  dbTable <- getDbTable
  DB.findOne dbTable predicate
  where
    predicate Storage.ProductInstance {..} =
      parentId ==. B.val_ (Just mparentId)
        &&. _type ==. B.val_ csType

findAllByParentId ::
  DBFlow m r =>
  Id Storage.ProductInstance ->
  m [Storage.ProductInstance]
findAllByParentId piId = do
  dbTable <- getDbTable
  DB.findAll dbTable identity (predicate piId)
  where
    predicate piid Storage.ProductInstance {..} = parentId ==. B.val_ (Just piid)

complementVal :: (Container t, B.SqlValable p, B.HaskellLiteralForQExpr p ~ Bool) => t -> p
complementVal l
  | null l = B.val_ True
  | otherwise = B.val_ False

findAllExpiredByStatus ::
  DBFlow m r =>
  [Storage.ProductInstanceStatus] ->
  UTCTime ->
  m [Storage.ProductInstance]
findAllExpiredByStatus statuses expiryTime = do
  dbTable <- getDbTable
  DB.findAll dbTable identity predicate
  where
    predicate Storage.ProductInstance {..} =
      B.in_ status (B.val_ <$> statuses)
        &&. startTime B.<=. B.val_ expiryTime
