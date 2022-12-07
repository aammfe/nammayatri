module Domain.Types.FareParams where

import Beckn.Prelude
import Beckn.Types.Common (Centesimal, Money)
import Beckn.Utils.GenericPretty (PrettyShow)

data FareParameters = FareParameters
  { baseFare :: Money,
    extraKmFare :: Maybe Money,
    driverSelectedFare :: Maybe Money,
    nightShiftRate :: Maybe Centesimal,
    nightCoefIncluded :: Bool,
    waitingChargePerMin :: Maybe Money
  }
  deriving (Generic, Show, Eq, PrettyShow)
