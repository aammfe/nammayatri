module Beckn.Spec.OnCancel
  ( module Beckn.Spec.OnCancel,
    module Reexport,
  )
where

import Beckn.Spec.OnStatus.Descriptor as Reexport
import Beckn.Spec.OnStatus.Item as Reexport
import Beckn.Spec.OnStatus.Order as Reexport
import Beckn.Spec.OnStatus.Params as Reexport
import Beckn.Spec.OnStatus.Time as Reexport
import Kernel.Prelude

newtype OnCancelMessage = OnCancelMessage
  { order :: Order
  }
  deriving stock (Generic, Show)
  deriving anyclass (FromJSON, ToJSON, ToSchema)
