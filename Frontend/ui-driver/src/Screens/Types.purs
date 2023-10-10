{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.Types where

import Common.Types.App as Common
import Components.ChatView.Controller as ChatView
import Components.PaymentHistoryListItem.Controller as PaymentHistoryListItem
import Components.ChooseVehicle.Controller (Config) as ChooseVehicle
import Components.RecordAudioModel.Controller as RecordAudioModel
import Data.Eq.Generic (genericEq)
import Data.Generic.Rep (class Generic)
import Data.Maybe (Maybe)
import Data.Show.Generic (genericShow)
import Foreign.Class (class Decode, class Encode)
import Halogen.VDom.DOM.Prop (PropValue)
import Prelude (class Eq, class Show )
import Presto.Core.Utils.Encoding (defaultDecode, defaultEncode)
import Presto.Core.Utils.Encoding (defaultEnumDecode, defaultEnumEncode)
import PrestoDOM (LetterSpacing, Visibility, visibility)
import Services.API (GetDriverInfoResp(..), Route, Status, MediaType, PaymentBreakUp)
import Styles.Types (FontSize)
import Components.ChatView.Controller as ChatView
import Components.RecordAudioModel.Controller as RecordAudioModel
import MerchantConfig.Types (AppConfig)
import Foreign.Object (Object)
import Foreign (Foreign)
import Screens (ScreenName)

type EditTextInLabelState =
 {
    topLabel :: String
  , showTopLabel :: Boolean
  , inLabel :: String
  , showInLabel :: Boolean
  , valueId :: String
  , hint :: String
  , pattern :: Maybe String
  , id :: String
  }

type LanguageItemState =
 {
    key :: String
  , language :: String
  , selected :: Boolean
  }

type NotificationItemState = {
    color :: String
  , color1 :: String
  , icon :: String
  , title :: String
  , description :: String
}

type EditTextState =
 {
    title :: String
  , hint :: String
  }

type EditTextInImageState =
 {
    topLabel :: String
  , showTopLabel :: Boolean
  , inImage :: String
  , showInImage :: Boolean
  , hint :: String
  }

type DateEditTextState =
 {
    label :: String
  , hint :: String
  , id :: String
  , value :: String
  }

type SplashScreenState =  {
   data :: SplashScreenData
 }

type SplashScreenData =  {
   message :: String
 }

type NoInternetScreenState =  { }

-- ############################################################# ChooseLanguageScreen ################################################################################

type ChooseLanguageScreenState = {
  data :: ChooseLanguageScreenData,
  props :: ChooseLanguageScreenProps
}

type ChooseLanguageScreenData =  {
  config :: AppConfig,
  isSelected :: Boolean,
  logField :: Object Foreign
 }

type ChooseLanguageScreenProps =  {
  selectedLanguage :: String,
  btnActive :: Boolean
 }

-- ############################################################# AddVehicleDetailsScreen ################################################################################

type AddVehicleDetailsScreenState = {
  data :: AddVehicleDetailsScreenData,
  props :: AddVehicleDetailsScreenProps
}

type AddVehicleDetailsScreenData =  {
  vehicle_type :: String,
  vehicle_model_name :: String,
  vehicle_color :: String,
  vehicle_registration_number :: String,
  reEnterVehicleRegistrationNumber :: String,
  rc_base64 :: String,
  vehicle_rc_number :: String,
  referral_mobile_number :: String,
  rcImageID :: String,
  errorMessage :: String,
  dateOfRegistration :: Maybe String,
  dateOfRegistrationView :: String,
  logField :: Object Foreign
 }

type AddVehicleDetailsScreenProps =  {
  rcAvailable :: Boolean,
  vehicleTypes :: Array VehicalTypes,
  openSelectVehicleTypeModal :: Boolean,
  openRegistrationModal :: Boolean,
  rc_name :: String,
  input_data :: String,
  enable_upload :: Boolean,
  openRCManual :: Boolean,
  openReferralMobileNumber :: Boolean,
  isValid :: Boolean,
  btnActive :: Boolean,
  referralViewstatus :: Boolean,
  isEdit :: Boolean,
  isValidState :: Boolean,
  limitExceedModal :: Boolean,
  errorVisibility :: Boolean,
  openRegistrationDateManual :: Boolean,
  addRcFromProfile :: Boolean,
  isDateClickable :: Boolean
 }

data VehicalTypes = Sedan | Hatchback | SUV | Auto

 -- ############################################################# UploadingDrivingLicenseScreen ################################################################################
type UploadDrivingLicenseState = {
  data :: UploadDrivingLicenseStateData,
  props :: UploadDrivingLicenseStateProps

}

type UploadDrivingLicenseStateData = {
  driver_license_number :: String
  , reEnterDriverLicenseNumber :: String
  , imageFront :: String
  , imageBack :: String
  , imageNameFront :: String
  , imageNameBack :: String
  , dob :: String
  , dobView :: String
  , imageIDFront :: String
  , imageIDBack :: String
  , rcVerificationStatus :: String
  , errorMessage :: String
  , dateOfIssue :: Maybe String
  , dateOfIssueView :: String
  , imageFrontUrl :: String
  , logField :: Object Foreign
}

type UploadDrivingLicenseStateProps = {
    openRegistrationModal :: Boolean
  , openLicenseManual :: Boolean
  , input_data :: String
  , clickedButtonType :: String
  , openGenericMessageModal :: Boolean
  , errorVisibility :: Boolean
  , openDateOfIssueManual :: Boolean
  , isDateClickable :: Boolean
}

 -- ############################################################# RegistrationScreen ################################################################################
type RegistrationScreenState = {
  data :: RegistrationScreenData,
  props :: RegistrationScreenProps
}
type RegistrationScreenData = {}
type RegistrationScreenProps = {}

 -- ############################################################# UploadAdhaarScreen ################################################################################

type UploadAdhaarScreenState = {
  data :: UploadAdhaarScreenData,
  props :: UploadAdhaarScreenProps
}
type UploadAdhaarScreenData = {
  imageFront :: String,
  imageBack :: String,
  imageName :: String
}

type UploadAdhaarScreenProps = {
    openRegistrationModal :: Boolean,
    clickedButtonType :: String
}
 ----------------------------------------------------  PrimaryEditTextState   ------------------------------------------------
type PrimaryEditTextState = {
  title :: String,
  type :: String,
  hint :: String,
  valueId :: String,
  pattern :: Maybe String,
  isinValid :: Boolean,
  error :: Maybe String,
  text :: String,
  fontSize :: FontSize,
  letterSpacing :: LetterSpacing,
  id :: String
}

----------------------------------------------------- DriverProfileScreen ------------------------------------------------
type DriverProfileScreenState = {
  data :: DriverProfileScreenData,
  props :: DriverProfileScreenProps
}

type DriverProfileScreenData = {
  driverName :: String,
  driverVehicleType :: String,
  driverRating :: Maybe Number,
  base64Image :: String,
  drivingLicenseNo :: String,
  driverMobile :: Maybe String,
  vehicleRegNumber :: String,
  vehicleModelName :: String,
  vehicleColor :: String,
  driverAlternateNumber :: Maybe String,
  capacity :: Int,
  downgradeOptions :: Array String,
  vehicleSelected :: Array VehicleP,
  genderTypeSelect :: Maybe String,
  alterNumberEditableText :: Boolean,
  driverEditAlternateMobile :: Maybe String,
  otpLimit :: Int,
  otpBackAlternateNumber :: Maybe String,
  languagesSpoken :: Array String,
  gender :: Maybe String,
  driverGender :: Maybe String,
  languageList :: Array Common.CheckBoxOptions,
  vehicleAge :: Int,
  vehicleName :: String,
  rcDataArray :: Array RcData,
  inactiveRCArray :: Array RcData,
  activeRCData :: RcData,
  rcNumber :: String,
  isRCActive :: Boolean,
  openInactiveRCViewOrNotArray :: Array Int,
  logField :: Object Foreign,
  analyticsData :: AnalyticsData,
  fromHomeScreen :: Boolean,
  profileImg :: Maybe String
}

type RcData = {
  rcStatus  :: Boolean,
  rcDetails :: RcDetails
  }

type RcDetails = {
    certificateNumber :: String,
    vehicleModel      :: Maybe String,
    vehicleColor      :: Maybe String
    }

type AnalyticsData = {
    totalEarnings :: String
  , bonusEarned :: String
  , totalCompletedTrips :: Int
  , totalUsersRated :: Int
  , rating :: Maybe Number
  , lateNightTrips :: Int
  , lastRegistered :: String
  , badges :: Array Badge
  , missedEarnings :: Int
  , ridesCancelled :: Int
  , cancellationRate :: Int
  , totalRidesAssigned :: Int
  , totalDistanceTravelled :: String
}

type ChipRailData = {
    mainTxt :: String
  , subTxt :: String
}

type Badge =  {
    badgeImage :: String
  , primaryText :: String
  , subText :: String
  }

type VehicleP = {
  vehicleName :: String,
  isSelected :: Boolean
}

type DriverProfileScreenProps = {
  logoutModalView :: Boolean,
  showLiveDashboard :: Boolean,
  screenType :: DriverProfileScreenType,
  openSettings :: Boolean,
  updateDetails :: Boolean,
  showGenderView :: Boolean,
  alternateNumberView :: Boolean,
  removeAlternateNumber :: Boolean,
  enterOtpModal :: Boolean,
  enterOtpFocusIndex :: Int,
  otpIncorrect :: Boolean,
  otpAttemptsExceeded :: Boolean,
  alternateMobileOtp :: String,
  checkAlternateNumber :: Boolean,
  isEditAlternateMobile :: Boolean,
  numberExistError :: Boolean,
  mNumberEdtFocused :: Boolean,
  updateLanguages :: Boolean,
  activateRcView :: Boolean,
  activateOrDeactivateRcView :: Boolean,
  activeRcIndex :: Int,
  deleteRcView :: Boolean,
  alreadyActive :: Boolean,
  callDriver :: Boolean,
  openRcView :: Boolean,
  detailsUpdationType :: Maybe UpdateType,
  btnActive :: Boolean,
  showBookingOptionForTaxi :: Boolean
}
data Gender = MALE | FEMALE | OTHER | PREFER_NOT_TO_SAY

data DriverProfileScreenType = DRIVER_DETAILS | VEHICLE_DETAILS | SETTINGS

derive instance genericDriverProfileScreenType :: Generic DriverProfileScreenType _
instance showDriverProfileScreenType :: Show DriverProfileScreenType where show = genericShow
instance eqDriverProfileScreenType :: Eq DriverProfileScreenType where eq = genericEq


data UpdateType = LANGUAGE | HOME_TOWN | VEHICLE_AGE | VEHICLE_NAME

derive instance genericUpdateType :: Generic UpdateType _
instance showUpdateType :: Show UpdateType where show = genericShow
instance eqUpdateType :: Eq UpdateType where eq = genericEq

-----------------------------------------------ApplicationStatusScreen ---------------------------------------
type ApplicationStatusScreenState = {
  data :: ApplicationStatusScreenData,
  props :: ApplicationStatusScreenProps
}
type ApplicationStatusScreenData =  {
  rcVerificationStatus :: String,
  dlVerificationStatus :: String,
  mobileNumber :: String,
  otpValue :: String
}
type ApplicationStatusScreenProps =  {
  isSelected :: Boolean,
  onBoardingFailure :: Boolean,
  isVerificationFailed :: Boolean,
  popupview :: Boolean,
  enterMobileNumberView :: Boolean,
  alternateNumberAdded :: Boolean,
  isValidAlternateNumber :: Boolean,
  buttonVisibilty :: Boolean,
  enterOtp :: Boolean,
  isValidOtp :: Boolean,
  isAlternateMobileNumberExists :: Boolean
}

--------------------------------------------------------------- EnterMobileNumberScreenState -----------------------------------------------------------------------------
type EnterMobileNumberScreenState = {
  data :: EnterMobileNumberScreenStateData,
  props :: EnterMobileNumberScreenStateProps
}

type EnterMobileNumberScreenStateData = {
    mobileNumber :: String,
    logField :: Object Foreign
}

type EnterMobileNumberScreenStateProps = {
  btnActive :: Boolean,
  isValid :: Boolean
}

--------------------------------------------------------------- BankDetailScreenState -----------------------------------------------------------------------------
type BankDetailScreenState = {
  data :: BankDetailScreenStateData,
  props :: BankDetailScreenStateProps
}

type BankDetailScreenStateData =  {
  beneficiaryNumber :: String,
  ifsc :: String
}

type BankDetailScreenStateProps =  {
  openRegistrationModal :: Boolean,
  inputData :: String,
  isBeneficiaryMatching :: Boolean
}

-------------------------------------------------------EnterOTPScreenState ------------------------------
type EnterOTPScreenState = {
  data :: EnterOTPScreenStateData,
  props :: EnterOTPScreenStateProps
}

type EnterOTPScreenStateData = {
  otp :: String,
  tokenId :: String,
  attemptCount :: Int,
  mobileNo :: String,
  timer :: String,
  capturedOtp :: String
}

type EnterOTPScreenStateProps = {
  btnActive :: Boolean,
  isValid :: Boolean,
  resendEnabled :: Boolean
}

---------------------PrimaryButtonState----------------------------------------
type PrimaryButtonState = {
  title :: String,
  active :: Boolean,
  size :: Boolean,
  screenName :: String,
  isEndScreen :: Boolean,
  specificLog :: String
  }


-- ################################################ RideHistoryScreenState ##################################################
data AnimationState
  = AnimatedIn
  | AnimatingIn
  | AnimatingOut
  | AnimatedOut

derive instance genericAnimationState :: Generic AnimationState _
instance showAnimationState :: Show AnimationState where show = genericShow
instance eqAnimationState :: Eq AnimationState where eq = genericEq
instance encodeAnimationState :: Encode AnimationState where encode = defaultEnumEncode
instance decodeAnimationState :: Decode AnimationState where decode = defaultEnumDecode

type RideHistoryScreenState =
  {
    shimmerLoader :: AnimationState,
    prestoListArrayItems :: Array ItemState,
    rideList :: Array IndividualRideCardState,
    selectedItem :: IndividualRideCardState,
    currentTab :: String,
    offsetValue :: Int,
    loaderButtonVisibility :: Boolean,
    loadMoreDisabled :: Boolean,
    recievedResponse :: Boolean,
    logField :: Object Foreign
  , datePickerState :: DatePickerState
  , props :: RideHistoryScreenStateProps
  , data :: RideHistoryScreenStateData
  }
type DatePickerState = {
  activeIndex :: Int
, selectedItem :: Common.CalendarDate
}
type RideHistoryScreenStateProps = {
    showDatePicker :: Boolean
 , showPaymentHistory :: Boolean
}
type RideHistoryScreenStateData = {
    pastDays :: Int
  , paymentHistory :: PaymentHistoryModelState
}

data EditRc = DEACTIVATING_RC | DELETING_RC | ACTIVATING_RC

derive instance genericEditRc :: Generic EditRc _
instance eqEditRc :: Eq EditRc where eq = genericEq

data CallOptions = CALLING_DRIVER | CALLING_CUSTOMER_SUPPORT
derive instance genericCallOptions :: Generic CallOptions _
instance eqCallOptions :: Eq CallOptions where eq = genericEq
instance showCallOptions :: Show CallOptions where show = genericShow
instance encodeCallOptions :: Encode CallOptions where encode = defaultEnumEncode
instance decodeCallOptions :: Decode CallOptions where decode = defaultEnumDecode

type RideSelectionScreenState =
  {
    shimmerLoader :: AnimationState,
    prestoListArrayItems :: Array ItemState,
    rideList :: Array IndividualRideCardState,
    selectedItem :: Maybe IndividualRideCardState,
    offsetValue :: Int,
    loaderButtonVisibility :: Boolean,
    loadMoreDisabled :: Boolean,
    recievedResponse :: Boolean,
    selectedCategory :: CategoryListType
  }

type VehicleDetails = { rcStatus :: Boolean
                , rcDetails :: { certificateNumber  :: String
                , vehicleModel :: Maybe String
                , vehicleColor :: Maybe String
                }}

------------------------------------------- ReferralScreenState -----------------------------------------

type ReferralScreenState = {
    data :: ReferralScreenStateData
  , props :: ReferralScreenStateProps
}

type ReferralScreenStateData = {
    referralCode :: String
  , confirmReferralCode :: String
  , password :: String
  , driverInfo :: {
      driverName :: String,
      driverMobile :: Maybe String,
      vehicleRegNumber :: String,
      referralCode     :: Maybe String,
      vehicleVariant :: String
    }
  , driverPerformance :: {
      referrals :: {
        totalActivatedCustomers :: Int,
        totalReferredCustomers :: Int
      }
    }
  , logField :: Object Foreign
  , config :: AppConfig
}

type ReferralScreenStateProps = {
    primarybtnActive :: Boolean
  , passwordPopUpVisible  :: Boolean
  , callSupportPopUpVisible :: Boolean
  , confirmBtnActive :: Boolean
  , enableReferralFlowCount :: Int
  , stage :: ReferralType
  , seconds :: Int
  , id :: String
  , firstTime :: Boolean
  , leaderBoardType :: LeaderBoardType
  , showDateSelector :: Boolean
  , days :: Array Common.CalendarDate
  , weeks :: Array Common.CalendarWeek
  , selectedDay :: Common.CalendarDate
  , selectedWeek :: Common.CalendarWeek
  , rankersData :: Array RankCardData
  , currentDriverData :: RankCardData
  , showShimmer :: Boolean
  , noData :: Boolean
  , lastUpdatedAt :: String
}

type ShareImageConfig = {
    viewId :: String
  , code :: String
  , logoId :: String
}

-- ################################################ IndividualRideCardState ##################################################

type IndividualRideCardState =
  {
    date :: String,
    time :: String,
    total_amount :: Int,
    card_visibility :: String,
    shimmer_visibility :: String,
    rideDistance :: String,
    status :: String,
    vehicleModel :: String,
    shortRideId :: String,
    vehicleNumber :: String,
    driverName :: String,
    driverSelectedFare :: Int,
    vehicleColor :: String,
    id :: String,
    updatedAt :: String,
    source :: String,
    destination :: String,
    vehicleType :: String
  }


type ItemState =
  {
    date :: PropValue,
    time :: PropValue,
    total_amount :: PropValue,
    card_visibility :: PropValue,
    shimmer_visibility :: PropValue,
    rideDistance :: PropValue,
    status :: PropValue,
    vehicleModel :: PropValue,
    shortRideId :: PropValue,
    vehicleNumber :: PropValue,
    driverName :: PropValue,
    driverSelectedFare :: PropValue,
    vehicleColor :: PropValue,
    id :: PropValue,
    updatedAt :: PropValue,
    source :: PropValue,
    destination :: PropValue,
    amountColor :: PropValue,
    riderName :: PropValue,
    metroTagVisibility :: PropValue,
    accessibilityTagVisibility :: PropValue,
    specialZoneText :: PropValue,
    specialZoneImage :: PropValue,
    specialZoneLayoutBackground :: PropValue
  }
-----------------------------------------------ApplicationStatusScreen -------------------

type DriverDetailsScreenState = {
  data :: DriverDetailsScreenStateData,
  props :: DriverDetailsScreenStateProps
}

data KeyboardModalType = MOBILE__NUMBER | OTP | NONE

derive instance genericKeyboardModalType :: Generic KeyboardModalType _
instance eqKeyboardModalType :: Eq KeyboardModalType where eq = genericEq
type DriverDetailsScreenStateData =  {
  driverName :: String,
  driverVehicleType :: String,
  driverRating :: Maybe Number,
  base64Image :: String,
  drivingLicenseNo :: String,
  driverMobile :: Maybe String,
  driverAlternateMobile :: Maybe String,
  driverEditAlternateMobile :: Maybe String,
  genderSelectionModal ::  GenderSelectionModalData,
  driverGender :: Maybe String,
  otpLimit :: Int,
  otpBackAlternateNumber :: Maybe String
}

type DriverDetailsScreenStateProps =  {
  keyboardModalType :: KeyboardModalType,
  checkAlternateNumber :: Boolean,
  enterOtpFocusIndex :: Int,
  otpIncorrect :: Boolean,
  otpAttemptsExceeded :: Boolean,
  genderSelectionModalShow :: Boolean,
  alternateMobileOtp :: String,
  removeNumberPopup :: Boolean,
  isEditAlternateMobile :: Boolean,
  numberExistError :: Boolean
}


----------------------------------------------- VehicleDetailsScreen -------------------

type VehicleDetailsScreenState = {
  data :: VehicleDetailsScreenData,
  props :: VehicleDetailsScreenProps
}

type VehicleDetailsScreenData =  {
  imageName :: String,
  vehicleTypes :: Array VehicalTypes,
  base64Image :: String,
  vehicleRegNumber :: String,
  vehicleType :: String,
  vehicleModel :: String,
  vehicleColor :: String
}

type VehicleDetailsScreenProps =  {
  isInEditVehicleDetailsView :: Boolean,
  openSelectVehicleTypeModal :: Boolean,
  isModalVisible :: Boolean,
  deleteButtonVisibility :: Boolean,
  isValid :: Boolean
}

--------------------------------------------- AboutUsScreenState ---------------------------
type AboutUsScreenState = {
  data :: AboutUsScreenData,
  props :: AboutUsScreenProps
}

type AboutUsScreenData = {
  versionNumber :: String
}

type AboutUsScreenProps = {
  demoModePopup :: Boolean,
  enableConfirmPassword :: Boolean,
  enableDemoModeCount :: Int
}

--------------------------------------------- SelectLanguageScreenState ---------------------------
type SelectLanguageScreenState = {
  data :: SelectLanguageScreenData,
  props :: SelectLanguageScreenProps
}

type SelectLanguageScreenData = {
  isSelected :: Boolean
, config :: AppConfig
, logField :: Object Foreign
}

type SelectLanguageScreenProps = {
  selectedLanguage :: String,
  btnActive :: Boolean
}

----------------------------------------------- HomeScreenState ---------------------------------------------

type HomeScreenState = {
  data :: HomeScreenData,
  props :: HomeScreenProps
}

-- check something here as well

type HomeScreenData =  {
  driverName :: String,
  vehicleType :: String,
  activeRide :: ActiveRide,
  cancelRideModal :: CancelRideModalData,
  currentDriverLat :: Number,
  currentDriverLon :: Number,
  locationLastUpdatedTime :: String,
  totalRidesOfDay :: Int,
  totalEarningsOfDay :: Int,
  bonusEarned :: Int ,
  route :: Array Route,
  cancelRideConfirmationPopUp :: CancelRidePopUpData,
  messages :: Array ChatView.ChatComponent,
  messagesSize :: String,
  suggestionsList :: Array String,
  messageToBeSent :: String,
  driverAlternateMobile :: Maybe String,
  logField :: Object Foreign,
  paymentState :: PaymentState,
  profileImg :: Maybe String, 
  endRideData :: EndRideData,
  config :: AppConfig
 }

type EndRideData = {
    rideId :: String,
    zeroCommision :: Int,
    tip :: Maybe Int,
    finalAmount :: Int, 
    riderName :: String,
    rating :: Int,
    feedback :: String,
    disability :: Maybe String
  }
type PaymentState = {
  rideCount :: Int,
  totalMoneyCollected :: Int,
  payableAndGST :: Int,
  platFromFee :: Int,
  date :: String,
  makePaymentModal :: Boolean,
  showRateCard :: Boolean,
  paymentStatusBanner :: Boolean,
  paymentStatus :: Common.PaymentStatus,
  invoiceId :: String,
  bannerBG :: String,
  bannerTitle :: String,
  bannerTitleColor :: String,
  banneActionText :: String,
  actionTextColor :: String,
  bannerImage :: String,
  showBannerImage :: Boolean,
  chargesBreakup :: Array PaymentBreakUp,
  blockedDueToPayment :: Boolean,
  dateObj :: String,
  laterButtonVisibility :: Boolean
}

type CancelRidePopUpData = {
  delayInSeconds :: Int,
  timerID :: String,
  continueEnabled :: Boolean,
  enableTimer :: Boolean
}

type CancelRideModalData = {
  selectionOptions :: Array Common.OptionButtonList,
  activeIndex ::Maybe Int,
  selectedReasonCode :: String,
  selectedReasonDescription :: String,
  isMandatoryTextHidden :: Boolean,
  isSelectButtonActive :: Boolean
}

type GenderSelectionModalData = {
  selectionOptions :: Array Common.OptionButtonList,
  activeIndex ::Maybe Int,
  selectedReasonCode :: String,
  selectedReasonDescription :: String,
  isSelectButtonActive :: Boolean
}

type Rides = {
  id :: String,
  timer :: Int,
  seconds :: Int,
  pickupDistance :: Int,
  journeyDistance :: Int,
  sourceAddress :: String,
  destinationAddress :: String,
  totalAmount :: Number,
  baseAmount :: Number ,
  increasePrice :: Number,
  decreasePrice :: Number,
  destinationArea :: String
}

type ActiveRide = {
  id :: String,
  source :: String,
  destination :: String,
  src_lat :: Number,
  src_lon :: Number,
  dest_lat :: Number,
  dest_lon :: Number,
  actualRideDistance :: Number,
  status :: Status,
  distance :: Number,
  exoPhone :: String,
  duration :: Int,
  riderName :: String,
  estimatedFare :: Int,
  isDriverArrived :: Boolean,
  notifiedCustomer :: Boolean,
  waitingTime :: String,
  waitTimeInfo :: Boolean,
  rideCreatedAt :: String,
  specialLocationTag :: Maybe String,
  requestedVehicleVariant :: Maybe String,
  disabilityTag :: Maybe DisabilityType
}

type HomeScreenProps =  {
  statusOnline :: Boolean,
  goOfflineModal :: Boolean,
  screenName :: String,
  rideActionModal :: Boolean,
  enterOtpModal :: Boolean,
  rideOtp :: String,
  enterOtpFocusIndex :: Int,
  time :: Int,
  otpIncorrect :: Boolean,
  wrongVehicleVariant :: Boolean,
  endRidePopUp :: Boolean,
  cancelRideModalShow :: Boolean,
  routeVisible :: Boolean,
  otpAttemptsExceeded :: Boolean,
  refreshAnimation :: Boolean,
  showDottedRoute :: Boolean,
  currentStage :: HomeScreenStage,
  mapRendered :: Boolean,
  cancelConfirmationPopup :: Boolean,
  chatcallbackInitiated :: Boolean,
  sendMessageActive :: Boolean,
  unReadMessages :: Boolean,
  openChatScreen :: Boolean,
  updatedArrivalInChat :: Boolean,
  driverStatusSet :: DriverStatus,
  silentPopUpView :: Boolean,
  zoneRideBooking :: Boolean,
  showGenderBanner :: Boolean,
  notRemoveBanner :: Boolean,
  showBonusInfo :: Boolean,
  timerRefresh :: Boolean,
  showlinkAadhaarPopup :: Boolean,
  isChatOpened :: Boolean,
  showAadharPopUp :: Boolean,
  canSendSuggestion :: Boolean,
  showOffer :: Boolean,
  autoPayBanner :: Boolean,
  rcActive :: Boolean, 
  rcDeactivePopup :: Boolean,
  showAccessbilityPopup :: Boolean,
  showRideCompleted :: Boolean,
  showRideRating :: Boolean,
  showContactSupportPopUp :: Boolean,
  showChatBlockerPopUp :: Boolean,
  driverBlocked :: Boolean,
  showBlockingPopup :: Boolean
 }

data DisabilityType = BLIND_AND_LOW_VISION | HEAR_IMPAIRMENT | LOCOMOTOR_DISABILITY | OTHER_DISABILITY

derive instance genericPwdType :: Generic DisabilityType _
instance eqPwdType :: Eq DisabilityType where eq = genericEq
instance showPwdType :: Show DisabilityType where show = genericShow
instance encodePwdType :: Encode DisabilityType where encode = defaultEnumEncode
instance decodePwdType :: Decode DisabilityType where decode = defaultEnumDecode

data DriverStatus = Online | Offline | Silent

data TimerStatus = Triggered | PostTriggered | Stop | NoView

derive instance genericTimerStatus :: Generic TimerStatus _
instance showTimerStatus :: Show TimerStatus where show = genericShow

type PillButtonState = {
  status :: DriverStatus,
  background :: String,
  imageUrl :: String,
  textColor :: String
}

data DriverStatusResult = ACTIVE | DEFAULT | DEMO_

derive instance genericDriverStatus :: Generic DriverStatus _
instance showDriverStatus :: Show DriverStatus where show = genericShow
instance eqDriverStatus :: Eq DriverStatus where eq = genericEq
instance encodeDriverStatus :: Encode DriverStatus where encode = defaultEnumEncode
instance decodeDriverStatus :: Decode DriverStatus where decode = defaultEnumDecode

type Location = {
  place :: String,
  lat :: Number,
  lon :: Number
}

data LocationType = LATITUDE | LONGITUDE

derive instance genericLocationType :: Generic LocationType _
instance eqLocationType :: Eq LocationType where eq = genericEq

-- ############################################################# BottomNavBarState ################################################################################

type BottomNavBarState = {
  activeIndex :: Int,
  navButton :: Array NavIcons
}

type NavIcons = {
  activeIcon :: String,
  defaultIcon :: String,
  text :: String
}
 -- ######################################  TripDetailsScreenState   ######################################

type TripDetailsScreenState =
  {
    data :: TripDetailsScreenData,
    props :: TripDetailsScreenProps
}

data PaymentMode = CASH | PAYMENT_ONLINE

derive instance genericPaymentMode :: Generic PaymentMode _
instance showPaymentMode :: Show PaymentMode where show = genericShow
instance eqPaymentMode :: Eq PaymentMode where eq = genericEq
instance encodePaymentMode :: Encode PaymentMode where encode = defaultEnumEncode
instance decodePaymentMode :: Decode PaymentMode where decode = defaultEnumDecode

type TripDetailsScreenData =
  {
    message :: String,
    tripId :: String,
    rider :: String,
    date :: String,
    time :: String,
    timeTaken :: String,
    source :: String,
    destination :: String,
    totalAmount :: Int,
    paymentMode :: PaymentMode,
    distance :: String,
    status :: String,
    vehicleType :: String
  }

type TripDetailsScreenProps =
  {
    rating :: Int,
    reportIssue :: Boolean,
    issueReported :: Boolean
  }

--------------------------------------------- AboutUsScreenState ---------------------------
type HelpAndSupportScreenState = {
  data :: HelpAndSupportScreenData,
  props :: HelpAndSupportScreenProps
}

type HelpAndSupportScreenData = {
  categories :: Array CategoryListType,
  issueList :: Array IssueInfo,
  ongoingIssueList :: Array IssueInfo,
  resolvedIssueList :: Array IssueInfo,
  issueListType :: IssueModalType
}

type CategoryListType = {
    categoryName :: String
  , categoryImageUrl :: String
  , categoryAction :: String
  , categoryId :: String
  }

type HelpAndSupportScreenProps = {
  isNoRides :: Boolean

}

type ReportIssueChatScreenState = {
    data :: ReportIssueChatScreenData,
    props :: ReportIssueChatScreenProps
}

type ReportIssueChatScreenData = {
  tripId :: Maybe String,
  categoryName :: String,
  messageToBeSent :: String,
  issueId :: Maybe String,
  chatConfig :: ChatView.Config,
  selectedOptionId :: Maybe String,
  categoryAction :: String,
  addedImages :: Array { image :: String, imageName :: String },
  categoryId :: String,
  recordAudioState :: RecordAudioModel.RecordAudioModelState,
  addImagesState :: { images :: Array { image :: String, imageName :: String }, stateChanged :: Boolean, isLoading :: Boolean, imageMediaIds :: Array String },
  viewImageState :: { image :: String, imageName :: Maybe String },
  recordedAudioUrl :: Maybe String,
  addAudioState :: { audioFile :: Maybe String, stateChanged :: Boolean },
  uploadedImagesIds :: Array String,
  uploadedAudioId :: Maybe String,
  options :: Array
             { issueOptionId :: String
             , option :: String
             , label :: String
             }
}

type ReportIssueChatScreenProps = {
  showSubmitComp :: Boolean,
  showImageModel :: Boolean,
  showAudioModel :: Boolean,
  showRecordModel :: Boolean,
  showCallCustomerModel :: Boolean,
  isReversedFlow :: Boolean,
  showViewImageModel :: Boolean,
  isPopupModelOpen :: Boolean
}

type IssueInfo = {

    issueReportId :: String,
    status :: String,
    category :: String,
    createdAt :: String

}

data IssueModalType = HELP_AND_SUPPORT_SCREEN_MODAL | ONGOING_ISSUES_MODAL | RESOLVED_ISSUES_MODAL | BACKPRESSED_MODAL

derive instance genericIssueModalType :: Generic IssueModalType _
instance eqIssueModalType :: Eq IssueModalType where eq = genericEq
--------------------------------------------- AboutUsScreenState ---------------------------
type WriteToUsScreenState = {
  data :: WriteToUsScreenData,
  props :: WriteToUsScreenProps
}

type WriteToUsScreenData = {

}

type WriteToUsScreenProps = {
  isThankYouScreen :: Boolean
}


------------------------------------------- PermissionsScreenState ---------------------------
type PermissionsScreenState = {
  data :: PermissionsScreenData
  , props :: PermissionsScreenProps
}

type PermissionsScreenData = {
  logField :: Object Foreign

}

type PermissionsScreenProps = {
  isLocationPermissionChecked :: Boolean
  , isOverlayPermissionChecked :: Boolean
  , isAutoStartPermissionChecked :: Boolean
  , androidVersion :: Int
  , isBatteryOptimizationChecked :: Boolean
}

------------------------------------------- OnBoardingSubscriptionScreenState ---------------------------
type OnBoardingSubscriptionScreenState = {
  data :: OnBoardingSubscriptionScreenData
  , props :: OnBoardingSubscriptionScreenProps
}

type OnBoardingSubscriptionScreenData = {
  plansList :: Array PlanCardConfig,
  selectedPlanItem :: Maybe PlanCardConfig
}

type OnBoardingSubscriptionScreenProps = {
  isSelectedLangTamil :: Boolean,
  screenCount :: Int
}


--------------------------------------------- RideDetailScreenState ---------------------------------------------

type RideDetailScreenState = {
  data :: RideDetailScreenData,
  props :: RideDetailScreenProps
}

type RideDetailScreenData =  {
  sourceAddress :: Location,
  destAddress :: Location,
  rideStartTime :: String,
  rideEndTime :: String,
  bookingDateAndTime :: String,
  totalAmount :: Int,
  customerName :: String
 }

type RideDetailScreenProps =  {
  cashCollectedButton :: Boolean
 }

--------------------------------------------- EditBankDetailsScreen ---------------------------
type EditBankDetailsScreenState = {
  data :: EditBankDetailsScreenData,
  props :: EditBankDetailsScreenProps
}

type EditBankDetailsScreenData = {

}

type EditBankDetailsScreenProps = {
  isInEditBankDetailsScreen :: Boolean
}

--------------------------------------------- EditAadhaarDetailsScreen ---------------------------
type EditAadhaarDetailsScreenState = {
  data :: EditAadhaarDetailsScreenData,
  props :: EditAadhaarDetailsScreenProps
}

type EditAadhaarDetailsScreenData = {

}

type EditAadhaarDetailsScreenProps = {
  isInEditAadharDetailsScreen :: Boolean
}


-- ######################################  InvoiceScreenState   ######################################

type InvoiceScreenState =
  {
    data :: InvoiceScreenData,
    props :: InvoiceScreenProps
  }

type InvoiceScreenData =
  {
    tripCharges :: Number,
    promotion :: Number,
    gst :: Number,
    totalAmount :: Number,
    date :: String
  }

type InvoiceScreenProps =
  {
    paymentMode :: String
  }

--------------------------------------------- PopUpScreenState ---------------------------
type PopUpScreenState = {
  data :: PopUpScreenData,
  props :: PopUpScreenProps
}

type PopUpScreenData = {
  availableRides :: Array Rides
}

type PopUpScreenProps = {}

type AllocationData = {
  searchRequestValidTill :: String,
  searchRequestId :: String,
  startTime :: String,
  baseFare :: Number,
  distance :: Int,
  distanceToPickup :: Int,
  fromLocation :: {
    area :: String,
    state :: String,
    full_address :: String,
    createdAt :: String,
    country :: String,
    building :: String,
    street :: String,
    lat :: Number,
    city :: String,
    areaCode :: String,
    id :: String,
    lon :: Number,
    updatedAt :: String
  },
  toLocation :: {
    area :: String,
    state :: String,
    full_address :: String,
    createdAt :: String,
    country :: String,
    building :: String,
    street :: String,
    lat :: Number,
    city :: String,
    areaCode :: String,
    id :: String,
    lon :: Number,
    updatedAt :: String
  },
  durationToPickup :: Int
}

type RegCardDetails =  {
  title :: String,
  reason :: String,
  image :: String,
  verificationStatus :: String,
  visibility :: String,
  docType :: String,
  status :: String
}


type DriverRideRatingScreenState = {
  data :: DriverRideRatingScreenData,
  props :: DriverRideRatingScreenProps
}

type DriverRideRatingScreenData = {
    rating :: Int
  , rideId :: String
  , feedback :: String
  , customerName :: String
  , activeFeedBackOption :: Maybe FeedbackSuggestions
  , selectedFeedbackOption :: String
}

type DriverRideRatingScreenProps = {

}

type AppUpdatePopUpScreenState = {
  version :: Int
  , updatePopup :: UpdatePopupType
}

data UpdatePopupType =  AppVersion
                      | DateAndTime
                      | NoUpdatePopup

derive instance genericUpdatePopupType :: Generic UpdatePopupType _
instance showUpdatePopupType :: Show UpdatePopupType where show = genericShow
instance eqUpdatePopupType :: Eq UpdatePopupType where eq = genericEq

data FeedbackSuggestions
 = CUSTOMER_RUDE_BEHAVIOUR
  | LONG_WAIT_TIME
  | DIDNT_COME_TO_PICUP
  | NOTHING

derive instance genericFeedbackSuggestions :: Generic FeedbackSuggestions _
instance eqFeedbackSuggestions :: Eq FeedbackSuggestions where eq = genericEq

data HomeScreenStage =  HomeScreen
                      | RideRequested
                      | RideAccepted
                      | RideStarted
                      | RideCompleted
                      | ChatWithCustomer

derive instance genericHomeScreenStage :: Generic HomeScreenStage _
instance showHomeScreenStage :: Show HomeScreenStage where show = genericShow
instance eqHomeScreenStage :: Eq HomeScreenStage where eq = genericEq
instance decodeHomeScreenStage :: Decode HomeScreenStage where decode = defaultEnumDecode
instance encodeHomeScreenStage :: Encode HomeScreenStage where encode = defaultEnumEncode

data NotificationType =  DRIVER_REACHED
                      | CANCELLED_PRODUCT
                      | DRIVER_ASSIGNMENT
                      | RIDE_REQUESTED

derive instance genericNotificationType :: Generic NotificationType _
instance showNotificationType :: Show NotificationType where show = genericShow
instance eqNotificationType :: Eq NotificationType where eq = genericEq


------------------------------------- NotificationScreen ------------------------------
type NotificationsScreenState = {
  shimmerLoader :: AnimationState,
  prestoListArrayItems :: Array NotificationCardPropState,
  notificationList :: Array NotificationCardState,
  selectedItem :: NotificationCardState,
  offsetValue :: Int,
  loaderButtonVisibility :: Boolean,
  loadMoreDisabled :: Boolean,
  recievedResponse :: Boolean,
  notificationDetailModelState :: NotificationDetailModelState,
  notifsDetailModelVisibility :: Visibility,
  loadMore :: Boolean,
  selectedNotification :: Maybe String,
  deepLinkActivated :: Boolean
}

type NotificationCardState = {
  mediaUrl :: String,
  title :: String,
  description :: String,
  action1Text :: String,
  action2Text :: String,
  notificationLabel :: String,
  timeLabel :: String,
  messageId :: String,
  notificationNotSeen :: Boolean,
  comment :: Maybe String,
  imageUrl :: String,
  mediaType :: Maybe MediaType,
  likeCount :: Int,
  viewCount :: Int,
  likeStatus :: Boolean
}

type NotificationCardPropState = {
  mediaUrl :: PropValue,
  title :: PropValue,
  action1Text :: PropValue,
  action2Text :: PropValue,
  notificationLabel :: PropValue,
  timeLabel :: PropValue,
  description :: PropValue,
  cardVisibility :: PropValue,
  shimmerVisibility :: PropValue,
  notificationLabelColor :: PropValue,
  action1Visibility :: PropValue,
  action2Visibility :: PropValue,
  descriptionVisibility :: PropValue,
  illustrationVisibility :: PropValue,
  notificationNotSeen :: PropValue,
  playBtnVisibility :: PropValue,
  imageUrl :: PropValue,
  playButton :: PropValue,
  previewImage :: PropValue,
  previewImageTitle :: PropValue,
  imageVisibility :: PropValue,
  messageId :: PropValue,
  imageWithUrl :: PropValue,
  imageWithUrlVisibility :: PropValue,
  likeCount :: PropValue,
  viewCount :: PropValue
}

type NotificationDetailModelState = {
  mediaUrl :: String,
  title :: String,
  timeLabel :: String,
  description :: Array String,
  actionText :: String,
  actionVisibility :: Visibility,
  addCommentModelVisibility :: Visibility,
  comment :: Maybe String,
  commentBtnActive :: Boolean,
  messageId :: String,
  notificationNotSeen :: Boolean,
  imageUrl :: String,
  mediaType :: Maybe MediaType,
  likeCount :: Int,
  likeStatus :: Boolean,
  viewCount :: Int
}

type YoutubeData = {
    videoTitle :: String
  , setVideoTitle :: Boolean
  , showMenuButton :: Boolean
  , showDuration :: Boolean
  , showSeekBar :: Boolean
  , videoId :: String
  , videoType :: String
}

data YoutubeVideoStatus = PLAY | PAUSE

derive instance genericYoutubeVideoStatus:: Generic YoutubeVideoStatus _
instance showYoutubeVideoStatus :: Show YoutubeVideoStatus where show = genericShow
instance eqYoutubeVideoStatus :: Eq YoutubeVideoStatus where eq = genericEq


data ReferralType = SuccessScreen | ComingSoonScreen | ReferralFlow | QRScreen | LeaderBoard

derive instance genericReferralType :: Generic ReferralType _
instance eqReferralType :: Eq ReferralType where eq = genericEq


type BookingOptionsScreenState = {
  data :: BookingOptionsScreenData,
  props :: BookingOptionsScreenProps
}

type BookingOptionsScreenData = {
  vehicleType :: String,
  vehicleNumber :: String,
  vehicleName :: String,
  vehicleCapacity :: Int,
  downgradeOptions :: Array ChooseVehicle.Config
}

type BookingOptionsScreenProps = {
  isBtnActive :: Boolean,
  downgraded :: Boolean
}

data LeaderBoardType = Daily | Weekly

derive instance genericLeaderBoardType :: Generic LeaderBoardType _
instance eqLeaderBoardType :: Eq LeaderBoardType where eq = genericEq


data DateSelector = DaySelector Common.CalendarDate | WeekSelector Common.CalendarWeek

type RankCardData = {
    goodName :: String
  , profileUrl :: Maybe String
  , rank :: Int
  , rides :: Int
}

type AcknowledgementScreenState = {
  data :: AcknowledgementScreenData,
  props :: AcknowledgementScreenProps
}

type AcknowledgementScreenData = {
  illustrationAsset :: String,
  title :: Maybe String,
  description ::Maybe String,
  primaryButtonText :: Maybe String,
  orderId  :: Maybe String,
  amount :: String
}

type AcknowledgementScreenProps = {
  primaryButtonVisibility :: Visibility,
  paymentStatus :: Common.PaymentStatus,
  illustrationType :: IllustrationType
}

data IllustrationType = Image | Lottie

derive instance genericIllustrationType:: Generic IllustrationType _
instance showIllustrationType :: Show IllustrationType where show = genericShow
instance eqIllustrationType :: Eq IllustrationType where eq = genericEq

type PaymentHistoryModelState = {
  paymentHistoryList :: Array PaymentHistoryListItem.Config
}
--------------------------------------------------------------- AadhaarVerificationScreenState -----------------------------------------------------------------------------
type AadhaarVerificationScreenState = {
  data :: EnterAadhaarNumberScreenStateData,
  props :: EnterAadhaarNumberScreenStateProps
}

type EnterAadhaarNumberScreenStateData = {
    aadhaarNumber :: String
  , timer :: String
  , otp :: String
  , driverName :: String
  , driverGender :: String
  , driverDob :: String
}

type EnterAadhaarNumberScreenStateProps = {
  btnActive :: Boolean
, isValid :: Boolean
, resendEnabled :: Boolean
, currentStage :: AadhaarStage
, showErrorAadhaar :: Boolean
, fromHomeScreen :: Boolean
, showLogoutPopup :: Boolean
, isDateClickable :: Boolean
}

data AadhaarStage = EnterAadhaar | VerifyAadhaar | AadhaarDetails

derive instance genericAadhaarStage :: Generic AadhaarStage _
instance eqAadhaarStage :: Eq AadhaarStage where eq = genericEq

type GlobalProps = {
  aadhaarVerificationRequired :: Boolean,
  driverInformation :: GetDriverInfoResp,
  callScreen :: ScreenName
}

--------------------------------------------------------------- SubscriptionScreenState ---------------------------------------------------

type SubscriptionScreenState = {
  data :: SubscriptionScreenData,
  props :: SubscriptionScreenProps
}

type SubscriptionScreenData = {
  myPlanData :: MyPlanData,
  managePlanData :: ManagePlanData,
  joinPlanData :: JoinPlanData,
  autoPayDetails :: AutoPayDetails,
  driverId :: String,
  paymentMode :: String,
  planId :: String,
  orderId :: Maybe String,
  errorMessage :: String
}

type AutoPayDetails = {
  isActive :: Boolean,
  detailsList :: Array KeyValType,
  payerUpiId :: Maybe String,
  pspLogo :: String
}

type KeyValType = {
  key :: String,
  val :: String
}

type SubscriptionScreenProps = {
  subView :: SubscriptionSubview,
  myPlanProps :: MyPlanProps,
  managePlanProps :: ManagePlanProps,
  joinPlanProps :: JoinPlanProps,
  popUpState :: Maybe SubscribePopupType,
  paymentStatus :: Maybe Common.PaymentStatus,
  resumeBtnVisibility :: Boolean,
  showError :: Boolean,
  showShimmer :: Boolean,
  isDueViewExpanded :: Boolean,
  refreshPaymentStatus :: Boolean,
  confirmCancel :: Boolean,
  isSelectedLangTamil :: Boolean,
  currentLat :: Number,
  currentLon :: Number,
  destLat :: Number,
  destLon :: Number,
  kioskLocation :: Array KioskLocation,
  prevSubView :: SubscriptionSubview,
  noKioskLocation :: Boolean,
  optionsMenuState :: OptionsMenuState,
  redirectToNav :: String
}

type JoinPlanData = {
  allPlans :: Array PlanCardConfig,
  subscriptionStartDate :: String
}

type JoinPlanProps = {
  paymentMode :: String,
  selectedPlanItem :: Maybe PlanCardConfig
}

type ManagePlanData = {
  currentPlan :: PlanCardConfig,
  alternatePlans :: Array PlanCardConfig
}

type ManagePlanProps = {
  selectedPlanItem :: PlanCardConfig
}

type MyPlanData = {
  dueItems :: Array DueItem,
  planEntity :: PlanCardConfig,
  autoPayStatus :: AutoPayStatus,
  lowAccountBalance :: Boolean,
  switchAndSave :: Boolean,
  paymentMethodWarning :: Boolean,
  maxDueAmount :: Number,
  currentDueAmount :: Number,
  mandateStatus :: String
}

type MyPlanProps = {
  isDuesExpanded :: Boolean
}

type DueItem = {
  tripDate :: String,
  amount :: String
}

type KioskLocation = {
  longitude :: Number,
  address :: String,
  contact :: Maybe String,
  latitude :: Number,
  landmark :: String,
  distance :: Number
}

type PlanCardConfig = {
    id :: String
  , title :: String
  , description :: String
  , isSelected :: Boolean
  , offers :: Array PromoConfig
  , priceBreakup :: Array PaymentBreakUp
  , frequency :: String
  , freeRideCount :: Int
  , showOffer :: Boolean
}

type PromoConfig = {
    title :: Maybe String
  , isGradient :: Boolean
  , gradient :: Array String
  , hasImage :: Boolean
  , imageURL :: String
  , offerDescription :: Maybe String
  , addedFromUI :: Boolean
}

data SubscribePopupType = SuccessPopup | FailedPopup | DuesClearedPopup | CancelAutoPay | SwitchedPlan | SupportPopup

derive instance genericSubscribePopupType :: Generic SubscribePopupType _
instance showSubscribePopupType :: Show SubscribePopupType where show = genericShow
instance eqSubscribePopupType :: Eq SubscribePopupType where eq = genericEq
instance decodeSubscribePopupType :: Decode SubscribePopupType where decode = defaultEnumDecode
instance encodeSubscribePopupType :: Encode SubscribePopupType where encode = defaultEnumEncode

data AutoPayStatus = ACTIVE_AUTOPAY | SUSPENDED | PAUSED_PSP | CANCELLED_PSP | NO_AUTOPAY | PENDING | MANDATE_FAILED

derive instance genericAutoPayStatus:: Generic AutoPayStatus _
instance showAutoPayStatus:: Show AutoPayStatus where show = genericShow
instance eqAutoPayStatus:: Eq AutoPayStatus where eq = genericEq

data SubscriptionSubview = JoinPlan | ManagePlan | MyPlan | PlanDetails | FindHelpCentre | NoSubView 

derive instance genericSubscriptionSubview :: Generic SubscriptionSubview _
instance showSubscriptionSubview :: Show SubscriptionSubview where show = genericShow
instance eqSubscriptionSubview :: Eq SubscriptionSubview where eq = genericEq
instance decodeSubscriptionSubview :: Decode SubscriptionSubview where decode = defaultEnumDecode
instance encodeSubscriptionSubview :: Encode SubscriptionSubview where encode = defaultEnumEncode

data OptionsMenuState = ALL_COLLAPSED | PLAN_MENU  -- SUPPORT_MENU  | CALL_MENU disabled for now.

derive instance genericOptionsMenuState :: Generic OptionsMenuState _
instance showOptionsMenuState :: Show OptionsMenuState where show = genericShow
instance eqOptionsMenuState :: Eq OptionsMenuState where eq = genericEq

---------------------------------------------------- PaymentHistoryScreen ----------------------------------

type PaymentHistoryScreenState = {
  data :: PaymentHistoryScreenData,
  props :: PaymentHistoryScreenProps
}

type PaymentHistoryScreenData = {
  paymentListItem :: Array PaymentListItem,
  transactionListItem :: Array TransactionListItem,
  manualPaymentRidesListItem :: Array TransactionListItem
}
type PaymentListItem = {
  paidDate :: String,
  rideTakenDate :: String,
  amount :: String,
  paymentStatus :: Common.PaymentStatus
}

type TransactionListItem = {
  key :: String,
  title :: String,
  val :: String
}

type PaymentHistoryScreenProps = {
  subView :: PaymentHistorySubview,
  autoPayHistory :: Boolean
}

data PaymentHistorySubview = PaymentHistory | TransactionDetails | RideDetails

derive instance genericPaymentHistorySubview :: Generic PaymentHistorySubview _
instance showPaymentHistorySubview :: Show PaymentHistorySubview where show = genericShow
instance eqPaymentHistorySubview :: Eq PaymentHistorySubview where eq = genericEq
instance decodePaymentHistorySubview :: Decode PaymentHistorySubview where decode = defaultEnumDecode
instance encodePaymentHistorySubview :: Encode PaymentHistorySubview where encode = defaultEnumEncode

type UpiApps
  = { supportsPay :: Boolean
    , supportsMandate :: Boolean
    , packageName :: String
    , appName :: String
    }

