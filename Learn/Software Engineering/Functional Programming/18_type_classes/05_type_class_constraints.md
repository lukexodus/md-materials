## Type Class Constraints


Type class constraints restrict polymorphic functions to types that implement specific interfaces. They establish requirements that type parameters must satisfy, enabling generic code to assume certain operations are available without knowing concrete types.

**Syntax and semantics:**

Constraints appear in type signatures between the context and the main type:

```haskell
sort :: Ord a => [a] -> [a]
sum :: Num a => [a] -> a
show :: Show a => a -> String
```

The constraint `Ord a =>` reads as "for any type `a` that is an instance of Ord." This guarantees the function can use comparison operations on values of type `a`.

**Multiple constraints:**

Functions may require several type class memberships:

```haskell
display :: (Show a, Ord a) => [a] -> String
display xs = show (sort xs)
```

The type variable `a` must satisfy both `Show` and `Ord`. Constraints combine conjunctively—all must hold.

**Constraint propagation:**

When a function calls another with constraints, those constraints propagate:

```haskell
-- maximum requires Ord constraint
-- maximum :: Ord a => [a] -> a

findLargest :: Ord a => [[a]] -> a
findLargest xss = maximum (map maximum xss)
```

The `Ord a` constraint flows from `maximum` to `findLargest`. The compiler infers this automatically.

**Higher-order constraints:**

Constraints can apply to type constructors:

```haskell
-- Functor constraint on type constructor f
mapTwice :: Functor f => (a -> b) -> f a -> f b
mapTwice g = fmap g . fmap g

-- Multiple constructor constraints
convert :: (Functor f, Foldable f) => f a -> [a]
convert = foldr (:) [] . fmap id
```

**Constraint solving:**

The type checker verifies constraints are satisfied:

1. **At call sites**: Concrete types must have required instances
2. **At definitions**: Constraints must cover all operations used
3. **Through composition**: Transitive requirements are traced

```haskell
-- This compiles: Int has Ord instance
sorted = sort [3, 1, 4, 1, 5]

-- This fails: functions lack Ord instance
badSort = sort [(+1), (+2), (+3)]  -- Type error
```

**Existential constraints:**

Existential types can hide type parameters while preserving constraints:

```haskell
data Showable = forall a. Show a => MkShowable a

helloShowable :: Showable -> String
helloShowable (MkShowable x) = "Hello " ++ show x
```

The concrete type `a` is hidden, but the `Show` constraint ensures `show` remains available.

**Default implementations:**

Type classes can provide default method implementations based on other methods:

```haskash
class Eq a where
  (==) :: a -> a -> Bool
  (/=) :: a -> a -> Bool
  
  -- Default implementations
  x == y = not (x /= y)
  x /= y = not (x == y)
```

Minimal complete definitions require implementing sufficient methods for defaults to work. This reduces boilerplate when declaring instances.

**Constraint kinds:**

Advanced type systems support constraints as first-class entities:

```haskell
type Serializable a = (Show a, Read a)

process :: Serializable a => a -> a
process x = read (show x)
```

Constraint synonyms group related requirements under meaningful names.

**Superclass constraints:**

Type classes can require other classes as prerequisites:

```haskell
class Eq a => Ord a where
  compare :: a -> a -> Ordering
  (<) :: a -> a -> Bool
  -- other methods
```

Every `Ord` instance automatically has `Eq` available. The superclass constraint establishes a hierarchy where equality must exist before ordering.

**Implications for reasoning:**

Constraints enable parametric reasoning with additional assumptions. Code polymorphic in `a` with constraint `C a` can:

- Use all operations from `C`
- Maintain type safety across different `a` instances
- Benefit from automatic specialization at compile time

The constraint system balances generality with capability—more constraints mean less generality but more usable operations.

