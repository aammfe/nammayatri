module Engineering.Helpers.Utils where

import Prelude

import Data.Maybe (Maybe(..))
import Effect.Aff (launchAff)
import Effect.Class (liftEffect)
import Engineering.Helpers.Commons (flowRunner, liftFlow)
import LoaderOverlay.Handler as UI
import Presto.Core.Types.Language.Flow (Flow, doAff, getState, modifyState)
import PrestoDOM.Core (terminateUI)
import Types.App (GlobalState(..))
import Debug (spy)
import Engineering.Helpers.Commons (os)
import Effect (Effect (..))
import Effect.Uncurried (EffectFn2(..), runEffectFn2, EffectFn1(..), runEffectFn1)
import Data.String (length)
import Data.String.CodeUnits (charAt)
import Common.Types.App (MobileNumberValidatorResp(..))

foreign import toggleLoaderIOS :: EffectFn1 Boolean Unit

foreign import loaderTextIOS :: EffectFn2 String String Unit

toggleLoader :: Boolean -> Flow GlobalState Unit
toggleLoader flag = do
  _ <- pure $ spy "toggleLoader" "toggleLoader"
  if os == "IOS" then do
    _ <- pure $ spy "toggleLoader" "toggleLoader"
    _ <- liftFlow $ runEffectFn1 toggleLoaderIOS flag
    pure unit
    else if flag then do
      state <- getState
      _ <- liftFlow $ launchAff $ flowRunner state UI.loaderScreen
      pure unit
      else do
        doAff $ liftEffect $ terminateUI $ Just "LoaderOverlay"

loaderText :: String -> String -> Flow GlobalState Unit
loaderText mainTxt subTxt = do
  _ <- pure $ spy "loaderText" "loaderText"
  if os == "IOS" then do
    _ <- pure $ spy "loaderText" "loaderText"
    _ <- liftFlow $ runEffectFn2 loaderTextIOS mainTxt subTxt
    pure unit
    else do 
      _ <- modifyState (\(GlobalState state) -> GlobalState state{loaderOverlay{data{title = mainTxt, subTitle = subTxt}}})
      pure unit

mobileNumberValidator :: String -> String -> String -> MobileNumberValidatorResp 
mobileNumberValidator country countryShortCode mobileNumber = 
  let len = length mobileNumber
      maxLen = mobileNumberMaxLength countryShortCode
  in if len <=  maxLen then 
      case countryShortCode of 
        "IN" -> case (charAt 0 mobileNumber) of
                  Just a -> if a=='0' || a=='1' || a=='2' || a=='3' || a=='4' then Invalid
                            else if a=='5' then if mobileNumber=="5000500050" then Valid else Invalid
                                 else if len == maxLen then Valid else ValidPrefix 
                  Nothing -> ValidPrefix 
        "FR" -> case (charAt 0 mobileNumber) of 
                  Just a -> if a == '6' || a == '7' then if len == maxLen then Valid else ValidPrefix
                            else Invalid 
                  Nothing -> ValidPrefix
        "BD" -> case (charAt 0 mobileNumber) of 
                  Just a -> if a == '1' then if len == maxLen then Valid else ValidPrefix 
                            else Invalid
                  Nothing -> ValidPrefix
        _ -> Invalid
    else MaxLengthExceeded

mobileNumberMaxLength :: String -> Int 
mobileNumberMaxLength countryShortCode = 
  case countryShortCode of 
    "IN" -> 10
    "FR" -> 9 
    "BD" -> 10
    _ -> 0
