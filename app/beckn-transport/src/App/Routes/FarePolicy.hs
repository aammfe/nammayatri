module App.Routes.FarePolicy where

import App.Routes.FarePolicy.Discount
import App.Types
import Beckn.Types.Id (Id)
import Product.FarePolicy (listFarePolicies, updateFarePolicy)
import Servant
import Types.API.FarePolicy
  ( ListFarePolicyRes,
    UpdateFarePolicyReq,
    UpdateFarePolicyRes,
  )
import Types.Domain.FarePolicy (FarePolicy)
import Utils.Auth

type FarePolicyAPI =
  "org" :> "farePolicy"
    :> ( AdminTokenAuth
           :> Get '[JSON] ListFarePolicyRes
           :<|> AdminTokenAuth
             :> Capture "farePolicyId" (Id FarePolicy)
             :> ReqBody '[JSON] UpdateFarePolicyReq
             :> Post '[JSON] UpdateFarePolicyRes
           :<|> FPDiscountAPI
       )

farePolicyFlow :: FlowServer FarePolicyAPI
farePolicyFlow =
  listFarePolicies
    :<|> updateFarePolicy
    :<|> discountFlow
