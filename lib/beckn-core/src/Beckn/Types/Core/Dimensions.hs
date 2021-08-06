module Beckn.Types.Core.Dimensions where

import Beckn.Types.Core.Scalar
import Beckn.Utils.Example
import EulerHS.Prelude hiding (length)

data Dimensions = Dimensions
  { length :: Scalar,
    breadth :: Scalar,
    height :: Scalar
  }
  deriving (Generic, FromJSON, ToJSON, Show)

instance Example Dimensions where
  example =
    Dimensions
      { length = example,
        breadth = example,
        height = example
      }
