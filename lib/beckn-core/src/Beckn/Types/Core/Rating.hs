module Beckn.Types.Core.Rating where

import Beckn.Types.Core.Api
import Beckn.Types.Core.Contact
import Beckn.Utils.Common
import Data.Text
import EulerHS.Prelude

data Rating = Rating
  { _value :: Text,
    _scale :: [Text]
  }
  deriving (Generic, Show)

instance FromJSON Rating where
  parseJSON = genericParseJSON stripAllLensPrefixOptions

instance ToJSON Rating where
  toJSON = genericToJSON stripAllLensPrefixOptions

instance Example Rating where
  example =
    Rating
      { _value = "5",
        _scale = ["10"]
      }
