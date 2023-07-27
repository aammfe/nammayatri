{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.DriverProfileScreen.ComponentConfig where

import Components.PopUpModal as PopUpModal
import Components.GenericHeader as GenericHeader
import Components.PrimaryEditText as PrimaryEditText
import Components.CheckListView as CheckListView
import Screens.DriverProfileScreen.Controller
import Language.Strings
import Language.Types (STR(..))
import PrestoDOM
import Screens.Types as ST
import Font.Size as FontSize
import Font.Style as FontStyle
import Styles.Colors as Color
import Common.Types.App (LazyCheck(..))
import Data.Maybe(fromMaybe, Maybe(..), isJust)
import Components.PrimaryButton as PrimaryButton
import Components.PrimaryEditText as PrimaryEditText
import Prelude ((<>), (||),(&&),(==),(<), not)
import Engineering.Helpers.Commons as EHC
import Data.String (length)
import Components.InAppKeyboardModal.View as InAppKeyboardModal
import Components.InAppKeyboardModal.Controller as InAppKeyboardModalController

logoutPopUp :: ST.DriverProfileScreenState -> PopUpModal.Config
logoutPopUp  state = let 
  config' = PopUpModal.config
  popUpConfig' = config' {
    primaryText {text = (getString LOGOUT)},
    secondaryText {text = (getString ARE_YOU_SURE_YOU_WANT_TO_LOGOUT)},
    option1 {text = (getString GO_BACK)},
    option2 {text = (getString LOGOUT)}
  }
  in popUpConfig'

genericHeaderConfig :: ST.DriverProfileScreenState -> GenericHeader.Config 
genericHeaderConfig state = let 
  config = GenericHeader.config
  genericHeaderConfig' = config 
    {
      height = WRAP_CONTENT
    , prefixImageConfig {
       visibility = VISIBLE
      , imageUrl = "ny_ic_chevron_left,https://assets.juspay.in/nammayatri/images/common/ny_ic_chevron_left.png"
      , height = (V 25)
      , width = (V 25)
      , margin = (Margin 16 16 16 16)
      } 
    , padding = (PaddingVertical 5 5)
    , textConfig {
        text = "Settings"
      , textSize = FontSize.a_18
      , color = Color.darkDescriptionText
      , fontStyle = FontStyle.bold LanguageStyle
      }
    , suffixImageConfig {
        visibility = GONE
      }
    }
  in genericHeaderConfig'

primaryEditTextConfig :: ST.DriverProfileScreenState -> PrimaryEditText.Config
primaryEditTextConfig state = let 
  config = PrimaryEditText.config
  primaryEditTextConfig' = config
    { editText
      { singleLine = true
        , pattern = Just "[0-9]*,10"
        , fontStyle = FontStyle.medium LanguageStyle
        , textSize = FontSize.a_16
        , text = ""
        , placeholder = ""
      }
    , topLabel
      { textSize = FontSize.a_14
      , text = ""
      , color = Color.greyTextColor
      }
    }
  in primaryEditTextConfig'

driverGenericHeaderConfig :: ST.DriverProfileScreenState -> GenericHeader.Config 
driverGenericHeaderConfig state = let 
  config = GenericHeader.config
  genericHeaderConfig' = config 
    {
      height = WRAP_CONTENT
    , prefixImageConfig {
        height = V 25
      , width = V 25
      , imageUrl = "ny_ic_chevron_left,https://assets.juspay.in/beckn/nammayatri/nammayatricommon/images/ny_ic_chevron_left.png"
      , margin = Margin 12 12 12 12
      } 
    , padding = PaddingVertical 5 5
    , textConfig {
        text = if state.props.showGenderView then getString GENDER else getString ALTERNATE_NUMBER
      , textSize = FontSize.a_18
      , color = Color.black900
      , fontStyle = FontStyle.bold LanguageStyle
      }
    }
  in genericHeaderConfig'

primaryButtonConfig :: ST.DriverProfileScreenState -> PrimaryButton.Config
primaryButtonConfig state = let 
    config = PrimaryButton.config
    primaryButtonConfig' = config 
      { textConfig
      { text = getString UPDATE
      , color = Color.primaryButtonColor
      , textSize = FontSize.a_18}
      , margin = MarginHorizontal 10 10
      , cornerRadius = 10.0
      , background = Color.black900
      , height = (V 48)
      , isClickable = (state.props.showGenderView && isJust state.data.genderTypeSelect) || (state.props.alternateNumberView && (length (fromMaybe "" state.data.driverEditAlternateMobile))==10 && state.props.checkAlternateNumber)
      , alpha = if (state.props.showGenderView && isJust state.data.genderTypeSelect) || (state.props.alternateNumberView && length(fromMaybe "" state.data.driverEditAlternateMobile)==10 && state.props.checkAlternateNumber) then 1.0 else 0.7
      }
  in primaryButtonConfig'

alternatePrimaryEditTextConfig :: ST.DriverProfileScreenState -> PrimaryEditText.Config
alternatePrimaryEditTextConfig state = let 
    config = PrimaryEditText.config
    primaryEditTextConfig' = config
      { editText
        { singleLine = true
          , pattern = Just "[0-9]*,10"
          , fontStyle = FontStyle.bold LanguageStyle
          , textSize = FontSize.a_16
          , color = Color.black800
          , margin = MarginHorizontal 10 10
          , focused = state.props.mNumberEdtFocused
        }
      , showConstantField = true
      , topLabel
        { textSize = FontSize.a_14
        , text = ""
        , color = Color.black800
        , visibility = GONE
        }
      , type = "number"
      , errorLabel 
        { text = if state.props.numberExistError then getString NUMBER_ALREADY_EXIST_ERROR else getString PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER
        , fontStyle = FontStyle.medium LanguageStyle
        , margin = MarginTop 1
        }
      , constantField { 
          color = if state.props.mNumberEdtFocused then Color.black800 else Color.grey900 
        , textSize = FontSize.a_16
        , padding = PaddingBottom 1
        }
      , showErrorLabel = not state.props.checkAlternateNumber || state.props.numberExistError
      , margin = Margin 10 10 10 0
      , background = Color.white900
      , id = EHC.getNewIDWithTag "alternateMobileNumber"
      }
    in primaryEditTextConfig'

removeAlternateNumberConfig :: ST.DriverProfileScreenState -> PopUpModal.Config
removeAlternateNumberConfig state = let
    config = PopUpModal.config
    popUpConfig' = config {
      gravity = BOTTOM,
      primaryText {
        text = getString REMOVE_ALTERNATE_NUMBER
      , margin = Margin 16 24 16 0
      },
      secondaryText {
        text = getString ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER
      , color = Color.black700
      , margin = Margin 16 12 16 40
        },
      option1 {
        text = getString CANCEL
      , fontSize = FontSize.a_16
      , color = Color.black900
      , strokeColor = Color.black700
      , fontStyle = FontStyle.semiBold LanguageStyle
      },
      option2 {
        text = getString YES_REMOVE_IT
      , background = Color.red
      , color = Color.white900
      , strokeColor = Color.red
      , fontSize = FontSize.a_16
      , margin = MarginLeft 12
      , fontStyle = FontStyle.semiBold LanguageStyle }
    }
  in popUpConfig'

enterOtpState :: ST.DriverProfileScreenState -> InAppKeyboardModalController.InAppKeyboardModalState
enterOtpState state = let
      config' = InAppKeyboardModalController.config
      inAppModalConfig' = config'{
        modalType = if state.props.otpAttemptsExceeded then ST.NONE else ST.OTP
      , showResendOtpButton = true 
      , otpIncorrect = if state.props.otpAttemptsExceeded then false else state.props.otpIncorrect
      , otpAttemptsExceeded = state.props.otpAttemptsExceeded
      , inputTextConfig {
        text = state.props.alternateMobileOtp
      , fontSize = FontSize.a_22
      , focusIndex = state.props.enterOtpFocusIndex
      },
      headingConfig {
        text = getString ENTER_OTP
      },
      errorConfig {
        text = if state.props.otpIncorrect then getString WRONG_OTP else ""
      , visibility = if state.props.otpIncorrect || state.props.otpAttemptsExceeded then VISIBLE else GONE
      , margin = MarginBottom 8
      },
      subHeadingConfig {
        text = getString OTP_SENT_TO <> fromMaybe "" state.data.driverEditAlternateMobile
      , color = Color.black800
      , fontSize = FontSize.a_14
      , margin = MarginBottom 8
      , visibility = if state.props.otpIncorrect == false then VISIBLE else GONE
      },
      imageConfig {
          alpha = if length state.props.alternateMobileOtp < 4 || state.props.otpIncorrect then 0.3 else 1.0
      }
      }
      in inAppModalConfig'
checkListConfig :: ST.DriverProfileScreenState -> CheckListView.Config
checkListConfig state = let
  config = CheckListView.config
  checkListConfig' = config
    {
        optionsProvided = state.data.languageList
        , isSelected = false
        , index = 0
    }
 in checkListConfig'


primaryButtonConfig1 :: ST.DriverProfileScreenState -> PrimaryButton.Config
primaryButtonConfig1 state = let
    config = PrimaryButton.config
    primaryButtonConfig' = config
      { textConfig
      { text = (getString UPDATE)
      , color = Color.primaryButtonColor
      , textSize = FontSize.a_18}
      , margin = (Margin 10 0 10 0)
      , cornerRadius = 10.0
      , background = Color.black900
      , height = (V 48)
      -- , isClickable = state.props.deleteButtonVisibility
      , alpha = 1.0
      }
  in primaryButtonConfig'
