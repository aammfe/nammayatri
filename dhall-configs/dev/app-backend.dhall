let common = ./common.dhall
let sec = ./secrets/app-backend.dhall

let GeoRestriction = < Unrestricted | Region : Text>

let postgresConfig =
  { connectHost = "localhost"
  , connectPort = 5433
  , connectUser = sec.dbUserId
  , connectPassword = sec.dbPassword
  , connectDatabase = "atlas_app"
  }

let pgcfg =
  { connTag = "providerDb"
  , pgConfig = postgresConfig
  , poolConfig = common.defaultPoolConfig
  , schemaName = "atlas_app"
  }

let rcfg =
  { connectHost = "localhost"
  , connectPort = 6379
  , connectAuth = None Text
  , connectDatabase = +0
  , connectMaxConnections = +50
  , connectMaxIdleTime = +30
  , connectTimeout = None Integer
  }

let smsConfig =
  { sessionConfig = common.smsSessionConfig
  , credConfig = {
      username = common.smsUserName
    , password = common.smsPassword
    , otpHash = sec.smsOtpHash
    }
  , useFakeSms = Some 7891
  , url = "https://http.myvfirst.com"
  , sender = "JUSPAY"
  }

let sesConfig =
  { issuesConfig = {
      from = "no-reply@juspay.in"
    , to = ["support@supportyatri.freshdesk.com"]
    , replyTo = ["support@supportyatri.freshdesk.com"]
    , cc = ["beckn_mobility@juspay.in"]
    , region = "eu-west-1"
    , fromArn = None Text
    }
  }

let geofencingConfig =
{ origin = GeoRestriction.Region "Ernakulam"
, destination = GeoRestriction.Region "Kerala"
}

let gwUri = "http://localhost:8015/v1"

let providerUri = "http://localhost:8014/v1"

let registrationHitsOptions = 
  { limit = +4
  , limitResetTime = +600
  }

in

{ dbCfg = pgcfg
, redisCfg = rcfg
, smsCfg = smsConfig
, otpSmsTemplate = "<#> Your OTP for login to Yatri App is {#otp#} {#hash#}"
, sesCfg = sesConfig
, port = +8013
, metricsPort = +9999
, xGatewayUri = gwUri
, xGatewayApiKey = None Text
, xGatewaySelector = Some "JUSPAY.BG.1"
, xGatewayNsdlUrl = None Text
, xProviderUri = providerUri
, bapSelfId = "JUSPAY.MOBILITY.APP.UAT.1"
, bapNwAddress = "http://localhost:8013/v1/"
, credRegistry = common.credRegistry
, signingKeys = common.signingKeys
, searchConfirmExpiry = Some +600
, searchCaseExpiry = Some +600
, cronAuthKey = Some sec.cronAutKey
, encService = common.passetto
, fcmJsonPath = common.fcmJsonPath
, exotelCfg = Some common.exotelCfg
, migrationPath = Some (env:APP_BACKEND_MIGRATION_PATH as Text ? "dev/migrations/app-backend")
, autoMigrate = True
, coreVersion = "0.8.2"
, domainVersion = "0.8.2"
, geofencingConfig = geofencingConfig
, loggerConfig = common.loggerConfig // {logFilePath = "/tmp/app-backend.log"}
, signatureExpiry = common.signatureExpiry
, googleMapsUrl = "https://maps.googleapis.com/maps/api/"
, googleMapsKey = common.googleMapsKey
, fcmUrl = common.fcmUrl
, graphhopperUrl = common.graphhopperUrl
, metricsSearchDurationTimeout = +45
, graceTerminationPeriod = +90
, registrationHitsOpt = registrationHitsOptions
}
