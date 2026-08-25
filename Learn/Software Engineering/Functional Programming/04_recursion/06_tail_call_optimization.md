## Tail Call Optimization


Tail call optimization (TCO), also called tail call elimination, is a compiler or interpreter optimization that converts tail-recursive function calls into iteration, eliminating stack frame allocation.

### How It Works

When a function makes a tail call, the current stack frame is no longer needed because no further computation occurs in the calling function. The optimizer replaces the function call with a jump instruction and reuses the current stack frame.

**Without TCO:**

1. Push new stack frame
2. Execute function
3. Pop stack frame
4. Return to caller
5. Repeat for each recursive call (stack grows)

**With TCO:**

1. Update parameters in current frame
2. Jump to function start
3. Single stack frame reused (constant stack space)

### Language Support

**Full support:** Scheme, Haskell, Scala, Elixir, Clojure (through recur), OCaml, F#

**Partial support:** JavaScript ES6 (specified but rarely implemented), Lua, Kotlin

**No native support:** Python, Ruby, Java (without special techniques), C/C++ (compiler-dependent)

### JavaScript TCO Status

[Inference] JavaScript ES6 specification includes proper tail calls, but most engines do not implement it due to:

- Debugging concerns (lost stack traces)
- Performance measurement challenges
- Compatibility with existing code and tools
- Implementation complexity

**Current state:** Safari/JavaScriptCore implements TCO; V8 (Chrome/Node) and SpiderMonkey (Firefox) do not.

### Verification and Testing

**Check if tail call is optimized:**

```javascript
function isInTailPosition() {
  const stack = new Error().stack;
  return stack.split('\n').length;
}

function testTCO(n) {
  if (n === 0) return isInTailPosition();
  return testTCO(n - 1);
}

// If stack depth remains constant, TCO is working
console.log(testTCO(1000));
```

### Optimization Requirements

For TCO to work, the function must:

- Make the recursive call in tail position
- Return the recursive call result directly
- Perform no operations after the recursive call
- Not be wrapped in try-catch blocks (in some implementations)
- Not use closures that capture the current frame (in some implementations)

### Manual Optimization Alternatives

**Convert to loops:**

```javascript
// Tail recursive
function sumTail(n, acc = 0) {
  if (n === 0) return acc;
  return sumTail(n - 1, acc + n);
}

// Manual optimization to loop
function sumLoop(n) {
  let acc = 0;
  while (n > 0) {
    acc += n;
    n -= 1;
  }
  return acc;
}
```

**Use trampolining** (see next section) - Simulate TCO in languages without native support.

### Performance Characteristics

**With TCO:** O(1) stack space, performance comparable to loops

**Without TCO:** O(n) stack space, function call overhead per recursion

**Key Points:**

- TCO eliminates stack frame allocation for tail calls
- Transforms recursion into iteration at the compiler/interpreter level
- Language support varies widely; not reliably available in JavaScript
- When unavailable, use loops or trampolining for deep recursions

