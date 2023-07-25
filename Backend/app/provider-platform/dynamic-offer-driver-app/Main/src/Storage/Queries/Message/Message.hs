{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Storage.Queries.Message.Message where

import qualified Data.Time as T
import Domain.Types.Merchant (Merchant)
import Domain.Types.Message.Message
import Domain.Types.Message.MessageTranslation as DomainMT
import qualified EulerHS.Language as L
import Kernel.Prelude
import Kernel.Types.Id
import Kernel.Types.Logging (Log)
import Lib.Utils (FromTType' (fromTType'), ToTType' (toTType'), createWithKV, findAllWithOptionsKV, findOneWithKV, findOneWithKvInReplica, updateOneWithKV)
import qualified Sequelize as Se
import qualified Storage.Beam.Message.Message as BeamM
import qualified Storage.Queries.Message.MessageTranslation as MT

createMessage :: (L.MonadFlow m, Log m) => Message -> m ()
createMessage message = do
  createWithKV message

create :: (L.MonadFlow m, Log m) => Message -> m ()
create = createWithKV

-- findById :: Transactionable m => Id Message -> m (Maybe RawMessage)
-- findById = Esq.findById

findById :: (L.MonadFlow m, Log m) => Id Message -> m (Maybe RawMessage)
findById (Id messageId) = do
  message <- findOneWithKV [Se.Is BeamM.id $ Se.Eq messageId]
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
            viewCount = viewCount,
            mediaFiles = mediaFiles,
            merchantId = merchantId,
            createdAt = createdAt
          }
    )
      <$> message

findByIdInReplica :: (L.MonadFlow m, Log m) => Id Message -> m (Maybe RawMessage)
findByIdInReplica (Id messageId) = do
  message <- findOneWithKvInReplica [Se.Is BeamM.id $ Se.Eq messageId]
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
            viewCount = viewCount,
            mediaFiles = mediaFiles,
            merchantId = merchantId,
            createdAt = createdAt
          }
    )
      <$> message

findAllWithLimitOffset :: (L.MonadFlow m, Log m) => Maybe Int -> Maybe Int -> Id Merchant -> m [RawMessage]
findAllWithLimitOffset mbLimit mbOffset merchantIdParam = do
  messages <- findAllWithOptionsKV [Se.Is BeamM.merchantId $ Se.Eq (getId merchantIdParam)] (Se.Asc BeamM.createdAt) (Just limitVal) (Just offsetVal)
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
              viewCount = viewCount,
              mediaFiles = mediaFiles,
              merchantId = merchantId,
              createdAt = createdAt
            }
      )
      messages
  where
    limitVal = min (fromMaybe 10 mbLimit) 10
    offsetVal = fromMaybe 0 mbOffset

-- updateMessageLikeCount :: Id Message -> Int -> SqlDB ()
-- updateMessageLikeCount messageId value = do
--   Esq.update $ \msg -> do
--     set msg [MessageLikeCount =. (msg ^. MessageLikeCount) +. val value]

-- updateMessageLikeCount :: (L.MonadFlow m, Log m) => Id Message -> Int -> m (MeshResult())
-- updateMessageLikeCount :: messageId value = do
--   messageObject <- findById messageId
--   likeCount <- mapM DTMM.likeCount messageObject

-- helper
updateMessageLikeCount :: (L.MonadFlow m, Log m) => Id Message -> Int -> m ()
updateMessageLikeCount messageId value = do
  findById messageId >>= \case
    Nothing -> pure ()
    Just msg -> do
      let likeCount = msg.likeCount
      updateOneWithKV
        [Se.Set BeamM.likeCount $ likeCount + value]
        [Se.Is BeamM.id (Se.Eq $ getId messageId)]

updateMessageViewCount :: (L.MonadFlow m, Log m) => Id Message -> Int -> m ()
updateMessageViewCount messageId value = do
  findById messageId >>= \case
    Just msg -> do
      let viewCount = msg.viewCount
      updateOneWithKV
        [Se.Set BeamM.viewCount $ viewCount + value]
        [Se.Is BeamM.id (Se.Eq $ getId messageId)]
    Nothing -> pure ()

-- Esq.update $ \msg -> do
--   set msg [MessageViewCount =. (msg ^. MessageViewCount) +. val value]

instance FromTType' BeamM.Message Message where
  fromTType' BeamM.MessageT {..} = do
    mT' <- MT.findByMessageId (Id id)
    let mT = (\(DomainMT.MessageTranslation _ language_ title_ label_ description_ shortDescription_ createdAt_) -> Domain.Types.Message.Message.MessageTranslation language_ title_ description_ shortDescription_ label_ createdAt_) <$> mT'
    pure $
      Just
        Message
          { id = Id id,
            _type = messageType,
            title = title,
            description = description,
            shortDescription = shortDescription,
            label = label,
            likeCount = likeCount,
            viewCount = viewCount,
            mediaFiles = Id <$> mediaFiles,
            messageTranslations = mT,
            merchantId = Id merchantId,
            createdAt = T.localTimeToUTC T.utc createdAt
          }

instance ToTType' BeamM.Message Message where
  toTType' Message {..} = do
    BeamM.MessageT
      { BeamM.id = getId id,
        BeamM.messageType = _type,
        BeamM.title = title,
        BeamM.description = description,
        BeamM.shortDescription = shortDescription,
        BeamM.label = label,
        BeamM.likeCount = likeCount,
        BeamM.viewCount = viewCount,
        BeamM.mediaFiles = getId <$> mediaFiles,
        BeamM.merchantId = getId merchantId,
        BeamM.createdAt = T.utcToLocalTime T.utc createdAt
      }
