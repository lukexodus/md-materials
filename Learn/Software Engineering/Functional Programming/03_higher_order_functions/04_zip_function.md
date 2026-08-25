## Zip Function


Zip combines multiple collections element-wise, producing a collection of tuples (or applying a function). It pairs corresponding elements from each input collection.

### Core Concept

Zip takes two or more collections and combines elements at corresponding positions. The result length equals the shortest input collection.

**Signature (binary zip):**

```
zip :: [a] -> [b] -> [(a, b)]
```

**Signature (zip with function):**

```
zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
```

### Behavior Characteristics

- **Length truncation**: Output length = min(input lengths)
- **Position correspondence**: Elements at index i are paired together
- **Multiple collection support**: Can zip 2, 3, or more collections
- **Type flexibility**: Creates tuples or applies combining function

### Basic Zip Operations

**Example:**

```haskell
-- Basic zip (creates pairs)
zip [1, 2, 3] ['a', 'b', 'c']
-- [(1, 'a'), (2, 'b'), (3, 'c')]

-- Different lengths (truncates)
zip [1, 2, 3, 4] ['a', 'b']
-- [(1, 'a'), (2, 'b')]

-- Empty list
zip [] [1, 2, 3]
-- []

-- Three lists
zip3 [1, 2] ['a', 'b'] [True, False]
-- [(1, 'a', True), (2, 'b', False)]
```

### ZipWith Variants

ZipWith applies a function instead of creating tuples:

**Example:**

```haskell
-- Add corresponding elements
zipWith (+) [1, 2, 3] [10, 20, 30]
-- [11, 22, 33]

-- Multiply pairs
zipWith (*) [2, 3, 4] [5, 6, 7]
-- [10, 18, 28]

-- Custom function
zipWith (\x y -> x ++ ":" ++ y) ["a", "b"] ["1", "2"]
-- ["a:1", "b:2"]

-- Max of pairs
zipWith max [1, 5, 3] [4, 2, 6]
-- [4, 5, 6]
```

### Common Use Cases

- Pairing related data from separate sources
- Element-wise operations on parallel collections
- Creating indexed collections
- Implementing parallel iteration patterns

**Example:**

```haskell
-- Add indices
zip [0..] ["apple", "banana", "cherry"]
-- [(0, "apple"), (1, "banana"), (2, "cherry")]

-- Dot product (vector multiplication)
dotProduct xs ys = sum (zipWith (*) xs ys)
dotProduct [1, 2, 3] [4, 5, 6]
-- 1*4 + 2*5 + 3*6 = 32

-- Pairwise comparison
zipWith (==) [1, 2, 3] [1, 5, 3]
-- [True, False, True]
```

### Unzip Operation

Unzip reverses zip, separating tuples back into individual collections:

```haskell
unzip :: [(a, b)] -> ([a], [b])
```

**Example:**

```haskell
unzip [(1, 'a'), (2, 'b'), (3, 'c')]
-- ([1, 2, 3], ['a', 'b', 'c'])

-- Round trip
unzip (zip [1, 2, 3] ['a', 'b', 'c'])
-- ([1, 2, 3], ['a', 'b', 'c'])
```

### Relationship with Map

ZipWith generalizes map:

- `map f xs` = `zipWith (\x _ -> f x) xs xs`
- ZipWith can apply binary functions across collections

**Example:**

```haskell
-- Map as zipWith
zipWith const [1, 2, 3] (repeat ())
-- [1, 2, 3]
```

### Infinite Lists

Zip works with infinite lists, producing output limited by finite list:

**Example:**

```haskell
-- Natural numbers with letters
zip [1..] ['a', 'b', 'c']
-- [(1, 'a'), (2, 'b'), (3, 'c')]

-- Enumerate function
enumerate = zip [0..]
enumerate ["apple", "banana"]
-- [(0, "apple"), (1, "banana")]
```

### Implementation Patterns

**Recursive zip:**

```haskell
zip :: [a] -> [b] -> [(a, b)]
zip [] _ = []
zip _ [] = []
zip (x:xs) (y:ys) = (x, y) : zip xs ys
```

**Recursive zipWith:**

```haskell
zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith f [] _ = []
zipWith f _ [] = []
zipWith f (x:xs) (y:ys) = f x y : zipWith f xs ys
```

### N-ary Zip Variants

Many languages provide zip for arbitrary numbers of collections:

```haskell
zip3 :: [a] -> [b] -> [c] -> [(a, b, c)]
zip4 :: [a] -> [b] -> [c] -> [d] -> [(a, b, c, d)]

zipWith3 :: (a -> b -> c -> d) -> [a] -> [b] -> [c] -> [d]
zipWith4 :: (a -> b -> c -> d -> e) -> [a] -> [b] -> [c] -> [d] -> [e]
```

### Alternative: ZipAll

Some implementations provide zipAll that doesn't truncate but uses default values:

```haskell
-- [Unverified] - not standard, implementation varies by language
zipAll :: a -> b -> [a] -> [b] -> [(a, b)]
```

**Example:**

```haskell
-- [Unverified] - hypothetical behavior
zipAll 0 '_' [1, 2] ['a', 'b', 'c', 'd']
-- [(1, 'a'), (2, 'b'), (0, 'c'), (0, 'd')]
```

### Performance Considerations

- Time complexity: O(min(n, m)) for two lists of lengths n, m
- Space complexity: O(min(n, m))
- Lazy evaluation: only computes needed elements
- Truncation happens at runtime—no compile-time length checking

**Key Points:**

- Zip combines collections element-wise
- Truncates to shortest input length
- ZipWith applies function instead of creating tuples
- Works naturally with infinite lists
- Unzip provides inverse operation

