{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Storage.Beam.PublicTransportQuote.Stop where

import qualified Data.Time as Time
import qualified Database.Beam as B
import GHC.Generics (Generic)
import Kernel.Prelude hiding (Generic)
import Tools.Beam.UtilsTH

data StopT f = StopT
  { id :: B.C f Text,
    stopName :: B.C f (Maybe Text),
    lat :: B.C f Double,
    lon :: B.C f Double,
    scheduledTime :: B.C f Text,
    createdAt :: B.C f Time.UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table StopT where
  data PrimaryKey StopT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type Stop = StopT Identity

$(enableKVPG ''StopT ['id] [])

$(mkTableInstances ''StopT "public_transport_quote_stop")
