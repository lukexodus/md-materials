## Filter Function


Filter selects elements from a collection based on a predicate function, producing a new collection containing only elements that satisfy the condition.

### Core Concept

Filter takes a predicate (boolean-returning function) and a collection. It evaluates the predicate for each element, keeping those that return true and discarding those that return false.

**Signature (generic):**

```
filter :: (a -> Bool) -> [a] -> [a]
```

### Behavior Characteristics

- **Length variation**: Output may be shorter than input (0 to n elements)
- **Order preservation**: Relative order of kept elements is maintained
- **Type preservation**: Input and output have same element type
- **No modification**: Elements are either kept or removed, never transformed

### Common Use Cases

- Removing invalid or unwanted data
- Selecting elements meeting criteria
- Partitioning data sets
- Implementing search/query logic

**Example:**

```haskell
-- Keep even numbers
filter even [1, 2, 3, 4, 5, 6]
-- [2, 4, 6]

-- Keep positive values
filter (> 0) [-2, -1, 0, 1, 2]
-- [1, 2]

-- Keep long strings
filter (\s -> length s > 3) ["hi", "hello", "bye", "world"]
-- ["hello", "world"]
```

### Combining Filters

Multiple filters compose through conjunction:

```haskell
filter p . filter q = filter (\x -> p x && q x)
```

**Example:**

```haskell
-- Multiple conditions
filter even (filter (> 10) [5, 12, 8, 15, 20])
-- Equivalent to
filter (\x -> x > 10 && even x) [5, 12, 8, 15, 20]
-- [12, 20]
```

### Partition Variant

Partition simultaneously filters into two collections (matching and non-matching):

```haskell
partition :: (a -> Bool) -> [a] -> ([a], [a])
```

**Example:**

```haskell
partition even [1, 2, 3, 4, 5]
-- ([2, 4], [1, 3, 5])
```

### Implementation Patterns

**Recursive implementation:**

```haskell
filter :: (a -> Bool) -> [a] -> [a]
filter p [] = []
filter p (x:xs)
  | p x       = x : filter p xs
  | otherwise = filter p xs
```

**Using foldr:**

```haskell
filter p = foldr (\x acc -> if p x then x:acc else acc) []
```

### Relationship with Map

Filter and map are complementary:

- Map: same length, changes values
- Filter: variable length, keeps values unchanged

Combined usage pattern:

```haskell
-- Transform then select
filter isValid . map transform

-- Select then transform
map transform . filter isValid
```

Order matters for performance—filter first to reduce work.

### Performance Considerations

- Time complexity: O(n) for evaluation
- Space complexity: O(k) where k ≤ n (kept elements)
- Predicate evaluation cost matters
- Short-circuit evaluation in predicates can improve performance

**Key Points:**

- Filter is selection without transformation
- Output length varies based on predicate
- Composable with other filters via conjunction
- Often combined with map for pipelines

---

