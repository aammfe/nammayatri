module Product.Cron where

import Beckn.Types.App
import Beckn.Types.Common as BC
import qualified Beckn.Types.Storage.Case as Case
import qualified Beckn.Types.Storage.CaseProduct as CaseProduct
import qualified Beckn.Types.Storage.Location as Loc
import qualified Beckn.Types.Storage.Products as Product
import qualified Beckn.Types.Storage.RegistrationToken as SR
import Beckn.Utils.Common (authenticate, withFlowHandler)
import qualified Data.Accessor as Lens
import Data.Aeson
import qualified Data.ByteString.Base64 as DBB
import qualified Data.Text as T
import qualified Data.Text.Encoding as DT
import Data.Time.LocalTime
import qualified EulerHS.Language as L
import EulerHS.Prelude
import Servant
import qualified Storage.Queries.Case as Case
import qualified Storage.Queries.CaseProduct as CaseProduct
import Storage.Queries.Location as Loc
import qualified Storage.Queries.Person as Person
import qualified Storage.Queries.Products as Products
import System.Environment
import Types.API.CaseProduct
import qualified Types.API.Cron as API
import Utils.Common (verifyToken)

updateCases :: Maybe CronAuthKey -> API.ExpireCaseReq -> FlowHandler API.ExpireCaseRes
updateCases maybeAuth API.ExpireCaseReq {..} = withFlowHandler $ do
  authenticate maybeAuth
  cases <- (Case.findAllExpiredByStatus [Case.NEW] from to)
  let caseIds = Case._id <$> cases
  traverse
    ( \cId -> do
        Case.updateStatus cId Case.CLOSED
        CaseProduct.updateAllCaseProductsByCaseId cId Product.EXPIRED
        CaseProduct.updateAllProductsByCaseId cId Product.EXPIRED
    )
    caseIds
  pure $ API.ExpireCaseRes $ length caseIds
