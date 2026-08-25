## Delayed Computation


Delayed computation is the strategic deferral of evaluation to optimize performance, enable modularity, or handle potentially infinite processes.

### Core Concept

Rather than computing values immediately, delayed computation represents computations as data structures that can be evaluated later, selectively, or incrementally.

### Mechanisms for Delay

**Explicit delay primitives:**

```haskell
-- Delay (create suspension)
delay :: (() -> a) -> Delayed a

-- Force (evaluate suspension)
force :: Delayed a -> a
```

**Example:**

```haskell
-- Create delayed computation
let delayed = delay (\() -> expensiveComputation())

-- Pass around without evaluating
let stored = saveToCache delayed

-- Evaluate when needed
let result = force delayed
```

### Streams and Lazy Lists

Streams represent potentially infinite sequences with delayed computation:

**Example:**

```haskell
-- Infinite stream of natural numbers
naturals :: [Int]
naturals = [0..]

-- Delayed: only head available initially
-- Tail is delayed computation

-- Take computes only what's needed
take 5 naturals  -- [0, 1, 2, 3, 4]
-- Only 5 elements computed
```

**Stream structure:**

```haskell
-- Conceptual representation
data Stream a = Cons a (Delayed (Stream a))

-- Example: naturals from n
nats n = Cons n (delay (\() -> nats (n + 1)))
```

### Producer-Consumer Separation

Delayed computation separates data production from consumption:

**Example:**

```haskell
-- Producer: generates candidates
candidates = [1..1000000]

-- Transformer: filters
primes = filter isPrime candidates

-- Consumer: takes what's needed
firstTenPrimes = take 10 primes

-- Only ~30 elements generated and tested
-- Not entire million
```

This modularity allows composing transformations without intermediate materialization.

### Memoization Tables

Delayed computation with caching enables efficient dynamic programming:

**Example:**

```haskell
-- Memoized Fibonacci
fib :: Int -> Integer
fib = (map fib' [0..] !!)
  where
    fib' 0 = 0
    fib' 1 = 1
    fib' n = fib (n-1) + fib (n-2)

-- List indices act as memoization table
-- Each fib(n) computed once, cached in list
```

### Control Structures from Delayed Computation

**Custom conditionals:**

```haskell
-- If-then-else with delayed branches
if' :: Bool -> a -> a -> a
if' True  x _ = x
if' False _ y = y

-- In lazy language, branches already delayed
-- In eager language, need explicit delay:
if' :: Bool -> (() -> a) -> (() -> a) -> a
if' True  x _ = x()
if' False _ y = y()
```

**Short-circuit logical operators:**

```haskell
-- And with delayed second argument
(&&) :: Bool -> Bool -> Bool
True  && y = y     -- y evaluated only if first is True
False && _ = False -- second argument never evaluated
```

### Tying the Knot

Circular definitions through delayed evaluation:

**Example:**

```haskell
-- Circular list (cycle)
ones = 1 : ones
-- ones points to itself
-- Infinite list of 1s without explicit recursion

-- More complex example
let (a, b) = (b + 1, a + 2)
-- Initially both delayed
-- Evaluation proceeds carefully to resolve
```

### Demand-Driven Computation

Computation proceeds based on demand:

**Example:**

```haskell
-- Generate all Pythagorean triples
triples = [(a, b, c) | a <- [1..],
                       b <- [a..],
                       c <- [b..],
                       a^2 + b^2 == c^2]

-- Infinite search space
-- But take 5 triples computes only until 5 found
take 5 triples
-- [(3,4,5), (5,12,13), (6,8,10), (7,24,25), (8,15,17)]
```

Only explores enough of the infinite space to satisfy demand.

### Codata and Observations

Delayed computation models codata—data defined by observations rather than construction:

**Example:**

```haskell
-- Stream as codata
head' :: Stream a -> a
tail' :: Stream a -> Stream a

-- Defined by how it's observed, not how it's built
-- Conceptually infinite, computed incrementally
```

### Staged Computation

Delayed computation enables multi-stage execution:

**Example:**

```haskell
-- Stage 1: Build computation plan
let pipeline = map (*2) . filter even . map (+1)

-- Stage 2: Apply to data (delayed)
let delayed = pipeline [1..1000000]

-- Stage 3: Force specific results
take 10 delayed
-- Only computes what take demands
```

### Resource Management

Delayed computation can defer resource acquisition:

**Example:**

```haskell
-- Lazy file reading
readFileLazy :: FilePath -> IO String

-- File not read until string is forced
contents <- readFileLazy "huge.txt"

-- Process incrementally
let lineCount = length (lines contents)
-- File read line-by-line as length consumes
```

**Caution:** Resource lifetimes become unpredictable. Files may remain open longer than expected.

### Parallel and Concurrent Strategies

Delayed computation enables speculative execution:

**Example:**

```haskell
-- [Inference] Conceptual parallel evaluation
par :: a -> b -> b
-- par x y evaluates x in parallel while returning y

-- Spark delayed computations
let x = delay expensiveA
let y = delay expensiveB

-- Request both in parallel
x `par` (y `par` (force x + force y))
```

### Optimization Through Fusion

Delayed computation enables optimization without materialization:

**Example:**

```haskell
-- Multiple transformations
map f . map g

-- In eager evaluation: two passes, intermediate list

-- In delayed evaluation: fused to single pass
-- No intermediate list allocated
map (f . g)
```

### Incremental Computation

Changes propagate only through affected delayed computations:

**Example:**

```haskell
-- [Inference] Conceptual incremental computation
-- Computation graph with delayed nodes
let a = input()
let b = transform(a)
let c = transform(b)

-- Input changes
updateInput(newValue)

-- Only recompute affected parts
-- If b uses caching and a didn't change, skip
-- Only recompute c if b changed
```

### Trade-offs

**Advantages:**

- Avoids unnecessary computation
- Enables infinite structures
- Better modularity and composition
- Can optimize across boundaries

**Disadvantages:**

- Unpredictable resource usage timing
- Potential space leaks
- Harder debugging (when did this compute?)
- Performance characteristics less obvious

**Key Points:**

- Delayed computation defers evaluation until results are needed
- Enables infinite structures and modular programming
- Separates production from consumption
- Can cause unpredictable resource management
- Supports optimization through fusion and demand-driven execution

---

