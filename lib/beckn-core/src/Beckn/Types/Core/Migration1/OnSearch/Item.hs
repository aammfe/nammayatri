module Beckn.Types.Core.Migration1.OnSearch.Item
  ( module Beckn.Types.Core.Migration1.OnSearch.Item,
    module Reexport,
  )
where

import Beckn.Types.Core.Migration1.Common.Price as Reexport
import Data.OpenApi (ToSchema)
import EulerHS.Prelude hiding (id)

data Item = Item
  { id :: Text,
    vehicle_variant :: Text,
    estimated_price :: Price,
    discount :: Maybe Price,
    discounted_price :: Price,
    nearest_driver_distance :: Double
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)
