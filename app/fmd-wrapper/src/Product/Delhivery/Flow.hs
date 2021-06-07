{-# LANGUAGE OverloadedLabels #-}

module Product.Delhivery.Flow where

import App.Types
import Beckn.Types.Common
import Beckn.Types.Core.Ack
import Beckn.Types.Id
import Beckn.Types.Storage.Case
import qualified Beckn.Types.Storage.Organization as Org
import qualified Beckn.Utils.Servant.SignatureAuth as HttpSig
import Control.Lens.Combinators hiding (Context)
import qualified Data.Text as T
import EulerHS.Prelude
import qualified EulerHS.Types as ET
import qualified ExternalAPI.Delhivery.Flow as API
import ExternalAPI.Delhivery.Types
import Product.Delhivery.Transform
import qualified Storage.Queries.Case as Storage
import qualified Storage.Queries.Organization as Org
import qualified Storage.Queries.Quote as Storage
import qualified Types.Beckn.API.Confirm as API
import qualified Types.Beckn.API.Init as API
import qualified Types.Beckn.API.Search as API
import qualified Types.Beckn.API.Select as API
import Types.Beckn.FmdOrder
import Types.Common
import Types.Error
import Types.Wrapper
import Utils.Common

search :: Org.Organization -> API.SearchReq -> Flow API.SearchRes
search org req = do
  config@DelhiveryConfig {..} <- dlConfig <$> ask
  quoteReq <- mkQuoteReqFromSearch req
  let context = updateBppUri (req ^. #context) dlBPNwAddress
  bapUrl <- context ^. #bap_uri & fromMaybeM (InvalidRequest "You should pass bap uri.")
  bap <- Org.findByBapUrl bapUrl >>= fromMaybeM OrgDoesNotExist
  dlBACreds <- getDlBAPCreds bap
  fork "Search" $ do
    eres <- getQuote dlBACreds config quoteReq
    sendCb context eres
  return Ack
  where
    sendCb context res = do
      cbUrl <- org ^. #callbackUrl & fromMaybeM (OrgFieldNotPresent "callback_url")
      case res of
        Right quoteRes -> do
          onSearchReq <- mkOnSearchReq org context quoteRes
          logTagInfo (req ^. #context . #transaction_id <> "_on_search req") $ encodeToText onSearchReq
          onSearchResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onSearchAPI onSearchReq) "search"
          logTagInfo (req ^. #context . #transaction_id <> "_on_search res") $ show onSearchResp
        Left err -> do
          let onSearchErrReq = mkOnSearchErrReq context err
          logTagInfo (req ^. #context . #transaction_id <> "_on_search err req") $ encodeToText onSearchErrReq
          onSearchResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onSearchAPI onSearchErrReq) "search"
          logTagInfo (req ^. #context . #transaction_id <> "_on_search err res") $ show onSearchResp

select :: Org.Organization -> API.SelectReq -> Flow API.SelectRes
select org req = do
  config@DelhiveryConfig {..} <- dlConfig <$> ask
  let context = updateBppUri (req ^. #context) dlBPNwAddress
  --  validateOrderRequest $ req ^. #message . #order
  cbUrl <- org ^. #callbackUrl & fromMaybeM (OrgFieldNotPresent "callback_url")
  dlBACreds <- getDlBAPCreds org
  fork "Select" $ do
    quoteReq <- mkQuoteReqFromSelect req
    eres <- getQuote dlBACreds config quoteReq
    logTagInfo (req ^. #context . #transaction_id <> "_QuoteRes") $ show eres
    sendCallback context cbUrl eres
  return Ack
  where
    sendCallback context cbUrl = \case
      Right quoteRes -> do
        let reqOrder = req ^. #message . #order
        onSelectMessage <- mkOnSelectOrder reqOrder quoteRes
        let onSelectReq = mkOnSelectReq context onSelectMessage
        let order = onSelectMessage ^. #order
        -- onSelectMessage has quotation
        let quote = fromJust $ onSelectMessage ^. #order . #quotation
        let quoteId = quote ^. #id
        let orderDetails = OrderDetails order quote
        Storage.storeQuote quoteId orderDetails
        logTagInfo (req ^. #context . #transaction_id <> "_on_select req") $ encodeToText onSelectReq
        onSelectResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onSelectAPI onSelectReq) "select"
        logTagInfo (req ^. #context . #transaction_id <> "_on_select res") $ show onSelectResp
      Left err -> do
        let onSelectReq = mkOnSelectErrReq context err
        logTagInfo (req ^. #context . #transaction_id <> "_on_select err req") $ encodeToText onSelectReq
        onSelectResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onSelectAPI onSelectReq) "select"
        logTagInfo (req ^. #context . #transaction_id <> "_on_select err res") $ show onSelectResp

init :: Org.Organization -> API.InitReq -> Flow API.InitRes
init org req = do
  conf@DelhiveryConfig {..} <- dlConfig <$> ask
  let context = updateBppUri (req ^. #context) dlBPNwAddress
  cbUrl <- org ^. #callbackUrl & fromMaybeM (OrgFieldNotPresent "callback_url")
  quote <- req ^. (#message . #order . #quotation) & fromMaybeErr "INVALID_QUOTATION" (Just CORE003)
  let quoteId = quote ^. #id
  payeeDetails <- dlPayee & decodeFromText & fromMaybeM (InternalError "Decode error.")
  orderDetails <- Storage.lookupQuote quoteId >>= fromMaybeErr "INVALID_QUOTATION_ID" (Just CORE003)
  dlBACreds <- getDlBAPCreds org
  fork "init" $ do
    quoteReq <- mkQuoteReqFromSelect $ API.SelectReq context (API.SelectOrder (orderDetails ^. #order))
    eres <- getQuote dlBACreds conf quoteReq
    logTagInfo (req ^. #context . #transaction_id <> "_QuoteRes") $ show eres
    sendCb orderDetails context cbUrl payeeDetails quoteId eres
  return Ack
  where
    sendCb orderDetails context cbUrl payeeDetails quoteId (Right res) = do
      -- quoteId will be used as orderId
      onInitMessage <-
        mkOnInitMessage
          quoteId
          (orderDetails ^. #order)
          payeeDetails
          req
          res
      let onInitReq = mkOnInitReq context onInitMessage
      createCaseIfNotPresent (getId $ org ^. #id) (onInitMessage ^. #order) (orderDetails ^. #quote)
      logTagInfo (req ^. #context . #transaction_id <> "_on_init req") $ encodeToText onInitReq
      onInitResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onInitAPI onInitReq) "init"
      logTagInfo (req ^. #context . #transaction_id <> "_on_init res") $ show onInitResp
    sendCb _ context cbUrl _ _ (Left err) = do
      let onInitReq = mkOnInitErrReq context err
      logTagInfo (req ^. #context . #transaction_id <> "_on_init err req") $ encodeToText onInitReq
      onInitResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onInitAPI onInitReq) "init"
      logTagInfo (req ^. #context . #transaction_id <> "_on_init err res") $ show onInitResp

    createCaseIfNotPresent orgId order quote = do
      now <- getCurrentTime
      let caseId = Id $ fromJust $ order ^. #id
      let case_ =
            Case
              { id = caseId,
                name = Nothing,
                description = Nothing,
                shortId = "", -- FIX this
                industry = GROCERY,
                _type = RIDEORDER,
                exchangeType = ORDER,
                status = NEW,
                startTime = now,
                endTime = Nothing,
                validTill = now,
                provider = Just "Delhivery",
                providerType = Nothing,
                requestor = Just orgId,
                requestorType = Nothing,
                parentCaseId = Nothing,
                fromLocationId = "",
                toLocationId = "",
                udf1 = Just $ encodeToText (OrderDetails order quote),
                udf2 = Nothing,
                udf3 = Nothing,
                udf4 = Nothing,
                udf5 = Nothing,
                info = Nothing,
                createdAt = now,
                updatedAt = now
              }
      mcase <- Storage.findById caseId
      case mcase of
        Nothing -> Storage.create case_
        Just _ -> pass

confirm :: Org.Organization -> API.ConfirmReq -> Flow API.ConfirmRes
confirm org req = do
  dconf@DelhiveryConfig {..} <- dlConfig <$> ask
  let ctx = updateBppUri (req ^. #context) dlBPNwAddress
  cbUrl <- org ^. #callbackUrl & fromMaybeM (OrgFieldNotPresent "callback_url")
  let reqOrder = req ^. (#message . #order)
  orderId <- fromMaybeErr "INVALID_ORDER_ID" (Just CORE003) $ reqOrder ^. #id
  case_ <- Storage.findById (Id orderId) >>= fromMaybeErr "ORDER_NOT_FOUND" (Just CORE003)
  (orderDetails :: OrderDetails) <- case_ ^. #udf1 >>= decodeFromText & fromMaybeErr "ORDER_NOT_FOUND" (Just CORE003)
  let order = orderDetails ^. #order
  verifyPayment reqOrder order
  dlBACreds <- getDlBAPCreds org
  fork "confirm" $ do
    createOrderReq <- mkCreateOrderReq order
    logTagInfo (req ^. #context . #transaction_id <> "_CreateTaskReq") (encodeToText createOrderReq)
    eres <- createOrderAPI dlBACreds dconf createOrderReq
    logTagInfo (req ^. #context . #transaction_id <> "_CreateTaskRes") $ show eres
    sendCb order ctx cbUrl eres
  return Ack
  where
    createOrderAPI dlBACreds@DlBAConfig {..} conf@DelhiveryConfig {..} req' = do
      token <- getBearerToken <$> fetchToken dlBACreds conf
      API.createOrder token dlUrl req'

    verifyPayment :: Order -> Order -> Flow ()
    verifyPayment reqOrder order = do
      confirmAmount <-
        reqOrder ^? #payment . _Just . #amount . #value
          & fromMaybeErr "INVALID_PAYMENT_AMOUNT" (Just CORE003)
      orderAmount <-
        order ^? #payment . _Just . #amount . #value
          & fromMaybeErr "ORDER_AMOUNT_NOT_FOUND" (Just CORE003)
      if confirmAmount == orderAmount
        then pass
        else throwError $ InvalidRequest "Invalid order amount."

    sendCb order context cbUrl = \case
      Right _ -> do
        onConfirmReq <- mkOnConfirmReq context order
        logTagInfo (req ^. #context . #transaction_id <> "_on_confirm req") $ encodeToText onConfirmReq
        eres <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onConfirmAPI onConfirmReq) "confirm"
        logTagInfo (req ^. #context . #transaction_id <> "_on_confirm res") $ show eres
      Left err -> do
        let onConfirmReq = mkOnConfirmErrReq context err
        logTagInfo (req ^. #context . #transaction_id <> "_on_confirm err req") $ encodeToText onConfirmReq
        onConfirmResp <- callAPI' (Just HttpSig.signatureAuthManagerKey) cbUrl (ET.client API.onConfirmAPI onConfirmReq) "confirm"
        logTagInfo (req ^. #context . #transaction_id <> "_on_confirm err res") $ show onConfirmResp

fetchToken :: DlBAConfig -> DelhiveryConfig -> Flow Token
fetchToken DlBAConfig {..} DelhiveryConfig {..} =
  API.getToken dlTokenUrl (TokenReq dlClientId dlClientSecret "client_credentials")
    >>= liftEither
    <&> (^. #access_token)

getQuote :: DlBAConfig -> DelhiveryConfig -> QuoteReq -> Flow (Either Error QuoteRes)
getQuote ba@DlBAConfig {..} conf@DelhiveryConfig {..} quoteReq = do
  token <- getBearerToken <$> fetchToken ba conf
  API.getQuote token dlUrl quoteReq

getBearerToken :: Token -> Token
getBearerToken a = Token (T.pack "Bearer " <> getToken a)
