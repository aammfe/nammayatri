module API.BPP.DriverOffer.Driver where

import qualified "driver-offer-bpp" API.Dashboard.Driver as DriverOfferBpp
import Beckn.Prelude
import Beckn.Types.Id
import Beckn.Utils.Common (withFlowHandlerAPI)
import "lib-dashboard" Domain.Types.Person as DP
import "lib-dashboard" Environment
import qualified EulerHS.Types as T
import Servant
import "lib-dashboard" Tools.Auth
import Tools.Client

type API =
  "driver"
    :> "list"
    :> TokenAuth (ApiAccessLevel 'READ_ACCESS 'DRIVERS)
    :> Get '[JSON] Text

handler :: FlowServer API
handler =
  listDriver

listDriver :: Id DP.Person -> FlowHandler Text
listDriver _ = withFlowHandlerAPI $ do
  callDriverOfferApi client "driverOfferBppDriverList"
  where
    driverOfferBppDriverListAPI :: Proxy DriverOfferBpp.DriverListAPI
    driverOfferBppDriverListAPI = Proxy
    client =
      T.client
        driverOfferBppDriverListAPI
