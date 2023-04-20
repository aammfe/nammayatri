{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.DriverDetailsScreen.View where

import Prelude 
import PrestoDOM (Gravity(..), Length(..), Margin(..), Orientation(..), Padding(..), PrestoDOM, Screen, Visibility(..), background, color, fontStyle, gravity, height, imageUrl, imageView, linearLayout, margin, orientation, padding, text, textSize, textView, weight, width, onClick, frameLayout, layoutGravity, alpha, scrollView, cornerRadius, onBackPressed, afterRender, id, visibility, imageWithFallback, clickable, relativeLayout)
import Effect (Effect)
import Screens.DriverDetailsScreen.Controller (Action(..), ScreenOutput, eval, getTitle, getValue)
import Screens.DriverDetailsScreen.ScreenData (ListOptions(..), optionList)
import Screens.Types as ST
import Styles.Colors as Color
import Font.Style as FontStyle
import Font.Size as FontSize
import Engineering.Helpers.Commons as EHC
import Animation as Anim
import Language.Strings (getString)
import Language.Types(STR(..))
import JBridge as JB
import Common.Types.App
import Components.InAppKeyboardModal.View as InAppKeyboardModal
import Components.InAppKeyboardModal.Controller as InAppKeyboardModalController
import Data.Maybe (Maybe(..), fromMaybe, isJust)
import Debug.Trace (spy)
import Components.PopUpModal.View as PopUpModal
import Components.PopUpModal.Controller as PopUpModalConfig
import Screens.DriverDetailsScreen.ComponentConfig
import PrestoDOM.Types.DomAttributes (Corners(..))


screen :: ST.DriverDetailsScreenState -> Screen Action ST.DriverDetailsScreenState ScreenOutput
screen initialState =
  { initialState
  , view
  , name : "DriverDetailsScreen"
  , globalEvents : [(\push -> do
    _ <- JB.storeCallBackImageUpload push CallBackImageUpload
    pure $ pure unit)]
  , eval : (\state  action -> do
      let _ = spy "DriverDetailsScreen state -----" state
      let _ = spy "DriverDetailsScreen --------action" action
      eval state action)
  }

view
  :: forall w
  . (Action -> Effect Unit)
  -> ST.DriverDetailsScreenState
  -> PrestoDOM (Effect Unit) w
view push state =
  Anim.screenAnimation $
  relativeLayout
  [height MATCH_PARENT
    , width MATCH_PARENT
    , orientation VERTICAL]
  ([ linearLayout
    [ height MATCH_PARENT
    , width MATCH_PARENT
    , orientation VERTICAL
    , onBackPressed push (const BackPressed)
    , afterRender push (const AfterRender)
    ][
      headerLayout state push,
      profilePictureLayout state push
     , driverDetailsView push state
    ]
  , if state.props.keyboardModalType == ST.MOBILE__NUMBER then enterMobileNumberModal push state else textView[height $ V 0,
  width $ V 0]
 , if state.props.keyboardModalType == ST.OTP then enterOtpModal push state else textView[height $ V 0,
  width $ V 0]
  ] <> if state.props.otpAttemptsExceeded then [enterOtpExceededModal push state] else []
  <> if state.props.removeNumberPopup then [removeAlternateNumber push state] else [])

---------------------------------------------- profilePictureLayout ------------------------------------
profilePictureLayout :: ST.DriverDetailsScreenState -> (Action -> Effect Unit) -> forall w . PrestoDOM (Effect Unit) w
profilePictureLayout state push =
    frameLayout
    [ width MATCH_PARENT
    , height $ V ((EHC.screenHeight unit)/5)
    , margin (MarginTop 10)
    ][ linearLayout
        [ width WRAP_CONTENT
        , height WRAP_CONTENT
        , orientation VERTICAL
        , layoutGravity "center"
        ][ frameLayout
            [ width $ V 90
            , height $ V 90
            ][ imageView
                [ width $ V 90
                , height $ V 90
                , layoutGravity "center"
                , cornerRadius 45.0
                , id (EHC.getNewIDWithTag "EditProfileImage")
                , imageWithFallback "ny_ic_profile_image,https://assets.juspay.in/nammayatri/images/common/ny_ic_profile_image.png"
                -- TODO : after 15 aug
                -- , afterRender push (const RenderBase64Image)
                ]
              , linearLayout
                [ width MATCH_PARENT
                , height $ V 30
                , layoutGravity "bottom"
                ][ linearLayout
                    [ width MATCH_PARENT
                    , height $ V 30
                    , gravity RIGHT
                    ][ imageView
                        [ width $ V 30
                        , height $ V 30
                        , gravity RIGHT
                        , cornerRadius 45.0
                        , imageWithFallback "ny_ic_camera_white,https://assets.juspay.in/nammayatri/images/driver/ny_ic_camera_white.png"
                        , visibility GONE 
                        -- To be added after 15 aug
                        -- , onClick (\action-> do
                        --       _ <- liftEffect $ JB.uploadFile unit
                        --       pure unit)(const UploadFileAction)
                        ]
                    ]
                ]

            ]
        ]
    ]


-------------------------------------------------- headerLayout --------------------------
headerLayout :: ST.DriverDetailsScreenState -> (Action -> Effect Unit) -> forall w . PrestoDOM (Effect Unit) w
headerLayout state push = 
 linearLayout
 [ width MATCH_PARENT
 , height WRAP_CONTENT
 , orientation VERTICAL
 ][ linearLayout
    [ width MATCH_PARENT
    , height MATCH_PARENT
    , orientation HORIZONTAL
    , layoutGravity "center_vertical"
    , padding (Padding 5 0 5 0)
    ][ imageView
        [ width $ V 25
        , height MATCH_PARENT
        , imageWithFallback "ny_ic_back,https://assets.juspay.in/nammayatri/images/driver/ny_ic_back.png"
        , gravity CENTER_VERTICAL
        , onClick push (const BackPressed)
        , padding (Padding 2 2 2 2)
        , margin (MarginLeft 5)
        ]
      , textView
        [ width WRAP_CONTENT
        , height MATCH_PARENT
        , text (getString PERSONAL_DETAILS)
        , textSize FontSize.a_19
        , margin (MarginLeft 20)
        , color Color.black
        , fontStyle $ FontStyle.semiBold LanguageStyle
        , weight 1.0
        , gravity CENTER_VERTICAL
        , alpha 0.8
        ]
    ]
  , horizontalLineView 0 0
 ]


------------------------------------------ driverDetailsView ---------------

driverDetailsView :: (Action ->Effect Unit) -> ST.DriverDetailsScreenState ->  forall w . PrestoDOM (Effect Unit) w
driverDetailsView push state =
 scrollView
 [ width MATCH_PARENT
 , height WRAP_CONTENT
 ][ linearLayout
    [ width MATCH_PARENT
    , height WRAP_CONTENT
    , orientation VERTICAL
    , padding (PaddingBottom 5)
    ] (map(\optionItem ->
            linearLayout
            [ width MATCH_PARENT
            , height WRAP_CONTENT
            , orientation VERTICAL
            , gravity CENTER_VERTICAL
            , visibility if (optionItem.title == DRIVER_LICENCE_INFO) then GONE else VISIBLE
            ][ linearLayout
              [ width MATCH_PARENT
              , height WRAP_CONTENT
              , orientation VERTICAL
              , gravity CENTER_VERTICAL
              , padding (Padding 15 0 15 0)
              , margin (MarginBottom 20)
              , visibility case optionItem.title of
                                      DRIVER_ALTERNATE_MOBILE_INFO -> case state.data.driverAlternateMobile of
                                                                      Just _ -> VISIBLE
                                                                      _ -> GONE
                                      _ -> VISIBLE
              ][ textView
                  [ height WRAP_CONTENT
                  , width WRAP_CONTENT
                  , text (getTitle optionItem.title)
                  , color Color.black800
                  , fontStyle $ FontStyle.medium LanguageStyle
                  , textSize FontSize.a_14
                  , alpha 0.9
                  ], driverSubsection push state optionItem.title
                  , if(optionItem.title == DRIVER_MOBILE_INFO && state.props.checkAlternateNumber == true && state.props.keyboardModalType == ST.NONE && state.data.driverAlternateMobile == Nothing) then addAlternateNumber push state else dummyTextView
                  , horizontalLineView 0 0
              ]


            ]
          ) optionList
    )
 ]

driverSubsection :: (Action ->Effect Unit) -> ST.DriverDetailsScreenState -> ListOptions -> forall w . PrestoDOM (Effect Unit) w
driverSubsection push state title =
  linearLayout[
    height WRAP_CONTENT
  , width MATCH_PARENT
  , orientation HORIZONTAL
  ][
  textView (
  [ width WRAP_CONTENT
  , height WRAP_CONTENT
  , margin (MarginTop 10)
  , color Color.black900
  , text (getValue title state)
  ] <> FontStyle.body1 TypoGraphy
  ),
  linearLayout[
    height WRAP_CONTENT
  , weight 1.0
  ][],
  textView(
  [width WRAP_CONTENT
  , height WRAP_CONTENT
  , text (getString EDIT)
  , gravity RIGHT
  , visibility if(title == DRIVER_ALTERNATE_MOBILE_INFO) then VISIBLE else GONE
  , textSize FontSize.a_14
  , fontStyle $ FontStyle.medium LanguageStyle
  , color Color.blue900
  , margin (Margin 0 10 20 0)
  , onClick push (const ClickEditAlternateNumber)
  ] <> FontStyle.body1 TypoGraphy
  ),
  textView(
  [width WRAP_CONTENT
  , height WRAP_CONTENT
  , text (getString REMOVE)
  , gravity RIGHT
  , visibility if(title == DRIVER_ALTERNATE_MOBILE_INFO) then VISIBLE else GONE
  , textSize FontSize.a_14
  , fontStyle $ FontStyle.medium LanguageStyle
  , color Color.blue900
  , margin (Margin 0 10 0 0)
  , onClick push (const ClickRemoveAlternateNumber)
  ]<> FontStyle.body1 TypoGraphy
  )
]

enterOtpExceededModal :: forall w . (Action -> Effect Unit) -> ST.DriverDetailsScreenState -> PrestoDOM (Effect Unit) w
enterOtpExceededModal push state =
  PopUpModal.view (push <<< PopUpModalActions)  (enterOtpExceededModalStateConfig state)

enterMobileNumberModal :: forall w . (Action -> Effect Unit) -> ST.DriverDetailsScreenState -> PrestoDOM (Effect Unit) w
enterMobileNumberModal push state =
  InAppKeyboardModal.view (push <<< InAppKeyboardModalMobile)  (enterMobileNumberState state)

enterOtpModal :: forall w . (Action -> Effect Unit) -> ST.DriverDetailsScreenState -> PrestoDOM (Effect Unit) w
enterOtpModal push state =
  InAppKeyboardModal.view (push <<< InAppKeyboardModalOtp) (enterOtpState state)



addAlternateNumber :: forall w . (Action -> Effect Unit) -> ST.DriverDetailsScreenState -> PrestoDOM (Effect Unit) w
addAlternateNumber push state =
  linearLayout
    [ height WRAP_CONTENT
    , width WRAP_CONTENT
    , orientation VERTICAL
    , onClick push (const ClickAddAlternateButton)
    ][  textView
        [
          width WRAP_CONTENT
        , height WRAP_CONTENT
        , text (getString ADD_ALTERNATE_NUMBER)
        , textSize FontSize.a_14
        , fontStyle $ FontStyle.medium LanguageStyle
        , color Color.blue900
        , margin (Margin 0 8 0 20)
        ]
        ]

removeAlternateNumber :: forall w . (Action -> Effect Unit) -> ST.DriverDetailsScreenState -> PrestoDOM (Effect Unit) w
removeAlternateNumber push state =
  PopUpModal.view (push <<< PopUpModalAction) (removeAlternateNumberConfig state)



--------------------------------- horizontalLineView and dummyTextView -------------------

horizontalLineView :: Int -> Int -> forall w . PrestoDOM (Effect Unit) w
horizontalLineView marginLeft marginRight = 
 linearLayout
  [ width MATCH_PARENT
  , height $ V 1
  , background Color.greyLight
  , margin (Margin marginLeft 0 marginRight 0)
  ][]

dummyTextView :: forall w . PrestoDOM (Effect Unit) w
dummyTextView = 
 textView
 [ width WRAP_CONTENT
 , height WRAP_CONTENT
 ]