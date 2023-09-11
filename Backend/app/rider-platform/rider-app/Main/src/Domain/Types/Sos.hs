{-# LANGUAGE TemplateHaskell #-}

module Domain.Types.Sos where

import Domain.Types.Person (Person)
import Domain.Types.Ride (Ride)
import Kernel.Beam.Lib.UtilsTH (mkBeamInstancesForEnum)
import Kernel.Prelude
import Kernel.Types.Id

data Sos = Sos
  { id :: Id Sos,
    personId :: Id Person,
    rideId :: Id Ride,
    status :: SosStatus,
    flow :: SosType,
    createdAt :: UTCTime,
    updatedAt :: UTCTime,
    ticketId :: Text
  }
  deriving (Generic, Show)

newtype EmergencyContactId = EmergencyContactId Text
  deriving (Show, Eq, Ord, Read, Generic, ToJSON, FromJSON, ToSchema)

data SosType = Police | CustomerCare | EmergencyContact EmergencyContactId
  deriving (Show, Eq, Ord, Read, Generic, ToJSON, FromJSON, ToSchema)

data SosStatus
  = Resolved
  | NotResolved
  | Pending
  deriving (Show, Eq, Ord, Read, Generic, ToJSON, FromJSON, ToSchema)

data MediaType = Video deriving (Read, Show, Generic, ToSchema, ToJSON, FromJSON)

data SosMedia = SosMedia
  { id :: Id SosMedia,
    _type :: MediaType,
    url :: Text,
    createdAt :: UTCTime
  }
  deriving (Generic, ToJSON, FromJSON)

$(mkBeamInstancesForEnum ''SosType)

$(mkBeamInstancesForEnum ''SosStatus)
