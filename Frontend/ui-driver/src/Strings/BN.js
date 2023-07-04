
export function getStringValue(key) {
	if (key in bengaliStrings) {
		return bengaliStrings[key];
	}
	console.error(key + " not found in bengaliStrings");
	return "";
}

const bengaliStrings = {
	LETS_GET_STARTED: "চল শুরু করি",
	YOUR_APPLICATION_HAS_BEEN_SUBMITTED_SUCCESSFULLY_AND_IS_UNDER_VERIFICATION: "আপনার আবেদন সফলভাবে জমা দেওয়া হয়েছে এবং যাচাইয়ের অধীনে রয়েছে",
	VIEW_STATUS: "স্থিতি দেখুন",
	GO_HOME: "বরিতে জ",
	SELECT_LANGUAGE: "ভাষা নির্বাচন কর",
	WHICH_LANGUAGE_DO_YOU_PREFER: "আপনি কোন ভাষা পছন্দ করেন?",
	NEXT: "পরবর্তী",
	T_C: "শর্তাবলী",
	ENTER_MOBILE_NUMBER: "মোবাইল নম্বর লিখুন",
	BY_CLICKING_NEXT_YOU_WILL_BE_AGREEING_TO_OUR: "পরবর্তী আলতো চাপ দিয়ে) ক) আপনি সম্মত হন যে আপনি বিটা টেস্টিংয়ের অংশগ্রহণকারী এবং জুস্পে কোনও ক্ষেত্রে আপনার বিরুদ্ধে কোনও দায়বদ্ধতা রাখবেন না",
	ENTER_OTP: "ওটিপি লিখুন",
	DIDNT_RECIEVE_OTP: "ওটিপি গ্রহণ করেনি?",
	RESEND_OTP: "ওটিপি পুনরায় প্রেরণ করুন",
	PLEASE_ENTER_VALID_OTP: "বৈধ ওটিপি লিখুন দয়া করে",
	INVALID_MOBILE_NUMBER: "অকার্যকর মোবাইল নম্বর",
	REGISTER: "নিবন্ধন",
	MOBILE_NUMBER: "মোবাইল নম্বর",
	AUTO_READING_OTP: "অটো রিডিং ওটিপি ...",
	UPLOAD_DRIVING_LICENSE: "ড্রাইভিং লাইসেন্স আপলোড করুন",
	UPLOAD_BACK_SIDE: "পিছনে পিছনে আপলোড করুন",
	UPLOAD_FRONT_SIDE: "আপনার ডিএল এর ফটো সাইড আপলোড করুন",
	BACK_SIDE: "পিছন দিক",
	FRONT_SIDE: "আপনার ডিএল এর ফটো সাইড",
	LICENSE_INSTRUCTION_PICTURE: "দয়া করে লাইসেন্সের উভয় পক্ষের পরিষ্কার ছবি আপলোড করুন",
	LICENSE_INSTRUCTION_CLARITY: "ফটো নিশ্চিত করুন এবং সমস্ত বিবরণ স্পষ্টভাবে দৃশ্যমান",
	REGISTRATION_STEPS: "নিবন্ধকরণ পদক্ষেপ",
	PROGRESS_SAVED: "আপনার অগ্রগতি সংরক্ষণ করা হয়েছে, আপনি কোনও তথ্য পরিবর্তন করতে পূর্ববর্তী পদক্ষেপে ফিরে যেতে পারেন",
	DRIVING_LICENSE: "ড্রাইভিং লাইসেন্স",
	AADHAR_CARD: "আধার কার্ড",
	BANK_DETAILS: "ব্যাংক বিবরণ",
	VEHICLE_DETAILS: "গাড়ির বিবরণ",
	UPLOAD_FRONT_BACK: "সামনে এবং পিছনের দিক আপলোড করুন",
	EARNINGS_WILL_BE_CREDITED: "আপনার উপার্জন এখানে ক্রেডিট হবে",
	FILL_VEHICLE_DETAILS: "আপনার গাড়ির বিশদ পূরণ করুন",
	FOLLOW_STEPS: "নিবন্ধনের জন্য নীচের পদক্ষেপগুলি অনুসরণ করুন",
	REGISTRATION: "নিবন্ধকরণ",
	UPLOAD_ADHAAR_CARD: "আধার কার্ড আপলোড করুন",
	ADHAAR_INTRUCTION_PICTURE: "দয়া করে আধার কার্ডের উভয় পক্ষের পরিষ্কার ছবি আপলোড করুন",
	ADD_VEHICLE_DETAILS: "গাড়ির বিশদ যুক্ত করুন",
	VEHICLE_REGISTRATION_NUMBER: "গাড়ির রেজিস্ট্রেশন নম্বর",
	RE_ENTER_VEHICLE_REGISTRATION_NUMBER: "পুনরায় প্রবেশের যানবাহন নিবন্ধকরণ নম্বর",
	ENTER_VEHICLE_NO: "যানবাহন নং প্রবেশ করান",
	VEHICLE_TYPE: "গাড়ির ধরন",
	VEHICLE_MODEL_NAME: "গাড়ির মডেল নাম",
	ENTER_MODEL_NAME: "মডেল নাম লিখুন",
	VEHICLE_COLOUR: "গাড়ির রঙ",
	ENTER_VEHICLE_COLOUR: "গাড়ির রঙ প্রবেশ করুন",
	UPLOAD_REGISTRATION_CERTIFICATE: "নিবন্ধকরণ শংসাপত্র আপলোড করুন (আরসি)",
	UPLOAD_RC: "আপলোড আরসি",
	PREVIEW: "পূর্বরূপ",
	CHOOSE_VEHICLE_TYPE: "গাড়ির ধরণ চয়ন করুন",
	BENIFICIARY_NUMBER: "সুবিধাভোগী অ্যাকাউন্ট নং",
	RE_ENTER_BENIFICIARY_NUMBER: "পুনরায় প্রবেশের সুবিধাভোগী অ্যাকাউন্ট নং",
	IFSC_CODE: "আইএফএসসি কোড",
	SENDING_OTP: "ওটিপি প্রেরণ",
	PLEASE_WAIT_WHILE_IN_PROGRESS: "অগ্রগতির সময় অপেক্ষা করুন",
	LIMIT_EXCEEDED: "সীমাবদ্ধতা ছাড়িয়ে গেছে",
	YOUR_REQUEST_HAS_TIMEOUT_TRY_AGAIN: "আপনার অনুরোধে আবার চেষ্টা করুন",
	ERROR_OCCURED_PLEASE_TRY_AGAIN_LATER: "ত্রুটি ঘটেছে দয়া করে পরে আবার চেষ্টা করুন",
	LIMIT_EXCEEDED_PLEASE_TRY_AGAIN_AFTER_10MIN: "সীমাবদ্ধতা ছাড়িয়ে গেছে দয়া করে আবার চেষ্টা করুন",
	ENTER_OTP_SENT_TO: " নম্বরে পাঠানো ওটিপি লিখুন",
	OTP_SENT_TO: " নম্বরে ওটিপি পাঠানো হয়েছে",
	COUNTRY_CODE_INDIA: "+91",
	ENTER_ACCOUNT_NUMBER: "অ্যাকাউন্ট নং প্রবেশ করান",
	ADD_BANK_DETAILS: "ব্যাংকের বিশদ যুক্ত করুন",
	ENTER_IFSC_CODE: "আইএফএসসি কোড প্রবেশ করান",
	SUBMIT: "জমা দিন",
	PERSONAL_DETAILS: "ব্যক্তিগত বিবরণ",
	LANGUAGES: "ভাষা",
	HELP_AND_FAQ: "সহায়তা",
	ABOUT: "অ্যাপ সম্পর্কিত",
	LOGOUT: "প্রস্থান",
	UPDATE: "আপডেট",
	EDIT: "সম্পাদনা",
	AUTO: "অটো",
	NAME: "নাম",
	PRIVACY_POLICY: "গোপনীয়তা নীতি",
	LOGO: "লোগো",
	ABOUT_APP_DESCRIPTION: "জাটি সাথি ড্রাইভার চালকদের সাথে ড্রাইভারদের সংযোগ করার জন্য একটি উন্মুক্ত প্ল্যাটফর্ম। অ্যাপটি প্রস্তাবিত পছন্দসই হার সহ চালকদের সন্ধান করা ড্রাইভারদের পক্ষে সুবিধাজনক করে তোলে। কোনও রাইড ভিত্তিক কমিশন নেই, কেবল মাসিক সাবস্ক্রিপশন আকারে অল্প পরিমাণে অর্থ প্রদান করুন",
	TERMS_AND_CONDITIONS: "শর্তাবলী",
	UPDATE_VEHICLE_DETAILS: "যানবাহন বিশদ আপডেট করুন",
	Help_AND_SUPPORT: "সাহায্য এবং সহযোগিতা",
	NOTE: "বিঃদ্রঃ:",
	VISIT_MY_RIDES_SCREEN_FOR_SPECIFIC_COMPLAINTS: "নির্দিষ্ট অভিযোগের জন্য আমার রাইডস বিভাগটি দেখুন",
	THANK_YOU_FOR_WRTITTING_US: "আমাদের লেখার জন্য আপনাকে ধন্যবাদ!",
	WE_HAVE_RECIEVED_YOUR_ISSUE: "আমরা আপনার সমস্যাটি পুনরুদ্ধার করেছি। আমরা কিছু সময় আপনার কাছে পৌঁছে যাব।",
	GO_TO_HOME: "বাড়িতে যেতে",
	YOUR_RECENT_RIDE: "আপনার সাম্প্রতিক যাত্রা",
	YOUR_RECENT_TRIP: "আপনার সাম্প্রতিক ট্রিপ",
	ALL_TOPICS: "সমস্ত বিষয়",
	REPORT_AN_ISSUE_WITH_THIS_TRIP: "এই ট্রিপ দিয়ে একটি সমস্যা রিপোর্ট করুন",
	YOU_RATED: "আপনি রেট করেছেন:",
	VIEW_ALL_RIDES: "সমস্ত ট্রিপ্স দেখুন",
	WRITE_TO_US: "আমাদের লিখুন",
	SUBJECT: "বিষয়",
	YOUR_EMAIL_ID: "আপনার ইমেল আইডি",
	DESCRIBE_YOUR_ISSUE: "আপনার সমস্যাটি বর্ণনা",
	GETTING_STARTED_AND_FAQ: "শুরু করা এবং FAQss",
	FOR_OTHER_ISSUES_WRITE_TO_US: "অন্যান্য ইস্যুগুলির জন্য, আমাদের লিখুন",
	CALL_SUPPORT_CENTER: "কল সমর্থন কেন্দ্র",
	YOU_CAN_DESCRIBE_ISSUE_THAT_YOU_FACED_HERE: "আপনি এখানে যে সমস্যার মুখোমুখি হয়েছেন তা বর্ণনা করতে পারেন",
	REGISTRATION_CERTIFICATE_IMAGE: "নিবন্ধকরণ শংসাপত্র (আরসি) চিত্র",
	HOME: "বাড়ি",
	RIDES: "রাইডস",
	TRIPS: "ট্রিপ্স",
	PROFILE: "প্রোফাইল",
	ENTER_DRIVING_LICENSE_NUMBER: "ড্রাইভিং লাইসেন্স নম্বর প্রবেশ করান",
	WHERE_IS_MY_LICENSE_NUMBER: "আমার লাইসেন্স নম্বরটি কোথায়?",
	TRIP_DETAILS: "ভ্রমণের বিশদ",
	BY_CASH: "নগদে",
	ONLINE_: "অনলাইন",
	REPORT_AN_ISSUE: "একটি সমস্যা রিপোর্ট",
	DISTANCE: "দূরত্ব",
	TIME_TAKEN: "সময় নিয়েছে",
	OPEN_GOOGLE_MAPS: "গুগল মানচিত্র",
	CALL: "কল",
	START_RIDE: "যাত্রা শুরু করুন",
	CANCEL_RIDE: "যাত্রা বাতিল করুন",
	PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL: "আপনি কেন বাতিল করতে চান দয়া করে আমাদের বলুন",
	MANDATORY: "বাধ্যতামূলক",
	END_RIDE: "শেষ যাত্রা",
	RIDE_COMPLETED_WITH: "গ্রাহকের সাথে যাত্রা সম্পূর্ণ",
	COLLECT_AMOUNT_IN_CASH: "নগদ অর্থ সংগ্রহ করুন",
	CASH_COLLECTED: "নগদ সংগ্রহ করা হয়েছে",
	OFFLINE: "অফলাইন",
	ACCEPT_FOR: "জন্য গ্রহণ:",
	DECLINE: "পতন",
	REQUEST: "অনুরোধ",
	YOU_ARE_OFFLINE: "আপনি অফলাইন",
	YOU_ARE_CURRENTLY_BUSY_GO_ONLINE_TO_RECIEVE_TRIP_REQUESTS: "আপনি বর্তমানে ব্যস্ত। ট্রিপ অনুরোধগুলি পেতে অনলাইনে যান",
	GOING_OFFLINE_WILL_NOT_GET_YOU_ANY_RIDE: "অফলাইনে যাওয়া আপনাকে কোনও যাত্রা পাবে না",
	CANCEL: "বাতিল",
	GO_OFFLINE: "অফলাইন যেতে",
	IS_WAITING_FOR_YOU: "তোমার জন্য অপেক্ষা করছে",
	YOU_ARE_ON_A_RIDE: "আপনি একটি যাত্রায় আছেন ...",
	PLEASE_ASK_RIDER_FOR_THE_OTP: "ওটিপির জন্য রাইডারকে জিজ্ঞাসা করুন",
	COMPLETED_: "সম্পূর্ণ",
	CANCELLED_: "বাতিল",
	WE_NEED_SOME_ACCESS: "আমাদের অ্যাক্সেস অনুসরণ করুন!",
	ALLOW_ACCESS: "ব্যবহারের অনুমতি",
	THANK_YOU_FOR_WRITING_TO_US: "আমাদের লেখার জন্য আপনাকে ধন্যবাদ!",
	RIDER: "রাইডার",
	TRIP_ID: "ট্রিপ আইডি",
	NEED_IT_TO_SHOW_YOU_INCOMING_RIDE_REQUEST: "অ্যাপটি ব্যাকগ্রাউন্ডে থাকাকালীন আগত রাইডের অনুরোধ পান",
	NEED_IT_TO_DISABLE_BATTERY_OPTIMIZATION_FOR_THE_APP: "প্রস্তাবিত, অ্যাপটিকে দীর্ঘকাল ব্যাকগ্রাউন্ডে চালাতে সক্ষম করে",
	NEED_IT_TO_AUTOSTART_YOUR_APP: "অ্যাপটিকে পটভূমিতে চালিয়ে রেখে সহায়তা করে",
	NEED_IT_TO_ENABLE_LOCATION: "জাটি সাথি ড্রাইভার ড্রাইভারের বর্তমান অবস্থান নিরীক্ষণের জন্য আপনার অবস্থানটি ভাগ করে নিতে সক্ষম করতে অবস্থানের ডেটা সংগ্রহ করে, এমনকি অ্যাপটি বন্ধ থাকলেও বা ব্যবহার না করা হয়।",
	OVERLAY_TO_DRAW_OVER_APPLICATIONS: "অ্যাপ্লিকেশনগুলি আঁকুন",
	BATTERY_OPTIMIZATIONS: "ব্যাটারি অপ্টিমাইজেশন",
	AUTO_START_APPLICATION_IN_BACKGROUND: "পটভূমিতে অটোস্টার্ট অ্যাপ",
	LOCATION_ACCESS: "অবস্থান অ্যাক্সেস",
	ENTER_RC_NUMBER: "আরসি নম্বর লিখুন",
	WHERE_IS_MY_RC_NUMBER: "আমার আরসি নম্বরটি কোথায়?",
	STEP: "পদক্ষেপ",
	PAID: "প্রদত্ত",
	ENTERED_WRONG_OTP: "ভুল ওটিপি প্রবেশ করেছে",
	COPIED: "অনুলিপি",
	BANK_NAME: "ব্যাংকের নাম",
	AADHAR_DETAILS: "আধারের বিবরণ",
	AADHAR_NUMBER: "আধার নম্বর",
	FRONT_SIDE_IMAGE: "সামনের দিকের চিত্র",
	BACK_SIDE_IMAGE: "পিছনের দিকের চিত্র",
	STILL_NOT_RESOLVED: "এখনও সমাধান না? আমাদের কল",
	CASE_TWO: "খ)",
	NON_DISCLOUSER_AGREEMENT: "কোন প্রকাশ চুক্তি নেই",
	DATA_COLLECTION_AUTHORITY: "গ) আমি এইভাবে আমার তথ্য সংগ্রহের জন্য জুস্পকে নিয়োগ ও অনুমোদন করি এবং চালিয়ে যাওয়ার মাধ্যমে আমি ব্যবহারের শর্তাদি এবং গোপনীয়তা নীতিমালার সাথে সম্মত হই",
	SOFTWARE_LICENSE: "সফ্টওয়্যার লাইসেন্স",
	LOAD_MORE: "আর ঢুকাও",
	ARE_YOU_SURE_YOU_WANT_TO_LOGOUT: "আপনি লগ আউট করতে চান?",
	GO_BACK: "ফিরে যাও",
	THANK_YOU_FOR_REGISTERING_US: "আমাদের সাথে নিবন্ধনের জন্য আপনাকে ধন্যবাদ!",
	UNFORTANUTELY_WE_ARE_NOT_AVAILABLE__YET_FOR_YOU: "দুর্ভাগ্যক্রমে, আমরা আপনার জন্য এখনও উপলব্ধ নেই। আমরা শীঘ্রই আপনাকে অবহিত করব।",
	ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE: "আপনি কি নিশ্চিত যে আপনি যাত্রাটি শেষ করতে চান?",
	EMPTY_RIDES: "খালি রাইড",
	YOU_HAVE_NOT_TAKEN_A_TRIP_YET: "আপনি এখনও একটি ট্রিপ নিচ্ছেন না",
	BOOK_NOW: "এখনই বুক করুন",
	RESEND_OTP_IN: "ওটিপি ইন পুনরায় পাঠান",
	WE_NEED_ACCESS_TO_YOUR_LOCATION: "আমাদের আপনার অবস্থানের অ্যাক্সেস দরকার!",
	YOUR_LOCATION_HELPS_OUR_SYSTEM: "আপনার অবস্থানটি আমাদের সিস্টেমকে অটোস দ্বারা সমস্ত কাছাকাছি মানচিত্র করতে এবং আপনাকে দ্রুততম যাত্রা সম্ভব করতে সহায়তা করে।",
	NO_INTERNET_CONNECTION: "কোনও ইন্টারনেট সংযোগ নেই",
	PLEASE_CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN: "দয়া করে আপনাকে ইন্টারনেট সংযোগটি পরীক্ষা করুন এবং আবার চেষ্টা করুন",
	TRY_AGAIN: "আবার চেষ্টা কর",
	GRANT_ACCESS: "অনুদান অ্যাক্সেস",
	YOUR_LIMIT_EXCEEDED_TRY_AGAIN_AFTER_10_MIN: "আপনি সীমা ছাড়িয়ে যান, 10 মিনিটের পরে আবার চেষ্টা করুন",
	ENTER_REFERRAL_MOBILE_NUMBER: "রেফারেল মোবাইল নম্বর প্রবেশ করান",
	APPLY: "প্রয়োগ করুন",
	HAVE_A_REFERRAL: "একটি রেফারেল আছে?",
	ADD_HERE: "এখানে যোগ করুন",
	REFERRAL_APPLIED: "রেফারেল প্রয়োগ!",
	SMALLEDIT: "সম্পাদনা",
	ADD_DRIVING_LICENSE: "ড্রাইভিং লাইসেন্স যুক্ত করুন",
	HELP: "সাহায্য?",
	INVALID_DL_NUMBER: "অবৈধ ডিএল নম্বর",
	DRIVING_LICENSE_NUMBER: "ড্রাইভিং লাইসেন্স নম্বর",
	RE_ENTER_DRIVING_LICENSE_NUMBER: "ড্রাইভিং লাইসেন্স নম্বর পুনরায় প্রবেশ করুন",
	ENTER_DL_NUMBER: "ডিএল নম্বর লিখুন",
	SELECT_DATE_OF_BIRTH: "জন্ম তারিখ নির্বাচন করুন",
	DATE_OF_BIRTH: "জন্ম তারিখ",
	WATCH_A_TUTORIAL_FOR_EASY_REGISTRATION: "সহজ \n নিবন্ধকরণের জন্য একটি টিউটোরিয়াল দেখুন",
	ENTER_MINIMUM_FIFTEEN_CHARACTERS: "মিনিয়াম 15 অক্ষর লিখুন",
	ADD_YOUR_FRIEND: "আপনার বন্ধু যোগ করুন",
	PLEASE_WAIT_WHILE_VALIDATING_THE_IMAGE: "চিত্রটি বৈধ করার সময় দয়া করে অপেক্ষা করুন",
	VALIDATING: "বৈধকরণ",
	VERIFICATION_PENDING: "যাচাইকরণ মুলতুবি",
	VERIFICATION_FAILED: "যাচাই ব্যর্থ",
	NO_DOC_AVAILABLE: "কোন নথি উপলব্ধ",
	ISSUE_WITH_DL_IMAGE: "আপনার ডিএল চিত্রের সাথে কিছু সমস্যা রয়েছে বলে মনে হচ্ছে, আমাদের সমর্থন দলটি শীঘ্রই আপনার সাথে যোগাযোগ করবে।",
	STILL_HAVE_SOME_DOUBT: "এখনও কিছু সন্দেহ আছে?",
	ISSUE_WITH_RC_IMAGE: "আপনার আরসি চিত্রের সাথে কিছু সমস্যা রয়েছে বলে মনে হচ্ছে, আমাদের সমর্থন দলটি শীঘ্রই আপনার সাথে যোগাযোগ করবে।",
	PLEASE_CHECK_FOR_IMAGE_IF_VALID_DOCUMENT_IMAGE_OR_NOT: "বৈধ ডকুমেন্ট ইমেজ কিনা দয়া করে চিত্রের জন্য চেক করুন",
	OOPS_YOUR_APPLICATION_HAS_BEEN_REJECTED: "ওফস! আপনার আবেদন প্রত্যাখ্যান করা হয়েছে। অনুগ্রহপূর্বক আবার চেষ্টা করুন",
	INVALID_DRIVING_LICENSE: "অবৈধ ড্রাইভিং লাইসেন্স",
	LIMIT_EXCEEDED_FOR_DL_UPLOAD: "ডিএল আপলোডের জন্য সীমাবদ্ধতা ছাড়িয়ে যায়",
	INVALID_VEHICLE_REGISTRATION_CERTIFICATE: "অবৈধ যানবাহন নিবন্ধকরণ শংসাপত্র",
	LIMIT_EXCEEDED_FOR_RC_UPLOAD: "আরসি আপলোডের জন্য সীমাবদ্ধতা ছাড়িয়ে গেছে",
	YOUR_DOCUMENTS_ARE_APPROVED: "আপনার নথি অনুমোদিত। সমর্থন দল শীঘ্রই আপনার অ্যাকাউন্ট সক্ষম করবে। আপনার অ্যাকাউন্ট সক্ষম করতে আপনি সমর্থন দলকে কল করতে পারেন",
	APPLICATION_STATUS: "আবেদনপত্রের অবস্থা",
	FOR_SUPPORT: "সমর্থন জন্য",
	CONTACT_US: "যোগাযোগ করুন",
	IMAGE_VALIDATION_FAILED: "চিত্রের বৈধতা ব্যর্থ হয়েছে",
	IMAGE_NOT_READABLE: "চিত্র পঠনযোগ্য নয়",
	IMAGE_LOW_QUALITY: "চিত্রের মান ভাল নয়",
	IMAGE_INVALID_TYPE: "প্রদত্ত চিত্রের ধরণটি প্রকৃত ধরণের সাথে মেলে না",
	IMAGE_DOCUMENT_NUMBER_MISMATCH: "এই চিত্রের ডকুমেন্ট নম্বরটি ইনপুটটির সাথে মেলে না",
	IMAGE_EXTRACTION_FAILED: "চিত্র নিষ্কাশন ব্যর্থ হয়েছে",
	IMAGE_NOT_FOUND: "ছবিটি খুঁজে পাওয়া যায়নি",
	IMAGE_NOT_VALID: "চিত্র বৈধ নয়",
	DRIVER_ALREADY_LINKED: "অন্যান্য ডক ইতিমধ্যে ড্রাইভারের সাথে যুক্ত",
	DL_ALREADY_UPDATED: "কর্ম প্রয়োজন. ড্রাইভার লাইসেন্স ইতিমধ্যে ড্রাইভারের সাথে যুক্ত",
	RC_ALREADY_LINKED: "যানবাহন আরসি উপলভ্য নয়। অন্যান্য ড্রাইভারের সাথে যুক্ত",
	RC_ALREADY_UPDATED: "কর্ম প্রয়োজন. যানবাহন আরসি ইতিমধ্যে ড্রাইভারের সাথে যুক্ত",
	DL_ALREADY_LINKED: "ড্রাইভার লাইসেন্স পাওয়া যায় না। অন্যান্য ড্রাইভারের সাথে যুক্ত",
	SOMETHING_WENT_WRONG: "কিছু ভুল হয়েছে",
	PICKUP: "পিকআপ",
	TRIP: "ট্রিপ",
	CURRENTLY_WE_ALLOW_ONLY_KARNATAKA_REGISTERED_NUMBER: "বর্তমানে, আমরা শুধুমাত্র পশ্চিমবঙ্গ নিবন্ধিত নম্বর অনুমোদন করি",
	UPDATED_AT: "ম্যাপ শেষ আপডেট",
	TRIP_COUNT: "আজকের ট্রিপস",
	TODAYS_EARNINGS: "আজকের উপার্জন",
	BONUS_EARNED : "বোনাস অর্জিত",
	GOT_IT : "বুঝেছি!",
	WHAT_IS_NAMMA_YATRI_BONUS : "বোনাস কি?",
	BONUS_PRIMARY_TEXT : "নম্মা যাত্রী বোনাস হল অতিরিক্ত পরিমাণ যা আপনি মিটার চার্জের উপরে পিকআপ চার্জ, গ্রাহকের টিপস এবং ড্রাইভার যোগের আকারে অর্জন করেছেন।",
    BONUS_SECONDARY_TEXT : "নম্মা যাত্রী বোনাসের পরিমাণ আপনার মোট উপার্জনের অংশ।",
	DATE_OF_REGISTRATION: "নিবন্ধনের তারিখ",
	SELECT_DATE_OF_ISSUE: "ইস্যুর তারিখ নির্বাচন করুন",
	DATE_OF_ISSUE: "প্রদান এর তারিখ",
	PROVIDE_DATE_OF_ISSUE_TEXT: "দুঃখিত, আমরা আপনার বিশদটি বৈধতা দিতে পারি না, আপনার ড্রাইভিং লাইসেন্সটি বৈধতা পেতে দয়া করে <b> ইস্যুর তারিখ </b> সরবরাহ করুন।",
	PROVIDE_DATE_OF_REGISTRATION_TEXT: "দুঃখিত আমরা আপনার বিশদটি বৈধতা দিতে পারি না, আপনার গাড়ির বিশদটি বৈধতা পেতে দয়া করে <b> নিবন্ধকরণের তারিখ </b> সরবরাহ করুন।",
	SELECT_DATE_OF_REGISTRATION: "নিবন্ধকরণের তারিখ নির্বাচন করুন",
	SAME_REENTERED_RC_MESSAGE: "দয়া করে নিশ্চিত হয়ে নিন",
	SAME_REENTERED_DL_MESSAGE: "পুনরায় প্রবেশ করা ডিএল নম্বর উপরে প্রদত্ত ডিএল নম্বরটির সাথে মেলে না",
	WHERE_IS_MY_ISSUE_DATE: "আমার ইস্যু তারিখ কোথায়?",
	WHERE_IS_MY_REGISTRATION_DATE: "নিবন্ধের তারিখ কোথায়?",
	OTP_RESENT: "ওটিপি বিরক্তি",
	EARNINGS_CREDITED_IN_ACCOUNT: "আপনার উপার্জন এই অ্যাকাউন্টে জমা দেওয়া হবে",
	INVALID_PARAMETERS: "অবৈধ পরামিতি",
	UNAUTHORIZED: "অননুমোদিত",
	INVALID_TOKEN: "অবৈধ টোকেন",
	SOME_ERROR_OCCURED_IN_OFFERRIDE: "অফারাইডে কিছু ত্রুটি ঘটেছিল",
	SELECT_VEHICLE_TYPE: "গাড়ির ধরণ নির্বাচন করুন",
	RIDE: "যাত্রা",
	NO_LOCATION_UPDATE: "কোনও অবস্থান আপডেট নেই",
	GOT_IT_TELL_US_MORE: "পেয়েছি, আরও বলুন?",
	WRITE_A_COMMENT: "একটি মন্তব্য লিখুন",
	HOW_WAS_YOUR_RIDE_WITH: "আপনার যাত্রা কেমন ছিল",
	RUDE_BEHAVIOUR: "অভদ্র আচরণ",
	LONG_WAITING_TIME: "দীর্ঘ সময় অপেক্ষা",
	DIDNT_COME_TO_PICUP_LOCATION: "পিকআপ লোকেশনে আসেনি",
	HELP_US_WITH_YOUR_REASON: "আপনার কারণ দিয়ে আমাদের সহায়তা করুন",
	MAX_CHAR_LIMIT_REACHED: "সর্বোচ্চ চরিত্রের সীমা পৌঁছেছে,",
	SHOW_ALL_OPTIONS: "সমস্ত বিকল্প দেখান",
	UPDATE_REQUIRED: "আপডেট প্রয়োজন",
	PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE: "পরিষেবা চালিয়ে যেতে অ্যাপ্লিকেশন আপডেট করুন",
	NOT_NOW: "এখন না",
	OF: "এর",
	DROP: "ড্রপ",
	PLEASE_WAIT: "অনুগ্রহপূর্বক অপেক্ষা করুন",
	SETTING_YOU_OFFLINE: "আমরা আপনাকে অফলাইন সেট করছি",
	SETTING_YOU_ONLINE: "আমরা আপনাকে অনলাইনে সেট করছি",
	SETTING_YOU_SILENT: "আমরা আপনাকে সাইলেন্ট সেট করছি",
	VIEW_BREAKDOWN: "ব্রেকডাউন দেখুন",
	APP_INFO: "অ্যাপ্লিকেশন তথ্য",
	OTHER: "অন্য",
	VEHICLE_ISSUE: "যানবাহন সমস্যা",
	FARE_UPDATED: "ভাড়া আপডেট হয়েছে",
	FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES: "ঘন ঘন বাতিলকরণগুলি কম রাইড এবং কম রেটিংয়ের দিকে পরিচালিত করবে",
	CONTINUE: "চালিয়ে যান",
	CONFIRM_PASSWORD: "পাসওয়ার্ড নিশ্চিত করুন",
	DEMO_MODE: "ডেমো মোড",
	PASSWORD: "পাসওয়ার্ড",
	ENTER_DEMO_MODE_PASSWORD: "ডেমো মোড পাসওয়ার্ড লিখুন",
	DEMO_MODE_DISABLED: "ডেমো মোড অক্ষম",
	ONLINE_VIA_DEMO_MODE: "অনলাইন (ডেমো)",
	MORE: "আরও",
	LESS: "কম",
	YOU_ARE_AT_PICKUP: "আপনি পিকআপ লোকেশনে আছেন",
	WAITING_FOR_CUSTOMER: "আপনি অপেক্ষা করছেন",
	CUSTOMER_NOTIFIED: "গ্রাহক বিজ্ঞপ্তি",
	I_ARRIVED: "আমি এসেছি",
	ESTIMATED_RIDE_FARE: "আনুমানিক রাইড ভাড়া:",
	PICKUP_TOO_FAR: "পিকআপ খুব দূরে",
	CUSTOMER_NOT_PICKING_CALL: "গ্রাহক কল বাছাই করছেন না",
	TRAFFIC_JAM: "ট্রাফিক জ্যাম",
	CUSTOMER_WAS_RUDE: "গ্রাহক অভদ্র ছিল",
	ALL_MESSAGES: "সমস্ত বার্তা",
	MESSAGES: "বার্তা",
	ADD_A_COMMENT: "একটি মন্তব্য যুক্ত করুন",
	POST_COMMENT: "পোস্ট মন্তব্য",
	ENTER_YOUR_COMMENT: "আপনার মন্তব্য লিখুন",
	NO_NOTIFICATIONS_RIGHT_NOW: "এখনই কোনও বিজ্ঞপ্তি নেই!",
	NO_NOTIFICATIONS_RIGHT_NOW_DESC: "যখন নতুন কোনও বিজ্ঞপ্তি আসবে তখন আমরা আপনাকে জানাব",
	ALERTS: "সতর্কতা",
	YOUR_COMMENT: "আপনার মন্তব্য",
	SHOW_MORE: "আরও দেখান",
	LOAD_OLDER_ALERTS: "পুরানো সতর্কতাগুলি লোড করুন",
	CONTEST: "প্রতিযোগিতা",
	YOUR_REFERRAL_CODE_IS_LINKED: "আপনার রেফারেল কোড লিঙ্কযুক্ত!",
	YOU_CAN_NOW_EARN_REWARDS: "আপনি এখন গ্রাহকদের উল্লেখ করার জন্য পুরষ্কার অর্জন করতে পারেন!",
	COMING_SOON: "শীঘ্রই আসছে!",
	COMING_SOON_DESCRIPTION: "আমরা আপনাকে রেফারেল প্রোগ্রামে বোর্ডে নিয়ে যাওয়ার কাজ করছি। আরও তথ্যের জন্য সতর্কতা পৃষ্ঠাটি দেখুন।",
	REFERRAL_CODE: "রেফারেল কোড",
	REFERRAL_CODE_HINT: "6-অঙ্কের রেফারেল কোড লিখুন",
	CONFIRM_REFERRAL_CODE: "রেফারেল কোড নিশ্চিত করুন",
	CONFIRM_REFERRAL_CODE_HINT: "রেফারাল কোড পুনরায় প্রবেশ করুন",
	YOUR_REFERRAL_CODE: "আপনার রেফারাল কোড",
	FIRST_REFERRAL_SUCCESSFUL: "প্রথম রেফারাল সফল! \n পুরষ্কার আনলক!",
	AWAITING_REFERRAL_RIDE: "রেফারাল রাইডের অপেক্ষায়",
	CHECK_THIS_SPACE_WHEN_YOU_GET_REFERRAL_ALERT: "আপনি যখন রেফারেল সতর্কতা পাবেন তখন এই স্থানটি পরীক্ষা করুন",
	REFERRED_CUSTOMERS: "গ্রাহকদের রেফারেন্স",
	ACTIVATED_CUSTOMERS: "সক্রিয় গ্রাহক",
	REFERRAL_CODE_LINKING: "রেফারেল কোড লিঙ্কিং",
	CONTACT_SUPPORT: "যোগাযোগ সমর্থন",
	CALL_SUPPORT: "কল সমর্থন",
	YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT: "আপনি জাত্রি সাথি সমর্থন দলকে কল করতে চলেছেন। আপনি কি এগিয়ে যেতে চান?",
	REFERRAL_ENROLMENT: "রেফারেল তালিকাভুক্তি",
	REFERRALS: "প্রচার",
	LINK_REFERRAL_CODE: "লিঙ্ক রেফারেল কোড",
	DRIVER_DETAILS: "ড্রাইভার বিবরণ",
	FOR_UPDATES_SEE_ALERTS: "আপডেটের জন্য, সতর্কতাগুলি দেখুন",
	SHARE_OPTIONS: "ভাগ বিকল্প",
	ENTER_PASSWORD: "পাসওয়ার্ড লিখুন",
	YOUR_VEHICLE: "আপনার বাহন",
	BOOKING_OPTIONS: "বুকিং অপশন",
	CONFIRM_AND_CHANGE: "পরিবর্তন নিশ্চিত করুন",
	OTP: "OTP",
	MAKE_YOURSELF_AVAILABLE_FOR : "এছাড়াও রাইড গ্রহণ করুন",
	SILENT_MODE_PROMPT : "আপনি যদি বিরক্ত হতে না চান তবে আপনি পরিবর্তে সাইলেন্ট মোডে স্যুইচ করতে পারেন",
	GO_SILENT : "চুপ করে যাও",
	TRY_SILENT_MODE : "নীরব মোড চেষ্টা করবেন?",
	RIDE_FARE : "রাইড ভাড়া" ,
	RIDE_DISTANCE : "যাত্রা দূরত্ব",
	FARE_UPDATED : "ভাড়া আপডেট হয়েছে",
	START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS : "এই দ্রুত চ্যাট পরামর্শগুলি ব্যবহার করে আপনার চ্যাট শুরু করুন",
	START_YOUR_CHAT_WITH_THE_DRIVER : "ড্রাইভারের সাথে আপনার চ্যাট শুরু করুন",
	MESSAGE : "বার্তা",
	I_AM_ON_MY_WAY : "আমি গন্তব্যের পথে",
	GETTING_DELAYED_PLEASE_WAIT : "বিলম্ব হচ্ছে, দয়া করে অপেক্ষা করুন",
	UNREACHABLE_PLEASE_CALL_BACK : "অ্যাক্সেসযোগ্য, দয়া করে ফিরে কল করুন",
	ARE_YOU_STARING : "আপনি কি শুরু করছেন?",
	PLEASE_COME_SOON : "দয়া করে শীঘ্রই আসুন",
	OK_I_WILL_WAIT : "আচ্ছা আমি অপেক্ষা করব",
	I_HAVE_ARRIVED : "আমি এসেছি",
	PLEASE_COME_FAST_I_AM_WAITING : "দয়া করে দ্রুত আসুন, আমি অপেক্ষা করছি",
	PLEASE_WAIT_I_WILL_BE_THERE : "দয়া করে অপেক্ষা করুন, আমি সেখানে থাকব",
	LOOKING_FOR_YOU_AT_PICKUP : "পিক-আপে আপনাকে খুঁজছেন",
	SILENT : "নীরব",
	GO_ONLINE : "যাওয়া!",
	GO_ONLINE_PROMPT : "আপনি বর্তমানে অফলাইনে রয়েছেন \ n n রাইডের অনুরোধগুলি পেতে, এখনই অনলাইনে যান!",
	LIVE_DASHBOARD : "লাইভ স্ট্যাটাস ড্যাশবোর্ড",
	CLICK_TO_ACCESS_YOUR_ACCOUNT : "আপনার অ্যাকাউন্ট অ্যাক্সেস করতে এখানে ক্লিক করুন",
	ADD_ALTERNATE_NUMBER : "বিকল্প নম্বর যুক্ত করুন",
	ENTER_ALTERNATE_MOBILE_NUMBER : "বিকল্প মোবাইল নম্বর লিখুন",
	EDIT_ALTERNATE_MOBILE_NUMBER : "বিকল্প মোবাইল নম্বর সম্পাদনা করুন",
	PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER : "দয়া করে একটি বৈধ 10-অঙ্কের নম্বর লিখুন",
	ALTERNATE_MOBILE_NUMBER : "বিকল্প মোবাইল নম্বর",
	REMOVE : "অপসারণ",
	REMOVE_ALTERNATE_NUMBER : "বিকল্প নম্বর সরান",
	ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER : "আপনি কি নিশ্চিত যে আপনি আপনার বিকল্প মোবাইল নম্বরটি সরিয়ে ফেলতে চান?",
	YES_REMOVE_IT : "হ্যাঁ, এটি সরান",
	NUMBER_REMOVED_SUCCESSFULLY : "নম্বর সফলভাবে সরানো হয়েছে",
	NUMBER_ADDED_SUCCESSFULLY : "নম্বর সফলভাবে যুক্ত হয়েছে",
	NUMBER_EDITED_SUCCESSFULLY : "নম্বর সফলভাবে আপডেট হয়েছে",
	ALTERNATE_MOBILE_OTP_LIMIT_EXCEED : "ওটিপি সীমা ছাড়িয়ে গেছে, আবার নম্বর এবং ওটিপি প্রবেশ করান",
	WRONG_OTP : "বৈধ ওটিপি লিখুন দয়া করে ",
	ATTEMPTS_LEFT : " চেষ্টা বাকি",
	ATTEMPT_LEFT : " বাম চেষ্টা",
	OTP_LIMIT_EXCEEDED : "ওটিপি সীমা ছাড়িয়ে গেছে",
	OTP_LIMIT_EXCEEDED_MESSAGE : "আপনি আপনার ওটিপি সীমাতে পৌঁছেছেন। 10 মিনিটের পরে আবার চেষ্টা করুন।",
	TRY_AGAIN_LATER : "পরে আবার চেষ্টা করুন",
	NUMBER_ALREADY_EXIST_ERROR : "অন্য অ্যাকাউন্টের সাথে যুক্ত নম্বর! অন্য নম্বর ব্যবহার করুন",
	OTP_RESEND_LIMIT_EXCEEDED : "ওটিপি সীমা ছাড়িয়ে গেছে",
	LIMIT_EXCEEDED_FOR_ALTERNATE_NUMBER : "কিছুক্ষণ পরে আবার চেষ্টা করুন",
	ALTERNATE_NUMBER_CANNOT_BE_ADDED : "বিকল্প নম্বর যুক্ত করা যাবে না",
	ADD_ALTERNATE_NUMBER_IN_MEANTIME : "এই প্রক্রিয়াটি 2 কার্যদিবসের সময় নিতে পারে \ n সম্পূর্ণ হতে পারে। ইতিমধ্যে, আপনি একটি বিকল্প মোবাইল নম্বর যুক্ত করুন।",
	VERIFICATION_IS_TAKING_A_BIT_LONGER : "দেখে মনে হচ্ছে আপনার যাচাইকরণটি প্রত্যাশার চেয়ে কিছুটা \ nlonger নিচ্ছে \ \ n আপনি আপনাকে সহায়তা করতে সহায়তার সাথে যোগাযোগ করতে পারেন।",
	COMPLETE_ONBOARDING : "অনবোর্ডিং সম্পূর্ণ",
	PERSON_WITH_THIS_NUMBER_ALREADY_EXISTS : "এই মোবাইল নম্বর সহ ব্যক্তি ইতিমধ্যে বিদ্যমান।",
	OTP_ : "OTP",
	MAPS: "Maps",
	Demo : "Demo",
	DELETE : "মুছে ফেলা",
	VIEW : "দেখুন",
	ISSUE_NO : "ইস্যু নং ",
	ADD_VOICE_NOTE : "ভয়েস নোট যোগ করুন",
	VOICE_NOTE_ADDED : "ভয়েস নোট যোগ করা হয়েছে",
	SUBMIT_ISSUE_DETAILS : "ইস্যু বিবরণ জমা দিন",
	IMAGE_PREVIEW : "ছবির পূর্বরূপ",
	RIDE_REPORT_ISSUE : "সমস্যা রিপোর্ট করার জন্য একটি রাইড নির্বাচন করুন",
	ADDED_IMAGES : "ছবি যোগ করা হয়েছে",
	NO_IMAGES_ADDED : "কোন ছবি যোগ করা হয়নি",
	ASK_DETAILS_MESSAGE : "অনুগ্রহ করে আরো কিছু বিস্তারিত জানান। আপনি আরও ভালভাবে বিস্তারিত জানাতে ছবি বা ভয়েস নোট পাঠাতে পারেন।",
	ASK_DETAILS_MESSAGE_REVERSED : "হারিয়ে যাওয়া আইটেম সম্পর্কে আরো বিস্তারিত শেয়ার করুন. আপনি আরও ভালভাবে বিস্তারিত জানাতে ছবি বা ভয়েস নোট পাঠাতে পারেন।",
	SELECT_OPTION : "আপনি যদি এইগুলির কোনটির মুখোমুখি হন তবে দয়া করে আমাদের বলুন",
	SELECT_OPTION_REVERSED : "আপনি কিভাবে এই সমস্যা সমাধান করতে চান?",
	ISSUE_SUBMITTED_MESSAGE : "বিস্তারিত প্রাপ্ত! আপনার সমস্যা সমাধানের জন্য আমাদের দল আপনাকে 24 ঘন্টার মধ্যে কল করবে।",
	I_DONT_KNOW_WHICH_RIDE : "আমি জানি না কোন রাইড",
	REPORT_ISSUE_CHAT_PLACEHOLDER : "আপনার সমস্যাটি বর্ণনা. আমরা 24 ঘন্টার মধ্যে এটি সমাধান করার চেষ্টা করব।",
	PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP : "অনুগ্রহ করে গ্রাহককে OTP-এর জন্য জিজ্ঞাসা করুন",
	ADDED_VOICE_NOTE : "ভয়েস নোট যোগ করা হয়েছে",
	NO_VOICE_NOTE_ADDED : "কোন ভয়েস নোট যোগ করা হয়নি",
	CALL_CUSTOMER_TITLE : "গ্রাহককে কল করবেন?",
	CALL_CUSTOMER_DESCRIPTION : "আপনি গ্রাহককে একটি কল করতে চলেছেন৷ আপনি কি এগিয়ে যেতে চান?",
	PLACE_CALL : "কল করুন",
	ADD_IMAGE : "ছবি যোগ কর",
	ADD_ANOTHER : "আরেকটি যোগ করুন",
	IMAGES_ADDED : "ছবি যোগ করা হয়েছে",
	ISSUE_SUBMITTED_TEXT : "অপেক্ষা কর! আমরা আপনার সমস্যা সমাধানে কাজ করছি",
	CHOOSE_AN_OPTION : "চালিয়ে যাওয়ার জন্য একটি বিকল্প বেছে নিন",
	IMAGE_ADDED : "ইমেজ যোগ করা হয়েছে",
	DONE : "সম্পন্ন",
	RECORD_VOICE_NOTE : "ভয়েস নোট রেকর্ড করুন",
	HELP_AND_SUPPORT : "সাহায্য সহযোগীতা",
	MORE_OPTIONS : "আরও বিকল্প",
	ONGOING_ISSUES : "চলমান সমস্যা",
	RESOLVED_ISSUES : "সমাধান করা সমস্যা",
	RESOLVED_ISSUE : "সমাধান করা সমস্যা",
	ONGOING_ISSUE : "চলমান সমস্যা",
	LOST_ITEM : "হারিয়ে যাওয়া আইটেম",
	RIDE_RELATED_ISSUE : "রাইড সম্পর্কিত সমস্যা",
	APP_RELATED_ISSUE : "অ্যাপ সম্পর্কিত সমস্যা",
	FARE_RELATED_ISSUE : "ভাড়া সম্পর্কিত সমস্যা",
	MAX_IMAGES : "সর্বোচ্চ ৩টি ছবি আপলোড করা যাবে",
	ISSUE_NUMBER : "ইস্যু নং  ",
	REMOVE_ISSUE : "সমস্যা সরান" ,
	CALL_SUPPORT_NUMBER : "যোগাযোগ সমর্থন",
	YEARS_AGO : " অনেক বছর আগে",
	MONTHS_AGO : " মাস কতক পূর্বে",
	DAYS_AGO : " দিন আগে",
	HOURS_AGO : " ঘন্টা আগে",
	MIN_AGO : " মিনিট আগে",
	SEC_AGO : " সেকেন্ড আগে",
	ISSUE_REMOVED : "সমস্যা সরানো হয়েছে",
	LOADING : "লোড হচ্ছে",
	APP_RELATED : "অ্যাপ সম্পর্কিত",
	FARE_RELATED : "ভাড়া সম্পর্কিত",
	RIDE_RELATED : "রাইড সম্পর্কিত",
	LOST_AND_FOUND : "হারানো এবং প্রাপ্তি",
	REPORT_LOST_ITEM : "হারানো আইটেম রিপোর্ট করুন",
	SELECT_YOUR_GENDER : "আপনার লিঙ্গ নির্বাচন",
	FEMALE : "মহিলা",
	MALE : "পুরুষ",
	PREFER_NOT_TO_SAY : "বলতে না পছন্দ",
	GENDER : "লিঙ্গ",
	SET_NOW : "এখন সেট করুন",
	COMPLETE_YOUR_PROFILE_AND_FIND_MORE_RIDES : "আপনার প্রোফাইল সম্পূর্ণ করুন এবং আরো রাইড খুঁজুন!",
	UPDATE_NOW : "এখন হালনাগাদ করুন",
	CONFIRM : "নিশ্চিত করুন",
	GENDER_UPDATED : "লিঙ্গ আপডেট করা হয়েছে",
	COMPLAINTS_GRIEVANCES : "অভিযোগ এবং অভিযোগ",
	COMPLAINTS_DESCRIPTION : "কোনো অভিযোগের জন্য, অনুগ্রহ করে আমাদের সাথে <u>yatrisathi.support@wb.gov.in</u> এ যোগাযোগ করুন;",
	COMPLAINTS_DESCRIPTION_ADDITIONAL : "অভিযোগের প্রতিকারের জন্য, অনুগ্রহ করে আমাদের <u>গোপনীয়তা নীতি</u> পড়ুন",
	REGISTERED_ADDRESS : "নিবন্ধিত ঠিকানা",
	REGISTERED_ADDRESS_DESCRIPTION : "স্ট্যালিয়ন বিজনেস সেন্টার, নং 444, 3য় এবং 4র্থ তলা, 18 তম প্রধান, 6 তম ব্লক, কোরামঙ্গলা, বেঙ্গালুরু, কর্ণাটক- 560095, ভারত",
	ZONE_CANCEL_TEXT_DROP : "আপনার গ্রাহক সম্ভবত সময়মতো মেট্রো স্টেশনে পৌঁছানোর জন্য তাড়াহুড়ো করছেন! \n আমরা আপনাকে বাতিল না করার জন্য অনুরোধ করছি।",
	ZONE_CANCEL_TEXT_PICKUP : "আপনার গ্রাহক সম্ভবত তাদের গন্তব্যে পৌঁছানোর জন্য তাড়াহুড়ো করছেন। \n আমরা আপনাকে বাতিল না করার জন্য অনুরোধ করছি।",
	RANKINGS : "র‍্যাঙ্কিং",
	GETTING_THE_LEADERBOARD_READY : "লিডারবোর্ড তৈরি করা হচ্ছে!",
	PLEASE_WAIT_WHILE_WE_UPDATE_THE_DETAILS : "আমরা বিস্তারিত আপডেট করা পর্যন্ত অপেক্ষা করুন",
	LAST_UPDATED : "সর্বশেষ আপডেট: ",
	CONGRATULATIONS_YOU_ARE_RANK : "অভিনন্দন! আপনি র্যাঙ্ক ",
	YOU : " (আপনি)",
	DAILY : "দৈনিক",
	WEEKLY : "সাপ্তাহিক"
	}
