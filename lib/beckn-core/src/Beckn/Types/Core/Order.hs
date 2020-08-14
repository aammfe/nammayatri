module Beckn.Types.Core.Order where

import Beckn.Types.Core.Billing
import Beckn.Types.Core.ItemQuantity
import Beckn.Types.Core.Payment
import Beckn.Types.Core.Quotation
import Beckn.Utils.Common
import Data.Time
import EulerHS.Prelude

data Order = Order
  { _id :: Text,
    _state :: Text,
    _created_at :: UTCTime,
    _updated_at :: UTCTime,
    _items :: [OrderItem],
    _billing :: Maybe Billing,
    _payment :: Maybe Payment,
    _update_action :: Maybe Text,
    _quotation :: Maybe Quotation
  }
  deriving (Generic, Show)

instance FromJSON Order where
  parseJSON = genericParseJSON stripAllLensPrefixOptions

instance ToJSON Order where
  toJSON = genericToJSON stripAllLensPrefixOptions

instance Example Order where
  example =
    Order
      { _id = idExample,
        _state = "State",
        _created_at = example,
        _updated_at = example,
        _items = example,
        _billing = example,
        _payment = example,
        _update_action = Nothing,
        _quotation = Nothing
      }

data OrderItem = OrderItem
  { _id :: Text,
    _quantity :: Maybe ItemQuantity
  }
  deriving (Generic, Show)

instance FromJSON OrderItem where
  parseJSON = genericParseJSON stripAllLensPrefixOptions

instance ToJSON OrderItem where
  toJSON = genericToJSON stripAllLensPrefixOptions

instance Example OrderItem where
  example =
    OrderItem
      { _id = idExample,
        _quantity = example
      }
