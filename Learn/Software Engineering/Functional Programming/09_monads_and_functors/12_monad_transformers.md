## Monad Transformers


Monad transformers allow combining multiple monadic effects into a single computational context. They stack monads vertically, enabling access to multiple effect types simultaneously without manually threading them.

**Key Points:**

- Type: `MonadT m a` adds effect `T` to underlying monad `m`
- `lift` operation promotes actions from inner monad to transformer
- Transformers build a stack: `StateT s (ReaderT r (ExceptT e IO)) a`
- Order matters—different stacks provide different capabilities
- Common transformers: `StateT`, `ReaderT`, `ExceptT`, `MaybeT`, `WriterT`

Each transformer is defined by wrapping an inner monad. The transformer's `bind` operation handles both its own effect and delegates to the inner monad. The `lift` function allows using operations from any layer of the stack.

```haskell
-- StateT transformer definition
newtype StateT s m a = StateT { runStateT :: s -> m (a, s) }

instance Monad m => Monad (StateT s m) where
  return x = StateT $ \s -> return (x, s)
  (StateT h) >>= f = StateT $ \s -> do
    (a, newState) <- h s
    let (StateT g) = f a
    g newState

-- Lift operation
lift :: Monad m => m a -> StateT s m a
lift ma = StateT $ \s -> do
  a <- ma
  return (a, s)

-- ReaderT transformer
newtype ReaderT r m a = ReaderT { runReaderT :: r -> m a }

-- ExceptT transformer
newtype ExceptT e m a = ExceptT { runExceptT :: m (Either e a) }
```

**Example:**

```haskell
-- Combining State, Reader, and Exception handling
type AppConfig = String
type AppState = Int
type AppError = String
type App a = StateT AppState (ReaderT AppConfig (ExceptT AppError IO)) a

-- Using the stack
computation :: App Int
computation = do
  config <- lift ask                    -- ReaderT operation
  state <- get                          -- StateT operation
  when (state < 0) $
    lift $ lift $ throwError "Negative state"  -- ExceptT operation
  lift $ lift $ lift $ putStrLn "Computing..."  -- IO operation
  modify (+1)
  return (state + length config)

runApp :: App a -> AppConfig -> AppState -> IO (Either AppError (a, AppState))
runApp app config initialState = 
  runExceptT $ runReaderT (runStateT app initialState) config
```

**Output:**

```
Computing...
Result: Right (10, 1)  -- assuming initial state 0 and config length 10
```

Monad transformers enable modular effect composition. Instead of creating monolithic monads for every effect combination, transformers allow mixing and matching effects as needed. The type system tracks all effects, and operations compose seamlessly across the stack.

