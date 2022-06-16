module Tools.JSON where

import Beckn.Prelude
import Data.Aeson

fareProductOptions :: Options
fareProductOptions =
  defaultOptions
    { sumEncoding = fareProductTaggedObject,
      constructorTagModifier = fareProductConstructorModifier
    }

fareProductTaggedObject :: SumEncoding
fareProductTaggedObject =
  defaultTaggedObject
    { tagFieldName = "fareProductType"
    }

fareProductConstructorModifier :: String -> String
fareProductConstructorModifier = \case
  "OneWayAPIDetails" -> "ONE_WAY"
  "RentalAPIDetails" -> "RENTAL"
  x -> x
