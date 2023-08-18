{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Beam.Plan where

import Data.Serialize
import qualified Database.Beam as B
import Database.Beam.Backend
import Database.Beam.MySQL ()
import Database.Beam.Postgres
  ( Postgres,
  )
import Database.PostgreSQL.Simple.FromField (FromField, fromField)
import qualified Domain.Types.Plan as Domain
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Beam.Lib.UtilsTH
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common hiding (id)
import Lib.Utils ()
import Sequelize

instance FromField Domain.PaymentMode where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Domain.PaymentMode where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Domain.PaymentMode

instance FromBackendRow Postgres Domain.PaymentMode

instance IsString Domain.PaymentMode where
  fromString = show

instance FromField Domain.PlanBaseAmount where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Domain.PlanBaseAmount where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Domain.PlanBaseAmount

instance FromBackendRow Postgres Domain.PlanBaseAmount

instance IsString Domain.PlanBaseAmount where
  fromString = show

instance FromField Domain.Frequency where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Domain.Frequency where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Domain.Frequency

instance FromBackendRow Postgres Domain.Frequency

instance IsString Domain.Frequency where
  fromString = show

instance FromField Domain.PlanType where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be Domain.PlanType where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be Domain.PlanType

instance FromBackendRow Postgres Domain.PlanType

instance IsString Domain.PlanType where
  fromString = show

data PlanT f = PlanT
  { id :: B.C f Text,
    paymentMode :: B.C f Domain.PaymentMode,
    merchantId :: B.C f Text,
    name :: B.C f Text,
    description :: B.C f Text,
    maxAmount :: B.C f HighPrecMoney,
    registrationAmount :: B.C f HighPrecMoney,
    isOfferApplicable :: B.C f Bool,
    maxCreditLimit :: B.C f HighPrecMoney,
    planBaseAmount :: B.C f Domain.PlanBaseAmount,
    freeRideCount :: B.C f Int,
    frequency :: B.C f Domain.Frequency,
    planType :: B.C f Domain.PlanType
  }
  deriving (Generic, B.Beamable)

instance B.Table PlanT where
  data PrimaryKey PlanT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . id

type Plan = PlanT Identity

deriving stock instance Ord Domain.Frequency

deriving stock instance Ord Domain.PlanType

deriving stock instance Ord Domain.PlanBaseAmount

planTMod :: PlanT (B.FieldModification (B.TableField PlanT))
planTMod =
  B.tableModification
    { id = B.fieldNamed "id",
      paymentMode = B.fieldNamed "payment_mode",
      merchantId = B.fieldNamed "merchant_id",
      name = B.fieldNamed "name",
      description = B.fieldNamed "description",
      maxAmount = B.fieldNamed "max_amount",
      registrationAmount = B.fieldNamed "registration_amount",
      isOfferApplicable = B.fieldNamed "is_offer_applicable",
      maxCreditLimit = B.fieldNamed "max_credit_limit",
      planBaseAmount = B.fieldNamed "plan_base_amount",
      freeRideCount = B.fieldNamed "free_ride_count",
      frequency = B.fieldNamed "frequency",
      planType = B.fieldNamed "plan_type"
    }

$(enableKVPG ''PlanT ['id] [['paymentMode], ['merchantId]]) -- DON'T Enable for KV

$(mkTableInstances ''PlanT "plan" "atlas_driver_offer_bpp")
