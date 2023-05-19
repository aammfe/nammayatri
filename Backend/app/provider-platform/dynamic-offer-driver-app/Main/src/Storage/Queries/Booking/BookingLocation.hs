{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE PartialTypeSignatures #-}

module Storage.Queries.Booking.BookingLocation where

import Domain.Types.Booking.BookingLocation
import qualified EulerHS.Extra.EulerDB as Extra
import qualified EulerHS.KVConnector.Flow as KV
import EulerHS.KVConnector.Types
import qualified EulerHS.Language as L
import Kernel.Prelude
import Kernel.Storage.Esqueleto as Esq
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Lib.Mesh as Mesh
import qualified Sequelize as Se
import qualified Storage.Beam.Booking.BookingLocation as BeamBL
import Storage.Tabular.Booking.BookingLocation hiding (area, areaCode, building, city, country, door, state, street)
import qualified Storage.Tabular.VechileNew as VN

updateAddress :: Id BookingLocation -> LocationAddress -> SqlDB ()
updateAddress blId LocationAddress {..} = do
  now <- getCurrentTime
  Esq.update $ \tbl -> do
    set
      tbl
      [ BookingLocationStreet =. val street,
        BookingLocationCity =. val city,
        BookingLocationState =. val state,
        BookingLocationCountry =. val country,
        BookingLocationBuilding =. val building,
        BookingLocationAreaCode =. val areaCode,
        BookingLocationArea =. val area,
        BookingLocationUpdatedAt =. val now
      ]
    where_ $ tbl ^. BookingLocationTId ==. val (toKey blId)

-- updateAddress' :: (L.MonadFlow m, MonadTime m) => Id BookingLocation -> LocationAddress -> m (MeshResult ())
-- updateAddress' (Id blId) LocationAddress = do
--   dbConf <- L.getOption Extra.EulerPsqlDbCfg
--   now <- getCurrentTime
--   case dbConf of
--     Just dbConf' ->
--       KV.updateWoReturningWithKVConnector
--         dbConf'
--         VN.meshConfig
--         [ Se.Set BeamBL.street street,
--           Se.Set BeamBL.city city,
--           Se.Set BeamBL.state state,
--           Se.Set BeamBL.country country,
--           Se.Set BeamBL.building building,
--           Se.Set BeamBL.areaCode areaCode,
--           Se.Set BeamBL.area area,
--           Se.Set BeamBL.updatedAt now
--         ]
--         [Se.Is BeamBL.id (Se.Eq blId)]
--     Nothing -> pure (Left (MKeyNotFound "DB Config not found"))

transformBeamBookingLocationToDomain :: BeamBL.BookingLocation -> BookingLocation
transformBeamBookingLocationToDomain BeamBL.BookingLocationT {..} = do
  BookingLocation
    { id = Id id,
      lat = lat,
      lon = lon,
      address = LocationAddress street door city state country building areaCode area,
      createdAt = createdAt,
      updatedAt = updatedAt
    }

transformDomainBookingLocationToBeam :: BookingLocation -> BeamBL.BookingLocation
transformDomainBookingLocationToBeam BookingLocation {..} =
  BeamBL.BookingLocationT
    { BeamBL.id = getId id,
      BeamBL.lat = lat,
      BeamBL.lon = lon,
      BeamBL.street = (street :: LocationAddress -> Maybe Text) address,
      BeamBL.door = (door :: LocationAddress -> Maybe Text) address,
      BeamBL.city = (city :: LocationAddress -> Maybe Text) address,
      BeamBL.state = (state :: LocationAddress -> Maybe Text) address,
      BeamBL.country = (country :: LocationAddress -> Maybe Text) address,
      BeamBL.building = (building :: LocationAddress -> Maybe Text) address,
      BeamBL.areaCode = (areaCode :: LocationAddress -> Maybe Text) address,
      BeamBL.area = (area :: LocationAddress -> Maybe Text) address,
      BeamBL.createdAt = createdAt,
      BeamBL.updatedAt = updatedAt
    }
