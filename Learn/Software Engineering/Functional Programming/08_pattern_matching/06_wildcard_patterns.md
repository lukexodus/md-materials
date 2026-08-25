## Wildcard Patterns


Wildcard patterns match any value without binding it to a name, serving as a catch-all mechanism when the specific value is irrelevant to the computation. They represent intentional disregard for certain data.

**Key Points:**

- Represented by underscore `_` in most functional languages
- Matches anything without creating a binding
- Reduces noise by omitting unused values
- Essential for exhaustiveness checking while ignoring cases
- Can appear in any position where a pattern is expected

Wildcards shine when only partial data structure information matters:

**Example:**

```haskell
-- Haskell: only care about list structure, not contents
isEmpty :: [a] -> Bool
isEmpty [] = True
isEmpty (_:_) = False  -- wildcard for head, tail irrelevant

-- Pattern match on tuple, ignore second element
getFirst :: (a, b) -> a
getFirst (x, _) = x
```

**Example:**

```python
# Python: match specific structures, ignore details
match response:
    case {"status": 200, "data": data}:
        process(data)
    case {"status": 404, "error": _}:  # error message doesn't matter
        handle_not_found()
    case _:  # catch-all wildcard for entire pattern
        handle_unknown()
```

Multiple wildcards in complex patterns:

**Example:**

```scala
// Scala: extract middle element from 3-tuple
def getMiddle[A, B, C](triple: (A, B, C)): B = triple match {
    case (_, middle, _) => middle
}

// Ignore multiple constructor arguments
case class Request(method: String, path: String, headers: Map[String, String], body: String)

req match {
    case Request("GET", path, _, _) =>  // only method and path matter
        handleGet(path)
}
```

Wildcards in function parameter patterns directly in definitions:

**Example:**

```haskell
-- Haskell: function ignores its argument entirely
const :: a -> b -> a
const x _ = x

-- Ignore parts of algebraic data types
data Tree a = Leaf a | Node a (Tree a) (Tree a)

depth :: Tree a -> Int
depth (Leaf _) = 1  -- leaf value irrelevant
depth (Node _ left right) = 1 + max (depth left) (depth right)
```

**[Inference]** Wildcards signal to readers (and the compiler) that omitted values are deliberately unused, improving code clarity and enabling dead code elimination optimizations.

