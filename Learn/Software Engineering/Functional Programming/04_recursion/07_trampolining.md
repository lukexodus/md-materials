## Trampolining


Trampolining is a technique that simulates tail call optimization in languages without native TCO support by converting recursive calls into an iterative loop that executes thunks (deferred computations).

### Core Concept

Instead of making recursive calls directly, functions return thunks (zero-argument functions) that represent the next computation. A trampoline function repeatedly executes these thunks until a final value is returned.

**Example:**

```javascript
// Trampoline executor
function trampoline(fn) {
  let result = fn;
  while (typeof result === 'function') {
    result = result();  // Execute thunk
  }
  return result;
}

// Tail recursive function converted to trampolined style
function sumTrampoline(n, acc = 0) {
  if (n === 0) return acc;
  return () => sumTrampoline(n - 1, acc + n);  // Return thunk
}

// Usage
trampoline(() => sumTrampoline(10000));  // Won't stack overflow
```

### Implementation Patterns

**Basic trampoline:**

```javascript
function trampoline(fn) {
  while (typeof fn === 'function') {
    fn = fn();
  }
  return fn;
}
```

**Thunk wrapper:**

```javascript
function thunk(fn, ...args) {
  return () => fn(...args);
}

function factorialTramp(n, acc = 1) {
  if (n === 0) return acc;
  return thunk(factorialTramp, n - 1, n * acc);
}
```

**Automatic trampolining helper:**

```javascript
function makeTrampolined(fn) {
  return function trampolined(...args) {
    let result = fn(...args);
    while (typeof result === 'function') {
      result = result();
    }
    return result;
  };
}

const sum = makeTrampolined(function(n, acc = 0) {
  if (n === 0) return acc;
  return () => sum(n - 1, acc + n);
});
```

### Advantages

**Stack safety** - Converts recursion to iteration, preventing stack overflow in languages without TCO.

**Language agnostic** - Works in any language that supports first-class functions, including JavaScript and Python.

**Explicit control** - Developer controls when and how optimization occurs rather than relying on compiler/interpreter behavior.

**Debugging friendly** - Stack traces remain meaningful because actual stack depth stays shallow.

### Disadvantages

**Performance overhead** - Function creation and type checking add overhead compared to native TCO or direct loops.

**Code complexity** - Requires wrapping recursive calls in thunks, making code less straightforward.

**Manual conversion** - Each recursive function requires explicit conversion to trampolined style.

**Not transparent** - Unlike native TCO, trampolining requires changes to both function implementation and call sites.

### Advanced Patterns

**Delayed evaluation with arguments:**

```javascript
function trampoline(fn) {
  return function(...args) {
    let result = fn(...args);
    while (typeof result === 'function') {
      result = result();
    }
    return result;
  };
}
```

**Multiple return types:**

```javascript
const Bounce = (fn) => ({tag: 'bounce', fn});
const Done = (value) => ({tag: 'done', value});

function trampoline(initial) {
  let current = initial;
  while (current.tag === 'bounce') {
    current = current.fn();
  }
  return current.value;
}

function evenTramp(n) {
  if (n === 0) return Done(true);
  return Bounce(() => oddTramp(n - 1));
}

function oddTramp(n) {
  if (n === 0) return Done(false);
  return Bounce(() => evenTramp(n - 1));
}
```

### Use Cases

**Deep recursion without TCO** - JavaScript, Python, and other languages where deep recursion would cause stack overflow.

**Mutual recursion** - Particularly useful for mutually recursive functions where TCO may not apply.

**Interpreter implementation** - Building interpreters where controlled execution is important.

**Recursive parsers** - Parsing deeply nested structures without stack limits.

### Comparison with Other Techniques

**vs. Direct recursion:** Trampoline prevents stack overflow but adds overhead.

**vs. Loops:** Loops are faster but less expressive for naturally recursive algorithms.

**vs. Native TCO:** TCO is more efficient when available, but trampolining works everywhere.

