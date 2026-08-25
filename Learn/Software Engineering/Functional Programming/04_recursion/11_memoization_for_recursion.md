## Memoization for Recursion


Memoization caches the results of expensive function calls, returning cached results when the same inputs occur again. This optimization transforms exponential recursive algorithms into polynomial or linear time by eliminating redundant computation.

### Basic Memoization Pattern

Memoization stores computed results in a cache (typically an object or Map), checking the cache before performing computation.

**Example:**

```javascript
// Without memoization: O(2^n)
const fibSlow = (n) =>
  n <= 1 ? n : fibSlow(n - 1) + fibSlow(n - 2);

// With memoization: O(n)
const fibMemo = (n, cache = {}) => {
  if (n in cache) return cache[n];
  if (n <= 1) return n;
  
  cache[n] = fibMemo(n - 1, cache) + fibMemo(n - 2, cache);
  return cache[n];
};
```

### Generic Memoization Wrapper

A higher-order function can add memoization to any recursive function automatically.

**Example:**

```javascript
const memoize = (fn) => {
  const cache = new Map();
  
  return (...args) => {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) {
      return cache.get(key);
    }
    
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
};

// Usage
const fib = memoize((n) =>
  n <= 1 ? n : fib(n - 1) + fib(n - 2));

// fib(100) computes instantly
```

### Performance Impact

Memoization dramatically improves performance for problems with overlapping subproblems, trading space for time.

**Example:**

```javascript
// Performance comparison
console.time('Without memo');
fibSlow(40);  // Takes several seconds
console.timeEnd('Without memo');

console.time('With memo');
fibMemo(40);  // Completes in milliseconds
console.timeEnd('With memo');

// fibSlow(40): ~331 million calls
// fibMemo(40): ~40 calls (each n computed once)
```

### Multiple Parameters

Memoization works with multi-parameter functions by creating composite cache keys.

**Example:**

```javascript
// Grid paths with memoization
const countPaths = (rows, cols) => {
  const cache = new Map();
  
  const helper = (r, c) => {
    const key = `${r},${c}`;
    if (cache.has(key)) return cache.get(key);
    
    if (r === rows - 1 && c === cols - 1) return 1;
    if (r >= rows || c >= cols) return 0;
    
    const result = helper(r + 1, c) + helper(r, c + 1);
    cache.set(key, result);
    return result;
  };
  
  return helper(0, 0);
};
```

### Memoization with Closure

Using closures to maintain the cache keeps the implementation clean and encapsulated.

**Example:**

```javascript
const createMemoizedFib = () => {
  const cache = {};
  
  const fib = (n) => {
    if (n in cache) return cache[n];
    if (n <= 1) return n;
    
    cache[n] = fib(n - 1) + fib(n - 2);
    return cache[n];
  };
  
  return fib;
};

const fib = createMemoizedFib();
fib(50);  // Fast, cache persists between calls
```

### Complex Recursive Problems

Memoization transforms intractable recursive problems into efficient solutions.

**Example:**

```javascript
// Longest common subsequence with memoization
const lcs = (s1, s2) => {
  const cache = new Map();
  
  const helper = (i, j) => {
    if (i === s1.length || j === s2.length) return 0;
    
    const key = `${i},${j}`;
    if (cache.has(key)) return cache.get(key);
    
    let result;
    if (s1[i] === s2[j]) {
      result = 1 + helper(i + 1, j + 1);
    } else {
      result = Math.max(
        helper(i + 1, j),
        helper(i, j + 1)
      );
    }
    
    cache.set(key, result);
    return result;
  };
  
  return helper(0, 0);
};
```

### Cache Invalidation

For mutable data or long-running applications, cache management becomes important.

**Example:**

```javascript
const createMemoizedFunction = (fn, maxCacheSize = 1000) => {
  const cache = new Map();
  
  return (...args) => {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) return cache.get(key);
    
    const result = fn(...args);
    
    // Limit cache size
    if (cache.size >= maxCacheSize) {
      const firstKey = cache.keys().next().value;
      cache.delete(firstKey);
    }
    
    cache.set(key, result);
    return result;
  };
};
```

### Limitations

Memoization has space overhead and works best for pure functions with immutable inputs. The cache key generation must correctly represent all inputs.

**Example:**

```javascript
// Problem: object/array arguments
const badMemoize = (fn) => {
  const cache = new Map();
  
  return (arg) => {
    // Won't work: different array instances, same content
    if (cache.has(arg)) return cache.get(arg);
    
    const result = fn(arg);
    cache.set(arg, result);
    return result;
  };
};

// Solution: serialize keys or use deep comparison
const goodMemoize = (fn) => {
  const cache = new Map();
  
  return (arg) => {
    const key = JSON.stringify(arg);
    if (cache.has(key)) return cache.get(key);
    
    const result = fn(arg);
    cache.set(key, result);
    return result;
  };
};
```

**Key Points:**

- Memoization caches function results by input parameters
- Transforms exponential recursion into linear/polynomial time
- Requires pure functions with deterministic outputs
- Trade-off: increased space complexity for decreased time complexity
- Cache key generation critical for correctness
- Most effective for problems with overlapping subproblems
- Can be implemented as generic higher-order function
- Consider cache size limits for long-running applications

