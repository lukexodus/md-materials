## F-Algebras


F-algebras provide the categorical foundation for understanding recursive data types and their operations. They formalize the relationship between functors and the structures they generate, enabling abstract reasoning about recursion.

**Definition**

An F-algebra for a functor `F` consists of:

- A carrier type `a`
- An evaluation function `F a -> a`

The pair `(a, F a -> a)` is the algebra. The functor `F` describes the signature of the data structure, and the evaluation function defines how to collapse one level of structure.

**Initial Algebras**

The fixed point `Fix F` forms an initial algebra with the evaluation function `unFix :: F (Fix F) -> Fix F`. This algebra is initial because there exists a unique homomorphism (catamorphism) from it to any other F-algebra.

```haskell
newtype Fix f = Fix { unFix :: f (Fix f) }

-- The initial algebra: (Fix F, unFix)
```

**Example: Expression Trees**

```haskell
data ExprF r
  = Const Int
  | Add r r
  | Mul r r
  deriving Functor

type Expr = Fix ExprF

-- Evaluation algebra
evalAlg :: ExprF Int -> Int
evalAlg (Const n) = n
evalAlg (Add x y) = x + y
evalAlg (Mul x y) = x * y

eval :: Expr -> Int
eval = cata evalAlg
```

The algebra `evalAlg` specifies the semantics of each operation. The catamorphism automatically handles traversal.

**Algebra Homomorphisms**

An algebra homomorphism from `(a, φ)` to `(b, ψ)` is a function `h :: a -> b` such that:

```
h . φ = ψ . fmap h
```

This preserves the algebraic structure—processing then mapping is equivalent to mapping then processing.

**F-Coalgebras**

Dually, an F-coalgebra consists of:

- A carrier type `a`
- A structure function `a -> F a`

The pair `(a, a -> F a)` represents a way to produce structure from state. Terminal coalgebras correspond to potentially infinite structures.

**Example: Streams**

```haskell
data StreamF a r = StreamF a r
  deriving Functor

type Stream a = Fix (StreamF a)

-- Coalgebra for generating naturals
natsCoalg :: Int -> StreamF Int Int
natsCoalg n = StreamF n (n + 1)

nats :: Stream Int
nats = ana natsCoalg 0
```

**Lambek's Lemma**

[Inference] For an initial algebra `(μF, in)` where `in :: F (μF) -> μF`, Lambek's lemma states that `in` is an isomorphism. Its inverse `out :: μF -> F (μF)` exists, demonstrating that the fixed point is isomorphic to one layer of its structure.

This justifies pattern matching on recursive types—unwrapping one layer is always possible and reversible.

**Mendler-Style Algebras**

Mendler-style algebras abstract over the recursive call, making them work without explicit fixed-point types:

```haskell
type MendlerAlgebra f a = forall r. (r -> a) -> f r -> a
```

This style enables working with negative occurrences of the type variable and provides more flexibility in certain contexts.

