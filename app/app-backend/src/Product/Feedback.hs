{-# LANGUAGE OverloadedLabels #-}

module Product.Feedback where

import qualified App.Types as App
import Beckn.Types.APISuccess (APISuccess (Success))
import qualified Beckn.Types.Core.API.Feedback as Beckn
import qualified Beckn.Types.Core.Description as Beckn
import qualified Beckn.Types.Core.Rating as Beckn
import Beckn.Types.Id
import qualified Beckn.Types.Storage.Person as Person
import EulerHS.Prelude hiding (product)
import qualified ExternalAPI.Flow as ExternalAPI
import qualified Models.Case as Case
import qualified Models.ProductInstance as ProductInstance
import qualified Storage.Queries.Organization as Organization
import qualified Types.API.Feedback as API
import Types.Error
import Utils.Common
  ( buildContext,
    checkAckResponseError,
    fromMaybeM,
    throwError,
    withFlowHandlerAPI,
  )

feedback :: Person.Person -> API.FeedbackReq -> App.FlowHandler API.FeedbackRes
feedback person request = withFlowHandlerAPI $ do
  let ratingValue = request ^. #rating
  unless (ratingValue `elem` [1 .. 5]) $ throwError InvalidRatingValue
  let prodInstId = request ^. #productInstanceId
  product <- ProductInstance.findById $ Id prodInstId
  order <- Case.findIdByPerson person $ product ^. #_caseId
  let txnId = getId $ order ^. #_id
  context <- buildContext "feedback" txnId Nothing Nothing
  organization <-
    Organization.findOrganizationById (Id $ product ^. #_organizationId)
      >>= fromMaybeM OrgNotFound
  let feedbackMsg =
        Beckn.FeedbackReqMessage
          { order_id = prodInstId,
            rating =
              Beckn.Rating
                { _value = show ratingValue,
                  _unit = "U+2B50",
                  _max_value = Just "5",
                  _direction = Just "UP"
                },
            description =
              Beckn.Description
                { _name = "Ride order rating",
                  _code = "RIDE_ORDER_RATING",
                  _symbol = Nothing,
                  _short_desc = Nothing,
                  _long_desc = Nothing,
                  _images = [],
                  _audio = Nothing,
                  _3d_render = Nothing
                }
          }
  gatewayUrl <- organization ^. #_callbackUrl & fromMaybeM (OrgFieldNotPresent "callback_url")
  ExternalAPI.feedback gatewayUrl (Beckn.FeedbackReq context feedbackMsg)
    >>= checkAckResponseError (ExternalAPIResponseError "feedback")
  return Success
