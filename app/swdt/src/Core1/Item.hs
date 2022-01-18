module Core1.Item where

import Beckn.Prelude
import Core1.Descriptor
import Core1.Price

newtype Quantity = Quantity
  { count :: Int
  }
  deriving (Generic, Show, ToJSON, FromJSON)

data OnSearchItem = OnSearchItem
  { id :: Text,
    fulfillment_id :: Text,
    descriptor :: DescriptorId,
    price :: Price
  }
  deriving (Generic, Show, ToJSON, FromJSON)

data InitItem = InitItem
  { id :: Text,
    fulfillment_id :: Text,
    quantity :: Quantity
  }
  deriving (Generic, Show, ToJSON, FromJSON)

type ConfirmItem = InitItem

data OnConfirmItem = OnConfirmItem
  { id :: Text,
    fulfillment_id :: Text,
    descriptor :: DescriptorCode,
    quantity :: Quantity
  }
  deriving (Generic, Show, ToJSON, FromJSON)
