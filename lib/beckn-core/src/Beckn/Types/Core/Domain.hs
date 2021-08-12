module Beckn.Types.Core.Domain where

import Beckn.Utils.Example
import Beckn.Utils.JSON
import Data.Aeson
import Data.OpenApi (ToSchema)
import EulerHS.Prelude

data Domain
  = MOBILITY
  | FINAL_MILE_DELIVERY
  | LOCAL_RETAIL
  | FOOD_AND_BEVERAGE
  | HEALTHCARE
  deriving (Eq, Generic, Show, ToSchema)

instance Example Domain where
  example = MOBILITY

instance ToJSON Domain where
  toJSON = genericToJSON constructorsWithHyphens

instance FromJSON Domain where
  parseJSON = genericParseJSON constructorsWithHyphens
