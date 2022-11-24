let globalCommon = ../../generic/common.dhall

let exotelCfg =
  { apiKey = "xxxxxxx"
  , apiToken = "xxxxxxx"
  , sid = "xxxxxxx"
  , callerId = "xxxxxxx"
  } : globalCommon.ExotelCfg

let s3Config =
  { secretAccessKey = "xxxxxxx"
  , accessKeyId = "xxxxxxx"
  , bucketName = "xxxxxxx"
  , region = "xxxxxxx"
  , pathPrefix = "xxxxxxx"
  }

let idfyCfg =
  { account_id = "xxxxxxx",
    api_key = "xxxxxxx",
    secret = "xxxxxxx",
    url = "http://localhost:6235"
  }

let InfoBIPConfig =
  { username = "xxxxx",
    password = "xxxxx",
    token = "xxxxx"
  }

in

{ smsUserName = "xxxxxxx"
, smsPassword = "yyyyyyy"
, exotelCfg = exotelCfg
, s3Config = s3Config
, idfyCfg = idfyCfg
, InfoBIPConfig = InfoBIPConfig
, googleMapsKey = "xxxxxxx"
, slackToken = "xxxxxxx"
}
