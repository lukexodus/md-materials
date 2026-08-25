## Pure Functions


A pure function is a function where the output value is determined only by its input values, without observable side effects. The function must consistently return the same result given the same arguments and must not modify external state or interact with the outside world.

### Characteristics

**Deterministic Output** The function returns identical results for identical inputs across all invocations. No hidden dependencies on global state, instance variables, or external systems affect the computation.

**No Side Effects** Pure functions avoid:

- Modifying variables outside their scope
- Mutating input parameters
- Performing I/O operations (reading files, network calls, console output)
- Modifying global state or static variables
- Throwing exceptions that escape the function
- Calling other impure functions

### Implementation Principles

**Immutable Data** Pure functions work with immutable data structures. Instead of modifying existing data, they create and return new data structures with the desired changes.

```javascript
// Pure function
const addItem = (array, item) => [...array, item];

// Impure function
const addItemImpure = (array, item) => {
  array.push(item); // Mutates input
  return array;
};
```

**Self-Contained Logic** All data needed for computation must be passed as parameters. The function cannot rely on external variables, configuration, or state.

```haskell
-- Pure
add :: Int -> Int -> Int
add x y = x + y

-- Impure (depends on external state)
globalMultiplier = 10
impureAdd :: Int -> Int -> Int
impureAdd x y = (x + y) * globalMultiplier
```

### Testing Pure Functions

Pure functions are trivially testable. Test cases require only input-output pairs without setup, teardown, mocking, or state management.

```python
def multiply(x, y):
    return x * y

# Testing is straightforward
assert multiply(3, 4) == 12
assert multiply(0, 100) == 0
assert multiply(-2, 5) == -10
```

No test isolation concerns exist since pure functions cannot interfere with each other or share state.

### Composition

Pure functions compose naturally because their deterministic nature guarantees predictable behavior when combined.

```javascript
const double = x => x * 2;
const increment = x => x + 1;
const square = x => x * x;

// Compose functions
const doubleThenIncrement = x => increment(double(x));
const process = x => square(increment(double(x)));
```

The composition order matters, but each function's behavior remains consistent regardless of context.

