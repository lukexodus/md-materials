## Side Effects


A side effect occurs when a function interacts with or modifies something outside its own scope, beyond simply returning a value. Side effects make code harder to reason about, test, and debug because the function's behavior depends on or affects external state.

### Types of Side Effects

**Modifying external variables** - Changing variables declared outside the function scope creates hidden dependencies and makes the function's behavior unpredictable.

**I/O operations** - Reading from or writing to files, databases, network requests, or console output are side effects because they interact with the external world.

**Mutating input arguments** - Changing the contents of objects or arrays passed as parameters affects the caller's data.

**Modifying global state** - Altering global variables, static fields, or singleton instances creates coupling across the entire application.

**Throwing exceptions** - While sometimes necessary, exceptions are side effects that alter the normal flow of execution.

**Time-dependent behavior** - Functions that produce different outputs for the same inputs based on time, random numbers, or external state have side effects.

### Identifying Side Effects

A function has side effects if:

- It returns `void` or `undefined` (likely performing operations for their effects)
- It modifies any variable not declared within its scope
- It calls other functions that have side effects
- It performs operations that are observable outside the function
- Running it multiple times with the same inputs produces different results or different observable behaviors

### Impact on Code Quality

**Testability** - Side effects require complex test setups with mocks, stubs, and fixtures. Pure functions need only input-output verification.

**Predictability** - Functions with side effects have outcomes that depend on hidden state, making behavior difficult to predict from the function signature alone.

**Concurrency** - Side effects create race conditions and require synchronization mechanisms when multiple threads or processes access shared state.

**Composability** - Functions with side effects cannot be safely composed because each function may interfere with others' assumptions about state.

**Example:**

```javascript
// Has side effects
let total = 0;
function addToTotal(value) {
  total += value;  // Modifies external state
  console.log(total);  // I/O operation
}

// Pure - no side effects
function add(a, b) {
  return a + b;  // Only returns a value
}
```

