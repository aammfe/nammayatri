module Beckn.Prelude (module E, module Beckn.Prelude) where

import Control.Exception as E (SomeException)
import Control.Exception.Safe as E (try)
import Control.Monad.Catch as E
  ( Exception (..),
    MonadCatch (..),
    MonadThrow (..),
    SomeException (..),
  )
import Control.Monad.Reader as E
import Data.Aeson as E (FromJSON (..), ToJSON (..), genericParseJSON, genericToJSON)
import Data.Foldable as E
import Data.Function as E hiding (id)
import Data.Functor as E
import Data.Functor.Identity as E
import Data.Kind as E (Type)
import Data.Maybe as E (fromMaybe, listToMaybe)
import Data.OpenApi as E (ToSchema)
import Data.Proxy as E (Proxy (..))
import Data.String as E (IsString (..))
import Data.Text as E (Text)
import Data.Time.Clock as E (UTCTime)
import GHC.Generics as E (Generic, Generic1)
import GHC.Records.Compat as E
import GHC.Stack as E (HasCallStack)
import Servant.Client as E (BaseUrl)
import Universum.Debug as E
import Universum.String.Conversion as E
import Prelude as E hiding (error, id, log, show, undefined)

foldWIndex :: (Integer -> acc -> a -> acc) -> acc -> [a] -> acc
foldWIndex f acc p = snd $ foldl' (\(i, acc') c -> (i + 1, f i acc' c)) (0, acc) p

identity :: p -> p
identity a = a

everyPossibleVariant :: (Enum a, Bounded a) => [a]
everyPossibleVariant = [minBound .. maxBound]

whenJust :: Applicative m => Maybe a -> (a -> m ()) -> m ()
whenJust mg f = maybe (pure ()) f mg

whenM :: Monad m => m Bool -> m () -> m ()
whenM mb thing = do
  b <- mb
  when b thing

unlessM :: Monad m => m Bool -> m () -> m ()
unlessM mb = whenM (not <$> mb)
