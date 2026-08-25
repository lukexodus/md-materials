## IO Monad Concept


The IO monad represents computations that interact with the external world. It separates pure functional code from impure effects, maintaining referential transparency at the type level while enabling real-world interactions.

**Key Points:**

- Type: `IO a` represents an action that performs I/O and produces `a`
- Cannot be escaped—once in IO, always in IO
- Sequencing of effects is explicit and controlled
- Lazy evaluation doesn't execute IO actions until explicitly run
- Main entry point `main :: IO ()` drives the entire program

IO monad is special because it's typically a primitive provided by the runtime system. It cannot be implemented in pure Haskell—the runtime handles actual execution of effects. The monad structure ensures effects occur in the specified order.

```haskell
-- IO monad interface (conceptual)
-- Actual implementation is runtime-level

-- Basic IO operations
getLine :: IO String
putStrLn :: String -> IO ()
readFile :: FilePath -> IO String
writeFile :: FilePath -> String -> IO ()

-- Sequencing IO actions
greet :: IO ()
greet = do
  putStrLn "What's your name?"
  name <- getLine
  putStrLn ("Hello, " ++ name)

-- IO actions are first-class values
delayedGreeting :: IO ()
delayedGreeting = greet  -- Not executed yet
```

**Example:**

```haskell
-- File processing with IO monad
processFile :: FilePath -> IO ()
processFile path = do
  contents <- readFile path
  let lineCount = length (lines contents)
      wordCount = length (words contents)
  putStrLn $ "Lines: " ++ show lineCount
  putStrLn $ "Words: " ++ show wordCount
  writeFile (path ++ ".stats") $ 
    "Lines: " ++ show lineCount ++ "\nWords: " ++ show wordCount

-- Combining multiple IO operations
main :: IO ()
main = do
  files <- getArgs
  mapM_ processFile files
  putStrLn "Processing complete"
```

The IO monad boundary creates a clear separation between pure and impure code. Pure functions can be tested and reasoned about independently, while IO actions explicitly declare their effects in the type system. This architecture prevents accidental side effects from contaminating pure code.

