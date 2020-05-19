{-# LANGUAGE OverloadedLabels #-}
module Product.Products where

import Beckn.Types.App
import Beckn.Types.Common as BC
import qualified Data.Accessor as Lens
import Data.Aeson
import qualified Data.Text as T
import Data.Time.LocalTime
import qualified EulerHS.Language as L
import EulerHS.Prelude
import Servant
import Types.API.Products
import qualified Storage.Queries.Case as CQ
import Storage.Queries.Location as LQ
import qualified Storage.Queries.CaseProduct as CPQ
import qualified Beckn.Types.Storage.Case as Case
import qualified Beckn.Types.Storage.CaseProduct as CaseP
import qualified Beckn.Types.Storage.Products as Product
import qualified Beckn.Types.Storage.RegistrationToken as SR
import qualified Beckn.Types.Storage.Person as SP
import Beckn.Types.Storage.Location as Location
import qualified Types.Storage.Driver as D
import qualified Beckn.Types.Storage.Vehicle as V
import qualified Storage.Queries.Vehicle as VQ
import qualified Storage.Queries.Driver as VD
import qualified Storage.Queries.Person as QP
import qualified Storage.Queries.Products as DB
import qualified Beckn.Types.Storage.Products as Storage
import qualified Storage.Queries.RegistrationToken as QR
import           Types.API.CaseProduct
import System.Environment
import qualified Data.Text as T
import Types.App
import Utils.Utils as U
import Beckn.Utils.Common (withFlowHandler)


update :: Maybe Text -> Text -> ProdReq -> FlowHandler ProdInfoRes
update regToken productId ProdReq {..} = withFlowHandler $ do
  SR.RegistrationToken {..} <- QR.verifyAuth regToken
  user <- QP.findPersonById (PersonId _EntityId)
  vehIdRes <- case _assignedTo of
            Just k ->  whenM (return $ (user ^. #_role) == SP.ADMIN || (user ^. #_role) == SP.DRIVER ) $
              DB.updateVeh (ProductsId productId) _vehicleId
            Nothing -> return ()
  infoRes <- case _driverInfo of
            Just k -> whenM (return $ (user ^. #_role) == SP.ADMIN ) $
              updateInfo (ProductsId productId) _driverInfo _vehicleInfo
            Nothing -> return ()
  dvrIdRes <- case _assignedTo of
            Just k -> whenM (return $ (user ^. #_role) == SP.ADMIN ) $
              DB.updateDvr (ProductsId productId) _assignedTo
            Nothing -> return ()
  tripRes <- case _status of
            Just c -> whenM (return $ (user ^. #_role) == SP.ADMIN ) $
              updateTrip (ProductsId productId) c
            Nothing -> return ()
  updatedProd <- DB.findById (ProductsId productId)
  return $ updatedProd

updateInfo :: ProductsId -> Maybe D.Driver -> Maybe V.Vehicle  -> L.Flow ()
updateInfo productId driverInfo vehicleInfo = do
  let info = Just $ U.encodeTypeToText (prepareInfo driverInfo vehicleInfo)
  DB.updateInfo productId info
  return ()
  where
    prepareInfo drivInfo vehiInfo = Storage.ProdInfo
          { driverInfo = U.encodeTypeToText drivInfo
          , vehicleInfo = U.encodeTypeToText vehiInfo
          }


updateTrip :: ProductsId -> Product.ProductsStatus -> L.Flow ()
updateTrip productId k = do
  cpList <- CPQ.findAllByProdId productId
  case_ <- CQ.findByIdType (CaseP._caseId <$> cpList) (Case.TRACKER)
  DB.updateStatus productId k
  CQ.updateStatus (Case._id case_) (read (show k) :: Case.CaseStatus)
  CPQ.updateStatus (Case._id case_) productId (read (show k) :: CaseP.CaseProductStatus)
  return ()

listRides :: Maybe Text -> FlowHandler ProdListRes
listRides regToken = withFlowHandler $ do
  SR.RegistrationToken {..} <- QR.verifyAuth regToken
  person <- QP.findPersonById (PersonId _EntityId)
  rideList <- DB.findAllByAssignedTo $ _getPersonId (SP._id person)
  locList <- LQ.findAllByLocIds (catMaybes (Storage._fromLocation <$> rideList)) (catMaybes (Storage._toLocation <$> rideList))
  return $ catMaybes $ joinByIds locList <$> rideList
  where
    joinByIds locList ride =
      case find (\x -> (Storage._fromLocation ride == Just (_getLocationId (Location._id x)))) locList of
        Just k -> buildResponse k
        Nothing -> Nothing
      where
        buildResponse k = (prepare ride k) <$> find (\x -> (Storage._toLocation ride == Just (_getLocationId (Location._id x)))) locList
        prepare ride from to =
          ProdRes
            { _product = ride,
              _fromLocation = from,
              _toLocation = to
            }
