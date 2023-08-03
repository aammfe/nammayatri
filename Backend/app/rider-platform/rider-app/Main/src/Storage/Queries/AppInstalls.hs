{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.AppInstalls where

import Domain.Types.AppInstalls as AppInstalls
import qualified EulerHS.Language as L
import Kernel.Beam.Functions
import Kernel.Prelude
import Kernel.Types.Id
import Kernel.Types.Logging
import Kernel.Types.Version
import Kernel.Utils.Version
import qualified Sequelize as Se
import qualified Storage.Beam.AppInstalls as BeamAI

upsert :: (L.MonadFlow m, Log m) => AppInstalls.AppInstalls -> m ()
upsert a@AppInstalls {..} = do
  res <- findOneWithKV [Se.Is BeamAI.id $ Se.Eq (getId a.id)]
  if isJust res
    then
      updateOneWithKV
        [ Se.Set BeamAI.deviceToken deviceToken,
          Se.Set BeamAI.source source,
          Se.Set BeamAI.merchantId $ getId merchantId,
          Se.Set BeamAI.appVersion (versionToText <$> appVersion),
          Se.Set BeamAI.bundleVersion (versionToText <$> bundleVersion),
          Se.Set BeamAI.platform platform,
          Se.Set BeamAI.updatedAt updatedAt
        ]
        [Se.Is BeamAI.id (Se.Eq $ getId id)]
    else createWithKV a

instance FromTType' BeamAI.AppInstalls AppInstalls where
  fromTType' BeamAI.AppInstallsT {..} = do
    bundleVersion' <- forM bundleVersion readVersion
    appVersion' <- forM appVersion readVersion
    pure $
      Just
        AppInstalls
          { id = Id id,
            deviceToken = deviceToken,
            source = source,
            merchantId = Id merchantId,
            appVersion = appVersion',
            bundleVersion = bundleVersion',
            platform = platform,
            createdAt = createdAt,
            updatedAt = updatedAt
          }

instance ToTType' BeamAI.AppInstalls AppInstalls where
  toTType' AppInstalls {..} = do
    BeamAI.AppInstallsT
      { BeamAI.id = getId id,
        BeamAI.deviceToken = deviceToken,
        BeamAI.source = source,
        BeamAI.merchantId = getId merchantId,
        BeamAI.appVersion = versionToText <$> appVersion,
        BeamAI.bundleVersion = versionToText <$> bundleVersion,
        BeamAI.platform = platform,
        BeamAI.createdAt = createdAt,
        BeamAI.updatedAt = updatedAt
      }
