{-# LANGUAGE UndecidableInstances #-}

module IssueManagement.Domain.Types.Issue.IssueReport where

import Data.Aeson
import EulerHS.Prelude hiding (id)
import IssueManagement.Common
import qualified IssueManagement.Domain.Types.Issue.IssueCategory as D
import qualified IssueManagement.Domain.Types.Issue.IssueOption as D
import qualified IssueManagement.Domain.Types.MediaFile as D
import qualified Kernel.Prelude as BP
import Kernel.Types.Id
import Kernel.Utils.Common

data IssueReport = IssueReport
  { id :: Id IssueReport,
    personId :: Id Person,
    rideId :: Maybe (Id Ride),
    description :: Text,
    assignee :: Maybe Text,
    status :: IssueStatus,
    categoryId :: Id D.IssueCategory,
    optionId :: Maybe (Id D.IssueOption),
    deleted :: Bool,
    mediaFiles :: [Id D.MediaFile],
    createdAt :: UTCTime,
    updatedAt :: UTCTime,
    ticketId :: Maybe Text,
    chats :: [Chat]
  }
  deriving (Show, Generic, Read, Eq, Ord, ToJSON, FromJSON, BP.ToSchema)
