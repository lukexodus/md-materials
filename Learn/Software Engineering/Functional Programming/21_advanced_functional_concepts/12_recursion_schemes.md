## Recursion Schemes


Recursion schemes are a family of combinators that capture common patterns of recursion, enabling you to write recursive functions without explicit recursion. They provide a structured approach to traversing and transforming recursive data structures.

**Core Schemes**

Beyond catamorphisms and anamorphisms, several other schemes capture specific patterns:

**Paramorphisms** provide access to both the accumulated result and the original substructure at each step:

```haskell
para :: Functor f => (f (Fix f, a) -> a) -> Fix f -> a
para alg = alg . fmap (\x -> (x, para alg x)) . unFix
```

This enables computations that need context from the original structure. For example, computing factorial where you need both the current number and the recursive result:

```haskell
data NatF r = Zero | Succ r
  deriving Functor

type Nat = Fix NatF

factAlg :: NatF (Nat, Int) -> Int
factAlg Zero = 1
factAlg (Succ (n, acc)) = (natToInt n + 1) * acc
```

**Apomorphisms** are the dual of paramorphisms, allowing early termination during structure building:

```haskell
apo :: Functor f => (a -> f (Either (Fix f) a)) -> a -> Fix f
apo coalg = Fix . fmap (either id (apo coalg)) . coalg
```

The coalgebra can return `Left structure` to reuse existing structure or `Right seed` to continue generating.

**Histomorphisms** provide access to all previously computed results through a course-of-values structure:

```haskell
data Cofree f a = Cofree a (f (Cofree f a))

histo :: Functor f => (f (Cofree f a) -> a) -> Fix f -> a
histo alg = extract . cata (\x -> Cofree (alg x) x)
  where extract (Cofree a _) = a
```

This enables dynamic programming–style computations where you need arbitrary historical values. Computing Fibonacci numbers efficiently uses histomorphisms naturally.

**Futumorphisms** are dual to histomorphisms, allowing generation of multiple future layers at once:

```haskell
data Free f a = Pure a | Free (f (Free f a))

futu :: Functor f => (a -> f (Free f a)) -> a -> Fix f
futu coalg = Fix . fmap (either id (futu coalg) . unFree) . coalg
  where
    unFree (Pure a) = Left (futu coalg a)
    unFree (Free f) = Right f
```

**Mutumorphisms** capture mutual recursion—two functions defined in terms of each other:

```haskell
mutu :: Functor f => (f (a, b) -> a) -> (f (a, b) -> b) -> Fix f -> a
mutu alg1 alg2 = fst . cata (\x -> (alg1 x, alg2 x))
```

This pattern appears when defining even/odd predicates or evaluating mutually recursive grammars.

**Chronomorphisms** compose histomorphisms and futumorphisms, enabling time-traveling computations:

```haskell
chrono :: Functor f => (f (Cofree f b) -> b) -> (a -> f (Free f a)) -> a -> b
chrono alg coalg = histo alg . futu coalg
```

**Dynamorphisms** compose anamorphisms and histomorphisms, useful for dynamic programming where you generate and consume with history:

```haskell
dyna :: Functor f => (f (Cofree f b) -> b) -> (a -> f a) -> a -> b
dyna alg coalg = histo alg . ana coalg
```

**Zygohistomorphisms** combine zygomorphisms (catamorphisms with an auxiliary value) and histomorphisms, providing both a helper computation and historical access:

```haskell
zygoHisto :: Functor f => (f b -> b) -> (f (Cofree f (a, b)) -> a) -> Fix f -> a
```

[Inference] This scheme is particularly useful for complex traversals requiring both immediate context and historical values.

**Practical Application: Syntax Tree Optimization**

Recursion schemes excel at compiler passes and AST transformations:

```haskell
-- Constant folding using a catamorphism
constantFoldAlg :: ExprF Expr -> Expr
constantFoldAlg (Add (Const 0) x) = x
constantFoldAlg (Add x (Const 0)) = x
constantFoldAlg (Mul (Const 1) x) = x
constantFoldAlg (Mul x (Const 1)) = x
constantFoldAlg (Mul (Const 0) _) = Const 0
constantFoldAlg (Mul _ (Const 0)) = Const 0
constantFoldAlg x = Fix x

constantFold :: Expr -> Expr
constantFold = cata constantFoldAlg
```

**Recursion Scheme Libraries**

The `recursion-schemes` library in Haskell provides implementations and utilities. It uses type families to associate base functors with their recursive types automatically:

```haskell
type family Base t :: * -> *
type instance Base [a] = ListF a
type instance Base (Tree a) = TreeF a

type Recursive t = (Functor (Base t), ...)
```

This enables writing recursion schemes for any recursive type without manual fixed-point wrapping.

**Advantages**

Recursion schemes provide:

- **Separation of concerns**: Traversal logic separates from business logic
- **Composability**: Schemes compose to handle complex patterns
- **Reusability**: Write algebras once, apply them anywhere
- **Safety**: Explicit recursion patterns reduce bugs from manual recursion
- **Optimization**: Fusion laws enable automatic optimization

**Performance Considerations**

[Inference] While recursion schemes provide abstraction, they may introduce overhead from intermediate structures and higher-order functions. Modern compilers with aggressive inlining can often eliminate this cost, but for performance-critical code, profiling is essential to verify optimization effectiveness.

---

