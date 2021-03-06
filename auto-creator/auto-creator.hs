import           Control.Monad
import           System.Environment
import           Text.Printf

main :: IO ()
main = do
  args <- map read <$> getArgs :: IO [Int]
  case args of
    [n] -> do
      forM_ [1..n] $ \i -> do
        printf "type N%d = Succ N%d\n" i (i-1)

      forM_ [1..n] $ \i -> do
        printf "n%d = SSucc n%d\n" i (i-1)

      forM_ [1..n] $ \i -> printf "n%d," i
      putStrLn ""

      forM_ [1..n] $ \i -> printf "N%d," i
      putStrLn ""

      putStr "["
      forM_ [n-1, n-2..0] $ \i -> do
        printf "a%d," i
      putStrLn "]"

      putStr "["
      forM_ [n-1,n-2..0] $ \i -> do
        printf "b%d," i
      putStrLn "]"

      forM_ [1..n-1] $ \i -> do
        printf "(c%d, s%d) <- fullAdder -< (a%d, b%d, c%d)\n" i i i i (i-1)
      putStrLn ""

      forM_ [1..n-1] $ \i -> do
        printf "(c%d, s%d) <- fullAdder -< (a%d, inv b%d, c%d)\n" i i i i (i-1)
      putStrLn ""

      forM_ [n-1, n-2..0] $ \i -> printf "s%d:*" i
      putStrLn "End\n"

      forM_ [0..n-1] $ \i -> do
        printf "o%d <- andGate -< (a%d, b%d)\n" i i i
      putStrLn ""

      forM_ [0..n-1] $ \i -> do
        printf "o%d <- orGate -< (a%d, b%d)\n" i i i
      putStrLn ""

      forM_ [n-1, n-2..0] $ \i -> printf "o%d:*" i
      putStrLn "End\n"

    _ -> putStrLn ("input error\nusage: auto-creator 32")
