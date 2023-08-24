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
{-# OPTIONS_GHC -Wno-missing-signatures #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Beam.Merchant.MerchantServiceUsageConfig where

import Data.ByteString.Internal (ByteString)
import Data.Serialize
import qualified Data.Text as T
import qualified Data.Time as Time
import qualified Data.Vector as V
import qualified Database.Beam as B
import Database.Beam.Backend
import Database.Beam.MySQL ()
import Database.Beam.Postgres
  ( Postgres,
  )
import Database.PostgreSQL.Simple.FromField (FromField, fromField)
import qualified Database.PostgreSQL.Simple.FromField as DPSF
import EulerHS.KVConnector.Types (KVConnector (..), MeshMeta (..), primaryKey, secondaryKeys, tableName)
import GHC.Generics (Generic)
import Kernel.Beam.Lib.UtilsTH
import Kernel.External.Call.Types (CallService)
import Kernel.External.Maps.Types
import Kernel.External.Notification.Types (NotificationService)
import Kernel.External.SMS (SmsService)
import Kernel.External.Ticket.Types (IssueTicketService)
import Kernel.External.Whatsapp.Types (WhatsappService)
import Kernel.Prelude hiding (Generic)
import Kernel.Types.Common hiding (id)
import Lib.Utils ()
import Sequelize

fromFieldSmsService ::
  DPSF.Field ->
  Maybe ByteString ->
  DPSF.Conversion [SmsService]
fromFieldSmsService f mbValue = case mbValue of
  Nothing -> DPSF.returnError DPSF.UnexpectedNull f mempty
  Just _ -> V.toList <$> fromField f mbValue

fromFieldWhatsappService ::
  DPSF.Field ->
  Maybe ByteString ->
  DPSF.Conversion [WhatsappService]
fromFieldWhatsappService f mbValue = case mbValue of
  Nothing -> DPSF.returnError DPSF.UnexpectedNull f mempty
  Just _ -> V.toList <$> fromField f mbValue

instance FromField NotificationService where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be NotificationService where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be NotificationService

instance FromBackendRow Postgres NotificationService

instance IsString NotificationService where
  fromString = show

instance FromField MapsService where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be MapsService where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be MapsService

instance FromBackendRow Postgres MapsService

instance IsString MapsService where
  fromString = show

instance FromField [WhatsappService] where
  fromField = fromFieldWhatsappService

instance FromField WhatsappService where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be (V.Vector Text) => HasSqlValueSyntax be [WhatsappService] where
  sqlValueSyntax x = sqlValueSyntax (V.fromList (T.pack . show <$> x))

instance BeamSqlBackend be => B.HasSqlEqualityCheck be [WhatsappService]

instance FromBackendRow Postgres [WhatsappService]

instance FromField [SmsService] where
  fromField = fromFieldSmsService

instance FromField SmsService where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be (V.Vector Text) => HasSqlValueSyntax be [SmsService] where
  sqlValueSyntax x = sqlValueSyntax (V.fromList (T.pack . show <$> x))

instance BeamSqlBackend be => B.HasSqlEqualityCheck be [SmsService]

instance FromBackendRow Postgres [SmsService]

instance FromField IssueTicketService where
  fromField = fromFieldEnum

instance HasSqlValueSyntax be String => HasSqlValueSyntax be IssueTicketService where
  sqlValueSyntax = autoSqlValueSyntax

instance BeamSqlBackend be => B.HasSqlEqualityCheck be IssueTicketService

instance FromBackendRow Postgres IssueTicketService

instance IsString IssueTicketService where
  fromString = show

data MerchantServiceUsageConfigT f = MerchantServiceUsageConfigT
  { merchantId :: B.C f Text,
    initiateCall :: B.C f CallService,
    getDistances :: B.C f MapsService,
    getRoutes :: B.C f MapsService,
    snapToRoad :: B.C f MapsService,
    getPlaceName :: B.C f MapsService,
    getPickupRoutes :: B.C f MapsService,
    getTripRoutes :: B.C f MapsService,
    getPlaceDetails :: B.C f MapsService,
    autoComplete :: B.C f MapsService,
    getDistancesForCancelRide :: B.C f MapsService,
    notifyPerson :: B.C f NotificationService,
    useFraudDetection :: B.C f Bool,
    smsProvidersPriorityList :: B.C f [SmsService],
    whatsappProvidersPriorityList :: B.C f [WhatsappService],
    issueTicketService :: B.C f IssueTicketService,
    enableDashboardSms :: B.C f Bool,
    getExophone :: B.C f CallService,
    updatedAt :: B.C f Time.UTCTime,
    createdAt :: B.C f Time.UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table MerchantServiceUsageConfigT where
  data PrimaryKey MerchantServiceUsageConfigT f
    = Id (B.C f Text)
    deriving (Generic, B.Beamable)
  primaryKey = Id . merchantId

type MerchantServiceUsageConfig = MerchantServiceUsageConfigT Identity

merchantServiceUsageConfigTMod :: MerchantServiceUsageConfigT (B.FieldModification (B.TableField MerchantServiceUsageConfigT))
merchantServiceUsageConfigTMod =
  B.tableModification
    { merchantId = B.fieldNamed "merchant_id",
      initiateCall = B.fieldNamed "initiate_call",
      getDistances = B.fieldNamed "get_distances",
      getRoutes = B.fieldNamed "get_routes",
      snapToRoad = B.fieldNamed "snap_to_road",
      getPlaceName = B.fieldNamed "get_place_name",
      getPickupRoutes = B.fieldNamed "get_pickup_routes",
      getTripRoutes = B.fieldNamed "get_trip_routes",
      getPlaceDetails = B.fieldNamed "get_place_details",
      autoComplete = B.fieldNamed "auto_complete",
      getDistancesForCancelRide = B.fieldNamed "get_distances_for_cancel_ride",
      notifyPerson = B.fieldNamed "notify_person",
      useFraudDetection = B.fieldNamed "use_fraud_detection",
      smsProvidersPriorityList = B.fieldNamed "sms_providers_priority_list",
      whatsappProvidersPriorityList = B.fieldNamed "whatsapp_providers_priority_list",
      issueTicketService = B.fieldNamed "issue_ticket_service",
      enableDashboardSms = B.fieldNamed "enable_dashboard_sms",
      getExophone = B.fieldNamed "get_exophone",
      updatedAt = B.fieldNamed "updated_at",
      createdAt = B.fieldNamed "created_at"
    }

$(enableKVPG ''MerchantServiceUsageConfigT ['merchantId] [])

$(mkTableInstances ''MerchantServiceUsageConfigT "merchant_service_usage_config" "atlas_app")
