{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module API.Dashboard.Driver where

import qualified "dashboard-helper-api" Dashboard.ProviderPlatform.Driver as Common
import qualified Domain.Action.Dashboard.Driver as DDriver
import qualified Domain.Action.UI.Driver as Driver
import qualified Domain.Types.Invoice as INV
import qualified Domain.Types.Merchant as DM
import Environment
import Kernel.Prelude
import Kernel.Types.APISuccess (APISuccess)
import Kernel.Types.Id
import Kernel.Utils.Common (withFlowHandlerAPI)
import Servant hiding (throwError)

type API =
  "driver"
    :> ( Common.DriverDocumentsInfoAPI
           :<|> Common.DriverAadhaarInfoAPI
           :<|> Common.DriverAadhaarInfoByPhoneAPI
           :<|> Common.DriverListAPI
           :<|> Common.DriverOutstandingBalanceAPI
           :<|> Common.DriverActivityAPI
           :<|> Common.EnableDriverAPI
           :<|> Common.DisableDriverAPI
           :<|> Common.BlockDriverWithReasonAPI
           :<|> Common.BlockDriverAPI
           :<|> Common.DriverBlockReasonListAPI
           :<|> DriverCashCollectionAPI
           :<|> DriverCashExemptionAPI
           :<|> Common.UnblockDriverAPI
           :<|> Common.DriverLocationAPI
           :<|> DriverInfoAPI
           :<|> Common.DeleteDriverAPI
           :<|> Common.UnlinkVehicleAPI
           :<|> Common.UnlinkDLAPI
           :<|> Common.UnlinkAadhaarAPI
           :<|> Common.EndRCAssociationAPI
           :<|> Common.UpdatePhoneNumberAPI
           :<|> Common.UpdateDriverAadhaarAPI
           :<|> Common.AddVehicleAPI
           :<|> AddVehicleForFleetAPI
           :<|> GetAllVehicleForFleetAPI
           :<|> FleetUnlinkVehicleAPI
           :<|> FleetRemoveVehicleAPI
           :<|> FleetStatsAPI
           :<|> Common.UpdateDriverNameAPI
           :<|> Common.SetRCStatusAPI
           :<|> Common.DeleteRCAPI
           :<|> Common.ClearOnRideStuckDriversAPI
           :<|> Common.GetDriverHomeLocationAPI
           :<|> Common.UpdateDriverHomeLocationAPI
           :<|> Common.IncrementDriverGoToCountAPI
           :<|> DriverPaymentHistoryAPI
           :<|> DriverPaymentHistoryEntityDetailsAPI
           :<|> Common.UpdateSubscriptionDriverFeeAndInvoiceAPI
           :<|> SendSmsToDriverAPI
       )

-- driver cash collection api ----------------------------------------
-- have to write like that because in this case i have to store the dashboard used id for it. and which i am getting internally
type DriverCashCollectionAPI =
  Capture "driverId" (Id Common.Driver)
    :> "collectCash"
    :> ReqBody '[JSON] Text
    :> Post '[JSON] APISuccess

-------------------------------------

-- driver cash exemption api ----------------------------------------

type DriverCashExemptionAPI =
  Capture "driverId" (Id Common.Driver)
    :> "exemptCash"
    :> ReqBody '[JSON] Text
    :> Post '[JSON] APISuccess

----- payment history ----------
type DriverPaymentHistoryAPI =
  Capture "driverId" (Id Common.Driver)
    :> "payments"
    :> "history"
    :> QueryParam "paymentMode" INV.InvoicePaymentMode
    :> QueryParam "limit" Int
    :> QueryParam "offset" Int
    :> Get '[JSON] Driver.HistoryEntityV2

----------- payment history entry  -------------
type DriverPaymentHistoryEntityDetailsAPI =
  Capture "driverId" (Id Common.Driver)
    :> "payments"
    :> "history"
    :> Capture "invoiceId" (Id INV.Invoice)
    :> "entity"
    :> Get '[JSON] Driver.HistoryEntryDetailsEntityV2

-----------------------------------

-- --- add vehicle for driver api so here  we are passing the fleet owner api----

type AddVehicleForFleetAPI =
  Capture "mobileNo" Text
    :> QueryParam "mobileCountryCode" Text
    :> Capture "fleetOwnerId" Text
    :> "addVehicle"
    :> "fleet"
    :> ReqBody '[JSON] Common.AddVehicleReq
    :> Post '[JSON] APISuccess

-- --- add vehicle for driver api so here  we are passing the fleet owner api----

type GetAllVehicleForFleetAPI =
  Capture "fleetOwnerId" Text
    :> "getAllVehicle"
    :> "fleet"
    :> Get '[JSON] Common.ListVehicleRes

type DriverInfoAPI =
  "info"
    :> QueryParam "mobileNumber" Text
    :> QueryParam "mobileCountryCode" Text
    :> QueryParam "vehicleNumber" Text
    :> QueryParam "dlNumber" Text
    :> QueryParam "rcNumber" Text
    :> Capture "fleetOwnerId" Text
    :> Capture "mbFleet" Bool
    :> Get '[JSON] Common.DriverInfoRes

type FleetUnlinkVehicleAPI =
  Capture "fleetOwnerId" Text
    :> Capture "vehicleNo" Text
    :> QueryParam "mobileCountryCode" Text
    :> Capture "driverMobileNo" Text
    :> "unlink"
    :> "fleet"
    :> Post '[JSON] APISuccess

type FleetRemoveVehicleAPI =
  Capture "fleetOwnerId" Text
    :> Capture "vehicleNo" Text
    :> "remove"
    :> "fleet"
    :> Post '[JSON] APISuccess

type FleetStatsAPI =
  Capture "fleetOwnerId" Text
    :> "stats"
    :> "fleet"
    :> Get '[JSON] Common.FleetStatsRes

-------------------------------------------------------------------
------- Send Sms to Driver ----------------------------------------

type SendSmsToDriverViaDashboardAPI =
  Capture "driverId" (Id Common.Driver)
    :> "sendSms"
    :> ReqBody '[JSON] DDriver.SendSmsReq
    :> Post '[JSON] APISuccess

type SendSmsToDriverAPI =
  Capture "driverId" (Id Common.Driver)
    :> Capture "volunteerId" Text
    :> "sendSms"
    :> ReqBody '[JSON] DDriver.SendSmsReq
    :> Post '[JSON] APISuccess

handler :: ShortId DM.Merchant -> FlowServer API
handler merchantId =
  driverDocumentsInfo merchantId
    :<|> driverAadhaarInfo merchantId
    :<|> driverAadhaarInfoByPhone merchantId
    :<|> listDrivers merchantId
    :<|> getDriverDue merchantId
    :<|> driverActivity merchantId
    :<|> enableDriver merchantId
    :<|> disableDriver merchantId
    :<|> blockDriverWithReason merchantId
    :<|> blockDriver merchantId
    :<|> blockReasonList merchantId
    :<|> collectCash merchantId
    :<|> exemptCash merchantId
    :<|> unblockDriver merchantId
    :<|> driverLocation merchantId
    :<|> driverInfo merchantId
    :<|> deleteDriver merchantId
    :<|> unlinkVehicle merchantId
    :<|> unlinkDL merchantId
    :<|> unlinkAadhaar merchantId
    :<|> endRCAssociation merchantId
    :<|> updatePhoneNumber merchantId
    :<|> updateByPhoneNumber merchantId
    :<|> addVehicle merchantId
    :<|> addVehicleForFleet merchantId
    :<|> getAllVehicleForFleet merchantId
    :<|> fleetUnlinkVehicle merchantId
    :<|> fleetRemoveVehicle merchantId
    :<|> fleetStats merchantId
    :<|> updateDriverName merchantId
    :<|> setRCStatus merchantId
    :<|> deleteRC merchantId
    :<|> clearOnRideStuckDrivers merchantId
    :<|> getDriverHomeLocation merchantId
    :<|> updateDriverHomeLocation merchantId
    :<|> incrementDriverGoToCount merchantId
    :<|> getPaymentHistory merchantId
    :<|> getPaymentHistoryEntityDetails merchantId
    :<|> updateDriverSubscriptionDriverFeeAndInvoiceUpdate merchantId
    :<|> sendSmsToDriver merchantId

driverDocumentsInfo :: ShortId DM.Merchant -> FlowHandler Common.DriverDocumentsInfoRes
driverDocumentsInfo = withFlowHandlerAPI . DDriver.driverDocumentsInfo

driverAadhaarInfo :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler Common.DriverAadhaarInfoRes
driverAadhaarInfo merchantShortId = withFlowHandlerAPI . DDriver.driverAadhaarInfo merchantShortId

driverAadhaarInfoByPhone :: ShortId DM.Merchant -> Text -> FlowHandler Common.DriverAadhaarInfoByPhoneReq
driverAadhaarInfoByPhone merchantShortId = withFlowHandlerAPI . DDriver.driverAadhaarInfoByPhone merchantShortId

listDrivers :: ShortId DM.Merchant -> Maybe Int -> Maybe Int -> Maybe Bool -> Maybe Bool -> Maybe Bool -> Maybe Bool -> Maybe Text -> Maybe Text -> FlowHandler Common.DriverListRes
listDrivers merchantShortId mbLimit mbOffset verified enabled blocked mbSubscribed vechicleNumberSearchString =
  withFlowHandlerAPI . DDriver.listDrivers merchantShortId mbLimit mbOffset verified enabled blocked mbSubscribed vechicleNumberSearchString

getDriverDue :: ShortId DM.Merchant -> Maybe Text -> Text -> FlowHandler [Common.DriverOutstandingBalanceResp]
getDriverDue merchantShortId mobileCountryCode phone =
  withFlowHandlerAPI $ DDriver.getDriverDue merchantShortId mobileCountryCode phone

driverActivity :: ShortId DM.Merchant -> FlowHandler Common.DriverActivityRes
driverActivity = withFlowHandlerAPI . DDriver.driverActivity

enableDriver :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
enableDriver merchantShortId = withFlowHandlerAPI . DDriver.enableDriver merchantShortId

disableDriver :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
disableDriver merchantShortId = withFlowHandlerAPI . DDriver.disableDriver merchantShortId

blockDriverWithReason :: ShortId DM.Merchant -> Id Common.Driver -> Common.BlockDriverWithReasonReq -> FlowHandler APISuccess
blockDriverWithReason merchantShortId driverId = withFlowHandlerAPI . DDriver.blockDriverWithReason merchantShortId driverId

blockDriver :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
blockDriver merchantShortId = withFlowHandlerAPI . DDriver.blockDriver merchantShortId

blockReasonList :: ShortId DM.Merchant -> FlowHandler [Common.BlockReason]
blockReasonList _ = withFlowHandlerAPI DDriver.blockReasonList

collectCash :: ShortId DM.Merchant -> Id Common.Driver -> Text -> FlowHandler APISuccess
collectCash merchantShortId driverId = withFlowHandlerAPI . DDriver.collectCash merchantShortId driverId

exemptCash :: ShortId DM.Merchant -> Id Common.Driver -> Text -> FlowHandler APISuccess
exemptCash merchantShortId driverId = withFlowHandlerAPI . DDriver.exemptCash merchantShortId driverId

unblockDriver :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
unblockDriver merchantShortId = withFlowHandlerAPI . DDriver.unblockDriver merchantShortId

driverLocation :: ShortId DM.Merchant -> Maybe Int -> Maybe Int -> Common.DriverIds -> FlowHandler Common.DriverLocationRes
driverLocation merchantShortId mbLimit mbOffset = withFlowHandlerAPI . DDriver.driverLocation merchantShortId mbLimit mbOffset

driverInfo :: ShortId DM.Merchant -> Maybe Text -> Maybe Text -> Maybe Text -> Maybe Text -> Maybe Text -> Text -> Bool -> FlowHandler Common.DriverInfoRes
driverInfo merchantShortId mbMobileNumber mbMobileCountryCode mbVehicleNumber mbRcNumber mbDlNumber fleetOwnerId = withFlowHandlerAPI . DDriver.driverInfo merchantShortId mbMobileNumber mbMobileCountryCode mbVehicleNumber mbDlNumber mbRcNumber fleetOwnerId

deleteDriver :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
deleteDriver merchantShortId = withFlowHandlerAPI . DDriver.deleteDriver merchantShortId

unlinkVehicle :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
unlinkVehicle merchantShortId = withFlowHandlerAPI . DDriver.unlinkVehicle merchantShortId

unlinkDL :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
unlinkDL merchantShortId = withFlowHandlerAPI . DDriver.unlinkDL merchantShortId

unlinkAadhaar :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
unlinkAadhaar merchantShortId = withFlowHandlerAPI . DDriver.unlinkAadhaar merchantShortId

endRCAssociation :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
endRCAssociation merchantShortId = withFlowHandlerAPI . DDriver.endRCAssociation merchantShortId

updatePhoneNumber :: ShortId DM.Merchant -> Id Common.Driver -> Common.UpdatePhoneNumberReq -> FlowHandler APISuccess
updatePhoneNumber merchantShortId driverId = withFlowHandlerAPI . DDriver.updatePhoneNumber merchantShortId driverId

updateByPhoneNumber :: ShortId DM.Merchant -> Text -> Common.UpdateDriverDataReq -> FlowHandler APISuccess
updateByPhoneNumber merchantShortId mobileNo = withFlowHandlerAPI . DDriver.updateByPhoneNumber merchantShortId mobileNo

addVehicle :: ShortId DM.Merchant -> Id Common.Driver -> Common.AddVehicleReq -> FlowHandler APISuccess
addVehicle merchantShortId driverId = withFlowHandlerAPI . DDriver.addVehicle merchantShortId driverId

addVehicleForFleet :: ShortId DM.Merchant -> Text -> Maybe Text -> Text -> Common.AddVehicleReq -> FlowHandler APISuccess
addVehicleForFleet merchantShortId phoneNo mbMobileCountryCode fleetOwnerId = withFlowHandlerAPI . DDriver.addVehicleForFleet merchantShortId phoneNo mbMobileCountryCode fleetOwnerId

getAllVehicleForFleet :: ShortId DM.Merchant -> Text -> FlowHandler Common.ListVehicleRes
getAllVehicleForFleet merchantId = withFlowHandlerAPI . DDriver.getAllVehicleForFleet merchantId

fleetUnlinkVehicle :: ShortId DM.Merchant -> Text -> Text -> Maybe Text -> Text -> FlowHandler APISuccess
fleetUnlinkVehicle merchantShortId fleetOwnerId vehicleNo mbMobileCountryCode = withFlowHandlerAPI . DDriver.fleetUnlinkVehicle merchantShortId fleetOwnerId vehicleNo mbMobileCountryCode

fleetRemoveVehicle :: ShortId DM.Merchant -> Text -> Text -> FlowHandler APISuccess
fleetRemoveVehicle merchantShortId fleetOwnerId = withFlowHandlerAPI . DDriver.fleetRemoveVehicle merchantShortId fleetOwnerId

fleetStats :: ShortId DM.Merchant -> Text -> FlowHandler Common.FleetStatsRes
fleetStats merchantShortId = withFlowHandlerAPI . DDriver.fleetStats merchantShortId

updateDriverName :: ShortId DM.Merchant -> Id Common.Driver -> Common.UpdateDriverNameReq -> FlowHandler APISuccess
updateDriverName merchantShortId driverId = withFlowHandlerAPI . DDriver.updateDriverName merchantShortId driverId

clearOnRideStuckDrivers :: ShortId DM.Merchant -> Maybe Int -> FlowHandler Common.ClearOnRideStuckDriversRes
clearOnRideStuckDrivers merchantId = withFlowHandlerAPI . DDriver.clearOnRideStuckDrivers merchantId

getDriverHomeLocation :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler Common.GetHomeLocationsRes
getDriverHomeLocation merchantShortId = withFlowHandlerAPI . DDriver.getDriverHomeLocation merchantShortId

updateDriverHomeLocation :: ShortId DM.Merchant -> Id Common.Driver -> Common.UpdateDriverHomeLocationReq -> FlowHandler APISuccess
updateDriverHomeLocation merchantShortId driverId = withFlowHandlerAPI . DDriver.updateDriverHomeLocation merchantShortId driverId

incrementDriverGoToCount :: ShortId DM.Merchant -> Id Common.Driver -> FlowHandler APISuccess
incrementDriverGoToCount merchantShortId = withFlowHandlerAPI . DDriver.incrementDriverGoToCount merchantShortId

setRCStatus :: ShortId DM.Merchant -> Id Common.Driver -> Common.RCStatusReq -> FlowHandler APISuccess
setRCStatus merchantShortId driverId = withFlowHandlerAPI . DDriver.setRCStatus merchantShortId driverId

deleteRC :: ShortId DM.Merchant -> Id Common.Driver -> Common.DeleteRCReq -> FlowHandler APISuccess
deleteRC merchantShortId driverId = withFlowHandlerAPI . DDriver.deleteRC merchantShortId driverId

getPaymentHistory :: ShortId DM.Merchant -> Id Common.Driver -> Maybe INV.InvoicePaymentMode -> Maybe Int -> Maybe Int -> FlowHandler Driver.HistoryEntityV2
getPaymentHistory merchantShortId driverId invoicePaymentMode limit offset = withFlowHandlerAPI $ DDriver.getPaymentHistory merchantShortId driverId invoicePaymentMode limit offset

getPaymentHistoryEntityDetails :: ShortId DM.Merchant -> Id Common.Driver -> Id INV.Invoice -> FlowHandler Driver.HistoryEntryDetailsEntityV2
getPaymentHistoryEntityDetails merchantShortId driverId invoiceId = do
  withFlowHandlerAPI $ DDriver.getPaymentHistoryEntityDetails merchantShortId driverId invoiceId

updateDriverSubscriptionDriverFeeAndInvoiceUpdate :: ShortId DM.Merchant -> Id Common.Driver -> Common.SubscriptionDriverFeesAndInvoicesToUpdate -> FlowHandler Common.SubscriptionDriverFeesAndInvoicesToUpdate
updateDriverSubscriptionDriverFeeAndInvoiceUpdate merchantShortId driverId req = withFlowHandlerAPI $ DDriver.updateSubscriptionDriverFeeAndInvoice merchantShortId driverId req

sendSmsToDriver :: ShortId DM.Merchant -> Id Common.Driver -> Text -> DDriver.SendSmsReq -> FlowHandler APISuccess
sendSmsToDriver merchantShortId driverId volunteerId = withFlowHandlerAPI . DDriver.sendSmsToDriver merchantShortId driverId volunteerId
