{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.HomeScreen.ScreenData where

import Common.Types.App (RateCardType(..))
import Components.LocationListItem.Controller (dummyLocationListState)
import Components.SettingSideBar.Controller (SettingSideBarState, Status(..))
import Components.ChooseVehicle.Controller (SearchType(..)) as CV
import Data.Maybe (Maybe(..))
import Screens.Types (Contact, DriverInfoCard, HomeScreenState, LocationListItemState, PopupType(..), RatingCard(..), SearchLocationModelType(..), Stage(..), Address, EmergencyHelpModelState,Location, ZoneType(..), SpecialTags, TipViewStage(..), SearchResultType(..), RentalStage(..), BookingStage(..))
import Services.API (DriverOfferAPIEntity(..), QuoteAPIDetails(..), QuoteAPIEntity(..), PlaceName(..), LatLong(..), SpecialLocation(..), QuoteAPIContents(..), RideBookingRes(..), RideBookingAPIDetails(..), RideBookingDetails(..), FareRange(..), FareBreakupAPIEntity(..))
import Prelude (($) ,negate)
import Data.Array (head)
import Prelude(negate)
import Foreign.Object (empty)
import MerchantConfig.DefaultConfig as DC
import Screens.MyRidesScreen.ScreenData (dummyBookingDetails)
import PrestoDOM (BottomSheetState(..))

initData :: HomeScreenState
initData = {
    data: {
      suggestedAmount : 0
    , finalAmount : 0
    , startedAt : ""
    , currentSearchResultType : ESTIMATES
    , endedAt : ""
    , source : ""
    , destination : ""
    , eta : "2 mins"
    , vehicleDetails : "Bajaj RE Auto"
    , registrationNumber : "KA  01  YF  4921"
    , rating : 4.0
    , locationList : []
    , savedLocations : []
    , recentSearchs : { predictionArray : []}
    , previousCurrentLocations : {pastCurrentLocations:[]}
    , selectList : []
    , quoteListModelState : []
    , driverInfoCardState : dummyDriverInfo
    , rideRatingState : dummyPreviousRiderating
    , settingSideBar : dummySettingBar
    , sourceAddress : dummyAddress
    , destinationAddress : dummyAddress
    , route : Nothing
    , startedAtUTC : ""
    , rateCard : {
       additionalFare : 0,
       nightShiftMultiplier : 0.0,
       nightCharges : false,
       currentRateCardType : DefaultRateCard,
       onFirstPage:false,
       baseFare : 0,
       extraFare : 0,
       pickUpCharges : 0,
       vehicleVariant : ""
       }
    , speed : 0
    , selectedLocationListItem : Nothing
    , saveFavouriteCard : {
        address : ""
      , tag : ""
      , tagExists : false
      , selectedItem : dummyLocationListState
      , tagData : []
      , isBtnActive : false
      }
    , rideDistance : "--"
    , rideDuration : "--"
    , showPreferences : false
    , messages : []
    , messagesSize : "-1"
    , suggestionsList : []
    , messageToBeSent : ""
    , nearByPickUpPoints : []
    , polygonCoordinates : ""
    , specialZoneQuoteList : [ {
            activeIndex: 0
          , basePrice: 254
          , capacity: "Economical, 4 people"
          , id: "d1b6e3e0-6075-49f1-abb9-28bfb1a4b353"
          , index: 0
          , isBookingOption: false
          , isCheckBox: false
          , isEnabled: true
          , isSelected: false
          , maxPrice: 123
          , price: "₹254"
          , searchResultType: CV.QUOTES
          , showInfo: false
          , vehicleImage: "ny_ic_taxi_side,https://assets.juspay.in/beckn/jatrisaathi/jatrisaathicommon/images/ny_ic_taxi_side.png"
          , vehicleType: ""
          , vehicleVariant: "TAXI"
          },
          {
            activeIndex: 0
          , basePrice: 292
          , capacity: "Comfy, 4 people"
          , id: "cd47110c-a5f4-41a7-bee8-724242850a2d"
          , index: 1
          , isBookingOption: false
          , isCheckBox: false
          , isEnabled: true
          , isSelected: false
          , maxPrice: 123
          , price: "₹292"
          , searchResultType: CV.QUOTES
          , showInfo: false
          , vehicleImage: "ny_ic_sedan_ac_side,https://assets.juspay.in/beckn/jatrisaathi/jatrisaathicommon/images/ny_ic_sedan_ac_side.png"
          , vehicleType: ""
          , vehicleVariant: "TAXI_PLUS"
          },
          { activeIndex: 0
          , basePrice: 582
          , capacity: "Spacious · 6 people"
          , id: "39ea627a-a7e2-41f9-976a-545d34833c08"
          , index: 1
          , isBookingOption: false
          , isCheckBox: false
          , isEnabled: true
          , isSelected: false
          , maxPrice: 123
          , price: "₹582"
          , searchResultType: CV.QUOTES
          , showInfo: false
          , vehicleImage: "ny_ic_suv_ac_side,https://assets.juspay.in/beckn/jatrisaathi/jatrisaathicommon/images/ny_ic_suv_ac_side.png"
          , vehicleType: ""
          , vehicleVariant: "SUV"
          }
        ]
    , specialZoneSelectedQuote : Nothing
    , specialZoneSelectedVariant : Nothing
    , selectedEstimatesObject : {
      vehicleImage: ""
      , isSelected: false
      , vehicleVariant: ""
      , vehicleType: ""
      , capacity: ""
      , price: ""
      , isCheckBox: false
      , isEnabled: true
      , activeIndex: 0
      , index: 0
      , id: ""
      , maxPrice : 0
      , basePrice : 0
      , showInfo : true
      , searchResultType : CV.ESTIMATES
      , isBookingOption : false
      }
    , lastMessage : { message : "", sentBy : "", timeStamp : "", type : "", delay : 0 }
    , cancelRideConfirmationData : { delayInSeconds : 5, timerID : "", enableTimer : true, continueEnabled : false }
    , pickUpCharges : 0
    , ratingViewState : {
        selectedYesNoButton : -1,
        selectedRating : -1,
        issueReportActiveIndex : Nothing ,
        issueReasonCode : Nothing,
        openReportIssue : false,
        doneButtonVisibility : false,
        issueFacedView : false,
        issueReason : Nothing,
        issueDescription : "",
        rideBookingRes : dummyRideBooking
    }
    , config : DC.config
    , logField : empty
    , nearByDrivers : Nothing
    , disability : Nothing
    , searchLocationModelData : dummySearchLocationModelData
    },
    props: {
      rideRequestFlow : false
    , isSearchLocation : NoView
    , currentStage : HomeScreen
    , bookingStage : NormalBooking
    , showCallPopUp : false
    , sourceLat : 0.0
    , isSource : Nothing
    , sourceLong : 0.0
    , destinationLat : 0.0
    , destinationLong : 0.0
    , sourcePlaceId : Nothing
    , destinationPlaceId : Nothing
    , estimateId : ""
    , selectedQuote : Nothing
    , locationRequestCount : 0
    , zoneTimerExpired : false
    , customerTip : {
        enableTips: false
      , tipForDriver: 10
      , tipActiveIndex: 1
      , isTipSelected: false
      }
    , searchId : ""
    , bookingId : ""
    , expiredQuotes : []
    , isCancelRide : false
    , cancellationReasons : []
    , cancelRideActiveIndex : Nothing
    , cancelDescription : ""
    , cancelReasonCode : ""
    , isPopUp : NoPopUp
    , forFirst : true
    , callbackInitiated : false
    , isLocationTracking : false
    , isInApp : true
    , locateOnMap : false
    , sourceSelectedOnMap : false
    , distance : 0
    , isSrcServiceable : true
    , isDestServiceable : true
    , isRideServiceable : true
    , showlocUnserviceablePopUp : false
    , autoSelecting : true
    , searchExpire : 90
    , isEstimateChanged : false
    , showRateCard : false
    , showRateCardIcon : false
    , sendMessageActive : false
    , chatcallbackInitiated : false
    , emergencyHelpModal : false
    , estimatedDistance : Nothing
    , waitingTimeTimerIds : []
    , tagType : Nothing
    , isSaveFavourite : false
    , showShareAppPopUp : false
    , showMultipleRideInfo : false
    , hasTakenRide : true
    , isReferred : false
    , storeCurrentLocs : false
    , unReadMessages : false
    , openChatScreen : false
    , emergencyHelpModelState : emergencyHelpModalData
    , showLiveDashboard : false
    , isBanner : true
    , callSupportPopUp : false
    , isMockLocation: false
    , isSpecialZone : false
    , defaultPickUpPoint : ""
    , showChatNotification : false
    , cancelSearchCallDriver : false
    , zoneType : dummyZoneType
    , cancelRideConfirmationPopup : false
    , searchAfterEstimate : false
    , isChatOpened : false
    , tipViewProps : {
        stage : DEFAULT
      , isVisible : false
      , onlyPrimaryText : false
      , isprimaryButtonVisible : false
      , primaryText : ""
      , secondaryText : ""
      , customerTipArray : ["₹10 🙂", "₹20 😄", "₹30 🤩"]
      , customerTipArrayWithValues : [10, 20, 30]
      , activeIndex : -1
      , primaryButtonText : ""
      }
    , timerId : ""
    , findingRidesAgain : false
    , routeEndPoints : Nothing
    , findingQuotesProgress : 0.0
    , confirmLocationCategory : ""
    , canSendSuggestion : true
    , sheetState : COLLAPSED
    , showDisabilityPopUp : false
    , isChatNotificationDismissed : false
    , searchLocationModelProps : dummySearchLocationModelProps
    , rentalStage : NotRental
    , showRentalPackagePopup : false
    , rentalData :
        { dateAndTime : ""
        }
    }
}

dummySearchLocationModelProps = {
    isAutoComplete : false
  , showLoader : false
  , crossBtnSrcVisibility : false
  , crossBtnDestVisibility : false
}

dummySearchLocationModelData = {
  prevLocation : ""
}

dummyZoneType = {
    sourceTag : NOZONE
  , destinationTag : NOZONE
  , priorityTag : NOZONE
}

dummyContactData :: Array Contact
dummyContactData = []

selectedContactData ::  Contact
selectedContactData =
  { name : "", phoneNo : "" }

emergencyHelpModalData :: EmergencyHelpModelState
emergencyHelpModalData = {
  showCallPolicePopUp : false,
  showCallContactPopUp : false,
  showCallSuccessfulPopUp : false,
  showContactSupportPopUp : false,
  emergencyContactData : dummyContactData,
  currentlySelectedContact : selectedContactData,
  sosId : "",
  sosStatus : "",
  isSelectEmergencyContact : false,
  waitingDialerCallback : false
}


dummyPreviousRiderating :: RatingCard
dummyPreviousRiderating = {
  rideId : ""
, rating : 0
, driverName : ""
, finalAmount : 0
, rideStartTime : ""
, rideEndTime : ""
, source : ""
, destination : ""
, rideStartDate : ""
, vehicleNumber : ""
, status : ""
, shortRideId : ""
, bookingId : ""
, rideEndTimeUTC : ""
, dateDDMMYY : ""
, offeredFare : 0
, distanceDifference : 0
, feedback : ""
, feedbackList : []
}


dummyDriverInfo :: DriverInfoCard
dummyDriverInfo =
  { otp : ""
  , driverName : ""
  , eta : 0
  , vehicleDetails : ""
  , currentSearchResultType : ESTIMATES
  , registrationNumber : ""
  , rating : 0.0
  , startedAt : ""
  , endedAt : ""
  , source : ""
  , destination : ""
  , rideId : ""
  , price : 0
  , sourceLat : 0.0
  , sourceLng : 0.0
  , destinationLat : 0.0
  , destinationLng : 0.0
  , driverLat : 0.0
  , driverLng : 0.0
  , distance : 0
  , waitingTime : "--"
  , driverArrived : false
  , estimatedDistance : ""
  , driverArrivalTime : 0
  , bppRideId : ""
  , driverNumber : Nothing
  , merchantExoPhone : ""
  , createdAt : ""
  , initDistance : Nothing
  , config : DC.config
  , vehicleVariant : ""
  }

dummySettingBar :: SettingSideBarState
dummySettingBar = {
    name : ""
  , number : ""
  , opened : CLOSED
  , email : Nothing
  , gender : Nothing
  , appConfig : DC.config
  , sideBarList : ["MyRides", "Favorites", "EmergencyContacts", "HelpAndSupport", "Language", "ShareApp", "LiveStatsDashboard", "About", "Logout"]
}

dummyAddress :: Address
dummyAddress = {
              "area" : Nothing
            , "state" : Nothing
            , "country" : Nothing
            , "building" : Nothing
            , "door" : Nothing
            , "street" : Nothing
            , "city" : Nothing
            , "areaCode" : Nothing
            , "ward" : Nothing
            , "placeId" : Nothing
            }

dummyQuoteAPIEntity :: QuoteAPIEntity
dummyQuoteAPIEntity = QuoteAPIEntity {
  agencyNumber : "",
  createdAt : "",
  discount : Nothing,
  estimatedTotalFare : 0,
  agencyName : "",
  vehicleVariant : "",
  estimatedFare : 0,
  tripTerms : [],
  id : "",
  agencyCompletedRidesCount : 0,
  quoteDetails : QuoteAPIDetails {fareProductType : "", contents : dummyDriverOfferAPIEntity}
}

dummyDriverOfferAPIEntity :: QuoteAPIContents
dummyDriverOfferAPIEntity =
  DRIVER_OFFER
    $ DriverOfferAPIEntity
        { rating: Nothing
        , validTill: ""
        , driverName: ""
        , distanceToPickup: 0.0
        , durationToPickup: 0
        }

dummyLocationName :: PlaceName
dummyLocationName = PlaceName {
  "formattedAddress" : "",
  "location" : LatLong{
    "lat" : 0.0,
    "lon" : 0.0
  },
  "plusCode" : Nothing,
  "addressComponents" : []
}

specialLocation :: SpecialLocation
specialLocation = SpecialLocation{
    "category" :"",
     "gates": [],
     "locationName" : ""
 }

dummyLocation :: Location
dummyLocation = {
   place : "",
   lat : 0.0,
   lng : 0.0,
   address : Nothing
 }


dummyRideBooking :: RideBookingRes
dummyRideBooking = RideBookingRes
  {
  agencyNumber : "",
  status : "",
  rideStartTime : Nothing,
  rideEndTime : Nothing,
  duration : Nothing,
  fareBreakup :[],
  createdAt : "",
  discount : Nothing ,
  estimatedTotalFare : 0,
  agencyName : "",
  rideList :[] ,
  estimatedFare : 0,
  tripTerms : [],
  id : "",
  updatedAt : "",
  bookingDetails : dummyRideBookingAPIDetails ,
  fromLocation :  dummyBookingDetails,
  merchantExoPhone : "",
  specialLocationTag : Nothing
  }

dummyRideBookingAPIDetails ::RideBookingAPIDetails
dummyRideBookingAPIDetails= RideBookingAPIDetails{
  contents : dummyRideBookingDetails,
  fareProductType : ""
}

dummyRideBookingDetails :: RideBookingDetails
dummyRideBookingDetails = RideBookingDetails {
  toLocation : dummyBookingDetails,
  estimatedDistance : Nothing,
  otpCode : Nothing
}

dummyFareBreakUp :: FareBreakupAPIEntity
dummyFareBreakUp = FareBreakupAPIEntity{
  amount : 0,
  description : "fare"
}
