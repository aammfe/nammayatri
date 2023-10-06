{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Beckn.Types.Core.Taxi.Confirm
  ( module Beckn.Types.Core.Taxi.Confirm,
    module Reexport,
  )
where

import Beckn.Types.Core.Taxi.Common.Agent as Reexport
import Beckn.Types.Core.Taxi.Common.Billing as Reexport
import Beckn.Types.Core.Taxi.Common.Customer as Reexport
import Beckn.Types.Core.Taxi.Common.Descriptor as Reexport
import Beckn.Types.Core.Taxi.Common.FulfillmentType as Reexport
import Beckn.Types.Core.Taxi.Common.Location as Reexport
import Beckn.Types.Core.Taxi.Common.Payment as Reexport
import Beckn.Types.Core.Taxi.Common.Price as Reexport
import Beckn.Types.Core.Taxi.Common.Provider as Reexport
import Beckn.Types.Core.Taxi.Common.Quote as Reexport
import Beckn.Types.Core.Taxi.Common.StartInfo as Reexport
import Beckn.Types.Core.Taxi.Common.StopInfo as Reexport
import Beckn.Types.Core.Taxi.Common.Vehicle as Reexport
import Beckn.Types.Core.Taxi.Confirm.Fulfillment as Reexport
import Beckn.Types.Core.Taxi.Confirm.Order as Reexport
import Data.OpenApi (ToSchema)
import EulerHS.Prelude

newtype ConfirmMessage = ConfirmMessage
  { order :: Order
  }
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema)
