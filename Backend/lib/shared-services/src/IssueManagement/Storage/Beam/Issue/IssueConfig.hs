{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-incomplete-patterns #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module IssueManagement.Storage.Beam.Issue.IssueConfig where

import qualified Database.Beam as B
import Database.Beam.MySQL ()
import GHC.Generics (Generic)
import IssueManagement.Tools.UtilsTH hiding (Generic)

data IssueConfigT f = IssueConfigT
  { id :: B.C f Text,
    autoMarkIssueResolveDuration :: B.C f Double,
    onAutoMarkIssueResMsgs :: B.C f [Text],
    onCreateIssueMsgs :: B.C f [Text],
    onIssueReopenMsgs :: B.C f [Text],
    onKaptMarkIssueAwtMsgs :: B.C f [Text]
  }
  deriving (Generic, B.Beamable)

instance B.Table IssueConfigT where
  data PrimaryKey IssueConfigT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type IssueConfig = IssueConfigT Identity

$(enableKVPG ''IssueConfigT ['id] [])

$(mkTableInstancesGenericSchema ''IssueConfigT "issue_config")
