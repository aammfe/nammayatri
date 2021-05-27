module Mobility.Fixtures where

import "app-backend" App.Routes as AbeRoutes
import "beckn-transport" App.Routes as TbeRoutes
import Beckn.External.FCM.Types
import Beckn.Types.APISuccess
import Beckn.Types.App
import Beckn.Types.Core.DecimalValue
import Beckn.Types.Core.Price
import Beckn.Types.Id
import Beckn.Types.Mobility.Payload
import Data.Time
import EulerHS.Prelude
import Servant hiding (Context)
import Servant.Client
import qualified Types.API.Cancel as CancelAPI
import qualified "app-backend" Types.API.Case as AppCase
import qualified "beckn-transport" Types.API.Case as TbeCase
import qualified Types.API.Confirm as ConfirmAPI
import qualified "beckn-transport" Types.API.DriverInformation as DriverInformationAPI
import qualified "app-backend" Types.API.Feedback as AppFeedback
import qualified "beckn-transport" Types.API.Person as TbePerson
import qualified "app-backend" Types.API.ProductInstance as AppPI
import qualified "beckn-transport" Types.API.ProductInstance as TbePI
import qualified "app-backend" Types.API.Registration as Reg
import qualified "beckn-transport" Types.API.Ride as RideAPI
import qualified "app-backend" Types.API.Search as AppBESearch
import qualified "app-backend" Types.API.Serviceability as AppServ
import "beckn-transport" Types.App
import qualified "app-backend" Types.Common as AppCommon
import qualified "app-backend" Types.Storage.CancellationReason as AbeCRC
import qualified "app-backend" Types.Storage.Case as BCase
import qualified "beckn-transport" Types.Storage.Case as TCase
import qualified "app-backend" Types.Storage.Person as BPerson
import qualified "beckn-transport" Types.Storage.Person as TPerson
import qualified "app-backend" Types.Storage.ProductInstance as BPI
import qualified "beckn-transport" Types.Storage.ProductInstance as TPI
import qualified "app-backend" Types.Storage.RegistrationToken as BSR
import qualified Types.Storage.Vehicle as SV

address :: AppCommon.Address
address =
  AppCommon.Address
    { door = "#817",
      building = "Juspay Apartments",
      street = "27th Main",
      area = "8th Block Koramangala",
      city = "Bangalore",
      country = "India",
      areaCode = "560047",
      state = "Karnataka"
    }

location :: AppCommon.GPS -> AppCommon.Location
location gps =
  AppCommon.Location
    { gps = Just gps,
      address = Just address,
      city = Nothing
    }

vehicle :: AppCommon.Vehicle
vehicle =
  AppCommon.Vehicle
    { category = Just AppCommon.CAR,
      capacity = Nothing,
      make = Nothing,
      model = Nothing,
      size = Nothing,
      variant = "SUV",
      color = Just "Black",
      registrationNumber = Nothing
    }

intentPayload :: Payload
intentPayload =
  Payload
    { travellers = [],
      traveller_count = Just 2,
      luggage = Nothing,
      travel_group = Nothing
    }

price :: Price
price =
  let amt = DecimalValue "800" Nothing
   in Price
        { currency = "INR",
          value = Just amt,
          estimated_value = Just amt,
          computed_value = Just amt,
          listed_value = Just amt,
          offered_value = Just amt,
          minimum_value = Just amt,
          maximum_value = Just amt
        }

getStop :: UTCTime -> AppCommon.GPS -> AppCommon.Stop
getStop stopTime gps =
  AppCommon.Stop
    { location = location gps,
      arrivalTime = AppCommon.StopTime stopTime (Just stopTime),
      departureTime = AppCommon.StopTime stopTime (Just stopTime)
    }

searchReq :: Text -> UTCTime -> UTCTime -> AppBESearch.SearchReq
searchReq tid utcTime futureTime =
  AppBESearch.SearchReq
    { transaction_id = tid,
      startTime = utcTime,
      origin = getStop futureTime $ AppCommon.GPS "10.0739" "76.2733",
      destination = getStop futureTime $ AppCommon.GPS "10.5449" "76.4356",
      vehicle = vehicle,
      travellers = [],
      fare = AppCommon.DecimalValue "360" $ Just "50"
    }

bppTransporterOrgId :: Text
bppTransporterOrgId = "70c76e36-f035-46fd-98a7-572dc8934323"

getFutureTime :: IO UTCTime
getFutureTime =
  -- Generate a time 2 hours in to the future else booking will fail
  addUTCTime 7200 <$> getCurrentTime

searchServices ::
  Text ->
  AppBESearch.SearchReq ->
  ClientM AppBESearch.SearchRes
searchServices :<|> _ = client (Proxy :: Proxy AbeRoutes.SearchAPI)

buildSearchReq :: Text -> IO AppBESearch.SearchReq
buildSearchReq guid = do
  futureTime <- getFutureTime
  utcTime <- getCurrentTime
  pure $ searchReq guid utcTime futureTime

cancelRide :: Text -> CancelAPI.CancelReq -> ClientM CancelAPI.CancelRes
cancelRide :<|> _ = client (Proxy :: Proxy AbeRoutes.CancelAPI)

rideRespond :: Text -> RideAPI.SetDriverAcceptanceReq -> ClientM RideAPI.SetDriverAcceptanceRes
rideStart :: Text -> Id TPI.ProductInstance -> RideAPI.StartRideReq -> ClientM APISuccess
rideEnd :: Text -> Id TPI.ProductInstance -> ClientM APISuccess
rideCancel :: Text -> Id TPI.ProductInstance -> RideAPI.CancelRideReq -> ClientM APISuccess
rideRespond :<|> rideStart :<|> rideEnd :<|> rideCancel = client (Proxy :: Proxy TbeRoutes.RideAPI)

getDriverInfo :: Text -> ClientM DriverInformationAPI.DriverInformationResponse
setDriverOnline :: Text -> Bool -> ClientM APISuccess
getNotificationInfo :: Text -> Maybe (Id Ride) -> ClientM DriverInformationAPI.GetRideInfoRes
_
  :<|> getDriverInfo
  :<|> setDriverOnline
  :<|> getNotificationInfo
  :<|> _
  :<|> _
  :<|> _ = client (Proxy :: Proxy TbeRoutes.DriverInformationAPI)

buildAppCancelReq :: Text -> CancelAPI.Entity -> CancelAPI.CancelReq
buildAppCancelReq entityId entityType =
  CancelAPI.CancelReq
    { entityId = entityId,
      entityType = entityType,
      rideCancellationReason = Just $ CancelAPI.RideCancellationReasonEntity (AbeCRC.CancellationReasonCode "OTHER") Nothing
    }

-- For the idea behind generating a client, when nested routes are involved,
-- see https://github.com/haskell-servant/servant/issues/335
newtype CaseAPIClient = CaseAPIClient {mkCaseClient :: Text -> CaseClient}

data CaseClient = CaseClient
  { getCaseListRes ::
      BCase.CaseType ->
      [BCase.CaseStatus] ->
      Maybe Integer ->
      Maybe Integer ->
      ClientM AppCase.CaseListRes,
    getCaseStatusRes :: Id BCase.Case -> ClientM AppCase.GetStatusRes
  }

getCase :: CaseAPIClient
getCase = CaseAPIClient {..}
  where
    caseAPIClient = client (Proxy :: Proxy AbeRoutes.CaseAPI)
    mkCaseClient regToken = CaseClient {..}
      where
        getCaseListRes :<|> getCaseStatusRes = caseAPIClient regToken

buildCaseListRes :: Text -> ClientM AppCase.CaseListRes
buildCaseListRes regToken = do
  let CaseAPIClient {..} = getCase
      CaseClient {..} = mkCaseClient regToken
  getCaseListRes BCase.RIDESEARCH [BCase.NEW] (Just 10) (Just 0)

buildCaseStatusRes :: Text -> ClientM AppCase.GetStatusRes
buildCaseStatusRes caseId = do
  let CaseAPIClient {..} = getCase
      CaseClient {..} = mkCaseClient appRegistrationToken
      appCaseId = Id caseId
  getCaseStatusRes appCaseId

appConfirmRide :: Text -> ConfirmAPI.ConfirmReq -> ClientM APISuccess
appConfirmRide :<|> _ = client (Proxy :: Proxy AbeRoutes.ConfirmAPI)

appFeedback :: Text -> AppFeedback.FeedbackReq -> ClientM APISuccess
appFeedback = client (Proxy :: Proxy AbeRoutes.FeedbackAPI)

callAppFeedback :: Int -> Id TPI.ProductInstance -> ClientM APISuccess
callAppFeedback ratingValue productInstanceId =
  let request =
        AppFeedback.FeedbackReq
          { productInstanceId = getId productInstanceId,
            rating = ratingValue
          }
   in appFeedback appRegistrationToken request

buildAppConfirmReq :: Text -> Text -> ConfirmAPI.ConfirmReq
buildAppConfirmReq cid pid =
  ConfirmAPI.ConfirmReq
    { caseId = cid,
      productInstanceId = pid
    }

listLeads :: Text -> [TCase.CaseStatus] -> TCase.CaseType -> Maybe Int -> Maybe Int -> ClientM [TbeCase.CaseRes]
listLeads = client (Proxy :: Proxy TbeRoutes.CaseAPI)

buildListLeads :: ClientM [TbeCase.CaseRes]
buildListLeads = listLeads appRegistrationToken [TCase.NEW] TCase.RIDESEARCH (Just 50) Nothing

listOrgRides :: Text -> [TPI.ProductInstanceStatus] -> [TCase.CaseType] -> Maybe Int -> Maybe Int -> ClientM TbePI.ProductInstanceList
listDriverRides :: Text -> Id TPerson.Person -> Maybe Integer -> Maybe Integer -> ClientM TbePI.RideListRes
listVehicleRides :: Text -> Id SV.Vehicle -> ClientM TbePI.RideListRes
listCasesByProductInstance :: Text -> Id TPI.ProductInstance -> Maybe TCase.CaseType -> ClientM [TbeCase.CaseRes]
listOrgRides :<|> listDriverRides :<|> listVehicleRides :<|> listCasesByProductInstance = client (Proxy :: Proxy TbeRoutes.ProductInstanceAPI)

listPIs :: Text -> [BPI.ProductInstanceStatus] -> [BCase.CaseType] -> Maybe Int -> Maybe Int -> ClientM AppPI.ProductInstanceList
listPIs = client (Proxy :: Proxy AbeRoutes.ProductInstanceAPI)

buildListPIs :: BPI.ProductInstanceStatus -> ClientM AppPI.ProductInstanceList
buildListPIs status = listPIs appRegistrationToken [status] [BCase.RIDEORDER] (Just 50) Nothing

updatePerson :: Text -> TbePerson.UpdatePersonReq -> ClientM TbePerson.UpdatePersonRes
deletePerson :: Text -> Id TPerson.Person -> ClientM TbePerson.DeletePersonRes
_
  :<|> updatePerson
  :<|> deletePerson = client (Proxy :: Proxy TbeRoutes.PersonAPI)

buildUpdateCaseReq :: TbeCase.UpdateCaseReq
buildUpdateCaseReq =
  TbeCase.UpdateCaseReq
    { quote = Just 150.50,
      transporterChoice = "ACCEPTED"
    }

buildStartRideReq :: Text -> RideAPI.StartRideReq
buildStartRideReq otp =
  RideAPI.StartRideReq
    { RideAPI.otp = otp
    }

originServiceability :: RegToken -> AppServ.ServiceabilityReq -> ClientM AppServ.ServiceabilityRes
originServiceability regToken = origin
  where
    origin :<|> _ :<|> _ = client (Proxy :: Proxy AbeRoutes.ServiceabilityAPI) regToken

destinationServiceability :: RegToken -> AppServ.ServiceabilityReq -> ClientM AppServ.ServiceabilityRes
destinationServiceability regToken = destination
  where
    _ :<|> destination :<|> _ = client (Proxy :: Proxy AbeRoutes.ServiceabilityAPI) regToken

rideServiceability :: RegToken -> AppServ.RideServiceabilityReq -> ClientM AppServ.RideServiceabilityRes
rideServiceability regToken = ride
  where
    _ :<|> _ :<|> ride = client (Proxy :: Proxy AbeRoutes.ServiceabilityAPI) regToken

buildOrgRideReq :: TPI.ProductInstanceStatus -> TCase.CaseType -> ClientM TbePI.ProductInstanceList
buildOrgRideReq status csType = listOrgRides appRegistrationToken [status] [csType] (Just 50) Nothing

appRegistrationToken :: Text
appRegistrationToken = "ea37f941-427a-4085-a7d0-96240f166672"

driverToken :: Text
driverToken = "ca05cf3c-c88b-4a2f-8874-191659397e0d"

testVehicleId :: Text
testVehicleId = "0c1cd0bc-b3a4-4c6c-811f-900ccf4dfb94"

testDriverId :: Text
testDriverId = "6bc4bc84-2c43-425d-8853-22f47bd06691"

appInitiateLogin :: Reg.InitiateLoginReq -> ClientM Reg.InitiateLoginRes
appVerifyLogin :: Text -> Reg.LoginReq -> ClientM Reg.LoginRes
appReInitiateLogin :: Text -> Reg.ReInitiateLoginReq -> ClientM Reg.InitiateLoginRes
logout :: RegToken -> ClientM APISuccess
appInitiateLogin
  :<|> appVerifyLogin
  :<|> appReInitiateLogin
  :<|> logout =
    client (Proxy :: Proxy AbeRoutes.RegistrationAPI)

buildInitiateLoginReq :: Reg.InitiateLoginReq
buildInitiateLoginReq =
  Reg.InitiateLoginReq
    { medium = BSR.SMS,
      __type = BSR.OTP,
      mobileNumber = "9000090000",
      mobileCountryCode = "+91",
      role = Just BPerson.USER,
      deviceToken = Nothing
    }

buildLoginReq :: Reg.LoginReq
buildLoginReq =
  Reg.LoginReq
    { medium = BSR.SMS,
      __type = BSR.OTP,
      hash = "7891",
      mobileNumber = "9000090000",
      mobileCountryCode = "+91",
      deviceToken = Just $ FCMRecipientToken "AN_DEV_TOKEN"
    }

initiateLoginReq :: ClientM Reg.InitiateLoginRes
initiateLoginReq = appInitiateLogin buildInitiateLoginReq

verifyLoginReq :: Text -> ClientM Reg.LoginRes
verifyLoginReq tokenId = appVerifyLogin tokenId buildLoginReq

getAppBaseUrl :: BaseUrl
getAppBaseUrl =
  BaseUrl
    { baseUrlScheme = Http,
      baseUrlHost = "localhost",
      baseUrlPort = 8013,
      baseUrlPath = "/v1"
    }

getTransporterBaseUrl :: BaseUrl
getTransporterBaseUrl =
  BaseUrl
    { baseUrlScheme = Http,
      baseUrlHost = "localhost",
      baseUrlPort = 8014,
      baseUrlPath = "/v1"
    }
