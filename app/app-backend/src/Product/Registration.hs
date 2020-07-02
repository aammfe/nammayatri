{-# LANGUAGE OverloadedLabels #-}

module Product.Registration where

import qualified Beckn.External.MyValueFirst.Flow as SF
import qualified Beckn.External.MyValueFirst.Types as SMS
import Beckn.Types.App
import qualified Beckn.Types.Common as BC
import qualified Beckn.Types.Storage.Person as SP
import qualified Beckn.Types.Storage.RegistrationToken as SR
import Beckn.Utils.Common
import Beckn.Utils.Extra
import qualified Crypto.Number.Generate as Cryptonite
import qualified Data.Accessor as Lens
import Data.Aeson
import qualified Data.Map as Map
import qualified Data.Text as T
import qualified EulerHS.Language as L
import EulerHS.Prelude
import Servant
import qualified Storage.Queries.Person as Person
import qualified Storage.Queries.RegistrationToken as RegistrationToken
import System.Environment
import Types.API.Registration
import Types.App
import qualified Utils.Notifications as Notify

initiateLogin :: InitiateLoginReq -> FlowHandler InitiateLoginRes
initiateLogin req =
  withFlowHandler $ do
    case (req ^. #_medium, req ^. #__type) of
      (SR.SMS, SR.OTP) -> initiateFlow req
      _ -> L.throwException $ err400 {errBody = "UNSUPPORTED_MEDIUM_TYPE"}

initiateFlow :: InitiateLoginReq -> L.Flow InitiateLoginRes
initiateFlow req = do
  let mobileNumber = req ^. #_mobileNumber
      countryCode = req ^. #_mobileCountryCode
  person <-
    Person.findByRoleAndMobileNumber SP.USER SP.MOBILENUMBER countryCode mobileNumber
      >>= maybe (createPerson req) pure
  let entityId = _getPersonId . SP._id $ person
  useFakeOtpM <- L.runIO $ lookupEnv "USE_FAKE_SMS"
  regToken <- case useFakeOtpM of
    Just _ -> do
      token <- makeSession req entityId (T.pack <$> useFakeOtpM)
      RegistrationToken.create token
      return token
    Nothing -> do
      token <- makeSession req entityId Nothing
      RegistrationToken.create token
      sendOTP mobileNumber (SR._authValueHash token)
      return token
  let attempts = SR._attempts regToken
      tokenId = SR._id regToken
  Notify.notifyOnRegistration regToken person
  return $ InitiateLoginRes {attempts, tokenId}

makePerson :: InitiateLoginReq -> L.Flow SP.Person
makePerson req = do
  role <- fromMaybeM400 "CUSTOMER_ROLE required" (req ^. #_role)
  id <- BC.generateGUID
  now <- getCurrentTimeUTC
  return $
    SP.Person
      { _id = id,
        _firstName = Nothing,
        _middleName = Nothing,
        _lastName = Nothing,
        _fullName = Nothing,
        _role = role,
        _gender = SP.UNKNOWN,
        _identifierType = SP.MOBILENUMBER,
        _email = Nothing,
        _mobileNumber = Just $ req ^. #_mobileNumber,
        _mobileCountryCode = Just $ req ^. #_mobileCountryCode,
        _identifier = Nothing,
        _rating = Nothing,
        _verified = False,
        _status = SP.INACTIVE,
        _deviceToken = req ^. #_deviceToken,
        _udf1 = Nothing,
        _udf2 = Nothing,
        _organizationId = Nothing,
        _locationId = Nothing,
        _description = Nothing,
        _createdAt = now,
        _updatedAt = now
      }

makeSession ::
  InitiateLoginReq -> Text -> Maybe Text -> L.Flow SR.RegistrationToken
makeSession req entityId fakeOtp = do
  otp <- case fakeOtp of
    Just otp -> return otp
    Nothing -> generateOTPCode
  id <- L.generateGUID
  token <- L.generateGUID
  now <- getCurrentTimeUTC
  attempts <-
    L.runIO $ fromMaybe 3 . (>>= readMaybe) <$> lookupEnv "SMS_ATTEMPTS"
  authExpiry <-
    L.runIO $ fromMaybe 3 . (>>= readMaybe) <$> lookupEnv "AUTH_EXPIRY"
  tokenExpiry <-
    L.runIO $ fromMaybe 365 . (>>= readMaybe) <$> lookupEnv "TOKEN_EXPIRY"
  return $
    SR.RegistrationToken
      { _id = id,
        _token = token,
        _attempts = attempts,
        _authMedium = (req ^. #_medium),
        _authType = (req ^. #__type),
        _authValueHash = otp,
        _verified = False,
        _authExpiry = authExpiry,
        _tokenExpiry = tokenExpiry,
        _EntityId = entityId,
        _entityType = SR.USER,
        _createdAt = now,
        _updatedAt = now,
        _info = Nothing
      }

generateOTPCode :: L.Flow Text
generateOTPCode =
  L.runIO $ padLeft 4 '0' . show <$> Cryptonite.generateBetween 1 9999
  where
    padLeft n c txt =
      let prefix = replicate (max 0 $ n - length txt) c
       in T.pack prefix <> txt

sendOTP :: Text -> Text -> L.Flow ()
sendOTP phoneNumber otpCode = do
  username <- L.runIO $ getEnv "SMS_GATEWAY_USERNAME"
  password <- L.runIO $ getEnv "SMS_GATEWAY_PASSWORD"
  -- Note: AUTO_READ_OTP_HASH is generated from the frontend code base
  -- This is used for the Android's SMS Retriever API for auto-reading OTP
  otpHash <- L.runIO $ getEnv "AUTO_READ_OTP_HASH"
  res <-
    SF.submitSms
      SF.defaultBaseUrl
      SMS.SubmitSms
        { SMS._username = T.pack username,
          SMS._password = T.pack password,
          SMS._from = SMS.JUSPAY,
          SMS._to = phoneNumber,
          SMS._category = SMS.BULK,
          SMS._text = SF.constructOtpSms otpCode (T.pack otpHash)
        }
  whenLeft res $ \err -> L.throwException err503 {errBody = encode err}

login :: Text -> LoginReq -> FlowHandler LoginRes
login tokenId req =
  withFlowHandler $ do
    SR.RegistrationToken {..} <- getRegistrationTokenE tokenId
    when _verified $ L.throwException $ err400 {errBody = "ALREADY_VERIFIED"}
    checkForExpiry _authExpiry _updatedAt
    let isValid =
          _authMedium == req ^. #_medium
            && _authType == req ^. #__type
            && _authValueHash == req ^. #_hash
    if isValid
      then do
        person <- checkPersonExists _EntityId
        let personId = person ^. #_id
            updatedPerson =
              person
                { SP._status = SP.ACTIVE,
                  SP._deviceToken =
                    (req ^. #_deviceToken) <|> (person ^. #_deviceToken)
                }
        Person.updateMultiple personId updatedPerson
        Person.findById personId
          >>= fromMaybeM500 "Could not find user"
          >>= return . LoginRes _token . maskPerson
      else L.throwException $ err400 {errBody = "AUTH_VALUE_MISMATCH"}
  where
    checkForExpiry authExpiry updatedAt =
      whenM (isExpired (realToFrac (authExpiry * 60)) updatedAt)
        $ L.throwException
        $ err400 {errBody = "AUTH_EXPIRED"}

getRegistrationTokenE :: Text -> L.Flow SR.RegistrationToken
getRegistrationTokenE tokenId =
  RegistrationToken.findById tokenId >>= fromMaybeM400 "INVALID_TOKEN"

createPerson :: InitiateLoginReq -> L.Flow SP.Person
createPerson req = do
  person <- makePerson req
  Person.create person
  pure person

checkPersonExists :: Text -> L.Flow SP.Person
checkPersonExists _EntityId =
  Person.findById (PersonId _EntityId) >>= fromMaybeM400 "INVALID_DATA"

reInitiateLogin :: Text -> ReInitiateLoginReq -> FlowHandler InitiateLoginRes
reInitiateLogin tokenId req =
  withFlowHandler $ do
    SR.RegistrationToken {..} <- getRegistrationTokenE tokenId
    void $ checkPersonExists _EntityId
    if _attempts > 0
      then do
        sendOTP (req ^. #_mobileNumber) _authValueHash
        RegistrationToken.updateAttempts (_attempts - 1) _id
        return $ InitiateLoginRes tokenId (_attempts - 1)
      else L.throwException $ err400 {errBody = "LIMIT_EXCEEDED"}
