## State Monad


The State monad encapsulates stateful computations, threading state through a sequence of operations without explicit state passing. It represents computations that can read from and write to a shared state.

**Key Points:**

- Type: `State s a` represents a computation producing `a` while threading state `s`
- Eliminates manual state threading through function parameters
- Provides `get`, `put`, `modify` for state manipulation
- Pure and referentially transparent despite managing state
- Commonly used for counters, symbol tables, random number generation

The State monad internally represents a function `s -> (a, s)` that takes an initial state and returns a value with the updated state. This function is composed using monadic operations.

```haskell
newtype State s a = State { runState :: s -> (a, s) }

instance Monad (State s) where
  return x = State $ \s -> (x, s)
  (State h) >>= f = State $ \s -> 
    let (a, newState) = h s
        (State g) = f a
    in g newState

-- Core operations
get :: State s s
get = State $ \s -> (s, s)

put :: s -> State s ()
put newState = State $ \_ -> ((), newState)

modify :: (s -> s) -> State s ()
modify f = State $ \s -> ((), f s)
```

**Example:**

```haskell
-- Stack operations using State monad
type Stack = [Int]

pop :: State Stack Int
pop = do
  (x:xs) <- get
  put xs
  return x

push :: Int -> State Stack ()
push x = modify (x:)

stackManipulation :: State Stack Int
stackManipulation = do
  push 10
  push 20
  push 30
  a <- pop
  b <- pop
  push (a + b)
  pop

result = runState stackManipulation []  -- (50, [])
```

**Output:**

```
Final value: 50
Final stack: []
```

State monad enables complex stateful algorithms to be written declaratively. The state threading happens automatically, and the code focuses on the logic rather than plumbing. Multiple state manipulations compose naturally through monadic bind.

