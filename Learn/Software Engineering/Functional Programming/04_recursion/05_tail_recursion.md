## Tail Recursion


Tail recursion is a special form of recursion where the recursive call is the last operation performed in the function. No additional computation occurs after the recursive call returns, allowing the function to be optimized into iteration.

### Definition and Recognition

A recursive call is in tail position when it is the final action before returning. The function returns the result of the recursive call directly without further processing.

**Example:**

```javascript
// Tail recursive - recursive call is last operation
function sumTail(n, accumulator = 0) {
  if (n === 0) return accumulator;
  return sumTail(n - 1, accumulator + n);  // Nothing after this call
}

// Not tail recursive - addition happens after recursive call
function sumNonTail(n) {
  if (n === 0) return 0;
  return n + sumNonTail(n - 1);  // Addition after recursion
}
```

### Accumulator Pattern

Tail recursion typically uses an accumulator parameter to build the result progressively, eliminating the need for post-recursive computation.

**Converting to tail recursion:**

```javascript
// Original non-tail recursive
function factorial(n) {
  if (n === 0) return 1;
  return n * factorial(n - 1);
}

// Tail recursive with accumulator
function factorialTail(n, acc = 1) {
  if (n === 0) return acc;
  return factorialTail(n - 1, n * acc);
}
```

### Identifying Tail Position

A recursive call is NOT in tail position if:

- Any operation occurs after the recursive call returns
- The recursive call result is used in an expression
- Multiple recursive calls occur (like in tree traversal)
- The call is inside a conditional that isn't the final return

A recursive call IS in tail position if:

- It's the direct return value
- No stack frame needs to be preserved after the call
- The function immediately returns whatever the recursive call returns

### Benefits

**Stack space efficiency** - With proper optimization, tail recursive functions use constant stack space regardless of recursion depth.

**Prevention of stack overflow** - Deep recursions that would overflow the stack with regular recursion can run indefinitely when tail call optimized.

**Performance** - Tail call optimization transforms recursion into iteration, eliminating function call overhead.

**Clarity for certain algorithms** - Some algorithms express more naturally with accumulator-based tail recursion than with loops.

### Limitations and Trade-offs

**Accumulator complexity** - Tail recursive versions often require additional parameters, making function signatures more complex.

**Readability** - Non-tail recursive versions sometimes express the algorithm more clearly, matching mathematical definitions more closely.

**Multiple recursion** - Algorithms with multiple recursive calls (tree operations, divide-and-conquer) cannot always be converted to tail recursion without restructuring.

**Debugging** - Tail call optimization eliminates stack frames, making stack traces less informative during debugging.

### Common Patterns

**List processing:**

```javascript
function reverseTail(list, acc = []) {
  if (list.length === 0) return acc;
  return reverseTail(list.slice(1), [list[0], ...acc]);
}
```

**Numeric sequences:**

```javascript
function fibonacciTail(n, a = 0, b = 1) {
  if (n === 0) return a;
  return fibonacciTail(n - 1, b, a + b);
}
```

**State machines:**

```javascript
function parseStateTail(input, index = 0, state = 'START') {
  if (index >= input.length) return state === 'ACCEPT';
  const char = input[index];
  const nextState = transition(state, char);
  return parseStateTail(input, index + 1, nextState);
}
```

