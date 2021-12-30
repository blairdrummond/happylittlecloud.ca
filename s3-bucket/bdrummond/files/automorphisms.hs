import Prelude hiding ((+),(*),(^))
import Data.List (permutations,(\\))
import Data.Maybe (fromJust)


{- Define the operators -}
infix 1 ^ -- Xor
(^) a b = (not a && b) || (a && not b)
          
          
infix 2 * -- High Associativity Matrix multiplication
(*) [a,b,c,d] [w,x,y,z] = [(a&&w) ^ (b&&y),
                           (a&&x) ^ (b&&z),
                           (c&&w) ^ (d&&y),
                           (c&&x) ^ (d&&z)
                          ]

infix 1 + -- Low Associativity Matrix addition
(+) = zipWith (^)
      

type Mat = [Bool]



-- cartesian product over a family
cart :: [[a]] -> [[a]] 
cart = sequence
{- Done with that -}




       
{- Split up the space of matrices -}
one  = [True, False,False,True] 
zero = [False,False,False,False]

pool = cart (replicate 4 [True,False]) \\ [one , zero]

units = filter unit pool
    where
      -- determinant = 1 = True?
      unit [a,b,c,d] = (a && d) ^ (b && c) 

nilpotents = filter nilpotent pool
    where
      --  "$" changes the associativity (it forces the right side to be evaluated)
      nilpotent a =  zero `elem` (take 16 $ tail $ iterate (a*) a)

idempotents = filter idempotent pool
    where
      idempotent a = a == (a * a) 
{- That's all we need there -}




--  "f . g" == "f ∘ g"
automorphisms :: [Mat -> Mat]
automorphisms = filter homomorphism $ map (fun . concat) $ cart $ map perm matrices
    where
      matrices = [[one], [zero], (idempotents \\ units), nilpotents, units]
      perm l = map (zip l) $ permutations l

      -- "\x ->" = "λx ↦"
      fun :: [(Mat, Mat)] -> (Mat -> Mat)
      fun l = (\a -> fromJust $ lookup a l)

      homomorphism :: (Mat -> Mat) -> Bool
      homomorphism f = ( f `preserves` (*) ) && ( f `preserves` (+) )
          where
            f `preserves` op = all
                               (\[a,b] -> ((f (a `op` b)) == ((f a) `op` (f b))))
                               (cart [pool,pool])


main = mapM_ (putStrLn . (\f -> show [ (a, f a) | a <- pool ]  ++ "\n\n")) $ automorphisms
