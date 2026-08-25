## Lazy vs Eager Evaluation


Lazy and eager evaluation are fundamental strategies for determining when expressions are computed, affecting performance, memory usage, and program semantics.

### Core Distinction

**Eager evaluation (strict evaluation):** Expressions are evaluated immediately when bound to variables, regardless of whether the result is needed.

**Lazy evaluation (non-strict evaluation):** Expressions are evaluated only when their results are actually required, deferring computation until necessary.

### Evaluation Timing

**Eager evaluation:**

```haskell
-- [Inference] Conceptual behavior in eager language
let x = expensiveComputation()  -- Computed immediately
let y = anotherValue()          -- Computed immediately
if condition then x else y      -- One result discarded after computation
```

**Lazy evaluation:**

```haskell
-- Conceptual behavior in lazy language
let x = expensiveComputation()  -- Not computed yet
let y = anotherValue()          -- Not computed yet
if condition then x else y      -- Only needed branch computed
```

### Call-by-Value vs Call-by-Name vs Call-by-Need

**Call-by-value (eager):**

- Arguments evaluated before function application
- Each expression evaluated exactly once
- Predictable performance characteristics

**Call-by-name (naive lazy):**

- Arguments passed unevaluated
- May evaluate same expression multiple times
- Can be inefficient with repeated use

**Call-by-need (lazy with memoization):**

- Arguments passed unevaluated
- Results cached after first evaluation
- Each expression evaluated at most once

**Example:**

```haskell
-- Function with repeated parameter use
square x = x * x

-- Call-by-value: (2 + 3) evaluated once, then 5 * 5
square (2 + 3)  -- 25

-- Call-by-name: (2 + 3) evaluated twice
-- (2 + 3) * (2 + 3)

-- Call-by-need: (2 + 3) evaluated once, cached, reused
-- First use computes 5, second use retrieves cached 5
```

### Infinite Data Structures

Lazy evaluation enables working with infinite structures:

**Example:**

```haskell
-- Infinite list of natural numbers
naturals = [0..]

-- Take first 5 (only these are computed)
take 5 naturals
-- [0, 1, 2, 3, 4]

-- Infinite list of ones
ones = 1 : ones

-- Fibonacci sequence
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
take 10 fibs
-- [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

In eager evaluation, defining `naturals = [0..]` would attempt to construct an infinite list immediately, never terminating.

### Short-Circuit Evaluation

Both strategies support logical short-circuiting, but lazy evaluation extends this principle:

**Example:**

```haskell
-- Logical AND short-circuit
False && expensiveCheck()  -- expensiveCheck never called

-- Lazy evaluation extends to custom functions
any :: (a -> Bool) -> [a] -> Bool
any p (x:xs) = p x || any p xs

-- Stops at first True
any (> 5) [1, 2, 6, 8, 10]  -- Checks 1, 2, 6, then stops
```

### Modularity Benefits

Lazy evaluation separates generation from consumption:

**Example:**

```haskell
-- Generate all candidates
candidates = [1..1000000]

-- Filter to primes
primes = filter isPrime candidates

-- Take only what's needed
take 10 primes

-- Only checks 1..29 (approximately), not entire million
```

Eager evaluation would compute all million candidates and filter all before taking 10.

### Memory Considerations

**Space leaks:** Lazy evaluation can accumulate unevaluated thunks, consuming memory:

**Example:**

```haskell
-- Problematic in lazy evaluation
sum = foldl (+) 0

-- Builds: (((0 + 1) + 2) + 3) ... as thunks
sum [1..1000000]  -- May overflow stack

-- Solution: strict fold
sum = foldl' (+) 0  -- Forces evaluation at each step
```

**Streaming advantages:** Lazy evaluation enables constant-space processing:

**Example:**

```haskell
-- Process large file
processFile = length . filter isValid . lines

-- Only one line in memory at a time (with proper laziness)
```

### Trade-offs

**Eager evaluation advantages:**

- Predictable performance
- Easier to reason about execution order
- No thunk overhead
- Better for strict accumulations

**Lazy evaluation advantages:**

- Enables infinite structures
- Automatic optimization (unused code not executed)
- Better modularity (separate generation/consumption)
- Natural short-circuiting

**Eager evaluation disadvantages:**

- Wastes computation on unused results
- Cannot express infinite structures naturally
- Forces sequential thinking

**Lazy evaluation disadvantages:**

- Space leaks from thunk accumulation
- Harder to predict performance
- Debugging complexity
- Overhead of thunk management

### Language Examples

**Lazy by default:**

- Haskell
- Miranda

**Eager by default:**

- ML, OCaml
- Scheme, Common Lisp
- JavaScript, Python, Java

**Mixed approaches:**

- Scala (eager but with lazy val)
- Clojure (eager but with lazy sequences)
- Python (eager but with generators)

**Example:**

```python
# Python: eager by default
x = [i**2 for i in range(1000000)]  # Computes all immediately

# Python: lazy with generator
x = (i**2 for i in range(1000000))  # Computes on demand
```

### Forcing Evaluation

Lazy languages provide mechanisms to force evaluation:

**Example:**

```haskell
-- Force evaluation with seq
x `seq` y  -- Evaluates x to WHNF, returns y

-- Force deep evaluation with deepseq
force x `seq` y  -- Fully evaluates x

-- Bang patterns (strict fields)
data Point = Point !Int !Int  -- Fields evaluated strictly
```

### Weak Head Normal Form (WHNF)

Lazy evaluation typically computes to WHNF, not full normal form:

**Example:**

```haskell
-- WHNF: outermost constructor evaluated
let x = (1 + 2, 3 + 4)
-- x is in WHNF: pair constructor visible
-- but 1 + 2 and 3 + 4 remain unevaluated

-- Forcing just x evaluates to: (_, _)
-- Components evaluated only when accessed
```

**Key Points:**

- Eager evaluation computes immediately; lazy defers until needed
- Lazy evaluation enables infinite structures and automatic optimization
- Call-by-need combines lazy evaluation with memoization
- Trade-offs exist between predictability and flexibility
- Space leaks are a concern in lazy evaluation

---

