## Trampolining


Trampolining is a technique that converts recursion into iteration to avoid stack overflow. Instead of making recursive calls directly, functions return descriptions of the next computation (thunks), which a trampoline loop executes sequentially. This transforms stack growth into heap allocation.

The core mechanism uses a driver loop that repeatedly invokes thunks until reaching a final value. Each thunk represents a suspended computation—a function waiting to be called. The trampoline evaluates thunks one at a time, keeping the call stack shallow.

**Basic trampoline implementation**:

```javascript
const trampoline = fn => {
  let result = fn;
  while (typeof result === 'function') {
    result = result();
  }
  return result;
};
```

The loop continues while the result is a function (thunk). Each iteration calls the thunk, which returns either another thunk or a final value.

**Recursive function transformed for trampolining**:

```javascript
// Stack-consuming recursion
const sumDirect = (n, acc = 0) => {
  if (n === 0) return acc;
  return sumDirect(n - 1, acc + n);
};

// Trampolined version
const sumTramp = (n, acc = 0) => {
  if (n === 0) return acc;
  return () => sumTramp(n - 1, acc + n);  // Return thunk
};

const result = trampoline(() => sumTramp(100000));
```

Instead of calling itself directly, `sumTramp` returns a thunk—a parameterless function that, when called, continues the computation. The trampoline executes these thunks iteratively.

Mutual recursion benefits significantly from trampolining:

```javascript
const isEven = n => 
  n === 0 ? true : () => isOdd(n - 1);

const isOdd = n => 
  n === 0 ? false : () => isEven(n - 1);

const checkEven = n => trampoline(() => isEven(n));
```

Without trampolining, mutually recursive functions quickly exhaust the stack. With trampolining, they execute in constant stack space.

**Enhanced trampoline with continuations**:

```javascript
const Bounce = (fn, ...args) => ({ type: 'bounce', fn, args });
const Done = value => ({ type: 'done', value });

const trampoline2 = result => {
  while (result.type === 'bounce') {
    result = result.fn(...result.args);
  }
  return result.value;
};

const factorial = (n, acc = 1) => {
  if (n <= 1) return Done(acc);
  return Bounce(factorial, n - 1, n * acc);
};
```

Using explicit `Bounce` and `Done` data structures clarifies intent and allows passing arguments without creating additional closures.

The performance trade-off involves exchanging stack frames for heap-allocated thunks. Modern JavaScript engines optimize tail calls in strict mode, but trampolining provides a fallback that works everywhere. The constant stack space guarantee makes trampolining essential for algorithms with unbounded recursion depth.

**[Inference]** Trampolining effectively implements tail-call optimization manually when the runtime doesn't provide it. The technique demonstrates how control flow primitives can be encoded using only first-class functions and loops.

