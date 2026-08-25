## Continuation-passing style


Continuation-passing style (CPS) is a programming technique where functions never return values directly. Instead, each function takes an additional parameter—a continuation—which is a function that receives the result and determines what happens next. Control flow becomes explicit as data passed between continuations.

In direct style, a function computes and returns: `f(x) => result`. In CPS, the same function takes a continuation: `f(x, k) => k(result)`. The continuation `k` represents "the rest of the computation." Rather than returning to the caller, the function calls the continuation with its result.

**Transformation from direct to CPS**:

```javascript
// Direct style
const add = (x, y) => x + y;
const square = x => x * x;
const compute = x => square(add(x, 3));

// CPS style
const addCPS = (x, y, k) => k(x + y);
const squareCPS = (x, k) => k(x * x);
const computeCPS = (x, k) => 
  addCPS(x, 3, sum => 
    squareCPS(sum, k));
```

Every intermediate result flows through a continuation. The computation becomes a chain of nested function calls where each continuation receives control explicitly.

CPS transforms control flow into data flow. Operations like exception handling, backtracking, coroutines, and early exit become first-class values—continuations that can be captured, stored, and invoked at will. You can implement `return`, `break`, `continue`, and exception throwing purely through continuation manipulation.

**Reified control flow**:

```javascript
const divide = (x, y, success, failure) => {
  if (y === 0) {
    failure("Division by zero");
  } else {
    success(x / y);
  }
};

divide(10, 2, 
  result => console.log(result),
  error => console.error(error)
);
```

Multiple continuations represent different execution paths. The success and failure continuations make error handling explicit without exceptions or special control structures.

CPS enables precise control over evaluation order and stack usage. Since functions don't return in the traditional sense, the call stack doesn't grow with each function call—continuations take over completely. However, this property only provides practical benefits when combined with tail-call optimization or trampolining.

**[Inference]** CPS serves as an intermediate representation in compilers. Many optimizing compilers convert code to CPS form, perform transformations, then convert back. The explicit control flow makes certain optimizations tractable that would be difficult in direct style.

The primary drawback is complexity. CPS code is harder to read and write. Callback pyramids and nested continuations obscure the underlying logic. However, monadic abstractions can recover direct-style appearance while maintaining CPS semantics underneath.

