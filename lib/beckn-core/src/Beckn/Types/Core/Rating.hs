module Beckn.Types.Core.Rating where

import Beckn.Utils.Example
import Data.OpenApi (ToSchema)
import Data.Text
import EulerHS.Prelude

data Rating = Rating
  { value :: Text,
    unit :: Text, -- Default:U+2B50 Follows the unicode 13.0 format for emojis : https://unicode.org/emoji/charts/full-emoji-list.html
    max_value :: Maybe Text,
    direction :: Maybe Text -- Default "UP" - "UP", "DOWN"
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)

instance Example Rating where
  example =
    Rating
      { value = "5",
        unit = "U+2B50",
        max_value = Just "5",
        direction = Just "UP"
      }
