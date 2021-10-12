{-# LANGUAGE NamedWildCards #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# OPTIONS_GHC -Wno-partial-type-signatures #-}

module Beckn.Storage.Common
  ( insertValue,
    insertValues,
    prepareDBConnections,
    getOrInitConn,
    insertExpression,
  )
where

import Beckn.Storage.DB.Config
import Beckn.Utils.Common
import qualified Database.Beam as B
import Database.Beam.Postgres
import qualified EulerHS.Language as L
import EulerHS.Prelude
import qualified EulerHS.Types as T

insertValue ::
  _ =>
  table B.Identity ->
  B.SqlInsertValues Postgres (table (B.QExpr Postgres s))
insertValue value = B.insertValues [value]

insertValues ::
  _ =>
  [table B.Identity] ->
  B.SqlInsertValues Postgres (table (B.QExpr Postgres s))
insertValues = B.insertValues

insertExpression ::
  (B.Beamable table) =>
  (forall s'. table (B.QExpr Postgres s')) ->
  B.SqlInsertValues Postgres (table (B.QExpr Postgres s))
insertExpression value = B.insertExpressions [value]

handleIt ::
  DBFlow m r =>
  (T.DBConfig Pg -> m (T.DBResult (T.SqlConn Pg))) ->
  m (T.DBResult (T.SqlConn Pg))
handleIt mf = do
  cfg <- asks (.dbCfg)
  mf $ repack cfg
  where
    repack (DBConfig x y z _) = T.mkPostgresPoolConfig x y z

prepareDBConnections :: DBFlow m r => m (T.DBResult (T.SqlConn Pg))
prepareDBConnections = handleIt L.initSqlDBConnection

getOrInitConn :: DBFlow m r => m (T.SqlConn Pg)
getOrInitConn = handleIt L.getOrInitSqlConn >>= checkDBError
