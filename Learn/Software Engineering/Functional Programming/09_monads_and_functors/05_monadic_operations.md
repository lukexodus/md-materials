## Monadic Operations


Monadic operations form the core computational patterns that allow us to chain operations while maintaining context. The fundamental operations are `bind` (also called `flatMap` or `>>=`), `return` (or `pure`), and their derived combinators.

**Key Points:**

- `bind` sequences computations while flattening nested structures
- `return`/`pure` lifts values into monadic context
- Operations must satisfy three laws: left identity, right identity, and associativity
- Monadic composition enables railway-oriented programming where effects are threaded implicitly

The bind operation takes a monadic value and a function that returns a monadic value, then flattens the result. This is fundamentally different from `map`, which would produce nested monads. The type signature reveals the flattening behavior: `M<A> -> (A -> M<B>) -> M<B>`.

**Example:**

```haskell
-- bind in action
halfIfEven :: Int -> Maybe Int
halfIfEven x = if even x then Just (x `div` 2) else Nothing

result1 = Just 8 >>= halfIfEven >>= halfIfEven  -- Just 2
result2 = Just 7 >>= halfIfEven                  -- Nothing
result3 = Nothing >>= halfIfEven                 -- Nothing
```

**Output:**

```
result1: Just 2   (8 -> 4 -> 2, all successful)
result2: Nothing  (7 is odd, chain stops)
result3: Nothing  (starts with Nothing, propagates)
```

The three monad laws ensure predictable composition:

1. **Left Identity**: `return a >>= f` ≡ `f a`
2. **Right Identity**: `m >>= return` ≡ `m`
3. **Associativity**: `(m >>= f) >>= g` ≡ `m >>= (\x -> f x >>= g)`

These laws guarantee that monadic operations behave consistently regardless of how they're grouped or combined. The associativity law is particularly important as it ensures the order of binding doesn't affect the final computation structure.

Common derived operations include `join` (flattens `M<M<A>>` to `M<A>`), `ap` (applies a function in monadic context), and `sequence` (transforms a list of monadic values into a monadic list).

**Key Points:**

- `join` is the dual of `return`: it removes one layer of monadic structure
- `bind` can be defined as `map` followed by `join`
- Kleisli composition (`>=>`) composes monadic functions directly
- Do-notation (Haskell) or for-comprehensions (Scala) provide syntactic sugar

