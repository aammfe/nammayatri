{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Domain.Types.Driver.DriverFlowStatus
  ( FlowStatus (..),
    DriverFlowStatus (..),
    isPaymentOverdue,
  )
where

import Data.Aeson (Options (..), SumEncoding (..), defaultOptions)
import Data.OpenApi
import Domain.Types.DriverFee (DriverFee, PlatformFee)
import qualified Domain.Types.DriverQuote as DQ
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Ride as DRide
import qualified Domain.Types.SearchTry as DST
import Kernel.Prelude
import Kernel.Types.Common (Money)
import Kernel.Types.Id

-- Warning: This whole thing is for frontend use only, don't make any backend logic based on this.
data FlowStatus
  = IDLE
  | ACTIVE
  | SILENT
  | GOT_SEARCH_REQUEST
      { requestId :: Id DST.SearchTry, -- TODO: deprecated, to be removed
        searchTryId :: Id DST.SearchTry,
        validTill :: UTCTime
      }
  | OFFERED_QUOTE
      { quoteId :: Id DQ.DriverQuote,
        validTill :: UTCTime
      }
  | RIDE_ASSIGNED
      { rideId :: Id DRide.Ride
      }
  | WAITING_FOR_CUSTOMER
      { rideId :: Id DRide.Ride
      }
  | ON_RIDE
      { rideId :: Id DRide.Ride
      }
  | PAYMENT_OVERDUE
  deriving (Show, Eq, Generic)

flowStatusCustomJSONOptions :: Options
flowStatusCustomJSONOptions =
  defaultOptions
    { sumEncoding =
        TaggedObject
          { tagFieldName = "status",
            contentsFieldName = "info"
          }
    }

instance ToJSON FlowStatus where
  toJSON = genericToJSON flowStatusCustomJSONOptions

instance FromJSON FlowStatus where
  parseJSON = genericParseJSON flowStatusCustomJSONOptions

instance ToSchema FlowStatus where
  declareNamedSchema = genericDeclareNamedSchema $ fromAesonOptions flowStatusCustomJSONOptions

data DriverFlowStatus = DriverFlowStatus
  { personId :: Id DP.Person,
    flowStatus :: FlowStatus,
    updatedAt :: UTCTime
  }
  deriving (Show, Eq, Generic)

isPaymentOverdue :: FlowStatus -> Bool
isPaymentOverdue flowStatus = case flowStatus of
  PAYMENT_OVERDUE {} -> True
  _ -> False
