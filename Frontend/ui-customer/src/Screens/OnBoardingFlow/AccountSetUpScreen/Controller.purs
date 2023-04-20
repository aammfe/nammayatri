{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.AccountSetUpScreen.Controller where

import Components.GenericHeader as GenericHeaderController
import Components.PopUpModal as PopUpModal
import Components.PrimaryButton as PrimaryButtonController
import Components.MenuButton as MenuButtonController
import Components.PrimaryEditText as PrimaryEditTextController
import Data.String (length, trim)
import JBridge (hideKeyboardOnNavigation)
import Log (trackAppActionClick, trackAppEndScreen, trackAppScreenRender, trackAppBackPress, trackAppTextInput, trackAppScreenEvent)
import Prelude (class Show, bind, discard, pure, unit, not, ($), (/=), (&&), (>=))
import PrestoDOM (Eval, continue, continueWithCmd, exit, updateAndExit)
import PrestoDOM.Types.Core (class Loggable)
import Screens (ScreenName(..), getScreen)
import Screens.Types (AccountSetUpScreenState, Gender(..))
import Engineering.Helpers.Commons(getNewIDWithTag)
import Data.Maybe(Maybe(..))

instance showAction :: Show Action where
  show _ = ""

instance loggableAction :: Loggable Action where
  performLog action appId  = case action of
    AfterRender -> trackAppScreenRender appId "screen" (getScreen ACCOUNT_SET_UP_SCREEN)
    BackPressed -> do
      trackAppBackPress appId (getScreen ACCOUNT_SET_UP_SCREEN)
      trackAppEndScreen appId (getScreen ACCOUNT_SET_UP_SCREEN)
    PrimaryButtonActionController act -> case act of
      PrimaryButtonController.OnClick -> do
        trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "primary_button_action" "continue"
      PrimaryButtonController.NoAction -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "primary_button" "no_action"
    NameEditTextActionController (PrimaryEditTextController.TextChanged id value) -> trackAppTextInput appId (getScreen ACCOUNT_SET_UP_SCREEN) "name_edit_text_changed" "primary_edit_text"
    GenericHeaderActionController act -> case act of
      GenericHeaderController.PrefixImgOnClick -> do
        trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "generic_header_action" "back_icon"
        trackAppEndScreen appId (getScreen ACCOUNT_SET_UP_SCREEN)
      GenericHeaderController.SuffixImgOnClick -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "generic_header_action" "forward_icon"
    PopUpModalAction act -> case act of
      PopUpModal.OnButton1Click -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "on_goback"
      PopUpModal.OnButton2Click -> do
        trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "register_on_different_number"
        trackAppEndScreen appId (getScreen ACCOUNT_SET_UP_SCREEN)
      PopUpModal.NoAction -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "no_action"
      PopUpModal.OnImageClick -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "image"
      PopUpModal.ETextController act -> trackAppTextInput appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "primary_edit_text"
      PopUpModal.CountDown arg1 arg2 arg3 arg4 -> trackAppScreenEvent appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "countdown_updated"
      PopUpModal.Tipbtnclick arg1 arg2 -> trackAppScreenEvent appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "tip_clicked"
      PopUpModal.DismissPopup -> trackAppScreenEvent appId (getScreen ACCOUNT_SET_UP_SCREEN) "popup_modal_action" "popup_dismissed"
    ShowOptions -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "in_screen" "show_options"
    EditTextFocusChanged -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "name_edit_text_focus_changed" "edit_text"
    TextChanged value -> trackAppTextInput appId (getScreen ACCOUNT_SET_UP_SCREEN) "name_text_changed" "edit_text"
    GenderSelected value -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "gender_selected" "edit_text"
    AnimationEnd _ -> trackAppActionClick appId (getScreen ACCOUNT_SET_UP_SCREEN) "show_options" "animation_end"
      


data ScreenOutput
  = GoHome AccountSetUpScreenState
  | ChangeMobileNumber

data Action
  = BackPressed
  | PrimaryButtonActionController PrimaryButtonController.Action
  | NameEditTextActionController PrimaryEditTextController.Action
  | GenericHeaderActionController GenericHeaderController.Action
  | PopUpModalAction PopUpModal.Action
  | ShowOptions
  | EditTextFocusChanged
  | TextChanged String
  | GenderSelected Gender
  | AfterRender
  | AnimationEnd String

eval :: Action -> AccountSetUpScreenState -> Eval Action ScreenOutput AccountSetUpScreenState
eval (PrimaryButtonActionController PrimaryButtonController.OnClick) state = do
  _ <- pure $ hideKeyboardOnNavigation true
  updateAndExit state $ GoHome state

eval (GenericHeaderActionController (GenericHeaderController.PrefixImgOnClick)) state =
  continueWithCmd state
    [ do
        pure $ BackPressed
    ]

eval EditTextFocusChanged state = continue state {props{genderOptionExpanded = false}}

eval (GenderSelected value) state = continue state{data{gender = Just value}, props{genderOptionExpanded = false, btnActive = (state.data.name /= "") && (length state.data.name >= 3) }}

eval (TextChanged value) state = do
  let
    newState = state { data { name = trim value } }
  continue newState { props { expandEnabled = false, genderOptionExpanded = false, btnActive = (newState.data.name /= "") && (length newState.data.name >= 3) && (newState.data.gender /= Nothing)} }

eval (ShowOptions) state = do
  _ <- pure $ hideKeyboardOnNavigation true
  continue state{props{genderOptionExpanded = not state.props.genderOptionExpanded, expandEnabled = true}}

eval (AnimationEnd _)  state = continue state{props{showOptions = false}}

eval BackPressed state = do
  _ <- pure $ hideKeyboardOnNavigation true
  continue state { props { backPressed = true } }

eval (PopUpModalAction (PopUpModal.OnButton1Click)) state = continue state { props { backPressed = false } }

eval (PopUpModalAction (PopUpModal.OnButton2Click)) state = exit $ ChangeMobileNumber

eval _ state = continue state

