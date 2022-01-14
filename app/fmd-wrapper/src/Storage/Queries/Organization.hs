module Storage.Queries.Organization where

import qualified Beckn.Storage.Queries as DB
import Beckn.Types.App as App
import Beckn.Types.Common
import Beckn.Types.Id
import Beckn.Types.Schema
import Database.Beam ((&&.), (==.), (||.))
import qualified Database.Beam as B
import EulerHS.Prelude hiding (id)
import qualified Types.Storage.DB as DB
import qualified Types.Storage.Organization as Org

getDbTable :: (Functor m, HasSchemaName m) => m (B.DatabaseEntity be DB.AppDb (B.TableEntity Org.OrganizationT))
getDbTable =
  DB.organization . DB.appDb <$> getSchemaName

findOrgByApiKey :: DBFlow m r => App.APIKey -> m (Maybe Org.Organization)
findOrgByApiKey apiKey_ = do
  dbTable <- getDbTable
  DB.findOne dbTable predicate
  where
    predicate Org.Organization {..} =
      apiKey ==. B.val_ (Just apiKey_)

listOrganizations ::
  DBFlow m r =>
  Maybe Int ->
  Maybe Int ->
  [Org.OrganizationType] ->
  [Org.Status] ->
  m [Org.Organization]
listOrganizations mlimit moffset oType status_ = do
  dbTable <- getDbTable
  DB.findAll dbTable (B.limit_ limit . B.offset_ offset . B.orderBy_ orderByDesc) (predicate status_)
  where
    complementVal l
      | null l = B.val_ True
      | otherwise = B.val_ False
    limit = toInteger $ fromMaybe 100 mlimit
    offset = toInteger $ fromMaybe 0 moffset
    orderByDesc Org.Organization {..} = B.desc_ createdAt
    predicate pstatus Org.Organization {..} =
      foldl
        (&&.)
        (B.val_ True)
        [ status `B.in_` (B.val_ <$> pstatus) ||. complementVal pstatus,
          _type `B.in_` (B.val_ <$> oType) ||. complementVal oType
        ]

findOrgByShortId :: DBFlow m r => ShortId Org.Organization -> m (Maybe Org.Organization)
findOrgByShortId shortId_ = do
  dbTable <- getDbTable
  DB.findOne dbTable predicate
  where
    predicate Org.Organization {..} = shortId ==. B.val_ shortId_
