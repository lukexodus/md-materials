## Map Function


A map function transforms each element of a collection by applying a given function, producing a new collection of the same length. It preserves structure while changing values.

### Core Concept

Map takes two arguments: a function `f` and a collection. It applies `f` to each element independently, returning a new collection with transformed values. The original collection remains unchanged (immutability).

**Signature (generic):**

```
map :: (a -> b) -> [a] -> [b]
```

### Behavior Characteristics

- **Length preservation**: Output collection has same length as input
- **Order preservation**: Element positions remain consistent
- **Independence**: Each transformation is independent of others
- **Laziness**: Many implementations support lazy evaluation

### Common Use Cases

- Data transformation (converting types, scaling values)
- Applying computations uniformly
- Extracting properties from objects
- Normalizing data formats

**Example:**

```haskell
-- Double all numbers
map (*2) [1, 2, 3, 4]
-- [2, 4, 6, 8]

-- Extract lengths
map length ["hello", "world", "fp"]
-- [5, 5, 2]

-- Convert to uppercase
map toUpper ['a', 'b', 'c']
-- ['A', 'B', 'C']
```

### Composition with Map

Maps compose naturally, allowing chained transformations:

```haskell
map f . map g = map (f . g)
```

This fusion property enables optimization—multiple maps can be combined into a single pass.

**Example:**

```haskell
-- Instead of two passes
map (*2) (map (+1) [1, 2, 3])

-- Single pass
map ((*2) . (+1)) [1, 2, 3]
-- [4, 6, 8]
```

### Functor Laws

Map must satisfy functor laws:

1. **Identity**: `map id = id`
2. **Composition**: `map (f . g) = map f . map g`

These laws ensure predictable, composable behavior.

### Implementation Patterns

**Recursive implementation:**

```haskell
map :: (a -> b) -> [a] -> [b]
map f [] = []
map f (x:xs) = f x : map f xs
```

**Tail-recursive with accumulator:**

```haskell
map' :: (a -> b) -> [a] -> [b]
map' f xs = go xs []
  where
    go [] acc = reverse acc
    go (x:xs) acc = go xs (f x : acc)
```

### Performance Considerations

- Time complexity: O(n)
- Space complexity: O(n) for new collection
- Lazy evaluation can defer computation until needed
- Fusion optimizations can eliminate intermediate structures

**Key Points:**

- Map is structure-preserving transformation
- Each element transforms independently
- Composable and optimizable through fusion
- Foundation for functor abstraction

---

