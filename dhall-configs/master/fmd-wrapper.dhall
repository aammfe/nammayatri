let common = ./common.dhall
let sec = ./secrets/fmd-wrapper.dhall

let postgresConfig =
  { connectHost = "beckn-sandbox-v2.cyijte0yeu00.ap-southeast-1.rds.amazonaws.com"
  , connectPort = 5432
  , connectUser = sec.dbUserId
  , connectPassword = sec.dbPassword
  , connectDatabase = "atlas_fmd_wrapper_v2"
  }

let pgcfg =
  { connTag = "fmdWrapperDb"
  , pgConfig = postgresConfig
  , poolConfig = common.defaultPoolConfig
  , schemaName = "atlas_fmd_wrapper"
  }

let rcfg =
  { connectHost = "ec-redis-beta.bfw4iw.ng.0001.apse1.cache.amazonaws.com"
  , connectPort = 6379
  , connectAuth = None Text
  , connectDatabase = +1
  , connectMaxConnections = +50
  , connectMaxIdleTime = +30
  , connectTimeout = Some +100
  }

let dunzoConfig =
  { dzUrl = "apis-staging.dunzo.in"
  , dzTokenUrl = "http://d4b.dunzodev.in:9016"
  , dzBPId = "fmd-wrapper.dunzo"
  , dzBPNwAddress = "https://api.sandbox.beckn.juspay.in/dev/fmd/v1/"
  , payee = sec.payee
  , dzTestMode = True
  , dzQuotationTTLinMin = +5
  }

let gwUri = "http://beckn-gateway-${common.branchName}.atlas:8015/v1"

let delhiveryConfig =
  { dlUrl = "https://pelorus.delhivery.com"
  , dlTokenUrl = "https://key-cloak.delhivery.com"
  , dlBPId = "fmd-wrapper.delhivery"
  , dlBPNwAddress = "http://localhost:8018/v1"
  , dlPayee = sec.dlPayee
  }

in

{ dbCfg = pgcfg
, redisCfg = rcfg
, port = +8018
, xGatewayUri = gwUri
, xGatewayApiKey = Some "fmd-wrapper-key"
, migrationPath = None Text
, autoMigrate = common.autoMigrate
, loggerConfig = common.loggerConfig // {logFilePath = "/tmp/fmd-wrapper.log"}
, coreVersion = "0.8.0"
, domainVersion = "0.8.3"
, dzConfig = dunzoConfig
, dlConfig = delhiveryConfig
, credRegistry = common.credRegistry
, signingKeys = common.signingKeys
, signatureExpiry = common.signatureExpiry
, selfId = "JUSPAY.FMD.UAT.1"
}
