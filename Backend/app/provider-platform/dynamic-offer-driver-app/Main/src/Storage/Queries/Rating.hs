{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Storage.Queries.Rating where

import Domain.Types.Person
import Domain.Types.Rating as DR
import Domain.Types.Ride
import qualified EulerHS.KVConnector.Flow as KV
import EulerHS.KVConnector.Types
import qualified EulerHS.Language as L
import qualified Kernel.Beam.Types as KBT
import Kernel.Prelude
import Kernel.Types.Id
import Kernel.Utils.Common
import Lib.Utils (setMeshConfig)
import qualified Sequelize as Se
import qualified Storage.Beam.Rating as BeamR

create :: L.MonadFlow m => DR.Rating -> m (MeshResult ())
create rating = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RatingT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbConf' -> KV.createWoReturingKVConnector dbConf' updatedMeshConfig (transformDomainRatingToBeam rating)
    Nothing -> pure (Left $ MKeyNotFound "DB Config not found")

updateRating :: (L.MonadFlow m, MonadTime m) => Id Rating -> Id Person -> Int -> Maybe Text -> m (MeshResult ())
updateRating (Id ratingId) (Id driverId) newRatingValue newFeedbackDetails = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RatingT
  let updatedMeshConfig = setMeshConfig modelName
  now <- getCurrentTime
  case dbConf of
    Just dbConf' ->
      KV.updateWoReturningWithKVConnector
        dbConf'
        updatedMeshConfig
        [ Se.Set BeamR.ratingValue newRatingValue,
          Se.Set BeamR.feedbackDetails newFeedbackDetails,
          Se.Set BeamR.updatedAt now
        ]
        [Se.And [Se.Is BeamR.id (Se.Eq ratingId), Se.Is BeamR.driverId (Se.Eq driverId)]]
    Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

findAllRatingsForPerson :: L.MonadFlow m => Id Person -> m [Rating]
findAllRatingsForPerson driverId = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RatingT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbCOnf' -> either (pure []) (transformBeamRatingToDomain <$>) <$> KV.findAllWithKVConnector dbCOnf' updatedMeshConfig [Se.Is BeamR.driverId $ Se.Eq $ getId driverId]
    Nothing -> pure []

findRatingForRide :: L.MonadFlow m => Id Ride -> m (Maybe Rating)
findRatingForRide (Id rideId) = do
  dbConf <- L.getOption KBT.PsqlDbCfg
  let modelName = Se.modelTableName @BeamR.RatingT
  let updatedMeshConfig = setMeshConfig modelName
  case dbConf of
    Just dbCOnf' -> either (pure Nothing) (transformBeamRatingToDomain <$>) <$> KV.findWithKVConnector dbCOnf' updatedMeshConfig [Se.Is BeamR.id $ Se.Eq rideId]
    Nothing -> pure Nothing

transformBeamRatingToDomain :: BeamR.Rating -> Rating
transformBeamRatingToDomain BeamR.RatingT {..} = do
  Rating
    { id = Id id,
      rideId = Id rideId,
      driverId = Id driverId,
      ratingValue = ratingValue,
      feedbackDetails = feedbackDetails,
      createdAt = createdAt,
      updatedAt = updatedAt
    }

transformDomainRatingToBeam :: Rating -> BeamR.Rating
transformDomainRatingToBeam Rating {..} =
  BeamR.defaultRating
    { BeamR.id = getId id,
      BeamR.rideId = getId rideId,
      BeamR.driverId = getId driverId,
      BeamR.ratingValue = ratingValue,
      BeamR.feedbackDetails = feedbackDetails,
      BeamR.createdAt = createdAt,
      BeamR.updatedAt = updatedAt
    }
