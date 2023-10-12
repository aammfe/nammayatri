{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE DerivingStrategies #-}

module Dashboard.Common
  ( module Dashboard.Common,
    module Reexport,
  )
where

import Data.Aeson
import Data.OpenApi
import Kernel.Prelude
import Kernel.Types.HideSecrets as Reexport

data Customer

data Driver

data User

data Image

data Ride

data Message

data File

data Receiver

data Booking

data IssueReport

data IssueCategory

data FarePolicy

data DriverHomeLocation

data Variant = SEDAN | SUV | HATCHBACK | AUTO_RICKSHAW | TAXI | TAXI_PLUS
  deriving stock (Show, Generic)
  deriving anyclass (ToJSON, FromJSON, ToSchema)

data Summary = Summary
  { totalCount :: Int, --TODO add db indexes
    count :: Int
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (ToJSON, FromJSON, ToSchema)

data ListItemResult = SuccessItem | FailItem Text
  deriving stock (Show, Generic)

instance ToJSON ListItemResult where
  toJSON = genericToJSON listItemOptions

instance FromJSON ListItemResult where
  parseJSON = genericParseJSON listItemOptions

instance ToSchema ListItemResult where
  declareNamedSchema = genericDeclareNamedSchema $ fromAesonOptions listItemOptions

listItemOptions :: Options
listItemOptions =
  defaultOptions
    { sumEncoding = listItemTaggedObject
    }

listItemTaggedObject :: SumEncoding
listItemTaggedObject =
  TaggedObject
    { tagFieldName = "result",
      contentsFieldName = "errorMessage"
    }

-- is it correct to show every error?
listItemErrHandler :: Monad m => SomeException -> m ListItemResult
listItemErrHandler = pure . FailItem . show @Text @SomeException
