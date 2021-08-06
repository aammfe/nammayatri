{-# LANGUAGE DuplicateRecordFields #-}

module Beckn.Types.Core.Tracking where

import Beckn.Utils.Example
import EulerHS.Prelude

data Tracking = Tracking
  { url :: Maybe Text,
    required_params :: Maybe Text,
    metadata :: Maybe Text
  }
  deriving (Generic, FromJSON, ToJSON, Show)

instance Example Tracking where
  example =
    Tracking
      { url = Just "https://api.example.com/track",
        required_params = Just "",
        metadata = Just ""
      }
