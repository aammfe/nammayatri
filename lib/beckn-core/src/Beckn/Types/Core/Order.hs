module Beckn.Types.Core.Order where

import Beckn.Types.Core.Billing
import Beckn.Types.Core.ItemQuantity
import Beckn.Types.Core.Payment
import Beckn.Types.Core.Quotation
import Beckn.Utils.Example
import Data.OpenApi (ToSchema)
import Data.Time
import EulerHS.Prelude hiding (id, state)

data Order = Order
  { id :: Text,
    state :: Text,
    created_at :: UTCTime,
    updated_at :: UTCTime,
    items :: [OrderItem],
    billing :: Maybe Billing,
    payment :: Maybe Payment,
    update_action :: Maybe Text,
    quotation :: Maybe Quotation
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)

instance Example Order where
  example =
    Order
      { id = idExample,
        state = "State",
        created_at = example,
        updated_at = example,
        items = example,
        billing = example,
        payment = example,
        update_action = Nothing,
        quotation = example
      }

data OrderItem = OrderItem
  { id :: Text,
    quantity :: Maybe ItemQuantity
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)

instance Example OrderItem where
  example =
    OrderItem
      { id = idExample,
        quantity = example
      }
