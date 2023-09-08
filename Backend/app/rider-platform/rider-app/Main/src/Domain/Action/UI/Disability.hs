module Domain.Action.UI.Disability
  ( listDisabilities,
  )
where

import qualified Domain.Types.Merchant as Merchant
import qualified Domain.Types.Merchant.MerchantOperatingCity as DMOC
import qualified Domain.Types.Person as Person
import qualified Domain.Types.Person.PersonDisability as PersonDisability
import EulerHS.Prelude hiding (id)
import Kernel.Beam.Functions
import Kernel.External.Types (Language (ENGLISH))
import Kernel.Storage.Esqueleto.Config (EsqDBReplicaFlow)
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.Queries.Disability as QD
import qualified Storage.Queries.Person as QP

listDisabilities :: EsqDBReplicaFlow m r => (Id Person.Person, Id Merchant.Merchant, Id DMOC.MerchantOperatingCity) -> m [PersonDisability.DisabilityItem]
listDisabilities (personId, _, _) = do
  person <- runInReplica $ QP.findById personId >>= fromMaybeM (PersonNotFound personId.getId)
  let mbLanguage = person.language
  let language = fromMaybe ENGLISH mbLanguage
  runInReplica (QD.findAllByLanguage language)
