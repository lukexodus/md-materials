## Sequence Patterns


Sequence patterns match ordered collections by their structure and contents, enabling decomposition of lists, arrays, tuples, and other sequential data types. They support both fixed-length and variable-length matching.

**Key Points:**

- Match sequences by element count, position, and values
- Support head/tail decomposition for recursive processing
- Enable prefix, suffix, and middle extraction patterns
- Can combine fixed elements with variable-length captures
- Form the basis of list processing in functional languages

Basic fixed-length sequence matching:

**Example:**

```haskell
-- Haskell: match exact list structures
processCoordinates :: [Int] -> String
processCoordinates [x, y] = "2D point: " ++ show (x, y)
processCoordinates [x, y, z] = "3D point: " ++ show (x, y, z)
processCoordinates _ = "Invalid coordinates"

-- Pattern match on tuple (fixed sequence)
swapPair :: (a, a) -> (a, a)
swapPair (x, y) = (y, x)
```

Head/tail (cons) patterns for recursive list processing:

**Example:**

```haskell
-- Haskell: classic list recursion patterns
sum :: [Int] -> Int
sum [] = 0                    -- empty list pattern
sum (x:xs) = x + sum xs       -- head x, tail xs

-- Multiple element prefix
take2 :: [a] -> Maybe (a, a)
take2 (x:y:_) = Just (x, y)   -- at least 2 elements
take2 _ = Nothing

-- F#
let rec length list =
    match list with
    | [] -> 0                 // empty
    | _::tail -> 1 + length tail  // ignore head, recurse on tail
```

**Example:**

```python
# Python 3.10+ sequence patterns with variable-length matching
match numbers:
    case []:
        print("Empty")
    case [x]:
        print(f"Single: {x}")
    case [x, y]:
        print(f"Pair: {x}, {y}")
    case [first, *middle, last]:  # variable-length middle
        print(f"First: {first}, Middle: {middle}, Last: {last}")
```

Nested sequence patterns for multi-dimensional structures:

**Example:**

```scala
// Scala: pattern match on nested sequences
matrix match {
    case List(List(a, b), List(c, d)) =>  // 2x2 matrix
        s"2x2 matrix with corners: $a, $b, $c, $d"
    case List(row1, row2, row3) =>  // 3 rows
        "3-row matrix"
    case _ => 
        "Other shape"
}
```

Sequence patterns with guards and additional constraints:

**Example:**

```haskell
-- Haskell: combining sequence patterns with conditions
classify :: [Int] -> String
classify [] = "empty"
classify [x] | x > 0 = "single positive"
             | otherwise = "single non-positive"
classify (x:y:rest) | x > y = "descending start"
                     | otherwise = "non-descending start"

-- OCaml: match specific sequence values
match coords with
| [0; 0] -> "origin"
| [x; 0] -> "x-axis"
| [0; y] -> "y-axis"
| [x; y] -> "plane point"
| _ -> "invalid"
```

**[Inference]** Sequence patterns enable declarative expression of list algorithms, replacing explicit index manipulation with structural decomposition that mirrors mathematical definitions.

