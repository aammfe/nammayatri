module API.Beckn.Handler where

import qualified API.Beckn.OnSearch.Handler as OnSearch
import qualified API.Beckn.Types as Beckn
import App.Types

handler :: FlowServer Beckn.API
handler = OnSearch.handler
