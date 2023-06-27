{-

  Copyright 2022-23, Juspay India Pvt Ltd

  This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

  as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

  is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

  the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Language.Types where

data STR = LETS_GET_STARTED
        | YOUR_APPLICATION_HAS_BEEN_SUBMITTED_SUCCESSFULLY_AND_IS_UNDER_VERIFICATION
        | VIEW_STATUS
        | GO_HOME
        | SELECT_LANGUAGE
        | WHICH_LANGUAGE_DO_YOU_PREFER
        | T_C
        | ENTER_MOBILE_NUMBER
        | BY_CLICKING_NEXT_YOU_WILL_BE_AGREEING_TO_OUR
        | ENTER_OTP
        | DIDNT_RECIEVE_OTP
        | RESEND_OTP
        | PLEASE_ENTER_VALID_OTP
        | INVALID_MOBILE_NUMBER
        | REGISTER
        | MOBILE_NUMBER
        | AUTO_READING_OTP
        | UPLOAD_DRIVING_LICENSE
        | UPLOAD_BACK_SIDE
        | UPLOAD_FRONT_SIDE
        | BACK_SIDE
        | FRONT_SIDE
        | NEXT
        | LICENSE_INSTRUCTION_PICTURE
        | LICENSE_INSTRUCTION_CLARITY
        | REGISTRATION_STEPS
        | PROGRESS_SAVED
        | DRIVING_LICENSE
        | AADHAR_CARD
        | BANK_DETAILS
        | VEHICLE_DETAILS
        | UPLOAD_FRONT_BACK
        | EARNINGS_WILL_BE_CREDITED
        | FILL_VEHICLE_DETAILS
        | FOLLOW_STEPS
        | REGISTRATION
        | UPLOAD_ADHAAR_CARD
        | ADHAAR_INTRUCTION_PICTURE
        | ADD_VEHICLE_DETAILS
        | VEHICLE_REGISTRATION_NUMBER
        | ENTER_VEHICLE_NO
        | VEHICLE_TYPE
        | VEHICLE_MODEL_NAME
        | ENTER_MODEL_NAME
        | VEHICLE_COLOUR
        | ENTER_VEHICLE_COLOUR
        | UPLOAD_REGISTRATION_CERTIFICATE
        | UPLOAD_RC
        | PREVIEW
        | CHOOSE_VEHICLE_TYPE
        | MAX_IMAGES
        | RE_ENTER_BENIFICIARY_NUMBER
        | IFSC_CODE
        | BENIFICIARY_NUMBER
        | SENDING_OTP
        | LOADING
        | PLEASE_WAIT_WHILE_IN_PROGRESS
        | YOUR_REQUEST_HAS_TIMEOUT_TRY_AGAIN
        | ERROR_OCCURED_PLEASE_TRY_AGAIN_LATER
        | COUNTRY_CODE_INDIA
        | ENTER_OTP_SENT_TO
        | OTP_SENT_TO
        | ENTER_ACCOUNT_NUMBER
        | ADD_BANK_DETAILS
        | ENTER_IFSC_CODE
        | SUBMIT
        | PERSONAL_DETAILS
        | LANGUAGES
        | HELP_AND_FAQ
        | ABOUT
        | LOGOUT
        | UPDATE
        | EDIT
        | DELETE
        | VIEW
        | ISSUE_NO
        | ADD_VOICE_NOTE
        | VOICE_NOTE_ADDED
        | ADDED_IMAGES
        | NO_IMAGES_ADDED
        | ASK_DETAILS_MESSAGE
        | ASK_DETAILS_MESSAGE_REVERSED
        | SELECT_OPTION
        | SELECT_OPTION_REVERSED
        | ISSUE_SUBMITTED_MESSAGE
        | SUBMIT_ISSUE_DETAILS
        | IMAGE_PREVIEW
        | RIDE_REPORT_ISSUE
        | I_DONT_KNOW_WHICH_RIDE
        | REPORT_ISSUE_CHAT_PLACEHOLDER
        | ADDED_VOICE_NOTE
        | NO_VOICE_NOTE_ADDED
        | CALL_CUSTOMER_TITLE
        | CALL_CUSTOMER_DESCRIPTION
        | PLACE_CALL
        | ADD_IMAGE
        | ADD_ANOTHER
        | IMAGES_ADDED
        | ISSUE_SUBMITTED_TEXT
        | CHOOSE_AN_OPTION
        | IMAGE_ADDED
        | DONE
        | RECORD_VOICE_NOTE
        | AUTO
        | NAME
        | PRIVACY_POLICY
        | LOGO
        | ABOUT_APP_DESCRIPTION
        | TERMS_AND_CONDITIONS
        | UPDATE_VEHICLE_DETAILS
        | HELP_AND_SUPPORT
        | NOTE
        | VISIT_MY_RIDES_SCREEN_FOR_SPECIFIC_COMPLAINTS
        | THANK_YOU_FOR_WRTITTING_US
        | GO_TO_HOME
        | YOUR_RECENT_RIDE
        | YOUR_RECENT_TRIP
        | ALL_TOPICS
        | REPORT_AN_ISSUE_WITH_THIS_TRIP
        | YOU_RATED
        | VIEW_ALL_RIDES
        | WRITE_TO_US
        | SUBJECT
        | YOUR_EMAIL_ID
        | MORE_OPTIONS
        | DESCRIBE_YOUR_ISSUE
        | GETTING_STARTED_AND_FAQ
        | ONGOING_ISSUES
        | RESOLVED_ISSUES
        | FOR_OTHER_ISSUES_WRITE_TO_US
        | CALL_SUPPORT_CENTER
        | YOU_CAN_DESCRIBE_ISSUE_THAT_YOU_FACED_HERE
        | REGISTRATION_CERTIFICATE_IMAGE
        | HOME
        | RIDES
        | TRIPS
        | PROFILE
        | ENTER_DRIVING_LICENSE_NUMBER
        | TRIP_DETAILS
        | BY_CASH
        | ONLINE_
        | DISTANCE
        | REPORT_AN_ISSUE
        | TIME_TAKEN
        | MAPS
        | CALL
        | START_RIDE
        | CANCEL_RIDE
        | PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL
        | MANDATORY
        | END_RIDE
        | RIDE_COMPLETED_WITH
        | COLLECT_AMOUNT_IN_CASH
        | CASH_COLLECTED
        | OFFLINE
        | ACCEPT_FOR
        | DECLINE
        | REQUEST
        | YOU_ARE_OFFLINE
        | YOU_ARE_CURRENTLY_BUSY_GO_ONLINE_TO_RECIEVE_TRIP_REQUESTS
        | GOING_OFFLINE_WILL_NOT_GET_YOU_ANY_RIDE
        | CANCEL
        | GO_OFFLINE
        | IS_WAITING_FOR_YOU
        | YOU_ARE_ON_A_RIDE
        | PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP
        | COMPLETED_
        | CANCELLED_
        | WHERE_IS_MY_LICENSE_NUMBER
        | WE_NEED_SOME_ACCESS
        | ALLOW_ACCESS
        | ENTER_RC_NUMBER
        | WHERE_IS_MY_RC_NUMBER
        | WE_HAVE_RECIEVED_YOUR_ISSUE
        | THANK_YOU_FOR_WRITING_TO_US
        | RIDER
        | TRIP_ID
        | NEED_IT_TO_SHOW_YOU_INCOMING_RIDE_REQUEST
        | NEED_IT_TO_DISABLE_BATTERY_OPTIMIZATION_FOR_THE_APP
        | NEED_IT_TO_AUTOSTART_YOUR_APP
        | NEED_IT_TO_ENABLE_LOCATION
        | OVERLAY_TO_DRAW_OVER_APPLICATIONS
        | BATTERY_OPTIMIZATIONS
        | AUTO_START_APPLICATION_IN_BACKGROUND
        | LOCATION_ACCESS
        | STEP
        | PAID
        | ENTERED_WRONG_OTP
        | COPIED
        | BANK_NAME
        | AADHAR_DETAILS
        | AADHAR_NUMBER
        | FRONT_SIDE_IMAGE
        | BACK_SIDE_IMAGE
        | STILL_NOT_RESOLVED
        | CASE_TWO
        | NON_DISCLOUSER_AGREEMENT
        | DATA_COLLECTION_AUTHORITY
        | SOFTWARE_LICENSE
        | LOAD_MORE
        | ARE_YOU_SURE_YOU_WANT_TO_LOGOUT
        | GO_BACK
        | THANK_YOU_FOR_REGISTERING_US
        | UNFORTANUTELY_WE_ARE_NOT_AVAILABLE__YET_FOR_YOU
        | ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE
        | EMPTY_RIDES
        | YOU_HAVE_NOT_TAKEN_A_TRIP_YET
        | BOOK_NOW
        | RESEND_OTP_IN
        | WE_NEED_ACCESS_TO_YOUR_LOCATION
        | YOUR_LOCATION_HELPS_OUR_SYSTEM
        | NO_INTERNET_CONNECTION
        | PLEASE_CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN
        | TRY_AGAIN
        | GRANT_ACCESS
        | OTP_LIMIT_EXCEED
        | ENTER_REFERRAL_MOBILE_NUMBER
        | APPLY
        | HAVE_A_REFERRAL
        | ADD_HERE
        | REFERRAL_APPLIED
        | SMALLEDIT
        | ADD_DRIVING_LICENSE
        | HELP
        | INVALID_DL_NUMBER
        | DRIVING_LICENSE_NUMBER
        | ENTER_DL_NUMBER
        | SELECT_DATE_OF_BIRTH
        | DATE_OF_BIRTH
        | WATCH_A_TUTORIAL_FOR_EASY_REGISTRATION
        | ENTER_MINIMUM_FIFTEEN_CHARACTERS
        | ADD_YOUR_FRIEND
        | PLEASE_WAIT_WHILE_VALIDATING_THE_IMAGE
        | VALIDATING
        | VERIFICATION_PENDING
        | VERIFICATION_FAILED
        | NO_DOC_AVAILABLE
        | ISSUE_WITH_DL_IMAGE
        | STILL_HAVE_SOME_DOUBT
        | ISSUE_WITH_RC_IMAGE
        | PLEASE_CHECK_FOR_IMAGE_IF_VALID_DOCUMENT_IMAGE_OR_NOT
        | OOPS_YOUR_APPLICATION_HAS_BEEN_REJECTED
        | INVALID_DRIVING_LICENSE
        | LIMIT_EXCEEDED_FOR_DL_UPLOAD
        | INVALID_VEHICLE_REGISTRATION_CERTIFICATE
        | LIMIT_EXCEEDED_FOR_RC_UPLOAD
        | YOUR_DOCUMENTS_ARE_APPROVED
        | APPLICATION_STATUS
        | FOR_SUPPORT
        | CONTACT_US
        | IMAGE_VALIDATION_FAILED
        | IMAGE_NOT_READABLE
        | IMAGE_LOW_QUALITY
        | IMAGE_INVALID_TYPE
        | IMAGE_DOCUMENT_NUMBER_MISMATCH
        | IMAGE_EXTRACTION_FAILED
        | IMAGE_NOT_FOUND
        | IMAGE_NOT_VALID
        | DRIVER_ALREADY_LINKED
        | DL_ALREADY_UPDATED
        | RC_ALREADY_LINKED
        | RC_ALREADY_UPDATED
        | DL_ALREADY_LINKED
        | SOMETHING_WENT_WRONG
        | PICKUP
        | TRIP
        | CURRENTLY_WE_ALLOW_ONLY_KARNATAKA_REGISTERED_NUMBER
        | RE_ENTER_VEHICLE_REGISTRATION_NUMBER
        | RE_ENTER_DRIVING_LICENSE_NUMBER
        | UPDATED_AT
        | TRIP_COUNT
        | TODAYS_EARNINGS
        | BONUS_EARNED
        | GOT_IT
        | WHAT_IS_NAMMA_YATRI_BONUS
        | BONUS_PRIMARY_TEXT
        | BONUS_SECONDARY_TEXT
        | DATE_OF_REGISTRATION
        | SELECT_DATE_OF_REGISTRATION
        | DATE_OF_ISSUE
        | PROVIDE_DATE_OF_ISSUE_TEXT
        | PROVIDE_DATE_OF_REGISTRATION_TEXT
        | SELECT_DATE_OF_ISSUE
        | SAME_REENTERED_RC_MESSAGE
        | SAME_REENTERED_DL_MESSAGE
        | WHERE_IS_MY_ISSUE_DATE
        | WHERE_IS_MY_REGISTRATION_DATE
        | EARNINGS_CREDITED_IN_ACCOUNT
        | INVALID_PARAMETERS
        | UNAUTHORIZED
        | INVALID_TOKEN
        | SOME_ERROR_OCCURED_IN_OFFERRIDE
        | SELECT_VEHICLE_TYPE
        | RIDE
        | NO_LOCATION_UPDATE
        | GOT_IT_TELL_US_MORE
        | WRITE_A_COMMENT
        | HOW_WAS_YOUR_RIDE_WITH
        | RUDE_BEHAVIOUR
        | LONG_WAITING_TIME
        | DIDNT_COME_TO_PICUP_LOCATION
        | HELP_US_WITH_YOUR_REASON
        | MAX_CHAR_LIMIT_REACHED
        | SHOW_ALL_OPTIONS
        | UPDATE_REQUIRED
        | PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE
        | NOT_NOW
        | OF
        | DROP
        | PLEASE_WAIT
        | SETTING_YOU_OFFLINE
        | SETTING_YOU_ONLINE
        | SETTING_YOU_SILENT
        | VIEW_BREAKDOWN
        | APP_INFO
        | OTHER
        | VEHICLE_ISSUE
        | FARE_UPDATED
        | FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES
        | CONTINUE
        | CONFIRM_PASSWORD
        | DEMO_MODE
        | PASSWORD
        | ENTER_DEMO_MODE_PASSWORD
        | DEMO_MODE_DISABLED
        | ONLINE_VIA_DEMO_MODE
        | MORE
        | LESS
        | YOU_ARE_AT_PICKUP
        | WAITING_FOR_CUSTOMER
        | CUSTOMER_NOTIFIED
        | PICKUP_TOO_FAR
        | CUSTOMER_NOT_PICKING_CALL
        | TRAFFIC_JAM
        | CUSTOMER_WAS_RUDE
        | ALL_MESSAGES
        | MESSAGES
        | ADD_A_COMMENT
        | POST_COMMENT
        | ENTER_YOUR_COMMENT
        | NO_NOTIFICATIONS_RIGHT_NOW
        | NO_NOTIFICATIONS_RIGHT_NOW_DESC
        | ALERTS
        | YOUR_COMMENT
        | SHOW_MORE
        | LOAD_OLDER_ALERTS
        | CONTEST
        | YOUR_REFERRAL_CODE_IS_LINKED
        | YOU_CAN_NOW_EARN_REWARDS
        | COMING_SOON
        | COMING_SOON_DESCRIPTION
        | REFERRAL_CODE
        | REFERRAL_CODE_HINT
        | CONFIRM_REFERRAL_CODE
        | CONFIRM_REFERRAL_CODE_HINT
        | YOUR_REFERRAL_CODE
        | FIRST_REFERRAL_SUCCESSFUL
        | AWAITING_REFERRAL_RIDE
        | CHECK_THIS_SPACE_WHEN_YOU_GET_REFERRAL_ALERT
        | REFERRED_CUSTOMERS
        | ACTIVATED_CUSTOMERS
        | REFERRAL_CODE_LINKING
        | CONTACT_SUPPORT
        | CALL_SUPPORT
        | YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT
        | REFERRAL_ENROLMENT
        | REFERRALS
        | LINK_REFERRAL_CODE
        | DRIVER_DETAILS
        | FOR_UPDATES_SEE_ALERTS
        | SHARE_OPTIONS
        | ENTER_PASSWORD
        | WELCOME_TEXT
        | ABOUT_TEXT
        | YOUR_VEHICLE
        | BOOKING_OPTIONS
        | CONFIRM_AND_CHANGE
        | MAKE_YOURSELF_AVAILABLE_FOR
        | OTP_
        | RIDE_FARE
        | RIDE_DISTANCE
        | MESSAGE
        | START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS
        | START_YOUR_CHAT_WITH_THE_DRIVER
        | I_AM_ON_MY_WAY
        | GETTING_DELAYED_PLEASE_WAIT
        | UNREACHABLE_PLEASE_CALL_BACK
        | ARE_YOU_STARING
        | PLEASE_COME_SOON
        | OK_I_WILL_WAIT
        | I_HAVE_ARRIVED
        | PLEASE_COME_FAST_I_AM_WAITING
        | PLEASE_WAIT_I_WILL_BE_THERE
        | LOOKING_FOR_YOU_AT_PICKUP
        | SILENT
        | TRY_SILENT_MODE
        | SILENT_MODE_PROMPT
        | GO_SILENT
        | GO_ONLINE
        | GO_ONLINE_PROMPT
        | LIVE_DASHBOARD
        | CLICK_TO_ACCESS_YOUR_ACCOUNT
        | ADD_ALTERNATE_NUMBER
        | ENTER_ALTERNATE_MOBILE_NUMBER
        | PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER
        | ALTERNATE_MOBILE_NUMBER
        | REMOVE
        | REMOVE_ALTERNATE_NUMBER
        | ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER
        | YES_REMOVE_IT
        | NUMBER_REMOVED_SUCCESSFULLY
        | EDIT_ALTERNATE_MOBILE_NUMBER
        | NUMBER_ADDED_SUCCESSFULLY
        | NUMBER_EDITED_SUCCESSFULLY
        | ALTERNATE_MOBILE_OTP_LIMIT_EXCEED
        | ATTEMPTS_LEFT
        | WRONG_OTP
        | OTP_LIMIT_EXCEEDED
        | OTP_LIMIT_EXCEEDED_MESSAGE
        | TRY_AGAIN_LATER
        | ATTEMPT_LEFT
        | NUMBER_ALREADY_EXIST_ERROR
        | PLEASE_ASK_RIDER_FOR_THE_OTP
        | YOUR_LIMIT_EXCEEDED_TRY_AGAIN_AFTER_10_MIN
        | I_ARRIVED
        | ESTIMATED_RIDE_FARE
        | COMPLETE_ONBOARDING
        | PERSON_WITH_THIS_NUMBER_ALREADY_EXISTS
        | RESOLVED_ISSUE
        | ONGOING_ISSUE
        | LOST_ITEM
        | RIDE_RELATED_ISSUE
        | APP_RELATED_ISSUE
        | FARE_RELATED_ISSUE
        | ISSUE_NUMBER
        | REMOVE_ISSUE
        | CALL_SUPPORT_NUMBER
        | YEARS_AGO
        | MONTHS_AGO
        | DAYS_AGO
        | HOURS_AGO
        | MIN_AGO
        | SEC_AGO
        | VERIFICATION_IS_TAKING_A_BIT_LONGER
        | ADD_ALTERNATE_NUMBER_IN_MEANTIME
        | DEMO
        | RIDE_RELATED
        | FARE_RELATED
        | APP_RELATED
        | LOST_AND_FOUND
        | REPORT_LOST_ITEM
        | CORPORATE_ADDRESS
        | CORPORATE_ADDRESS_DESCRIPTION
        | CORPORATE_ADDRESS_DESCRIPTION_ADDITIONAL
        | REGISTERED_ADDRESS
        | REGISTERED_ADDRESS_DESCRIPTION
        | REGISTERED_ADDRESS_DESCRIPTION_ADDITIONAL
        | SELECT_THE_LANGUAGES_YOU_CAN_SPEAK
        | GENDER
        | SELECT_YOUR_GENDER
        | MALE
        | FEMALE
        | PREFER_NOT_TO_SAY
        | SET_NOW
        | COMPLETE_YOUR_PROFILE_AND_FIND_MORE_RIDES
        | UPDATE_NOW
        | CONFIRM
        | GENDER_UPDATED
        | ZONE_CANCEL_TEXT_DROP
        | ZONE_CANCEL_TEXT_PICKUP
        | RANKINGS
        | GETTING_THE_LEADERBOARD_READY
        | PLEASE_WAIT_WHILE_WE_UPDATE_THE_DETAILS
        | LAST_UPDATED
        | CONGRATULATIONS_YOU_ARE_RANK
        | YOU
        | DAILY
        | WEEKLY
        | INACCURATE_DATE_AND_TIME
        | ADJUST_YOUR_DEVICE_DATE_AND_TIME_AND_TRY_AGAIN
        | THE_CURRENT_DATE_AND_TIME_IS
        | GO_TO_SETTING
        | ACCEPT_RIDES_TO_ENTER_RANKINGS
        | OTP_HAS_BEEN_RESENT
        | OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_RESENDING_OTP
        | OTP_RESENT_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER
        | OTP_PAGE_HAS_BEEN_EXPIRED_PLEASE_REQUEST_OTP_AGAIN
        | SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN
        | INVALID_REFERRAL_CODE
        | ISSUE_REMOVED_SUCCESSFULLY
        | OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER
        | TOO_MANY_ATTEMPTS_PLEASE_TRY_AGAIN_LATER
        | INVALID_REFERRAL_NUMBER
        | SOMETHING_WENT_WRONG_TRY_AGAIN_LATER
        | WAIT_TIME
        | WAIT_TIMER
        | HOW_LONG_WAITED_FOR_PICKUP
        | CUSTOMER_WILL_PAY_FOR_EVERY_MINUTE
        | OTHERS
        | ENTER_SECOND_SIM_NUMBER
        | ALTERNATE_NUMBER


getStringFromEnum :: STR -> String
getStringFromEnum key = case key of
    RESOLVED_ISSUE -> "RESOLVED_ISSUE"
    ONGOING_ISSUE -> "ONGOING_ISSUE"
    LOST_ITEM -> "LOST_ITEM"
    RIDE_RELATED_ISSUE -> "RIDE_RELATED_ISSUE"
    APP_RELATED_ISSUE -> "APP_RELATED_ISSUE"
    FARE_RELATED_ISSUE -> "FARE_RELATED_ISSUE"
    ISSUE_NUMBER -> "ISSUE_NUMBER"
    REMOVE_ISSUE -> "REMOVE_ISSUE"
    CALL_SUPPORT_NUMBER -> "CALL_SUPPORT_NUMBER"
    YEARS_AGO -> "YEARS_AGO"
    MONTHS_AGO -> "MONTHS_AGO"
    DAYS_AGO -> "DAYS_AGO"
    HOURS_AGO -> "HOURS_AGO"
    MIN_AGO -> "MIN_AGO"
    SEC_AGO -> "SEC_AGO"
    LETS_GET_STARTED -> "LETS_GET_STARTED"
    YOUR_APPLICATION_HAS_BEEN_SUBMITTED_SUCCESSFULLY_AND_IS_UNDER_VERIFICATION -> "YOUR_APPLICATION_HAS_BEEN_SUBMITTED_SUCCESSFULLY_AND_IS_UNDER_VERIFICATION"
    VIEW_STATUS -> "VIEW_STATUS"
    GO_HOME -> "GO_HOME"
    SELECT_LANGUAGE -> "SELECT_LANGUAGE"
    WHICH_LANGUAGE_DO_YOU_PREFER -> "WHICH_LANGUAGE_DO_YOU_PREFER"
    T_C -> "T_C"
    ENTER_MOBILE_NUMBER -> "ENTER_MOBILE_NUMBER"
    BY_CLICKING_NEXT_YOU_WILL_BE_AGREEING_TO_OUR -> "BY_CLICKING_NEXT_YOU_WILL_BE_AGREEING_TO_OUR"
    ENTER_OTP -> "ENTER_OTP"
    DIDNT_RECIEVE_OTP -> "DIDNT_RECIEVE_OTP"
    RESEND_OTP -> "RESEND_OTP"
    PLEASE_ENTER_VALID_OTP -> "PLEASE_ENTER_VALID_OTP"
    INVALID_MOBILE_NUMBER -> "INVALID_MOBILE_NUMBER"
    REGISTER -> "REGISTER"
    MOBILE_NUMBER -> "MOBILE_NUMBER"
    AUTO_READING_OTP -> "AUTO_READING_OTP"
    UPLOAD_DRIVING_LICENSE -> "UPLOAD_DRIVING_LICENSE"
    UPLOAD_BACK_SIDE -> "UPLOAD_BACK_SIDE"
    UPLOAD_FRONT_SIDE -> "UPLOAD_FRONT_SIDE"
    BACK_SIDE -> "BACK_SIDE"
    FRONT_SIDE -> "FRONT_SIDE"
    NEXT -> "NEXT"
    LICENSE_INSTRUCTION_PICTURE -> "LICENSE_INSTRUCTION_PICTURE"
    LICENSE_INSTRUCTION_CLARITY -> "LICENSE_INSTRUCTION_CLARITY"
    REGISTRATION_STEPS  -> "REGISTRATION_STEPS "
    PROGRESS_SAVED  -> "PROGRESS_SAVED "
    DRIVING_LICENSE  -> "DRIVING_LICENSE "
    AADHAR_CARD  -> "AADHAR_CARD "
    BANK_DETAILS  -> "BANK_DETAILS "
    VEHICLE_DETAILS  -> "VEHICLE_DETAILS "
    UPLOAD_FRONT_BACK  -> "UPLOAD_FRONT_BACK "
    EARNINGS_WILL_BE_CREDITED  -> "EARNINGS_WILL_BE_CREDITED "
    FILL_VEHICLE_DETAILS -> "FILL_VEHICLE_DETAILS"
    FOLLOW_STEPS -> "FOLLOW_STEPS"
    REGISTRATION -> "REGISTRATION"
    UPLOAD_ADHAAR_CARD -> "UPLOAD_ADHAAR_CARD"
    ADHAAR_INTRUCTION_PICTURE -> "ADHAAR_INTRUCTION_PICTURE"
    ADD_VEHICLE_DETAILS  -> "ADD_VEHICLE_DETAILS "
    VEHICLE_REGISTRATION_NUMBER -> "VEHICLE_REGISTRATION_NUMBER"
    ENTER_VEHICLE_NO  -> "ENTER_VEHICLE_NO "
    VEHICLE_TYPE  -> "VEHICLE_TYPE "
    VEHICLE_MODEL_NAME  -> "VEHICLE_MODEL_NAME "
    ENTER_MODEL_NAME  -> "ENTER_MODEL_NAME "
    VEHICLE_COLOUR  -> "VEHICLE_COLOUR "
    ENTER_VEHICLE_COLOUR  -> "ENTER_VEHICLE_COLOUR "
    UPLOAD_REGISTRATION_CERTIFICATE  -> "UPLOAD_REGISTRATION_CERTIFICATE "
    UPLOAD_RC -> "UPLOAD_RC"
    PREVIEW  -> "PREVIEW "
    CHOOSE_VEHICLE_TYPE -> "CHOOSE_VEHICLE_TYPE"
    RE_ENTER_BENIFICIARY_NUMBER -> "RE_ENTER_BENIFICIARY_NUMBER"
    IFSC_CODE -> "IFSC_CODE"
    BENIFICIARY_NUMBER -> "BENIFICIARY_NUMBER"
    SENDING_OTP -> "SENDING_OTP"
    PLEASE_WAIT_WHILE_IN_PROGRESS -> "PLEASE_WAIT_WHILE_IN_PROGRESS"
    YOUR_REQUEST_HAS_TIMEOUT_TRY_AGAIN -> "YOUR_REQUEST_HAS_TIMEOUT_TRY_AGAIN"
    ERROR_OCCURED_PLEASE_TRY_AGAIN_LATER -> "ERROR_OCCURED_PLEASE_TRY_AGAIN_LATER"
    COUNTRY_CODE_INDIA -> "COUNTRY_CODE_INDIA"
    ENTER_OTP_SENT_TO -> "ENTER_OTP_SENT_TO"
    OTP_SENT_TO -> "OTP_SENT_TO"
    ENTER_ACCOUNT_NUMBER -> "ENTER_ACCOUNT_NUMBER"
    ADD_BANK_DETAILS -> "ADD_BANK_DETAILS"
    ENTER_IFSC_CODE -> "ENTER_IFSC_CODE"
    SUBMIT -> "SUBMIT"
    PERSONAL_DETAILS -> "PERSONAL_DETAILS"
    LANGUAGES -> "LANGUAGES"
    HELP_AND_FAQ -> "HELP_AND_FAQ"
    ABOUT -> "ABOUT"
    LOGOUT -> "LOGOUT"
    UPDATE -> "UPDATE"
    EDIT -> "EDIT"
    AUTO -> "AUTO"
    NAME -> "NAME"
    PRIVACY_POLICY -> "PRIVACY_POLICY"
    LOGO -> "LOGO"
    ABOUT_APP_DESCRIPTION -> "ABOUT_APP_DESCRIPTION"
    TERMS_AND_CONDITIONS -> "TERMS_AND_CONDITIONS"
    UPDATE_VEHICLE_DETAILS -> "UPDATE_VEHICLE_DETAILS"
    HELP_AND_SUPPORT -> "HELP_AND_SUPPORT"
    NOTE -> "NOTE"
    VISIT_MY_RIDES_SCREEN_FOR_SPECIFIC_COMPLAINTS -> "VISIT_MY_RIDES_SCREEN_FOR_SPECIFIC_COMPLAINTS"
    THANK_YOU_FOR_WRTITTING_US -> "THANK_YOU_FOR_WRTITTING_US"
    GO_TO_HOME -> "GO_TO_HOME"
    YOUR_RECENT_RIDE -> "YOUR_RECENT_RIDE"
    YOUR_RECENT_TRIP -> "YOUR_RECENT_TRIP"
    ALL_TOPICS -> "ALL_TOPICS"
    REPORT_AN_ISSUE_WITH_THIS_TRIP -> "REPORT_AN_ISSUE_WITH_THIS_TRIP"
    YOU_RATED -> "YOU_RATED"
    VIEW_ALL_RIDES -> "VIEW_ALL_RIDES"
    WRITE_TO_US -> "WRITE_TO_US"
    SUBJECT -> "SUBJECT"
    YOUR_EMAIL_ID -> "YOUR_EMAIL_ID"
    DESCRIBE_YOUR_ISSUE -> "DESCRIBE_YOUR_ISSUE"
    GETTING_STARTED_AND_FAQ -> "GETTING_STARTED_AND_FAQ"
    FOR_OTHER_ISSUES_WRITE_TO_US -> "FOR_OTHER_ISSUES_WRITE_TO_US"
    CALL_SUPPORT_CENTER -> "CALL_SUPPORT_CENTER"
    YOU_CAN_DESCRIBE_ISSUE_THAT_YOU_FACED_HERE -> "YOU_CAN_DESCRIBE_ISSUE_THAT_YOU_FACED_HERE"
    REGISTRATION_CERTIFICATE_IMAGE -> "REGISTRATION_CERTIFICATE_IMAGE"
    HOME -> "HOME"
    RIDES -> "RIDES"
    TRIPS -> "TRIPS"
    PROFILE -> "PROFILE"
    ENTER_DRIVING_LICENSE_NUMBER -> "ENTER_DRIVING_LICENSE_NUMBER"
    TRIP_DETAILS -> "TRIP_DETAILS"
    BY_CASH -> "BY_CASH"
    ONLINE_ -> "ONLINE_"
    DISTANCE -> "DISTANCE"
    REPORT_AN_ISSUE -> "REPORT_AN_ISSUE"
    TIME_TAKEN -> "TIME_TAKEN"
    MAPS -> "MAPS"
    CALL -> "CALL"
    START_RIDE -> "START_RIDE"
    CANCEL_RIDE -> "CANCEL_RIDE"
    PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL -> "PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL"
    MANDATORY -> "MANDATORY"
    END_RIDE -> "END_RIDE"
    RIDE_COMPLETED_WITH -> "RIDE_COMPLETED_WITH"
    COLLECT_AMOUNT_IN_CASH -> "COLLECT_AMOUNT_IN_CASH"
    CASH_COLLECTED -> "CASH_COLLECTED"
    OFFLINE -> "OFFLINE"
    ACCEPT_FOR -> "ACCEPT_FOR"
    DECLINE -> "DECLINE"
    REQUEST -> "REQUEST"
    YOU_ARE_OFFLINE -> "YOU_ARE_OFFLINE"
    YOU_ARE_CURRENTLY_BUSY_GO_ONLINE_TO_RECIEVE_TRIP_REQUESTS -> "YOU_ARE_CURRENTLY_BUSY_GO_ONLINE_TO_RECIEVE_TRIP_REQUESTS"
    GOING_OFFLINE_WILL_NOT_GET_YOU_ANY_RIDE -> "GOING_OFFLINE_WILL_NOT_GET_YOU_ANY_RIDE"
    CANCEL -> "CANCEL"
    GO_OFFLINE -> "GO_OFFLINE"
    IS_WAITING_FOR_YOU -> "IS_WAITING_FOR_YOU"
    YOU_ARE_ON_A_RIDE -> "YOU_ARE_ON_A_RIDE"
    PLEASE_ASK_RIDER_FOR_THE_OTP -> "PLEASE_ASK_RIDER_FOR_THE_OTP"
    COMPLETED_ -> "COMPLETED_"
    CANCELLED_ -> "CANCELLED_"
    WHERE_IS_MY_LICENSE_NUMBER -> "WHERE_IS_MY_LICENSE_NUMBER"
    WE_NEED_SOME_ACCESS -> "WE_NEED_SOME_ACCESS"
    ALLOW_ACCESS -> "ALLOW_ACCESS"
    ENTER_RC_NUMBER -> "ENTER_RC_NUMBER"
    WHERE_IS_MY_RC_NUMBER -> "WHERE_IS_MY_RC_NUMBER"
    WE_HAVE_RECIEVED_YOUR_ISSUE -> "WE_HAVE_RECIEVED_YOUR_ISSUE"
    THANK_YOU_FOR_WRITING_TO_US -> "THANK_YOU_FOR_WRITING_TO_US"
    RIDER -> "RIDER"
    TRIP_ID -> "TRIP_ID"
    NEED_IT_TO_SHOW_YOU_INCOMING_RIDE_REQUEST -> "NEED_IT_TO_SHOW_YOU_INCOMING_RIDE_REQUEST"
    NEED_IT_TO_DISABLE_BATTERY_OPTIMIZATION_FOR_THE_APP -> "NEED_IT_TO_DISABLE_BATTERY_OPTIMIZATION_FOR_THE_APP"
    NEED_IT_TO_AUTOSTART_YOUR_APP -> "NEED_IT_TO_AUTOSTART_YOUR_APP"
    NEED_IT_TO_ENABLE_LOCATION -> "NEED_IT_TO_ENABLE_LOCATION"
    OVERLAY_TO_DRAW_OVER_APPLICATIONS -> "OVERLAY_TO_DRAW_OVER_APPLICATIONS"
    BATTERY_OPTIMIZATIONS -> "BATTERY_OPTIMIZATIONS"
    AUTO_START_APPLICATION_IN_BACKGROUND -> "AUTO_START_APPLICATION_IN_BACKGROUND"
    LOCATION_ACCESS -> "LOCATION_ACCESS"
    STEP -> "STEP"
    PAID -> "PAID"
    ENTERED_WRONG_OTP -> "ENTERED_WRONG_OTP"
    COPIED -> "COPIED"
    BANK_NAME -> "BANK_NAME"
    AADHAR_DETAILS -> "AADHAR_DETAILS"
    AADHAR_NUMBER -> "AADHAR_NUMBER"
    FRONT_SIDE_IMAGE -> "FRONT_SIDE_IMAGE"
    BACK_SIDE_IMAGE -> "BACK_SIDE_IMAGE"
    STILL_NOT_RESOLVED -> "STILL_NOT_RESOLVED"
    CASE_TWO -> "CASE_TWO"
    NON_DISCLOUSER_AGREEMENT -> "NON_DISCLOUSER_AGREEMENT"
    DATA_COLLECTION_AUTHORITY -> "DATA_COLLECTION_AUTHORITY"
    SOFTWARE_LICENSE -> "SOFTWARE_LICENSE"
    LOAD_MORE -> "LOAD_MORE"
    ARE_YOU_SURE_YOU_WANT_TO_LOGOUT -> "ARE_YOU_SURE_YOU_WANT_TO_LOGOUT"
    GO_BACK -> "GO_BACK"
    THANK_YOU_FOR_REGISTERING_US -> "THANK_YOU_FOR_REGISTERING_US"
    UNFORTANUTELY_WE_ARE_NOT_AVAILABLE__YET_FOR_YOU -> "UNFORTANUTELY_WE_ARE_NOT_AVAILABLE__YET_FOR_YOU"
    ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE -> "ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE"
    EMPTY_RIDES -> "EMPTY_RIDES"
    YOU_HAVE_NOT_TAKEN_A_TRIP_YET -> "YOU_HAVE_NOT_TAKEN_A_TRIP_YET"
    BOOK_NOW -> "BOOK_NOW"
    RESEND_OTP_IN -> "RESEND_OTP_IN"
    WE_NEED_ACCESS_TO_YOUR_LOCATION -> "WE_NEED_ACCESS_TO_YOUR_LOCATION"
    YOUR_LOCATION_HELPS_OUR_SYSTEM -> "YOUR_LOCATION_HELPS_OUR_SYSTEM"
    NO_INTERNET_CONNECTION -> "NO_INTERNET_CONNECTION"
    PLEASE_CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN -> "PLEASE_CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN"
    TRY_AGAIN -> "TRY_AGAIN"
    GRANT_ACCESS -> "GRANT_ACCESS"
    YOUR_LIMIT_EXCEEDED_TRY_AGAIN_AFTER_10_MIN -> "YOUR_LIMIT_EXCEEDED_TRY_AGAIN_AFTER_10_MIN"
    ENTER_REFERRAL_MOBILE_NUMBER -> "ENTER_REFERRAL_MOBILE_NUMBER"
    APPLY -> "APPLY"
    HAVE_A_REFERRAL -> "HAVE_A_REFERRAL"
    ADD_HERE -> "ADD_HERE"
    REFERRAL_APPLIED -> "REFERRAL_APPLIED"
    SMALLEDIT -> "SMALLEDIT"
    ADD_DRIVING_LICENSE -> "ADD_DRIVING_LICENSE"
    HELP -> "HELP"
    INVALID_DL_NUMBER -> "INVALID_DL_NUMBER"
    DRIVING_LICENSE_NUMBER -> "DRIVING_LICENSE_NUMBER"
    ENTER_DL_NUMBER -> "ENTER_DL_NUMBER"
    SELECT_DATE_OF_BIRTH -> "SELECT_DATE_OF_BIRTH"
    DATE_OF_BIRTH -> "DATE_OF_BIRTH"
    WATCH_A_TUTORIAL_FOR_EASY_REGISTRATION -> "WATCH_A_TUTORIAL_FOR_EASY_REGISTRATION"
    ENTER_MINIMUM_FIFTEEN_CHARACTERS -> "ENTER_MINIMUM_FIFTEEN_CHARACTERS"
    ADD_YOUR_FRIEND -> "ADD_YOUR_FRIEND"
    PLEASE_WAIT_WHILE_VALIDATING_THE_IMAGE -> "PLEASE_WAIT_WHILE_VALIDATING_THE_IMAGE"
    VALIDATING -> "VALIDATING"
    VERIFICATION_PENDING -> "VERIFICATION_PENDING"
    VERIFICATION_FAILED -> "VERIFICATION_FAILED"
    NO_DOC_AVAILABLE -> "NO_DOC_AVAILABLE"
    ISSUE_WITH_DL_IMAGE -> "ISSUE_WITH_DL_IMAGE"
    STILL_HAVE_SOME_DOUBT -> "STILL_HAVE_SOME_DOUBT"
    ISSUE_WITH_RC_IMAGE -> "ISSUE_WITH_RC_IMAGE"
    PLEASE_CHECK_FOR_IMAGE_IF_VALID_DOCUMENT_IMAGE_OR_NOT -> "PLEASE_CHECK_FOR_IMAGE_IF_VALID_DOCUMENT_IMAGE_OR_NOT"
    OOPS_YOUR_APPLICATION_HAS_BEEN_REJECTED -> "OOPS_YOUR_APPLICATION_HAS_BEEN_REJECTED"
    INVALID_DRIVING_LICENSE -> "INVALID_DRIVING_LICENSE"
    LIMIT_EXCEEDED_FOR_DL_UPLOAD -> "LIMIT_EXCEEDED_FOR_DL_UPLOAD"
    INVALID_VEHICLE_REGISTRATION_CERTIFICATE -> "INVALID_VEHICLE_REGISTRATION_CERTIFICATE"
    LIMIT_EXCEEDED_FOR_RC_UPLOAD -> "LIMIT_EXCEEDED_FOR_RC_UPLOAD"
    YOUR_DOCUMENTS_ARE_APPROVED -> "YOUR_DOCUMENTS_ARE_APPROVED"
    APPLICATION_STATUS -> "APPLICATION_STATUS"
    FOR_SUPPORT -> "FOR_SUPPORT"
    CONTACT_US -> "CONTACT_US"
    IMAGE_VALIDATION_FAILED  -> "IMAGE_VALIDATION_FAILED "
    IMAGE_NOT_READABLE -> "IMAGE_NOT_READABLE"
    IMAGE_LOW_QUALITY -> "IMAGE_LOW_QUALITY"
    IMAGE_INVALID_TYPE  -> "IMAGE_INVALID_TYPE "
    IMAGE_DOCUMENT_NUMBER_MISMATCH  -> "IMAGE_DOCUMENT_NUMBER_MISMATCH "
    IMAGE_EXTRACTION_FAILED -> "IMAGE_EXTRACTION_FAILED"
    IMAGE_NOT_FOUND  -> "IMAGE_NOT_FOUND "
    IMAGE_NOT_VALID  -> "IMAGE_NOT_VALID "
    DRIVER_ALREADY_LINKED  -> "DRIVER_ALREADY_LINKED "
    DL_ALREADY_UPDATED  -> "DL_ALREADY_UPDATED "
    RC_ALREADY_LINKED  -> "RC_ALREADY_LINKED "
    RC_ALREADY_UPDATED  -> "RC_ALREADY_UPDATED "
    DL_ALREADY_LINKED -> "DL_ALREADY_LINKED"
    SOMETHING_WENT_WRONG -> "SOMETHING_WENT_WRONG"
    PICKUP -> "PICKUP"
    TRIP -> "TRIP"
    CURRENTLY_WE_ALLOW_ONLY_KARNATAKA_REGISTERED_NUMBER -> "CURRENTLY_WE_ALLOW_ONLY_KARNATAKA_REGISTERED_NUMBER"
    RE_ENTER_VEHICLE_REGISTRATION_NUMBER -> "RE_ENTER_VEHICLE_REGISTRATION_NUMBER"
    RE_ENTER_DRIVING_LICENSE_NUMBER -> "RE_ENTER_DRIVING_LICENSE_NUMBER"
    UPDATED_AT -> "UPDATED_AT"
    TRIP_COUNT -> "TRIP_COUNT"
    TODAYS_EARNINGS -> "TODAYS_EARNINGS"
    BONUS_EARNED -> "BONUS_EARNED"
    GOT_IT -> "GOT_IT"
    WHAT_IS_NAMMA_YATRI_BONUS -> "WHAT_IS_NAMMA_YATRI_BONUS"
    BONUS_PRIMARY_TEXT -> "BONUS_PRIMARY_TEXT"
    BONUS_SECONDARY_TEXT -> "BONUS_SECONDARY_TEXT"
    DATE_OF_REGISTRATION -> "DATE_OF_REGISTRATION"
    SELECT_DATE_OF_REGISTRATION -> "SELECT_DATE_OF_REGISTRATION"
    DATE_OF_ISSUE -> "DATE_OF_ISSUE"
    PROVIDE_DATE_OF_ISSUE_TEXT -> "PROVIDE_DATE_OF_ISSUE_TEXT"
    PROVIDE_DATE_OF_REGISTRATION_TEXT -> "PROVIDE_DATE_OF_REGISTRATION_TEXT"
    SELECT_DATE_OF_ISSUE -> "SELECT_DATE_OF_ISSUE"
    SAME_REENTERED_RC_MESSAGE -> "SAME_REENTERED_RC_MESSAGE"
    SAME_REENTERED_DL_MESSAGE -> "SAME_REENTERED_DL_MESSAGE"
    WHERE_IS_MY_ISSUE_DATE -> "WHERE_IS_MY_ISSUE_DATE"
    WHERE_IS_MY_REGISTRATION_DATE -> "WHERE_IS_MY_REGISTRATION_DATE"
    EARNINGS_CREDITED_IN_ACCOUNT -> "EARNINGS_CREDITED_IN_ACCOUNT"
    INVALID_PARAMETERS -> "INVALID_PARAMETERS"
    UNAUTHORIZED -> "UNAUTHORIZED"
    INVALID_TOKEN -> "INVALID_TOKEN"
    SOME_ERROR_OCCURED_IN_OFFERRIDE -> "SOME_ERROR_OCCURED_IN_OFFERRIDE"
    SELECT_VEHICLE_TYPE -> "SELECT_VEHICLE_TYPE"
    RIDE -> "RIDE"
    NO_LOCATION_UPDATE -> "NO_LOCATION_UPDATE"
    GOT_IT_TELL_US_MORE  -> "GOT_IT_TELL_US_MORE "
    WRITE_A_COMMENT  -> "WRITE_A_COMMENT "
    HOW_WAS_YOUR_RIDE_WITH  -> "HOW_WAS_YOUR_RIDE_WITH "
    RUDE_BEHAVIOUR -> "RUDE_BEHAVIOUR"
    LONG_WAITING_TIME -> "LONG_WAITING_TIME"
    DIDNT_COME_TO_PICUP_LOCATION -> "DIDNT_COME_TO_PICUP_LOCATION"
    HELP_US_WITH_YOUR_REASON -> "HELP_US_WITH_YOUR_REASON"
    MAX_CHAR_LIMIT_REACHED -> "MAX_CHAR_LIMIT_REACHED"
    SHOW_ALL_OPTIONS -> "SHOW_ALL_OPTIONS"
    UPDATE_REQUIRED -> "UPDATE_REQUIRED"
    PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE -> "PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE"
    NOT_NOW  -> "NOT_NOW "
    OF -> "OF"
    DROP -> "DROP"
    PLEASE_WAIT -> "PLEASE_WAIT"
    SETTING_YOU_OFFLINE -> "SETTING_YOU_OFFLINE"
    SETTING_YOU_ONLINE -> "SETTING_YOU_ONLINE"
    SETTING_YOU_SILENT -> "SETTING_YOU_SILENT"
    VIEW_BREAKDOWN -> "VIEW_BREAKDOWN"
    APP_INFO -> "APP_INFO"
    OTHER -> "OTHER"
    VEHICLE_ISSUE -> "VEHICLE_ISSUE"
    FARE_UPDATED -> "FARE_UPDATED"
    FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES -> "FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES"
    CONTINUE -> "CONTINUE"
    CONFIRM_PASSWORD -> "CONFIRM_PASSWORD"
    DEMO_MODE -> "DEMO_MODE"
    PASSWORD -> "PASSWORD"
    ENTER_DEMO_MODE_PASSWORD -> "ENTER_DEMO_MODE_PASSWORD"
    DEMO_MODE_DISABLED -> "DEMO_MODE_DISABLED"
    ONLINE_VIA_DEMO_MODE -> "ONLINE_VIA_DEMO_MODE"
    MORE -> "MORE"
    LESS -> "LESS"
    YOU_ARE_AT_PICKUP -> "YOU_ARE_AT_PICKUP"
    WAITING_FOR_CUSTOMER -> "WAITING_FOR_CUSTOMER"
    CUSTOMER_NOTIFIED -> "CUSTOMER_NOTIFIED"
    I_ARRIVED -> "I_ARRIVED"
    ESTIMATED_RIDE_FARE -> "ESTIMATED_RIDE_FARE"
    PICKUP_TOO_FAR -> "PICKUP_TOO_FAR"
    CUSTOMER_NOT_PICKING_CALL -> "CUSTOMER_NOT_PICKING_CALL"
    TRAFFIC_JAM -> "TRAFFIC_JAM"
    CUSTOMER_WAS_RUDE -> "CUSTOMER_WAS_RUDE"
    ALL_MESSAGES -> "ALL_MESSAGES"
    MESSAGES -> "MESSAGES"
    ADD_A_COMMENT -> "ADD_A_COMMENT"
    POST_COMMENT -> "POST_COMMENT"
    ENTER_YOUR_COMMENT -> "ENTER_YOUR_COMMENT"
    NO_NOTIFICATIONS_RIGHT_NOW -> "NO_NOTIFICATIONS_RIGHT_NOW"
    NO_NOTIFICATIONS_RIGHT_NOW_DESC -> "NO_NOTIFICATIONS_RIGHT_NOW_DESC"
    ALERTS -> "ALERTS"
    YOUR_COMMENT -> "YOUR_COMMENT"
    SHOW_MORE -> "SHOW_MORE"
    LOAD_OLDER_ALERTS -> "LOAD_OLDER_ALERTS"
    CONTEST -> "CONTEST"
    YOUR_REFERRAL_CODE_IS_LINKED -> "YOUR_REFERRAL_CODE_IS_LINKED"
    YOU_CAN_NOW_EARN_REWARDS -> "YOU_CAN_NOW_EARN_REWARDS"
    COMING_SOON -> "COMING_SOON"
    COMING_SOON_DESCRIPTION -> "COMING_SOON_DESCRIPTION"
    REFERRAL_CODE -> "REFERRAL_CODE"
    REFERRAL_CODE_HINT -> "REFERRAL_CODE_HINT"
    CONFIRM_REFERRAL_CODE -> "CONFIRM_REFERRAL_CODE"
    CONFIRM_REFERRAL_CODE_HINT -> "CONFIRM_REFERRAL_CODE_HINT"
    YOUR_REFERRAL_CODE -> "YOUR_REFERRAL_CODE"
    FIRST_REFERRAL_SUCCESSFUL -> "FIRST_REFERRAL_SUCCESSFUL"
    AWAITING_REFERRAL_RIDE -> "AWAITING_REFERRAL_RIDE"
    CHECK_THIS_SPACE_WHEN_YOU_GET_REFERRAL_ALERT -> "CHECK_THIS_SPACE_WHEN_YOU_GET_REFERRAL_ALERT"
    REFERRED_CUSTOMERS -> "REFERRED_CUSTOMERS"
    ACTIVATED_CUSTOMERS -> "ACTIVATED_CUSTOMERS"
    REFERRAL_CODE_LINKING -> "REFERRAL_CODE_LINKING"
    CONTACT_SUPPORT -> "CONTACT_SUPPORT"
    CALL_SUPPORT -> "CALL_SUPPORT"
    YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT -> "YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT"
    REFERRAL_ENROLMENT -> "REFERRAL_ENROLMENT"
    REFERRALS -> "REFERRALS"
    LINK_REFERRAL_CODE -> "LINK_REFERRAL_CODE"
    DRIVER_DETAILS -> "DRIVER_DETAILS"
    FOR_UPDATES_SEE_ALERTS -> "FOR_UPDATES_SEE_ALERTS"
    SHARE_OPTIONS -> "SHARE_OPTIONS"
    ENTER_PASSWORD -> "ENTER_PASSWORD"
    WELCOME_TEXT -> "WELCOME_TEXT"
    ABOUT_TEXT -> "ABOUT_TEXT"
    YOUR_VEHICLE -> "YOUR_VEHICLE"
    BOOKING_OPTIONS -> "BOOKING_OPTIONS"
    CONFIRM_AND_CHANGE -> "CONFIRM_AND_CHANGE"
    OTP_ -> "OTP_"
    MAKE_YOURSELF_AVAILABLE_FOR -> "MAKE_YOURSELF_AVAILABLE_FOR"

    RIDE_FARE -> "RIDE_FARE"
    RIDE_DISTANCE -> "RIDE_DISTANCE"
    MESSAGE -> "MESSAGE"
    START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS -> "START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS"
    START_YOUR_CHAT_WITH_THE_DRIVER -> "START_YOUR_CHAT_WITH_THE_DRIVER"
    I_AM_ON_MY_WAY  -> "I_AM_ON_MY_WAY"
    GETTING_DELAYED_PLEASE_WAIT  -> "GETTING_DELAYED_PLEASE_WAIT"
    UNREACHABLE_PLEASE_CALL_BACK  -> "UNREACHABLE_PLEASE_CALL_BACK"
    ARE_YOU_STARING  -> "ARE_YOU_STARING"
    PLEASE_COME_SOON  -> "PLEASE_COME_SOON"
    OK_I_WILL_WAIT  -> "OK_I_WILL_WAIT"
    I_HAVE_ARRIVED -> "I_HAVE_ARRIVED"
    PLEASE_COME_FAST_I_AM_WAITING -> "PLEASE_COME_FAST_I_AM_WAITING"
    PLEASE_WAIT_I_WILL_BE_THERE  -> "PLEASE_WAIT_I_WILL_BE_THERE"
    LOOKING_FOR_YOU_AT_PICKUP -> "LOOKING_FOR_YOU_AT_PICKUP"
    SILENT -> "SILENT"
    TRY_SILENT_MODE -> "TRY_SILENT_MODE"
    SILENT_MODE_PROMPT -> "SILENT_MODE_PROMPT"
    GO_SILENT -> "GO_SILENT"
    GO_ONLINE -> "GO_ONLINE"
    GO_ONLINE_PROMPT -> "GO_ONLINE_PROMPT"
    LIVE_DASHBOARD -> "LIVE_DASHBOARD"
    CLICK_TO_ACCESS_YOUR_ACCOUNT -> "CLICK_TO_ACCESS_YOUR_ACCOUNT"
    ADD_ALTERNATE_NUMBER -> "ADD_ALTERNATE_NUMBER"
    ENTER_ALTERNATE_MOBILE_NUMBER -> "ENTER_ALTERNATE_MOBILE_NUMBER"
    PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER -> "PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER"
    ALTERNATE_MOBILE_NUMBER -> "ALTERNATE_MOBILE_NUMBER"
    REMOVE -> "REMOVE"
    REMOVE_ALTERNATE_NUMBER -> "REMOVE_ALTERNATE_NUMBER"
    ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER -> "ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER"
    YES_REMOVE_IT -> "YES_REMOVE_IT"
    NUMBER_REMOVED_SUCCESSFULLY -> "NUMBER_REMOVED_SUCCESSFULLY"
    EDIT_ALTERNATE_MOBILE_NUMBER -> "EDIT_ALTERNATE_MOBILE_NUMBER"
    NUMBER_ADDED_SUCCESSFULLY -> "NUMBER_ADDED_SUCCESSFULLY"
    NUMBER_EDITED_SUCCESSFULLY -> "NUMBER_EDITED_SUCCESSFULLY"
    ALTERNATE_MOBILE_OTP_LIMIT_EXCEED -> "ALTERNATE_MOBILE_OTP_LIMIT_EXCEED"
    ATTEMPTS_LEFT -> "ATTEMPTS_LEFT"
    WRONG_OTP -> "WRONG_OTP"
    OTP_LIMIT_EXCEEDED -> "OTP_LIMIT_EXCEEDED"
    OTP_LIMIT_EXCEEDED_MESSAGE -> "OTP_LIMIT_EXCEEDED_MESSAGE"
    TRY_AGAIN_LATER -> "TRY_AGAIN_LATER"
    ATTEMPT_LEFT -> "ATTEMPT_LEFT"
    NUMBER_ALREADY_EXIST_ERROR -> "NUMBER_ALREADY_EXIST_ERROR"
    PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP -> "PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP"
    OTP_LIMIT_EXCEED -> "OTP_LIMIT_EXCEED"
    COMPLETE_ONBOARDING -> "COMPLETE_ONBOARDING"
    PERSON_WITH_THIS_NUMBER_ALREADY_EXISTS -> "PERSON_WITH_THIS_NUMBER_ALREADY_EXISTS"
    VERIFICATION_IS_TAKING_A_BIT_LONGER -> "VERIFICATION_IS_TAKING_A_BIT_LONGER"
    ADD_ALTERNATE_NUMBER_IN_MEANTIME -> "ADD_ALTERNATE_NUMBER_IN_MEANTIME"
    DEMO -> "DEMO"
    MAX_IMAGES -> "MAX_IMAGES"
    LOADING -> "LOADING"
    DELETE -> "DELETE"
    VIEW -> "VIEW"
    ISSUE_NO -> "ISSUE_NO"
    ADD_VOICE_NOTE -> "ADD_VOICE_NOTE"
    ADDED_IMAGES -> "ADDED_IMAGES"
    NO_IMAGES_ADDED -> "NO_IMAGES_ADDED"
    ASK_DETAILS_MESSAGE -> "ASK_DETAILS_MESSAGE"
    VOICE_NOTE_ADDED -> "VOICE_NOTE_ADDED"
    SELECT_OPTION -> "SELECT_OPTION"
    SELECT_OPTION_REVERSED -> "SELECT_OPTION_REVERSED"
    ISSUE_SUBMITTED_MESSAGE -> "ISSUE_SUBMITTED_MESSAGE"
    ASK_DETAILS_MESSAGE_REVERSED -> "ASK_DETAILS_MESSAGE_REVERSED"
    SUBMIT_ISSUE_DETAILS -> "SUBMIT_ISSUE_DETAILS"
    IMAGE_PREVIEW -> "IMAGE_PREVIEW"
    RIDE_REPORT_ISSUE -> "RIDE_REPORT_ISSUE"
    I_DONT_KNOW_WHICH_RIDE -> "I_DONT_KNOW_WHICH_RIDE"
    REPORT_ISSUE_CHAT_PLACEHOLDER -> "REPORT_ISSUE_CHAT_PLACEHOLDER"
    ADDED_VOICE_NOTE -> "ADDED_VOICE_NOTE"
    NO_VOICE_NOTE_ADDED -> "NO_VOICE_NOTE_ADDED"
    CALL_CUSTOMER_TITLE -> "CALL_CUSTOMER_TITLE"
    CALL_CUSTOMER_DESCRIPTION -> "CALL_CUSTOMER_DESCRIPTION"
    PLACE_CALL -> "PLACE_CALL"
    ADD_IMAGE -> "ADD_IMAGE"
    ADD_ANOTHER -> "ADD_ANOTHER"
    IMAGES_ADDED -> "IMAGES_ADDED"
    ISSUE_SUBMITTED_TEXT -> "ISSUE_SUBMITTED_TEXT"
    CHOOSE_AN_OPTION -> "CHOOSE_AN_OPTION"
    IMAGE_ADDED -> "IMAGE_ADDED"
    DONE -> "DONE"
    RECORD_VOICE_NOTE -> "RECORD_VOICE_NOTE"
    MORE_OPTIONS -> "MORE_OPTIONS"
    ONGOING_ISSUES -> "ONGOING_ISSUES"
    RESOLVED_ISSUES -> "RESOLVED_ISSUES"
    LOST_AND_FOUND -> "LOST_AND_FOUND"
    RIDE_RELATED -> "RIDE_RELATED"
    FARE_RELATED -> "FARE_RELATED"
    APP_RELATED -> "APP_RELATED"
    REPORT_LOST_ITEM -> "REPORT_LOST_ITEM"
    GENDER -> "GENDER"
    SELECT_YOUR_GENDER -> "SELECT_YOUR_GENDER"
    MALE -> "MALE"
    FEMALE -> "FEMALE"
    PREFER_NOT_TO_SAY -> "PREFER_NOT_TO_SAY"
    SET_NOW -> "SET_NOW"
    COMPLETE_YOUR_PROFILE_AND_FIND_MORE_RIDES -> "COMPLETE_YOUR_PROFILE_AND_FIND_MORE_RIDES"
    UPDATE_NOW -> "UPDATE_NOW"
    CONFIRM -> "CONFIRM"
    GENDER_UPDATED -> "GENDER_UPDATED"
    CORPORATE_ADDRESS -> "CORPORATE_ADDRESS"
    CORPORATE_ADDRESS_DESCRIPTION -> "CORPORATE_ADDRESS_DESCRIPTION"
    CORPORATE_ADDRESS_DESCRIPTION_ADDITIONAL -> "CORPORATE_ADDRESS_DESCRIPTION_ADDITIONAL"
    REGISTERED_ADDRESS -> "REGISTERED_ADDRESS"
    REGISTERED_ADDRESS_DESCRIPTION -> "REGISTERED_ADDRESS_DESCRIPTION"
    REGISTERED_ADDRESS_DESCRIPTION_ADDITIONAL -> "REGISTERED_ADDRESS_DESCRIPTION_ADDITIONAL"
    SELECT_THE_LANGUAGES_YOU_CAN_SPEAK -> "SELECT_THE_LANGUAGES_YOU_CAN_SPEAK"
    ZONE_CANCEL_TEXT_DROP -> "ZONE_CANCEL_TEXT_DROP"
    ZONE_CANCEL_TEXT_PICKUP -> "ZONE_CANCEL_TEXT_PICKUP"
    RANKINGS -> "RANKINGS"
    GETTING_THE_LEADERBOARD_READY -> "GETTING_THE_LEADERBOARD_READY"
    PLEASE_WAIT_WHILE_WE_UPDATE_THE_DETAILS -> "PLEASE_WAIT_WHILE_WE_UPDATE_THE_DETAILS"
    LAST_UPDATED -> "LAST_UPDATED"
    CONGRATULATIONS_YOU_ARE_RANK -> "CONGRATULATIONS_YOU_ARE_RANK"
    YOU -> "YOU"
    DAILY -> "DAILY"
    WEEKLY -> "WEEKLY"
    INACCURATE_DATE_AND_TIME -> "INACCURATE_DATE_AND_TIME"
    ADJUST_YOUR_DEVICE_DATE_AND_TIME_AND_TRY_AGAIN -> "ADJUST_YOUR_DEVICE_DATE_AND_TIME_AND_TRY_AGAIN"
    THE_CURRENT_DATE_AND_TIME_IS -> "THE_CURRENT_DATE_AND_TIME_IS"
    GO_TO_SETTING -> "GO_TO_SETTING"
    ACCEPT_RIDES_TO_ENTER_RANKINGS -> "ACCEPT_RIDES_TO_ENTER_RANKINGS"
    OTP_HAS_BEEN_RESENT -> "OTP_HAS_BEEN_RESENT"
    OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_RESENDING_OTP -> "OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_RESENDING_OTP"
    OTP_RESENT_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER -> "OTP_RESENT_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER"
    OTP_PAGE_HAS_BEEN_EXPIRED_PLEASE_REQUEST_OTP_AGAIN -> "OTP_PAGE_HAS_BEEN_EXPIRED_PLEASE_REQUEST_OTP_AGAIN"
    SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN -> "SOMETHING_WENT_WRONG_PLEASE_TRY_AGAIN"
    INVALID_REFERRAL_CODE -> "INVALID_REFERRAL_CODE"
    ISSUE_REMOVED_SUCCESSFULLY -> "ISSUE_REMOVED_SUCCESSFULLY"
    OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER -> "OTP_ENTERING_LIMIT_EXHAUSTED_PLEASE_TRY_AGAIN_LATER"
    TOO_MANY_ATTEMPTS_PLEASE_TRY_AGAIN_LATER -> "TOO_MANY_ATTEMPTS_PLEASE_TRY_AGAIN_LATER"
    INVALID_REFERRAL_NUMBER -> "INVALID_REFERRAL_NUMBER"
    SOMETHING_WENT_WRONG_TRY_AGAIN_LATER -> "SOMETHING_WENT_WRONG_TRY_AGAIN_LATER"
    WAIT_TIME -> "WAIT_TIME"
    WAIT_TIMER -> "WAIT_TIMER"
    HOW_LONG_WAITED_FOR_PICKUP -> "HOW_LONG_WAITED_FOR_PICKUP"
    CUSTOMER_WILL_PAY_FOR_EVERY_MINUTE -> "CUSTOMER_WILL_PAY_FOR_EVERY_MINUTE"
    OTHERS -> "OTHERS"
    ENTER_SECOND_SIM_NUMBER -> "ENTER_SECOND_SIM_NUMBER"
    ALTERNATE_NUMBER -> "ALTERNATE_NUMBER"
