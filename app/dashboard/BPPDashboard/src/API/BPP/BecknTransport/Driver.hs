module API.BPP.BecknTransport.Driver
  ( API,
    handler,
  )
where

import qualified BPPClient.BecknTransport as Client
import Beckn.Prelude
import Beckn.Types.APISuccess (APISuccess (..))
import Beckn.Types.Error
import Beckn.Types.Id
import Beckn.Utils.Common (MonadFlow, throwError, withFlowHandlerAPI)
import Beckn.Utils.Validation (runRequestValidation)
import qualified "dashboard-bpp-helper-api" Dashboard.Common.Driver as Common
import qualified "lib-dashboard" Domain.Types.Merchant as DM
import qualified "lib-dashboard" Domain.Types.Transaction as DT
import "lib-dashboard" Environment
import Servant hiding (throwError)
import qualified SharedLogic.Transaction as T
import "lib-dashboard" Tools.Auth
import "lib-dashboard" Tools.Auth.Merchant

type API =
  "driver"
    :> ( DriverListAPI
           :<|> DriverActivityAPI
           :<|> EnableDriverAPI
           :<|> DisableDriverAPI
           :<|> DriverLocationAPI
           :<|> DriverInfoAPI
           :<|> DeleteDriverAPI
           :<|> UnlinkVehicleAPI
           :<|> UpdatePhoneNumberAPI
           :<|> AddVehicleAPI
       )

type DriverListAPI =
  ApiAuth 'BECKN_TRANSPORT 'READ_ACCESS 'DRIVERS
    :> Common.DriverListAPI

type DriverActivityAPI =
  ApiAuth 'BECKN_TRANSPORT 'READ_ACCESS 'DRIVERS
    :> Common.DriverActivityAPI

type EnableDriverAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.EnableDriverAPI

type DisableDriverAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.DisableDriverAPI

type DriverLocationAPI =
  ApiAuth 'BECKN_TRANSPORT 'READ_ACCESS 'DRIVERS
    :> Common.DriverLocationAPI

type DriverInfoAPI =
  ApiAuth 'BECKN_TRANSPORT 'READ_ACCESS 'DRIVERS
    :> Common.DriverInfoAPI

type DeleteDriverAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.DeleteDriverAPI

type UnlinkVehicleAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.UnlinkVehicleAPI

type UpdatePhoneNumberAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.UpdatePhoneNumberAPI

type AddVehicleAPI =
  ApiAuth 'BECKN_TRANSPORT 'WRITE_ACCESS 'DRIVERS
    :> Common.AddVehicleAPI

handler :: ShortId DM.Merchant -> FlowServer API
handler merchantId =
  listDriver merchantId
    :<|> driverActivity merchantId
    :<|> enableDriver merchantId
    :<|> disableDriver merchantId
    :<|> driverLocation merchantId
    :<|> driverInfo merchantId
    :<|> deleteDriver merchantId
    :<|> unlinkVehicle merchantId
    :<|> updatePhoneNumber merchantId
    :<|> addVehicle merchantId

buildTransaction ::
  ( MonadFlow m,
    ToJSON request
  ) =>
  Common.DriverEndpoint ->
  ApiTokenInfo ->
  Id Common.Driver ->
  Maybe request ->
  m DT.Transaction
buildTransaction endpoint apiTokenInfo driverId =
  T.buildTransaction (DT.DriverAPI endpoint) apiTokenInfo (Just driverId) Nothing

listDriver :: ShortId DM.Merchant -> ApiTokenInfo -> Maybe Int -> Maybe Int -> Maybe Bool -> Maybe Bool -> Maybe Bool -> Maybe Text -> FlowHandler Common.DriverListRes
listDriver merchantShortId apiTokenInfo mbLimit mbOffset verified enabled blocked phone = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  Client.callBecknTransportBPP checkedMerchantId (.drivers.listDrivers) mbLimit mbOffset verified enabled blocked phone

driverActivity :: ShortId DM.Merchant -> ApiTokenInfo -> FlowHandler Common.DriverActivityRes
driverActivity merchantShortId apiTokenInfo = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  Client.callBecknTransportBPP checkedMerchantId (.drivers.driverActivity)

enableDriver :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> FlowHandler APISuccess
enableDriver merchantShortId apiTokenInfo driverId = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.EnableDriverEndpoint apiTokenInfo driverId T.emptyRequest
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.enableDriver) driverId

disableDriver :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> FlowHandler APISuccess
disableDriver merchantShortId apiTokenInfo driverId = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.DisableDriverEndpoint apiTokenInfo driverId T.emptyRequest
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.disableDriver) driverId

driverLocation :: ShortId DM.Merchant -> ApiTokenInfo -> Maybe Int -> Maybe Int -> Common.DriverIds -> FlowHandler Common.DriverLocationRes
driverLocation merchantShortId apiTokenInfo mbLimit mbOffset req = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  Client.callBecknTransportBPP checkedMerchantId (.drivers.driverLocation) mbLimit mbOffset req

driverInfo :: ShortId DM.Merchant -> ApiTokenInfo -> Maybe Text -> Maybe Text -> FlowHandler Common.DriverInfoRes
driverInfo merchantShortId apiTokenInfo mbMobileNumber mbVehicleNumber = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  when (isJust mbMobileNumber == isJust mbVehicleNumber) $
    throwError $ InvalidRequest "Exactly one of query parameters \"mobileNumber\", \"vehicleNumber\" is required"
  Client.callBecknTransportBPP checkedMerchantId (.drivers.driverInfo) mbMobileNumber mbVehicleNumber

deleteDriver :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> FlowHandler APISuccess
deleteDriver merchantShortId apiTokenInfo driverId = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.DeleteDriverEndpoint apiTokenInfo driverId T.emptyRequest
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.deleteDriver) driverId

unlinkVehicle :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> FlowHandler APISuccess
unlinkVehicle merchantShortId apiTokenInfo driverId = withFlowHandlerAPI $ do
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.UnlinkVehicleEndpoint apiTokenInfo driverId T.emptyRequest
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.unlinkVehicle) driverId

updatePhoneNumber :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> Common.UpdatePhoneNumberReq -> FlowHandler APISuccess
updatePhoneNumber merchantShortId apiTokenInfo driverId req = withFlowHandlerAPI $ do
  runRequestValidation Common.validateUpdatePhoneNumberReq req
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.UpdatePhoneNumberEndpoint apiTokenInfo driverId $ Just req
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.updatePhoneNumber) driverId req

addVehicle :: ShortId DM.Merchant -> ApiTokenInfo -> Id Common.Driver -> Common.AddVehicleReq -> FlowHandler APISuccess
addVehicle merchantShortId apiTokenInfo driverId req = withFlowHandlerAPI $ do
  runRequestValidation Common.validateAddVehicleReq req
  checkedMerchantId <- merchantAccessCheck merchantShortId apiTokenInfo.merchant.shortId
  transaction <- buildTransaction Common.AddVehicleEndpoint apiTokenInfo driverId $ Just req
  T.withTransactionStoring transaction $
    Client.callBecknTransportBPP checkedMerchantId (.drivers.addVehicle) driverId req
