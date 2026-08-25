## Applicative Functors


Applicative functors extend functors with the ability to apply functions that are themselves wrapped in a context to values in a context. They provide operations for lifting multi-argument functions into the functor context and for sequencing computations with effects.

An applicative functor must implement two primary operations:

1. **pure** (or **of**): Lifts a value into the functor context
2. **apply** (or **<*>**): Applies a wrapped function to a wrapped value

Applicative functors must satisfy four laws: identity, composition, homomorphism, and interchange.

**Key Points:**

- Applicatives enable applying functions with multiple arguments to wrapped values
- They bridge the gap between functors (single argument) and monads (full sequencing)
- The `pure` operation injects values into the minimal context
- The `apply` operation enables function application within contexts
- Applicatives maintain independence between computations (no sequential dependency)
- Useful for parallel validation, form processing, and combining independent effects

**Example:**

```haskell
-- Applicative type class
class Functor f => Applicative f where
    pure :: a -> f a
    (<*>) :: f (a -> b) -> f a -> f b

-- Maybe applicative
instance Applicative Maybe where
    pure = Just
    Nothing <*> _ = Nothing
    (Just f) <*> something = fmap f something

-- Using applicative style
-- Lifting a binary function
addThree :: Int -> Int -> Int -> Int
addThree x y z = x + y + z

result1 = pure addThree <*> Just 1 <*> Just 2 <*> Just 3
-- Just 6

result2 = pure addThree <*> Just 1 <*> Nothing <*> Just 3
-- Nothing

-- List applicative (Cartesian product)
instance Applicative [] where
    pure x = [x]
    fs <*> xs = [f x | f <- fs, x <- xs]

result3 = pure (*) <*> [1,2,3] <*> [4,5]
-- [4,5,8,10,12,15]

-- Applicative style validation
data Validation e a = Failure e | Success a

instance Applicative (Validation [e]) where
    pure = Success
    (Failure e1) <*> (Failure e2) = Failure (e1 ++ e2)
    (Failure e) <*> _ = Failure e
    _ <*> (Failure e) = Failure e
    (Success f) <*> (Success x) = Success (f x)
```

**Output:**

```
Just 6
Nothing
[4,5,8,10,12,15]
```

Applicative functors provide a powerful abstraction for working with multiple independent effectful computations, particularly valuable in scenarios requiring validation accumulation or parallel execution.

