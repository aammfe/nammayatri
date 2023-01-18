let common = ./common.dhall

let sec = ./secrets/beckn-gateway.dhall

let rcfg =
      { connectHost = "beckn-redis-001.zkt6uh.ng.0001.aps1.cache.amazonaws.com"
      , connectPort = 6379
      , connectAuth = None Text
      , connectDatabase = +2
      , connectMaxConnections = +50
      , connectMaxIdleTime = +30
      , connectTimeout = Some +100
      }

in  { hedisCfg = rcfg
    , port = +8015
    , metricsPort = +9999
    , selfId = "api.sandbox.beckn.juspay.in/gateway/v1"
    , hostName = "juspay.in"
    , authEntity =
      { signingKey = sec.signingKey
      , uniqueKeyId = "39"
      , signatureExpiry = common.signatureExpiry
      }
    , loggerConfig =
        common.loggerConfig // { logFilePath = "/tmp/beckn-gateway.log" }
    , graceTerminationPeriod = +90
    , httpClientOptions = common.httpClientOptions
    , shortDurationRetryCfg = common.shortDurationRetryCfg
    , longDurationRetryCfg = common.longDurationRetryCfg
    , registryUrl = common.registryUrl
    , disableSignatureAuth = False
    }
