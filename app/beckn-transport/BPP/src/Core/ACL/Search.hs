module Core.ACL.Search (buildSearchReq) where

import Beckn.Product.Validation.Context
import Beckn.Types.Common
import qualified Beckn.Types.Core.Context as Context
import qualified Beckn.Types.Core.Taxi.API.Search as Search
import qualified Beckn.Types.Core.Taxi.Search as Search
import qualified Beckn.Types.Registry.Subscriber as Subscriber
import Beckn.Utils.Common
import qualified Domain.Action.Beckn.Search as DSearch
import EulerHS.Prelude hiding (state)
import Tools.Error

buildSearchReq ::
  (HasFlowEnv m r '["coreVersion" ::: Text]) =>
  Subscriber.Subscriber ->
  Search.SearchReq ->
  m DSearch.DSearchReq
buildSearchReq subscriber req = do
  let context = req.context
  validateContext Context.SEARCH context
  let intent = req.message.intent
  let pickup = intent.fulfillment.start
  let mbDropOff = intent.fulfillment.end
  unless (subscriber.subscriber_id == context.bap_id) $
    throwError (InvalidRequest "Invalid bap_id")
  unless (subscriber.subscriber_url == context.bap_uri) $
    throwError (InvalidRequest "Invalid bap_uri") -- is it correct?
  let messageId = context.message_id
  pure
    DSearch.DSearchReq
      { messageId = messageId,
        bapId = subscriber.subscriber_id,
        bapUri = subscriber.subscriber_url,
        pickupLocation = mkLocation pickup.location,
        pickupTime = pickup.time.timestamp,
        mbDropLocation = mkLocation <$> (mbDropOff <&> (.location))
      }

mkLocation :: Search.Location -> DSearch.LocationReq
mkLocation (Search.Location Search.Gps {..}) =
  DSearch.LocationReq
    { ..
    }
