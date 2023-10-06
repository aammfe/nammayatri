{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.Types.Core.Taxi.OnConfirm.Fulfillment
  ( module Beckn.Types.Core.Taxi.OnConfirm.Fulfillment,
  )
where

import Beckn.Types.Core.Taxi.Common.Agent
import Beckn.Types.Core.Taxi.Common.Customer
import Beckn.Types.Core.Taxi.Common.Descriptor
import Beckn.Types.Core.Taxi.Common.FulfillmentType
import Beckn.Types.Core.Taxi.Common.StartInfo
import Beckn.Types.Core.Taxi.Common.StopInfo
import Beckn.Types.Core.Taxi.Common.Tags
import Beckn.Types.Core.Taxi.Common.Vehicle
import Data.Aeson
import Data.OpenApi (ToSchema (..), defaultSchemaOptions)
import Kernel.Prelude
import Kernel.Utils.JSON
import Kernel.Utils.Schema (genericDeclareUnNamedSchema)

-- If end = Nothing, then bpp sends quotes only for RENTAL
-- If end is Just, then bpp sends quotes both for RENTAL and ONE_WAY
data FulfillmentInfo = FulfillmentInfo
  { id :: Text,
    _type :: FulfillmentType,
    state :: FulfillmentState,
    start :: StartInfo,
    end :: Maybe StopInfo,
    vehicle :: Vehicle,
    customer :: Customer,
    agent :: Maybe Agent, -- If NormalBooking then Just else Nothing for SpecialZoneBooking
    tags :: Maybe TagGroups,
    tracking :: Maybe Bool -- Only for FRFS
  }
  deriving (Generic, Show)

instance ToSchema FulfillmentInfo where
  declareNamedSchema = genericDeclareUnNamedSchema defaultSchemaOptions

instance FromJSON FulfillmentInfo where
  parseJSON = genericParseJSON $ stripPrefixUnderscoreIfAny {omitNothingFields = True}

instance ToJSON FulfillmentInfo where
  toJSON = genericToJSON $ stripPrefixUnderscoreIfAny {omitNothingFields = True}

newtype FulfillmentState = FulfillmentState
  { descriptor :: Descriptor
  }
  deriving (Generic, FromJSON, ToJSON, Show)

instance ToSchema FulfillmentState where
  declareNamedSchema = genericDeclareUnNamedSchema defaultSchemaOptions
