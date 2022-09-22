{-# LANGUAGE AllowAmbiguousTypes #-}

module Tools.Auth.Common (verifyPerson, cleanCachedTokens, cleanCachedTokensByServerName, AuthFlow) where

import Beckn.Prelude
import qualified Beckn.Storage.Esqueleto as Esq
import qualified Beckn.Storage.Redis.Queries as Redis
import Beckn.Types.App
import Beckn.Types.Error
import Beckn.Types.Id
import Beckn.Utils.Common
import qualified Beckn.Utils.Common as Utils
import qualified Domain.Types.Person as DP
import qualified Domain.Types.RegistrationToken as DR
import qualified Storage.Queries.RegistrationToken as QR
import qualified Storage.Queries.ServerAccess as QServer

type AuthFlow m r =
  ( EsqDBFlow m r,
    HasFlowEnv m r ["authTokenCacheExpiry" ::: Seconds, "registrationTokenExpiry" ::: Days],
    HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text]
  )

verifyPerson ::
  AuthFlow m r =>
  RegToken ->
  m (Id DP.Person, DR.ServerName)
verifyPerson token = do
  key <- authTokenCacheKey token
  authTokenCacheExpiry <- getSeconds <$> asks (.authTokenCacheExpiry)
  mbTuple <- getKeyRedis key
  (personId, serverName) <- case mbTuple of
    Just (personId, serverName) -> return (personId, serverName)
    Nothing -> do
      sr <- verifyToken token
      let personId = sr.personId
      let serverName = sr.serverName
      setExRedis key (personId, serverName) authTokenCacheExpiry
      return (personId, serverName)
  return (personId, serverName)

getKeyRedis :: (MonadFlow m, MonadThrow m, Log m) => Text -> m (Maybe (Id DP.Person, DR.ServerName))
getKeyRedis = Redis.getKeyRedis

setExRedis :: (MonadFlow m, MonadThrow m, Log m) => Text -> (Id DP.Person, DR.ServerName) -> Int -> m ()
setExRedis = Redis.setExRedis

authTokenCacheKey ::
  HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text] =>
  RegToken ->
  m Text
authTokenCacheKey regToken = do
  authTokenCacheKeyPrefix <- asks (.authTokenCacheKeyPrefix)
  pure $ authTokenCacheKeyPrefix <> regToken

verifyToken ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["registrationTokenExpiry" ::: Days]
  ) =>
  RegToken ->
  m DR.RegistrationToken
verifyToken regToken = do
  QR.findByToken regToken
    >>= Utils.fromMaybeM (InvalidToken regToken)
    >>= validateToken

validateToken ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["registrationTokenExpiry" ::: Days]
  ) =>
  DR.RegistrationToken ->
  m DR.RegistrationToken
validateToken sr = do
  registrationTokenExpiry <- asks (.registrationTokenExpiry)
  let nominal = realToFrac . daysToSeconds $ registrationTokenExpiry
  expired <- Utils.isExpired nominal sr.createdAt
  when expired $ do
    Esq.runTransaction $
      QR.deleteById sr.id
    Utils.throwError TokenExpired
  mbServerAccess <- QServer.findByPersonIdAndServerName sr.personId sr.serverName
  when (isNothing mbServerAccess) $ do
    Esq.runTransaction $
      QR.deleteById sr.id
    Utils.throwError AccessDenied
  return sr

cleanCachedTokens ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text]
  ) =>
  Id DP.Person ->
  m ()
cleanCachedTokens personId = do
  regTokens <- QR.findAllByPersonId personId
  for_ regTokens $ \regToken -> do
    key <- authTokenCacheKey regToken.token
    void $ Redis.deleteKeyRedis key

cleanCachedTokensByServerName ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text]
  ) =>
  Id DP.Person ->
  DR.ServerName ->
  m ()
cleanCachedTokensByServerName personId serverName = do
  regTokens <- QR.findAllByPersonIdAndServerName personId serverName
  for_ regTokens $ \regToken -> do
    key <- authTokenCacheKey regToken.token
    void $ Redis.deleteKeyRedis key
