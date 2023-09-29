{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.CustomerUtils.RideSelectionScreen.ComponentConfig where

import Common.Types.App
import Components.PrimaryButton as PrimaryButton
import Components.ErrorModal as ErrorModal
import Components.GenericHeader as GenericHeader
import Screens.RideSelectionScreen.Controller (getTitle)
import Language.Strings (getString)
import Language.Types (STR(..))
import PrestoDOM (Length(..), Margin(..), Padding(..), Visibility(..))
import Screens.Types as ST
import Styles.Colors as Color
import Storage as Storage
import Prelude ((<>))
import Helpers.Utils (getAssetStoreLink, getCommonAssetStoreLink)
import Common.Types.App (LazyCheck(..))

apiErrorModalConfig :: ST.RideSelectionScreenState -> ErrorModal.Config 
apiErrorModalConfig state = let 
  config = ErrorModal.config 
  errorModalConfig' = config 
    { imageConfig {
        imageUrl = "ny_ic_error_404," <> (getAssetStoreLink FunctionCall) <> "ny_ic_error_404.png"
      , height = V 110
      , width = V 124
      , margin = (MarginBottom 32)
      }
    , errorConfig {
        text = (getString ERROR_404)
      , margin = (MarginBottom 7)  
      , color = Color.black800
      }
    , errorDescriptionConfig {
        text = (getString PROBLEM_AT_OUR_END)
      , color = Color.black700
      , margin = (Margin 16 0 16 0)
      }
    , buttonConfig {
        text = (getString NOTIFY_ME)
      , margin = (Margin 16 0 16 16)
      , background = state.data.config.primaryBackground
      , color = state.data.config.primaryTextColor
      }
    }
  in errorModalConfig' 

errorModalConfig :: ST.RideSelectionScreenState -> ErrorModal.Config 
errorModalConfig state = let 
  config = ErrorModal.config 
  errorModalConfig' = config 
    { imageConfig {
        imageUrl = "ny_ic_no_past_rides," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_no_past_rides.png"
      , height = V 110
      , width = V 124
      , margin = (MarginBottom 32)
      }
    , errorConfig {
        text = (getString EMPTY_RIDES)
      , margin = (MarginBottom 7)  
      , color = Color.black800
      }
    , errorDescriptionConfig {
        text = (getString YOU_HAVENT_TAKEN_A_TRIP_YET)
      , color = Color.black700
      }
    , buttonConfig {
       visibility = GONE
      }
    }
  in errorModalConfig' 

genericHeaderConfig :: ST.RideSelectionScreenState -> GenericHeader.Config 
genericHeaderConfig state = let 
  config = GenericHeader.config
  genericHeaderConfig' = config 
    {
      height = WRAP_CONTENT
    , prefixImageConfig {
        height = V 25
      , width = V 25
      , imageUrl = "ny_ic_chevron_left," <> (getCommonAssetStoreLink FunctionCall) <> "ny_ic_chevron_left.png"
      } 
    , textConfig {
        text = (getTitle state.selectedCategory.categoryLabel)
      , color = Color.darkDescriptionText
      }
    , suffixImageConfig {
        visibility = GONE
      }
    }
  in genericHeaderConfig'

cancelButtonConfig :: ST.RideSelectionScreenState -> PrimaryButton.Config
cancelButtonConfig state = let
  config = PrimaryButton.config
  primaryButtonConfig' = config
    { textConfig
      { text     = getString I_DONT_KNOW_WHICH_RIDE
      , color    = Color.black700
      }
    , background = Color.grey700
    , height     = (V 60)
    , isClickable  = true
    , cornerRadius= 0.0
    , margin = (Margin 0 0 0 0)
    , id = "cancelButtonConfig"
    }
  in primaryButtonConfig'