{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.DriverEarningsScreen.Controller where

import Effect.Unsafe
import Prelude
import Screens.Types (DriverEarningsScreenState, DriverEarningsSubView(..), AnimationState(..), ItemState(..), IndividualRideCardState(..), DisabilityType(..))
import Log
import Components.BottomNavBar.Controller (Action(..)) as BottomNavBar
import Components.DatePickerModel as DatePickerModel
import Components.ErrorModal as ErrorModalController
import Components.GenericHeader as GenericHeader
import Components.IndividualRideCard.Controller as IndividualRideCardController
import Components.PaymentHistoryListItem as PaymentHistoryModelItem
import Components.PaymentHistoryModel as PaymentHistoryModel
import Components.PrimaryButton as PrimaryButton
import Data.Array (union, (!!), filter, length, (:), foldl)
import Data.Int (ceil)
import Data.Int (fromString, toNumber)
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Data.Number (fromString) as NUM
import Data.Show (show)
import Data.String (Pattern(..), split)
import Engineering.Helpers.Commons (getNewIDWithTag, strToBool)
import Engineering.Helpers.LogEvent (logEvent)
import JBridge (cleverTapCustomEvent, metaLogEvent, firebaseLogEvent)
import Helpers.Utils (setRefreshing, setEnabled, parseFloat, getRideLabelData, convertUTCtoISC, getRequiredTag)
import Language.Strings (getString)
import Language.Types (STR(..))
import Log (trackAppActionClick, trackAppEndScreen, trackAppScreenRender, trackAppBackPress)
import PrestoDOM (Eval, continue, exit, ScrollState(..), updateAndExit)
import PrestoDOM.Types.Core (class Loggable, toPropValue)
import Resource.Constants (decodeAddress, tripDatesCount)
import Components.PrimaryButton as PrimaryButtonController
import Screens (ScreenName(..), getScreen)
import Screens.Types
import Services.API (RidesInfo(..), Status(..),  DriverProfileSummaryRes(..))
import Storage (KeyStore(..), getValueToLocalNativeStore, setValueToLocalNativeStore)
import Styles.Colors as Color
import Debug

instance showAction :: Show Action where
  show _ = ""

instance loggableAction :: Loggable Action where
  performLog action appId = case action of
    _ -> trackAppScreenRender appId "screen" (getScreen DRIVER_EARNINGS_SCREEN)
    -- BackPressed -> do
    --   trackAppBackPress appId (getScreen RIDE_HISTORY_SCREEN)
    --   trackAppEndScreen appId (getScreen RIDE_HISTORY_SCREEN)
    -- OnFadeComplete str -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "on_fade_complete"
    -- Refresh -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "refresh"
    -- SelectTab str -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "select_tab"
    -- BottomNavBarAction (BottomNavBar.OnNavigate item) -> do
    --   trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "bottom_nav_bar" "on_navigate"
    --   trackAppEndScreen appId (getScreen RIDE_HISTORY_SCREEN)
    -- IndividualRideCardAction (IndividualRideCardController.Select index)-> do
    --   trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "individual_ride_card_action" "select"
    --   trackAppEndScreen appId (getScreen RIDE_HISTORY_SCREEN)
    -- Loader -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "load_more"
    -- Scroll str -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "scroll_event"
    -- ScrollStateChanged scrollState -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "scroll_state_changed"
    RideHistoryAPIResponseAction resp -> trackAppScreenEvent appId (getScreen DRIVER_EARNINGS_SCREEN) "in_screen" "ride_history_response_action"
    -- ErrorModalActionController action -> trackAppScreenEvent appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "error_modal_action"
    -- Dummy -> trackAppScreenEvent appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "dummy_action"
    -- NoAction -> trackAppScreenEvent appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "no_action"
    -- ShowDatePicker -> trackAppScreenEvent appId (getScreen RIDE_HISTORY_SCREEN) "in_screen" "show_date_picker_action"
    -- DatePickerAC act -> trackAppActionClick appId (getScreen RIDE_HISTORY_SCREEN) "date_picker_model" "on_date_select"
    -- GenericHeaderAC act -> case act of
    --   GenericHeader.PrefixImgOnClick -> do
    --       trackAppActionClick appId (getScreen TRIP_DETAILS_SCREEN) "generic_header" "back_icon_on_click"
    --       trackAppEndScreen appId (getScreen TRIP_DETAILS_SCREEN)
    --   GenericHeader.SuffixImgOnClick -> do
    --       trackAppActionClick appId (getScreen TRIP_DETAILS_SCREEN) "generic_header" "forward_icon_on_click"
    --       trackAppEndScreen appId (getScreen TRIP_DETAILS_SCREEN)
    -- PaymentHistoryModelAC act -> pure unit
    -- OpenPaymentHistory -> pure unit

data ScreenOutput = GoBack
                    

data Action = Dummy
            | ChangeTab DriverEarningsSubView
            -- | Refresh
            | BackPressed
            | PrimaryButtonActionController PrimaryButtonController.Action
            | PlanCount Boolean
            | BottomNavBarAction BottomNavBar.Action
            -- | IndividualRideCardAction IndividualRideCardController.Action
            | RideHistoryAPIResponseAction (Array RidesInfo)
            | DriverSummary DriverProfileSummaryRes
            -- | Loader
            -- | Scroll String
            | ErrorModalActionController ErrorModalController.Action
            -- | NoAction
            | AfterRender
            -- | ScrollStateChanged ScrollState
            -- | DatePickerAC DatePickerModel.Action
            | SelectPlan Int
            | GenericHeaderAC GenericHeader.Action
            | BarViewSelected Int 
            | LeftChevronClicked Int
            | RightChevronClicked Int
            | MyAction (Array WeeklyEarning)
            -- | PaymentHistoryModelAC PaymentHistoryModel.Action
            -- | OpenPaymentHistory

eval :: Action -> DriverEarningsScreenState -> Eval Action ScreenOutput DriverEarningsScreenState

eval BackPressed state = exit GoBack

eval (PrimaryButtonActionController PrimaryButtonController.OnClick) state = continue state

eval (ChangeTab subView') state = continue state{props{subView = subView', selectedBarIndex = -1}}

eval (BarViewSelected index) state = do
  let mbSelectedBarData = state.props.currWeekData !! index
  let selectedBarData = { fromDate : case mbSelectedBarData of
                                  Just mbSelectedBarData -> mbSelectedBarData.rideDate
                                  Nothing -> "",
    toDate : "",
    totalEarnings : 0,
    totalRides : 0,
    totalDistanceTravelled : 0
  } 
  continue state{props{selectedBarIndex = index, totalEarningsData = spy "inside BarViewSelected" selectedBarData}}


eval (DriverSummary response) state = do
  let (DriverProfileSummaryRes resp) = response
  let anyRidesAssignedEver = if resp.totalRidesAssigned > 0 then true else false
  continue state{data{anyRidesAssignedEver = anyRidesAssignedEver}}

eval (LeftChevronClicked currentIndex) state = do
  let updatedIndex = case currentIndex of 
                        0 -> currentIndex + 1
                        _ -> currentIndex
  continue state{props{weekIndex = updatedIndex, selectedBarIndex = -1}}
  
eval (RightChevronClicked currentIndex) state = do
  let updatedIndex = case currentIndex of 
                        1 -> currentIndex - 1
                        _ -> currentIndex
  continue state{props{weekIndex = updatedIndex, selectedBarIndex = -1}}

eval (MyAction barGraphData) state = do 
  let totalBarData = getTotalBarGrapData barGraphData 
  continue state{props{totalEarningsData = spy "printing totalbardata -> " totalBarData}}

-- eval (OnFadeComplete _ ) state = if (not state.recievedResponse) then continue state else
--   continue state { shimmerLoader = case state.shimmerLoader of
--                               AnimatedIn ->AnimatedOut
--                               AnimatingOut -> AnimatedOut
--                               a -> a  }

-- eval Refresh state = do
--   exit $ RefreshScreen state

-- eval (ScrollStateChanged scrollState) state = do
--   _ <- case scrollState of
--            SCROLL_STATE_FLING ->
--                pure $ setEnabled "2000030" false
--            _ ->
--                pure unit
--   continue state

-- eval (SelectTab tab) state = updateAndExit state $ SelectedTab state{currentTab = tab, datePickerState { activeIndex = tripDatesCount - 1 , selectedItem {date = 0, month = "", year = 0}}} 

-- eval (BottomNavBarAction (BottomNavBar.OnNavigate screen)) state = do
--   case screen of
--     "Home" -> exit $ HomeScreen
--     "Profile" -> exit $ ProfileScreen
--     "Alert" -> do
--       _ <- pure $ setValueToLocalNativeStore ALERT_RECEIVED "false"
--       let _ = unsafePerformEffect $ logEvent state.logField "ny_driver_alert_click"
--       exit $ GoToNotification
--     "Rankings" -> do
--       _ <- pure $ setValueToLocalNativeStore REFERRAL_ACTIVATED "false"
--       exit $ GoToReferralScreen
--     "Join" -> do
--       let driverSubscribed = getValueToLocalNativeStore DRIVER_SUBSCRIBED == "true"
--       _ <- pure $ cleverTapCustomEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
--       _ <- pure $ metaLogEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
--       let _ = unsafePerformEffect $ firebaseLogEvent if driverSubscribed then "ny_driver_myplan_option_clicked" else "ny_driver_plan_option_clicked"
--       exit $ SubscriptionScreen state
--     _ -> continue state

-- eval (IndividualRideCardAction (IndividualRideCardController.Select index)) state = do
--   let filteredRideList = rideListFilter state.currentTab state.rideList
--   exit $ GoToTripDetails state {
--       selectedItem = (fromMaybe dummyCard (filteredRideList !! index))
--   }
-- eval Loader state = do
--   exit $ LoaderOutput state{loaderButtonVisibility = false}

eval (RideHistoryAPIResponseAction rideList) state = do
  let coinHistoryItemsList = (coinHistoryItemsListTransformer rideList)
  continue $ state {data{earningHistoryItems = coinHistoryItemsList}}

-- eval (Scroll value) state = do
--   -- TODO : LOAD MORE FUNCTIONALITY
--   let firstIndex = fromMaybe 0 (fromString (fromMaybe "0"((split (Pattern ",")(value))!!0)))
--   let visibleItems = fromMaybe 0 (fromString (fromMaybe "0"((split (Pattern ",")(value))!!1)))
--   let totalItems = fromMaybe 0 (fromString (fromMaybe "0"((split (Pattern ",")(value))!!2)))
--   let canScrollUp = fromMaybe true (strToBool (fromMaybe "true" ((split (Pattern ",")(value))!!3)))
--   let loadMoreButton = if (totalItems == (firstIndex + visibleItems) && totalItems /= 0 && totalItems /= visibleItems) then true else false
--   _ <- if canScrollUp then (pure $ setEnabled "2000030" false) else  (pure $ setEnabled "2000030" true)
--   continue state { loaderButtonVisibility = loadMoreButton}

-- eval (DatePickerAC (DatePickerModel.OnDateSelect idx item)) state = do
--   let newState = state{datePickerState{activeIndex = idx, selectedItem = item},rideList = [], prestoListArrayItems = []}
--   exit $ SelectedTab newState

-- eval ShowDatePicker state = continue state{props{showDatePicker = not state.props.showDatePicker}}

-- eval OpenPaymentHistory state = exit $ OpenPaymentHistoryScreen state

eval (GenericHeaderAC (GenericHeader.PrefixImgOnClick)) state = continue state{props{subView = YATRI_COINS_VIEW}}

-- eval (PaymentHistoryModelAC (PaymentHistoryModel.ErrorModalActionController (ErrorModalController.PrimaryButtonActionController PrimaryButton.OnClick))) state = continue state{props{showPaymentHistory = false}}

-- eval (PaymentHistoryModelAC (PaymentHistoryModel.PaymentHistoryListItemAC (PaymentHistoryModelItem.OnClick id))) state = do
--   let updatedData = map (\item -> if item.id == id then item{isSelected = not item.isSelected} else item) state.data.paymentHistory.paymentHistoryList
--   continue state{data{paymentHistory { paymentHistoryList = updatedData}}}

eval (SelectPlan index) state = if index == state.props.selectedPlanIndex 
                                  then continue state
                                else continue state {props{selectedPlanIndex = index, selectedPlanQuantity = 0}}

eval (PlanCount shouldIncrease) state = do
  let quantity = if shouldIncrease then state.props.selectedPlanQuantity + 1 else state.props.selectedPlanQuantity - 1
  continue state {props{selectedPlanQuantity = quantity}}

eval _ state = continue state


coinHistoryItemsListTransformer :: Array RidesInfo -> Array CoinHistoryItem
coinHistoryItemsListTransformer list = (map (\(RidesInfo ride) -> {
  destination : Just (decodeAddress (ride.toLocation) false),
  timestamp : (convertUTCtoISC (ride.createdAt) "D MMM") <> " " <> (convertUTCtoISC (ride.createdAt )"h:mm A"),
  earnings : Just (case (ride.status) of
                    "CANCELLED" -> 0
                    _ -> fromMaybe ride.estimatedBaseFare ride.computedFare),
  status : Just ride.status, 
  coins :  Nothing,
  event : Nothing,
  tagImages : getTagImages (RidesInfo ride) []
}) list) 

getTagImages :: RidesInfo -> Array String -> Array String
getTagImages (RidesInfo ride) list = do
  let a = case ride.customerExtraFee of
            Just _ -> ("ny_ic_tip_ride_tag" : list)
            Nothing -> list
      b = case ride.disabilityTag of
          Just _ -> "ny_ic_disability_tag" : list
          Nothing -> list
      c = case ride.specialLocationTag of
          Just _ -> "ny_ic_special_location_tag" : list
          Nothing -> list
  (a <> b <> c)
  

getTotalBarGrapData :: Array WeeklyEarning -> TotalEarningsData
getTotalBarGrapData barGraphData = do
  let firstElement = barGraphData !! 0
      lastElement = barGraphData !! 6
      totalEarnings = foldl (\acc record -> case record.earnings of
                                         Just x -> acc + x
                                         Nothing -> acc) 0 barGraphData
      totalDistance = foldl (\acc record ->  acc + record.rideDistance ) 0 barGraphData
      totalRides = foldl (\acc record -> acc + record.noOfRides) 0 barGraphData
  {fromDate : case firstElement of
              Just firstElement -> firstElement.rideDate
              Nothing -> "",
    toDate : case lastElement of
              Just lastElement -> lastElement.rideDate
              Nothing -> "",
    totalEarnings : totalEarnings,
    totalRides : totalRides,
    totalDistanceTravelled : totalDistance
  }  
-- rideHistoryListTransformer :: Array RidesInfo -> Array ItemState
-- rideHistoryListTransformer list = (map (\(RidesInfo ride) ->
--   let accessibilityTag = (getDisabilityType ride.disabilityTag)
--     in 
--       {
--       date : toPropValue (convertUTCtoISC (ride.createdAt) "D MMM"),
--       time : toPropValue (convertUTCtoISC (ride.createdAt )"h:mm A"),
--       total_amount : toPropValue $ fromMaybe ride.estimatedBaseFare ride.computedFare,
--       card_visibility : toPropValue "visible",
--       shimmer_visibility : toPropValue "gone",
--       rideDistance : toPropValue $ (parseFloat (toNumber (fromMaybe 0 ride.chargeableDistance) / 1000.0) 2) <> " km Ride" <> case ride.riderName of 
--                               Just name -> " with " <> name
--                               Nothing -> "",
--       status :  toPropValue ride.status,
--       vehicleModel : toPropValue ride.vehicleModel ,
--       shortRideId : toPropValue ride.shortRideId  ,
--       vehicleNumber :  toPropValue ride.vehicleNumber  ,
--       driverName : toPropValue ride.driverName  ,
--       driverSelectedFare : toPropValue ride.driverSelectedFare  ,
--       vehicleColor : toPropValue ride.vehicleColor  ,
--       id : toPropValue ride.shortRideId,
--       updatedAt : toPropValue ride.updatedAt,
--       source : toPropValue (decodeAddress (ride.fromLocation) false),
--       destination : toPropValue (decodeAddress (ride.toLocation) false),
--       amountColor: toPropValue (case (ride.status) of
--                     "COMPLETED" -> Color.black800
--                     "CANCELLED" -> Color.red
--                     _ -> Color.black800),
--       riderName : toPropValue $ fromMaybe "" ride.riderName,
--       metroTagVisibility : toPropValue if (ride.specialLocationTag /= Nothing || ride.disabilityTag /= Nothing  || (getRequiredTag "text" ride.specialLocationTag accessibilityTag) /= Nothing) then "visible" else "gone",
--       specialZoneText : toPropValue $ getRideLabelData "text" (if (isJust accessibilityTag) then Just "Purple_Ride" else ride.specialLocationTag) Nothing,
--       specialZoneImage : toPropValue $ getRideLabelData "imageUrl" ride.specialLocationTag accessibilityTag,
--       specialZoneLayoutBackground : toPropValue $ getRideLabelData "backgroundColor" ride.specialLocationTag accessibilityTag

--     }) list )

-- getDisabilityType :: Maybe String -> Maybe DisabilityType
-- getDisabilityType disabilityString = case disabilityString of 
--                                       Just "BLIND_LOW_VISION" -> Just BLIND_AND_LOW_VISION
--                                       Just "HEAR_IMPAIRMENT" -> Just HEAR_IMPAIRMENT
--                                       Just "LOCOMOTOR_DISABILITY" -> Just LOCOMOTOR_DISABILITY
--                                       Just "OTHER" -> Just OTHER_DISABILITY
--                                       _ -> Nothing

-- rideListResponseTransformer :: Array RidesInfo -> Array IndividualRideCardState
-- rideListResponseTransformer list = (map (\(RidesInfo ride) -> {
--     date : (convertUTCtoISC (ride.createdAt) "D MMM"),
--     time : (convertUTCtoISC (ride.createdAt )"h:mm A"),
--     total_amount : (case (ride.status) of
--                     "CANCELLED" -> 0
--                     _ -> fromMaybe ride.estimatedBaseFare ride.computedFare),
--     card_visibility : (case (ride.status) of
--                         "CANCELLED" -> "gone"
--                         _ -> "visible"),
--     shimmer_visibility : "gone",
--     rideDistance :  parseFloat (toNumber (fromMaybe 0 ride.chargeableDistance) / 1000.0) 2,
--     status :  (ride.status),
--     vehicleModel : ride.vehicleModel ,
--     shortRideId : ride.shortRideId  ,
--     vehicleNumber :  ride.vehicleNumber  ,
--     driverName : ride.driverName  ,
--     driverSelectedFare : ride.driverSelectedFare  ,
--     vehicleColor : ride.vehicleColor  ,
--     id : ride.shortRideId,
--     updatedAt : ride.updatedAt,
--     source : (decodeAddress (ride.fromLocation) false),
--     destination : (decodeAddress (ride.toLocation) false),
--     vehicleType : ride.vehicleVariant

-- }) list )


-- prestoListFilter :: String -> Array ItemState -> Array ItemState
-- prestoListFilter statusType list = (filter (\(ride) -> (ride.status == (toPropValue statusType)) ) list )

-- rideListFilter :: String -> Array IndividualRideCardState -> Array IndividualRideCardState
-- rideListFilter statusType list = (filter (\(ride) -> (ride.status == statusType) ) list )

-- dummyCard :: IndividualRideCardState
-- dummyCard =  {
--     date : "",
--     time : "",
--     total_amount : 0,
--     card_visibility : "",
--     shimmer_visibility : "",
--     rideDistance : "",
--     status : "",
--     vehicleModel : "",
--     shortRideId : "",
--     vehicleNumber : "",
--     driverName : "",
--     driverSelectedFare : 0,
--     vehicleColor : "",
--     id : "",
--     updatedAt : "",
--     source : "",
--     destination : "",
--     vehicleType : ""
--   }
