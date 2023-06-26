{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.HomeScreen.ComponentConfig where

import Language.Strings (getString)
import Prelude(unit, ($), (-), (/), (<), (<=), (<>), (==), (>=), (||), show)
import PrestoDOM (Gravity(..), Length(..), Margin(..), Visibility(..))
import Components.SelectListModal as SelectListModal
import Components.Banner as Banner
import Components.PopUpModal as PopUpModal
import Components.RideActionModal as RideActionModal
import Components.StatsModel as StatsModel
import Components.ChatView as ChatView
import Data.Array as DA
import Data.Maybe (Maybe(..), fromMaybe)
import Data.String as DS
import Engineering.Helpers.Commons as EHC
import Font.Size as FontSize
import Helpers.Utils as HU
import Components.InAppKeyboardModal as InAppKeyboardModal
import Language.Strings
import Language.Types (STR(..))
import PrestoDOM.Types.DomAttributes as PTD
import Screens.Types as ST
import Styles.Colors as Color
import Storage (KeyStore(..), getValueToLocalStore)
import JBridge as JB
import Components.MakePaymentModal as MakePaymentModal
import Components.RateCard as RateCard
import Common.Types.App as CommonTypes


--------------------------------- rideActionModalConfig -------------------------------------
rideActionModalConfig :: ST.HomeScreenState -> RideActionModal.Config
rideActionModalConfig state = let
  config = RideActionModal.config
  rideActionModalConfig' = config {
    startRideActive = if state.props.currentStage == ST.RideAccepted then true else false,
    totalDistance = if state.data.activeRide.distance <= 0.0 then "0.0" else if(state.data.activeRide.distance < 1000.0) then HU.parseFloat (state.data.activeRide.distance) 2 <> " m" else HU.parseFloat((state.data.activeRide.distance / 1000.0)) 2 <> " km",
    customerName = if DS.length (fromMaybe "" ((DS.split (DS.Pattern " ") (state.data.activeRide.riderName)) DA.!! 0)) < 4
                      then (fromMaybe "" ((DS.split (DS.Pattern " ") (state.data.activeRide.riderName)) DA.!! 0)) <> " " <> (fromMaybe "" ((DS.split (DS.Pattern " ") (state.data.activeRide.riderName)) DA.!! 1))
                      else
                        (fromMaybe "" ((DS.split (DS.Pattern " ") (state.data.activeRide.riderName)) DA.!! 0)),
    sourceAddress  {
      titleText = fromMaybe "" ((DS.split (DS.Pattern ",") (state.data.activeRide.source)) DA.!! 0),
      detailText = state.data.activeRide.source
    },
    destinationAddress {
      titleText = fromMaybe "" ((DS.split (DS.Pattern ",") (state.data.activeRide.destination)) DA.!! 0),
      detailText = state.data.activeRide.destination
    },
    estimatedRideFare = state.data.activeRide.estimatedFare,
    isDriverArrived = state.data.activeRide.isDriverArrived,
    notifiedCustomer = state.data.activeRide.notifiedCustomer,
    currentStage = state.props.currentStage,
    unReadMessages = state.props.unReadMessages,
    specialLocationTag = state.data.activeRide.specialLocationTag
  }
  in rideActionModalConfig'

---------------------------------------- endRidePopUp -----------------------------------------
endRidePopUp :: ST.HomeScreenState -> PopUpModal.Config
endRidePopUp state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
    primaryText {text = (getString END_RIDE)},
    secondaryText {text = (getString ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE)},
    option1 {text =(getString GO_BACK)},
    option2 {text = (getString END_RIDE)}
  }
  in popUpConfig'

------------------------------------------ cancelRideModalConfig ---------------------------------
cancelRideModalConfig :: ST.HomeScreenState -> SelectListModal.Config
cancelRideModalConfig state = let
  config = SelectListModal.config
  lastIndex = ((DA.length state.data.cancelRideModal.selectionOptions) -1)
  cancelRideModalConfig' = config {
    activeIndex = state.data.cancelRideModal.activeIndex,
    hint = (getString HELP_US_WITH_YOUR_REASON),
    strings {
      mandatory = (getString MANDATORY),
      limitReached = ((getString MAX_CHAR_LIMIT_REACHED) <> " 100 " <> (getString OF) <> " 100")
    },
    headingTextConfig{
      text = ((getString CANCEL_RIDE) <> "?")
    },
    subHeadingTextConfig{
      text = (getString PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL)
    },
    showAllOptionsText = (getString SHOW_ALL_OPTIONS),
    selectionOptions = state.data.cancelRideModal.selectionOptions,
    isLimitExceeded = ((DS.length (state.data.cancelRideModal.selectedReasonDescription)) >= 100),
    activeReasonCode = Just state.data.cancelRideModal.selectedReasonCode,
    primaryButtonTextConfig {
      firstText = (getString GO_BACK)
    , secondText = (getString CANCEL_RIDE)
    },
    isSelectButtonActive = case state.data.cancelRideModal.activeIndex of
                              Just index -> true
                              Nothing    -> false
  }
  in cancelRideModalConfig'

---------------------------------- statsModelConfig --------------------------------
statsModelConfig :: ST.HomeScreenState -> StatsModel.Config
statsModelConfig state =
  let
    config = StatsModel.config
    config' = config
      { countTextConfig { text = getString TRIP_COUNT }
      , earningsTextConfig { text = getString TODAYS_EARNINGS }
      , textConfig {  text = "" }
      , totalRidesOfDay = state.data.totalRidesOfDay
      , totalEarningsOfDay = state.data.totalEarningsOfDay
      }
  in config'

-------------------------------------genderBannerConfig------------------------------------
genderBannerConfig :: ST.HomeScreenState -> Banner.Config
genderBannerConfig state =
  let
    config = Banner.config
    config' = config
      {
        backgroundColor = Color.green600,
        title = (getString COMPLETE_YOUR_PROFILE_AND_FIND_MORE_RIDES),
        titleColor = Color.white900,
        actionText = (getString UPDATE_NOW),
        actionTextColor = Color.white900,
        imageUrl = "ny_ic_driver_gender_banner,https://assets.juspay.in/beckn/nammayatri/driver/images/ny_ic_driver_gender_banner.png",
        isBanner = true
      }
  in config'

------------------------------------ cancelConfirmationConfig -----------------------------
cancelConfirmationConfig :: ST.HomeScreenState -> PopUpModal.Config
cancelConfirmationConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
    gravity = CENTER,
    margin = MarginHorizontal 24 24 ,
    buttonLayoutMargin = Margin 16 0 16 20 ,
    primaryText {
      text = case state.data.activeRide.specialLocationTag of
              Nothing -> getString FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES
              Just specialLocationTag -> getString $ getCancelAlertText $ HU.getSpecialZoneConfig  "cancelText" (Just specialLocationTag)
    , margin = Margin 16 24 16 24 },
    secondaryText {visibility = GONE},
    option1 {
      text = (getString CONTINUE)
    , fontSize = FontSize.a_16
    , width = V $ (((EHC.screenWidth unit)-92)/2)
    , isClickable = state.data.cancelRideConfirmationPopUp.continueEnabled
    , timerValue = state.data.cancelRideConfirmationPopUp.delayInSeconds
    , enableTimer = true
    , background = Color.white900
    , strokeColor = Color.black500
    , color = Color.black700
    },
    option2 {
      text = (getString GO_BACK)
    , margin = MarginLeft 12
    , fontSize = FontSize.a_16
    , width = V $ (((EHC.screenWidth unit)-92)/2)
    , color = Color.yellow900
    , strokeColor = Color.black900
    , background = Color.black900
    },
    backgroundClickable = false,
    cornerRadius = (PTD.Corners 15.0 true true true true),
    coverImageConfig {
      imageUrl = if state.data.activeRide.specialLocationTag == Nothing then "ic_cancel_prevention,https://assets.juspay.in/nammayatri/images/driver/ny_ic_cancel_prevention.png"
                  else HU.getSpecialZoneConfig "cancelConfirmImage" (state.data.activeRide.specialLocationTag)
    , visibility = VISIBLE
    , margin = Margin 16 20 16 0
    , height = V 178
    }
  }
  in popUpConfig'

------------------------------------ chatViewConfig -----------------------------
chatViewConfig :: ST.HomeScreenState -> ChatView.Config
chatViewConfig state = let
  config = ChatView.config
  chatViewConfig' = config {
    userConfig {
      userName = state.data.activeRide.riderName,
      appType = "Driver"
    }
    , messages = state.data.messages
    , messagesSize = state.data.messagesSize
    , sendMessageActive = state.props.sendMessageActive
    , distance = ""
    , suggestionsList = (if (state.data.activeRide.isDriverArrived || state.data.activeRide.notifiedCustomer) then pickupSuggestions "" else initialSuggestions "")
    , hint = (getString MESSAGE)
    , suggestionHeader = (getString START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS)
    , emptyChatHeader = (getString START_YOUR_CHAT_WITH_THE_DRIVER)
    , mapsText = (getString MAPS)
    , languageKey = (getValueToLocalStore LANGUAGE_KEY)
    , grey700 = Color.grey700
    , blue600 = Color.blue600
    , blue900 = Color.blue900
    , transparentGrey = Color.transparentGrey
    , green200 = Color.green200
    , grey900 = Color.grey900
    , grey800 = Color.grey800
    , blue800 = Color.blue800
    , white900 = Color.white900
    , black800 = Color.black800
    , black700 = Color.black700
  }
  in chatViewConfig'

initialSuggestions :: String -> Array String
initialSuggestions _ =
  [
    (getString I_AM_ON_MY_WAY),
    (getString GETTING_DELAYED_PLEASE_WAIT),
    (getString UNREACHABLE_PLEASE_CALL_BACK)
  ]

pickupSuggestions :: String -> Array String
pickupSuggestions _ =
  [
    (getString I_HAVE_ARRIVED),
    (getString PLEASE_COME_FAST_I_AM_WAITING),
    (getString UNREACHABLE_PLEASE_CALL_BACK)
  ]
silentModeConfig :: ST.HomeScreenState -> PopUpModal.Config
silentModeConfig state = let
  config' = PopUpModal.config
  popUpConfig' = config'{
    gravity = CENTER
  , cornerRadius = (PTD.Corners 15.0 true true true true)
  , backgroundClickable = false
  , margin = (Margin 16 0 16 0)
  , primaryText {
      text = getString TRY_SILENT_MODE
    }
  , secondaryText {
      text =  getString SILENT_MODE_PROMPT
    }
    , option1 {
      text =   getString GO_OFFLINE
      , width = (V 140)
    }
  , option2 {
      width = (V 170)
      , text =  getString GO_SILENT
    }
  }
  in popUpConfig'





enterOtpStateConfig :: ST.HomeScreenState -> InAppKeyboardModal.InAppKeyboardModalState
enterOtpStateConfig state = let
      config' = InAppKeyboardModal.config
      inAppModalConfig' = config'{
      otpIncorrect = if (state.props.otpAttemptsExceeded) then false else (state.props.otpIncorrect),
      otpAttemptsExceeded = (state.props.otpAttemptsExceeded),
      inputTextConfig {
        text = state.props.rideOtp,
        -- pattern = "[0-9]*,4",
        fontSize = FontSize.a_22,
        focusIndex = state.props.enterOtpFocusIndex
      },
      headingConfig {
        text = getString (ENTER_OTP)
      },
      errorConfig {
        text = if (state.props.otpIncorrect) then (getString ENTERED_WRONG_OTP) else (getString OTP_LIMIT_EXCEEDED),
        visibility = if (state.props.otpIncorrect || state.props.otpAttemptsExceeded) then VISIBLE else GONE
      },
      subHeadingConfig {
        text = getString (PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP),
        fontSize = FontSize.a_14,
        visibility = if (state.props.otpAttemptsExceeded) then GONE else VISIBLE
      },
      imageConfig {
        alpha = if(DS.length state.props.rideOtp < 4) then 0.3 else 1.0
      },
      modalType = ST.OTP
      }
      in inAppModalConfig'

driverStatusIndicators :: Array ST.PillButtonState
driverStatusIndicators = [
    {
      status : ST.Offline,
      background : Color.red,
      imageUrl : "ic_driver_status_offline,https://assets.juspay.in/beckn/nammayatri/driver/images/ic_driver_status_offline.png",
      textColor : Color.white900
    },
    {
        status : ST.Silent,
        background : Color.blue800,
        imageUrl : "ic_driver_status_silent,https://assets.juspay.in/beckn/nammayatri/driver/images/ic_driver_status_silent.png",
        textColor : Color.white900
    },
    {
      status : ST.Online,
        background : Color.darkMint,
        imageUrl : "ic_driver_status_online,https://assets.juspay.in/beckn/nammayatri/driver/images/ic_driver_status_online.png",
        textColor : Color.white900
    }
]
getCancelAlertText :: String -> STR
getCancelAlertText key = case key of
  "ZONE_CANCEL_TEXT_PICKUP" -> ZONE_CANCEL_TEXT_PICKUP
  "ZONE_CANCEL_TEXT_DROP" -> ZONE_CANCEL_TEXT_DROP
  _ -> FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES

specialLocationConfig :: String -> String -> JB.SpecialLocationTag
specialLocationConfig srcIcon destIcon = {
    sourceSpecialTagIcon : srcIcon
  , destSpecialTagIcon : destIcon
}

makePaymentState :: ST.HomeScreenState -> MakePaymentModal.MakePaymentModalState
makePaymentState state = {
  title : getString GREAT_JOB,
  description : getString YOU_HAVE_COMPLETED_RIDES_YESTERDAY,
  description2 : getString TO_CONTINUE_USING_YATRI_SATHI,
  okButtontext : "Pay ₹" <> (show state.data.paymentState.payableAndGST) <> " now",
  cancelButtonText : getString LATER,
  ridesCount : state.data.paymentState.rideCount,
  feeItem : [
    { feeType : MakePaymentModal.TOTAL_COLLECTED,
      title : getString TOTAL_MONEY_COLLECTED,
      val : state.data.paymentState.totalMoneyCollected},
    { feeType : MakePaymentModal.EARNED_OF_THE_DAY,
      title : getString FARE_EARNED_OF_THE_DAY,
      val : (state.data.paymentState.totalMoneyCollected - state.data.paymentState.payableAndGST)},
    { feeType : MakePaymentModal.GST_PAYABLE,
      title : getString GST_PLUS_PAYABLE,
      val : state.data.paymentState.payableAndGST}
  ]
}

rateCardState :: ST.HomeScreenState -> RateCard.Config
rateCardState state =
  let
    config' = RateCard.config
    rateCardConfig' =
      config'
        { title = getString FEE_BREAKUP
        , description = getString YATRI_SATHI_FEE_PAYABLE_FOR_DATE
        , buttonText = getString VIEW_DETAILS
        , currentRateCardType = CommonTypes.PaymentFareBreakup
        , primaryButtonText = getString GOT_IT
        , additionalStrings = [
          {key : "FEE_CORRESPONDING_to_DISTANCE", val : getString FEE_CORRESPONDING_TO_THE_DISTANCE},
          {key : "GOT_IT", val : getString GOT_IT},
          {key : "TOTAL_PAYABLE", val : getString TOTAL_PAYABLE},
          {key : "TOTAL_PAYABLE_VAL", val : "₹" <> (show state.data.paymentState.payableAndGST)}]
          
        , fareList = [
          {key : getString PLATFORM_FEE , val : "₹" <> (show state.data.paymentState.platFromFee)},
          {key : getString GST , val : "₹" <> show (state.data.paymentState.payableAndGST - state.data.paymentState.platFromFee)}]

        }
  in
    rateCardConfig'

paymentStatusConfig :: ST.HomeScreenState -> Banner.Config
paymentStatusConfig state = 
  let 
    config = Banner.config
    config' = config
      { 
        backgroundColor = state.data.paymentState.bannerBG,
        title = state.data.paymentState.bannerTitle,
        titleColor = state.data.paymentState.bannerTitleColor,
        actionText = state.data.paymentState.banneActionText,
        actionTextColor = state.data.paymentState.actionTextColor,
        imageUrl = state.data.paymentState.bannerImage,
        isBanner = true
      }
  in config'
