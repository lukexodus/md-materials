## Functor Concept


A functor is a type class that represents computational contexts that can be mapped over. It abstracts the pattern of applying a function to value(s) wrapped in a context without removing them from that context. Functors preserve structure while transforming contents.

The functor must satisfy two laws:

1. **Identity law**: Mapping the identity function over a functor returns the original functor unchanged
2. **Composition law**: Mapping a composition of functions is equivalent to mapping each function in sequence

**Key Points:**

- Functors are containers or computational contexts that support the map operation
- The structure of the functor is preserved during mapping
- Common functors include: List, Maybe/Option, Either, Tree, and Function types
- Functors enable composition of transformations without unpacking values

**Example:**

```haskell
-- Functor type class definition
class Functor f where
    fmap :: (a -> b) -> f a -> f b

-- Maybe functor instance
instance Functor Maybe where
    fmap _ Nothing = Nothing
    fmap f (Just x) = Just (f x)

-- List functor instance
instance Functor [] where
    fmap = map

-- Usage
fmap (+1) (Just 5)        -- Just 6
fmap (*2) [1,2,3,4]       -- [2,4,6,8]
fmap length (Just "hello") -- Just 5
```

**Output:**

```
Just 6
[2,4,6,8]
Just 5
```

The functor abstraction allows generic programming over any mappable context, making code more reusable and compositional.

