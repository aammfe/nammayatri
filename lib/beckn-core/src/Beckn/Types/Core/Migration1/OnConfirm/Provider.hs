module Beckn.Types.Core.Migration1.OnConfirm.Provider where

import Beckn.Utils.Example (Example (..))
import Data.OpenApi (ToSchema)
import EulerHS.Prelude

newtype Provider = Provider
  { name :: Text
  }
  deriving (Generic, Show, ToJSON, FromJSON, ToSchema)

instance Example Provider where
  example =
    Provider
      { name = "Yatri Cabs"
      }
