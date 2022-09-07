module Domain.Action.UI.DriverOnboarding.Status
  ( ResponseStatus (..),
    StatusRes (..),
    statusHandler,
  )
where

import Beckn.Prelude
import Beckn.Storage.Esqueleto (EsqDBFlow)
import qualified Beckn.Storage.Esqueleto as DB
import Beckn.Types.Error
import Beckn.Types.Id (Id)
import Beckn.Utils.Error
import qualified Domain.Types.Person as SP
import qualified Storage.Queries.DriverOnboarding.OperatingCity as DO
import Storage.Queries.Person as Person
import qualified Storage.Queries.Person as QPerson

data ResponseStatus = VERIFICATION_PENDING | VERIFIED | VERIFICATION_FAILED | WAITING_INPUT
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON, ToSchema, ToParamSchema, Enum, Bounded)

data StatusRes = StatusRes
  { dlVerificationStatus :: ResponseStatus,
    rcVerificationStatus :: ResponseStatus,
    operatingCity :: Text
  }
  deriving (Show, Eq, Read, Generic, ToJSON, FromJSON, ToSchema)

statusHandler :: (EsqDBFlow m r) => Id SP.Person -> m StatusRes
statusHandler personId = do
  person <- QPerson.findById personId >>= fromMaybeM (PersonDoesNotExist personId.getId)
  orgId <- person.organizationId & fromMaybeM (PersonFieldNotPresent "organization_id")
  -- vehicleRegCertM <- DVehicle.findLatestByPersonId personId
  -- driverDrivingLicenseM <- QDDL.findLatestByPersonId personId
  operatingCity <- DO.findByorgId orgId >>= fromMaybeM (PersonNotFound orgId.getId)
  let vehicleRCVerification = VERIFICATION_FAILED -- getVerificationStatus ((.verificationStatus) <$> vehicleRegCertM)
  let driverDLVerification = VERIFICATION_FAILED -- getVerificationStatus ((.verificationStatus) <$> driverDrivingLicenseM)
  let operatingCityVerification = operatingCity.cityName
  let response = StatusRes vehicleRCVerification driverDLVerification operatingCityVerification
  when (vehicleRCVerification == VERIFIED || driverDLVerification == VERIFIED) $ DB.runTransaction $ Person.setRegisteredTrue personId
  return response

-- getVerificationStatus :: Maybe ClassOfVehicle.VerificationStatus -> ResponseStatus
-- getVerificationStatus = \case
--   Just ClassOfVehicle.PENDING -> VERIFICATION_PENDING
--   Just ClassOfVehicle.VALID -> VERIFIED
--   Just ClassOfVehicle.INVALID -> VERIFICATION_FAILED
--   Nothing -> WAITING_INPUT
