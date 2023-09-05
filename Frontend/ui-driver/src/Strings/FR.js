export function getStringValue(key) {
  if (key in frenchStrings) {
    return frenchStrings[key];
  }
  console.error(key + " not found in englishStrings");
  return "";
}

const frenchStrings = {
  LETS_GET_STARTED: "Commençons",
  YOUR_APPLICATION_HAS_BEEN_SUBMITTED_SUCCESSFULLY_AND_IS_UNDER_VERIFICATION: "Votre demande a été soumise avec succès et est en cours de vérification",
  VIEW_STATUS: "Afficher l'état",
  GO_HOME: "Retour au domicile",
  SELECT_LANGUAGE: "Choisir la langue",
  WHICH_LANGUAGE_DO_YOU_PREFER: "Quelle langue préférez-vous?",
  NEXT: "Suivant",
  T_C: "Conditions générales d'utilisation",
  ENTER_MOBILE_NUMBER: "Entrez votre numéro de mobile",
  BY_CLICKING_CONTINUE_YOU_WILL_BE_AGREEING_TO_OUR: "En cliquant sur Continuer, vous acceptez nos",
  ENTER_OTP: "Entrez votre code à usage unique",
  DIDNT_RECIEVE_OTP: "Vous n'avez pas reçu de code à usage unique?",
  RESEND_OTP: "Renvoyer un code à usage unique",
  PLEASE_ENTER_VALID_OTP: "Veuillez saisir un code à usage unique valide",
  INVALID_MOBILE_NUMBER: "Numéro de portable invalide",
  REGISTER: "S'enregistrer",
  MOBILE_NUMBER: "Numéro de portable",
  AUTO_READING_OTP: "Lire automatique le code à usage unique ",
  UPLOAD_DRIVING_LICENSE: "Charger le permis de conduire",
  UPLOAD_BACK_SIDE: "Charger la face arrière",
  UPLOAD_FRONT_SIDE: "Charger une photo de la face avant de votre permis de conduire",
  BACK_SIDE: "face arrière",
  FRONT_SIDE: "Face avant de votre permis de conduire",
  LICENSE_INSTRUCTION_PICTURE: "Veuillez charger des photos lisibles des deux faces du permis",
  LICENSE_INSTRUCTION_CLARITY: "Assurez-vous que la photo et tous les détails sont clairement visibles",
  REGISTRATION_STEPS: "Étapes d'inscription",
  PROGRESS_SAVED: "Vos progrès sont enregistrés, vous pouvez également revenir aux étapes précédentes pour modifier les informations",
  DRIVING_LICENSE: "Permis de conduire",
  AADHAR_CARD: "Carte Aadhar",
  BANK_DETAILS: "Coordonnées bancaires",
  VEHICLE_DETAILS: "Détails du véhicule",
  UPLOAD_FRONT_BACK: "Charger la face avant et arrière",
  EARNINGS_WILL_BE_CREDITED: "Vos revenus seront crédités ici",
  FILL_VEHICLE_DETAILS: "Renseignez les informations de votre véhicule",
  FOLLOW_STEPS: "Veuillez suivre les étapes ci-dessous pour vous inscrire",
  REGISTRATION: "Inscription",
  UPLOAD_ADHAAR_CARD: "Télécharger la carte Aadhar",
  ADHAAR_INTRUCTION_PICTURE: "Veuillez télécharger des photos lisibles des deux faces de la carte Aadhar",
  ADD_VEHICLE_DETAILS: "Ajouter les informations du véhicule",
  VEHICLE_REGISTRATION_NUMBER: "Numéro d'immatriculation du véhicule",
  RE_ENTER_VEHICLE_REGISTRATION_NUMBER: "Entrez à nouveau le Numéro d'enregistrement du véhicule",
  ENTER_VEHICLE_NO: "Entrez le n° de véhicule",
  VEHICLE_TYPE: "Type de véhicule",
  VEHICLE_MODEL_NAME: "Nom du modèle de véhicule",
  ENTER_MODEL_NAME: "Entrez le nom du modèle",
  VEHICLE_COLOUR: "Couleur du véhicule",
  ENTER_VEHICLE_COLOUR: "Entrez la couleur du véhicule",
  UPLOAD_REGISTRATION_CERTIFICATE: "Charger le certificat d'enregistrement (CE)",
  UPLOAD_RC: "Charger le CE",
  PREVIEW: "Aperçu",
  CHOOSE_VEHICLE_TYPE: "Choisissez le type de véhicule",
  BENIFICIARY_NUMBER: "n° de Compte Bénéficiaire",
  RE_ENTER_BENIFICIARY_NUMBER: "Renseignez à nouveau le n° de Compte Bénéficiaire",
  IFSC_CODE: "Code IFSC",
  SENDING_OTP: "Envoi du code à usage unique",
  PLEASE_WAIT_WHILE_IN_PROGRESS: "Veuillez patienter, chargement en cours",
  LIMIT_EXCEEDED: "Limite dépassée",
  YOUR_REQUEST_HAS_TIMEOUT_TRY_AGAIN: "Votre demande a expiré, réessayez plus tard",
  ERROR_OCCURED_PLEASE_TRY_AGAIN_LATER: "Une erreur s'est produite, s'il vous plaît réessayez plus tard",
  LIMIT_EXCEEDED_PLEASE_TRY_AGAIN_AFTER_10MIN: "Limite dépassée, s'il vous plaît réessayez plus tard",
  ENTER_OTP_SENT_TO: "Entrez le code à usage unique envoyé à",
  OTP_SENT_TO: "Code à usage unique envoyé à",
  COUNTRY_CODE_INDIA: "(+91)",
  ENTER_ACCOUNT_NUMBER: "Entrez le numéro de compte",
  ADD_BANK_DETAILS: "Ajouter les informations bancaires",
  ENTER_IFSC_CODE: "Entrez le code IFSC",
  SUBMIT: "Soumettre",
  PERSONAL_DETAILS: "Informations personnelles",
  LANGUAGES: "Langues",
  HELP_AND_FAQ: "Aide et FAQ",
  ABOUT: "À propos de",
  LOGOUT: "Se déconnecter",
  UPDATE: "Mise à jour",
  EDIT: "Modifier",
  AUTO: "Auto",
  NAME: "Nom",
  PRIVACY_POLICY: "Politique de confidentialité",
  LOGO: "Logo",
  ABOUT_APP_DESCRIPTION: "Le partenaire Namma Yatri est une plateforme ouverte de mise en relation des chauffeurs et des clients. L'application permet aux conducteurs de trouver des chauffeurs aux tarifs proposés. Il n'y a pas de commission basée sur la course : il suffit de payer un petit montant sous la forme d'un abonnement mensuel",
  TERMS_AND_CONDITIONS: "Conditions générales d'utilisation",
  UPDATE_VEHICLE_DETAILS: "Mettre à jour les informations du véhicule",
  Help_AND_SUPPORT: "Aide et service client",
  NOTE: "Note:",
  VISIT_MY_RIDES_SCREEN_FOR_SPECIFIC_COMPLAINTS: "Visitez la section My Rides pour des plaintes spécifiques",
  THANK_YOU_FOR_WRTITTING_US: "Merci de nous avoir écrits!",
  WE_HAVE_RECIEVED_YOUR_ISSUE: "Nous avons reçu votre problème Nous vous contacterons sous peu",
  GO_TO_HOME: "Aller à la maison",
  YOUR_RECENT_RIDE: "Votre dernière course",
  YOUR_RECENT_TRIP: "Votre dernier voyage",
  ALL_TOPICS: "Tous les sujets",
  REPORT_AN_ISSUE_WITH_THIS_TRIP: "Signaler un problème avec cette course",
  YOU_RATED: "Vous avez noté:",
  VIEW_ALL_RIDES: "Afficher toutes les courses",
  WRITE_TO_US: "Écrivez-nous",
  SUBJECT: "Sujet",
  YOUR_EMAIL_ID: "Votre adresse courriel",
  DESCRIBE_YOUR_ISSUE: "Décrivez votre problème",
  GETTING_STARTED_AND_FAQ: "Démarrage et foire aux questions",
  FOR_OTHER_ISSUES_WRITE_TO_US: "Pour d'autres questions, écrivez-nous",
  CALL_SUPPORT_CENTER: "Centre d'assistance téléphonique",
  YOU_CAN_DESCRIBE_ISSUE_THAT_YOU_FACED_HERE: "Vous pouvez décrire le problème auquel vous avez été confronté ici",
  REGISTRATION_CERTIFICATE_IMAGE: "Image du certificat d'enregistrement (CE)",
  HOME: "Accueil",
  RIDES: "Courses",
  TRIPS: "Trajets",
  PROFILE: "Profil",
  ENTER_DRIVING_LICENSE_NUMBER: "Entrez le numéro de permis de conduire",
  WHERE_IS_MY_LICENSE_NUMBER: "Où est mon numéro de permis ?",
  TRIP_DETAILS: "Détails du trajet",
  BY_CASH: "en espèces",
  ONLINE_: "En ligne",
  REPORT_AN_ISSUE: "Signaler un problème",
  DISTANCE: "Distance",
  TIME_TAKEN: "Temps pris",
  MAPS: "Cartes",
  CALL: "Appeler",
  START_RIDE: "Démarrer la course",
  CANCEL_RIDE: "Annuler la course",
  PLEASE_TELL_US_WHY_YOU_WANT_TO_CANCEL: "Veuillez nous dire pourquoi vous souhaitez annuler",
  MANDATORY: "Obligatoire",
  END_RIDE: "Mettre fin à la course",
  RIDE_COMPLETED_WITH: "Course terminée avec le client",
  COLLECT_AMOUNT_IN_CASH: "Percevoir le montant en espèces",
  CASH_COLLECTED: "L'argent encaissé",
  OFFLINE: "Hors ligne",
  ACCEPT_FOR: "Accepter:",
  DECLINE: "Refuser",
  REQUEST: "Demander",
  YOU_ARE_OFFLINE: "Vous êtes hors ligne",
  YOU_ARE_CURRENTLY_BUSY_GO_ONLINE_TO_RECIEVE_TRIP_REQUESTS: "Vous avez actuellement le statut occupé. Placez votre statut sur en ligne pour recevoir des demandes de course",
  GOING_OFFLINE_WILL_NOT_GET_YOU_ANY_RIDE: "Se déconnecter vous empêchera de recevoir des courses",
  CANCEL: "Annuler",
  GO_OFFLINE: "Se déconnecter",
  IS_WAITING_FOR_YOU: "est entrain de vous attendre",
  YOU_ARE_ON_A_RIDE: "Vous êtes en route",
  PLEASE_ASK_RIDER_FOR_THE_OTP: "Veuillez demander le code à usage unique à votre chauffeur",
  COMPLETED_: "Complétée",
  CANCELLED_: "Annulée",
  WE_NEED_SOME_ACCESS: "Accordez-nous les accès suivants",
  ALLOW_ACCESS: "Permettre l'accès",
  THANK_YOU_FOR_WRITING_TO_US: "Merci de nous avoir écrit!",
  RIDER: "Chauffeur",
  TRIP_ID: "Référence de votre course",
  NEED_IT_TO_SHOW_YOU_INCOMING_RIDE_REQUEST: "Recevez des demandes de course lors l'application est en arrière-plan",
  NEED_IT_TO_DISABLE_BATTERY_OPTIMIZATION_FOR_THE_APP: "Recommandé, permet à l'application de fonctionner en arrière-plan plus longtemps",
  NEED_IT_TO_AUTOSTART_YOUR_APP: "Aide en gardant l'application exécutée en arrière-plan",
  NEED_IT_TO_ENABLE_LOCATION: "Namma Yatri Partner recueille des données de localisation afin de partager votre position pour suivre la position du conducteur en direct, même lorsque l'application est fermée ou n'est pas utilisée",
  OVERLAY_TO_DRAW_OVER_APPLICATIONS: "Dessiner sur les applications",
  BATTERY_OPTIMIZATIONS: "Optimisation de la batterie",
  AUTO_START_APPLICATION_IN_BACKGROUND: "Application lancée automatiquement en arrière-plan",
  LOCATION_ACCESS: "Accès à l'emplacement",
  ENTER_RC_NUMBER: "Entrez le numéro CE",
  WHERE_IS_MY_RC_NUMBER: "Où est mon numéro CE?",
  STEP: "Étape",
  PAID: "Payé",
  ENTERED_WRONG_OTP: "Code à usage unique erroné",
  OTP_INVALID_FOR_THIS_VEHICLE_VARIANT : "OTP invalide – Le type de véhicule ne correspond pas au type de trajet",
  COPIED: "Copié",
  BANK_NAME: "Nom de la banque",
  AADHAR_DETAILS: "Informations Aadhar",
  AADHAR_NUMBER: "Numéro Aadhar",
  FRONT_SIDE_IMAGE: "Image avant",
  BACK_SIDE_IMAGE: "Image arrière",
  STILL_NOT_RESOLVED: "Toujours pas résolu? Appelez-nous",
  CASE_TWO: "b) au",
  NON_DISCLOUSER_AGREEMENT: "Accord de confidentialité",
  DATA_COLLECTION_AUTHORITY: "c) J'autorise et donne mandat à Juspay pour collecter mes informations et, en continuant, j'accepte les conditions d'utilisation et la politique de confidentialité",
  SOFTWARE_LICENSE: "Licence logicielle",
  LOAD_MORE: "Charger plus",
  ARE_YOU_SURE_YOU_WANT_TO_LOGOUT: "Êtes-vous sûr de vouloir vous déconnecter?",
  GO_BACK: "Retour",
  THANK_YOU_FOR_REGISTERING_US: "Merci de vous être inscrit avec nous!",
  UNFORTANUTELY_WE_ARE_NOT_AVAILABLE__YET_FOR_YOU: "Malheureusement, nous ne sommes pas encore disponibles près de chez vous. Nous vous informerons bientôt lorsque ce sera le cas",
  ARE_YOU_SURE_YOU_WANT_TO_END_THE_RIDE: "Êtes-vous sûr de vouloir mettre fin à la course",
  EMPTY_RIDES: "Rides vides",
  YOU_HAVE_NOT_TAKEN_A_TRIP_YET: "Vous n'avez pas encore fait de course",
  BOOK_NOW: "Réserver maintenant",
  RESEND_OTP_IN: "Renvoyer le code à usage unique dans",
  WE_NEED_ACCESS_TO_YOUR_LOCATION: "Nous avons besoin d'accéder à votre localisation!",
  YOUR_LOCATION_HELPS_OUR_SYSTEM: "Votre position aide notre système à localiser tous les chauffeurs à proximité et à vous trouver la course la plus rapide possible",
  NO_INTERNET_CONNECTION: "Pas de connexion Internet",
  PLEASE_CHECK_YOUR_INTERNET_CONNECTION_AND_TRY_AGAIN: "Veuillez vérifier votre connexion Internet et réessayer",
  TRY_AGAIN: "Essayer à nouveau",
  GRANT_ACCESS: "Accorder l'accès",
  YOUR_LIMIT_EXCEEDED_TRY_AGAIN_AFTER_10_MIN: "Vous dépassez la limite, réessayez dans 10 minutes",
  ENTER_REFERRAL_MOBILE_NUMBER: "Entrez le numéro de mobile de référence",
  APPLY: "Appliquer",
  HAVE_A_REFERRAL: "Vous avez un parrainage?",
  ADD_HERE: "Ajouter ici",
  REFERRAL_APPLIED: "Le parrainage a été pris en compte",
  SMALLEDIT: "modifier",
  ADD_DRIVING_LICENSE: "Ajouter un permis de conduire",
  HELP: "Aide?",
  INVALID_DL_NUMBER: "Numéro de permis de conduire non valide",
  DRIVING_LICENSE_NUMBER: "Numéro de permis de conduire",
  RE_ENTER_DRIVING_LICENSE_NUMBER: "Saisir à nouveau le numéro du permis de conduire",
  ENTER_DL_NUMBER: "Entrez le numéro PC",
  SELECT_DATE_OF_BIRTH: "Sélectionnez votre date de naissance",
  DATE_OF_BIRTH: "Date de naissance",
  WATCH_A_TUTORIAL_FOR_EASY_REGISTRATION: "Regarder un tutoriel pour faciliter \nl'inscription",
  ENTER_MINIMUM_FIFTEEN_CHARACTERS: "Entrez au moins 15 caractères",
  ADD_YOUR_FRIEND: "Ajoutez votre ami",
  PLEASE_WAIT_WHILE_VALIDATING_THE_IMAGE: "Veuillez patienter pendant la validation l'image",
  VALIDATING: "Valider",
  VERIFICATION_PENDING: "Vérification en attente",
  VERIFICATION_FAILED: "Échec de la vérification",
  NO_DOC_AVAILABLE: "Aucun document disponible",
  ISSUE_WITH_DL_IMAGE: "Il semble y avoir un problème avec votre photo de permis, notre équipe d'assistance vous contactera bientôt",
  STILL_HAVE_SOME_DOUBT: "Vous avez encore un doute?",
  ISSUE_WITH_RC_IMAGE: "Il semble y avoir un problème avec votre photo de certification d'enregistrement, notre équipe d'assistance vous contactera bientôt",
  PLEASE_CHECK_FOR_IMAGE_IF_VALID_DOCUMENT_IMAGE_OR_NOT: "Veuillez vérifier l'image si l'image du document est valide ou non",
  OOPS_YOUR_APPLICATION_HAS_BEEN_REJECTED: "Oups! Votre demande a été rejetée. Veuillez réessayer",
  INVALID_DRIVING_LICENSE: "Permis de conduire non valide",
  LIMIT_EXCEEDED_FOR_DL_UPLOAD: "Limite dépassée pour le chargement du PC",
  INVALID_VEHICLE_REGISTRATION_CERTIFICATE: "Certificat d'enregistrement des véhicules non valide",
  LIMIT_EXCEEDED_FOR_RC_UPLOAD: "Limite dépassée pour le chargement du CE",
  YOUR_DOCUMENTS_ARE_APPROVED: "Vos documents sont approuvés. L'équipe d'assistance activera votre compte sous peu. Vous pouvez également appeler l'équipe d'assistance pour activer votre compte directement.",
  APPLICATION_STATUS: "État de la candidature",
  FOR_SUPPORT: "Pour une assitance",
  CONTACT_US: " Contactez-nous",
  IMAGE_VALIDATION_FAILED: "La validation de l'image a échoué",
  IMAGE_NOT_READABLE: "L'image n'est pas lisible",
  IMAGE_LOW_QUALITY: "La qualité de l'image n'est pas bonne",
  IMAGE_INVALID_TYPE: "Le type d'image fourni ne correspond pas au type réel",
  IMAGE_DOCUMENT_NUMBER_MISMATCH: "Le numéro de document dans cette image ne correspond pas aux informations fournies",
  IMAGE_EXTRACTION_FAILED: "L'extraction d'image a échoué",
  IMAGE_NOT_FOUND: "Image non trouvée",
  IMAGE_NOT_VALID: "Image non valide",
  DRIVER_ALREADY_LINKED: "Un autre doc est déjà lié au chauffeur",
  DL_ALREADY_UPDATED: "Aucune action requise. Le permis de conduire est déjà lié au chauffeur",
  RC_ALREADY_LINKED: "CE du Véhicule non disponible. Lié à un autre conducteur",
  RC_ALREADY_UPDATED: "Aucune action requise. Le CE du véhicule est déjà lié au conducteur",
  DL_ALREADY_LINKED: "Permis de conduire non disponible. Lié à un autre conducteur",
  SOMETHING_WENT_WRONG: "Quelque chose s'est mal passé",
  PICKUP: "Pick-up",
  TRIP: "Trajet",
  CURRENTLY_WE_ALLOW_ONLY_KARNATAKA_REGISTERED_NUMBER: "Actuellement, nous n'autorisons que les numéros enregistrés au Karnataka",
  UPDATED_AT: "Carte mise à jour à",
  TRIP_COUNT: "Compteur de trajets",
  TODAYS_EARNINGS: "Gains",
  DATE_OF_REGISTRATION: "Date d'enregistrement",
  SELECT_DATE_OF_ISSUE: "Sélectionner la date de délivrance",
  DATE_OF_ISSUE: "Date d'émission",
  PROVIDE_DATE_OF_ISSUE_TEXT: "Désolé, nous ne pouvons pas valider vos informations, veuillez fournir <b> la date de délivrance </b> pour faire valider votre permis de conduire",
  PROVIDE_DATE_OF_REGISTRATION_TEXT: "Désolé, nous ne pourrions pas valider vos détails, veuillez fournir <b> la date de l'enregistrement </b> pour faire valider les détails de votre véhicule",
  SELECT_DATE_OF_REGISTRATION: "Sélectionner la date d'inscription",
  SAME_REENTERED_RC_MESSAGE: "Veuillez vous assurer que le numéro de CE réintégré est le même que le numéro de CE fourni ci-dessus",
  SAME_REENTERED_DL_MESSAGE: "Le numéro de PC re-renseigné ne correspond pas au numéro de PC fourni ci-dessus",
  WHERE_IS_MY_ISSUE_DATE: "Où est ma date d'émission?",
  WHERE_IS_MY_REGISTRATION_DATE: "Où est la date d'inscription?",
  OTP_RESENT: "Code à usage unique envoyé",
  EARNINGS_CREDITED_IN_ACCOUNT: "Vos gains seront crédités dans ce compte",
  INVALID_PARAMETERS: "Paramètres invalides",
  UNAUTHORIZED: "Non autorisé",
  INVALID_TOKEN: "Jeton invalide",
  SOME_ERROR_OCCURED_IN_OFFERRIDE: "Une erreur s'est produite dans l'offre de courses",
  SELECT_VEHICLE_TYPE: "Sélectionner le type de véhicule",
  RIDE: "Course",
  NO_LOCATION_UPDATE: "Aucune mise à jour de localisation",
  GOT_IT_TELL_US_MORE: "J'ai compris, dites-nous en plus ?",
  WRITE_A_COMMENT: "Écrire un commentaire",
  HOW_WAS_YOUR_RIDE_WITH: "Comment était votre trajet avec",
  RUDE_BEHAVIOUR: "Comportement grossier",
  LONG_WAITING_TIME: "Temps d'attente plus long",
  DIDNT_COME_TO_PICUP_LOCATION: "N'est pas venu au lieu de rencontre",
  HELP_US_WITH_YOUR_REASON: "Aidez-nous avec votre avis",
  MAX_CHAR_LIMIT_REACHED: "Limite de caractère maximum atteinte,",
  SHOW_ALL_OPTIONS: "Afficher toutes les options",
  UPDATE_REQUIRED: "Mise à jour requise",
  PLEASE_UPDATE_APP_TO_CONTINUE_SERVICE: "Nous sommes ravis d'annoncer la nouvelle mise à jour disponible pour notre application. Cette mise à jour comprend un nouveau design et plusieurs nouvelles fonctionnalités pour rendre votre expérience encore meilleure",
  NOT_NOW: "Pas maintenant",
  OF: "de",
  DROP: "Déposer",
  PLEASE_WAIT: "S'il vous plaît, patientez",
  SETTING_YOU_OFFLINE: "Nous vous mettons hors ligne",
  SETTING_YOU_ONLINE: "Nous vous mettons en ligne",
  SETTING_YOU_SILENT: "Nous vous mettons en silencieux",
  VIEW_BREAKDOWN: "Voir le détail",
  APP_INFO: "Informations sur l'application",
  OTHER: "Autre",
  VEHICLE_ISSUE: "Problème de véhicule",
  FARE_UPDATED: "Tarif mis à jour",
  FREQUENT_CANCELLATIONS_WILL_LEAD_TO_LESS_RIDES: "Les annulations fréquentes conduiront à moins de courses et à une note inférieure",
  CONTINUE: "Continuez",
  CONFIRM_PASSWORD: "Confirmez le mot de passe",
  DEMO_MODE: "Mode de démonstration",
  PASSWORD: "Mot de passe",
  ENTER_DEMO_MODE_PASSWORD: "Entrez le mot de passe du mode de démonstration",
  DEMO_MODE_DISABLED: "Mode de démonstration désactivé",
  ONLINE_VIA_DEMO_MODE: "En ligne (démo)",
  MORE: "plus",
  LESS: "moins",
  YOU_ARE_AT_PICKUP: "Vous êtes au lieu de rencontre",
  WAITING_FOR_CUSTOMER: "Vous attendez",
  CUSTOMER_NOTIFIED: "Client notifié",
  I_ARRIVED: "Je suis arrivé",
  ESTIMATED_RIDE_FARE: "Tarif estimé:",
  PICKUP_TOO_FAR: "Pick-up trop loin",
  CUSTOMER_NOT_PICKING_CALL: "Le client ne répond pas à l'appel",
  TRAFFIC_JAM: "Embouteillages",
  CUSTOMER_WAS_RUDE: "Le client était impoli",
  ALL_MESSAGES: "Tous les messages",
  MESSAGES: "Messages",
  ADD_A_COMMENT: "Ajouter un commentaire",
  POST_COMMENT: "Publier un commentaire",
  ENTER_YOUR_COMMENT: "Entrez votre commentaire",
  NO_NOTIFICATIONS_RIGHT_NOW: "Pas de notifications en ce moment !",
  NO_NOTIFICATIONS_RIGHT_NOW_DESC: "Nous vous ferons savoir quand il y a de nouvelles notifications",
  ALERTS: "Alertes",
  YOUR_COMMENT: "Votre commentaire",
  SHOW_MORE: "Montre plus",
  LOAD_OLDER_ALERTS: "Chargez des alertes plus anciennes",
  CONTEST: "Concours",
  YOUR_REFERRAL_CODE_IS_LINKED: "Votre code de référence est lié!",
  YOU_CAN_NOW_EARN_REWARDS: "Vous pouvez désormais gagner des récompenses pour les clients référés!",
  COMING_SOON: "À venir!",
  COMING_SOON_DESCRIPTION: "Nous travaillons à vous mettre à bord du programme de parrainage Consultez la page des alertes pour plus d'informations",
  REFERRAL_CODE: "Code de Parrainage",
  REFERRAL_CODE_HINT: "Entrez le code de référence à 6 chiffres",
  CONFIRM_REFERRAL_CODE: "Confirmer le code de référence",
  CONFIRM_REFERRAL_CODE_HINT: "Code de référence à nouveau",
  YOUR_REFERRAL_CODE: "Votre code de référence",
  FIRST_REFERRAL_SUCCESSFUL: "Première référence réussie! \ Nreward déverrouillée!",
  AWAITING_REFERRAL_RIDE: "En attente de trajet de référence",
  CHECK_THIS_SPACE_WHEN_YOU_GET_REFERRAL_ALERT: "Vérifiez cet espace lorsque vous avez une alerte de référence",
  REFERRED_CUSTOMERS: "Clients référés",
  ACTIVATED_CUSTOMERS: "Clients activés",
  REFERRAL_CODE_LINKING: "Lien avec le code de référence",
  CONTACT_SUPPORT: "Contactez le support",
  CALL_SUPPORT: "Support d'appel",
  YOU_ARE_ABOUT_TO_CALL_NAMMA_YATRI_SUPPORT: "Vous êtes sur le point de passer un appel à l'équipe de soutien Namma Yatri Voulez-vous continuer?",
  REFERRAL_ENROLMENT: "Inscription de référence",
  REFERRALS: "Références",
  LINK_REFERRAL_CODE: "Code de référence de liaison",
  DRIVER_DETAILS: "Détails du pilote",
  FOR_UPDATES_SEE_ALERTS: "Pour les mises à jour, voir les alertes",
  SHARE_OPTIONS: "Partager des options",
  ENTER_PASSWORD: "Entrer le mot de passe",
  YOUR_VEHICLE: "Votre véhicule",
  BOOKING_OPTIONS: "Options de réservation",
  CONFIRM_AND_CHANGE: "Confirmer et changer",
  OTP_: "OTP",
  MAKE_YOURSELF_AVAILABLE_FOR: "Mettez-vous disponible pour",
  SILENT_MODE_PROMPT: "Si vous ne voulez pas être dérangé, vous pouvez passer en mode silencieux à la place",
  GO_SILENT: "Mettez vous en silencieux",
  TRY_SILENT_MODE: "Essayez le mode silencieux?",
  RIDE_FARE: "Tarif de conduite",
  RIDE_DISTANCE: "Distance du trajet",
  FARE_UPDATED: "Tarif mis à jour",
  START_YOUR_CHAT_USING_THESE_QUICK_CHAT_SUGGESTIONS: "Commencez votre chat en utilisant ces suggestions de chat rapides",
  START_YOUR_CHAT_WITH_THE_DRIVER: "Commencez votre conversation avec le pilote",
  MESSAGE: "Message",
  I_AM_ON_MY_WAY: "Je suis en route",
  GETTING_DELAYED_PLEASE_WAIT: "Être retardé, veuillez attendre",
  UNREACHABLE_PLEASE_CALL_BACK: "Injoignable, veuillez rappeler",
  ARE_YOU_STARING: "Vous commencez?",
  PLEASE_COME_SOON: "S'il vous plait venez bientot",
  OK_I_WILL_WAIT: "D'accord, je vais attendre",
  I_HAVE_ARRIVED: "Je suis arrivé",
  PLEASE_COME_FAST_I_AM_WAITING: "S'il te plaît, viens vite, j'attends",
  PLEASE_WAIT_I_WILL_BE_THERE: "Veuillez attendre, je serai là",
  LOOKING_FOR_YOU_AT_PICKUP: "Vous cherchez au ramassage",
  SILENT: "Silencieux",
  GO_ONLINE: "ALLER!",
  GO_ONLINE_PROMPT: "Vous êtes actuellement hors ligne \ NTO Obtenez des demandes de conduite, allez en ligne maintenant!",
  LIVE_DASHBOARD: "Tableau de bord en direct",
  CLICK_TO_ACCESS_YOUR_ACCOUNT: "Cliquez ici pour accéder à votre compte",
  ADD_ALTERNATE_NUMBER: "Ajouter un numéro alternatif",
  ENTER_ALTERNATE_MOBILE_NUMBER: "Entrez un autre numéro de mobile",
  EDIT_ALTERNATE_MOBILE_NUMBER: "Modifier un autre numéro de mobile",
  PLEASE_ENTER_A_VALID_10_DIGIT_NUMBER: "Veuillez saisir un numéro de 10 chiffres valide",
  ALTERNATE_MOBILE_NUMBER: "Numéro de mobile alternatif",
  REMOVE: "Retirer",
  REMOVE_ALTERNATE_NUMBER: "Supprimer le numéro alternatif",
  ARE_YOU_SURE_YOU_WANT_TO_REMOVE_YOUR_ALTERNATE_MOBILE_NUMBER: "Êtes-vous sûr de vouloir supprimer votre autre numéro de mobile?",
  YES_REMOVE_IT: "Oui, supprimez-le",
  NUMBER_REMOVED_SUCCESSFULLY: "Numéro supprimé avec succès",
  NUMBER_ADDED_SUCCESSFULLY: "Numéro ajouté avec succès",
  NUMBER_EDITED_SUCCESSFULLY: "Numéro mis à jour avec succès",
  ALTERNATE_MOBILE_OTP_LIMIT_EXCEED: "Limite OTP dépassé, entrez le numéro et OTP à nouveau",
  WRONG_OTP: "Veuillez saisir OTP valide",
  ATTEMPTS_LEFT: "Tentatives laissées",
  ATTEMPT_LEFT: "Tentative à gauche",
  A: "Limite OTP dépassé",
  OTP_LIMIT_EXCEEDED_MESSAGE: "Vous avez atteint votre limite OTP Veuillez réessayer après 10 minutes",
  TRY_AGAIN_LATER: "Réessayez plus tard",
  NUMBER_ALREADY_EXIST_ERROR: "Numéro lié à un autre compte! Veuillez utiliser un autre numéro",
  OTP_RESEND_LIMIT_EXCEEDED: "Limite de renvoi de l'OTP dépassée",
  LIMIT_EXCEEDED_FOR_ALTERNATE_NUMBER: "S'il vous plaît réessayer après un certain temps",
  ALTERNATE_NUMBER_CANNOT_BE_ADDED: "Le numéro alternatif ne peut pas être ajouté",
  ADD_ALTERNATE_NUMBER_IN_MEANTIME: "Ce processus peut prendre jusqu'à deux jours ouvrables En attendant, vous pouvez ajouter un autre numéro de téléphone portable",
  VERIFICATION_IS_TAKING_A_BIT_LONGER: "On dirait que votre vérification prend un peu \ nlonger que prévu \ Nyou peut contacter le support pour vous aider",
  COMPLETE_ONBOARDING: "Finalisez le processus d'intégration",
  PERSON_WITH_THIS_NUMBER_ALREADY_EXISTS: "La personne avec ce numéro de mobile existe déjà",
  DEMO: "Démo",
  PLEASE_ASK_THE_CUSTOMER_FOR_THE_OTP: "Veuillez demander au client le OTP",
  DELETE: "Supprimer",
  VIEW: "Voir",
  ISSUE_NO: "numéro de problème",
  ADD_VOICE_NOTE: "Ajouter une note vocale",
  VOICE_NOTE_ADDED: "Note vocale ajoutée",
  SUBMIT_ISSUE_DETAILS: "Soumettre les détails du problème",
  IMAGE_PREVIEW: "Aperçu de l'image",
  RIDE_REPORT_ISSUE: "Sélectionnez Ride to Rapport le problème sur",
  ADDED_IMAGES: "Images ajoutées",
  NO_IMAGES_ADDED: "Pas d'images ajoutées",
  ASK_DETAILS_MESSAGE: "Veuillez donner plus de détails Vous pouvez également envoyer des images ou des notes vocales pour mieux élaborer",
  ASK_DETAILS_MESSAGE_REVERSED: "Veuillez partager plus de détails sur l'article perdu Vous pouvez également envoyer des images ou des notes vocales pour mieux élaborer",
  SELECT_OPTION: "Dites-nous si vous êtes confronté à l'un de ces problèmes",
  SELECT_OPTION_REVERSED: "Comment souhaitez-vous résoudre ce problème?",
  ISSUE_SUBMITTED_MESSAGE: "Détails reçus! Notre équipe vous appellera dans les 24 heures pour vous aider avec votre problème",
  I_DONT_KNOW_WHICH_RIDE: "Je ne sais pas quelle balade",
  REPORT_ISSUE_CHAT_PLACEHOLDER: "Décrivez votre problème Namma Yatri essaiera de le résoudre en moins de 24 heures",
  ADDED_VOICE_NOTE: "Note vocale ajoutée",
  NO_VOICE_NOTE_ADDED: "Aucune note vocale ajoutée",
  CALL_CUSTOMER_TITLE: "Appelez le client?",
  CALL_CUSTOMER_DESCRIPTION: "Vous êtes sur le point de passer un appel au client Voulez-vous continuer?",
  PLACE_CALL: "Placez l'appel",
  ADD_IMAGE: "Ajouter des images)",
  ADD_ANOTHER: "Ajouter un autre",
  IMAGES_ADDED: "Images ajoutées",
  ISSUE_SUBMITTED_TEXT: "Attends! Nous travaillons sur la résolution de votre problème",
  CHOOSE_AN_OPTION: "Choisissez une option pour continuer",
  IMAGE_ADDED: "Image ajoutée",
  DONE: "Fait",
  RECORD_VOICE_NOTE: "Enregistrer la note vocale",
  HELP_AND_SUPPORT: "Aide et assistance",
  MORE_OPTIONS: "Plus d'options",
  ONGOING_ISSUES: "Problèmes en cours",
  RESOLVED_ISSUES: "Problèmes résolus",
  RESOLVED_ISSUE: "Problème résolu",
  ONGOING_ISSUE: "Problèmes en cours",
  LOST_ITEM: "Article perdu",
  RIDE_RELATED_ISSUE: "Problème lié à la conduite",
  APP_RELATED_ISSUE: "Problème lié à l'application",
  FARE_RELATED_ISSUE: "Problème lié aux tarifs",
  MAX_IMAGES: "Maximum 3 images peuvent être téléchargées",
  ISSUE_NUMBER: "Émettre aucune ",
  REMOVE_ISSUE: "Supprimer le problème",
  CALL_SUPPORT_NUMBER: "Contactez le support",
  YEARS_AGO: " il y a des années",
  MONTHS_AGO: " il y a des mois",
  DAYS_AGO: " il y a quelques jours",
  HOURS_AGO: " il y a des heures",
  MIN_AGO: " il y a quelques minutes",
  SEC_AGO: " il y a quelques instants",
  ISSUE_REMOVED: "Problème supprimé",
  LOADING: "Chargement",
  APP_RELATED: "En rapport avec l'application",
  FARE: "Lié au tarif",
  RIDE_RELATED: "En rapport avec la conduite",
  LOST_AND_FOUND: "Perdus et trouvés",
  REPORT_LOST_ITEM: "Signaler un article, perdu",
  CORPORATE_ADDRESS: "Adresse d'entreprise",
  CORPORATE_ADDRESS_DESCRIPTION: "Juspay Technologies Private Limited <br> Girija Building, numéro 817, Ganapathi Temple Rd, 8th Block, Koramangala, Bengaluru, Karnataka 560095, Inde",
  CORPORATE_ADDRESS_DESCRIPTION_ADDITIONAL: "Website: <u> https://nammayatriin/ </u>",
  REGISTERED_ADDRESS: "Adresse enregistrée",
  REGISTERED_ADDRESS_DESCRIPTION: "Juspay Technologies Private Limited <br>Stallion Business Centre, numero 444, 3e et 4e étage, 18e Main, 6e bloc, Koramangala Bengaluru, Karnataka- 560095, Inde",
  REGISTERED_ADDRESS_DESCRIPTION_ADDITIONAL: "Website : <u> https://nammayatriin/ </u>",
  NEW_: "Nouvelle",
  WITH: "avec",
  CHOOSE_LANGUAGE: "Choisissez la langue",
  TODAY : "আজ",
  AADHAAR_ALREADY_LINKED : "déjà lié",
  OPTIONAL : " (Facultatif)",
  DOWNLOAD_STATEMENT : "Télécharger la déclaration",
  SELECT_A_DATE_RANGE : "Sélectionnez une plage de dates pour télécharger le relevé",
  FEE_PAYMENT_HISTORY : "Historique de paiement des frais",
  LANGUAGES_SPOKEN : "Langues parlées",
  VIEW_PAYMENT_HISTORY : "Afficher l'historique des paiements",
  RIDE_TYPE : "Type de trajet",
  PLACE_CALL_REQUEST : "Faire une demande d'appel",
  RC_STATUS : "Statut RC",
  RATED_BY_USERS1 : "",
  RATED_BY_USERS2 : "UTILISATRICES Évalué par",
  MONTHS : "Mois",
  RC_ADDED_SUCCESSFULLY : "Certificat d'enregistrement ajouté avec succès",
  OFFER_APPLIED : "Offre appliquée",
  YOUR_EARNINGS : "Vos gains",
  NUMBER_OF_RIDES : "Nombre de trajets",
  FARE_BREAKUP : "Répartition tarifaire",
  MY_PLAN : "Mon plan",
  YOUR_DUES : "Vos cotisations",
  YOUR_DUES_DESCRIPTION : "Vous avez mis en place un paiement automatique pour régler vos cotisations. Nous essaierons automatiquement de nous assurer que vos cotisations sont toujours payées à temps.",
  CURRENT_DUES : "Cotisations actuelles",
  YOUR_LIMIT : "Votre limite",
  DUE_DETAILS : "Détails dus",
  TRIP_DATE : "Date du voyage",
  AMOUNT : "Montant",
  VIEW_DUE_DETAILS : "Afficher les détails d'échéance",
  SETUP_AUTOPAY : "Configurer le paiement automatique",
  CURRENT_PLAN : "PLAN ACTUEL",
  ALTERNATE_PLAN : "RÉGIME ALTERNATIF",
  AUTOPAY_DETAILS : "Détails du paiement automatique",
  CANCEL_AUTOPAY_STR : "Annuler le paiement automatique",
  WE_MIGHT_BE_LOST : "Uh oh ! Nous pourrions être perdus",
  EXEPERIENCING_ERROR : "Erreur rencontrée",
  ENJOY_THESE_BENEFITS : "Profitez de ces avantages",
  CHOOSE_YOUR_PLAN : "Choisissez un plan maintenant!",
  GET_FREE_TRAIL_UNTIL : "Obtenez un essai gratuit jusqu'à",
  CLEAR_DUES : "Effacer les cotisations",
  PAYMENT_PENDING_ALERT : "⚠️ Paiement en attente ! ⚠️",
  PAYMENT_PENDING_ALERT_DESC : "Pour continuer à faire des trajets sur Namma Yatri, effacez vos frais de paiement",
  LOW_ACCOUNT_BALANCE : "Solde de compte faible",
  LOW_ACCOUNT_BALANCE_DESC : "Le solde de votre compte bancaire est faible. Ajoutez de l'argent pour profiter de trajets ininterrompus.",
  OKAY_GOT_IT : "D'accord, j'ai compris",
  LIMITED_TIME_OFFER : "Offre à durée limitée pour vous !",
  JOIN_NOW : "S'inscrire maintenant",
  AUTOMATIC_PAYMENTS_WILL_APPEAR_HERE : "Les paiements automatiques apparaîtront ici",
  MANUAL_PAYMENTS : "Paiements manuels",
  MANUAL_PAYMENTS_WILL_APPEAR_HERE : "Les paiements manuels apparaîtront ici",
  NO_AUTOMATIC_PAYMENTS_DESC : "Votre historique de paiement automatique apparaîtra ici une fois que vous serez facturé pour la même chose",
  NO_MANUAL_PAYMENTS_DESC : "Votre historique de paiement pour la compensation des cotisations apparaîtra ici, le cas échéant.",
  PAYMENT_HISTORY : "Historique des paiements",
  DO_A_ONE_TIME_SETTLEMENT : "Effectuer un règlement unique",
  TAP_A_PLAN_TO_VIEW_DETAILS : "Appuyez sur un plan pour afficher les détails",
  HOW_IT_WORKS : "Comment ça marche ?",
  ZERO_COMMISION : "ZERO commission",
  EARN_TODAY_PAY_TOMORROW : "Gagnez aujourd'hui, payez demain",
  PAY_ONLY_IF_YOU_TAKE_RIDES : "Ne payez que si vous faites des trajets",
  PLAN : "Plan",
  DAY : "Jour",
  PLANS : "Des plans",
  MANAGE_PLAN : "Gérer le forfait",
  VIEW_AUTOPAY_DETAILS : "Afficher les détails du paiement automatique",
  SWITCH_AND_SAVE : "Changer et enregistrer",
  SWITCH_AND_SAVE_DESC : "Vous avez effectué plus de 7 trajets aujourd'hui. Économisez jusqu'à 10 ₹ en passant au forfait DAILY UNLIMITED",
  SWITCH_NOW : "Changer maintenant",
  PAYMENT_MODE_CHANGED_TO_MANUAL : "Mode de paiement changé en manuel",
  PAYMENT_MODE_CHANGED_TO_MANUAL_DESC : "Vous avez suspendu votre paiement automatique UPI. Vous pouvez effacer vos cotisations manuellement.",
  AUTOPAY_PAYMENTS : "Paiements automatiques",
  TRANSACTION_ON : "Transaction activée",
  SUCCESS : "Succès",
  PAID_ON : "Payé le",
  RIDES_TAKEN_ON : "Voyages effectués",
  JOIN_PLAN : "Rejoindre le forfait",
  JOIN_NAMMAA_YATRI : "Rejoindre Namma Yatri",
  CANCEL_AUTOPAY_AND_PAY_MANUALLY : "Annuler le paiement automatique et payer manuellement",
  PLAN_ACTIVATED_SUCCESSFULLY : "Plan activé avec succès",
  DUES_CLEARED_SUCCESSFULLY : "Cotisations effacées avec succès",
  NOT_PLANNING_TO_TAKE_RIDES : "Vous ne prévoyez pas de faire des trajets ?",
  RETRY_PAYMENT_STR : "Réessayer le paiement",
  PAUSE_AUTOPAY_STR : "Suspendre le paiement automatique",
  SETUP_AUTOPAY_STR : "Reprendre le paiement automatique",
  VIEW_RIDE_DETAILS : "Afficher les détails du trajet",
  ACCOUNT : "Compte",
  AUTOPAY_IS_NOT_ENABLED_YET : "Le paiement automatique n'est pas encore activé !",
  ENABLE_AUTOPAY_DESC : "Activez le paiement automatique maintenant pour commencer les paiements sans tracas !",
  ENABLE_AUTOPAY_NOW : "Activer le paiement automatique maintenant",
  AUTOPAY_SETUP_PENDING_STR : "Configuration du paiement automatique en attente !",
  PAYMENT_PENDING_DESC_STR : "Attendez ou réessayez le paiement. Le paiement supplémentaire sera remboursé.",
  REFRESH_STR : "Actualiser",
  TRANSACTION_DETAILS : "Détails de la transaction",
  RIDE_DETAILS : "Détails du trajet",
  NAMMA_YATRI_PLANS : "À propos de nous",
  SWITCH_TO : "Passer à",
  PLEASE_TRY_AGAIN : "Veuillez réessayer",
  PLEASE_TRY_AGAIN : "Veuillez réessayer",
  PLAN_NOT_FOUND : "Plan introuvable",
  MANDATE_NOT_FOUND : "Mandat introuvable",
  ACTIVE_MANDATE_EXISTS : "Le mandat actif existe déjà",
  NO_ACTIVE_MANDATE_EXIST : "Aucun mandat actif n'existe",
  NO_PLAN_FOR_DRIVER : "Aucun plan trouvé",
  INVALID_PAYMENT_MODE : "Mode de paiement invalide",
  INVALID_AUTO_PAY_STATUS : "Statut de paiement automatique non valide",
  MAX_AMOUNT : "Montant maximum",
  FREQUENCY : "Fréquence",
  STATRED_ON : "Démarré le",
  EXPIRES_ON : "Expire le",
  SWITCHED_PLAN : "Changement de forfait",
  RESUME_AUTOPAY : "Paiement automatique repris",
  PAYMENT_CANCELLED: "Vous avez annulé votre paiement automatique UPI. Vous pouvez effacer vos cotisations manuellement",
  UPI_AUTOPAY_S : "UPI Paiement automatique",
	MANUAL_PAYMENT : "Paiement manuel",
  DAILY_UNLIMITED : "quotidiennement illimité",
  DAILY_PER_RIDE : "quotidiennement par trajet",
  DAILY_UNLIMITED_PLAN_DESC : "Profitez de trajets illimités, tous les jours",
  DAILY_PER_RIDE_PLAN_DESC : "Jusqu'à un maximum de ₹35 par jour",
  PAY_TO_JOIN_THIS_PLAN : "Payez 1 ₹ pour rejoindre ce plan",
	OFFERS_NOT_APPLICABLE : "Les offres ne s'appliquent que si elles sont complétées",
  PAUSED_STR : "En pause",
  PENDING_STR : "En attente",
  SWITCH_PLAN_STR : "Plan de commutation?",
  PLAN_SWITCHED_TO : "le plan est passé à",
  OFFERS_APPLICABLE_ON_DAILY_UNLIMITED : "Remarque: Offre applicable uniquement si AutoPay est configuré sur le plan illimité quotidien.",
  DAILY_UNLIMITED_OFFER_NOT_AVAILABLE : "Remarque: les offres illimitées quotidiennes ne sont pas applicables sur ce plan!" , 
  NO_RIDES_NO_CHARGE : "Payez uniquement si vous faites des courses",
  GET_SPECIAL_OFFERS : "Get Special Offers",
  VALID_ONLY_IF_PAYMENT : "valid only if payment is completed",
  HELP_STR : "HELP",
  REFRESH_STRING : "Refresh",
  CHAT_FOR_HELP : "Chat for Help",
  VIEW_FAQs : "View FAQs",
  SUPPORT : "Support",
	NEED_HELP_JOINING_THE_PLAN : "Besoin d'aide pour adhérer au plan ?Contactez-nous",
  NEED_HELP_CALL_SUPPORT : "Besoin d'aide? <span style='color:#2194FF'>Appeler l'assistance</span>"
}