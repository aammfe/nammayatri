module Domain.Action.Dashboard.Person where

import Beckn.External.Encryption (decrypt)
import Beckn.Prelude
import qualified Beckn.Storage.Esqueleto as Esq
import qualified Beckn.Storage.Hedis as Redis
import Beckn.Types.APISuccess (APISuccess (..))
import Beckn.Types.Common
import Beckn.Types.Error
import Beckn.Types.Id
import Beckn.Utils.Common
import Beckn.Utils.Validation
import qualified Domain.Types.Person as DP
import qualified Domain.Types.RegistrationToken as DReg
import qualified Domain.Types.Role as DRole
import qualified Domain.Types.ServerAccess as DServer
import qualified Storage.Queries.Person as QP
import qualified Storage.Queries.RegistrationToken as QReg
import qualified Storage.Queries.Role as QRole
import qualified Storage.Queries.ServerAccess as QServer
import Tools.Auth
import qualified Tools.Auth.Common as Auth
import qualified Tools.Client as Client
import Tools.Error
import Tools.Validation

newtype ListPersonRes = ListPersonRes
  {list :: [DP.PersonAPIEntity]}
  deriving (Generic, ToJSON, FromJSON, ToSchema)

newtype ServerAccessReq = ServerAccessReq
  {serverName :: DReg.ServerName}
  deriving (Generic, ToJSON, FromJSON, ToSchema)

type ServerAccessRes = ServerAccessReq

validateAssignServerAccessReq :: [DReg.ServerName] -> Validate ServerAccessReq
validateAssignServerAccessReq availableServerNames ServerAccessReq {..} =
  sequenceA_
    [ validateField "serverName" serverName $ InList availableServerNames
    ]

listPerson ::
  (EsqDBFlow m r, EncFlow m r) =>
  TokenInfo ->
  Maybe Text ->
  Maybe Integer ->
  Maybe Integer ->
  m ListPersonRes
listPerson _ mbSearchString mbLimit mbOffset = do
  personAndRoleList <- QP.findAllWithLimitOffset mbSearchString mbLimit mbOffset
  res <- forM personAndRoleList $ \(encPerson, role, serverAccess) -> do
    decPerson <- decrypt encPerson
    pure $ DP.makePersonAPIEntity decPerson role serverAccess
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

assignServerAccess ::
  ( EsqDBFlow m r,
    HasFlowEnv m r '["dataServers" ::: [Client.DataServer]]
  ) =>
  TokenInfo ->
  Id DP.Person ->
  ServerAccessReq ->
  m APISuccess
assignServerAccess _ personId req = do
  availableServers <- asks (.dataServers)
  runRequestValidation (validateAssignServerAccessReq $ availableServers <&> (.name)) req
  _person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  mbServerAccess <- QServer.findByPersonIdAndServerName personId req.serverName
  whenJust mbServerAccess $ \_ -> do
    throwError $ InvalidRequest "Server access already assigned."
  serverAccess <- buildServerAccess personId req.serverName
  Esq.runTransaction $
    QServer.create serverAccess
  pure Success

resetServerAccess ::
  ( EsqDBFlow m r,
    Redis.HedisFlow m r,
    HasFlowEnv m r '["dataServers" ::: [Client.DataServer]],
    HasFlowEnv m r '["authTokenCacheKeyPrefix" ::: Text]
  ) =>
  TokenInfo ->
  Id DP.Person ->
  ServerAccessReq ->
  m APISuccess
resetServerAccess _ personId req = do
  availableServers <- asks (.dataServers)
  runRequestValidation (validateAssignServerAccessReq $ availableServers <&> (.name)) req
  _person <- QP.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  mbServerAccess <- QServer.findByPersonIdAndServerName personId req.serverName
  case mbServerAccess of
    Nothing -> throwError $ InvalidRequest "Server access already denied."
    Just serverAccess -> do
      -- this function uses tokens from db, so should be called before transaction
      Auth.cleanCachedTokensByServerName personId req.serverName
      Esq.runTransaction $ do
        QServer.deleteById serverAccess.id
        QReg.deleteAllByPersonIdAndServerName personId req.serverName
      pure Success

buildServerAccess :: MonadFlow m => Id DP.Person -> DReg.ServerName -> m DServer.ServerAccess
buildServerAccess personId serverName = do
  uid <- generateGUID
  now <- getCurrentTime
  return $
    DServer.ServerAccess
      { id = Id uid,
        personId = personId,
        serverName = serverName,
        createdAt = now
      }

profile ::
  (EsqDBFlow m r, EncFlow m r) =>
  TokenInfo ->
  m DP.PersonAPIEntity
profile tokenInfo = do
  encPerson <- QP.findById tokenInfo.personId >>= fromMaybeM (PersonNotFound tokenInfo.personId.getId)
  role <- QRole.findById encPerson.roleId >>= fromMaybeM (RoleNotFound encPerson.roleId.getId)
  serverAccessList <- QServer.findAllByPersonId tokenInfo.personId
  decPerson <- decrypt encPerson
  pure $ DP.makePersonAPIEntity decPerson role (serverAccessList <&> (.serverName))

getCurrentServer ::
  TokenInfo ->
  ServerAccessRes
getCurrentServer tokenInfo = do
  ServerAccessReq tokenInfo.serverName
