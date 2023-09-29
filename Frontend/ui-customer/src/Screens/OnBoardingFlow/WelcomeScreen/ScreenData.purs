module Screens.OnBoardingFlow.WelcomeScreen.ScreenData where

import Screens.Types (WelcomeScreenState)
import Foreign.Object (empty)

initData :: WelcomeScreenState
initData = {
  data : {
    carouselModel : [
      -- {image : "carousel_1", title : "The fastest auto booking\napp is here!", description : "Our speedy booking process means\nyou get a ride quickly and easily."},
      -- {image : "carousel_2", title : "No more\nsurge pricing!", description : "Experience fair and consistent fares,\neven during peak hours."},
      -- {image : "carousel_4", title : "Inclusive and accessible for everyone!", description : "We strive to provide all our users an \n even & equal experience."},
      -- {image : "carousel_3", title : "Be a part of the Open\nMobility Revolution!", description : "Our data and product roadmap are\ntransparent for all."}
      {image : "carousel_1", title : "The fastest auto booking\napp is here!", description : "Our speedy booking process means\nyou get a ride quickly and easily.", viewId : ""},
      {image : "carousel_2", title : "No more\nsurge pricing!", description : "Experience fair and consistent fares,\neven during peak hours.", viewId : ""},
      {image : "carousel_3", title : "Be a part of the Open\nMobility Revolution!", description : "Our data and product roadmap are\ntransparent for all.", viewId : ""}
    ],
    logField : empty
  }
}