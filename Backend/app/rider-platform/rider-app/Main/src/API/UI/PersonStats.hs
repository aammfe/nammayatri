{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module API.UI.PersonStats
  ( API,
    handler,
  )
where

import qualified Domain.Action.UI.PersonStats as DPersonStats
import qualified Domain.Types.Merchant as Merchant
import qualified Domain.Types.Person as Person
import Environment
import EulerHS.Prelude
import Kernel.Types.Id
import Kernel.Utils.Common
import Servant
import Tools.Auth

type API =
  "personStats"
    :> ( TokenAuth
           :> Get '[JSON] DPersonStats.PersonStatsRes
       )

handler :: FlowServer API
handler =
  getPersonStats

getPersonStats :: (Id Person.Person, Id Merchant.Merchant) -> FlowHandler DPersonStats.PersonStatsRes
getPersonStats = withFlowHandlerAPI . DPersonStats.getPersonStats
