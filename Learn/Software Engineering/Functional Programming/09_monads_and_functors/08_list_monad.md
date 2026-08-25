## List Monad


The List monad represents non-deterministic computations where each step may produce multiple results. Bind explores all possible combinations, making it powerful for generating permutations, combinations, and search spaces.

**Key Points:**

- Models computations with multiple possible outcomes
- Bind produces the Cartesian product of results
- Empty list represents failure/no solutions
- Automatic backtracking through all possibilities

The monadic bind for lists applies the function to each element and concatenates all resulting lists. This creates a branching computation tree where each branch is explored. When used with multiple binds, this generates all combinations of results from each step.

**Example:**

```haskell
-- List comprehension is syntactic sugar for list monad
pairs :: [Int] -> [Int] -> [(Int, Int)]
pairs xs ys = do
  x <- xs
  y <- ys
  return (x, y)

-- Equivalent to:
-- pairs xs ys = xs >>= \x -> ys >>= \y -> return (x, y)

pythagoras :: Int -> [(Int, Int, Int)]
pythagoras n = do
  a <- [1..n]
  b <- [a..n]
  c <- [b..n]
  guard (a*a + b*b == c*c)
  return (a, b, c)
```

**Output:**

```haskell
pairs [1,2] [3,4]  
-- [(1,3), (1,4), (2,3), (2,4)]

pythagoras 15
-- [(3,4,5), (5,12,13), (6,8,10), (9,12,15)]
```

The `guard` function demonstrates how filtering integrates into monadic chains. It takes a boolean and returns either a singleton list (on true) or empty list (on false). Empty lists cause that branch to be pruned from the result.

**Key Points:**

- Each `<-` introduces a new level of nesting/iteration
- `guard` prunes branches that don't satisfy conditions
- Equivalent to nested loops but compositional
- Performance considerations: generates intermediate lists

List comprehensions in various languages desugar to list monad operations. Python's list comprehensions, Haskell's do-notation, and LINQ in C# all express the same pattern: binding over collections with filtering.

**Example:**

```python
# Python list comprehension
[(x, y, z) for x in range(1, n+1)
           for y in range(x, n+1)
           for z in range(y, n+1)
           if x*x + y*y == z*z]

# This is list monad in disguise
```

The list monad also naturally expresses parsing with ambiguity, where multiple parses are valid:

**Example:**

```haskell
-- Parser that returns all possible parses
type Parser a = String -> [(a, String)]

item :: Parser Char
item [] = []
item (c:cs) = [(c, cs)]

-- Bind threads remaining input through parsers
(>>=) :: Parser a -> (a -> Parser b) -> Parser b
p >>= f = \input -> concat [f a rest | (a, rest) <- p input]
```

This parser monad explores all possible parse trees, automatically handling backtracking and ambiguity. Each element in the result list represents one valid parse with its remaining input.

**Conclusion:** Monads provide a unified interface for sequential computation with effects. Maybe/Option handles partiality, Result/Either handles errors with context, and List handles non-determinism. The monadic operations abstract away the effect-specific plumbing, allowing focus on business logic while the monad handles the computational context. Understanding these three monads provides foundation for more advanced monads like State, Reader, Writer, and their transformers.

