module Domain.Action.Dashboard.Person where

import Beckn.External.Encryption (decrypt, getDbHash)
import Beckn.Prelude
import Beckn.Storage.Esqueleto (Transactionable)
import qualified Beckn.Storage.Esqueleto as Esq
import qualified Beckn.Storage.Hedis as Redis
import Beckn.Types.APISuccess (APISuccess (..))
import Beckn.Types.Common
import Beckn.Types.Error
import Beckn.Types.Id
import Beckn.Utils.Common
import qualified Domain.Types.Merchant as DMerchant
import qualified Domain.Types.MerchantAccess as DAccess
import qualified Domain.Types.Person as DP
import qualified Domain.Types.Role as DRole
import qualified Storage.Queries.Merchant as QMerchant
import qualified Storage.Queries.MerchantAccess as QAccess
import qualified Storage.Queries.Person as QP
import qualified Storage.Queries.RegistrationToken as QReg
import qualified Storage.Queries.Role as QRole
import Tools.Auth
import qualified Tools.Auth.Common as Auth
import qualified Tools.Client as Client
import Tools.Error

newtype ListPersonRes = ListPersonRes
  {list :: [DP.PersonAPIEntity]}
  deriving (Generic, ToJSON, FromJSON, ToSchema)

newtype MerchantAccessReq = MerchantAccessReq
  {merchantId :: ShortId DMerchant.Merchant}
  deriving (Generic, ToJSON, FromJSON, ToSchema)

type MerchantAccessRes = MerchantAccessReq

data ChangePasswordReq = ChangePasswordReq
  { oldPassword :: Text,
    newPassword :: Text
  }
  deriving (Generic, ToJSON, FromJSON, ToSchema)

listPerson ::
  (EsqDBFlow m r, EncFlow m r) =>
  TokenInfo ->
  Maybe Text ->
  Maybe Integer ->
  Maybe Integer ->
  m ListPersonRes
listPerson _ mbSearchString mbLimit mbOffset = do
  personAndRoleList <- QP.findAllWithLimitOffset mbSearchString mbLimit mbOffset
  res <- forM personAndRoleList $ \(encPerson, role, merchantAccessList) -> do
    decPerson <- decrypt encPerson
    pure $ DP.makePersonAPIEntity decPerson role merchantAccessList
  pure $ ListPersonRes res

assignRole ::
  EsqDBFlow m r =>
  TokenInfo ->
  Id DP.Person ->
  Id DRole.Role ->
  m APISuccess
assignRole _ personId roleId = do
  _person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  _role <- QRole.findById roleId >>= fromMaybeM (RoleDoesNotExist roleId.getId)
  Esq.runTransaction $
    QP.updatePersonRole personId roleId
  pure Success

assignMerchantAccess ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["dataServers" ::: [Client.DataServer]]
  ) =>
  TokenInfo ->
  Id DP.Person ->
  MerchantAccessReq ->
  m APISuccess
assignMerchantAccess _ personId req = do
  merchant <-
    QMerchant.findByShortId req.merchantId
      >>= fromMaybeM (MerchantDoesNotExist req.merchantId.getShortId)
  availableServers <- asks (.dataServers)
  unless (merchant.serverName `elem` (availableServers <&> (.name))) $
    throwError $ InvalidRequest "Server for this merchant is not available"
  _person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  mbMerchantAccess <- QAccess.findByPersonIdAndMerchantId personId merchant.id
  whenJust mbMerchantAccess $ \_ -> do
    throwError $ InvalidRequest "Merchant access already assigned."
  merchantAccess <- buildMerchantAccess personId merchant.id
  Esq.runTransaction $
    QAccess.create merchantAccess
  pure Success

resetMerchantAccess ::
  ( EsqDBFlow m r,
    Redis.HedisFlow m r,
    HasFlowEnv m r '["dataServers" ::: [Client.DataServer]],
    HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text]
  ) =>
  TokenInfo ->
  Id DP.Person ->
  MerchantAccessReq ->
  m APISuccess
resetMerchantAccess _ personId req = do
  merchant <-
    QMerchant.findByShortId req.merchantId
      >>= fromMaybeM (MerchantDoesNotExist req.merchantId.getShortId)
  availableServers <- asks (.dataServers)
  unless (merchant.serverName `elem` (availableServers <&> (.name))) $
    throwError $ InvalidRequest "Server for this merchant is not available"
  _person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  mbMerchantAccess <- QAccess.findByPersonIdAndMerchantId personId merchant.id
  case mbMerchantAccess of
    Nothing -> throwError $ InvalidRequest "Server access already denied."
    Just merchantAccess -> do
      -- this function uses tokens from db, so should be called before transaction
      Auth.cleanCachedTokensByMerchantId personId merchant.id
      Esq.runTransaction $ do
        QAccess.deleteById merchantAccess.id
        QReg.deleteAllByPersonIdAndMerchantId personId merchant.id
      pure Success

changePassword ::
  (Transactionable m, EncFlow m r) =>
  TokenInfo ->
  ChangePasswordReq ->
  m APISuccess
changePassword tokenInfo req = do
  encPerson <- QP.findById tokenInfo.personId >>= fromMaybeM (PersonNotFound tokenInfo.personId.getId)
  newHash <- getDbHash req.newPassword
  let oldActual = encPerson.passwordHash
  oldProvided <- getDbHash req.oldPassword
  unless (oldActual == oldProvided) . throwError $ InvalidRequest "Old password is incorrect."
  Esq.runTransaction $
    QP.updatePersonPassword tokenInfo.personId newHash
  pure Success

buildMerchantAccess :: MonadFlow m => Id DP.Person -> Id DMerchant.Merchant -> m DAccess.MerchantAccess
buildMerchantAccess personId merchantId = do
  uid <- generateGUID
  now <- getCurrentTime
  return $
    DAccess.MerchantAccess
      { id = Id uid,
        personId = personId,
        merchantId = merchantId,
        createdAt = now
      }

profile ::
  (EsqDBFlow m r, EncFlow m r) =>
  TokenInfo ->
  m DP.PersonAPIEntity
profile tokenInfo = do
  encPerson <- QP.findById tokenInfo.personId >>= fromMaybeM (PersonNotFound tokenInfo.personId.getId)
  role <- QRole.findById encPerson.roleId >>= fromMaybeM (RoleNotFound encPerson.roleId.getId)
  merchantAccessList <- QAccess.findAllByPersonId tokenInfo.personId
  decPerson <- decrypt encPerson
  pure $ DP.makePersonAPIEntity decPerson role (merchantAccessList <&> (.shortId))

getCurrentMerchant ::
  EsqDBFlow m r =>
  TokenInfo ->
  m MerchantAccessRes
getCurrentMerchant tokenInfo = do
  merchant <-
    QMerchant.findById tokenInfo.merchantId
      >>= fromMaybeM (MerchantNotFound tokenInfo.merchantId.getId)
  pure $ MerchantAccessReq merchant.shortId
