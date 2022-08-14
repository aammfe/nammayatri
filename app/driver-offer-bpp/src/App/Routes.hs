module App.Routes where

import App.Routes.FarePolicy
import Beckn.Types.APISuccess
import Beckn.Types.App
import qualified Beckn.Types.Core.Taxi.API.Cancel as API
import qualified Beckn.Types.Core.Taxi.API.Confirm as API
import qualified Beckn.Types.Core.Taxi.API.Init as API
import qualified Beckn.Types.Core.Taxi.API.Rating as API
import qualified Beckn.Types.Core.Taxi.API.Search as API
import qualified Beckn.Types.Core.Taxi.API.Select as API
import qualified Beckn.Types.Core.Taxi.API.Track as API
import Beckn.Types.Id
import Beckn.Utils.Common
import Beckn.Utils.Servant.SignatureAuth
import Data.OpenApi
import Domain.Types.Organization (Organization)
import Domain.Types.Person as SP
import qualified Domain.Types.RegistrationToken as SRT
import qualified Domain.Types.Ride as DRide
import qualified Domain.Types.Vehicle.Variant as Variant
import Environment
import EulerHS.Prelude
import qualified Product.BecknProvider.Cancel as BP
import qualified Product.BecknProvider.Confirm as BP
import Product.BecknProvider.Init as BP
import Product.BecknProvider.Rating as BP
import Product.BecknProvider.Search as BP
import Product.BecknProvider.Select as BP
import qualified Product.BecknProvider.Track as BP
import qualified Product.Call as Call
import qualified Product.CancellationReason as CancellationReason
import qualified Product.Driver as Driver
import Product.DriveronBoarding.DriverOnBoarding as DO
import qualified Product.DriveronBoarding.Idfy as Idfy
import Product.DriveronBoarding.Status as Status
import qualified Product.Location as Location
import qualified Product.OrgAdmin as OrgAdmin
import qualified Product.Registration as Registration
import qualified Product.Ride as Ride
import qualified Product.RideAPI.CancelRide as RideAPI.CancelRide
import qualified Product.RideAPI.EndRide as RideAPI.EndRide
import qualified Product.RideAPI.StartRide as RideAPI.StartRide
import qualified Product.Transporter as Transporter
import qualified Product.Vehicle as Vehicle
import Servant
import Servant.OpenApi
import qualified Types.API.Call as CallAPI
import qualified Types.API.CancellationReason as CancellationReasonAPI
import qualified Types.API.Driver as DriverAPI
import Types.API.Driveronboarding.DriverOnBoarding
import Types.API.Driveronboarding.Status
import Types.API.Idfy
import Types.API.Location as Location
import qualified Types.API.OrgAdmin as OrgAdminAPI
import Types.API.Registration
import qualified Types.API.Ride as RideAPI
import Types.API.Transporter
import Types.API.Vehicle
import Utils.Auth (AdminTokenAuth, TokenAuth)

type DriverOfferAPI =
  MainAPI
    :<|> SwaggerAPI

type MainAPI =
  "ui" :> UIAPI
    :<|> "beckn" :> OrgBecknAPI

type UIAPI =
  HealthCheckAPI
    :<|> RegistrationAPI
    :<|> OrgAdminAPI
    :<|> DriverAPI
    :<|> VehicleAPI
    :<|> OrganizationAPI
    :<|> FarePolicyAPI
    :<|> LocationAPI
    :<|> RouteAPI
    :<|> RideAPI
    :<|> CallAPIs
    :<|> IdfyHandlerAPI
    :<|> OnBoardingAPI
    :<|> RideAPI
    :<|> CancellationReasonAPI

driverOfferAPI :: Proxy DriverOfferAPI
driverOfferAPI = Proxy

uiServer :: FlowServer UIAPI
uiServer =
  pure "App is UP"
    :<|> registrationFlow
    :<|> orgAdminFlow
    :<|> driverFlow
    :<|> vehicleFlow
    :<|> organizationFlow
    :<|> farePolicyFlow
    :<|> locationFlow
    :<|> routeFlow
    :<|> rideFlow
    :<|> callFlow
    :<|> idfyHandlerFlow
    :<|> onBoardingAPIFlow
    :<|> rideFlow
    :<|> cancellationReasonFlow

mainServer :: FlowServer MainAPI
mainServer =
  uiServer
    :<|> orgBecknApiFlow

driverOfferServer :: FlowServer DriverOfferAPI
driverOfferServer =
  mainServer
    :<|> writeSwaggerJSONFlow

---- Registration Flow ------
type RegistrationAPI =
  "auth"
    :> ( ReqBody '[JSON] AuthReq
           :> Post '[JSON] AuthRes
           :<|> Capture "authId" (Id SRT.RegistrationToken)
             :> "verify"
             :> ReqBody '[JSON] AuthVerifyReq
             :> Post '[JSON] AuthVerifyRes
           :<|> "otp"
             :> Capture "authId" (Id SRT.RegistrationToken)
             :> "resend"
             :> Post '[JSON] ResendAuthRes
           :<|> "logout"
             :> TokenAuth
             :> Post '[JSON] APISuccess
       )

registrationFlow :: FlowServer RegistrationAPI
registrationFlow =
  Registration.auth
    :<|> Registration.verify
    :<|> Registration.resend
    :<|> Registration.logout

type OrgAdminAPI =
  "orgAdmin" :> "profile"
    :> AdminTokenAuth
    :> Get '[JSON] OrgAdminAPI.OrgAdminProfileRes
    :<|> AdminTokenAuth
      :> ReqBody '[JSON] OrgAdminAPI.UpdateOrgAdminProfileReq
      :> Post '[JSON] OrgAdminAPI.UpdateOrgAdminProfileRes

orgAdminFlow :: FlowServer OrgAdminAPI
orgAdminFlow =
  OrgAdmin.getProfile
    :<|> OrgAdmin.updateProfile

type DriverAPI =
  "org" :> "driver"
    :> ( AdminTokenAuth
           :> ReqBody '[JSON] DriverAPI.OnboardDriverReq
           :> Post '[JSON] DriverAPI.OnboardDriverRes
           :<|> "list"
             :> AdminTokenAuth
             :> QueryParam "searchString" Text
             :> QueryParam "limit" Integer
             :> QueryParam "offset" Integer
             :> Get '[JSON] DriverAPI.ListDriverRes
           :<|> AdminTokenAuth
             :> Capture "driverId" (Id Person)
             :> MandatoryQueryParam "enabled" Bool
             :> Post '[JSON] APISuccess
           :<|> AdminTokenAuth
             :> Capture "driverId" (Id Person)
             :> Delete '[JSON] APISuccess
       )
    :<|> "driver"
      :> ( "setActivity"
             :> TokenAuth
             :> MandatoryQueryParam "active" Bool
             :> Post '[JSON] APISuccess
             :<|> "nearbyRideRequest"
               :> ( TokenAuth
                      :> Get '[JSON] DriverAPI.GetNearbySearchRequestsRes
                  )
             :<|> "searchRequest"
               :> ( TokenAuth
                      :> "quote"
                      :> "offer"
                      :> ReqBody '[JSON] DriverAPI.DriverOfferReq
                      :> Post '[JSON] APISuccess
                  )
             :<|> "profile"
               :> ( TokenAuth
                      :> Get '[JSON] DriverAPI.DriverInformationRes
                      :<|> TokenAuth
                        :> ReqBody '[JSON] DriverAPI.UpdateDriverReq
                        :> Post '[JSON] DriverAPI.UpdateDriverRes
                  )
         )

driverFlow :: FlowServer DriverAPI
driverFlow =
  ( Driver.createDriver
      :<|> Driver.listDriver
      :<|> Driver.changeDriverEnableState
      :<|> Driver.deleteDriver
  )
    :<|> ( Driver.setActivity
             :<|> Driver.getNearbySearchRequests
             :<|> Driver.offerQuote
             :<|> ( Driver.getInformation
                      :<|> Driver.updateDriver
                  )
         )

-- Following is vehicle flow
type VehicleAPI =
  "org" :> "vehicle"
    :> ( "list"
           :> AdminTokenAuth
           :> QueryParam "variant" Variant.Variant
           :> QueryParam "registrationNo" Text
           :> QueryParam "limit" Int
           :> QueryParam "offset" Int
           :> Get '[JSON] ListVehicleRes
           :<|> AdminTokenAuth
             :> Capture "driverId" (Id Person)
             :> ReqBody '[JSON] UpdateVehicleReq
             :> Post '[JSON] UpdateVehicleRes
           :<|> TokenAuth
             :> QueryParam "registrationNo" Text
             :> QueryParam "driverId" (Id Person)
             :> Get '[JSON] GetVehicleRes
       )

vehicleFlow :: FlowServer VehicleAPI
vehicleFlow =
  Vehicle.listVehicles
    :<|> Vehicle.updateVehicle
    :<|> Vehicle.getVehicle

-- Following is organization creation
type OrganizationAPI =
  "transporter"
    :> ( TokenAuth
           :> Get '[JSON] TransporterRec
           :<|> AdminTokenAuth
           :> Capture "orgId" (Id Organization)
           :> ReqBody '[JSON] UpdateTransporterReq
           :> Post '[JSON] UpdateTransporterRes
       )

organizationFlow :: FlowServer OrganizationAPI
organizationFlow =
  Transporter.getTransporter
    :<|> Transporter.updateTransporter

-- Location update and get for tracking is as follows
type LocationAPI =
  "driver" :> "location"
    :> ( Capture "rideId" (Id DRide.Ride) -- TODO: add auth
           :> Get '[JSON] GetLocationRes
           :<|> TokenAuth
             :> ReqBody '[JSON] UpdateLocationReq
             :> Post '[JSON] UpdateLocationRes
       )

locationFlow :: FlowServer LocationAPI
locationFlow =
  Location.getLocation
    :<|> Location.updateLocation

type RouteAPI =
  "route"
    :> TokenAuth
    :> ReqBody '[JSON] Location.Request
    :> Post '[JSON] Location.Response

routeFlow :: FlowServer RouteAPI
routeFlow = Location.getRoute

type IdfyHandlerAPI =
  "ext" :> "idfy"
    :> ( "drivingLicense"
           :> ReqBody '[JSON] IdfyDLReq
           :> Post '[JSON] AckResponse
           :<|> "vehicleRegistrationCert"
             :> ReqBody '[JSON] IdfyRCReq
             :> Post '[JSON] AckResponse
       )

idfyHandlerFlow :: FlowServer IdfyHandlerAPI
idfyHandlerFlow =
  Idfy.idfyDrivingLicense --update handler
    :<|> Idfy.idfyRCLicense --update handler

type RideAPI =
  "driver" :> "ride"
    :> ( "list"
           :> TokenAuth
           :> QueryParam "limit" Integer
           :> QueryParam "offset" Integer
           :> QueryParam "onlyActive" Bool
           :> Get '[JSON] RideAPI.DriverRideListRes
           :<|> TokenAuth
           :> Capture "rideId" (Id DRide.Ride)
           :> "start"
           :> ReqBody '[JSON] RideAPI.StartRideReq
           :> Post '[JSON] APISuccess
           :<|> TokenAuth
           :> Capture "rideId" (Id DRide.Ride)
           :> "end"
           :> ReqBody '[JSON] RideAPI.EndRideReq
           :> Post '[JSON] APISuccess
           :<|> TokenAuth
           :> Capture "rideId" (Id DRide.Ride)
           :> "cancel"
           :> ReqBody '[JSON] RideAPI.CancelRideReq
           :> Post '[JSON] APISuccess
       )

rideFlow :: FlowServer RideAPI
rideFlow =
  Ride.listDriverRides
    :<|> RideAPI.StartRide.startRide
    :<|> RideAPI.EndRide.endRide
    :<|> RideAPI.CancelRide.cancelRide

-------- Direct call (Exotel) APIs
type CallAPIs =
  "exotel"
    :> "call"
    :> ( "customer"
           :> "number"
           :> MandatoryQueryParam "CallSid" Text
           :> MandatoryQueryParam "CallFrom" Text
           :> MandatoryQueryParam "CallTo" Text
           :> MandatoryQueryParam "CallStatus" Text
           :> Get '[JSON] CallAPI.MobileNumberResp
           :<|> "statusCallback"
           :> MandatoryQueryParam "CallSid" Text
           :> MandatoryQueryParam "DialCallStatus" Text
           :> MandatoryQueryParam "RecordingUrl" Text
           :> QueryParam "Legs[0][OnCallDuration]" Int
           :> Get '[JSON] CallAPI.CallCallbackRes
       )

-- :<|> "ride"
--   :> Capture "rideId" (Id DRide.Ride)
--   :> "call"
--   :> "status"
--   :> TokenAuth
--   :> Get '[JSON] CallAPI.GetCallStatusRes

callFlow :: FlowServer CallAPIs
callFlow =
  Call.getCustomerMobileNumber
    :<|> Call.directCallStatusCallback

-- :<|> Call.getCallStatus

type OrgBecknAPI =
  Capture "orgId" (Id Organization)
    :> SignatureAuth "Authorization"
    :> ( SignatureAuth "X-Gateway-Authorization"
           :> API.SearchAPI
           :<|> API.SelectAPI
           :<|> API.InitAPI
           :<|> API.ConfirmAPI
           :<|> API.TrackAPI
           :<|> API.CancelAPI
           :<|> API.RatingAPI
       )

orgBecknApiFlow :: FlowServer OrgBecknAPI
orgBecknApiFlow orgId aurhRes =
  BP.search orgId aurhRes
    :<|> BP.select orgId aurhRes
    :<|> BP.init orgId aurhRes
    :<|> BP.confirm orgId aurhRes
    :<|> BP.track orgId aurhRes
    :<|> BP.cancel orgId aurhRes
    :<|> BP.rating orgId aurhRes

type OnBoardingAPI =
  "driver"
    :> ( "register"
           :> TokenAuth
           :> ReqBody '[JSON] DriverOnBoardingReq
           :> Post '[JSON] DriverOnBoardingRes
           :<|> "register"
           :> "status"
           :> TokenAuth
           :> Get '[JSON] StatusRes
       )

onBoardingAPIFlow :: FlowServer OnBoardingAPI
onBoardingAPIFlow =
  DO.registrationHandler
    :<|> Status.statusHandler

type CancellationReasonAPI =
  "cancellationReason"
    :> ( "list"
           :> TokenAuth
           :> Get '[JSON] CancellationReasonAPI.ListRes
       )

cancellationReasonFlow :: FlowServer CancellationReasonAPI
cancellationReasonFlow = CancellationReason.list

type HealthCheckAPI = Get '[JSON] Text

type SwaggerAPI = "swagger" :> Get '[JSON] OpenApi

swagger :: OpenApi
swagger = do
  let openApi = toOpenApi (Proxy :: Proxy MainAPI)
  openApi
    { _openApiInfo =
        (_openApiInfo openApi)
          { _infoTitle = "Namma Yatri Partner",
            _infoVersion = "1.0"
          }
    }

writeSwaggerJSONFlow :: FlowServer SwaggerAPI
writeSwaggerJSONFlow = return swagger
