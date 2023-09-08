{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module API.UI.CancellationReason
  ( API,
    handler,
    ListRes,
  )
where

import qualified Domain.Action.UI.CancellationReason as DCancellationReason
import qualified Domain.Types.CancellationReason as DCR
import qualified Domain.Types.Merchant as Merchant
import qualified Domain.Types.Merchant.MerchantOperatingCity as DMOC
import qualified Domain.Types.Person as Person
import Environment
import EulerHS.Prelude hiding (id)
import Kernel.Types.Id
import Kernel.Utils.Common
import Servant
import Tools.Auth

type API =
  "cancellationReason"
    :> ( "list"
           :> TokenAuth
           :> MandatoryQueryParam "cancellationStage" DCR.CancellationStage
           :> Get '[JSON] ListRes
       )

type ListRes = [DCR.CancellationReasonAPIEntity]

handler :: FlowServer API
handler = list

list :: (Id Person.Person, Id Merchant.Merchant, Id DMOC.MerchantOperatingCity) -> DCR.CancellationStage -> FlowHandler ListRes
list _ = withFlowHandlerAPI . DCancellationReason.list
