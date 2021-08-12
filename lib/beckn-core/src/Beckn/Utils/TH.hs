{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Beckn.Utils.TH where

import Data.OpenApi (ToSchema)
import Database.Beam.Backend.SQL (FromBackendRow, HasSqlValueSyntax)
import Database.Beam.Postgres as Posgres
import Database.Beam.Postgres.Syntax (PgValueSyntax)
import Database.Beam.Query (HasSqlEqualityCheck)
import EulerHS.Prelude
import qualified Language.Haskell.TH as TH
import Servant (FromHttpApiData, ToHttpApiData)

-- | A set of instances common for all identifier newtypes.
deriveIdentifierInstances :: TH.Name -> TH.Q [TH.Dec]
deriveIdentifierInstances name = do
  let tyQ = pure (TH.ConT name)
  [d|
    deriving stock instance Eq $tyQ

    deriving stock instance Ord $tyQ

    deriving newtype instance ToJSON $tyQ

    deriving newtype instance FromJSON $tyQ

    deriving newtype instance HasSqlValueSyntax PgValueSyntax $tyQ

    deriving newtype instance FromBackendRow Postgres $tyQ

    deriving newtype instance HasSqlEqualityCheck Postgres $tyQ

    deriving newtype instance ToHttpApiData $tyQ

    deriving newtype instance FromHttpApiData $tyQ

    deriving newtype instance ToSchema $tyQ
    |]
