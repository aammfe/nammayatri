{-
 
  Copyright 2022-23, Juspay India Pvt Ltd
 
  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License
 
  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program
 
  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 
  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of
 
  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
module Language.Types where

data STR
  = DOWNLOAD_INVOICE
  | REPORT_AN_ISSUE
  | SUBMIT
  | TRIP_DETAILS_
  | VIEW_INVOICE
  | YOU_RATED
  | TOTAL_AMOUNT
  | AMOUNT_PAID
  | DOWNLOAD_PDF
  | GST
  | INVOICE
  | TRIP_CHARGES
  | PROMOTION
  | SEND_EMAIL
  | YOU_CAN_DESCRIBE_THE_ISSUE_YOU_FACED_HERE
  | THANK_YOU_FOR_WRITING
  | WE_HAVE_RECEIVED_YOUR_ISSUE
  | GO_HOME_
  | ABOUT_APP_DESCRIPTION
  | CONTINUE
  | ENTER_YOUR_NAME
  | FULL_NAME
  | EMAIL
  | LOGO
  | TERMS_AND_CONDITIONS
  | ABOUT
  | PRIVACY_POLICY
  | SET_UP_YOUR_ACCOUNT
  | PLEASE_CHOOSE_YOUR_PREFERRED_LANGUAGE_TO_CONTINUE
  | WRITE_TO_US
  | NOTE
  | VISIT_MY_RIDES_SECTION_FOR_RIDE_SPECIFIC_COMPLAINTS
  | THANK_YOU_FOR_WRITING_TO_US
  | WE_HAVE_RECEIVED_YOUR_ISSUE_WELL_REACH_OUT_TO_YOU_IN_SOMETIME
  | GO_TO_HOME__
  | SUBJECT
  | YOUR_EMAIL_ID
  | DESCRIBE_YOUR_ISSUE
  | ENTER_MOBILE_NUMBER
  | BY_TAPPING_CONTINUE
  | TO_THE
  | ENTER_OTP
  | RESEND
  | ENTER_YOUR_MOBILE_NUMBER
  | LOGIN_USING_THE_OTP_SENT_TO
  | YOUR_RECENT_RIDE
  | VIEW_ALL_RIDES
  | ALL_TOPICS
  | FAQ
  | REPORT_AN_ISSUE_WITH_THIS_TRIP
  | GETTING_STARTED_AND_FAQS
  | FOR_OTHER_ISSUES_WRITE_TO_US
  | HELP_AND_SUPPORT
  | OUR_SUGGESTED_PRICE_FOR_THIS_TRIP_IS
  | DRIVERS_CAN_CHARGE_BETWEEN_THE_ABOVE_RANGE
  | HOW_THIS_WORKS
  | FINDING_RIDES_NEAR_YOU
  | CONFIRMING_THE_RIDE_FOR_YOU
  | CANCEL_SEARCH
  | YOUR_RIDE_IS_NOW_COMPLETE
  | PLEASE_PAY_THE_FINAL_AMOUNT_TO_THE_DRIVER_VIA_CASH
  | WHERE_TO
  | HOME
  | PICK_UP_LOCATION
  | REQUEST_RIDE
  | NAME
  | MOBILE_NUMBER_STR
  | PERSONAL_DETAILS
  | YOUR_RIDES
  | YOU_ARE_OFFLINE
  | CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN
  | TRY_AGAIN
  | THANK_YOUR_DRIVER
  | HOPE_YOUR_RIDE_WAS_HASSLE_FREE
  | HOW_WAS_YOUR_RIDE_WITH
  | GOT_IT_TELL_US_MORE
  | WRITE_A_COMMENT
  | UPDATE
  | LANGUAGE
  | OTP
  | PAYMENT_METHOD
  | PAYMENT_METHOD_STRING
  | CANCEL_RIDE
  | SUPPORT
  | PICKUP_AND_DROP
  | CANCELLED
  | HOW_THE_PRICING_WORKS
  | SELECT_AN_OFFER
  | CHOOSE_A_RIDE_AS_PER_YOUR_COMFORT
  | IT_SEEMS_TO_BE_A_VERY_BUSY_DAY
  | SORT_BY
  | SORRY_WE_COULDNT_FIND_ANY_RIDES
  | LOAD_MORE
  | WE_NEED_ACCESS_TO_YOUR_LOCATION
  | YOUR_LOCATION_HELPS_OUR_SYSTEM
  | CALL
  | EMPTY_RIDES
  | YOU_HAVENT_TAKEN_A_TRIP_YET
  | BOOK_NOW
  | T_AND_C_A
  | DATA_COLLECTION_AUTHORITY
  | SOFTWARE_LICENSE
  | DENY_ACCESS
  | PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL
  | MANDATORY
  | LOGOUT_
  | REQUEST_AUTO_RIDE
  | RATE_YOUR_RIDE
  | SKIP
  | ERROR_404
  | PROBLEM_AT_OUR_END
  | NOTIFY_ME
  | ADDRESS
  | CHANGE
  | SAVE_AS
  | ADD_TAG
  | WORK
  | OTHER
  | SAVE
  | ADD_NEW_ADDRESS
  | SAVED_ADDRESSES
  | ADDRESSES
  | NO_FAVOURITES_SAVED_YET
  | EMERGENCY_CONTACTS
  | NO_EMERGENCY_CONTACTS_SET
  | EMERGENCY_CONTACTS_SCREEN_DESCRIPTION
  | ADD_EMERGENCY_CONTACTS
  | SAVED_ADDRESS_HELPS_YOU_KEEP_YOUR_FAVOURITE_PLACES_HANDY
  | COPIED
  | TRIP_ID
  | SAVE_PLACE
  | RIDE_FARE
  | ASK_FOR_PRICE
  | ASK_FOR_PRICE_INFO
  | GET_ESTIMATE_FARE
  | SELECT_AN_OFFER_FROM_OUR_DRIVERS
  | SELECT_AN_OFFER_FROM_OUR_DRIVERS_INFO
  | PAY_THE_DRIVER
  | PAY_THE_DRIVER_INFO
  | PAY_THE_DRIVER_NOTE
  | UPDATE_PERSONAL_DETAILS
  | EDIT
  | DEL_ACCOUNT
  | ACCOUNT_DELETION_CONFIRMATION
  | REQUEST_SUBMITTED
  | WE_WILL_DELETE_YOUR_ACCOUNT
  | YES_DELETE_IT
  | REQUEST_TO_DELETE_ACCOUNT
  | CANCEL_STR
  | LOADING
  | PLEASE_WAIT_WHILE_IN_PROGRESS
  | SET_LOCATION_ON_MAP
  | CURRENT_LOCATION
  | I_AM_NOT_RECEIVING_ANY_RIDES
  | DELETE
  | ARE_YOU_SURE_YOU_WANT_TO_LOGOUT
  | ARE_YOU_SURE_YOU_WANT_TO_CANCEL
  | YOU_HAVE_RIDE_OFFERS_ARE_YOU_SURE_YOU_WANT_TO_CANCEL
  | GO_BACK_
  | REGISTER_USING_DIFFERENT_NUMBER
  | YES
  | NO
  | CANCEL_
  | IS_ON_THE_WAY
  | ENTER_4_DIGIT_OTP
  | WRONG_OTP
  | GRANT_ACCESS
  | ENTER_A_LOCATION
  | NEARBY
  | MINS_AWAY
  | PAID
  | BY_CASH
  | ONLINE_
  | USER
  | EMAIL_ALREADY_EXISTS
  | IN
  | VERIFYING_OTP
  | TRACK_LIVE_LOCATION_USING
  | GOOGLE_MAP_
  | IN_APP_TRACKING
  | REQUEST_TIMED_OUT
  | LIMIT_EXCEEDED
  | ERROR_OCCURED
  | QUOTE_EXPIRED
  | GETTING_ESTIMATES_FOR_YOU
  | LET_TRY_THAT_AGAIN
  | CONFIRM_PICKUP_LOCATION
  | CONFIRM_DROP_LOCATION
  | NO_DRIVERS_AVAILABLE
  | ERROR_OCCURED_TRY_AGAIN
  | ERROR_OCCURED_TRY_AFTER_SOMETIME
  | ASKED_FOR_MORE_MONEY
  | START_
  | LIMIT_REACHED
  | RIDE_NOT_SERVICEABLE
  | CONFIRM_FOR
  | ETA_WAS_TOO_SHORT
  | DRIVER_REQUESTED_TO_CANCEL
  | PICK_UP_LOCATION_INCORRECT
  | COULD_NOT_CONNECT_TO_DRIVER
  | ETA_WAS_TOO_LONG
  | OTHERS
  | DESTINATION_OUTSIDE_LIMITS
  | DROP_LOCATION_FAR_AWAY
  | CHANGE_DROP_LOCATION
  | YOU_CAN_TAKE_A_WALK_OR_CONTINUE_WITH_RIDE_BOOKING
  | YOUR_TRIP_IS_TOO_SHORT_YOU_ARE_JUST
  | METERS_AWAY_FROM_YOUR_DESTINATION
  | BOOK_RIDE_
  | LOCATION_UNSERVICEABLE
  | CURRENTLY_WE_ARE_LIVE_IN_
  | CHANGE_LOCATION
  | IF_YOU_STILL_WANNA_BOOK_RIDE_CLICK_CONTINUE_AND_START_BOOKING_THE_RIDE
  | THE_TRIP_IS_VERY_SHORT_AND_JUST_TAKE
  | STEPS_TO_COMPLETE
  | CANCEL_AUTO_ASSIGNING
  | AUTO_ACCEPTING_SELECTED_RIDE
  | HELP_US_WITH_YOUR_REASON
  | MAX_CHAR_LIMIT_REACHED
  | DRIVER_WAS_NOT_REACHABLE
  | SHOW_ALL_OPTIONS
  | EXPIRES_IN
  | PAY_DIRECTLY_TO_YOUR_DRIVER_USING_CASH_UPI
  | UPDATE_REQUIRED
  | PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE
  | NOT_NOW
  | OF
  | LOST_SOMETHING
  | TRY_CONNECTING_WITH_THE_DRIVER
  | CALL_DRIVER
  | NO_MORE_RIDES
  | CONTACT_SUPPORT
  | INVALID_MOBILE_NUMBER
  | CONFIRM_LOCATION
  | RIDE_COMPLETED
  | SUBMIT_FEEDBACK
  | HOW_WAS_YOUR_RIDE_EXPERIENCE
  | DROP
  | RATE_YOUR_RIDE_WITH
  | VIEW_BREAKDOWN
  | PAY_DRIVER_USING_CASH_OR_UPI
  | RATE_YOUR_DRIVER
  | MY_RIDES
  | RIDE_ID
  | RIDE_DETAILS
  | SELECT_A_RIDE
  | CONFIRM_RIDE_
  | YOU_CAN_CANCEL_RIDE
  | ESTIMATES_CHANGED
  | ESTIMATES_REVISED_TO
  | RATE_CARD
  | NIGHT_TIME_CHARGES
  | MIN_FARE_UPTO
  | RATE_ABOVE_MIN_FARE
  | DRIVER_PICKUP_CHARGES
  | NOMINAL_FARE
  | DAY_TIMES_OF
  | NIGHT_TIMES_OF
  | DAYTIME_CHARGES_APPLICABLE_AT_NIGHT
  | DAYTIME_CHARGES_APPLIED_AT_NIGHT
  | DRIVERS_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC
  | GOT_IT
  | DAY_TIME_CHARGES
  | SHARE_APP
  | AWAY_C
  | AWAY
  | AT_PICKUP
  | FARE_UPDATED
  | TOTAL_FARE_MAY_CHANGE_DUE_TO_CHANGE_IN_ROUTE
  | HELP_US_WITH_YOUR_FEEDBACK
  | WAIT_TIME
  | FAVOURITES
  | ADD_FAVOURITE
  | ALL_FAVOURITES
  | REMOVE
  | SELECT_ON_MAP
  | FAVOURITE_LOCATION
  | EDIT_FAVOURITE
  | DRAG_THE_MAP
  | CHOOSE_ON_MAP
  | USE_CURRENT_LOCATION
  | FAVOURITE_YOUR_CURRENT_LOCATION
  | LOCATION
  | LOCATION_ALREADY_EXISTS_AS
  | GIVE_THIS_LOCATION_A_NAME
  | FAVOURITE
  | CONFIRM_AND_SAVE
  | REMOVE_FAVOURITE
  | ARE_YOU_SURE_YOU_WANT_TO_REMOVE_FAVOURITE_
  | YES_REMOVE
  | ADD_NEW_FAVOURITE
  | SELECT_YOUR_DROP
  | FAVOURITE_REMOVED_SUCCESSFULLY
  | LOCATION_ALREADY_EXISTS
  | FAVOURITE_LIMIT_REACHED
  | LOCATION_ALREADY
  | EXISTS_AS
  | FAVOURITE_ADDED_SUCCESSFULLY
  | FAVOURITE_UPDATED_SUCCESSFULLY
  | ALREADY_EXISTS
  | NAME_ALREADY_IN_USE
  | SELECT_FAVOURITE
  | CONFIRM_CHANGES
  | ADD_SAVED_LOCATION_FROM_SETTINGS
  | AT_DROP
  | EMERGENCY_HELP
  | CALL_POLICE
  | ALSO_SHARE_YOUR_RIDE_STATUS_AND_LOCATION
  | SHARE_RIDE_WITH_EMERGENCY_CONTACTS
  | DO_YOU_NEED_EMERGENCY_HELP
  | CALL_SUPPORT
  | YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT
  | YOU_ARE_ABOUT_TO_CALL_POLICE
  | DAIL_100
  | YOU_WILL_BE_ASKED_TO_SELECT_CONTACTS
  | AUTO_ASSIGN_A_RIDE
  | IS_WAITING_FOR_YOU
  | WAIT_TIME_TOO_LONG
  | GOT_ANOTHER_RIDE_ELSE_WHERE
  | DRIVER_WAS_RUDE
  | MAYBE_LATER
  | YOUR_RIDE_HAS_STARTED
  | ENJOY_RIDING_WITH_US
  | VIEW_DETAILS
  | REPEAT_RIDE
  | FARE_WAS_HIGH
  | AUTO_ASSIGN_DRIVER
  | CHOOSE_BETWEEN_MULTIPLE_DRIVERS
  | CHOOSE_BETWEEN_MULTIPLE_RIDES
  | ENABLE_THIS_FEATURE_TO_CHOOSE_YOUR_RIDE
  | BOOKING_PREFERENCE
  | BASE_FARES
  | PICKUP_CHARGE
  | WAITING_CHARGE
  | TOTAL_PAID
  | NOMINAL_FARES
  | DRIVERS_CAN_CHARGE_AN_ADDITIONAL_FARE_UPTO
  | WAITING_CHARGE_DESCRIPTION
  | SUCCESSFUL_ONBOARD
  | HAVE_REFERRAL_CODE
  | REFEREAL_CODE_DISCRIPTION
  | SIX_DIGIT_REFERRAL_CODE
  | ABOUT_REFERRAL_PROGRAM
  | ABOUT_REFERRAL_PROGRAM_DISCRIPTION
  | REFERRAL_CODE_SUCCESSFULL
  | REFERRAL_CODE_APPLIED
  | HEY
  | YOU_CAN_GET_REFERRAL_CODE_FROM_DRIVER
  | INVALID_CODE_PLEASE_RE_ENTER
  | CONTACTS_SELECTED
  | SELECT_CONTACTS
  | CONFIRM_EMERGENCY_CONTACTS
  | MAXIMUM_CONTACTS_LIMIT_REACHED
  | ARE_YOU_SURE_YOU_WANT_TO_REMOVE_CONTACT
  | SEARCH_CONTACTS
  | SELECTED_CONTACT_IS_INVALID
  | CALL_EMERGENCY_CONTACTS
  | LIVE_STATS_DASHBOARD
  | CHECK_OUT_LIVE_STATS
  | ADD_ANOTHER_CONTACT
  | WELCOME_TEXT
  | EMERGENCY_CONTACS_ADDED_SUCCESSFULLY
  | NO_CONTACTS_FOUND_ON_DEVICE_TO_ADD
  | NO_CONTACTS_LEFT_ON_DEVICE_TO_ADD
  | PERMISSION_DENIED
  | PERCENTAGE_OF_NOMINAL_FARE
  | PAY_VIA_CASH_OR_UPI
  | BOARD_THE_FIRST_TAXI
  | REQUEST_CALLBACK

getKeyString :: STR -> String
getKeyString key = case key of
  DOWNLOAD_INVOICE -> "DOWNLOAD_INVOICE"
  REPORT_AN_ISSUE -> "REPORT_AN_ISSUE"
  SUBMIT -> "SUBMIT"
  TRIP_DETAILS_ -> "TRIP_DETAILS_"
  VIEW_INVOICE -> "VIEW_INVOICE"
  YOU_RATED -> "YOU_RATED"
  TOTAL_AMOUNT -> "TOTAL_AMOUNT"
  AMOUNT_PAID -> "AMOUNT_PAID"
  DOWNLOAD_PDF -> "DOWNLOAD_PDF"
  GST -> "GST"
  INVOICE -> "INVOICE"
  TRIP_CHARGES -> "TRIP_CHARGES"
  PROMOTION -> "PROMOTION"
  SEND_EMAIL -> "SEND_EMAIL"
  YOU_CAN_DESCRIBE_THE_ISSUE_YOU_FACED_HERE -> "YOU_CAN_DESCRIBE_THE_ISSUE_YOU_FACED_HERE"
  THANK_YOU_FOR_WRITING -> "THANK_YOU_FOR_WRITING"
  WE_HAVE_RECEIVED_YOUR_ISSUE -> "WE_HAVE_RECEIVED_YOUR_ISSUE"
  GO_HOME_ -> "GO_HOME_"
  ABOUT_APP_DESCRIPTION -> "ABOUT_APP_DESCRIPTION"
  CONTINUE -> "CONTINUE"
  ENTER_YOUR_NAME -> "ENTER_YOUR_NAME"
  FULL_NAME -> "FULL_NAME"
  EMAIL -> "EMAIL"
  LOGO -> "LOGO"
  TERMS_AND_CONDITIONS -> "TERMS_AND_CONDITIONS"
  ABOUT -> "ABOUT"
  PRIVACY_POLICY -> "PRIVACY_POLICY"
  SET_UP_YOUR_ACCOUNT -> "SET_UP_YOUR_ACCOUNT"
  PLEASE_CHOOSE_YOUR_PREFERRED_LANGUAGE_TO_CONTINUE -> "PLEASE_CHOOSE_YOUR_PREFERRED_LANGUAGE_TO_CONTINUE"
  WRITE_TO_US -> "WRITE_TO_US"
  NOTE -> "NOTE"
  VISIT_MY_RIDES_SECTION_FOR_RIDE_SPECIFIC_COMPLAINTS -> "VISIT_MY_RIDES_SECTION_FOR_RIDE_SPECIFIC_COMPLAINTS"
  THANK_YOU_FOR_WRITING_TO_US -> "THANK_YOU_FOR_WRITING_TO_US"
  WE_HAVE_RECEIVED_YOUR_ISSUE_WELL_REACH_OUT_TO_YOU_IN_SOMETIME -> "WE_HAVE_RECEIVED_YOUR_ISSUE_WELL_REACH_OUT_TO_YOU_IN_SOMETIME"
  GO_TO_HOME__ -> "GO_TO_HOME__"
  SUBJECT -> "SUBJECT"
  YOUR_EMAIL_ID -> "YOUR_EMAIL_ID"
  DESCRIBE_YOUR_ISSUE -> "DESCRIBE_YOUR_ISSUE"
  ENTER_MOBILE_NUMBER -> "ENTER_MOBILE_NUMBER"
  BY_TAPPING_CONTINUE -> "BY_TAPPING_CONTINUE"
  TO_THE -> "TO_THE"
  ENTER_OTP -> "ENTER_OTP"
  RESEND -> "RESEND"
  ENTER_YOUR_MOBILE_NUMBER -> "ENTER_YOUR_MOBILE_NUMBER"
  LOGIN_USING_THE_OTP_SENT_TO -> "LOGIN_USING_THE_OTP_SENT_TO"
  YOUR_RECENT_RIDE -> "YOUR_RECENT_RIDE"
  VIEW_ALL_RIDES -> "VIEW_ALL_RIDES"
  ALL_TOPICS -> "ALL_TOPICS"
  FAQ -> "FAQ"
  REPORT_AN_ISSUE_WITH_THIS_TRIP -> "REPORT_AN_ISSUE_WITH_THIS_TRIP"
  GETTING_STARTED_AND_FAQS -> "GETTING_STARTED_AND_FAQS"
  FOR_OTHER_ISSUES_WRITE_TO_US -> "FOR_OTHER_ISSUES_WRITE_TO_US"
  HELP_AND_SUPPORT -> "HELP_AND_SUPPORT"
  OUR_SUGGESTED_PRICE_FOR_THIS_TRIP_IS -> "OUR_SUGGESTED_PRICE_FOR_THIS_TRIP_IS"
  DRIVERS_CAN_CHARGE_BETWEEN_THE_ABOVE_RANGE -> "DRIVERS_CAN_CHARGE_BETWEEN_THE_ABOVE_RANGE"
  HOW_THIS_WORKS -> "HOW_THIS_WORKS"
  FINDING_RIDES_NEAR_YOU -> "FINDING_RIDES_NEAR_YOU"
  CONFIRMING_THE_RIDE_FOR_YOU -> "CONFIRMING_THE_RIDE_FOR_YOU"
  CANCEL_SEARCH -> "CANCEL_SEARCH"
  YOUR_RIDE_IS_NOW_COMPLETE -> "YOUR_RIDE_IS_NOW_COMPLETE"
  PLEASE_PAY_THE_FINAL_AMOUNT_TO_THE_DRIVER_VIA_CASH -> "PLEASE_PAY_THE_FINAL_AMOUNT_TO_THE_DRIVER_VIA_CASH"
  WHERE_TO -> "WHERE_TO"
  HOME -> "HOME"
  PICK_UP_LOCATION -> "PICK_UP_LOCATION"
  REQUEST_RIDE -> "REQUEST_RIDE"
  NAME -> "NAME"
  MOBILE_NUMBER_STR -> "MOBILE_NUMBER_STR"
  PERSONAL_DETAILS -> "PERSONAL_DETAILS"
  YOUR_RIDES -> "YOUR_RIDES"
  YOU_ARE_OFFLINE -> "YOU_ARE_OFFLINE"
  CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN -> "CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN"
  TRY_AGAIN -> "TRY_AGAIN"
  THANK_YOUR_DRIVER -> "THANK_YOUR_DRIVER"
  HOPE_YOUR_RIDE_WAS_HASSLE_FREE -> "HOPE_YOUR_RIDE_WAS_HASSLE_FREE"
  HOW_WAS_YOUR_RIDE_WITH -> "HOW_WAS_YOUR_RIDE_WITH"
  GOT_IT_TELL_US_MORE -> "GOT_IT_TELL_US_MORE"
  WRITE_A_COMMENT -> "WRITE_A_COMMENT"
  UPDATE -> "UPDATE"
  LANGUAGE -> "LANGUAGE"
  OTP -> "OTP"
  PAYMENT_METHOD -> "PAYMENT_METHOD"
  PAYMENT_METHOD_STRING -> "PAYMENT_METHOD_STRING"
  CANCEL_RIDE -> "CANCEL_RIDE"
  SUPPORT -> "SUPPORT"
  PICKUP_AND_DROP -> "PICKUP_AND_DROP"
  CANCELLED -> "CANCELLED"
  HOW_THE_PRICING_WORKS -> "HOW_THE_PRICING_WORKS"
  SELECT_AN_OFFER -> "SELECT_AN_OFFER"
  CHOOSE_A_RIDE_AS_PER_YOUR_COMFORT -> "CHOOSE_A_RIDE_AS_PER_YOUR_COMFORT"
  IT_SEEMS_TO_BE_A_VERY_BUSY_DAY -> "IT_SEEMS_TO_BE_A_VERY_BUSY_DAY"
  SORT_BY -> "SORT_BY"
  SORRY_WE_COULDNT_FIND_ANY_RIDES -> "SORRY_WE_COULDNT_FIND_ANY_RIDES"
  LOAD_MORE -> "LOAD_MORE"
  WE_NEED_ACCESS_TO_YOUR_LOCATION -> "WE_NEED_ACCESS_TO_YOUR_LOCATION"
  YOUR_LOCATION_HELPS_OUR_SYSTEM -> "YOUR_LOCATION_HELPS_OUR_SYSTEM"
  CALL -> "CALL"
  EMPTY_RIDES -> "EMPTY_RIDES"
  YOU_HAVENT_TAKEN_A_TRIP_YET -> "YOU_HAVENT_TAKEN_A_TRIP_YET"
  BOOK_NOW -> "BOOK_NOW"
  T_AND_C_A -> "T_AND_C_A"
  DATA_COLLECTION_AUTHORITY -> "DATA_COLLECTION_AUTHORITY"
  SOFTWARE_LICENSE -> "SOFTWARE_LICENSE"
  DENY_ACCESS -> "DENY_ACCESS"
  PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL -> "PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL"
  MANDATORY -> "MANDATORY"
  LOGOUT_ -> "LOGOUT_"
  REQUEST_AUTO_RIDE -> "REQUEST_AUTO_RIDE"
  RATE_YOUR_RIDE -> "RATE_YOUR_RIDE"
  SKIP -> "SKIP"
  ERROR_404 -> "ERROR_404"
  PROBLEM_AT_OUR_END -> "PROBLEM_AT_OUR_END"
  NOTIFY_ME -> "NOTIFY_ME"
  ADDRESS -> "ADDRESS"
  CHANGE -> "CHANGE"
  SAVE_AS -> "SAVE_AS"
  ADD_TAG -> "ADD_TAG"
  WORK -> "WORK"
  OTHER -> "OTHER"
  SAVE -> "SAVE"
  ADD_NEW_ADDRESS -> "ADD_NEW_ADDRESS"
  SAVED_ADDRESSES -> "SAVED_ADDRESSES"
  ADDRESSES -> "ADDRESSES"
  NO_FAVOURITES_SAVED_YET -> "NO_FAVOURITES_SAVED_YET"
  EMERGENCY_CONTACTS -> "EMERGENCY_CONTACTS"
  NO_EMERGENCY_CONTACTS_SET -> "NO_EMERGENCY_CONTACTS_SET"
  EMERGENCY_CONTACTS_SCREEN_DESCRIPTION -> "EMERGENCY_CONTACTS_SCREEN_DESCRIPTION"
  ADD_EMERGENCY_CONTACTS -> "ADD_EMERGENCY_CONTACTS"
  SAVED_ADDRESS_HELPS_YOU_KEEP_YOUR_FAVOURITE_PLACES_HANDY -> "SAVED_ADDRESS_HELPS_YOU_KEEP_YOUR_FAVOURITE_PLACES_HANDY"
  COPIED -> "COPIED"
  TRIP_ID -> "TRIP_ID"
  SAVE_PLACE -> "SAVE_PLACE"
  RIDE_FARE -> "RIDE_FARE"
  ASK_FOR_PRICE -> "ASK_FOR_PRICE"
  ASK_FOR_PRICE_INFO -> "ASK_FOR_PRICE_INFO"
  GET_ESTIMATE_FARE -> "GET_ESTIMATE_FARE"
  SELECT_AN_OFFER_FROM_OUR_DRIVERS -> "SELECT_AN_OFFER_FROM_OUR_DRIVERS"
  SELECT_AN_OFFER_FROM_OUR_DRIVERS_INFO -> "SELECT_AN_OFFER_FROM_OUR_DRIVERS_INFO"
  PAY_THE_DRIVER -> "PAY_THE_DRIVER"
  PAY_THE_DRIVER_INFO -> "PAY_THE_DRIVER_INFO"
  PAY_THE_DRIVER_NOTE -> "PAY_THE_DRIVER_NOTE"
  UPDATE_PERSONAL_DETAILS -> "UPDATE_PERSONAL_DETAILS"
  EDIT -> "EDIT"
  DEL_ACCOUNT -> "DEL_ACCOUNT"
  ACCOUNT_DELETION_CONFIRMATION -> "ACCOUNT_DELETION_CONFIRMATION"
  REQUEST_SUBMITTED -> "REQUEST_SUBMITTED"
  WE_WILL_DELETE_YOUR_ACCOUNT -> "WE_WILL_DELETE_YOUR_ACCOUNT"
  YES_DELETE_IT -> "YES_DELETE_IT"
  REQUEST_TO_DELETE_ACCOUNT -> "REQUEST_TO_DELETE_ACCOUNT"
  CANCEL_STR -> "CANCEL_STR"
  LOADING -> "LOADING"
  PLEASE_WAIT_WHILE_IN_PROGRESS -> "PLEASE_WAIT_WHILE_IN_PROGRESS"
  SET_LOCATION_ON_MAP -> "SET_LOCATION_ON_MAP"
  CURRENT_LOCATION -> "CURRENT_LOCATION"
  I_AM_NOT_RECEIVING_ANY_RIDES -> "I_AM_NOT_RECEIVING_ANY_RIDES"
  DELETE -> "DELETE"
  ARE_YOU_SURE_YOU_WANT_TO_LOGOUT -> "ARE_YOU_SURE_YOU_WANT_TO_LOGOUT"
  ARE_YOU_SURE_YOU_WANT_TO_CANCEL -> "ARE_YOU_SURE_YOU_WANT_TO_CANCEL"
  YOU_HAVE_RIDE_OFFERS_ARE_YOU_SURE_YOU_WANT_TO_CANCEL -> "YOU_HAVE_RIDE_OFFERS_ARE_YOU_SURE_YOU_WANT_TO_CANCEL"
  GO_BACK_ -> "GO_BACK_"
  REGISTER_USING_DIFFERENT_NUMBER -> "REGISTER_USING_DIFFERENT_NUMBER"
  YES -> "YES"
  NO -> "NO"
  CANCEL_ -> "CANCEL_"
  IS_ON_THE_WAY -> "IS_ON_THE_WAY"
  ENTER_4_DIGIT_OTP -> "ENTER_4_DIGIT_OTP"
  WRONG_OTP -> "WRONG_OTP"
  GRANT_ACCESS -> "GRANT_ACCESS"
  ENTER_A_LOCATION -> "ENTER_A_LOCATION"
  NEARBY -> "NEARBY"
  MINS_AWAY -> "MINS_AWAY"
  PAID -> "PAID"
  BY_CASH -> "BY_CASH"
  ONLINE_ -> "ONLINE_"
  USER -> "USER"
  EMAIL_ALREADY_EXISTS -> "EMAIL_ALREADY_EXISTS"
  IN -> "IN"
  VERIFYING_OTP -> "VERIFYING_OTP"
  TRACK_LIVE_LOCATION_USING -> "TRACK_LIVE_LOCATION_USING"
  GOOGLE_MAP_ -> "GOOGLE_MAP_"
  IN_APP_TRACKING -> "IN_APP_TRACKING"
  REQUEST_TIMED_OUT -> "REQUEST_TIMED_OUT"
  LIMIT_EXCEEDED -> "LIMIT_EXCEEDED"
  ERROR_OCCURED -> "ERROR_OCCURED"
  QUOTE_EXPIRED -> "QUOTE_EXPIRED"
  GETTING_ESTIMATES_FOR_YOU -> "GETTING_ESTIMATES_FOR_YOU"
  LET_TRY_THAT_AGAIN -> "LET_TRY_THAT_AGAIN"
  CONFIRM_PICKUP_LOCATION -> "CONFIRM_PICKUP_LOCATION"
  CONFIRM_DROP_LOCATION -> "CONFIRM_DROP_LOCATION"
  NO_DRIVERS_AVAILABLE -> "NO_DRIVERS_AVAILABLE"
  ERROR_OCCURED_TRY_AGAIN -> "ERROR_OCCURED_TRY_AGAIN"
  ERROR_OCCURED_TRY_AFTER_SOMETIME -> "ERROR_OCCURED_TRY_AFTER_SOMETIME"
  ASKED_FOR_MORE_MONEY -> "ASKED_FOR_MORE_MONEY"
  START_ -> "START_"
  LIMIT_REACHED -> "LIMIT_REACHED"
  RIDE_NOT_SERVICEABLE -> "RIDE_NOT_SERVICEABLE"
  CONFIRM_FOR -> "CONFIRM_FOR"
  ETA_WAS_TOO_SHORT -> "ETA_WAS_TOO_SHORT"
  DRIVER_REQUESTED_TO_CANCEL -> "DRIVER_REQUESTED_TO_CANCEL"
  PICK_UP_LOCATION_INCORRECT -> "PICK_UP_LOCATION_INCORRECT"
  COULD_NOT_CONNECT_TO_DRIVER -> "COULD_NOT_CONNECT_TO_DRIVER"
  ETA_WAS_TOO_LONG -> "ETA_WAS_TOO_LONG"
  OTHERS -> "OTHERS"
  DESTINATION_OUTSIDE_LIMITS -> "DESTINATION_OUTSIDE_LIMITS"
  DROP_LOCATION_FAR_AWAY -> "DROP_LOCATION_FAR_AWAY"
  CHANGE_DROP_LOCATION -> "CHANGE_DROP_LOCATION"
  YOU_CAN_TAKE_A_WALK_OR_CONTINUE_WITH_RIDE_BOOKING -> "YOU_CAN_TAKE_A_WALK_OR_CONTINUE_WITH_RIDE_BOOKING"
  YOUR_TRIP_IS_TOO_SHORT_YOU_ARE_JUST -> "YOUR_TRIP_IS_TOO_SHORT_YOU_ARE_JUST"
  METERS_AWAY_FROM_YOUR_DESTINATION -> "METERS_AWAY_FROM_YOUR_DESTINATION"
  BOOK_RIDE_ -> "BOOK_RIDE_"
  LOCATION_UNSERVICEABLE -> "LOCATION_UNSERVICEABLE"
  CURRENTLY_WE_ARE_LIVE_IN_ -> "CURRENTLY_WE_ARE_LIVE_IN_"
  CHANGE_LOCATION -> "CHANGE_LOCATION"
  IF_YOU_STILL_WANNA_BOOK_RIDE_CLICK_CONTINUE_AND_START_BOOKING_THE_RIDE -> "IF_YOU_STILL_WANNA_BOOK_RIDE_CLICK_CONTINUE_AND_START_BOOKING_THE_RIDE"
  THE_TRIP_IS_VERY_SHORT_AND_JUST_TAKE -> "THE_TRIP_IS_VERY_SHORT_AND_JUST_TAKE"
  STEPS_TO_COMPLETE -> "STEPS_TO_COMPLETE"
  CANCEL_AUTO_ASSIGNING -> "CANCEL_AUTO_ASSIGNING"
  AUTO_ACCEPTING_SELECTED_RIDE -> "AUTO_ACCEPTING_SELECTED_RIDE"
  HELP_US_WITH_YOUR_REASON -> "HELP_US_WITH_YOUR_REASON"
  MAX_CHAR_LIMIT_REACHED -> "MAX_CHAR_LIMIT_REACHED"
  DRIVER_WAS_NOT_REACHABLE -> "DRIVER_WAS_NOT_REACHABLE"
  SHOW_ALL_OPTIONS -> "SHOW_ALL_OPTIONS"
  EXPIRES_IN -> "EXPIRES_IN"
  PAY_DIRECTLY_TO_YOUR_DRIVER_USING_CASH_UPI -> "PAY_DIRECTLY_TO_YOUR_DRIVER_USING_CASH_UPI"
  UPDATE_REQUIRED -> "UPDATE_REQUIRED"
  PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE -> "PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE"
  NOT_NOW -> "NOT_NOW"
  OF -> "OF"
  LOST_SOMETHING -> "LOST_SOMETHING"
  TRY_CONNECTING_WITH_THE_DRIVER -> "TRY_CONNECTING_WITH_THE_DRIVER"
  CALL_DRIVER -> "CALL_DRIVER"
  NO_MORE_RIDES -> "NO_MORE_RIDES"
  CONTACT_SUPPORT -> "CONTACT_SUPPORT"
  INVALID_MOBILE_NUMBER -> "INVALID_MOBILE_NUMBER"
  CONFIRM_LOCATION -> "CONFIRM_LOCATION"
  RIDE_COMPLETED -> "RIDE_COMPLETED"
  SUBMIT_FEEDBACK -> "SUBMIT_FEEDBACK"
  HOW_WAS_YOUR_RIDE_EXPERIENCE -> "HOW_WAS_YOUR_RIDE_EXPERIENCE"
  DROP -> "DROP"
  RATE_YOUR_RIDE_WITH -> "RATE_YOUR_RIDE_WITH"
  VIEW_BREAKDOWN -> "VIEW_BREAKDOWN"
  PAY_DRIVER_USING_CASH_OR_UPI -> "PAY_DRIVER_USING_CASH_OR_UPI"
  RATE_YOUR_DRIVER -> "RATE_YOUR_DRIVER"
  MY_RIDES -> "MY_RIDES"
  RIDE_ID -> "RIDE_ID"
  RIDE_DETAILS -> "RIDE_DETAILS"
  SELECT_A_RIDE -> "SELECT_A_RIDE"
  CONFIRM_RIDE_ -> "CONFIRM_RIDE_"
  YOU_CAN_CANCEL_RIDE -> "YOU_CAN_CANCEL_RIDE"
  ESTIMATES_CHANGED -> "ESTIMATES_CHANGED"
  ESTIMATES_REVISED_TO -> "ESTIMATES_REVISED_TO"
  RATE_CARD -> "RATE_CARD"
  NIGHT_TIME_CHARGES -> "NIGHT_TIME_CHARGES"
  MIN_FARE_UPTO -> "MIN_FARE_UPTO"
  RATE_ABOVE_MIN_FARE -> "RATE_ABOVE_MIN_FARE"
  DRIVER_PICKUP_CHARGES -> "DRIVER_PICKUP_CHARGES"
  NOMINAL_FARE -> "NOMINAL_FARE"
  DAY_TIMES_OF -> "DAY_TIMES_OF"
  NIGHT_TIMES_OF -> "NIGHT_TIMES_OF"
  DAYTIME_CHARGES_APPLICABLE_AT_NIGHT -> "DAYTIME_CHARGES_APPLICABLE_AT_NIGHT"
  DAYTIME_CHARGES_APPLIED_AT_NIGHT -> "DAYTIME_CHARGES_APPLIED_AT_NIGHT"
  DRIVERS_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC -> "DRIVERS_MAY_QUOTE_EXTRA_TO_COVER_FOR_TRAFFIC"
  GOT_IT -> "GOT_IT"
  DAY_TIME_CHARGES -> "DAY_TIME_CHARGES"
  SHARE_APP -> "SHARE_APP"
  AWAY_C -> "AWAY_C"
  AWAY -> "AWAY"
  AT_PICKUP -> "AT_PICKUP"
  FARE_UPDATED -> "FARE_UPDATED"
  TOTAL_FARE_MAY_CHANGE_DUE_TO_CHANGE_IN_ROUTE -> "TOTAL_FARE_MAY_CHANGE_DUE_TO_CHANGE_IN_ROUTE"
  HELP_US_WITH_YOUR_FEEDBACK -> "HELP_US_WITH_YOUR_FEEDBACK"
  WAIT_TIME -> "WAIT_TIME"
  FAVOURITES -> "FAVOURITES"
  ADD_FAVOURITE -> "ADD_FAVOURITE"
  ALL_FAVOURITES -> "ALL_FAVOURITES"
  REMOVE -> "REMOVE"
  SELECT_ON_MAP -> "SELECT_ON_MAP"
  FAVOURITE_LOCATION -> "FAVOURITE_LOCATION"
  EDIT_FAVOURITE -> "EDIT_FAVOURITE"
  DRAG_THE_MAP -> "DRAG_THE_MAP"
  CHOOSE_ON_MAP -> "CHOOSE_ON_MAP"
  USE_CURRENT_LOCATION -> "USE_CURRENT_LOCATION"
  FAVOURITE_YOUR_CURRENT_LOCATION -> "FAVOURITE_YOUR_CURRENT_LOCATION"
  LOCATION -> "LOCATION"
  LOCATION_ALREADY_EXISTS_AS -> "LOCATION_ALREADY_EXISTS_AS"
  GIVE_THIS_LOCATION_A_NAME -> "GIVE_THIS_LOCATION_A_NAME"
  FAVOURITE -> "FAVOURITE"
  CONFIRM_AND_SAVE -> "CONFIRM_AND_SAVE"
  REMOVE_FAVOURITE -> "REMOVE_FAVOURITE"
  ARE_YOU_SURE_YOU_WANT_TO_REMOVE_FAVOURITE_ -> "ARE_YOU_SURE_YOU_WANT_TO_REMOVE_FAVOURITE_"
  YES_REMOVE -> "YES_REMOVE"
  ADD_NEW_FAVOURITE -> "ADD_NEW_FAVOURITE"
  SELECT_YOUR_DROP -> "SELECT_YOUR_DROP"
  FAVOURITE_REMOVED_SUCCESSFULLY -> "FAVOURITE_REMOVED_SUCCESSFULLY"
  LOCATION_ALREADY_EXISTS -> "LOCATION_ALREADY_EXISTS"
  FAVOURITE_LIMIT_REACHED -> "FAVOURITE_LIMIT_REACHED"
  LOCATION_ALREADY -> "LOCATION_ALREADY"
  EXISTS_AS -> "EXISTS_AS"
  FAVOURITE_ADDED_SUCCESSFULLY -> "FAVOURITE_ADDED_SUCCESSFULLY"
  FAVOURITE_UPDATED_SUCCESSFULLY -> "FAVOURITE_UPDATED_SUCCESSFULLY"
  ALREADY_EXISTS -> "ALREADY_EXISTS"
  NAME_ALREADY_IN_USE -> "NAME_ALREADY_IN_USE"
  SELECT_FAVOURITE -> "SELECT_FAVOURITE"
  CONFIRM_CHANGES -> "CONFIRM_CHANGES"
  ADD_SAVED_LOCATION_FROM_SETTINGS -> "ADD_SAVED_LOCATION_FROM_SETTINGS"
  AT_DROP -> "AT_DROP"
  EMERGENCY_HELP -> "EMERGENCY_HELP"
  CALL_POLICE -> "CALL_POLICE"
  ALSO_SHARE_YOUR_RIDE_STATUS_AND_LOCATION -> "ALSO_SHARE_YOUR_RIDE_STATUS_AND_LOCATION"
  SHARE_RIDE_WITH_EMERGENCY_CONTACTS -> "SHARE_RIDE_WITH_EMERGENCY_CONTACTS"
  DO_YOU_NEED_EMERGENCY_HELP -> "DO_YOU_NEED_EMERGENCY_HELP"
  CALL_SUPPORT -> "CALL_SUPPORT"
  YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT -> "YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT"
  YOU_ARE_ABOUT_TO_CALL_POLICE -> "YOU_ARE_ABOUT_TO_CALL_POLICE"
  DAIL_100 -> "DAIL_100"
  YOU_WILL_BE_ASKED_TO_SELECT_CONTACTS -> "YOU_WILL_BE_ASKED_TO_SELECT_CONTACTS"
  AUTO_ASSIGN_A_RIDE -> "AUTO_ASSIGN_A_RIDE"
  IS_WAITING_FOR_YOU -> "IS_WAITING_FOR_YOU"
  WAIT_TIME_TOO_LONG -> "WAIT_TIME_TOO_LONG"
  GOT_ANOTHER_RIDE_ELSE_WHERE -> "GOT_ANOTHER_RIDE_ELSE_WHERE"
  DRIVER_WAS_RUDE -> "DRIVER_WAS_RUDE"
  MAYBE_LATER -> "MAYBE_LATER"
  YOUR_RIDE_HAS_STARTED -> "YOUR_RIDE_HAS_STARTED"
  ENJOY_RIDING_WITH_US -> "ENJOY_RIDING_WITH_US"
  VIEW_DETAILS -> "VIEW_DETAILS"
  REPEAT_RIDE -> "REPEAT_RIDE"
  FARE_WAS_HIGH -> "FARE_WAS_HIGH"
  AUTO_ASSIGN_DRIVER -> "AUTO_ASSIGN_DRIVER"
  CHOOSE_BETWEEN_MULTIPLE_DRIVERS -> "CHOOSE_BETWEEN_MULTIPLE_DRIVERS"
  CHOOSE_BETWEEN_MULTIPLE_RIDES -> "CHOOSE_BETWEEN_MULTIPLE_RIDES"
  ENABLE_THIS_FEATURE_TO_CHOOSE_YOUR_RIDE -> "ENABLE_THIS_FEATURE_TO_CHOOSE_YOUR_RIDE"
  BOOKING_PREFERENCE -> "BOOKING_PREFERENCE"
  BASE_FARES -> "BASE_FARES"
  PICKUP_CHARGE -> "PICKUP_CHARGE"
  WAITING_CHARGE -> "WAITING_CHARGE"
  TOTAL_PAID -> "TOTAL_PAID"
  NOMINAL_FARES -> "NOMINAL_FARES"
  DRIVERS_CAN_CHARGE_AN_ADDITIONAL_FARE_UPTO -> "DRIVERS_CAN_CHARGE_AN_ADDITIONAL_FARE_UPTO"
  WAITING_CHARGE_DESCRIPTION -> "WAITING_CHARGE_DESCRIPTION"
  SUCCESSFUL_ONBOARD -> "SUCCESSFUL_ONBOARD"
  HAVE_REFERRAL_CODE -> "HAVE_REFERRAL_CODE"
  REFEREAL_CODE_DISCRIPTION -> "REFEREAL_CODE_DISCRIPTION"
  SIX_DIGIT_REFERRAL_CODE -> "SIX_DIGIT_REFERRAL_CODE"
  ABOUT_REFERRAL_PROGRAM -> "ABOUT_REFERRAL_PROGRAM"
  ABOUT_REFERRAL_PROGRAM_DISCRIPTION -> "ABOUT_REFERRAL_PROGRAM_DISCRIPTION"
  REFERRAL_CODE_SUCCESSFULL -> "REFERRAL_CODE_SUCCESSFULL"
  REFERRAL_CODE_APPLIED -> "REFERRAL_CODE_APPLIED"
  HEY -> "HEY"
  YOU_CAN_GET_REFERRAL_CODE_FROM_DRIVER -> "YOU_CAN_GET_REFERRAL_CODE_FROM_DRIVER"
  INVALID_CODE_PLEASE_RE_ENTER -> "INVALID_CODE_PLEASE_RE_ENTER"
  CONTACTS_SELECTED -> "CONTACTS_SELECTED"
  SELECT_CONTACTS -> "SELECT_CONTACTS"
  CONFIRM_EMERGENCY_CONTACTS -> "CONFIRM_EMERGENCY_CONTACTS"
  MAXIMUM_CONTACTS_LIMIT_REACHED -> "MAXIMUM_CONTACTS_LIMIT_REACHED"
  ARE_YOU_SURE_YOU_WANT_TO_REMOVE_CONTACT -> "ARE_YOU_SURE_YOU_WANT_TO_REMOVE_CONTACT"
  SEARCH_CONTACTS -> "SEARCH_CONTACTS"
  SELECTED_CONTACT_IS_INVALID -> "SELECTED_CONTACT_IS_INVALID"
  CALL_EMERGENCY_CONTACTS -> "CALL_EMERGENCY_CONTACTS"
  LIVE_STATS_DASHBOARD -> "LIVE_STATS_DASHBOARD"
  CHECK_OUT_LIVE_STATS -> "CHECK_OUT_LIVE_STATS"
  ADD_ANOTHER_CONTACT -> "ADD_ANOTHER_CONTACT"
  WELCOME_TEXT -> "WELCOME_TEXT"
  EMERGENCY_CONTACS_ADDED_SUCCESSFULLY -> "EMERGENCY_CONTACS_ADDED_SUCCESSFULLY"
  NO_CONTACTS_FOUND_ON_DEVICE_TO_ADD -> "NO_CONTACTS_FOUND_ON_DEVICE_TO_ADD"
  NO_CONTACTS_LEFT_ON_DEVICE_TO_ADD -> "NO_CONTACTS_LEFT_ON_DEVICE_TO_ADD"
  PERMISSION_DENIED -> "PERMISSION_DENIED"
  PERCENTAGE_OF_NOMINAL_FARE -> "PERCENTAGE_OF_NOMINAL_FARE"
  PAY_VIA_CASH_OR_UPI -> "PAY_VIA_CASH_OR_UPI"
  BOARD_THE_FIRST_TAXI -> "BOARD_THE_FIRST_TAXI"
  REQUEST_CALLBACK -> "REQUEST_CALLBACK"
