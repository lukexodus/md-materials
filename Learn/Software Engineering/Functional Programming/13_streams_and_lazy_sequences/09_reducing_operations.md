## Reducing Operations


Reducing operations collapse a sequence into a single value by iteratively combining elements according to a binary operation. The reduction proceeds through the structure, accumulating results via a combining function and an initial value.

**Basic structure:**

```haskell
fold :: (b -> a -> b) -> b -> [a] -> b
fold f acc [] = acc
fold f acc (x:xs) = fold f (f acc x) xs
```

The signature reveals:

- `f`: combining function `(accumulator -> element -> accumulator)`
- `acc`: initial accumulator value
- `[a]`: input sequence
- Result type `b` may differ from element type `a`

**Left vs Right associativity:**

**Left fold (foldl)**: Processes left-to-right, accumulator on left of operation

```haskell
foldl (-) 0 [1,2,3] = ((0 - 1) - 2) - 3 = -6
```

**Right fold (foldr)**: Processes right-to-left, accumulator on right

```haskash
foldr (-) 0 [1,2,3] = 1 - (2 - (3 - 0)) = 2
```

Associativity matters when:

- Operation is non-associative (like subtraction, division)
- Working with infinite lists (foldr can short-circuit, foldl cannot)
- Building data structures (foldr naturally constructs lists)

**Strict vs Lazy evaluation:**

**foldl** builds up thunks, potentially causing stack overflow:

```haskell
foldl (+) 0 [1..1000000]  -- accumulates unevaluated additions
```

**foldl'** (strict left fold) evaluates immediately:

```haskell
foldl' (+) 0 [1..1000000]  -- evaluates at each step
```

**foldr** can work with infinite lists when the combining function is lazy in its second argument:

```haskell
foldr (&&) True (repeat False)  -- terminates immediately
```

**Common patterns:**

Map as fold:

```haskell
map f xs = foldr (\x acc -> f x : acc) [] xs
```

Filter as fold:

```haskell
filter p xs = foldr (\x acc -> if p x then x : acc else acc) [] xs
```

Reverse as fold:

```haskell
reverse xs = foldl (\acc x -> x : acc) [] xs
```

**Monoid pattern:**

When the combining operation forms a monoid (associative with identity), reduction becomes particularly elegant:

```haskell
fold mappend mempty xs
```

This works for:

- Numbers under addition (identity: 0)
- Lists under concatenation (identity: [])
- Booleans under conjunction/disjunction
- Any type with an associative operation and neutral element

**Parallel reduction:**

For associative operations, reduction can parallelize by dividing the sequence and combining partial results:

```scala
def parallelReduce[A](xs: Seq[A], z: A)(f: (A, A) => A): A = {
  if (xs.length <= threshold) xs.foldLeft(z)(f)
  else {
    val (left, right) = xs.splitAt(xs.length / 2)
    val (leftResult, rightResult) = parallel(
      parallelReduce(left, z)(f),
      parallelReduce(right, z)(f)
    )
    f(leftResult, rightResult)
  }
}
```

**Scan operations:**

Scan produces intermediate accumulations:

```haskell
scanl :: (b -> a -> b) -> b -> [a] -> [b]
scanl f z xs = z : (case xs of
                      [] -> []
                      (x:xs') -> scanl f (f z x) xs')

-- scanl (+) 0 [1,2,3,4] = [0,1,3,6,10]
```

This enables:

- Running totals
- Prefix sum computations
- Cumulative statistics
- State propagation through sequences

**Unfold (dual of fold):**

While fold consumes a structure, unfold generates one:

```haskell
unfold :: (b -> Maybe (a, b)) -> b -> [a]
unfold f seed = case f seed of
                  Nothing -> []
                  Just (a, seed') -> a : unfold f seed'
```

The relationship between fold and unfold forms a fundamental duality in functional programming—fold deconstructs, unfold constructs. Together they enable transformation patterns where reduction and generation compose seamlessly.

---

