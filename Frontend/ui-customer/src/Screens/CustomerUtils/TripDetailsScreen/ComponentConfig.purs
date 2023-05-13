{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Screens.CustomerUtils.TripDetailsScreen.ComponentConfig where

import Components.PopUpModal as PopUpModal
import Components.PrimaryButton as PrimaryButton
import Language.Types (STR(..))
import Language.Strings (getString)
import PrestoDOM (Length(..), Margin(..), Padding(..), Visibility(..))
import Prelude (Unit, const, map, ($), (&&), (/=), (<<<), (<=), (<>), (==), (||))
import Screens.Types as ST
import Font.Size as FontSize
import Font.Style as FontStyle
import Components.GenericHeader as GenericHeader
import Components.SourceToDestination as SourceToDestination
import Styles.Colors as Color
import Common.Types.App
import Helpers.Utils (getAssetStoreLink, getCommonAssetStoreLink)
import Prelude ((<>))

genericHeaderConfig :: ST.TripDetailsScreenState -> GenericHeader.Config 
genericHeaderConfig state= let 
  config = GenericHeader.config
  genericHeaderConfig' = config 
    {
      height = WRAP_CONTENT
     , prefixImageConfig {
        height = V 25
      , width = V 25
      , imageUrl = "ny_ic_chevron_left," <> (getCommonAssetStoreLink FunctionCall) <> "/ny_ic_chevron_left.png"
      , margin = (Margin 12 12 12 12)
      , visibility = if state.props.issueReported then GONE else VISIBLE
      }
    , textConfig {
        text = if state.props.issueReported then "" else (getString RIDE_DETAILS)
      , textSize = FontSize.a_18
      , color = Color.darkDescriptionText
      , fontStyle = FontStyle.bold LanguageStyle
      }
    , suffixImageConfig {
        visibility = GONE
      }
    , padding = (Padding 0 5 0 5)
    }
  in genericHeaderConfig'
  
confirmLostAndFoundConfig :: ST.TripDetailsScreenState ->  PopUpModal.Config 
confirmLostAndFoundConfig state = let 
    config' = PopUpModal.config 
    popUpConfig' = config' {
      primaryText { text = (getString LOST_SOMETHING)},
      secondaryText {
        text = (getString TRY_CONNECTING_WITH_THE_DRIVER)
      , margin = (Margin 0 4 0 20)}
      , option1 { 
          background = state.data.config.primaryTextColor
        , strokeColor = state.data.config.primaryBackground
        , color = state.data.config.primaryBackground
        , text = (getString CANCEL_)
        }
      , option2 { 
          color = state.data.config.primaryTextColor
        , strokeColor = state.data.config.primaryBackground
        , background = state.data.config.primaryBackground
        , text = (getString REQUEST_CALLBACK)
        , margin = MarginLeft 12
        }
    }
    in popUpConfig'

sourceToDestinationConfig :: ST.TripDetailsScreenState -> SourceToDestination.Config
sourceToDestinationConfig state = let 
  config = SourceToDestination.config
  sourceToDestinationConfig' = config
    {
      margin = (Margin 0 0 0 0)
    , sourceMargin = (Margin 0 0 0 25)
    , lineMargin = (Margin 4 4 0 0)
    , sourceImageConfig {
        imageUrl = "ny_ic_green_circle," <> (getCommonAssetStoreLink FunctionCall) <> "/ny_ic_green_circle.png"
      , margin = (MarginTop 3)
      }
    , sourceTextConfig {
        text = state.data.source
      , textSize = FontSize.a_12
      , padding = (Padding 2 0 2 2)
      , margin = (Margin 12 0 15 0)
      , fontStyle = FontStyle.regular LanguageStyle
      , color = Color.greyDavy
      , ellipsize = false
      }
    , destinationImageConfig {
        imageUrl = "ny_ic_red_circle," <> (getCommonAssetStoreLink FunctionCall) <> "/ny_ic_red_circle.png"
      , margin = (MarginTop 3)
      }
    , destinationBackground = Color.blue600
    , destinationTextConfig {
        text = state.data.destination
      , textSize = FontSize.a_12
      , padding = (Padding 2 0 2 2)
      , margin = (Margin 12 0 15 0)
      , fontStyle = FontStyle.regular LanguageStyle
      , color = Color.greyDavy
      , ellipsize = false
      }
    }
  in sourceToDestinationConfig'

primaryButtonConfig :: ST.TripDetailsScreenState -> PrimaryButton.Config
primaryButtonConfig state = let 
    config = PrimaryButton.config
    primaryButtonConfig' = config 
      { textConfig { 
          text = if state.props.issueReported then (getString GO_HOME_) else (getString SUBMIT)
        , color = state.data.config.primaryTextColor
        , fontStyle = FontStyle.bold LanguageStyle
        , textSize = FontSize.a_16
        }
      , height = V 48
      , width = MATCH_PARENT
      , background = state.data.config.primaryBackground
      , alpha = if (state.props.activateSubmit || state.props.issueReported)  then 1.0 else 0.5 
      , isClickable = (state.props.activateSubmit || state.props.issueReported) 
      , margin = (Margin 16 0 16 16 ) 
      }
  in primaryButtonConfig'
