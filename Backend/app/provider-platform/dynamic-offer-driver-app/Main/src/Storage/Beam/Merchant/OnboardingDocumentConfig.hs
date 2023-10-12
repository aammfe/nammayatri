{-
  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}

module Storage.Beam.Merchant.OnboardingDocumentConfig where

import qualified Data.Aeson as A
import qualified Database.Beam as B
import qualified Domain.Types.Merchant.OnboardingDocumentConfig as Domain
import Kernel.Prelude
import Kernel.Utils.Common (encodeToText)
import Tools.Beam.UtilsTH

data OnboardingDocumentConfigT f = OnboardingDocumentConfigT
  { merchantOperatingCityId :: B.C f Text,
    documentType :: B.C f Domain.DocumentType,
    checkExtraction :: B.C f Bool,
    checkExpiry :: B.C f Bool,
    supportedVehicleClassesJSON :: B.C f A.Value,
    rcNumberPrefix :: B.C f Text,
    vehicleClassCheckType :: B.C f Domain.VehicleClassCheckType,
    createdAt :: B.C f UTCTime,
    updatedAt :: B.C f UTCTime
  }
  deriving (Generic, B.Beamable)

instance B.Table OnboardingDocumentConfigT where
  data PrimaryKey OnboardingDocumentConfigT f
    = Id (B.C f Text) (B.C f Domain.DocumentType)
    deriving (Generic, B.Beamable)
  primaryKey = Id <$> merchantOperatingCityId <*> documentType

type OnboardingDocumentConfig = OnboardingDocumentConfigT Identity

getConfigJSON :: Domain.SupportedVehicleClasses -> Text
getConfigJSON = \case
  Domain.DLValidClasses cfg -> encodeToText cfg
  Domain.RCValidClasses cfg -> encodeToText cfg

$(enableKVPG ''OnboardingDocumentConfigT ['merchantOperatingCityId, 'documentType] [['merchantOperatingCityId]])

$(mkTableInstances ''OnboardingDocumentConfigT "onboarding_document_configs")
