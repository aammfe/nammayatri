{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.RideHistoryScreen.View where

import Common.Types.App
import Debug
import Screens.RideHistoryScreen.ComponentConfig

import Animation (fadeIn, fadeInWithDelay, fadeOut)
import Animation as Anim
import Components.BottomNavBar as BottomNavBar
import Components.BottomNavBar.Controller (navData)
import Components.DatePickerModel as DatePickerModel
import Components.ErrorModal as ErrorModal
import Components.GenericHeader as GenericHeader
import Components.PaymentHistoryModel as PaymentHistoryModel
import Control.Monad.Except (runExceptT)
import Control.Monad.Trans.Class (lift)
import Control.Transformers.Back.Trans (runBackT)
import Data.Array (length, (..))
import Data.Array as DA
import Data.Function.Uncurried (runFn1)
import Data.Tuple as DT
import Effect (Effect)
import Effect.Aff (launchAff)
import Effect.Class (liftEffect)
import Effect.Uncurried (runEffectFn2, runEffectFn3)
import Engineering.Helpers.BackTrack (liftFlowBT)
import Engineering.Helpers.Commons (flowRunner, getDateFromObj, getFormattedDate, getNewIDWithTag)
import Engineering.Helpers.Commons (safeMarginBottom, screenWidth)
import Font.Size as FontSize
import Font.Style as FontStyle
import Helpers.Utils (getcurrentdate, getPastDays, convertUTCtoISC)
import JBridge (horizontalScrollToPos)
import Language.Strings (getString)
import Language.Types (STR(..))
import Prelude (Unit, ($), (<$>), const, (==), (<<<), bind, pure, unit, discard, show, not, map, (&&), ($), (<$>), (<>), (<<<), (==), (/), (>), (-))
import Presto.Core.Types.Language.Flow (doAff)
import Services.API (GetRidesHistoryResp(..), Status(..))
import PrestoDOM (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), PrestoDOM, Screen, Visibility(..), afterRender, alignParentBottom, background, calendar, clickable, color, cornerRadius, fontSize, fontStyle, gravity, height, horizontalScrollView, id, imageView, imageWithFallback, linearLayout, margin, onAnimationEnd, onBackPressed, onClick, onRefresh, onScroll, onScrollStateChange, orientation, padding, relativeLayout, scrollBarX, scrollBarY, stroke, swipeRefreshLayout, text, textSize, textView, visibility, weight, width)
import PrestoDOM.Animation as PrestoAnim
import PrestoDOM.Elements.Keyed as Keyed
import PrestoDOM.Events (globalOnScroll)
import PrestoDOM.List as PrestoList
import PrestoDOM.Types.Core (toPropValue)
import Resource.Constants (tripDatesCount)
import Screens as ScreenNames
import Screens.RideHistoryScreen.Controller (Action(..), ScreenOutput, eval, prestoListFilter)
import Screens.Types as ST
import Services.Backend as Remote
import Storage (getValueToLocalStore)
import Styles.Colors as Color
import MerchantConfig.Utils (Merchant(..), getMerchant)
import Types.App (defaultGlobalState)


screen :: ST.RideHistoryScreenState -> PrestoList.ListItem -> Screen Action ST.RideHistoryScreenState ScreenOutput
screen initialState rideListItem =
  {
    initialState : initialState {
      shimmerLoader = ST.AnimatedIn
    }
  , view : view rideListItem
  , name : "RideHistoryScreen"
  , globalEvents : [
    globalOnScroll "RideHistoryScreen",
        ( \push -> do
            _ <- launchAff $ flowRunner defaultGlobalState $ runExceptT $ runBackT $ do
              let date = if initialState.datePickerState.selectedItem.date == 0 then getcurrentdate "" else (convertUTCtoISC initialState.datePickerState.selectedItem.utcDate "YYYY-MM-DD" )
              if initialState.currentTab == "COMPLETED" then do
                (GetRidesHistoryResp rideHistoryResponse) <- Remote.getRideHistoryReqBT "8" (show initialState.offsetValue) "false" "COMPLETED" date
                lift $ lift $ doAff do liftEffect $ push $ RideHistoryAPIResponseAction rideHistoryResponse.list
                else do
                  (GetRidesHistoryResp rideHistoryResponse) <- Remote.getRideHistoryReqBT "8" (show initialState.offsetValue) "false" "CANCELLED" date
                  lift $ lift $ doAff do liftEffect $ push $ RideHistoryAPIResponseAction rideHistoryResponse.list
            pure $ pure unit
        )
  ]
  , eval : (\action state -> do 
    let _ = spy "RideHistoryScreenState action" action
    let _ = spy "RideHistoryScreenState state" state 
    eval action state)
  }

view :: forall w . PrestoList.ListItem -> (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
view rideListItem push state =
   linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background Color.white900
    , orientation VERTICAL
    , onBackPressed push (const BackPressed)
    , afterRender push (const AfterRender)
    ][ Anim.screenAnimationFadeInOut
        $ relativeLayout
            [ height MATCH_PARENT
            , width WRAP_CONTENT
            ]$[rideListView rideListItem push state] <> if state.props.showPaymentHistory then [paymentHistoryModel push state] else []
    ]

rideListView :: forall w . PrestoList.ListItem -> (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
rideListView rideListItem push state = 
  linearLayout
  [ height WRAP_CONTENT
  , width MATCH_PARENT
  , orientation VERTICAL
  ]
  [ linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      , orientation VERTICAL
      , weight 1.0
      ]
      [ headerView push state
      , ridesView rideListItem push state
      ]
  , linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      , orientation VERTICAL
      , background Color.white900
      , onClick push (const Loader)
      , gravity CENTER
      , alignParentBottom "true,-1"
      , padding (PaddingBottom 5)
      , visibility if (state.loaderButtonVisibility && (not state.loadMoreDisabled)) then VISIBLE else GONE --(state.data.totalItemCount == (state.data.firstVisibleItem + state.data.visibleItemCount) && state.data.totalItemCount /= 0 && state.data.totalItemCount /= state.data.visibleItemCount) then VISIBLE else GONE
      ]
      [ linearLayout
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , orientation VERTICAL
          , margin $ Margin 0 5 0 5
          ]
          [ textView
              ( [ width WRAP_CONTENT
                , height WRAP_CONTENT
                , text (getString LOAD_MORE)
                , padding (Padding 10 5 10 5)
                , color Color.blueTextColor
                ]
                  <> FontStyle.subHeading1 TypoGraphy
              )
          ]
      ]
  , BottomNavBar.view (push <<< BottomNavBarAction) (navData ScreenNames.RIDE_HISTORY_SCREEN)
  ]

paymentHistoryModel :: forall w . (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
paymentHistoryModel push state = 
    PrestoAnim.animationSet[
    fadeIn state.props.showPaymentHistory
  , fadeOut $ not state.props.showPaymentHistory
  ] $ linearLayout
  [ width MATCH_PARENT
  , orientation VERTICAL
  , height MATCH_PARENT
  , background Color.white900
  , clickable true
  , visibility $ if state.props.showPaymentHistory then VISIBLE else GONE
  ]$[ PaymentHistoryModel.view (push <<< PaymentHistoryModelAC) state.data.paymentHistory
    ] <> if (length state.data.paymentHistory.paymentHistoryList) == 0 then [] else [BottomNavBar.view (push <<< BottomNavBarAction) (navData ScreenNames.RIDE_HISTORY_SCREEN)]

headerView :: forall w . (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
headerView push state =
  linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , gravity CENTER
    , margin $ MarginTop 16
    ][ textView $
        [ text $ getString TRIPS
        , gravity CENTER_VERTICAL
        , color Color.black900
        , margin (MarginBottom 10)
        ] <> FontStyle.body12 TypoGraphy
      , linearLayout
         [ background Color.bg_color
         , orientation HORIZONTAL
         , width MATCH_PARENT
         , height WRAP_CONTENT
         ][ linearLayout
              [ orientation VERTICAL
              , width WRAP_CONTENT
              , height WRAP_CONTENT
              , weight 0.5
              , onClick push (const $ SelectTab "COMPLETED")
              ][
                linearLayout
                  [ width $ (V (screenWidth unit / 2) )
                  , height WRAP_CONTENT
                  , gravity CENTER
                  ][ textView $
                      [ text (getString COMPLETED_)
                      , color if state.currentTab == "COMPLETED" then Color.black900 else Color.black500
                      , margin (MarginVertical 15 15)
                      ] <> FontStyle.body14 TypoGraphy
                  ]
              , linearLayout
                  [ height (V 2)
                  , width MATCH_PARENT
                  , background Color.black900
                  , margin $ MarginHorizontal 5 5
                  , visibility if state.currentTab == "COMPLETED" then VISIBLE else GONE
                  ][]
              ]
          , linearLayout
              [ orientation VERTICAL
              , width WRAP_CONTENT
              , height WRAP_CONTENT
              , weight 0.5
              , onClick push (const $ SelectTab "CANCELLED")
              ][
                linearLayout
                  [ width $ V (screenWidth unit / 2)
                  , height WRAP_CONTENT
                  , gravity CENTER
                  ][ textView $
                      [ text (getString CANCELLED_)
                      , color if state.currentTab == "CANCELLED" then Color.black900 else Color.black500
                      , margin (MarginVertical 15 15)
                      ] <> FontStyle.body14 TypoGraphy
                  ]
              , linearLayout
                  [ height (V 2)
                  , width MATCH_PARENT
                  , background Color.black900
                  , margin $ MarginHorizontal 5 5
                  , visibility if state.currentTab == "CANCELLED" then VISIBLE else GONE
                  ][]
              ]
         ]
      , calendarView push state
    ]

calendarView :: forall w. (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
calendarView push state =
    linearLayout
    [ height WRAP_CONTENT
    , width MATCH_PARENT
    , orientation VERTICAL
    ]
    [ linearLayout
        [ height WRAP_CONTENT
        , width MATCH_PARENT
        , background Color.white900
        , orientation HORIZONTAL
        , gravity CENTER
        , margin $ Margin 24 16 24 16
        ]
        [ linearLayout
          [ height WRAP_CONTENT
          , width WRAP_CONTENT
          , orientation HORIZONTAL
          , gravity CENTER_VERTICAL
          , onClick push (const ShowDatePicker)
          ][ textView
            $ [ width WRAP_CONTENT
              , height WRAP_CONTENT
              , text $ if state.datePickerState.activeIndex == (tripDatesCount - 1) then getString TODAY else runFn1 getFormattedDate state.datePickerState.selectedItem.utcDate
              , color Color.black800
              , margin $ MarginRight 12
              ]
            <> FontStyle.body1 LanguageStyle
        , linearLayout
            [ height $ V 34
            , width $ V 34
            , background Color.grey700
            , cornerRadius 17.0
            , gravity CENTER
            ]
            [ imageView
                [ height $ V 24
                , width $ V 24
                , imageWithFallback if state.props.showDatePicker then "ny_ic_chevron_down_blue,https://assets.juspay.in/nammayatri/images/driver/ny_ic_chevron_down_blue.png" else "ny_ic_calendar_blue,https://assets.juspay.in/nammayatri/images/driver/ny_ic_calendar_blue.png"
                ]
            ]
          ]
        , linearLayout
            [ height WRAP_CONTENT
            , weight 1.0
            ]
            []
        , linearLayout 
          [ height MATCH_PARENT
          , width WRAP_CONTENT
          , orientation HORIZONTAL
          , gravity CENTER
          , padding $ Padding 5 5 5 5
          , onClick push $ const OpenPaymentHistory
          , visibility $ if getMerchant FunctionCall == YATRISATHI then VISIBLE else GONE
          ][  textView
              $ [ height WRAP_CONTENT
                , width WRAP_CONTENT
                , text $ getString VIEW_PAYMENT_HISTORY
                , color Color.blue900
                , margin $ MarginRight 5
                ]
              <> FontStyle.tags LanguageStyle
            , imageView
              [ height $ V 8
              , width $ V 10
              , imageWithFallback "ny_ic_right_arrow_blue,https://assets.juspay.in/nammayatri/images/driver/ny_ic_right_arrow_blue.png"
              ]
          ]
        ]
    ]

ridesView :: forall w . PrestoList.ListItem -> (Action -> Effect Unit) -> ST.RideHistoryScreenState -> PrestoDOM (Effect Unit) w
ridesView rideListItem push state =
  relativeLayout
  [ width MATCH_PARENT
  , height MATCH_PARENT
  ]$[ linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      ][ swipeRefreshLayout
          [height MATCH_PARENT
          , width MATCH_PARENT
          , onRefresh push (const Refresh)
          , id "2000030"
          ]
          [ Keyed.relativeLayout
            [ width MATCH_PARENT
            , height MATCH_PARENT
            , orientation VERTICAL
            ]([ DT.Tuple "Rides"
                $ PrestoList.list
                [ height MATCH_PARENT
                , scrollBarY false
                , width MATCH_PARENT
                , onScroll "rides" "RideHistoryScreen" push (Scroll)
                , onScrollStateChange push (ScrollStateChanged)
                , visibility $ case state.shimmerLoader of
                            ST.AnimatedOut -> VISIBLE
                            _ -> if state.props.showPaymentHistory then VISIBLE else GONE
                , PrestoList.listItem rideListItem
                , background Color.bg_grey
                , PrestoList.listDataV2 (prestoListFilter state.currentTab state.prestoListArrayItems)
                ]
              , DT.Tuple "LOADER"
                  $ PrestoAnim.animationSet
                  [ PrestoAnim.Animation
                    [ PrestoAnim.duration 1000
                    , PrestoAnim.toAlpha $
                        case state.shimmerLoader of
                            ST.AnimatingIn -> 1.0
                            ST.AnimatedIn -> 1.0
                            ST.AnimatingOut -> 0.0
                            ST.AnimatedOut -> 0.0
                    , PrestoAnim.fromAlpha $
                        case state.shimmerLoader of
                            ST.AnimatingIn -> 0.0
                            ST.AnimatedIn -> 1.0
                            ST.AnimatingOut -> 1.0
                            ST.AnimatedOut -> 0.0
                    , PrestoAnim.tag "Shimmer"
                    ] true
                  ] $ PrestoList.list
                    [ height MATCH_PARENT
                    , scrollBarY false
                    , background Color.bg_grey
                    , width MATCH_PARENT
                    , onAnimationEnd push OnFadeComplete
                    , PrestoList.listItem rideListItem
                    , PrestoList.listDataV2 $ shimmerData <$> (1..5)
                    , visibility $ case state.shimmerLoader of
                            ST.AnimatedOut -> GONE
                            _ -> if state.props.showPaymentHistory then GONE else VISIBLE
                    ]
              , DT.Tuple "NoRides"
                  $ linearLayout
                    [ height MATCH_PARENT
                    , width MATCH_PARENT
                    , padding (PaddingBottom safeMarginBottom)
                    , background Color.white900
                    , visibility $ case state.shimmerLoader of
                              ST.AnimatedOut ->  if (DA.length (prestoListFilter state.currentTab state.prestoListArrayItems) > 0) then GONE else VISIBLE
                              _ -> if state.props.showPaymentHistory then VISIBLE else GONE
                    ][  ErrorModal.view (push <<< ErrorModalActionController) (errorModalConfig state)]
              ])
            ]
      ]
  ] <> if state.props.showDatePicker then [linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , background Color.blackLessTrans
    , visibility if state.props.showDatePicker then VISIBLE else GONE
    , onClick push $ const ShowDatePicker
    ][   linearLayout
      [ height WRAP_CONTENT
      , width MATCH_PARENT
      , orientation VERTICAL
      , background Color.white900
      ][DatePickerModel.view (push <<< DatePickerAC) (datePickerConfig state)]
    ]] else []

separatorView :: forall w. PrestoDOM (Effect Unit) w
separatorView =
  linearLayout
  [ height $ V 1
  , width MATCH_PARENT
  , background Color.separatorViewColor
  ][]

shimmerData :: Int -> ST.ItemState
shimmerData i = {
  date : toPropValue "31/05/2022",
  time : toPropValue "7:35pm",
  total_amount : toPropValue "₹ 0.0",
  card_visibility : toPropValue "gone",
  shimmer_visibility : toPropValue "visible",
  rideDistance : toPropValue "10km Ride with Bharat",
  status :  toPropValue "",
  vehicleModel : toPropValue "Auto",
  shortRideId : toPropValue ""  ,
  vehicleNumber :  toPropValue ""  ,
  driverName : toPropValue ""  ,
  driverSelectedFare : toPropValue ""  ,
  vehicleColor : toPropValue ""  ,
  id : toPropValue "",
  updatedAt : toPropValue "",
  source : toPropValue "Nagarjuna Apartments,15/2, 19th Main, 27th Cross Rd, Sector 2, HSR Layout, Bengaluru, Karnataka 560102",
  destination : toPropValue "Nagarjuna Apartments,15/2, 19th Main, 27th Cross Rd, Sector 2, HSR Layout, Bengaluru, Karnataka 560102",
  amountColor: toPropValue "",
  riderName : toPropValue "",
  metroTagVisibility : toPropValue "",
  accessibilityTagVisibility : toPropValue "",
  specialZoneText : toPropValue "",
  specialZoneImage : toPropValue "",
  specialZoneLayoutBackground : toPropValue ""
}
