{-# LANGUAGE DataKinds, FlexibleContexts, FlexibleInstances, GADTs #-}
-----------------------------------------------------------------------------
-- |
-- Module      :  Data.Extensible.Union
-- Copyright   :  (c) Fumiaki Kinoshita 2015
-- License     :  BSD3
--
-- Maintainer  :  Fumiaki Kinoshita <fumiexcel@gmail.com>
-- Stability   :  experimental
-- Portability :  non-portable
--
------------------------------------------------------------------------
module Data.Extensible.Union (
    (<$?~)
  , Union(..)
  , liftU
  , Flux(..)
  , mapFlux
  ) where

import Data.Typeable
import Data.Extensible.Internal
import Data.Extensible.Sum
import Data.Extensible.Product
import Data.Extensible.Match
import Unsafe.Coerce

-- | A much more efficient representation for 'Union' of 'Functor's.
newtype Union fs a = Union { getLeague :: Flux a :| fs } deriving Typeable

-- | fast fmap
instance Functor (League fs) where
  fmap f (League (UnionAt pos s)) = League (UnionAt pos (mapFlux f s))
  {-# INLINE fmap #-}

-- | /O(log n)/ Embed a value.
liftU :: (f ∈ fs) => f a -> League fs a
liftU f = Union . embed . Flux id
{-# INLINE liftL #-}

-- | Flipped <http://hackage.haskell.org/package/kan-extensions/docs/Data-Functor-Coyoneda.html Coyoneda>
data Flux a f where
  Flux :: (a -> b) -> f a -> Flux b f

-- | 'fmap' for the content.
mapFlux :: (a -> b) -> Flux a f -> Flux b f
mapFlux f (Flux g m) = Flux (f . g) m
{-# INLINE mapFlux #-}

-- | Prepend a clause for @'Match' ('Flux' x)@ as well as ('<?!').
(<$?~) :: (forall b. f b -> (b -> a) -> a) -> Match (Flux x) a :* fs -> Match (Flux x) a :* (f ': fs)
(<$?~) f = (<:*) (Match (f . meltdown))
infixr 1 <$?~
