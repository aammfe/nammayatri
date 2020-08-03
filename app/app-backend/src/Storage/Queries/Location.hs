module Storage.Queries.Location where

import App.Types
import qualified Beckn.Storage.Common as Storage
import qualified Beckn.Storage.Queries as DB
import Beckn.Types.App
import qualified Beckn.Types.Storage.Location as Storage
import Database.Beam ((&&.), (==.), (||.))
import qualified Database.Beam as B
import EulerHS.Prelude hiding (id)
import qualified Types.Storage.DB as DB

dbTable :: B.DatabaseEntity be DB.AppDb (B.TableEntity Storage.LocationT)
dbTable = DB._location DB.appDb

create :: Storage.Location -> Flow ()
create Storage.Location {..} =
  DB.createOne dbTable (Storage.insertExpression Storage.Location {..})
    >>= either DB.throwDBError pure

findLocationById ::
  LocationId -> Flow (Maybe Storage.Location)
findLocationById id =
  DB.findOne dbTable predicate
    >>= either DB.throwDBError pure
  where
    predicate Storage.Location {..} = _id ==. B.val_ id

findAllWithLimitOffsetWhere :: [Text] -> [Text] -> [Text] -> [Text] -> [Text] -> Maybe Int -> Maybe Int -> Flow [Storage.Location]
findAllWithLimitOffsetWhere pins cities states districts wards mlimit moffset =
  DB.findAllWithLimitOffsetWhere
    dbTable
    predicate
    limit
    offset
    orderByDesc
    >>= either DB.throwDBError pure
  where
    limit = toInteger $ fromMaybe 100 mlimit
    offset = toInteger $ fromMaybe 0 moffset
    orderByDesc Storage.Location {..} = B.desc_ _createdAt
    predicate Storage.Location {..} =
      foldl
        (&&.)
        (B.val_ True)
        [ _pincode `B.in_` (B.val_ . Just <$> pins) ||. complementVal pins,
          _city `B.in_` (B.val_ . Just <$> cities) ||. complementVal cities,
          _state `B.in_` (B.val_ . Just <$> states) ||. complementVal states,
          _district `B.in_` (B.val_ . Just <$> districts) ||. complementVal districts,
          _ward `B.in_` (B.val_ . Just <$> wards) ||. complementVal wards
        ]

complementVal :: (Container t, B.SqlValable p, B.HaskellLiteralForQExpr p ~ Bool) => t -> p
complementVal l
  | null l = B.val_ True
  | otherwise = B.val_ False

findAllByIds :: [Text] -> Flow [Storage.Location]
findAllByIds locIds =
  DB.findAllOrErr dbTable (predicate (LocationId <$> locIds))
  where
    predicate locationIds Storage.Location {..} =
      B.in_ _id (B.val_ <$> locationIds)
