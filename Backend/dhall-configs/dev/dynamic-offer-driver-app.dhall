let common = ./common.dhall

let sec = ./secrets/dynamic-offer-driver-app.dhall

let globalCommon = ../generic/common.dhall

let esqDBCfg =
      { connectHost = "localhost"
      , connectPort = 5434
      , connectUser = sec.dbUserId
      , connectPassword = sec.dbPassword
      , connectDatabase = "atlas_dev"
      , connectSchemaName = "atlas_driver_offer_bpp"
      , connectionPoolCount = +25
      }

let esqDBReplicaCfg =
      { connectHost = esqDBCfg.connectHost
      , connectPort = 5434
      , connectUser = esqDBCfg.connectUser
      , connectPassword = esqDBCfg.connectPassword
      , connectDatabase = esqDBCfg.connectDatabase
      , connectSchemaName = esqDBCfg.connectSchemaName
      , connectionPoolCount = esqDBCfg.connectionPoolCount
      }

let esqLocationDBCfg = esqDBCfg

let esqLocationDBRepCfg =
      { connectHost = esqDBCfg.connectHost
      , connectPort = 5434
      , connectUser = esqDBCfg.connectUser
      , connectPassword = esqDBCfg.connectPassword
      , connectDatabase = esqDBCfg.connectDatabase
      , connectSchemaName = esqDBCfg.connectSchemaName
      , connectionPoolCount = esqDBCfg.connectionPoolCount
      }

let clickhouseCfg =
      { username = sec.clickHouseUsername
      , host = "xxxxx"
      , port = 1234
      , password = sec.clickHousePassword
      , database = "xxxx"
      , tls = True
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

let rccfg =
      { connectHost = "localhost"
      , connectPort = 30001
      , connectAuth = None Text
      , connectDatabase = +0
      , connectMaxConnections = +50
      , connectMaxIdleTime = +30
      , connectTimeout = None Integer
      }

let smsConfig =
      { sessionConfig = common.smsSessionConfig
      , credConfig =
        { username = common.smsUserName
        , password = common.smsPassword
        , otpHash = sec.smsOtpHash
        }
      , useFakeSms = Some 7891
      , url = "http://localhost:4343"
      , sender = "JUSPAY"
      }

let sampleKafkaConfig
    : globalCommon.kafkaConfig
    = { topicName = "dynamic-offer-driver-events-updates"
      , kafkaKey = "dynamic-offer-driver"
      }

let sampleLogConfig
    : Text
    = "log-stream"

let eventStreamMappings =
      [ { streamName = globalCommon.eventStreamNameType.KAFKA_STREAM
        , streamConfig = globalCommon.streamConfig.KafkaStream sampleKafkaConfig
        , eventTypes =
          [ globalCommon.eventType.RideCreated
          , globalCommon.eventType.RideStarted
          , globalCommon.eventType.RideEnded
          , globalCommon.eventType.RideCancelled
          , globalCommon.eventType.BookingCreated
          , globalCommon.eventType.BookingCancelled
          , globalCommon.eventType.BookingCompleted
          , globalCommon.eventType.SearchRequest
          , globalCommon.eventType.Quotes
          , globalCommon.eventType.Estimate
          ]
        }
      , { streamName = globalCommon.eventStreamNameType.LOG_STREAM
        , streamConfig = globalCommon.streamConfig.LogStream sampleLogConfig
        , eventTypes =
          [ globalCommon.eventType.RideEnded
          , globalCommon.eventType.RideCancelled
          ]
        }
      ]

let apiRateLimitOptions = { limit = +4, limitResetTimeInSec = +600 }

let encTools = { service = common.passetto, hashSalt = sec.encHashSalt }

let slackCfg =
      { channelName = "beckn-driver-onboard-test"
      , slackToken = common.slackToken
      }

let apiRateLimitOptions = { limit = +4, limitResetTimeInSec = +600 }

let driverLocationUpdateRateLimitOptions =
      { limit = +100, limitResetTimeInSec = +1 }

let cacheConfig = { configsExpTime = +86400 }

let cacheTranslationConfig = { expTranslationTime = +3600 }

let kafkaProducerCfg =
      { brokers = [ "localhost:29092" ]
      , kafkaCompression = common.kafkaCompression.LZ4
      }

let tables =
      { enableKVForWriteAlso =
            [ { nameOfTable = "registration_token", percentEnable = 100 }
            , { nameOfTable = "search_request", percentEnable = 100 }
            , { nameOfTable = "search_try", percentEnable = 100 }
            , { nameOfTable = "driver_information", percentEnable = 100 }
            , { nameOfTable = "driver_flow_status", percentEnable = 100 }
            , { nameOfTable = "business_event", percentEnable = 100 }
            , { nameOfTable = "booking", percentEnable = 100 }
            , { nameOfTable = "estimate", percentEnable = 100 }
            , { nameOfTable = "fare_parameters", percentEnable = 100 }
            , { nameOfTable = "fare_parameters_progressive_details"
              , percentEnable = 100
              }
            , { nameOfTable = "booking_location", percentEnable = 100 }
            , { nameOfTable = "ride_details", percentEnable = 100 }
            , { nameOfTable = "rider_details", percentEnable = 100 }
            , { nameOfTable = "driver_stats", percentEnable = 100 }
            , { nameOfTable = "driver_quote", percentEnable = 100 }
            , { nameOfTable = "search_request_location", percentEnable = 100 }
            , { nameOfTable = "fare_parameters_slab_details"
              , percentEnable = 100
              }
            , { nameOfTable = "booking_cancellation_reason"
              , percentEnable = 100
              }
            , { nameOfTable = "rating", percentEnable = 100 }
            , { nameOfTable = "beckn_request", percentEnable = 100 }
            , { nameOfTable = "ride", percentEnable = 100 }
            , { nameOfTable = "search_request_for_driver", percentEnable = 100 }
            , { nameOfTable = "person", percentEnable = 100 }
            , { nameOfTable = "vehicle", percentEnable = 100 }
            , { nameOfTable = "driver_rc_association", percentEnable = 100 }
            , { nameOfTable = "driver_referral", percentEnable = 100 }
            , { nameOfTable = "message", percentEnable = 100 }
            , { nameOfTable = "idfy_verification", percentEnable = 100 }
            ]
          : List { nameOfTable : Text, percentEnable : Natural }
      , enableKVForRead =
            [ "registration_token"
            , "search_request"
            , "search_try"
            , "driver_information"
            , "driver_flow_status"
            , "business_event"
            , "booking"
            , "estimate"
            , "fare_parameters"
            , "fare_parameters_progressive_details"
            , "booking_location"
            , "ride_details"
            , "rider_details"
            , "driver_stats"
            , "driver_quote"
            , "search_request_location"
            , "fare_parameters_slab_details"
            , "booking_cancellation_reason"
            , "rating"
            , "beckn_request"
            , "search_request_for_driver"
            , "ride"
            , "person"
            , "vehicle"
            , "driver_rc_association"
            , "driver_referral"
            , "message"
            , "idfy_verification"
            ]
          : List Text
      }

let dontEnableForDb = [] : List Text

let appBackendBapInternal =
      { name = "APP_BACKEND"
      , url = "http://localhost:8013/"
      , apiKey = sec.appBackendApikey
      , internalKey = sec.internalKey
      }

let registryMap =
      [ { mapKey = "localhost/beckn/cab/v1/da4e23a5-3ce6-4c37-8b9b-41377c3c1a51"
        , mapValue = "http://localhost:8020/"
        }
      , { mapKey = "localhost/beckn/cab/v1/da4e23a5-3ce6-4c37-8b9b-41377c3c1a52"
        , mapValue = "http://localhost:8020/"
        }
      , { mapKey = "JUSPAY.BG.1", mapValue = "http://localhost:8020/" }
      ]

let AllocatorJobType =
      < SendSearchRequestToDriver
      | SendPaymentReminderToDriver
      | UnsubscribeDriverForPaymentOverdue
      | UnblockDriver
      | SendPDNNotificationToDriver
      | MandateExecution
      | CalculateDriverFees
      | OrderAndNotificationStatusUpdate
      | SendOverlay
      >

let jobInfoMapx =
      [ { mapKey = AllocatorJobType.SendSearchRequestToDriver
        , mapValue = False
        }
      , { mapKey = AllocatorJobType.SendPaymentReminderToDriver
        , mapValue = False
        }
      , { mapKey = AllocatorJobType.UnsubscribeDriverForPaymentOverdue
        , mapValue = True
        }
      , { mapKey = AllocatorJobType.UnblockDriver, mapValue = False }
      , { mapKey = AllocatorJobType.SendPDNNotificationToDriver
        , mapValue = True
        }
      , { mapKey = AllocatorJobType.MandateExecution, mapValue = True }
      , { mapKey = AllocatorJobType.CalculateDriverFees, mapValue = True }
      , { mapKey = AllocatorJobType.OrderAndNotificationStatusUpdate
        , mapValue = True
        }
      , { mapKey = AllocatorJobType.SendOverlay, mapValue = True }
      ]

let LocationTrackingeServiceConfig = { url = "http://localhost:8081/" }

in  { esqDBCfg
    , esqDBReplicaCfg
    , esqLocationDBCfg
    , esqLocationDBRepCfg
    , clickhouseCfg
    , hedisCfg = rcfg
    , hedisClusterCfg = rccfg
    , hedisNonCriticalCfg = rcfg
    , hedisNonCriticalClusterCfg = rccfg
    , hedisMigrationStage = True
    , cutOffHedisCluster = False
    , port = +8016
    , metricsPort = +9997
    , hostName = "localhost"
    , nwAddress = "http://localhost:8016/beckn"
    , selfUIUrl = "http://localhost:8016/ui/"
    , signingKey = sec.signingKey
    , signatureExpiry = common.signatureExpiry
    , s3Config = common.s3Config
    , s3PublicConfig = common.s3PublicConfig
    , migrationPath = Some
        (   env:DYNAMIC_OFFER_DRIVER_APP_MIGRATION_PATH as Text
          ? "dev/migrations/dynamic-offer-driver-app"
        )
    , autoMigrate = True
    , coreVersion = "0.9.4"
    , loggerConfig =
            common.loggerConfig
        //  { logFilePath = "/tmp/dynamic-offer-driver-app.log"
            , logRawSql = True
            }
    , googleTranslateUrl = common.googleTranslateUrl
    , googleTranslateKey = common.googleTranslateKey
    , appBackendBapInternal
    , graceTerminationPeriod = +90
    , encTools
    , authTokenCacheExpiry = +600
    , disableSignatureAuth = False
    , httpClientOptions = common.httpClientOptions
    , shortDurationRetryCfg = common.shortDurationRetryCfg
    , longDurationRetryCfg = common.longDurationRetryCfg
    , apiRateLimitOptions
    , slackCfg
    , jobInfoMapx
    , smsCfg = smsConfig
    , searchRequestExpirationSeconds = +3600
    , driverQuoteExpirationSeconds = +60
    , driverUnlockDelay = +2
    , dashboardToken = sec.dashboardToken
    , cacheConfig
    , metricsSearchDurationTimeout = +45
    , driverLocationUpdateRateLimitOptions
    , driverReachedDistance = +100
    , cacheTranslationConfig
    , driverLocationUpdateTopic = "location-updates"
    , broadcastMessageTopic = "broadcast-messages"
    , kafkaProducerCfg
    , snapToRoadSnippetThreshold = +300
    , minTripDistanceForReferralCfg = Some +1000
    , maxShards = +5
    , enableRedisLatencyLogging = False
    , enablePrometheusMetricLogging = True
    , enableAPILatencyLogging = True
    , enableAPIPrometheusMetricLogging = True
    , eventStreamMap = eventStreamMappings
    , tables
    , locationTrackingServiceKey = sec.locationTrackingServiceKey
    , schedulerSetName = "Scheduled_Jobs"
    , schedulerType = common.schedulerType.DbBased
    , ltsCfg = LocationTrackingeServiceConfig
    , enableLocationTrackingService = False
    , dontEnableForDb
    }
