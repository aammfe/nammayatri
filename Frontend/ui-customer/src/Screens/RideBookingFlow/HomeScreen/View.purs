{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.HomeScreen.View where

import Screens.RideBookingFlow.HomeScreen.Config (autoAnimConfig,chooseYourRideConfig, menuButtonConfig, cancelRidePopUpConfig, distanceOusideLimitsConfig, driverInfoCardViewState, emergencyHelpModelViewState, estimateChangedPopupConfig, fareBreakUpConfig, logOutPopUpModelConfig, previousRideRatingViewState, primaryButtonConfirmPickupConfig, primaryButtonRequestRideConfig, quoteListModelViewState, rateCardConfig, rateRideButtonConfig, ratingCardViewState, searchLocationModelViewState, shareAppConfig, shortDistanceConfig, skipButtonConfig, sourceUnserviceableConfig, whereToButtonConfig, chatViewConfig, metersToKm, callSupportConfig,genderBannerConfig,cancelAppConfig, specialLocationIcons, specialLocationConfig)
import Accessor (_lat, _lon, _selectedQuotes, _fareProductType)
import Animation (fadeOut, translateYAnimFromTop, scaleAnim, translateYAnimFromTopWithAlpha, fadeIn)
import Animation.Config (Direction(..), translateFullYAnimWithDurationConfig, translateYAnimHomeConfig)
import Components.Banner.View as Banner
import Components.Banner.Controller as BannerConfig
import Components.ChatView as ChatView
import Common.Types.App (LazyCheck(..))
import Components.SelectListModal as CancelRidePopUp
import Components.ChooseYourRide as ChooseYourRide
import Components.DriverInfoCard as DriverInfoCard
import Components.EmergencyHelp as EmergencyHelp
import Components.ErrorModal as ErrorModal
import Components.FareBreakUp as FareBreakUp
import Components.FavouriteLocationModel as FavouriteLocationModel
import Components.LocationListItem.View as LocationListItem
import Components.LocationTagBar as LocationTagBar
import Components.MenuButton as MenuButton
import Components.PopUpModal as PopUpModal
import Components.PricingTutorialModel as PricingTutorialModel
import Components.PrimaryButton as PrimaryButton
import Components.QuoteListModel.View as QuoteListModel
import Components.RateCard as RateCard
import Components.RatingCard as RatingCard
import Components.RequestInfoCard as RequestInfoCard
import Components.SaveFavouriteCard as SaveFavouriteCard
import Components.SearchLocationModel as SearchLocationModel
import Components.SettingSideBar as SettingSideBar
import Control.Monad.Except (runExceptT)
import Control.Monad.Trans.Class (lift)
import Control.Transformers.Back.Trans (runBackT)
import Data.Array (any, length, mapWithIndex, null, (!!))
import Data.Either (Either(..))
import Data.Int (toNumber, fromString, ceil)
import Data.Lens ((^.))
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Number as NUM
import Data.Time.Duration (Milliseconds(..))
import Debug (spy)
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class (liftEffect)
import Effect.Uncurried (runEffectFn1)
import Effect.Unsafe (unsafePerformEffect)
import Engineering.Helpers.Commons (countDown, flowRunner, getNewIDWithTag, liftFlow, os, safeMarginBottom, safeMarginTop, screenHeight, isPreviousVersion)
import Engineering.Helpers.LogEvent (logEvent)
import Font.Size as FontSize
import Font.Style as FontStyle
import Helpers.Utils (adjustViewWithKeyboard) as HU
import Helpers.Utils (decodeErrorMessage, fetchAndUpdateCurrentLocation, getCurrentLocationMarker, getLocationName, getNewTrackingId, getPreviousVersion, parseFloat, storeCallBackCustomer, storeCallBackLocateOnMap, storeOnResumeCallback, toString, waitingCountdownTimer)
import Helpers.Utils (getAssetStoreLink, getCommonAssetStoreLink, getAssetsBaseUrl)
import JBridge (addMarker, animateCamera, drawRoute, enableMyLocation, firebaseLogEvent, generateSessionId, getCurrentPosition, getExtendedPath, getHeightFromPercent, initialWebViewSetUp, isCoordOnPath, isInternetAvailable, isMockLocation, removeAllPolylines, removeMarker, requestKeyboardShow, showMap, startChatListenerService, startLottieProcess, stopChatListenerService, storeCallBackMessageUpdated, storeCallBackOpenChatScreen, toast, updateRoute)
import Language.Strings (getString)
import Language.Types (STR(..))
import Log (printLog)
import MerchantConfig.Utils (Merchant(..), getValueFromConfig, getMerchant)
import Prelude (Unit, bind, const, discard, map, negate, not, pure, show, unit, void, when, ($), (&&), (*), (+), (-), (/), (/=), (<), (<<<), (<=), (<>), (==), (>), (||))
import Presto.Core.Types.API (ErrorResponse)
import Presto.Core.Types.Language.Flow (Flow, doAff, delay)
import PrestoDOM (BottomSheetState(..), Gradient(..), Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), PrestoDOM, Screen, Visibility(..), adjustViewWithKeyboard, afterRender, alignParentBottom, background, clickable, color, cornerRadius, disableClickFeedback, ellipsize, fontStyle, frameLayout, gradient, gravity, halfExpandedRatio, height, id, imageView, imageWithFallback, lineHeight, linearLayout, lottieAnimationView, margin, maxLines, onBackPressed, onClick, orientation, padding, peakHeight, relativeLayout, singleLine, stroke, text, textFromHtml, textSize, textView, url, visibility, webView, weight, width)
import PrestoDOM.Animation as PrestoAnim
import PrestoDOM.Elements.Elements (bottomSheetLayout, coordinatorLayout)
import PrestoDOM.Properties (cornerRadii, sheetState)
import PrestoDOM.Types.DomAttributes (Corners(..))
import Screens.AddNewAddressScreen.Controller as AddNewAddress
import Screens.HomeScreen.Controller (Action(..), ScreenOutput, checkCurrentLocation, checkSavedLocations, dummySelectedQuotes, eval, flowWithoutOffers, getCurrentCustomerLocation)
import Screens.HomeScreen.ScreenData as HomeScreenData
import Screens.HomeScreen.Transformer (transformSavedLocations)
import Screens.Types (HomeScreenState, LocationListItemState, PopupType(..), SearchLocationModelType(..), Stage(..), CallType(..), ZoneType(..))
import Services.API (GetDriverLocationResp(..), GetQuotesRes(..), GetRouteResp(..), LatLong(..), RideAPIEntity(..), RideBookingRes(..), Route(..), SavedLocationsListRes(..), SearchReqLocationAPIEntity(..), SelectListRes(..), Snapped(..), GetPlaceNameResp(..), PlaceName(..))
import Services.Backend (getDriverLocation, getQuotes, getRoute, makeGetRouteReq, rideBooking, selectList, driverTracking, rideTracking, walkCoordinates, walkCoordinate, getSavedLocationList)
import Services.Backend as Remote
import Storage (KeyStore(..), getValueToLocalStore, isLocalStageOn, setValueToLocalStore, updateLocalStage)
import Styles.Colors as Color
import Types.App (GlobalState, defaultGlobalState)

screen :: HomeScreenState -> Screen Action HomeScreenState ScreenOutput
screen initialState =
  { initialState
  , view
  , name: "HomeScreen"
  , globalEvents:
      [ ( \push -> do
            _ <- pure $ printLog "storeCallBackCustomer initially" "."
            _ <- pure $ printLog "storeCallBackCustomer callbackInitiated" initialState.props.callbackInitiated
            -- push NewUser -- TODO :: Handle the functionality
            -- _ <- isMockLocation push IsMockLocation
            _ <- launchAff $ flowRunner defaultGlobalState $ checkForLatLongInSavedLocations push UpdateSavedLoc initialState
            if (not initialState.props.callbackInitiated) then do
              _ <- pure $ printLog "storeCallBackCustomer initiateCallback" "."
              _ <- storeCallBackCustomer push NotificationListener
              _ <- storeOnResumeCallback push OnResumeCallback
              push HandleCallback
              pure unit
            else do
              pure unit
            case initialState.props.currentStage of
              SearchLocationModel -> case initialState.props.isSearchLocation of
                LocateOnMap -> do
                  _ <- storeCallBackLocateOnMap push UpdateLocation
                  pure unit
                _ -> do
                  case initialState.props.isSource of
                    Just index -> do
                      _ <- pure $ requestKeyboardShow (if index then (getNewIDWithTag "SourceEditText") else (getNewIDWithTag "DestinationEditText"))
                      pure unit
                    Nothing -> pure unit
                  pure unit
              FindingEstimate -> do
                _ <- removeMarker (getCurrentLocationMarker (getValueToLocalStore VERSION_NAME))
                _ <- launchAff $ flowRunner defaultGlobalState $ getEstimate GetEstimates CheckFlowStatusAction 10 1000.0 push initialState
                pure unit
              FindingQuotes -> do
                when ((getValueToLocalStore FINDING_QUOTES_POLLING) == "false") $ do
                  _ <- pure $ setValueToLocalStore FINDING_QUOTES_POLLING "true"
                  _ <- countDown initialState.props.searchExpire "" push SearchExpireCountDown
                  _ <- pure $ setValueToLocalStore GOT_ONE_QUOTE "FALSE"
                  _ <- pure $ setValueToLocalStore TRACKING_ID (getNewTrackingId unit)
                  let pollingCount = ceil ((toNumber initialState.props.searchExpire)/((fromMaybe 0.0 (NUM.fromString (getValueToLocalStore TEST_POLLING_INTERVAL))) / 1000.0))
                  void $ launchAff $ flowRunner defaultGlobalState $ getQuotesPolling (getValueToLocalStore TRACKING_ID) GetQuotesList Restart pollingCount (fromMaybe 0.0 (NUM.fromString (getValueToLocalStore TEST_POLLING_INTERVAL))) push initialState
              ConfirmingRide -> void $ launchAff $ flowRunner defaultGlobalState $ confirmRide GetRideConfirmation 5 3000.0 push initialState
              HomeScreen -> do
                _ <- pure $ setValueToLocalStore SESSION_ID (generateSessionId unit)
                _ <- pure $ removeAllPolylines ""
                _ <- pure $ enableMyLocation true
                fetchAndUpdateCurrentLocation push UpdateLocAndLatLong RecenterCurrentLocation
              RideAccepted -> do
                _ <- pure $ enableMyLocation true
                _ <- removeMarker (getCurrentLocationMarker (getValueToLocalStore VERSION_NAME))
                if ((getValueToLocalStore DRIVER_ARRIVAL_ACTION) == "TRIGGER_WAITING_ACTION") then waitingCountdownTimer initialState.data.driverInfoCardState.driverArrivalTime push WaitingTimeAction else pure unit
                if ((getValueToLocalStore TRACKING_DRIVER) == "False") then do
                  _ <- pure $ setValueToLocalStore TRACKING_ID (getNewTrackingId unit)
                  void $ launchAff $ flowRunner defaultGlobalState $ driverLocationTracking push UpdateCurrentStage DriverArrivedAction UpdateETA 3000.0 (getValueToLocalStore TRACKING_ID) initialState "pickup"
                else pure unit
                if(not initialState.props.chatcallbackInitiated) && (not initialState.props.isSpecialZone) then do
                  _ <- storeCallBackMessageUpdated push initialState.data.driverInfoCardState.bppRideId "Customer" UpdateMessages
                  _ <- storeCallBackOpenChatScreen push OpenChatScreen
                  _ <- startChatListenerService
                  push InitializeChat
                  pure unit
                else
                  pure unit
              RideStarted -> do
                _ <- pure $ enableMyLocation false
                _ <- removeMarker (getCurrentLocationMarker (getValueToLocalStore VERSION_NAME))
                if ((getValueToLocalStore TRACKING_DRIVER) == "False") then do
                  _ <- pure $ setValueToLocalStore TRACKING_ID (getNewTrackingId unit)
                  _ <- launchAff $ flowRunner defaultGlobalState $ driverLocationTracking push UpdateCurrentStage DriverArrivedAction UpdateETA 20000.0 (getValueToLocalStore TRACKING_ID) initialState "trip"
                  pure unit
                else
                  pure unit
                _ <- push RemoveChat
                pure unit
              ChatWithDriver -> if ((getValueToLocalStore DRIVER_ARRIVAL_ACTION) == "TRIGGER_WAITING_ACTION") then waitingCountdownTimer initialState.data.driverInfoCardState.driverArrivalTime push WaitingTimeAction else pure unit
              ConfirmingLocation -> do
                _ <- pure $ enableMyLocation true
                _ <- removeMarker (getCurrentLocationMarker (getValueToLocalStore VERSION_NAME))
                _ <- storeCallBackLocateOnMap push UpdatePickupLocation
                pure unit
              TryAgain -> do
                _ <- launchAff $ flowRunner defaultGlobalState $ getEstimate EstimatesTryAgain CheckFlowStatusAction 10 1000.0 push initialState
                pure unit
              FindEstimateAndSearch -> do
                push $ SearchForSelectedLocation
                pure unit
              _ -> pure unit
            if ((initialState.props.sourceLat /= (-0.1)) && (initialState.props.sourceLong /= (-0.1))) then do
              case initialState.props.sourceLat, initialState.props.sourceLong of
                0.0, 0.0 -> do
                  if (initialState.props.currentStage == HomeScreen) then do
                    _ <- getCurrentPosition push CurrentLocation
                    pure (pure unit)
                  else do
                    getCurrentCustomerLocation push initialState
                _, _ ->
                  if (initialState.props.currentStage == HomeScreen) then do
                    pure (pure unit)
                  else do
                    let src = initialState.data.source
                    if src == "" || src == "Current Location" then do
                        if (checkCurrentLocation initialState.props.sourceLat initialState.props.sourceLong initialState.data.previousCurrentLocations.pastCurrentLocations  && initialState.props.storeCurrentLocs )|| checkSavedLocations initialState.props.sourceLat initialState.props.sourceLong initialState.data.savedLocations
                          then push $ UpdateSourceFromPastLocations
                          else
                            pure unit
                        pure (pure unit)
                    else  pure (pure unit)
            else
              pure (pure unit)
        )
      ]
  , eval:
      \action state -> do
        let _ = spy "HomeScreen action " action
        let _ = spy "HomeScreen state " state
        eval action state
  }

getDelayForLocateOnMap :: Int
getDelayForLocateOnMap = 1000

enableCurrentLocation :: Boolean
enableCurrentLocation = true

disableCurrentLocation :: Boolean
disableCurrentLocation = false

isCurrentLocationEnabled :: Boolean
isCurrentLocationEnabled = if (isLocalStageOn HomeScreen) then enableCurrentLocation else disableCurrentLocation

view :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
view push state =
  -- screenAnimation $
  frameLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , onBackPressed push (const BackPressed)
    , clickable true
    , afterRender push (const AfterRender)
    ]
    [ linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        , clickable true
        , afterRender
            (  \action -> do
                _ <- push action
                _ <- showMap (getNewIDWithTag "CustomerHomeScreenMap") isCurrentLocationEnabled "satellite" (17.0) push MAPREADY
                if(state.props.openChatScreen == true && state.props.currentStage == RideAccepted) then push OpenChatScreen else pure unit
            )
            (const MapReadyAction)
        ]
        [ relativeLayout
            [ width MATCH_PARENT
            , weight 1.0
            , orientation VERTICAL
            , background "#FAFAFA"
            , height MATCH_PARENT
            ]
            [ frameLayout
                [ width MATCH_PARENT
                , height MATCH_PARENT
                , clickable true
                ]
                [ linearLayout
                    [ height if any (_ == state.props.currentStage) [RideAccepted, RideStarted, ChatWithDriver] && os /= "IOS" then (V (((screenHeight unit)/ 15)*10)) else MATCH_PARENT
                    , width MATCH_PARENT
                    , id (getNewIDWithTag "CustomerHomeScreenMap")
                    ]
                    []
                , linearLayout
                    [ width MATCH_PARENT
                    , height MATCH_PARENT
                    , background Color.transparent
                    , padding (PaddingBottom if os == "IOS" then 20 else 35)
                    , gravity CENTER
                    ]
                    [ imageView
                        [ width $ V 35
                        , height $ V 35
                        , imageWithFallback $ case (state.props.currentStage == ConfirmingLocation) || state.props.isSource == (Just true) of
                            true  ->  (if isPreviousVersion (getValueToLocalStore VERSION_NAME) (getPreviousVersion "") then "src_marker" else "ny_ic_src_marker") <> "," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_src_marker.png" 
                            false ->  (if isPreviousVersion (getValueToLocalStore VERSION_NAME) (getPreviousVersion "") then "dest_marker" else "ny_ic_dest_marker") <> "," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_dest_marker.png"
                        , visibility if ((state.props.currentStage == ConfirmingLocation) || state.props.locateOnMap) then VISIBLE else GONE
                        ]
                    ]
                ]
            , homeScreenView push state
            , buttonLayoutParentView push state
            , if (not state.props.rideRequestFlow) || (state.props.currentStage == FindingEstimate || state.props.currentStage == ConfirmingRide) then emptyTextView state else topLeftIconView state push
            , linearLayout
                [ width MATCH_PARENT
                , height MATCH_PARENT
                , background if (state.props.currentStage == RideCompleted || state.props.currentStage == RideRating) then Color.black9000 else Color.transparent
                ]
                []
            , rideRequestFlowView push state
            , if state.props.currentStage == PricingTutorial then (pricingTutorialView push state) else emptyTextView state
            , if state.props.currentStage == ChatWithDriver then (chatView push state) else emptyTextView state
            , rideTrackingView push state
            , if ((not state.props.ratingModal) && (state.props.showlocUnserviceablePopUp || (state.props.isMockLocation && (getMerchant FunctionCall == NAMMAYATRI))) && state.props.currentStage == HomeScreen) then (sourceUnserviceableView push state) else emptyTextView state
            , if state.data.settingSideBar.opened /= SettingSideBar.CLOSED then settingSideBarView push state else emptyTextView state
            , if (state.props.currentStage == SearchLocationModel || state.props.currentStage == FavouriteLocationModel) then searchLocationView push state else emptyTextView state
            , if (any (_ == state.props.currentStage) [ FindingQuotes, QuoteList ]) then (quoteListModelView push state) else emptyTextView state
            , if (state.props.isCancelRide) then (cancelRidePopUpView push state) else emptyTextView state
            , if (state.props.isPopUp /= NoPopUp) then (logOutPopUpView push state) else emptyTextView state
            , if (state.props.isLocationTracking) then (locationTrackingPopUp push state) else emptyTextView state
            , if (state.props.isEstimateChanged) then (estimateChangedPopUp push state) else emptyTextView state
            , if state.props.ratingModal then previousRideRatingView push state else emptyTextView state
            , if state.props.currentStage == DistanceOutsideLimits then (distanceOutsideLimitsView push state) else emptyTextView state
            , if state.props.currentStage == ShortDistance then (shortDistanceView push state) else emptyTextView state
            , if state.props.showRateCard then (rateCardView push state) else emptyTextView state
            , if state.props.currentStage == RideRating then rideRatingCardView state push else emptyTextView state
            , if state.props.isSaveFavourite then saveFavouriteCardView push state else emptyTextView state
            , if state.props.emergencyHelpModal then (emergencyHelpModal push state) else emptyTextView state
            , if state.props.showShareAppPopUp && ((getValueFromConfig "isShareAppEnabled") == "true") then (shareAppPopUp push state) else emptyTextView state
            , if state.props.showMultipleRideInfo then (requestInfoCardView push state) else emptyTextView state
            , if state.props.showLiveDashboard then showLiveStatsDashboard push state else emptyTextView state
            , if state.props.showCallPopUp then (driverCallPopUp push state) else emptyTextView state
            , if state.props.callSupportPopUp then callSupportPopUpView push state else emptyTextView state
            , if state.props.cancelSearchCallDriver then cancelSearchPopUp push state else emptyTextView state
            ]
        ]
    ]

callSupportPopUpView :: forall w . (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
callSupportPopUpView push state =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  ][PopUpModal.view (push <<< CallSupportAction) (callSupportConfig state)]

cancelSearchPopUp :: forall w . (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
cancelSearchPopUp push state =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  ][PopUpModal.view (push <<< CancelSearchAction) (cancelAppConfig state)]

chatView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
chatView push state =
  relativeLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , alignParentBottom "true,-1"
  , adjustViewWithKeyboard "true"
  , background Color.transparent
  ][ ChatView.view (push <<< ChatViewActionController) (chatViewConfig state) ]

showLiveStatsDashboard :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
showLiveStatsDashboard push state =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , background Color.grey800
  , afterRender
        ( \action -> do
            initialWebViewSetUp push (getNewIDWithTag "webview") HideLiveDashboard
            pure unit
        )
        (const NoAction)
  ] [ webView
      [ height MATCH_PARENT
      , width MATCH_PARENT
      , id (getNewIDWithTag "webview")
      , url if (isPreviousVersion (getValueToLocalStore VERSION_NAME) ("1.2.4")) then "https://nammayatri.in/open/" else "https://nammayatri.in/open?source=in-app"
      ]]

driverCallPopUp :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
driverCallPopUp push state =
  relativeLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background Color.black9000
    , alignParentBottom "true,-1"
    , onClick push (const $ CloseShowCallDialer)
    , disableClickFeedback true
    ]
    [ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , background Color.white900
        , orientation VERTICAL
        , cornerRadii $ Corners 24.0 true true false false
        , padding (Padding 20 32 20 25)
        , alignParentBottom "true,-1"
        , disableClickFeedback true
        ]
        [ textView
            $
              [ text (getString CALL_DRIVER_USING)
              , height WRAP_CONTENT
              , color Color.black700
              , textSize FontSize.a_18
              , margin (MarginBottom 4)
              ]
            <> FontStyle.subHeading2 TypoGraphy
        , linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , orientation VERTICAL
            ]
            ( map
                ( \item ->
                    linearLayout
                      [ height WRAP_CONTENT
                      , width MATCH_PARENT
                      , orientation VERTICAL
                      ]
                      [ trackingCardCallView push state item
                      , if(item.type == ANONYMOUS_CALLER) then linearLayout
                          [ height $ V 1
                          , width MATCH_PARENT
                          , background Color.grey900
                          ]
                          []
                        else linearLayout[][]
                      ]
                )
                (driverCallPopUpData state)
            )

        ]
    ]

driverCallPopUpData :: HomeScreenState -> Array { text :: String, imageWithFallback :: String, type :: CallType, data :: String }
driverCallPopUpData state =
  [ { text: (getString ANONYMOUS_CALL)
    , imageWithFallback: "ny_ic_anonymous_call,https://assets.juspay.in/beckn/nammayatri/user/images/ny_ic_anonymous_call.png"
    , type: ANONYMOUS_CALLER
    , data: (getString YOUR_NUMBER_WILL_NOT_BE_SHOWN_TO_THE_DRIVER_THE_CALL_WILL_BE_RECORDED_FOR_COMPLIANCE)
    }
  , { text: (getString DIRECT_CALL)
    , imageWithFallback: "ny_ic_direct_call,https://assets.juspay.in/beckn/nammayatri/user/images/ny_ic_direct_call.png"
    , type: DIRECT_CALLER
    , data: (getString YOUR_NUMBER_WILL_BE_VISIBLE_TO_THE_DRIVER_USE_IF_NOT_CALLING_FROM_REGISTERED_NUMBER)
    }
  ]

trackingCardCallView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> { text :: String, imageWithFallback :: String, type :: CallType, data :: String} -> PrestoDOM (Effect Unit) w
trackingCardCallView push state item =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation HORIZONTAL
    , padding (Padding 0 20 0 20)
    , gravity CENTER_VERTICAL
    , onClick push (const (ShowCallDialer item.type))
    ]
    [
    imageView
        [ imageWithFallback item.imageWithFallback
        , height $ V 30
        , width $ V 30
        , margin (MarginRight 20)
        ]
    ,  linearLayout[
        height WRAP_CONTENT
      , weight 1.0
      , orientation VERTICAL]
    [
      linearLayout
      [
        height WRAP_CONTENT
      , width WRAP_CONTENT
      , gravity CENTER
      , orientation HORIZONTAL
      , margin (MarginBottom 2)
      ][
        textView
        $
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , textSize FontSize.a_16
          , text item.text
          , gravity CENTER_VERTICAL
          , color Color.black800
          ]
        , if(item.type == ANONYMOUS_CALLER) then labelView push state else linearLayout[][]
      ]
      , textView
        $
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , text item.data
          , color Color.black600
          ]
    ]
    , imageView
        [ imageWithFallback $ "ny_ic_chevron_right," <> (getAssetStoreLink FunctionCall) <> "ny_ic_chevron_right.png"
        , height $ V 30
        , width $ V 32
        , padding (Padding 3 3 3 3)
        ]
    ]

labelView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
labelView push state =
  linearLayout[
    height WRAP_CONTENT
  , width WRAP_CONTENT
  , cornerRadii $ Corners 8.0 true true true true
  , background Color.green900
  , margin (MarginHorizontal 10 10)
  ][
    textView $ [
      width WRAP_CONTENT
    , height WRAP_CONTENT
    , color Color.white900
    , gravity CENTER
    , padding (Padding 8 1 8 1)
    , textSize FontSize.a_13
    , text (getString RECOMMENDED)
    ]
  ]

searchLocationView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
searchLocationView push state =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , background if state.props.currentStage == SearchLocationModel && state.props.isSearchLocation == LocateOnMap then Color.transparent else Color.grey800
  ] [ if state.props.currentStage == SearchLocationModel then (searchLocationModelView push state) else emptyTextView state
    , if state.props.currentStage == FavouriteLocationModel then (favouriteLocationModel push state) else emptyTextView state
]

shareAppPopUp :: forall w . (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
shareAppPopUp push state =
  linearLayout
  [ height MATCH_PARENT
  , width MATCH_PARENT
  , background Color.blackLessTrans
  ][PopUpModal.view (push <<< PopUpModalShareAppAction) (shareAppConfig state )]



buttonLayoutParentView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
buttonLayoutParentView push state =
  linearLayout
  [ height WRAP_CONTENT
  , width MATCH_PARENT
  , alignParentBottom "true,-1"
  , orientation VERTICAL
  ][ if (state.props.currentStage == HomeScreen && (not state.props.rideRequestFlow) && (not state.props.showlocUnserviceablePopUp)) then buttonLayout state push else emptyTextView state]

recenterButtonView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
recenterButtonView push state =
  (if os == "IOS" then PrestoAnim.animationSet [] else PrestoAnim.animationSet [ translateYAnimFromTop $ translateYAnimHomeConfig BOTTOM_TOP ])
    $ linearLayout
        [ width MATCH_PARENT
        , height WRAP_CONTENT
        , background Color.transparent
        , visibility if state.props.rideRequestFlow && state.props.currentStage /= ConfirmingLocation then GONE else VISIBLE
        , gravity RIGHT
        , alignParentBottom "true,-1"
        , padding $ Padding 0 0 16 14
        , disableClickFeedback true
        , margin if ((state.props.showlocUnserviceablePopUp) && state.props.currentStage == HomeScreen) then (MarginBottom (360 + safeMarginBottom)) else (Margin 0 0 0 0) --else if (state.props.currentStage == ConfirmingLocation) then (Margin ((screenWidth unit) - 66) 0 0 270) else(Margin ((screenWidth unit) - 66) 0 0 120)
        ]
        [ -- linearLayout
          --   [ width WRAP_CONTENT
          --   , height WRAP_CONTENT
          --   , stroke ("1," <> Color.grey900)
          --   , cornerRadii $ Corners 24.0 true true true true
          --   ][
          imageView
            [ imageWithFallback $ "ny_ic_recenter_btn," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_recenter_btn.png"
            , onClick
                ( \action -> do
                    _ <- push action
                    _ <- getCurrentPosition push UpdateCurrentLocation
                    _ <- pure $ logEvent state.data.logField "ny_user_recenter_btn_click"
                    pure unit
                )
                (const $ RecenterCurrentLocation)
            , height $ V 40
            , width $ V 40
            ]
        ]
-- ]

referralView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
referralView push state =
  linearLayout
    [ width WRAP_CONTENT
    , height WRAP_CONTENT
    , visibility if (getValueFromConfig "isReferralEnabled") == "false" || ((state.props.isReferred && state.props.currentStage == RideStarted) || state.props.hasTakenRide) then GONE else VISIBLE
    , stroke $ "1," <> if not state.props.isReferred then Color.blue900 else Color.black700
    , margin (MarginHorizontal 16 13)
    , cornerRadius 20.0
    , background Color.white900
    , gravity RIGHT
    , padding (Padding 16 12 16 12)
    , onClick push $ const $ if state.props.isReferred then ReferralFlowNoAction else ReferralFlowAction
    ][
      imageView [
         imageWithFallback $ "ny_ic_tick," <> (getAssetStoreLink FunctionCall) <> "ny_ic_tick.png"
        , width $ V 20
        , height $ V 15
        , margin (Margin 0 3 5 0)
        , visibility if state.props.isReferred then VISIBLE else GONE
      ]
      , textView $ [
        width WRAP_CONTENT
      , height WRAP_CONTENT
      , color if not state.props.isReferred then Color.blue900 else Color.black700
      , text if not state.props.isReferred then (getString HAVE_REFERRAL_CODE) else (getString REFERRAL_CODE_APPLIED)
      ] <> FontStyle.tags TypoGraphy
    ]

liveStatsDashboardView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
liveStatsDashboardView push state =
  linearLayout
    [ width WRAP_CONTENT
    , height WRAP_CONTENT
    , visibility if (state.props.isReferred || state.props.hasTakenRide) && state.props.currentStage == RideStarted then VISIBLE else GONE
    , stroke $ "1," <> Color.blue900
    , margin (MarginHorizontal 16 13)
    , cornerRadius 20.0
    , background Color.white900
    , gravity RIGHT
    , padding (Padding 16 12 16 12)
    , onClick push $ const $ LiveDashboardAction
    ][
      imageView [
        imageWithFallback $ "ic_graph_blue," <> (getAssetStoreLink FunctionCall) <> "ic_graph_blue.png"
        , width $ V 20
        , height $ V 15
        , margin (Margin 0 0 5 0)
      ]
      , textView $ [
        width WRAP_CONTENT
      , height WRAP_CONTENT
      , color Color.blue900
      , text (getString CHECK_OUT_LIVE_STATS)
      ] <> FontStyle.tags TypoGraphy
    ]

sourceUnserviceableView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
sourceUnserviceableView push state =
  PrestoAnim.animationSet [ fadeIn true ]
    $ relativeLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , orientation VERTICAL
        , alignParentBottom "true,-1"
        , gravity BOTTOM
        ]
        [ recenterButtonView push state
        , ErrorModal.view (push <<< SourceUnserviceableActionController) (sourceUnserviceableConfig state)
        ]

rateCardView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
rateCardView push state =
  PrestoAnim.animationSet [ fadeIn true ]
    $ linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ RateCard.view (push <<< RateCardAction) (rateCardConfig state) ]

requestInfoCardView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
requestInfoCardView push state =
  PrestoAnim.animationSet [ fadeIn true ]
    $ linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        ]
        [ RequestInfoCard.view (push <<< RequestInfoCardAction) state ]

buttonLayout :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
buttonLayout state push =
  PrestoAnim.animationSet (buttonLayoutAnimation state)
    $ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , alignParentBottom "true,-1"
        , orientation VERTICAL
        ]
        [
          linearLayout
          [ width MATCH_PARENT
          , height WRAP_CONTENT
          , orientation HORIZONTAL
          ][
            referralView push state
          , recenterButtonView push state
          ]
        , linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , background if (((state.data.savedLocations == []) && state.data.recentSearchs.predictionArray == []) || state.props.isSearchLocation == LocateOnMap) then Color.transparent else Color.white900
            , gradient if os == "IOS" then (Linear 90.0 ["#FFFFFF" , "#FFFFFF" , "#FFFFFF", Color.transparent]) else (Linear 0.0 ["#FFFFFF" , "#FFFFFF" , "#FFFFFF", Color.transparent])
            , orientation VERTICAL
            , padding (PaddingTop 16)
            ]
            [ PrimaryButton.view (push <<< PrimaryButtonActionController) (whereToButtonConfig state)
            , if (((state.data.savedLocations == []) && state.data.recentSearchs.predictionArray == [] && state.props.isBanner == false) || state.props.isSearchLocation == LocateOnMap) then emptyLayout state else recentSearchesAndFavourites state push
            ]
        ]

recentSearchesAndFavourites :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
recentSearchesAndFavourites state push =
  linearLayout
  [ width MATCH_PARENT
  , height WRAP_CONTENT
  , orientation VERTICAL
  , padding $ Padding 16 0 16 (16+safeMarginBottom)
  , cornerRadii $ Corners (4.0) true true false false
  ]([ savedLocationsView state push
   , recentSearchesView state push]
   <> if(state.props.isBanner) then [genderBannerView state push] else [])


genderBannerView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
genderBannerView state push =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , margin (Margin 10 10 10 10)
    , gravity BOTTOM
    ][
        genderBanner push state
    ]


savedLocationsView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
savedLocationsView state push =
  linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    ]
    [ linearLayout
        [ width MATCH_PARENT
        , height WRAP_CONTENT
        , margin $ MarginTop 16
        , visibility if (state.data.savedLocations /= []) then VISIBLE else GONE
        ]
        [ LocationTagBar.view (push <<< SavedAddressClicked) { savedLocations: state.data.savedLocations } ]
    ]

recentSearchesView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
recentSearchesView state push =
  linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    , orientation VERTICAL
    , margin $ MarginTop 16
    , visibility if state.data.recentSearchs.predictionArray == [] then GONE else VISIBLE
    ]
    [ linearLayout
        [ height MATCH_PARENT
        , width MATCH_PARENT
        , cornerRadius 8.0
        , stroke $ "1," <> Color.grey900
        , orientation VERTICAL
        ]
        ( mapWithIndex
            ( \index item ->
                linearLayout
                  [ width MATCH_PARENT
                  , height WRAP_CONTENT
                  , orientation VERTICAL
                  , visibility if (state.props.isBanner && index >0) then GONE else VISIBLE
                  ]
                  [ LocationListItem.view (push <<< PredictionClickedAction) item
                  , linearLayout
                      [ height $ V 1
                      , width MATCH_PARENT
                      , background Color.lightGreyShade
                      , visibility if (index == (length state.data.recentSearchs.predictionArray) - 1) || (state.props.isBanner) then GONE else VISIBLE
                      ]
                      []
                  ]
            )
            state.data.recentSearchs.predictionArray
        )
    ]

buttonLayoutAnimation :: HomeScreenState -> Array PrestoAnim.Animation
buttonLayoutAnimation state = if os == "IOS" then [ fadeIn true ] else [ translateYAnimFromTop $ translateYAnimHomeConfig BOTTOM_TOP, fadeOut (state.props.showlocUnserviceablePopUp) ]

------------- settingSideBarView ------------
settingSideBarView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
settingSideBarView push state =
  linearLayout
    [ weight 1.0
    , height MATCH_PARENT
    , width MATCH_PARENT
    ]
    [ SettingSideBar.view (push <<< SettingSideBarActionController) (state.data.settingSideBar{appConfig = state.data.config}) ]

------------------------------- homeScreenView --------------------------
homeScreenView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
homeScreenView push state =
  PrestoAnim.animationSet
    [ fadeOut (state.props.currentStage == SearchLocationModel)
    ]
    $ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , padding (Padding 0 safeMarginTop 0 safeMarginBottom)
        , orientation VERTICAL
        ]
        [ if (not state.props.rideRequestFlow) then homeScreenTopIconView push state else emptyTextView state ]

homeScreenTopIconView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
homeScreenTopIconView push state =
  homeScreenAnimation TOP_BOTTOM
    $
     -- 1000 (-100) 0 0 true $ PrestoAnim.Bezier 0.37 0.0 0.63 1.0] $ 
     linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , orientation VERTICAL
        ]
        [ linearLayout
            [ width MATCH_PARENT
            , height WRAP_CONTENT
            , background Color.white900
            , orientation HORIZONTAL
            , gravity LEFT
            , visibility if state.data.config.terminateBtnConfig.visibility then VISIBLE else GONE
            ]
            [ linearLayout
                [ width WRAP_CONTENT
                , height WRAP_CONTENT
                , margin $ MarginLeft 16
                , padding $ Padding 6 6 6 6
                , gravity CENTER_VERTICAL
                , onClick push (const TerminateApp)
                ]
                [ imageView
                    [ imageWithFallback state.data.config.terminateBtnConfig.imageUrl
                    , height $ V 20
                    , width $ V 20
                    , margin $ MarginRight 10
                    ]
                , textView
                    $ [ width WRAP_CONTENT
                      , height WRAP_CONTENT
                      , gravity CENTER_VERTICAL
                      , text state.data.config.terminateBtnConfig.title
                      , color Color.black900
                      ]
                    <> FontStyle.tags TypoGraphy
                ]
            ]
        , linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , orientation HORIZONTAL
            , cornerRadius 8.0
            , background Color.white900
            , visibility if state.props.rideRequestFlow then GONE else VISIBLE
            , stroke $ "1," <> Color.grey900
            , gravity CENTER_VERTICAL
            , margin (Margin 16 26 16 0)
            , padding (Padding 0 16 16 16)
            ]
            [ linearLayout
                [ width WRAP_CONTENT -- $ V 54
                , height MATCH_PARENT
                , gravity CENTER
                , disableClickFeedback true
                , clickable if state.props.currentStage == SearchLocationModel then false else true
                , onClick push $ const OpenSettings
                ]
                [ imageView
                    [ imageWithFallback if ((getValueFromConfig "showDashboard") == "true") && (checkVersion "LazyCheck") then "ic_menu_notify," <> (getAssetStoreLink FunctionCall) <> "ic_menu_notify.png" else "ny_ic_hamburger," <> (getAssetStoreLink FunctionCall) <> "ny_ic_hamburger.png"
                    , height $ V 24
                    , width $ V 24
                    , margin (Margin 16 16 16 16)
                    ]
                ]
            , linearLayout
                [ height $ V 42
                , width $ V 1
                , background Color.grey900
                ]
                []
            , imageView
                [ imageWithFallback $ "ny_ic_source_dot," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_source_dot.png"
                , height $ V 20
                , width $ V 20
                , margin (Margin 5 5 5 5)
                , onClick push (const $ OpenSearchLocation)
                , gravity BOTTOM
                ]
            , linearLayout
                [ orientation VERTICAL
                , width MATCH_PARENT
                , height WRAP_CONTENT
                , disableClickFeedback true
                , onClick push (const $ OpenSearchLocation)
                ]
                [ textView
                    $ [ height WRAP_CONTENT
                      , width MATCH_PARENT
                      , text (getString PICK_UP_LOCATION)
                      , color Color.black800
                      , gravity LEFT
                      , lineHeight "16"
                      ]
                    <> FontStyle.body3 LanguageStyle
                , textView
                    $ [ height WRAP_CONTENT
                      , width MATCH_PARENT
                      , text if state.data.source /= "" then state.data.source else (getString CURRENT_LOCATION)
                      , maxLines 1
                      , ellipsize true
                      , color Color.black800
                      , gravity LEFT
                      , lineHeight "23"
                      ]
                    <> FontStyle.body7 LanguageStyle
                ]
            ]
        ]
  where
  homeScreenAnimation direction = PrestoAnim.animationSet [ translateYAnimFromTop $ translateYAnimHomeConfig direction ]

checkVersion :: String -> Boolean
checkVersion str = getValueToLocalStore LIVE_DASHBOARD /= "LIVE_DASHBOARD_SELECTED" && not (isPreviousVersion (getValueToLocalStore VERSION_NAME) (if os == "IOS" then "1.2.5" else "1.2.1"))

------------------------------- rideRequestFlowView --------------------------
rideRequestFlowView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
rideRequestFlowView push state =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , cornerRadii $ Corners 24.0 true true false false
    , visibility if (any (_ == state.props.currentStage) [ SettingPrice, ConfirmingLocation, RideCompleted, FindingEstimate, ConfirmingRide, FindingQuotes, TryAgain ]) then VISIBLE else GONE
    , alignParentBottom "true,-1"
    ]
    [ -- TODO Add Animations
      -- PrestoAnim.animationSet
      -- [ translateYAnim (300) 0 state.props.rideRequestFlow
      -- , translateYAnim 0 (300) (not state.props.rideRequestFlow)
      -- ] $
      relativeLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , cornerRadii $ Corners 24.0 true true false false
        , background Color.transparent
        ]
        [ PrestoAnim.animationSet [ fadeIn true ]
            $ if (state.props.currentStage == SettingPrice) then
                if (state.props.isSpecialZone ||  any (_ == getMerchant FunctionCall) [YATRI,JATRISAATHI]) then 
                  ChooseYourRide.view (push <<< ChooseYourRideAction) (chooseYourRideConfig state)
                else
                suggestedPriceView push state
              else if (state.props.currentStage == ConfirmingLocation) then
                confirmPickUpLocationView push state
              else
                emptyTextView state
        , if (any (_ == state.props.currentStage) [ FindingEstimate, ConfirmingRide, TryAgain, FindingQuotes]) then
            (loaderView push state)
          else
            emptyTextView state
        , rideCompletedCardView state push
        ]
    ]

-------------- rideRatingCardView -------------
rideRatingCardView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
rideRatingCardView state push =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    , background Color.transparent
    ]
    [ RatingCard.view (push <<< RatingCardAC) $ ratingCardViewState state
    ]

-------------- rideCompletedCardView -------------
rideCompletedCardView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
rideCompletedCardView state push =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , padding (Padding 16 16 16 16)
    , stroke ("1," <> Color.grey900)
    , background Color.white900
    , cornerRadii $ Corners 24.0 true true false false
    , visibility if state.props.currentStage == RideCompleted then VISIBLE else GONE
    ]
    [ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , orientation VERTICAL
        , gravity CENTER
        ]
        [ linearLayout
            [ width WRAP_CONTENT
            , height WRAP_CONTENT
            , background Color.transparentBlue
            , cornerRadius $ if os == "IOS" then 25.0 else 60.0
            , orientation HORIZONTAL
            , gravity CENTER
            , padding (Padding 14 14 14 14)
            , visibility if state.props.zoneType.priorityTag == METRO then VISIBLE else GONE
            ][ imageView
                [ width (V 20)
                , height (V 20)
                , imageWithFallback "ny_ic_metro_blue,https://assets.juspay.in/nammayatri/images/common/ny_ic_metro_blue.png"
                , margin (MarginRight 5)
                ]
              , textView
                [ width WRAP_CONTENT
                , height WRAP_CONTENT
                , text (getString METRO_RIDE)
                , fontStyle $ FontStyle.semiBold LanguageStyle
                , color Color.blue900
                , textSize FontSize.a_14
                ]
              ]
        , linearLayout
            [ width WRAP_CONTENT
            , height MATCH_PARENT
            , gravity CENTER
            ]
            [ textView $
                [ text $ state.data.config.currency <> show state.data.finalAmount
                , color Color.black800
                , width WRAP_CONTENT
                , height WRAP_CONTENT
                ] <> FontStyle.priceFont LanguageStyle
            , textView $ 
                [ textFromHtml $ "<strike>" <> state.data.config.currency <> " " <> (show state.data.driverInfoCardState.price) <> "</strike>"
                , margin $ Margin 8 5 0 0
                , width WRAP_CONTENT
                , height WRAP_CONTENT
                , lineHeight "40"
                , color Color.black600
                , visibility if state.data.finalAmount /= state.data.driverInfoCardState.price then VISIBLE else GONE
                ] <> FontStyle.h0 LanguageStyle
            ]
        , textView $
            [ text $ getString PAY_DRIVER_USING_CASH_OR_UPI_
            , lineHeight "20"
            , width MATCH_PARENT
            , gravity CENTER_HORIZONTAL
            , color Color.black800
            , margin $ MarginVertical 4 24
            ] <> FontStyle.subHeading2 LanguageStyle
        ]
    , fareUpdatedView state push
    , linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , stroke ("1," <> Color.grey900)
        , clickable true
        , cornerRadius 8.0
        , padding (Padding 16 24 16 24)
        , margin (MarginBottom 24)
        ]
        [ FareBreakUp.view (push <<< FareBreakUpActionController) (fareBreakUpConfig state) ]
    , linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , orientation HORIZONTAL
        , gravity CENTER_VERTICAL
        ]
        [ PrimaryButton.view (push <<< SkipButtonActionController) (skipButtonConfig state)
        , PrimaryButton.view (push <<< RateRideButtonActionController) (rateRideButtonConfig state)
        ]
    ]

fareUpdatedView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
fareUpdatedView state push =
  linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    , cornerRadius 8.0
    , stroke $ "1," <> Color.grey900
    , padding $ Padding 16 12 16 12
    , margin $ MarginBottom 20
    , gravity CENTER_VERTICAL
    , visibility if (state.data.finalAmount /= state.data.driverInfoCardState.price && state.props.estimatedDistance /= Nothing) then VISIBLE else GONE
    ]
    [ imageView
        [ width $ V 16
        , height $ V 16
        , imageWithFallback $ "ny_ic_parallel_arrows," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_parallel_arrows.png"
        , margin $ MarginRight 12
        ]
    , textView
        $ ( [ height MATCH_PARENT
            , width WRAP_CONTENT
            , gravity CENTER_VERTICAL
            , text $ FareBreakUp.getFareUpdatedString state.data.previousRideRatingState.distanceDifference
            , color Color.black700
            ]
          )
        <> FontStyle.body3 TypoGraphy
    ]

----------- topLeftIconView -------------
topLeftIconView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
topLeftIconView state push =
  linearLayout
      [ width MATCH_PARENT
      , height WRAP_CONTENT
      , orientation HORIZONTAL
      , visibility if state.data.config.showHamMenu then VISIBLE else GONE
      , margin (Margin 16 48 0 0)
      ][
        linearLayout
          [ height $ V 48
          , width $ V 48
          , stroke ("1," <> Color.grey900)
          , background Color.white900
          , gravity CENTER
          , cornerRadius 24.0
          , visibility if (any (_ == state.props.currentStage) [ FindingEstimate, ConfirmingRide, FindingQuotes, TryAgain ]) then GONE else VISIBLE
          , clickable true
          , onClick push $ if (any (_ == state.props.currentStage) [ SettingPrice, ConfirmingLocation, PricingTutorial, DistanceOutsideLimits ]) then const BackPressed else const OpenSettings
          ]
          [ imageView
              [ imageWithFallback if (any (_ == state.props.currentStage) [ SettingPrice, ConfirmingLocation, PricingTutorial, DistanceOutsideLimits ]) then "ny_ic_chevron_left," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_chevron_left.png" else if ((getValueFromConfig "showDashboard") == "true") && (checkVersion "LazyCheck") then "ic_menu_notify," <> (getAssetStoreLink FunctionCall) <> "ic_menu_notify.png" else "ny_ic_hamburger," <> (getAssetStoreLink FunctionCall) <> "ny_ic_hamburger.png"
              , height $ V 25
              , clickable true
              , onClick push $ if (any (_ == state.props.currentStage) [ SettingPrice, ConfirmingLocation, PricingTutorial, DistanceOutsideLimits ]) then const BackPressed else const OpenSettings
              , width $ V 25
              ]
          ]
        , linearLayout
          [ height WRAP_CONTENT
          , weight 1.0
          ][]
        , referralView push state
        , if ((getValueFromConfig "showDashboard") == "false") || (isPreviousVersion (getValueToLocalStore VERSION_NAME) (if os == "IOS" then "1.2.5" else "1.2.1")) then emptyTextView state else liveStatsDashboardView push state
      ]

----------- suggestedPriceView -------------
suggestedPriceView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
suggestedPriceView push state =
  linearLayout
  [ orientation VERTICAL
  , height WRAP_CONTENT
  , width MATCH_PARENT
  , background Color.blue800
  , clickable true
  , visibility if (state.props.currentStage == SettingPrice) then VISIBLE else GONE
  , stroke ("1," <> Color.grey900)
  , gravity CENTER
  , cornerRadii $ Corners 24.0 true true false false
  ][  linearLayout
      [ width MATCH_PARENT
      , height WRAP_CONTENT
      , orientation HORIZONTAL
      , gravity CENTER
      , padding (PaddingVertical 4 4)
      , visibility if state.props.zoneType.priorityTag == METRO then VISIBLE else GONE
      ] [ imageView
          [ width (V 15)
          , height (V 15)
          , margin (MarginRight 6)
          , imageWithFallback "ny_ic_metro_white,https://assets.juspay.in/nammayatri/images/common/ny_ic_metro_white.png"
          ]
        , textView
          [ width WRAP_CONTENT
          , height WRAP_CONTENT
          , textSize FontSize.a_14
          , text (getString METRO_RIDE)
          , color Color.white900
          ]
        ]
    , linearLayout
      [ orientation VERTICAL
      , height WRAP_CONTENT
      , width MATCH_PARENT
      , background Color.white900
      , clickable true
      , visibility if (state.props.currentStage == SettingPrice) then VISIBLE else GONE
      , padding (Padding 16 16 16 24)
      , stroke ("1," <> Color.grey900)
      , gravity CENTER
      , cornerRadii $ Corners 24.0 true true false false
      ][  textView
          [ text $ getString REQUEST_AUTO_RIDE
          , textSize FontSize.a_22
          , color Color.black800
          , gravity CENTER_HORIZONTAL
          , height WRAP_CONTENT
          , width MATCH_PARENT
          , fontStyle $ FontStyle.bold LanguageStyle
          ]
        , linearLayout
          [ width MATCH_PARENT
          , height WRAP_CONTENT
          , orientation VERTICAL
          , stroke $ "1," <> Color.grey900
          , gravity CENTER
          , cornerRadius 8.0
          , margin $ MarginTop 16
          , padding $ PaddingVertical 2 10
          ][linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation HORIZONTAL
            , margin (MarginLeft 15)]
            [ linearLayout
            [ height WRAP_CONTENT
            , width WRAP_CONTENT
            , orientation VERTICAL
            , gravity CENTER
            , margin $ MarginTop if os == "IOS" then 10 else 0
            ][  textView
                [ text $ if state.data.rateCard.additionalFare == 0 then state.data.config.currency <> (show state.data.suggestedAmount) else  state.data.config.currency <> (show state.data.suggestedAmount) <> "-" <> state.data.config.currency <> (show $ (state.data.suggestedAmount + state.data.rateCard.additionalFare))
                , textSize FontSize.a_32
                , color Color.black800
                , margin $ MarginTop 8
                , gravity CENTER_HORIZONTAL
                , width WRAP_CONTENT
                , height WRAP_CONTENT
                , fontStyle $ FontStyle.bold LanguageStyle
                , onClick (\action -> if (getValueFromConfig "showRateCard") == "true" then push action else pure unit ) $ const ShowRateCard
                ]
                , estimatedTimeAndDistanceView push state
              ]
              , imageView
                [ imageWithFallback "ny_ic_info_blue,https://assets.juspay.in/nammayatri/images/common/ny_ic_info_blue.png"
                , width $ V 40
                , height $ V 40
                , gravity BOTTOM
                , margin (MarginTop 13)
                , visibility if (getValueFromConfig "showRateCard") == "true" then VISIBLE else GONE
                , onClick (\action -> if (getValueFromConfig "showRateCard") == "true" then push action else pure unit ) $ const ShowRateCard
                ]
            ]
            , linearLayout
              [ width MATCH_PARENT
              , height WRAP_CONTENT
              , orientation VERTICAL
              , visibility if (getValueFromConfig "showBookingPreference") == "true" then VISIBLE else GONE
              ]
              [ linearLayout
                  [ width MATCH_PARENT
                  , height $ V 1
                  , margin $ Margin 16 12 16 14
                  , background Color.grey900
                  ][]
              , linearLayout
                  [ width MATCH_PARENT
                  , height WRAP_CONTENT
                  , orientation VERTICAL
                  ]
                  [ linearLayout
                      [ width MATCH_PARENT
                      , height WRAP_CONTENT
                      , gravity CENTER_HORIZONTAL
                      , onClick push $ const PreferencesDropDown
                      , margin (MarginBottom 8)
                      ][
                          textView
                          [ height $ V 24
                          , width WRAP_CONTENT
                          , color Color.darkDescriptionText
                          , text $ getString BOOKING_PREFERENCE
                          , textSize FontSize.a_16
                          , fontStyle $ FontStyle.regular LanguageStyle

                          ],
                          imageView
                          [ width $ V 10
                          , height $ V 10
                          , margin (Margin 9 8 0 0)
                          , imageWithFallback if state.data.showPreferences then "ny_ic_chevron_up,https://assets.juspay.in/nammayatri/images/common/ny_ic_chevron_up.png" else "ny_ic_chevron_down,https://assets.juspay.in/nammayatri/images/user/ny_ic_down_arrow.png"
                          ]
                      ],
                      linearLayout
                        [ width MATCH_PARENT
                        , height WRAP_CONTENT
                        , margin $ MarginLeft 20
                        , orientation VERTICAL
                        ][ linearLayout
                          [ width MATCH_PARENT
                          , height WRAP_CONTENT
                          , orientation VERTICAL
                          , visibility if state.data.showPreferences then VISIBLE else GONE
                          ][ showMenuButtonView push (getString AUTO_ASSIGN_DRIVER) "ny_ic_faster,https://assets.juspay.in/nammayatri/images/user/ny_ic_faster.png" true state,
                            showMenuButtonView push (getString CHOOSE_BETWEEN_MULTIPLE_DRIVERS) "ny_ic_info,https://assets.juspay.in/nammayatri/images/user/ny_ic_information_grey.png" false state]
                      ]

                  ]
              ]
          ]
        , PrimaryButton.view (push <<< PrimaryButtonActionController) (primaryButtonRequestRideConfig state)
      ]
  ]


showMenuButtonView :: forall w. (Action -> Effect Unit) -> String -> String -> Boolean -> HomeScreenState -> PrestoDOM (Effect Unit) w
showMenuButtonView push menuText menuImage autoAssign state =
  linearLayout
  [ width WRAP_CONTENT
  , height WRAP_CONTENT
  , gravity CENTER
  , margin $ (Margin 0 10 0 10)
  ][ linearLayout
      [ height $ V 20
      , width $ V 20
      , stroke if ( (flowWithoutOffers WithoutOffers) && autoAssign || not (flowWithoutOffers WithoutOffers) && not autoAssign ) then ("2," <> state.data.config.primaryBackground) else ("2," <> Color.black600)
      , cornerRadius 10.0
      , gravity CENTER
      , onClick push (const $ CheckBoxClick autoAssign)
      ][  linearLayout
          [ width $ V 10
          , height $ V 10
          , cornerRadius 5.0
          , background $ state.data.config.primaryBackground
          , visibility if ( (flowWithoutOffers WithoutOffers) && autoAssign || not (flowWithoutOffers WithoutOffers) && not autoAssign ) then VISIBLE else GONE
          ][]
        ]
    , textView $
      [ text menuText
      , width MATCH_PARENT
      , gravity CENTER
      , color Color.black700
      , height WRAP_CONTENT
      , margin (MarginHorizontal 10 10)
      , onClick push (const $ CheckBoxClick autoAssign)
      ] <> FontStyle.paragraphText LanguageStyle
    , imageView
      [ height $ if autoAssign then V 30 else V 25
      , width $ if autoAssign then V 75 else V 25
      , imageWithFallback menuImage
      , margin $ (MarginHorizontal 5 5)
      , onClick push (const $ OnIconClick autoAssign)
      ]
  ]

estimatedTimeAndDistanceView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
estimatedTimeAndDistanceView push state =
  linearLayout
  [ width WRAP_CONTENT
  , height WRAP_CONTENT
  , gravity CENTER
  , margin $ MarginTop 4
  ][ textView $
      [ text state.data.rideDistance
      , width MATCH_PARENT
      , gravity CENTER
      , color Color.black650
      , height WRAP_CONTENT
      ] <> FontStyle.paragraphText LanguageStyle
    , linearLayout
      [height $ V 4
      , width $ V 4
      , cornerRadius 2.5
      , background Color.black600
      , margin (Margin 6 2 6 0)
      ][]
    , textView $
      [ text state.data.rideDuration
      , width MATCH_PARENT
      , gravity CENTER
      , color Color.black650
      , height WRAP_CONTENT
      ] <> FontStyle.paragraphText LanguageStyle
  ]

emergencyHelpModal :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
emergencyHelpModal push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , orientation VERTICAL
    ]
    [ EmergencyHelp.view (push <<< EmergencyHelpModalAC) $ emergencyHelpModelViewState state ]

locationTrackingPopUp :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
locationTrackingPopUp push state =
  relativeLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background Color.black9000
    , alignParentBottom "true,-1"
    , onClick push (const $ CloseLocationTracking)
    , disableClickFeedback true
    ]
    [ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , background Color.white900
        , orientation VERTICAL
        , cornerRadii $ Corners 24.0 true true false false
        , padding (Padding 20 32 20 25)
        , onClick push (const $ TrackLiveLocationAction)
        , alignParentBottom "true,-1"
        , disableClickFeedback true
        ]
        [ textView
            $
              [ text (getString TRACK_LIVE_LOCATION_USING)
              , height WRAP_CONTENT
              , color Color.black700
              ]
            <> FontStyle.subHeading2 TypoGraphy
        , linearLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            , orientation VERTICAL
            , padding (PaddingTop 32)
            ]
            ( mapWithIndex
                ( \idx item ->
                    linearLayout
                      [ height WRAP_CONTENT
                      , width MATCH_PARENT
                      , orientation VERTICAL
                      ]
                      [ trackingCardView push state item
                      , linearLayout
                          [ height $ V 1
                          , width MATCH_PARENT
                          , background Color.grey900
                          , visibility if (state.props.currentStage == RideAccepted && item.type == "GOOGLE_MAP") || (idx == (length (locationTrackingData "lazyCheck")) - 1) then GONE else VISIBLE
                          ]
                          []
                      ]
                )
                (locationTrackingData "LazyCheck")
            )
        ]
    ]

estimateChangedPopUp :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
estimateChangedPopUp push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    ]
    [ PopUpModal.view (push <<< EstimateChangedPopUpController) (estimateChangedPopupConfig state) ]

trackingCardView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> { text :: String, imageWithFallback :: String, type :: String } -> PrestoDOM (Effect Unit) w
trackingCardView push state item =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation HORIZONTAL
    , padding (Padding 0 20 0 20)
    , onClick push (const (StartLocationTracking item.type))
    , visibility if (state.props.currentStage == RideAccepted && item.type == "GOOGLE_MAP") then GONE else VISIBLE
    ]
    [ imageView
        [ imageWithFallback item.imageWithFallback
        , height $ V 25
        , width $ V 25
        , margin (MarginRight 20)
        ]
    , textView
        $
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , text item.text
          , gravity CENTER_VERTICAL
          , color Color.black800
          ]
        <> if state.props.isInApp && item.type == "IN_APP" then FontStyle.subHeading1 TypoGraphy else FontStyle.subHeading2 TypoGraphy
    , linearLayout
        [ height WRAP_CONTENT
        , weight 1.0
        ]
        []
    , imageView
        [ imageWithFallback $ "ny_ic_chevron_right," <> (getAssetStoreLink FunctionCall) <> "ny_ic_chevron_right.png"
        , height $ V 20
        , width $ V 22
        , padding (Padding 3 3 3 3)
        ]
    ]

locationTrackingData :: String -> Array { text :: String, imageWithFallback :: String, type :: String }
locationTrackingData lazyCheck =
  [ { text: (getString GOOGLE_MAP_)
    , imageWithFallback: "ny_ic_track_google_map," <> (getAssetStoreLink FunctionCall) <> "ny_ic_track_google_map.png"
    , type: "GOOGLE_MAP"
    }
  , { text: (getString IN_APP_TRACKING)
    , imageWithFallback: "ny_ic_track_in_app," <> (getAssetStoreLink FunctionCall) <> "ny_ic_track_in_app.png"
    , type: "IN_APP"
    }
  ]

----------- confirmPickUpLocationView -------------
confirmPickUpLocationView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
confirmPickUpLocationView push state =
  linearLayout
    [ orientation VERTICAL
    , height WRAP_CONTENT
    , width MATCH_PARENT
    , clickable true
    , background Color.transparent
    , visibility if state.props.currentStage == ConfirmingLocation then VISIBLE else GONE
    , padding $ PaddingTop 16
    , cornerRadii $ Corners 24.0 true true false false
    , gravity CENTER
    ]
    [ recenterButtonView push state
    , linearLayout
        [ width MATCH_PARENT
        , height WRAP_CONTENT
        , orientation VERTICAL
        , background Color.white900
        , stroke $ "1," <> Color.grey900
        , cornerRadii $ Corners 24.0 true true false false
        , padding $ Padding 16 16 16 24
        ]
        [ textView $
            [ text (getString CONFIRM_PICKUP_LOCATION)
            , color Color.black800
            , gravity CENTER_HORIZONTAL
            , height WRAP_CONTENT
            , width MATCH_PARENT
            , cornerRadius state.data.config.primaryButtonCornerRadius
            ] <> FontStyle.h1 TypoGraphy
        , if  ((getMerchant FunctionCall == JATRISAATHI) && state.props.isSpecialZone ) then  nearByPickUpPointsView state push else currentLocationView push state
        , PrimaryButton.view (push <<< PrimaryButtonActionController) (primaryButtonConfirmPickupConfig state)
        ]
    ]

----------- loaderView -------------
loaderView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
loaderView push state =
  linearLayout
    [ orientation VERTICAL
    , height WRAP_CONTENT
    , width MATCH_PARENT
    , padding (Padding 0 40 0 24)
    , background Color.white900
    , cornerRadii $ Corners 24.0 true true false false
    , stroke ("1," <> Color.grey900)
    , clickable true
    , gravity CENTER_HORIZONTAL
    , visibility if (any (_ == state.props.currentStage) [ FindingEstimate, ConfirmingRide, TryAgain ]) then VISIBLE else GONE
    ]
    [ PrestoAnim.animationSet [ scaleAnim $ autoAnimConfig ]
        $ lottieLoaderView state push
    , PrestoAnim.animationSet [ fadeIn true ]
        $ textView $
            [ text
                ( case state.props.currentStage of
                    ConfirmingRide -> (getString CONFIRMING_THE_RIDE_FOR_YOU)
                    FindingEstimate -> (getString GETTING_ESTIMATES_FOR_YOU)
                    TryAgain -> (getString LET_TRY_THAT_AGAIN)
                    _ -> (getString GETTING_ESTIMATES_FOR_YOU)
                )
            , color Color.black800
            , height WRAP_CONTENT
            , width MATCH_PARENT
            , lineHeight "20"
            , gravity CENTER
            , margin (Margin 0 24 0 36)
            ] <> FontStyle.subHeading1 TypoGraphy
    , PrestoAnim.animationSet [ translateYAnimFromTopWithAlpha $ translateFullYAnimWithDurationConfig 300 ]
        $ separator (V 1) Color.grey900 state.props.currentStage
    , linearLayout
        [ width MATCH_PARENT
        , height WRAP_CONTENT
        , onClick push $ const CancelSearch
        , visibility if (any (_ == state.props.currentStage) [ FindingEstimate, TryAgain ]) then VISIBLE else GONE
        , orientation VERTICAL
        , gravity CENTER
        ]
        [ PrestoAnim.animationSet [ translateYAnimFromTopWithAlpha $ translateFullYAnimWithDurationConfig 300 ]
            $ textView $
                [ text (getString CANCEL_SEARCH)
                , lineHeight "18"
                , width MATCH_PARENT
                , height WRAP_CONTENT
                , padding (Padding 0 20 0 16)
                , color state.data.config.cancelSearchTextColor
                , gravity CENTER
                ] <> FontStyle.paragraphText TypoGraphy
        ]
    ]
------------------------------- pricingTutorialView --------------------------
pricingTutorialView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
pricingTutorialView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , weight 1.0
    , padding (Padding 0 safeMarginTop 0 safeMarginBottom)
    , background Color.white900
    ]
    [ -- TODO Add Animations
      -- PrestoAnim.animationSet
      --   [ translateYAnim 900 0 (state.props.currentStage == PricingTutorial)
      --   , translateYAnim 0 900 (not (state.props.currentStage == PricingTutorial))
      --   ] $
      PricingTutorialModel.view (push <<< PricingTutorialModelActionController)
    ]

------------------------ searchLocationModelView ---------------------------
searchLocationModelView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
searchLocationModelView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background if state.props.isRideServiceable then Color.transparent else Color.white900
    ]
    [ SearchLocationModel.view (push <<< SearchLocationModelActionController) $ searchLocationModelViewState state]

------------------------ quoteListModelView ---------------------------
quoteListModelView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
quoteListModelView push state =
  QuoteListModel.view (push <<< QuoteListModelActionController) $ quoteListModelViewState state


------------------------ emptyTextView ---------------------------
emptyTextView :: forall w. HomeScreenState ->  PrestoDOM (Effect Unit) w
emptyTextView state = textView [text "", width $ if os == "IOS" then V 1 else V 0]

emptyLayout :: forall w. HomeScreenState -> PrestoDOM (Effect Unit) w
emptyLayout state =
  textView
    [ width MATCH_PARENT
    , height $ V 30
    , background Color.transparent
    ]

------------------------ rideTrackingView ---------------------------
rideTrackingView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
rideTrackingView push state =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , padding (Padding 0 0 0 0)
    , background Color.transparent
    , alignParentBottom "true,-1" -- Check it in Android.
    , onBackPressed push (const $ BackPressed)
    , visibility if (any (_ == state.props.currentStage) [RideAccepted, RideStarted]) then VISIBLE else GONE
    ]
    [ -- TODO Add Animations
      -- PrestoAnim.animationSet
      --   [ translateInXAnim (-30) ( state.props.currentStage == RideAccepted || state.props.currentStage == RideStarted)
      --   , translateOutXAnim (-100) $ not ( state.props.currentStage == RideAccepted || state.props.currentStage == RideStarted)
      --   ] $
      linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , background Color.transparent
        -- , gravity BOTTOM -- Check it in Android.
        ]
        [ -- TODO Add Animations
          -- PrestoAnim.animationSet
          --   [ translateYAnim 900 0 ( state.props.currentStage == RideAccepted || state.props.currentStage == RideStarted)
          --   , translateYAnim 0 900 $ not ( state.props.currentStage == RideAccepted || state.props.currentStage == RideStarted)
          --   ] $
          coordinatorLayout
            [ height WRAP_CONTENT
            , width MATCH_PARENT
            ]
            [ bottomSheetLayout
                [ height WRAP_CONTENT
                , width MATCH_PARENT
                , background Color.transparent
                , sheetState COLLAPSED
                , peakHeight if (state.props.currentStage == RideAccepted && state.data.config.nyBrandingVisibility == true) then getHeightFromPercent 66
                             else if (state.props.currentStage == RideStarted && state.data.config.nyBrandingVisibility == true) then getHeightFromPercent 52
                             else getPeakHeight state.props.currentStage
                , visibility VISIBLE
                , halfExpandedRatio 0.75
                ]
                [ linearLayout
                    [ height WRAP_CONTENT
                    , width MATCH_PARENT
                    ]
                    [ if (state.props.currentStage == RideAccepted || state.props.currentStage == RideStarted) then
                        DriverInfoCard.view (push <<< DriverInfoCardActionController) $ driverInfoCardViewState state

                      else
                        emptyTextView state
                    ]
                ]
            ]
        ]
    ]

getPeakHeight :: Stage -> Int
getPeakHeight stage = case getValueFromConfig "enableShareRide" , stage of
                      "true" , RideAccepted -> getHeightFromPercent 65
                      "false" , RideAccepted -> getHeightFromPercent 60
                      "true" , _ ->  getHeightFromPercent 52
                      "false" , _ ->  getHeightFromPercent 47
                      _ , _ -> getHeightFromPercent 47

previousRideRatingView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
previousRideRatingView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    , background Color.black9000
    ]
    [ RatingCard.view (push <<< RatingCardAC) $ previousRideRatingViewState state ]

distanceOutsideLimitsView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
distanceOutsideLimitsView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    ]
    [ PopUpModal.view (push <<< DistanceOutsideLimitsActionController) (distanceOusideLimitsConfig state) ]

shortDistanceView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
shortDistanceView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , gravity BOTTOM
    ]
    [ PopUpModal.view (push <<< ShortDistanceActionController) (shortDistanceConfig state) ]

saveFavouriteCardView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
saveFavouriteCardView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    ]
    [ SaveFavouriteCard.view (push <<< SaveFavouriteCardAction) (state.data.saveFavouriteCard) ]

logOutPopUpView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
logOutPopUpView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    ]
    [ PopUpModal.view (push <<< PopUpModalAction) (logOutPopUpModelConfig state) ]

favouriteLocationModel :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
favouriteLocationModel push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background Color.white900
    ]
    [ FavouriteLocationModel.view (push <<< FavouriteLocationModelAC) (state.data.savedLocations) ]

------------------------------- separator --------------------------
separator :: Length -> String -> Stage -> forall w. PrestoDOM (Effect Unit) w
separator lineHeight lineColor currentStage =
  linearLayout
    [ height $ lineHeight
    , width MATCH_PARENT
    , background lineColor
    , visibility if currentStage == FindingQuotes then GONE else VISIBLE
    ]
    []

lottieLoaderView :: forall w. HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
lottieLoaderView state push =
  lottieAnimationView
    [ id $ getNewIDWithTag "1234567890"
    , afterRender (\_ -> pure $ startLottieProcess ((getAssetsBaseUrl FunctionCall) <> "lottie/ic_vehicle_processing.json") (getNewIDWithTag "1234567890") true 0.6 "Default") (const unit)
    , height $ V state.data.config.searchLocationConfig.lottieHeight
    , width $ V state.data.config.searchLocationConfig.lottieWidth
    ]

getEstimate :: forall action. (GetQuotesRes -> action) -> action -> Int -> Number -> (action -> Effect Unit) -> HomeScreenState -> Flow GlobalState Unit
getEstimate action flowStatusAction count duration push state = do
  if (isLocalStageOn FindingEstimate) || (isLocalStageOn TryAgain) then
    if (count > 0) then do
      resp <- getQuotes (state.props.searchId)
      _ <- pure $ printLog "caseId" (state.props.searchId)
      case resp of
        Right response -> do
          _ <- pure $ printLog "api Results " response
          let (GetQuotesRes resp) = response
          if not (state.props.isSpecialZone && (null resp.quotes) || ((not state.props.isSpecialZone) && null resp.estimates)) then do
            doAff do liftEffect $ push $ action response
            pure unit
          else do
            if (count == 1) then do
              _ <- pure $ updateLocalStage SearchLocationModel
              doAff do liftEffect $ push $ action response
            else do
              void $ delay $ Milliseconds duration
              getEstimate action flowStatusAction (count - 1) duration push state
        Left err -> do
          let errResp = err.response
              codeMessage = decodeErrorMessage errResp.errorMessage
          if ( err.code == 400 && codeMessage == "ACTIVE_BOOKING_ALREADY_PRESENT" ) then do
            -- _ <- pure $ logEvent state.data.logField "ny_fs_active_booking_found_on_search"
            void $ pure $ toast "ACTIVE BOOKING ALREADY PRESENT"
            doAff do liftEffect $ push $ flowStatusAction
          else do
            void $ delay $ Milliseconds duration
            if (count == 1) then do
              let response = GetQuotesRes { quotes: [], estimates: [], fromLocation: SearchReqLocationAPIEntity { lat: 0.0, lon: 0.0 }, toLocation: Nothing }
              _ <- pure $ updateLocalStage SearchLocationModel
              doAff do liftEffect $ push $ action response
            else do
              getEstimate action flowStatusAction (count - 1) duration push state
    else
      pure unit
  else
    pure unit

getQuotesPolling :: forall action. String -> (SelectListRes -> action) -> (ErrorResponse -> action) -> Int -> Number -> (action -> Effect Unit) -> HomeScreenState -> Flow GlobalState Unit
getQuotesPolling pollingId action retryAction count duration push state = do
  when (pollingId == (getValueToLocalStore TRACKING_ID) && (isLocalStageOn FindingQuotes)) $ do
    internetCondition <- liftFlow $ isInternetAvailable unit
    when internetCondition $ do
      let gotQuote = (getValueToLocalStore GOT_ONE_QUOTE)
      let minimumPollingCount = fromMaybe 0 (fromString (getValueToLocalStore TEST_MINIMUM_POLLING_COUNT))
      let usableCount = if gotQuote == "TRUE" && count > minimumPollingCount then minimumPollingCount else count
      if (spy "USABLECOUNT :- " usableCount > 0) then do
        resp <- selectList (state.props.estimateId)
        _ <- pure $ printLog "caseId" (state.props.estimateId)
        case resp of
          Right response -> do
            _ <- pure $ printLog "Quote api Results " response
            let (SelectListRes resp) = response
            if (resp.bookingId /= Nothing && resp.bookingId /= Just "") then do
               doAff do liftEffect $ push $ action response
            else if not (null ((fromMaybe dummySelectedQuotes resp.selectedQuotes)^._selectedQuotes)) then do
              doAff do liftEffect $ push $ action response
            else
              pure unit
            void $ delay $ Milliseconds duration
            getQuotesPolling pollingId action retryAction (usableCount - 1) duration push state
          Left err -> do
            _ <- pure $ printLog "api error " err
            doAff do liftEffect $ push $ retryAction err
            void $ delay $ Milliseconds duration
            pure unit
            getQuotesPolling pollingId action retryAction (usableCount - 1) duration push state
      else do
        let response = SelectListRes { selectedQuotes: Nothing, bookingId : Nothing }
        _ <- pure $ updateLocalStage QuoteList
        doAff do liftEffect $ push $ action response

driverLocationTracking :: forall action. (action -> Effect Unit) -> (String -> action) -> (String -> action) -> (Int -> Int -> action) -> Number -> String -> HomeScreenState -> String -> Flow GlobalState Unit
driverLocationTracking push action driverArrivedAction updateState duration trackingId state routeState = do
  _ <- pure $ printLog "trackDriverLocation2_function" trackingId
  if (any (\stage -> isLocalStageOn stage) [ RideAccepted, RideStarted, ChatWithDriver]) && ((getValueToLocalStore TRACKING_ID) == trackingId) then do
    when (state.props.bookingId /= "") $ do
      respBooking <- rideBooking (state.props.bookingId)
      case respBooking of
        Right (RideBookingRes respBooking) -> do
          if (length respBooking.rideList) > 0 then do
            case (respBooking.rideList !! 0) of
              Just (RideAPIEntity res) -> do
                let rideStatus = res.status
                doAff do liftEffect $ push $ action rideStatus
                if (os /= "IOS" && res.driverArrivalTime /= Nothing  && (getValueToLocalStore DRIVER_ARRIVAL_ACTION) == "TRIGGER_DRIVER_ARRIVAL" ) then doAff do liftEffect $ push $ driverArrivedAction (fromMaybe "" res.driverArrivalTime)
                  else pure unit
              Nothing -> pure unit
          else
            pure unit
        Left err -> pure unit
    if (state.props.isSpecialZone) && (isLocalStageOn RideAccepted) then do
      _ <- pure $ enableMyLocation true
      _ <- pure $ removeAllPolylines ""
      _ <- doAff $ liftEffect $ animateCamera state.data.driverInfoCardState.sourceLat state.data.driverInfoCardState.sourceLng 17
      _ <- doAff $ liftEffect $ addMarker "ny_ic_src_marker" state.data.driverInfoCardState.sourceLat state.data.driverInfoCardState.sourceLng 160 (0.0) (0.0)
      void $ delay $ Milliseconds duration
      driverLocationTracking push action driverArrivedAction updateState duration trackingId state routeState
      else do
        response <- getDriverLocation state.data.driverInfoCardState.rideId
        case response of
          Right (GetDriverLocationResp resp) -> do
            let
              rideID = state.data.driverInfoCardState.rideId
              srcLat = (resp ^. _lat)
              srcLon = (resp ^. _lon)
              dstLat = if (any (_ == state.props.currentStage) [ RideAccepted, ChatWithDriver]) then state.data.driverInfoCardState.sourceLat else state.data.driverInfoCardState.destinationLat
              dstLon = if (any (_ == state.props.currentStage) [ RideAccepted, ChatWithDriver]) then state.data.driverInfoCardState.sourceLng else state.data.driverInfoCardState.destinationLng
              markers = if (isLocalStageOn RideAccepted) || (isLocalStageOn ChatWithDriver) then (driverTracking "" ) else (rideTracking "")
              sourceSpecialTagIcon = specialLocationIcons state.props.zoneType.sourceTag
              destSpecialTagIcon = specialLocationIcons state.props.zoneType.destinationTag
              specialLocationTag =  if (any (_ == state.props.currentStage) [ RideAccepted, ChatWithDriver]) then
                                      specialLocationConfig destSpecialTagIcon sourceSpecialTagIcon
                                    else
                                      specialLocationConfig sourceSpecialTagIcon destSpecialTagIcon
            if (getValueToLocalStore TRACKING_ENABLED) == "False" then do
              _ <- pure $ setValueToLocalStore TRACKING_DRIVER "True"
              _ <- pure $ removeAllPolylines ""
              _ <- liftFlow $ drawRoute (walkCoordinate srcLat srcLon dstLat dstLon) "DOT" "#323643" false markers.srcMarker markers.destMarker 8 "DRIVER_LOCATION_UPDATE" "" "" specialLocationTag
              void $ delay $ Milliseconds duration
              driverLocationTracking push action driverArrivedAction updateState duration trackingId state routeState
              pure unit
            else if ((getValueToLocalStore TRACKING_DRIVER) == "False" || not (isJust state.data.route)) then do
              _ <- pure $ setValueToLocalStore TRACKING_DRIVER "True"
              routeResponse <- getRoute routeState $ makeGetRouteReq srcLat srcLon dstLat dstLon
              case routeResponse of
                Right (GetRouteResp routeResp) -> do
                  case ((routeResp) !! 0) of
                    Just (Route routes) -> do
                      _ <- pure $ removeAllPolylines ""
                      let newPoints = getExtendedPath (walkCoordinates routes.points)
                          newRoute = routes { points = Snapped (map (\item -> LatLong { lat: item.lat, lon: item.lng }) newPoints.points) }
                      liftFlow $ drawRoute newPoints "LineString" "#323643" true markers.srcMarker markers.destMarker 8 "DRIVER_LOCATION_UPDATE" "" (metersToKm routes.distance state) specialLocationTag
                      _ <- doAff do liftEffect $ push $ updateState routes.duration routes.distance
                      void $ delay $ Milliseconds duration
                      driverLocationTracking push action driverArrivedAction updateState duration trackingId state { data { route = Just (Route newRoute), speed = routes.distance / routes.duration } } routeState
                    Nothing -> do 
                      _ <- pure $ spy "Nothing" "1"
                      pure unit
                Left err -> do
                  _ <- pure $ spy "Nothing" "2"
                  pure unit
            else do
              case state.data.route of
                Just (Route route) -> do
                      locationResp <- liftFlow $ isCoordOnPath (walkCoordinates route.points) (resp ^. _lat) (resp ^. _lon) (state.data.speed)
                      if locationResp.isInPath then do
                        let newPoints = { points : locationResp.points}
                        let specialLocationTag =  if (any (\stage -> isLocalStageOn stage) [ RideAccepted, ChatWithDriver]) then
                                                    specialLocationConfig "" sourceSpecialTagIcon
                                                  else
                                                    specialLocationConfig "" destSpecialTagIcon
                        liftFlow $ updateRoute newPoints markers.destMarker (metersToKm locationResp.distance state) specialLocationTag
                        _ <- doAff do liftEffect $ push $ updateState locationResp.eta locationResp.distance
                        void $ delay $ Milliseconds duration
                        driverLocationTracking push action driverArrivedAction updateState duration trackingId state routeState
                      else do
                        driverLocationTracking push action driverArrivedAction updateState duration trackingId state { data { route = Nothing } } routeState
                Nothing -> driverLocationTracking push action driverArrivedAction updateState duration trackingId state { data { route = Nothing } } routeState
          Left err -> do
            void $ delay $ Milliseconds duration
            driverLocationTracking push action driverArrivedAction updateState duration trackingId state { data { route = Nothing } } routeState
  else do
    pure unit


confirmRide :: forall action. (RideBookingRes -> action) -> Int -> Number -> (action -> Effect Unit) -> HomeScreenState -> Flow GlobalState Unit
confirmRide action count duration push state = do
  if (count /= 0) && (isLocalStageOn ConfirmingRide) && (state.props.bookingId /= "")then do
    resp <- rideBooking (state.props.bookingId)
    _ <- pure $ printLog "response to confirm ride:- " (state.props.searchId)
    case resp of
      Right response -> do
        _ <- pure $ printLog "api Results " response
        let (RideBookingRes resp) = response
        let fareProductType = (resp.bookingDetails) ^. _fareProductType
        let status = if fareProductType == "OneWaySpecialZoneAPIDetails" then "CONFIRMED" else "TRIP_ASSIGNED"
        if  status == resp.status then do
            doAff do liftEffect $ push $ action response
            -- _ <- pure $ logEvent state.data.logField "ny_user_ride_assigned"
            pure unit
        else do
            void $ delay $ Milliseconds duration
            confirmRide action (count - 1) duration push state
      Left err -> do
        _ <- pure $ printLog "api error " err
        void $ delay $ Milliseconds duration
        confirmRide action (count - 1) duration push state
  else
    pure unit

cancelRidePopUpView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
cancelRidePopUpView push state =
  linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    ][ CancelRidePopUp.view (push <<< CancelRidePopUpAction) (cancelRidePopUpConfig state)]

checkForLatLongInSavedLocations :: forall action. (action -> Effect Unit) -> (Array LocationListItemState -> action) -> HomeScreenState -> Flow GlobalState Unit
checkForLatLongInSavedLocations push action state = do
  _ <- runExceptT $ runBackT $ setValueToLocalStore RELOAD_SAVED_LOCATION "false"
  _ <- runExceptT $ runBackT $ transformSavedLocations state.data.savedLocations
  if getValueToLocalStore RELOAD_SAVED_LOCATION == "true" then do
    (savedLocationResp )<- getSavedLocationList ""
    case savedLocationResp of
        Right (SavedLocationsListRes listResp) -> do
          doAff do liftEffect $ push $ action $ AddNewAddress.getSavedLocations listResp.list
          pure unit
        Left err -> pure unit
    pure unit
    else pure unit
  _ <- runExceptT $ runBackT $ setValueToLocalStore RELOAD_SAVED_LOCATION "false"
  pure unit

notinPickUpZoneView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
notinPickUpZoneView push state =
  linearLayout
      [ width MATCH_PARENT
      , height WRAP_CONTENT
      , orientation VERTICAL
      , stroke $ "1," <> Color.grey900
      , gravity CENTER
      , cornerRadius 8.0
      , margin $ MarginTop 16
      , padding $ PaddingVertical 2 10
      ][linearLayout
        [ height WRAP_CONTENT
        , width WRAP_CONTENT
        , orientation HORIZONTAL
        , margin (MarginLeft 15)]
        [ linearLayout
        [ height WRAP_CONTENT
        , width WRAP_CONTENT
        , orientation VERTICAL
        , gravity CENTER
        , margin $ MarginTop if os == "IOS" then 10 else 0
        ][  textView $
            [ text $ if state.data.rateCard.additionalFare == 0 then (getValueFromConfig "currency") <> (show state.data.suggestedAmount) else  (getValueFromConfig "currency") <> (show state.data.suggestedAmount) <> "-" <> (getValueFromConfig "currency") <> (show $ (state.data.suggestedAmount + state.data.rateCard.additionalFare))
            , color Color.black800
            , margin $ MarginTop 8
            , gravity CENTER_HORIZONTAL
            , width WRAP_CONTENT
            , height WRAP_CONTENT
            , onClick push $ const ShowRateCard
            ] <> FontStyle.priceFont LanguageStyle
            , estimatedTimeAndDistanceView push state
          ]
          , imageView
            [ imageWithFallback $ "ny_ic_info_blue," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_info_blue.png"
            , width $ V 40
            , height $ V 40
            , gravity BOTTOM
            , margin (MarginTop 13)
            , onClick push $ const ShowRateCard
            ]
        ]
        , linearLayout
          [ width MATCH_PARENT
          , height WRAP_CONTENT
          , orientation VERTICAL
          ]
          [ linearLayout
              [ width MATCH_PARENT
              , height $ V 1
              , margin $ Margin 16 12 16 14
              , background Color.grey900
              ][]
          , linearLayout
              [ width MATCH_PARENT
              , height WRAP_CONTENT
              , orientation VERTICAL
              ]
              [ linearLayout
                  [ width MATCH_PARENT
                  , height WRAP_CONTENT
                  , gravity CENTER_HORIZONTAL
                  , onClick push $ const PreferencesDropDown
                  , margin $ MarginBottom 8
                  ][ textView $
                      [ height $ V 24
                      , width WRAP_CONTENT
                      , color Color.darkDescriptionText
                      , text $ getString BOOKING_PREFERENCE
                      ] <> FontStyle.body5 TypoGraphy,
                      imageView
                      [ width $ V 10
                      , height $ V 10
                      , margin (Margin 9 8 0 0)
                      , imageWithFallback if state.data.showPreferences then "ny_ic_chevron_up," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_chevron_up.png" else "ny_ic_chevron_down," <> (getAssetStoreLink FunctionCall) <> "ny_ic_down_arrow.png"
                      ]
                  ],
                  linearLayout
                    [ width MATCH_PARENT
                    , height WRAP_CONTENT
                    , margin $ MarginLeft 20
                    , orientation VERTICAL
                    ][ linearLayout
                       [ width MATCH_PARENT
                       , height WRAP_CONTENT
                       , orientation VERTICAL
                       , visibility if state.data.showPreferences then VISIBLE else GONE
                       ][showMenuButtonView push (getString AUTO_ASSIGN_DRIVER) ("ny_ic_faster," <> (getAssetStoreLink FunctionCall) <> "ny_ic_faster.png") true state,
                         showMenuButtonView push (getString CHOOSE_BETWEEN_MULTIPLE_DRIVERS) ("ny_ic_info," <> (getAssetStoreLink FunctionCall) <> "ny_ic_information_grey.png") false state ]
                  ]

              ]
          ]
      ]
currentLocationView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
currentLocationView push state =
  linearLayout
            [ width MATCH_PARENT
            , height WRAP_CONTENT
            , orientation HORIZONTAL
            , margin $ MarginVertical 20 10
            , onClick push $ const GoBackToSearchLocationModal
            , padding $ PaddingHorizontal 15 15
            , stroke $ "1," <> state.data.config.confirmPickUpLocationBorder
            , gravity CENTER_VERTICAL
            , cornerRadius 5.0
            ]
            [ imageView
                [ imageWithFallback $ "ny_ic_source_dot," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_source_dot.png"
                , height $ V 20
                , width $ V 20
                , gravity CENTER_VERTICAL
                ]
            , textView
                $
                  [ text state.data.source
                  , ellipsize true
                  , singleLine true
                  , gravity CENTER
                  , padding (Padding 10 16 10 16)
                  , color Color.black800
                  ]
                <> FontStyle.subHeading1 TypoGraphy
            ]

nearByPickUpPointsView :: forall w . HomeScreenState -> (Action -> Effect Unit) -> PrestoDOM (Effect Unit) w
nearByPickUpPointsView state push =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , padding $ Padding 5 20 0 5
    ](map (\item -> MenuButton.view (push <<< MenuButtonActionController) (menuButtonConfig state item)) state.data.nearByPickUpPoints)

confirmingLottieView :: forall w. (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
confirmingLottieView push state =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , cornerRadii $ Corners 24.0 true true false false
    , alignParentBottom "true,-1"
    ][ relativeLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , cornerRadii $ Corners 24.0 true true false false
        , background Color.transparent
        ][ PrestoAnim.animationSet [ fadeIn true ] $
          loaderView push state
          ]
    ]

genderBanner :: forall w . (Action -> Effect Unit) -> HomeScreenState -> PrestoDOM (Effect Unit) w
genderBanner push state =
  Banner.view (push <<< GenderBannerModal) (genderBannerConfig state)
