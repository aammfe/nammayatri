{-# OPTIONS_GHC -Wno-orphans #-}

module IssueManagement.Storage.Queries.Issue.IssueReport where

import qualified Data.Time as T
import IssueManagement.Common
import IssueManagement.Domain.Types.Issue.IssueCategory
import IssueManagement.Domain.Types.Issue.IssueOption
import IssueManagement.Domain.Types.Issue.IssueReport as IssueReport
import qualified IssueManagement.Storage.Beam.Issue.IssueReport as BeamIR
import IssueManagement.Storage.BeamFlow
import IssueManagement.Tools.UtilsTH
import Kernel.Types.Id

create :: BeamFlow m => IssueReport.IssueReport -> m ()
create = createWithKV

findAllWithOptions :: BeamFlow m => Maybe Int -> Maybe Int -> Maybe IssueStatus -> Maybe (Id IssueCategory) -> Maybe Text -> m [IssueReport]
findAllWithOptions mbLimit mbOffset mbStatus mbCategoryId mbAssignee =
  findAllWithOptionsKV conditions (Desc BeamIR.createdAt) (Just limitVal) (Just offsetVal)
  where
    limitVal = min (fromMaybe 10 mbLimit) 10
    offsetVal = fromMaybe 0 mbOffset
    conditions =
      [ And $
          catMaybes
            [ fmap (Is BeamIR.status . Eq) mbStatus,
              fmap (Is BeamIR.assignee . Eq . Just) mbAssignee,
              fmap (Is BeamIR.categoryId . Eq . getId) mbCategoryId
            ]
      ]

findById :: BeamFlow m => Id IssueReport -> m (Maybe IssueReport)
findById (Id issueReportId) = findOneWithKV [And [Is BeamIR.id $ Eq issueReportId, Is BeamIR.deleted $ Eq False]]

findAllByPerson :: BeamFlow m => Id Person -> m [IssueReport]
findAllByPerson (Id personId) = findAllWithKV [And [Is BeamIR.personId $ Eq personId, Is BeamIR.deleted $ Eq False]]

safeToDelete :: BeamFlow m => Id IssueReport -> Id Person -> m (Maybe IssueReport)
safeToDelete (Id issueReportId) (Id personId) = findOneWithKV [And [Is BeamIR.id $ Eq issueReportId, Is BeamIR.personId $ Eq personId, Is BeamIR.deleted $ Eq False]]

isSafeToDelete :: BeamFlow m => Id IssueReport -> Id Person -> m Bool
isSafeToDelete issueReportId personId = do
  findSafeToDelete <- safeToDelete issueReportId personId
  return $ isJust findSafeToDelete

deleteByPersonId :: BeamFlow m => Id Person -> m ()
deleteByPersonId (Id personId) = deleteWithKV [Is BeamIR.personId (Eq personId)]

updateAsDeleted :: BeamFlow m => Id IssueReport -> m ()
updateAsDeleted issueReportId = do
  now <- getCurrentTime
  updateOneWithKV
    [ Set BeamIR.deleted True,
      Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now
    ]
    [Is BeamIR.id (Eq $ getId issueReportId)]

updateStatusAssignee :: BeamFlow m => Id IssueReport -> Maybe IssueStatus -> Maybe Text -> m ()
updateStatusAssignee issueReportId status assignee = do
  now <- getCurrentTime
  updateOneWithKV
    ([Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now] <> if isJust status then [Set BeamIR.status (fromJust status)] else [] <> ([Set BeamIR.assignee assignee | isJust assignee]))
    [Is BeamIR.id (Eq $ getId issueReportId)]

updateOption :: BeamFlow m => Id IssueReport -> Id IssueOption -> m ()
updateOption issueReportId (Id optionId) = do
  now <- getCurrentTime
  updateOneWithKV
    [Set BeamIR.optionId (Just optionId), Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now]
    [Is BeamIR.id (Eq $ getId issueReportId)]

updateIssueStatus :: BeamFlow m => Text -> IssueStatus -> m ()
updateIssueStatus ticketId status = do
  now <- getCurrentTime
  updateOneWithKV
    [Set BeamIR.status status, Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now]
    [Is BeamIR.ticketId (Eq (Just ticketId))]

updateTicketId :: BeamFlow m => Id IssueReport -> Text -> m ()
updateTicketId issueId ticketId = do
  now <- getCurrentTime
  updateOneWithKV
    [Set BeamIR.ticketId (Just ticketId), Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now]
    [Is BeamIR.id (Eq $ getId issueId)]

findByTicketId :: BeamFlow m => Text -> m (Maybe IssueReport)
findByTicketId ticketId = findOneWithKV [Is BeamIR.ticketId $ Eq (Just ticketId)]

updateChats :: BeamFlow m => Id IssueReport -> [Chat] -> m ()
updateChats issueId chats = do
  now <- getCurrentTime
  updateOneWithKV
    [Set BeamIR.chats chats, Set BeamIR.updatedAt $ T.utcToLocalTime T.utc now]
    [Is BeamIR.id (Eq $ getId issueId)]

instance FromTType' BeamIR.IssueReport IssueReport where
  fromTType' BeamIR.IssueReportT {..} = do
    pure $
      Just
        IssueReport
          { id = Id id,
            personId = Id personId,
            rideId = Id <$> rideId,
            description = description,
            assignee = assignee,
            status = status,
            categoryId = Id categoryId,
            optionId = Id <$> optionId,
            deleted = deleted,
            mediaFiles = Id <$> mediaFiles,
            ticketId = ticketId,
            createdAt = T.localTimeToUTC T.utc createdAt,
            updatedAt = T.localTimeToUTC T.utc updatedAt,
            chats = chats
          }

instance ToTType' BeamIR.IssueReport IssueReport where
  toTType' IssueReport {..} = do
    BeamIR.IssueReportT
      { BeamIR.id = getId id,
        BeamIR.personId = getId personId,
        BeamIR.rideId = getId <$> rideId,
        BeamIR.description = description,
        BeamIR.assignee = assignee,
        BeamIR.status = status,
        BeamIR.categoryId = getId categoryId,
        BeamIR.optionId = getId <$> optionId,
        BeamIR.deleted = deleted,
        BeamIR.mediaFiles = getId <$> mediaFiles,
        BeamIR.ticketId = ticketId,
        BeamIR.createdAt = T.utcToLocalTime T.utc createdAt,
        BeamIR.updatedAt = T.utcToLocalTime T.utc updatedAt,
        BeamIR.chats = chats
      }
