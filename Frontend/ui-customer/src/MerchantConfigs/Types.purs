module MerchantConfig.Types where
import Prelude
import Styles.Types (FontType)

type AppConfig =
  {
    primaryTextColor :: String,
    primaryBackground :: String,
    searchLocationTheme :: String,
    estimateConfirmText :: String,
    autoConfirmingLoaderColor :: String,
    quoteListModelBackground :: String,
    quoteListModel :: QuoteListConfig,
    profileBackground :: String,
    profileName :: String,
    profileImage :: String,
    profileCompletion :: String,
    feedbackBackground :: String,
    sideBarList :: Array String,
    rateCardColor :: String,
    nyBrandingVisibility :: Boolean,
    fontType :: String,
    languageList :: Array Language,
    confirmPickUpLocationBorder ::String,
    bannerConfig :: BannerViewState,
    popupBackground :: String,
    cancelRideColor :: String,
    infoIconUrl :: String,
    profileEditGravity :: String,
    merchantLogo :: String,
    logs :: Array String,
    showCorporateAddress :: Boolean,
    terminateBtnConfig :: TerminateBtnConfig,
    showDeleteAccount :: Boolean
  } 

type QuoteListConfig = {
  backgroundColor :: String,
  textColor :: String,
  loaderColor :: String,
  otpTextBackground :: String,
  otpBackground :: String,
  otpTextColor :: String,
  otpTitleColor :: String
}

type Language =  {
  name :: String,
  value :: String,
  subTitle :: String
 }

type BannerViewState = {
  backgroundColor :: String,
  title :: String,
  titleColor :: String,
  actionText :: String,
  actionTextColor :: String,
  imageUrl :: String
}
type TerminateBtnConfig = {
    visibility :: Boolean, 
    title :: String,
    imageUrl :: String
}