module Beckn.Types.Core.Offer where

import Beckn.Types.Core.Descriptor
import Beckn.Utils.Example
import Beckn.Utils.JSON
import Data.OpenApi (ToSchema)
import Data.Text
import Data.Time
import EulerHS.Prelude hiding (id)

data Offer = Offer
  { id :: Text,
    descriptor :: Descriptor,
    applies_to :: OfferRef,
    start_date :: UTCTime,
    end_date :: UTCTime
  }
  deriving (Generic, FromJSON, ToJSON, Show, ToSchema)

instance Example Offer where
  example =
    Offer
      { id = idExample,
        descriptor = example,
        applies_to = example,
        start_date = example,
        end_date = example
      }

data OfferRef = OfferRef
  { _type :: Text, --"category", "service", "item"
    ids :: [Text]
  }
  deriving (Generic, Show, ToSchema)

instance FromJSON OfferRef where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON OfferRef where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny

instance Example OfferRef where
  example =
    OfferRef
      { _type = "service",
        ids = one idExample
      }
