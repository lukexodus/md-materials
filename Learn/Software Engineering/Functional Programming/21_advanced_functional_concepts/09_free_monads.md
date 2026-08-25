## Free Monads


Free monads provide a way to build composable, interpretable programs by separating the description of a computation from its execution. They transform any functor into a monad without requiring additional constraints, enabling you to build abstract syntax trees (ASTs) that can be interpreted in multiple ways.

**Structure and Construction**

A free monad over a functor `F` is defined recursively:

```haskell
data Free f a = Pure a | Free (f (Free f a))
```

The `Pure` constructor represents a completed computation with a value, while `Free` wraps another layer of the functor containing more computations. This structure allows you to build computation trees where each node represents an effectful operation defined by your functor.

**Monad Instance**

The monad instance for Free doesn't require `F` to be a monad—only a functor:

```haskell
instance Functor f => Monad (Free f) where
  return = Pure
  Pure a >>= f = f a
  Free fa >>= f = Free (fmap (>>= f) fa)
```

The bind operation recursively threads the continuation through the computation tree, demonstrating how free monads defer actual computation until interpretation.

**Building DSLs**

Free monads excel at creating domain-specific languages. Define your operations as a functor representing primitive commands:

```haskell
data FileSystemF next
  = ReadFile FilePath (String -> next)
  | WriteFile FilePath String next
  | DeleteFile FilePath next

instance Functor FileSystemF where
  fmap f (ReadFile path k) = ReadFile path (f . k)
  fmap f (WriteFile path content next) = WriteFile path content (f next)
  fmap f (DeleteFile path next) = DeleteFile path (f next)

type FileSystem = Free FileSystemF
```

Smart constructors make the DSL ergonomic:

```haskell
readFile' :: FilePath -> FileSystem String
readFile' path = Free (ReadFile path Pure)

writeFile' :: FilePath -> String -> FileSystem ()
writeFile' path content = Free (WriteFile path content (Pure ()))
```

**Interpreters**

The power of free monads lies in multiple interpretation strategies. You can interpret the same program into different monads:

```haskell
interpretIO :: FileSystem a -> IO a
interpretIO (Pure a) = return a
interpretIO (Free (ReadFile path k)) = do
  content <- readFile path
  interpretIO (k content)
interpretIO (Free (WriteFile path content next)) = do
  writeFile path content
  interpretIO next

interpretTest :: FileSystem a -> State (Map FilePath String) a
interpretTest (Pure a) = return a
interpretTest (Free (ReadFile path k)) = do
  content <- gets (Map.lookup path)
  interpretTest (k (fromMaybe "" content))
```

**Performance Considerations**

Free monads incur overhead from building and traversing computation trees. Each bind operation adds a layer of indirection. For performance-critical code, consider:

- **Freer monads** (extensible effects): Use type-aligned sequences to optimize bind
- **Tagless final**: Encode effects as type classes, eliminating intermediate structures
- **Operational monads**: Similar to free monads but with different performance characteristics

**Composing Effects**

Free monads naturally compose through coproducts (sums of functors):

```haskell
data (f :+: g) a = InL (f a) | InR (g a)

type App = Free (FileSystemF :+: LoggingF :+: NetworkF)
```

This enables modular effect systems where you can inject and handle different capabilities independently.

