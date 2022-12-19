let common = ./common.dhall

let hcfg =
      { connectHost = "cache.primary.beckn.juspay.net"
      , connectPort = 6379
      , connectAuth = None Text
      , connectDatabase = +1
      , connectMaxConnections = +50
      , connectMaxIdleTime = +30
      , connectTimeout = Some +100
      }

let kafkaConsumerCfgs =
      { publicTransportQuotes =
        { brokers = [ "localhost:29092" ]
        , groupId = "publicTransportQuotesGroup"
        , timeoutMilliseconds = +10000
        }
      }

in  { port = +8025
    , graceTerminationPeriod = +90
    , hedisCfg = hcfg
    , kafkaConsumerCfgs
    , loggerConfig =
            common.loggerConfig
        //  { logFilePath = "/tmp/search-result-aggregator.log" }
    }
