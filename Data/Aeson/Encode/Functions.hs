module Data.Aeson.Encode.Functions
    (
      brackets
    , builder
    , char7
    , foldable
    , list
    , pairs
    ) where

import Data.Aeson.Encode.Builder
import Data.Aeson.Types.Class
import Data.Aeson.Types.Internal
import Data.ByteString.Builder (Builder, char7)
import Data.ByteString.Builder.Prim (primBounded)
import Data.Foldable (Foldable, foldMap)
import Data.Monoid ((<>), mempty)

builder :: ToJSON a => a -> Builder
builder = fromEncoding . toEncoding
{-# INLINE builder #-}

-- | Encode a 'Foldable' as a JSON array.
foldable :: (Foldable t, ToJSON a) => t a -> Encoding
foldable = brackets '[' ']' . foldMap (Value . toEncoding)
{-# INLINE foldable #-}

list :: (ToJSON a) => [a] -> Encoding
list []     = emptyArray_
list (x:xs) = Encoding $
              char7 '[' <> builder x <> commas xs <> char7 ']'
      where commas = foldr (\v vs -> char7 ',' <> builder v <> vs) mempty
{-# INLINE list #-}

brackets :: Char -> Char -> Series -> Encoding
brackets begin end (Value v) = Encoding $
                               char7 begin <> fromEncoding v <> char7 end
brackets begin end Empty     = Encoding (primBounded (ascii2 (begin,end)) ())

-- | Encode a series of key/value pairs, separated by commas.
pairs :: Series -> Encoding
pairs Empty     = mempty
pairs (Value v) = v
