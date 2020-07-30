module App.Utils where

import Beckn.Types.Core.Context
import Beckn.Types.Core.Location
import Beckn.Types.FMD.API.Search
import Beckn.Types.FMD.API.Select
import Beckn.Types.FMD.Intent
import Beckn.Types.FMD.Order
import Beckn.Types.FMD.Task
import Beckn.Utils.Common
import Data.Time
import EulerHS.Prelude
import System.Environment (lookupEnv)

address :: Address
address =
  Address
    { door = "#817",
      building = "Juspay Apartments",
      street = "27th Main",
      area = "8th Block Koramangala",
      city = "Bangalore",
      country = "India",
      area_code = "560047"
    }

gps :: GPS
gps =
  GPS
    { lat = "12.9401108",
      lon = "77.6206631"
    }

location :: Location
location =
  Location
    { _type = "gps",
      _gps = Just gps,
      _address = Just address,
      _station_code = Nothing,
      _area_code = Nothing,
      _city = Nothing,
      _country = Nothing,
      _circle = Nothing,
      _polygon = Nothing,
      _3dspace = Nothing
    }

buildIntent :: SearchIntent
buildIntent =
  SearchIntent
    { intent =
        Intent
          { _query_string = Nothing,
            _provider_id = Nothing,
            _category_id = Nothing,
            _item_id = Nothing,
            _pickups = [location],
            _drops = [location],
            _packages = [],
            _tags = []
          }
    }

buildDraftOrder :: Text -> IO Order
buildDraftOrder itemId = do
  now <- toLocalTime <$> getCurrentTime
  return $
    Order
      { _id = "draft-task-1",
        _state = "DRAFT", -- FIXME?
        _items = [itemId],
        _created_at = now,
        _updated_at = now,
        _tasks =
          [ Task
              { _id = "draft-task-1",
                _next_task_id = Nothing,
                _previous_task_id = Nothing,
                _state = "", -- FIXME: no relevant value in spec
                _pickup = PickupOrDrop location [] example,
                _drop = PickupOrDrop location [] example,
                _package = example, -- FIXME: references item and price
                _agent = example, -- FIXME: we can't fill this
                _vehicle = example, -- FIXME: we can't fill this
                _created_at = now,
                _updated_at = now
              }
          ]
      }

buildContext :: Text -> Text -> IO Context
buildContext act tid = do
  localTime <- getFutureTime
  bapId <- lookupEnv "MOCK_APP_ID"
  bapNwAddr <- lookupEnv "MOCK_APP_NW_ADDRESS"
  return $
    Context
      { _domain = "FINAL-MILE-DELIVERY",
        _action = act,
        _country = Nothing,
        _city = Nothing,
        _core_version = Just "0.8.0",
        _domain_version = Just "0.7.0",
        _bap_id = fromString <$> bapId,
        _bg_id = Nothing,
        _bpp_id = Nothing,
        _bap_nw_address = fromString <$> bapNwAddr,
        _bg_nw_address = Nothing,
        _bpp_nw_address = Nothing,
        _request_transaction_id = tid,
        _timestamp = localTime,
        _token = Nothing
      }

toLocalTime :: UTCTime -> LocalTime
toLocalTime = zonedTimeToLocalTime . utcToZonedTime utc

getFutureTime :: IO LocalTime
getFutureTime =
  -- Generate a time 2 hours in to the future else booking will fail
  toLocalTime . addUTCTime 7200 <$> getCurrentTime

buildSearchReq :: Text -> IO SearchReq
buildSearchReq tid = SearchReq <$> buildContext "search" tid <*> pure buildIntent

buildSelectReq :: Context -> Text -> IO SelectReq
buildSelectReq ctx itemId = do
  order <- buildDraftOrder itemId
  return $
    SelectReq
      { context = ctx {_action = "select"},
        message = DraftOrder order
      }
