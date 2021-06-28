{-# LANGUAGE ApplicativeDo #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wno-orphans #-}

-- | Utilities for encrypting secret and personal data with external service.
module Beckn.External.Encryption
  ( DbHash (..),
    DbHashable (..),
    EncKind (..),
    Encrypted (..),
    EncryptedField,
    FlowWithEnc,
    EncryptedHashed (..),
    EncryptedHashedField,
    EncryptedBase64 (..),
    encrypt,
    decrypt,
    encryptOne,
    decryptOne,
    deriveTableEncryption,

    -- * Re-exports
    EncryptedItem (..),
    genericEncryptItem,
    genericDecryptItem,
  )
where

import Beckn.Types.Common (FlowR)
import qualified Crypto.Hash as Hash
import Crypto.Hash.Algorithms (SHA256)
import qualified Data.Aeson as Aeson
import qualified Data.ByteArray as BA
import qualified Data.ByteString.Lazy as LBS
import Database.Beam (Beamable, Columnar, HasSqlEqualityCheck (..), Nullable)
import Database.Beam.Backend (FromBackendRow (..), HasSqlValueSyntax (..))
import Database.Beam.Postgres (Postgres)
import Database.Beam.Postgres.Syntax (PgValueSyntax)
import qualified EulerHS.Language as L
import EulerHS.Prelude
import GHC.Records (HasField (..))
import GHC.TypeLits (ErrorMessage (..), TypeError)
import qualified Language.Haskell.TH as TH
import Passetto.Client (EncryptedBase64 (..), EncryptedItem (..), PassettoContext, cliDecrypt, cliEncrypt, genericDecryptItem, genericEncryptItem, mkDefPassettoContext, throwLeft)
import Passetto.Client.EncryptedItem (Encrypted (..))
import Text.Hex (decodeHex, encodeHex)

-- * Encrypted fields

-- | Specifies whether field is encrypted or not.
--
-- Beam table schemas which have some fields encrypted are assumed to be
-- polymorphic over type of this kind; it then should be included into
-- 'EncryptedField' to affect a particular field.
data EncKind
  = AsEncrypted
  | AsUnencrypted

-- | Mark a field as encrypted or not, depending on @e@ argument.
--
-- This always relies on 'ToJSON' and 'FromJSON' instances to serialize the value
-- under the hood. If this does not suit you, use some other type family.
type family EncryptedField (e :: EncKind) (a :: Type) :: Type where
  EncryptedField 'AsEncrypted a = Encrypted a
  EncryptedField 'AsUnencrypted a = a

-- | 'Encrypted' always corresponds to a textual SQL type.
-- Adjust the size to be @4/3@ times greater than JSON encoded plaintext value
-- (because of base64 encoding) + few extra bytes as reserve.
deriving newtype instance HasSqlValueSyntax PgValueSyntax (Encrypted a)

deriving newtype instance FromBackendRow Postgres (Encrypted a)

-- | This instance is prohibited because encryption is not a deterministic
-- operation (different encryption keys can be used each time), so
-- matching on encrypted data does not actually give you any information.
--
-- If you need to lookup by encrypted data, put 'EncryptedHashedField'
-- into table field, and in query match against field hash, e.g.
-- @ myfield.hash ==. val_ (evalDbHash seekedValue) @
instance
  TypeError
    ( 'Text "Matching on encrypted data is not allowed"
        ':$$: 'Text "Match on hash instead"
    ) =>
  HasSqlEqualityCheck Postgres (Encrypted a)

-- ** Encrypted and hashed fields

-- | Hash which we store in the database in order to be able to lookup on a
-- value.
--
-- NOTE: we have decided on this temporary solution, in no way it is assumed
-- to be secure.
-- Implementation of this hash, as well as the overall need in it is to be
-- revised later.
newtype DbHash = DbHash {unDbHash :: ByteString}
  deriving stock (Show, Eq)
  deriving anyclass (HasSqlEqualityCheck Postgres)

-- These json instances are necessary for Euler's ART system only
instance ToJSON DbHash where
  toJSON = toJSON . encodeHex . unDbHash

instance FromJSON DbHash where
  parseJSON = maybe (fail "Bad hex") (pure . DbHash) . decodeHex <=< parseJSON

-- | Corresponds to @bytea@ type in database.
deriving newtype instance HasSqlValueSyntax PgValueSyntax DbHash

deriving newtype instance FromBackendRow Postgres DbHash

type HashAlgo = SHA256

-- FIXME: make configurable. We need to rehash everything with
--   a new salt periodically
hashSalt :: LByteString
hashSalt =
  "How wonderful it is that nobody need wait a single \
  \moment before starting to improve the world"

-- | Typeclass for values which can be hashed.
class DbHashable a where
  evalDbHash :: a -> DbHash
  default evalDbHash :: ToJSON a => a -> DbHash
  evalDbHash = evalDbHash . toJSON

instance DbHashable ByteString where
  evalDbHash = evalDbHash . LBS.fromStrict

instance DbHashable LByteString where
  evalDbHash =
    DbHash . BA.convert @(Hash.Digest HashAlgo) . Hash.hashlazy . (hashSalt <>)

instance DbHashable Text where
  evalDbHash = evalDbHash @ByteString . encodeUtf8

instance DbHashable Aeson.Value where
  evalDbHash = evalDbHash . Aeson.encode

-- | A field which appears encrypted in database along with hash.
--
-- In database this occupies two columns.
--
-- If you need to mark a field as optional, pass @Nullable f@ as
-- the last type argument.
data EncryptedHashed a f = EncryptedHashed
  { encrypted :: Columnar f (Encrypted a),
    hash :: Columnar f DbHash
  }
  deriving stock (Generic)
  deriving anyclass (Beamable)

instance
  (ToJSON a, FromJSON a, DbHashable a) =>
  EncryptedItem (EncryptedHashed a Identity)
  where
  type Unencrypted (EncryptedHashed a Identity) = a
  encryptItem value = do
    let hash = evalDbHash value
    encrypted <- encryptItem value
    return EncryptedHashed {..}
  decryptItem = decryptItem . encrypted

instance
  (ToJSON a, FromJSON a, DbHashable a) =>
  EncryptedItem (EncryptedHashed a (Nullable Identity))
  where
  type Unencrypted (EncryptedHashed a (Nullable Identity)) = Maybe a
  encryptItem mvalue = do
    let hash = evalDbHash <$> mvalue
    encrypted <- encryptItem mvalue
    return EncryptedHashed {..}
  decryptItem = decryptItem . encrypted

-- | Mark a field as encrypted with hash or not, depending on @e@ argument.
--
-- The same considerations as for 'EncryptedField' apply here.
type family EncryptedHashedField (e :: EncKind) (f :: Type -> Type) (a :: Type) :: Type where
  EncryptedHashedField 'AsUnencrypted f a = Columnar f a
  EncryptedHashedField 'AsEncrypted f a = EncryptedHashed a f

-- * Encryption methods

-- FIXME! Modify passetto to use BaseUrl and use it too!
type FlowWithEnc r a = HasField "encService" r (String, Word16) => FlowR r a

-- Helper which allows running passetto client operations in our monad.
withPassettoCtx :: ReaderT PassettoContext IO a -> FlowWithEnc r a
withPassettoCtx action = do
  (host, port) <- getField @"encService" <$> ask
  L.runIO (mkDefPassettoContext host port) >>= L.runIO . runReaderT action

-- | Encrypt given value.
--
-- Note: this performs not more than one call to server, so try to avoid using
-- multiple subsequent invocations of this method in favor of passing complex
-- structures (e.g. tuples) through it.
encrypt :: EncryptedItem e => Unencrypted e -> FlowWithEnc r e
encrypt payload = withPassettoCtx $ throwLeft =<< cliEncrypt payload

-- | Decrypt given value.
decrypt :: EncryptedItem e => e -> FlowWithEnc r (Unencrypted e)
decrypt encrypted = withPassettoCtx $ throwLeft =<< cliDecrypt encrypted

-- | Simplified version of 'encrypt'.
--
-- In some cases 'encrypt' requires specifying resulting type explicitly,
-- but here it is not necessary.
encryptOne :: (ToJSON a, FromJSON a) => a -> FlowWithEnc r (Encrypted a)
encryptOne = encrypt

-- | Simplified version of 'decrypt'.
decryptOne :: (ToJSON a, FromJSON a) => Encrypted a -> FlowWithEnc r a
decryptOne = decrypt

-- | Derive an instance which allows running 'encrypt' and 'decrypt' on
-- the entire table.
--
-- Your table should be defined as a datatype standing for a Beam schema,
-- it must have two type arguments - @e :: EncKind@ and @f :: Type -> Type@.
--
-- Note that it is not yet clear how well automatic derivation will work,
-- in case of any problems (arising at compile-time) feel free to write
-- 'EncryptedItem' instance and implementation for its methods manually.
-- This definition is just a meta-programming helper alias.
deriveTableEncryption :: TH.Name -> TH.DecsQ
deriveTableEncryption name = do
  let tyQ = pure (TH.ConT name)
  [d|
    -- Type arguments in instance head are constrained like this to make
    -- GHC infer them when our table is encrypted or decrypted.
    -- Otherwise, users of 'decrypt' would often have to specify the
    -- exact type of the decrypted thing manually in order for this instance
    -- to be applied.
    instance
      (e ~ 'AsEncrypted, f ~ Identity) =>
      EncryptedItem ($tyQ e f)
      where
      type Unencrypted ($tyQ e f) = $tyQ 'AsUnencrypted Identity
      encryptItem = genericEncryptItem
      decryptItem = genericDecryptItem
    |]
