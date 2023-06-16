{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Storage.Queries.Message.Message where

-- import qualified Kernel.Storage.Esqueleto as Esq

import qualified Data.Time as T
import Domain.Types.Merchant (Merchant)
import Domain.Types.Message.Message
import Domain.Types.Message.MessageTranslation as DomainMT
import qualified EulerHS.KVConnector.Flow as KV
import EulerHS.KVConnector.Types
import qualified EulerHS.Language as L
import qualified Kernel.Beam.Types as KBT
import Kernel.Prelude
import Kernel.Types.Id
import Lib.Utils (setMeshConfig)
import qualified Sequelize as Se
import qualified Storage.Beam.Message.Message as BeamM
import qualified Storage.Queries.Message.MessageTranslation as MT
import Storage.Tabular.Message.Instances ()

createMessage :: L.MonadFlow m => Message -> m (MeshResult ())
createMessage message = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamM.MessageT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> KV.createWoReturingKVConnector dbConf' updatedMeshConfig (transformDomainMessageToBeam message)
    Nothing -> pure (Left $ MKeyNotFound "DB Config not found")

create :: L.MonadFlow m => Message -> m ()
create msg = do
  _ <- createMessage msg
  let mT' = map (\(Domain.Types.Message.Message.MessageTranslation language_ title_ description_ shortDescription_ label_ createdAt_) -> DomainMT.MessageTranslation msg.id language_ title_ label_ description_ shortDescription_ createdAt_) msg.messageTranslations
  traverse_ MT.create mT'

-- findById :: Transactionable m => Id Message -> m (Maybe RawMessage)
-- findById = Esq.findById

findById :: L.MonadFlow m => Id Message -> m (Maybe RawMessage)
findById (Id messageId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamM.MessageT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      result <- KV.findWithKVConnector dbConf' updatedMeshConfig [Se.Is BeamM.id $ Se.Eq messageId]
      case result of
        Right msg -> do
          msg' <- traverse transformBeamMessageToDomain msg
          pure $
            ( \Message {..} ->
                RawMessage
                  { id = id,
                    _type = _type,
                    title = title,
                    description = description,
                    shortDescription = shortDescription,
                    label = label,
                    likeCount = likeCount,
                    mediaFiles = mediaFiles,
                    merchantId = merchantId,
                    createdAt = createdAt
                  }
            )
              <$> msg'
        Left _ -> pure Nothing
    Nothing -> pure Nothing

findAllWithLimitOffset :: L.MonadFlow m => Maybe Int -> Maybe Int -> Id Merchant -> m [RawMessage]
findAllWithLimitOffset mbLimit mbOffset merchantIdParam = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamM.MessageT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      srsz <- KV.findAllWithOptionsKVConnector dbConf' updatedMeshConfig [Se.Is BeamM.merchantId $ Se.Eq (getId merchantIdParam)] (Se.Asc BeamM.createdAt) (Just limitVal) (Just offsetVal)
      case srsz of
        Left _ -> pure []
        Right x -> do
          msg <- traverse transformBeamMessageToDomain x
          pure $
            map
              ( \Message {..} ->
                  RawMessage
                    { id = id,
                      _type = _type,
                      title = title,
                      description = description,
                      shortDescription = shortDescription,
                      label = label,
                      likeCount = likeCount,
                      mediaFiles = mediaFiles,
                      merchantId = merchantId,
                      createdAt = createdAt
                    }
              )
              msg
    Nothing -> pure []
  where
    limitVal = min (fromMaybe 10 mbLimit) 10
    offsetVal = fromMaybe 0 mbOffset

-- updateMessageLikeCount :: Id Message -> Int -> SqlDB ()
-- updateMessageLikeCount messageId value = do
--   Esq.update $ \msg -> do
--     set msg [MessageLikeCount =. (msg ^. MessageLikeCount) +. val value]
--     where_ $ msg ^. MessageId ==. val (getId messageId)

-- updateMessageLikeCount :: L.MonadFlow m => Id Message -> Int -> m (MeshResult())
-- updateMessageLikeCount :: messageId value = do
--   messageObject <- findById messageId
--   likeCount <- mapM DTMM.likeCount messageObject

-- helper
updateMessageLikeCount :: L.MonadFlow m => Id Message -> Int -> m ()
updateMessageLikeCount messageId value = do
  messageObject <- findById messageId
  case messageObject of
    Just msg -> do
      let likeCount = msg.likeCount
      dbConf <- L.getOption KBT.PsqlDbCfg
      let modelName = Se.modelTableName @BeamM.MessageT
      let updatedMeshConfig = setMeshConfig modelName
      case dbConf of
        Just dbConf' ->
          void $
            KV.updateWoReturningWithKVConnector
              dbConf'
              updatedMeshConfig
              [Se.Set BeamM.likeCount $ likeCount + value]
              [Se.Is BeamM.id (Se.Eq $ getId messageId)]
        Nothing -> pure ()
    Nothing -> pure ()

transformBeamMessageToDomain :: L.MonadFlow m => BeamM.Message -> m Message
transformBeamMessageToDomain BeamM.MessageT {..} = do
  mT' <- MT.findByMessageId (Id id)
  let mT = (\(DomainMT.MessageTranslation _ language_ title_ label_ description_ shortDescription_ createdAt_) -> Domain.Types.Message.Message.MessageTranslation language_ title_ description_ shortDescription_ label_ createdAt_) <$> mT'
  pure
    Message
      { id = Id id,
        _type = messageType,
        title = title,
        description = description,
        shortDescription = shortDescription,
        label = label,
        likeCount = likeCount,
        mediaFiles = Id <$> mediaFiles,
        messageTranslations = mT,
        merchantId = Id merchantId,
        createdAt = T.localTimeToUTC T.utc createdAt
      }

transformDomainMessageToBeam :: Message -> BeamM.Message
transformDomainMessageToBeam Message {..} =
  BeamM.MessageT
    { BeamM.id = getId id,
      BeamM.messageType = _type,
      BeamM.title = title,
      BeamM.description = description,
      BeamM.shortDescription = shortDescription,
      BeamM.label = label,
      BeamM.likeCount = likeCount,
      BeamM.mediaFiles = getId <$> mediaFiles,
      BeamM.merchantId = getId merchantId,
      BeamM.createdAt = T.utcToLocalTime T.utc createdAt
    }
