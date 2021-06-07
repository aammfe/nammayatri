module Beckn.Types.Core.Migration.Order where

import Beckn.Types.Common (IdObject)
import Beckn.Types.Core.Migration.Billing
import Beckn.Types.Core.Migration.Fulfillment (Fulfillment)
import Beckn.Types.Core.Migration.ItemQuantity
import Beckn.Types.Core.Migration.Payment
import Beckn.Types.Core.Migration.Quotation
import Beckn.Utils.JSON
import Data.Time
import EulerHS.Prelude hiding (State, id, state)

data Order = Order
  { id :: Maybe Text,
    state :: Maybe Text,
    provider :: IdAndLocations,
    items :: [OrderItem],
    add_ons :: [IdObject],
    offers :: [IdObject],
    billing :: Billing,
    fulfillment :: Fulfillment,
    quote :: Quotation,
    payment :: Payment,
    created_at :: Maybe UTCTime,
    updated_at :: Maybe UTCTime
  }
  deriving (Generic, Show)

data IdAndLocations = IdAndLocations
  { id :: Text,
    locations :: [IdObject]
  }
  deriving (Generic, Show)

data OrderItem = OrderItem
  { id :: Text,
    quantity :: ItemQuantity
  }
  deriving (Generic, Show)

instance FromJSON Order where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON Order where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

instance FromJSON OrderItem where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON OrderItem where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

instance FromJSON IdAndLocations where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON IdAndLocations where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny
