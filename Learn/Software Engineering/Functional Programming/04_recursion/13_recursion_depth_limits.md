## Recursion Depth Limits


Recursion depth limits exist because each recursive call adds a frame to the call stack, which has finite memory. Exceeding this limit causes stack overflow errors, requiring techniques like tail call optimization or iterative conversion.

### Understanding Stack Overflow

```javascript
function infiniteRecursion(n) {
  return infiniteRecursion(n + 1);
}

// This will throw: RangeError: Maximum call stack size exceeded
try {
  infiniteRecursion(0);
} catch (e) {
  console.log(e.message);
}
```

### Finding Stack Limit

```javascript
function findStackLimit(depth = 0) {
  try {
    return findStackLimit(depth + 1);
  } catch (e) {
    return depth;
  }
}

console.log(`Stack limit: ~${findStackLimit()} calls`);
// Typically 10,000-15,000 in JavaScript engines
```

### Problematic Deep Recursion

```javascript
function sumArray(arr, index = 0) {
  if (index >= arr.length) return 0;
  return arr[index] + sumArray(arr, index + 1);
}

const largeArray = Array(100000).fill(1);
// This will stack overflow
try {
  console.log(sumArray(largeArray));
} catch (e) {
  console.log("Stack overflow on large array");
}
```

### Tail Call Optimization (TCO)

[Inference] Tail call optimization eliminates stack frame accumulation when the recursive call is the last operation. [Unverified: JavaScript engines may not implement TCO despite ES6 specification including it.]

```javascript
// Non-tail recursive (accumulates stack frames)
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1); // Multiplication happens AFTER return
}

// Tail recursive (last operation is the call)
function factorialTail(n, acc = 1) {
  if (n <= 1) return acc;
  return factorialTail(n - 1, n * acc); // Call is the last operation
}

console.log(factorialTail(10000)); // May still overflow without TCO
```

### Trampolining

```javascript
// Trampoline executes thunks iteratively
function trampoline(fn) {
  while (typeof fn === 'function') {
    fn = fn();
  }
  return fn;
}

// Return functions instead of calling directly
function sumTail(arr, index = 0, acc = 0) {
  if (index >= arr.length) return acc;
  return () => sumTail(arr, index + 1, acc + arr[index]);
}

const largeArray = Array(100000).fill(1);
console.log(trampoline(() => sumTail(largeArray))); // 100000
```

### Continuation-Passing Style (CPS)

```javascript
function factorial(n, cont = x => x) {
  if (n <= 1) {
    return cont(1);
  }
  return factorial(n - 1, result => cont(n * result));
}

// Still causes stack overflow in JavaScript
// CPS doesn't solve the problem without TCO
```

### Manual Stack Management

```javascript
function factorialIterative(n) {
  const stack = [];
  let result = 1;
  
  while (n > 1) {
    stack.push(n);
    n--;
  }
  
  while (stack.length > 0) {
    result *= stack.pop();
  }
  
  return result;
}

console.log(factorialIterative(10000)); // Works for large inputs
```

### Depth Limiting

```javascript
function limitedRecursion(n, maxDepth = 1000, depth = 0) {
  if (depth >= maxDepth) {
    throw new Error('Maximum recursion depth exceeded');
  }
  if (n <= 0) return 0;
  return n + limitedRecursion(n - 1, maxDepth, depth + 1);
}

try {
  console.log(limitedRecursion(10000));
} catch (e) {
  console.log(e.message);
}
```

### Batching Deep Recursion

```javascript
function processInBatches(arr, batchSize = 1000) {
  function processBatch(start, acc = 0) {
    if (start >= arr.length) return acc;
    
    // Process batch iteratively
    let batchSum = acc;
    const end = Math.min(start + batchSize, arr.length);
    for (let i = start; i < end; i++) {
      batchSum += arr[i];
    }
    
    // Recursive call between batches
    return processBatch(end, batchSum);
  }
  
  return processBatch(0);
}

const largeArray = Array(100000).fill(1);
console.log(processInBatches(largeArray)); // 100000
```

**Key Points:**

- JavaScript typically limits stack to ~10,000-15,000 frames
- Tail recursion optimization not reliably available
- Trampolining converts recursion to iteration
- Manual stack management for complex traversals
- Batch processing reduces recursion depth
- Consider iteration for deep or unbounded recursion
- Monitor depth in production systems

