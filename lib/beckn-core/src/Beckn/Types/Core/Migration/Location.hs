module Beckn.Types.Core.Migration.Location (Location (..)) where

import Beckn.Types.Core.Migration.Address (Address)
import Beckn.Types.Core.Migration.Circle (Circle)
import Beckn.Types.Core.Migration.City (City)
import Beckn.Types.Core.Migration.Country (Country)
import Beckn.Types.Core.Migration.Descriptor (Descriptor)
import Beckn.Types.Core.Migration.Gps (Gps)
import Beckn.Utils.Example
import Beckn.Utils.JSON
import EulerHS.Prelude hiding (id)

data Location = Location
  { id :: Maybe Text,
    descriptor :: Maybe Descriptor,
    gps :: Maybe Gps,
    address :: Maybe Address,
    station_code :: Maybe Text,
    city :: Maybe City,
    country :: Maybe Country,
    circle :: Maybe Circle,
    polygon :: Maybe Text,
    _3dspace :: Maybe Text
  }
  deriving (Generic, Show)

instance Example Location where
  example =
    Location
      { id = Nothing,
        descriptor = Nothing,
        gps = Nothing,
        address = Nothing,
        station_code = Nothing,
        city = Nothing,
        country = Nothing,
        circle = Nothing,
        polygon = Nothing,
        _3dspace = Nothing
      }

instance FromJSON Location where
  parseJSON = genericParseJSON stripPrefixUnderscoreIfAny

instance ToJSON Location where
  toJSON = genericToJSON stripPrefixUnderscoreIfAny
