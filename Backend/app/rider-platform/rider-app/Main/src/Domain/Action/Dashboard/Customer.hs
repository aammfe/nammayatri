{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Domain.Action.Dashboard.Customer
  ( deleteCustomer,
    blockCustomer,
    unblockCustomer,
    listCustomers,
  )
where

import qualified "dashboard-helper-api" Dashboard.Common as Common
import qualified Dashboard.RiderPlatform.Customer as RiderCommon
import qualified Domain.Types.Booking.Type as DRB
import qualified Domain.Types.Merchant as DM
import qualified Domain.Types.Person as DP
import Environment
import Kernel.External.Encryption (decrypt, getDbHash)
import Kernel.Prelude
import Kernel.Storage.Esqueleto.Transactionable (Transactionable' (runTransaction), runInReplica)
import Kernel.Types.APISuccess
import Kernel.Types.Error
import Kernel.Types.Id
import Kernel.Utils.Common
import qualified Storage.CachedQueries.Merchant as QM
import qualified Storage.Queries.Booking as QRB
import qualified Storage.Queries.Person as QP
import qualified Storage.Queries.Person.PersonFlowStatus as QPFS
import qualified Storage.Queries.SavedReqLocation as QSRL

---------------------------------------------------------------------
deleteCustomer ::
  ShortId DM.Merchant ->
  Id Common.Customer ->
  Flow APISuccess
deleteCustomer merchantShortId customerId = do
  let personId = cast @Common.Customer @DP.Person customerId
  merchant <- QM.findByShortId merchantShortId >>= fromMaybeM (MerchantDoesNotExist merchantShortId.getShortId)
  person <- runInReplica $ QP.findById personId >>= fromMaybeM (PersonNotFound $ getId personId)
  unless (merchant.id == person.merchantId) $ throwError (PersonDoesNotExist $ getId personId)
  bookings <- runInReplica $ QRB.findByRiderIdAndStatus personId [DRB.NEW, DRB.TRIP_ASSIGNED, DRB.AWAITING_REASSIGNMENT, DRB.CONFIRMED, DRB.COMPLETED]
  unless (null bookings) $ throwError (InvalidRequest "Can't delete customer, has a valid booking in past.")
  runTransaction $ do
    QPFS.deleteByPersonId personId
    QSRL.deleteAllByRiderId personId
    QP.deleteById personId
  pure Success

---------------------------------------------------------------------
blockCustomer :: ShortId DM.Merchant -> Id Common.Customer -> Flow APISuccess
blockCustomer merchantShortId customerId = do
  merchant <- QM.findByShortId merchantShortId >>= fromMaybeM (MerchantDoesNotExist merchantShortId.getShortId)

  let personId = cast @Common.Customer @DP.Person customerId
  customer <-
    runInReplica $
      QP.findById personId
        >>= fromMaybeM (PersonDoesNotExist personId.getId)

  -- merchant access checking
  let merchantId = customer.merchantId
  unless (merchant.id == merchantId) $ throwError (PersonDoesNotExist personId.getId)

  runTransaction $ do
    QP.updateBlockedState personId True
  logTagInfo "dashboard -> blockCustomer : " (show personId)
  pure Success

---------------------------------------------------------------------
unblockCustomer :: ShortId DM.Merchant -> Id Common.Customer -> Flow APISuccess
unblockCustomer merchantShortId customerId = do
  merchant <- QM.findByShortId merchantShortId >>= fromMaybeM (MerchantDoesNotExist merchantShortId.getShortId)

  let personId = cast @Common.Customer @DP.Person customerId
  customer <-
    runInReplica $
      QP.findById personId
        >>= fromMaybeM (PersonDoesNotExist personId.getId)

  -- merchant access checking
  let merchantId = customer.merchantId
  unless (merchant.id == merchantId) $ throwError (PersonDoesNotExist personId.getId)

  runTransaction $ do
    QP.updateBlockedState personId False
  logTagInfo "dashboard -> unblockCustomer : " (show personId)
  pure Success

---------------------------------------------------------------------
listCustomers :: ShortId DM.Merchant -> Maybe Int -> Maybe Int -> Maybe Bool -> Maybe Bool -> Maybe Text -> Flow RiderCommon.CustomerListRes
listCustomers merchantShortId mbLimit mbOffset mbEnabled mbBlocked mbSearchPhone = do
  merchant <- QM.findByShortId merchantShortId >>= fromMaybeM (MerchantDoesNotExist merchantShortId.getShortId)
  let limit = min maxLimit . fromMaybe defaultLimit $ mbLimit
      offset = fromMaybe 0 mbOffset
  mbSearchPhoneDBHash <- getDbHash `traverse` mbSearchPhone
  customers <- runInReplica $ QP.findAllCustomers merchant.id limit offset mbEnabled mbBlocked mbSearchPhoneDBHash
  items <- mapM buildCustomerListItem customers
  let count = length items
  totalCount <- runInReplica $ QP.countCustomers merchant.id
  let summary = Common.Summary {totalCount, count}
  pure RiderCommon.CustomerListRes {totalItems = count, summary, customers = items}
  where
    maxLimit = 20
    defaultLimit = 10

buildCustomerListItem :: EncFlow m r => DP.Person -> m RiderCommon.CustomerListItem
buildCustomerListItem person = do
  phoneNo <- mapM decrypt person.mobileNumber
  pure $
    RiderCommon.CustomerListItem
      { customerId = cast @DP.Person @Common.Customer person.id,
        firstName = person.firstName,
        middleName = person.middleName,
        lastName = person.lastName,
        phoneNo,
        enabled = person.enabled,
        blocked = person.blocked
      }
