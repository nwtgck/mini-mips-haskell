-- Yampaを使って論理回路を作る
-- TODO Bitsに長さを含めて型付けする（ビット違いの配線ミスを防ぐため）(多少型付けした)

{-# LANGUAGE Arrows         #-}
{-# LANGUAGE DataKinds      #-}
-- {-# LANGUAGE DatatypeContexts #-}
{-# LANGUAGE GADTs          #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE TypeFamilies   #-}
{-# LANGUAGE TypeOperators  #-}
-- {-# LANGUAGE TypeFamilyDependencies #-}

import           Control.Concurrent
import           Control.Monad
import           Data.Bits          (shift, (.|.))
import           Data.IORef
import           Data.Maybe
-- import           FRP.Yampa
import           Unsafe.Coerce

-- data N0 = N0 deriving Show
-- data Nat n => Succ n = Succ n deriving Show
-- type N1 = Succ N0
-- type N2 = Succ N1
-- type N3 = Succ N2
-- type N4 = Succ N3
-- type N5 = Succ N4

-- class Nat n
-- instance Nat N0
-- instance Nat n => Nat (Succ n)

-- data Nat = N0 | Succ Nat

-- class Natural (n :: Nat)
-- instance Natural N0
-- instance Natural n => Natural (Succ n)


data Succ n = Succ n deriving (Eq, Show)
data N0 = N0 deriving (Eq, Show)
class (Eq n, Show n) => Nat n
instance Nat N0
instance Nat n => Nat (Succ n)

type N1 = Succ N0
type N2 = Succ N1
type N3 = Succ N2

-- n1 = Succ N0
-- n2 = Succ n1
-- n3 = Succ n2
-- n4 = Succ n3
-- n5 = Succ n4

n0 = SN0
n1 = SSucc n0
n2 = SSucc n1
n3 = SSucc n2
n4 = SSucc n3
n5 = SSucc n4
n6 = SSucc n5
n7 = SSucc n6

inc :: SNat n -> SNat (N1 + n)
inc SN0       = SSucc SN0
inc (SSucc n) = SSucc $ SSucc n

(#+) :: SNat n -> SNat m -> SNat (n + m)
SN0 #+ b   = b
(SSucc a) #+ b = SSucc (a #+ b)
infixl 6 #+

type family a + b :: * where
  N0 + b       = b
  -- Add a N0       = a
  (Succ a) + b = Succ (a + b)
infixl 6 +

type family Sub a b :: * where
  Sub N0 b               = N0
  Sub a N0               = a
  Sub (Succ a) (Succ b)  = Sub a b

-- O, I, X mean 0, 1, x respectively
data Bit = O | I | X

instance Show Bit where
  show O = "0"
  show I = "1"
  show X = "x"

data SNat n :: * where
  SN0   :: SNat N0
  SSucc :: SNat n ->  SNat (Succ n)

-- Bits synonim can be changed, so I use the synonim
data Bits :: * -> * where
  End :: Bits N0
  (:-) :: Bit -> Bits n -> Bits (Succ n)

infixr 0 :-

instance Show (Bits n) where
  show End     = ""
  show (b:-bs) = show b ++ show bs
--
dropBits :: SNat n -> Bits m -> Bits (Sub m n)
dropBits SN0 bits           = bits
dropBits (SSucc n) (b:-bs)  = dropBits n bs

takeBits :: SNat n -> Bits m -> Bits n
takeBits SN0 bits           = End
takeBits (SSucc n) (b:-bs)  = b :- (takeBits n bs)

drop3Bits :: Nat m => m -> Bits n -> Bits (Sub n N3)
drop3Bits _ (a:-b:-c:-bs) = bs


headBits :: Bits (Succ n) -> Bit
headBits (b:-bs) = b

lastBits :: Bits (Succ n) -> Bit
lastBits (b:-End) = b
lastBits (_:-bs)  = lastBits (unsafeCoerce bs :: Bits n)

drop2Bits :: Bits n -> Bits (Sub n N2)
drop2Bits (a:-b:-bs) = bs

sub 0 b = 0
sub a 0 = a
sub a b = sub (a-1) (b-1)

-- range :: SNat n -> SNat m -> Bits l -> Bits (Sub )

snatValue :: SNat n -> String
snatValue SN0       = "0."
snatValue (SSucc n) = "1+" ++ snatValue n

main :: IO ()
main = do
  let bits1   = I:-I:-O:-I:-End
      -- (b:-bs) = bits1
  print $ headBits  bits1
  print $ drop2Bits bits1
  print $ lastBits  bits1
  print $ snatValue (SN0)
  print $ snatValue (SSucc SN0)
  print $ snatValue (SSucc $ SSucc SN0)
  print $ dropBits n3 bits1
  print $ takeBits n3 bits1
  print $ snatValue $ n3 #+ n1
  return ()
