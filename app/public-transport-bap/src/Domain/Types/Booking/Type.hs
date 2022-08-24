{-# OPTIONS_GHC -Wno-orphans #-}

module Domain.Types.Booking.Type where

import Beckn.Prelude
import Beckn.Types.Common
import Beckn.Types.Id
import Beckn.Utils.GenericPretty
import Domain.Types.Quote (Quote)
import Domain.Types.Search (Search)
import Domain.Types.TransportStation (TransportStation)
import Tools.Auth

data BookingStatus = NEW | AWAITING_PAYMENT | CONFIRMED | CANCELLED
  deriving (Generic, Show, Read, FromJSON, ToJSON, ToSchema, Eq)

instance PrettyShow BookingStatus where
  prettyShow = prettyShow . Showable

data Booking = Booking
  { id :: Id Booking,
    searchId :: Id Search,
    quoteId :: Id Quote,
    bknTxnId :: Text,
    requestorId :: Id Person,
    quantity :: Int,
    bppId :: Text,
    bppUrl :: BaseUrl,
    publicTransportSupportNumber :: Text,
    description :: Text,
    fare :: Money,
    departureTime :: UTCTime,
    arrivalTime :: UTCTime,
    departureStationId :: Id TransportStation,
    arrivalStationId :: Id TransportStation,
    status :: BookingStatus,
    createdAt :: UTCTime,
    updatedAt :: UTCTime,
    ticketId :: Maybe Text,
    ticketCreatedAt :: Maybe UTCTime
  }
  deriving (Generic, ToSchema, Show)
