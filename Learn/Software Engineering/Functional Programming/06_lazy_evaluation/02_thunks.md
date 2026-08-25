## Thunks


A thunk is a deferred computation—a data structure representing an unevaluated expression along with its environment, enabling lazy evaluation.

### Core Concept

A thunk encapsulates:

1. The expression to compute
2. The environment (variable bindings) needed for computation
3. The evaluation state (unevaluated, evaluating, or evaluated)

When forced, a thunk executes its computation, caches the result, and replaces itself with the value.

### Thunk Representation

**Conceptual structure:**

```
Thunk {
  expression: () -> Value
  state: Unevaluated | Evaluating | Evaluated(Value)
  environment: Map<Name, Value>
}
```

**States:**

- **Unevaluated:** Expression not yet computed
- **Evaluating:** Currently computing (detects cycles)
- **Evaluated:** Computation complete, result cached

### Creation and Evaluation

**Example:**

```haskell
-- Creating a thunk (lazy binding)
let x = 2 + 3  -- x is a thunk containing "+ 2 3"

-- Forcing evaluation
print x  -- Thunk evaluated, becomes 5, prints 5

-- Subsequent uses
print x  -- Uses cached value, no recomputation
```

### Memoization

Thunks implement call-by-need through memoization:

**Example:**

```haskell
-- Expensive computation
let x = expensiveComputation()

-- First use: computes and caches
let y = x + 1  -- x evaluated here

-- Second use: retrieves cached value
let z = x + 2  -- x not recomputed
```

**Without memoization (call-by-name):** Each use would recompute. **With memoization (call-by-need):** Computed once, cached, reused.

### Thunk Overhead

Thunks impose costs:

**Memory overhead:**

- Storage for expression closure
- Environment capture
- State tracking

**Time overhead:**

- Allocation cost
- Indirection on access
- Cache check on force

**Example:**

```haskell
-- Simple value in eager: 8 bytes (Int64)
let x = 42

-- Same in lazy: ~40+ bytes
-- Thunk header, expression pointer, environment, state
-- Plus eventual 8 bytes for value after evaluation
```

### Black Holes

Black holes detect circular dependencies during evaluation:

**Example:**

```haskell
-- Circular definition
let x = x + 1

-- Evaluation:
-- 1. Mark thunk as "Evaluating" (black hole)
-- 2. Attempt to compute x + 1
-- 3. Need x, find it's "Evaluating"
-- 4. Cycle detected: error or deadlock prevention
```

Black holes prevent infinite loops from self-referential thunks.

### Thunk Chains

Unevaluated expressions can form chains:

**Example:**

```haskell
let a = 1 + 2
let b = a + 3
let c = b + 4

-- Memory: three thunks
-- c -> thunk(b + 4)
-- b -> thunk(a + 3)  
-- a -> thunk(1 + 2)

-- Forcing c:
-- Evaluates a: 3
-- Evaluates b: 6
-- Evaluates c: 10

-- After: all cached as values
```

Long chains consume memory and require recursive evaluation.

### Stack Overflow Risk

Deep thunk chains can overflow the stack:

**Example:**

```haskell
-- Left fold accumulating thunks
foldl (+) 0 [1..1000000]

-- Builds: ((((0 + 1) + 2) + 3) ... + 1000000)
-- Each + is a thunk
-- Forcing final result evaluates 1M nested thunks
-- Stack overflow likely

-- Solution: strict fold
foldl' (+) 0 [1..1000000]
-- Forces evaluation at each step
-- Constant stack space
```

### Weak Head Normal Form (WHNF)

Forcing a thunk evaluates to WHNF, not necessarily full normal form:

**Example:**

```haskell
let x = (1 + 2, 3 + 4)

-- Forcing x evaluates to WHNF:
-- Pair constructor visible: (_, _)
-- Components remain as thunks

-- Accessing first element forces its thunk:
fst x  -- Forces 1 + 2, returns 3
```

### Deep vs Shallow Forcing

**Shallow (seq, default):** Evaluates to WHNF only

**Deep (deepseq):** Recursively evaluates entire structure

**Example:**

```haskell
let x = [1+1, 2+2, 3+3]

-- Shallow force
x `seq` ()
-- List spine evaluated: (:) (:) (:) []
-- Elements remain thunks: [_, _, _]

-- Deep force  
force x `seq` ()
-- Fully evaluated: [2, 4, 6]
```

### Space Leaks from Thunks

Accumulated thunks cause space leaks:

**Example:**

```haskell
-- Reading large file
contents = readFile "huge.txt"
let lineCount = length (lines contents)

-- If contents is lazy:
-- Entire file held as thunks while counting
-- Consumes memory proportional to file size

-- Solution: strict reading or incremental processing
```

### Thunk Inspection

Some languages provide thunk introspection:

**Example:**

```haskell
-- [Unverified] GHC-specific inspection
import GHC.HeapView

let x = 1 + 2
isEvaluated x  -- False (still a thunk)

let y = x + 1  -- Forces x
isEvaluated x  -- True (now a value)
```

### Bang Patterns and Strictness

Strictness annotations prevent thunk creation:

**Example:**

```haskell
-- Lazy field (default in Haskell)
data Point = Point Int Int
-- Fields stored as thunks until accessed

-- Strict field
data Point = Point !Int !Int
-- Fields evaluated immediately, no thunks

-- Function strictness
f !x = x + 1  -- x evaluated before entering function
```

### Thunk Behavior in Different Contexts

**In data structures:**

```haskell
-- List with thunks
let xs = map (*2) [1, 2, 3]
-- xs is [_, _, _] (three thunks)

-- Accessing head forces one thunk
head xs  -- Forces first thunk only: 2
```

**In function arguments:**

```haskell
-- Lazy parameter
f x = if condition then x else 0
-- x is thunk, only forced if condition is True

-- Strict parameter
f !x = if condition then x else 0
-- x forced before function body executes
```

### Performance Characteristics

**Best cases for thunks:**

- Conditional computation (may avoid entirely)
- Infinite structures (compute only what's needed)
- Modular programming (separate generation/consumption)

**Worst cases for thunks:**

- Accumulating computations (thunk chains)
- Always-needed values (wasted overhead)
- Tight loops (repeated allocation/indirection)

**Key Points:**

- Thunks are suspended computations with memoization
- Enable lazy evaluation but impose memory and time overhead
- Can cause space leaks through accumulation
- Black holes detect circular dependencies
- Strictness annotations prevent thunk creation when undesired

---

