{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-identities #-}

module Storage.Queries.Message.MessageReport where

import qualified Database.Beam as B
import Database.Beam.Postgres
import Domain.Types.Message.Message
import qualified Domain.Types.Message.Message as Msg (Message (id))
import Domain.Types.Message.MessageReport as DTMR
import qualified Domain.Types.Message.MessageTranslation as MTD
import qualified Domain.Types.Person as P
import qualified EulerHS.KVConnector.Flow as KV
import EulerHS.KVConnector.Types
import EulerHS.KVConnector.Utils (meshModelTableEntity)
import qualified EulerHS.Language as L
import qualified Kernel.Beam.Types as KBT
import Kernel.External.Types
import Kernel.Prelude
import Kernel.Types.Common (MonadTime (getCurrentTime))
import Kernel.Types.Id
import Kernel.Types.Logging
import Lib.Utils (setMeshConfig)
import Sequelize
import qualified Sequelize as Se
import qualified Storage.Beam.Message.Message as BeamM
import qualified Storage.Beam.Message.MessageReport as BeamMR
import qualified Storage.Beam.Message.MessageTranslation as BeamMT
import Storage.Beam.Person as BeamP (PersonT (createdAt, id))
import Storage.Queries.Message.Message as QMM hiding (create)
import Storage.Queries.Message.MessageTranslation as QMMT hiding (create)
import qualified Storage.Queries.Person as QP
import Storage.Tabular.Message.Instances ()

createMany :: L.MonadFlow m => [MessageReport] -> m ()
createMany = traverse_ create

create :: L.MonadFlow m => MessageReport -> m (MeshResult ())
create messageReport = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> KV.createWoReturingKVConnector dbConf' updatedMeshConfig (transformDomainMessageReportToBeam messageReport)
    Nothing -> pure (Left $ MKeyNotFound "DB Config not found")

findByDriverIdAndLanguage :: (L.MonadFlow m) => Id P.Driver -> Language -> Maybe Int -> Maybe Int -> m [(MessageReport, RawMessage, Maybe MTD.MessageTranslation)]
findByDriverIdAndLanguage driverId language mbLimit mbOffset = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      let limitVal = min (fromMaybe 10 mbLimit) 10
          offsetVal = fromMaybe 0 mbOffset
      messageReport <- do
        messageReport' <- KV.findAllWithKVConnector dbConf' updatedMeshConfig [Se.Is BeamMR.driverId $ Se.Eq $ getId driverId]
        case messageReport' of
          Left _ -> pure []
          Right result -> pure $ transformBeamMessageReportToDomain <$> result
      message <- do
        message' <-
          KV.findAllWithOptionsKVConnector
            dbConf'
            updatedMeshConfig
            [Se.Is BeamM.id $ Se.In $ getId . DTMR.messageId <$> messageReport]
            (Se.Desc BeamM.createdAt)
            Nothing
            Nothing
        case message' of
          Left _ -> pure []
          Right result -> traverse QMM.transformBeamMessageToDomain result
      let rawMessageFromMessage Message {..} =
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
      messageTranslation <- do
        messageTranslation' <-
          KV.findAllWithOptionsKVConnector
            dbConf'
            updatedMeshConfig
            [ Se.And
                [Se.Is BeamMT.messageId $ Se.In $ getId . Msg.id <$> message, Se.Is BeamMT.language $ Se.Eq language]
            ]
            (Se.Desc BeamMT.createdAt)
            Nothing
            Nothing
        case messageTranslation' of
          Left _ -> pure []
          Right result -> pure $ QMMT.transformBeamMessageTranslationToDomain <$> result
      let messageReportAndMessage = foldl' (getMessageReportAndMessage messageReport) [] message
      let finalResult' = foldl' (getMessageTranslationAndMessage messageTranslation rawMessageFromMessage) [] messageReportAndMessage
      let finalResult = map (\(mr, rm, mt) -> (mr, rm, Just mt)) finalResult'
      pure $ take limitVal (drop offsetVal finalResult)
    Nothing -> pure []
  where
    getMessageReportAndMessage messageReports acc message' =
      let messageeReports' = filter (\messageReport -> messageReport.messageId == message'.id) messageReports
       in acc <> ((\messageReport' -> (messageReport', message')) <$> messageeReports')

    getMessageTranslationAndMessage messageTranslations rawMessageFromMessage acc (msgRep, msg) =
      let messageTranslations' = filter (\messageTranslation' -> messageTranslation'.messageId == msg.id) messageTranslations
       in acc <> ((\messageTranslation' -> (msgRep, rawMessageFromMessage msg, messageTranslation')) <$> messageTranslations')

findByDriverIdMessageIdAndLanguage :: L.MonadFlow m => Id P.Driver -> Id Msg.Message -> Language -> m (Maybe (MessageReport, RawMessage, Maybe MTD.MessageTranslation))
findByDriverIdMessageIdAndLanguage driverId messageId language = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  case dbConf of
    Just _ -> do
      messageReport <- findByMessageIdAndDriverId messageId driverId
      case messageReport of
        Just report -> do
          rawMessage <- QMM.findById messageId
          case rawMessage of
            Just message -> do
              messageTranslation <- QMMT.findByMessageIdAndLanguage messageId language
              pure $ Just (report, message, messageTranslation)
            Nothing -> pure Nothing
        Nothing -> pure Nothing
    Nothing -> pure Nothing

findByMessageIdAndDriverId :: L.MonadFlow m => Id Msg.Message -> Id P.Driver -> m (Maybe MessageReport)
findByMessageIdAndDriverId (Id messageId) (Id driverId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbCOnf' -> either (pure Nothing) (transformBeamMessageReportToDomain <$>) <$> KV.findWithKVConnector dbCOnf' updatedMeshConfig [Se.And [Se.Is BeamMR.messageId $ Se.Eq messageId, Se.Is BeamMR.driverId $ Se.Eq driverId]]
    Nothing -> pure Nothing

findByMessageIdAndStatusWithLimitAndOffset ::
  (L.MonadFlow m, Log m) =>
  Maybe Int ->
  Maybe Int ->
  Id Msg.Message ->
  Maybe DeliveryStatus ->
  m [(MessageReport, P.Person)]
findByMessageIdAndStatusWithLimitAndOffset mbLimit mbOffset (Id messageID) mbDeliveryStatus = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> do
      let limitVal = min (maybe 10 fromIntegral mbLimit) 20
          offsetVal = maybe 0 fromIntegral mbOffset
      messageReport <- do
        messageReport' <-
          KV.findAllWithOptionsKVConnector
            dbConf'
            updatedMeshConfig
            [ Se.And
                ( [Se.Is BeamMR.messageId $ Se.Eq messageID]
                    <> ([Se.Is BeamMR.deliveryStatus $ Se.Eq (fromJust mbDeliveryStatus) | isJust mbDeliveryStatus])
                )
            ]
            (Se.Desc BeamMR.createdAt)
            Nothing
            Nothing
        case messageReport' of
          Left _ -> pure []
          Right result -> pure $ transformBeamMessageReportToDomain <$> result
      person <- do
        person' <-
          KV.findAllWithOptionsKVConnector
            dbConf'
            updatedMeshConfig
            [Se.Is BeamP.id $ Se.In $ getId . DTMR.driverId <$> messageReport]
            (Se.Desc BeamP.createdAt)
            Nothing
            Nothing
        case person' of
          Left _ -> pure []
          Right result -> mapM QP.transformBeamPersonToDomain result
      let personValues = catMaybes person
      let messageOfPerson = foldl' (getMessageOfPerson messageReport) [] personValues
      pure $ take limitVal (drop offsetVal messageOfPerson)
    Nothing -> pure []
  where
    getMessageOfPerson messageReports acc person' =
      let messageReports' = filter (\messageReport -> getId messageReport.driverId == getId person'.id) messageReports
       in acc <> ((\messageReport -> (messageReport, person')) <$> messageReports')

getMessageCountByStatus :: L.MonadFlow m => Id Msg.Message -> DeliveryStatus -> m Int
getMessageCountByStatus (Id messageID) status = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  conn <- L.getOrInitSqlConn (fromJust dbConf)
  case conn of
    Right c -> do
      resp <-
        L.runDB c $
          L.findRow $
            B.select $
              B.aggregate_ (\_ -> B.as_ @Int B.countAll_) $
                B.filter_' (\(BeamMR.MessageReportT {..}) -> messageId B.==?. B.val_ messageID B.&&?. (deliveryStatus B.==?. B.val_ status)) $
                  B.all_ (meshModelTableEntity @BeamMR.MessageReportT @Postgres @(DatabaseWith BeamMR.MessageReportT))
      pure (either (const 0) (fromMaybe 0) resp)
    Left _ -> pure 0

getMessageCountByReadStatus :: L.MonadFlow m => Id Msg.Message -> m Int
getMessageCountByReadStatus (Id messageID) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  conn <- L.getOrInitSqlConn (fromJust dbConf)
  case conn of
    Right c -> do
      resp <-
        L.runDB c $
          L.findRow $
            B.select $
              B.aggregate_ (\_ -> B.as_ @Int B.countAll_) $
                B.filter_' (\(BeamMR.MessageReportT {..}) -> messageId B.==?. B.val_ messageID B.&&?. readStatus B.==?. B.val_ True) $
                  B.all_ (meshModelTableEntity @BeamMR.MessageReportT @Postgres @(DatabaseWith BeamMR.MessageReportT))
      pure (either (const 0) (fromMaybe 0) resp)
    Left _ -> pure 0

updateSeenAndReplyByMessageIdAndDriverId :: (L.MonadFlow m, MonadTime m) => Id Msg.Message -> Id P.Driver -> Bool -> Maybe Text -> m (MeshResult ())
updateSeenAndReplyByMessageIdAndDriverId messageId driverId readStatus reply = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamMR.readStatus readStatus,
          Se.Set BeamMR.reply reply,
          Se.Set BeamMR.updatedAt now
        ]
        [Se.Is BeamMR.messageId $ Se.Eq $ getId messageId, Se.Is BeamMR.driverId $ Se.Eq $ getId driverId]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

updateMessageLikeByMessageIdAndDriverIdAndReadStatus :: (L.MonadFlow m, MonadTime m) => Id Msg.Message -> Id P.Driver -> m ()
updateMessageLikeByMessageIdAndDriverIdAndReadStatus messageId driverId = do
  messageReport <- findByMessageIdAndDriverId messageId driverId
  case messageReport of
    Just report -> do
      let likeStatus = not report.likeStatus
      dbConf <- L.getOption KBT.PsqlDbCfg
      let modelName = Se.modelTableName @BeamMR.MessageReportT
      let updatedMeshConfig = setMeshConfig modelName
      now <- getCurrentTime
      case dbConf of
        Just dbConf' ->
          void $
            KV.updateWoReturningWithKVConnector
              dbConf'
              updatedMeshConfig
              [ Se.Set BeamMR.likeStatus likeStatus,
                Se.Set BeamMR.updatedAt now
              ]
              [Se.And [Se.Is BeamMR.messageId $ Se.Eq $ getId messageId, Se.Is BeamMR.driverId $ Se.Eq $ getId driverId, Se.Is BeamMR.readStatus $ Se.Eq True]]
        Nothing -> pure ()
    Nothing -> pure ()

updateDeliveryStatusByMessageIdAndDriverId :: (L.MonadFlow m, MonadTime m) => Id Msg.Message -> Id P.Driver -> DeliveryStatus -> m (MeshResult ())
updateDeliveryStatusByMessageIdAndDriverId messageId driverId deliveryStatus = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamMR.deliveryStatus deliveryStatus,
          Se.Set BeamMR.updatedAt now
        ]
        [Se.Is BeamMR.messageId $ Se.Eq $ getId messageId, Se.Is BeamMR.driverId $ Se.Eq $ getId driverId]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

deleteByPersonId :: L.MonadFlow m => Id P.Person -> m ()
deleteByPersonId (Id personId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamMR.MessageReportT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' ->
      void $
        KV.deleteWithKVConnector
          dbConf'
          updatedMeshConfig
          [Se.Is BeamMR.driverId (Se.Eq personId)]
    Nothing -> pure ()

transformBeamMessageReportToDomain :: BeamMR.MessageReport -> MessageReport
transformBeamMessageReportToDomain BeamMR.MessageReportT {..} = do
  MessageReport
    { messageId = Id messageId,
      driverId = Id driverId,
      deliveryStatus = deliveryStatus,
      readStatus = readStatus,
      likeStatus = likeStatus,
      reply = reply,
      messageDynamicFields = messageDynamicFields,
      createdAt = createdAt,
      updatedAt = updatedAt
    }

transformDomainMessageReportToBeam :: MessageReport -> BeamMR.MessageReport
transformDomainMessageReportToBeam MessageReport {..} =
  BeamMR.MessageReportT
    { BeamMR.messageId = getId messageId,
      BeamMR.driverId = getId driverId,
      BeamMR.deliveryStatus = deliveryStatus,
      BeamMR.readStatus = readStatus,
      BeamMR.likeStatus = likeStatus,
      BeamMR.reply = reply,
      BeamMR.messageDynamicFields = messageDynamicFields,
      BeamMR.createdAt = createdAt,
      BeamMR.updatedAt = updatedAt
    }
