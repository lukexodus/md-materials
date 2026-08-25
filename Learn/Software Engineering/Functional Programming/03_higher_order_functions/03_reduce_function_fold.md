## Reduce Function (Fold)


Reduce (also called fold) combines all elements of a collection into a single value by iteratively applying a binary function with an accumulator.

### Core Concept

Reduce processes a collection sequentially, maintaining an accumulator that combines each element with the accumulated result. It collapses structure into a single value.

**Signature (left fold):**

```
foldl :: (b -> a -> b) -> b -> [a] -> b
```

**Signature (right fold):**

```
foldr :: (a -> b -> b) -> b -> [a] -> b
```

### Left Fold vs Right Fold

**Left fold (foldl):** Processes left-to-right, accumulator as first argument

```haskell
foldl f z [x1, x2, x3] = f (f (f z x1) x2) x3
```

**Right fold (foldr):** Processes right-to-left, accumulator as second argument

```haskell
foldr f z [x1, x2, x3] = f x1 (f x2 (f x3 z))
```

### Direction Implications

**Left fold:**

- Tail-recursive (can be optimized)
- Strict evaluation (processes entire list)
- Natural for accumulation operations

**Right fold:**

- Can work with infinite lists (lazy)
- Natural for constructing new structures
- Required for operations that need early termination

**Example:**

```haskell
-- Left fold: subtraction
foldl (-) 0 [1, 2, 3]
-- ((0 - 1) - 2) - 3 = -6

-- Right fold: subtraction
foldr (-) 0 [1, 2, 3]
-- 1 - (2 - (3 - 0)) = 2
```

### Common Use Cases

- Summing or aggregating values
- Building data structures
- Implementing other higher-order functions
- Complex accumulations (counting, grouping)

**Example:**

```haskell
-- Sum
foldl (+) 0 [1, 2, 3, 4]
-- 10

-- Product
foldl (*) 1 [2, 3, 4]
-- 24

-- Concatenation
foldr (++) [] ["hello", " ", "world"]
-- "hello world"

-- Length (counting)
foldl (\acc _ -> acc + 1) 0 [1, 2, 3, 4]
-- 4

-- Reverse
foldl (\acc x -> x : acc) [] [1, 2, 3]
-- [3, 2, 1]
```

### Implementing Other Functions

Many list operations can be expressed as folds:

```haskell
-- Map using foldr
map f = foldr (\x acc -> f x : acc) []

-- Filter using foldr
filter p = foldr (\x acc -> if p x then x:acc else acc) []

-- Any
any p = foldr (\x acc -> p x || acc) False

-- All
all p = foldr (\x acc -> p x && acc) True
```

### Strict Left Fold

Standard left fold can cause stack overflow due to thunk accumulation. Strict variant evaluates accumulator immediately:

```haskell
foldl' :: (b -> a -> b) -> b -> [a] -> b
```

**When to use foldl':**

- Accumulating strict values (numbers, booleans)
- Processing large lists
- When entire list must be consumed

**When to use foldr:**

- Working with infinite lists
- Building lazy structures
- Early termination scenarios

### Fold Fusion

Multiple folds over same structure can sometimes be fused:

```haskell
-- Instead of two passes
(foldl f z xs, foldl g w xs)

-- Could potentially be optimized to single pass
-- [Inference] (implementation-dependent optimization)
```

### Implementation Patterns

**Left fold (recursive):**

```haskell
foldl :: (b -> a -> b) -> b -> [a] -> b
foldl f acc [] = acc
foldl f acc (x:xs) = foldl f (f acc x) xs
```

**Right fold (recursive):**

```haskell
foldr :: (a -> b -> b) -> b -> [a] -> b
foldr f acc [] = acc
foldr f acc (x:xs) = f x (foldr f acc xs)
```

### Monoid Pattern

When combining function is associative and has identity element, fold operates over a monoid:

```haskell
-- Associative: f (f a b) c = f a (f b c)
-- Identity: f z a = a = f a z

-- Examples: (+, 0), (*, 1), (++, []), (&&, True)
```

### Performance Considerations

- Time complexity: O(n)
- Space complexity:
    - foldl: O(n) thunks without strictness
    - foldl': O(1) stack space
    - foldr: O(1) for lazy operations, O(n) if fully evaluated
- Choice of fold direction affects performance and correctness

**Key Points:**

- Reduce collapses collections to single values
- Left and right folds have different evaluation orders
- Many operations can be expressed as folds
- Strictness matters for performance and stack safety

---

