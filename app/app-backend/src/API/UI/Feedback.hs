module API.UI.Feedback
  ( API,
    handler,
    DFeedback.FeedbackReq (..),
  )
where

import Beckn.Types.APISuccess (APISuccess (Success))
import Beckn.Types.Id
import Beckn.Utils.Common
import qualified Core.ACL.Rating as ACL
import qualified Domain.Action.UI.Feedback as DFeedback
import qualified Domain.Types.Person as Person
import qualified Environment as App
import EulerHS.Prelude hiding (product)
import Servant
import qualified SharedLogic.CallBPP as CallBPP
import Tools.Auth

-------- Feedback Flow ----------
type API =
  "feedback"
    :> ( "rateRide"
           :> TokenAuth
           :> ReqBody '[JSON] DFeedback.FeedbackReq
           :> Post '[JSON] APISuccess
       )

handler :: App.FlowServer API
handler = feedback

feedback :: Id Person.Person -> DFeedback.FeedbackReq -> App.FlowHandler APISuccess
feedback personId request = withFlowHandlerAPI . withPersonIdLogTag personId $ do
  dFeedbackRes <- DFeedback.feedback request
  becknReq <- ACL.buildRatingReq dFeedbackRes
  void $ withRetry $ CallBPP.feedback dFeedbackRes.providerUrl becknReq
  pure Success
