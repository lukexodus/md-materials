## Dynamic Programming with Recursion


Dynamic programming optimizes recursive solutions by storing previously computed results to avoid redundant calculations. This technique, called memoization, transforms exponential time complexity into polynomial or linear time by caching function outputs.

### Naive Recursion Problem

```javascript
// Fibonacci without memoization - exponential O(2^n)
function fib(n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
}

console.log(fib(40)); // Takes several seconds
```

### Memoization Implementation

```javascript
// Manual memoization
function fibMemo() {
  const cache = {};
  
  return function fib(n) {
    if (n in cache) return cache[n];
    if (n <= 1) return n;
    
    cache[n] = fib(n - 1) + fib(n - 2);
    return cache[n];
  };
}

const fib = fibMemo();
console.log(fib(40)); // Instant - O(n)
console.log(fib(100)); // Still instant
```

### Generic Memoization Function

```javascript
function memoize(fn) {
  const cache = new Map();
  
  return function(...args) {
    const key = JSON.stringify(args);
    
    if (cache.has(key)) {
      return cache.get(key);
    }
    
    const result = fn.apply(this, args);
    cache.set(key, result);
    return result;
  };
}

const fib = memoize(function(n) {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
});

console.log(fib(100)); // Fast computation
```

### Practical Example: Longest Common Subsequence

```javascript
function lcs(str1, str2) {
  const memo = {};
  
  function helper(i, j) {
    const key = `${i},${j}`;
    if (key in memo) return memo[key];
    
    if (i === str1.length || j === str2.length) {
      return 0;
    }
    
    if (str1[i] === str2[j]) {
      memo[key] = 1 + helper(i + 1, j + 1);
    } else {
      memo[key] = Math.max(
        helper(i + 1, j),
        helper(i, j + 1)
      );
    }
    
    return memo[key];
  }
  
  return helper(0, 0);
}

console.log(lcs("ABCDGH", "AEDFHR")); // 3 (ADH)
```

### Coin Change Problem

```javascript
function coinChange(coins, amount) {
  const memo = {};
  
  function min(n) {
    if (n in memo) return memo[n];
    if (n === 0) return 0;
    if (n < 0) return Infinity;
    
    let result = Infinity;
    for (const coin of coins) {
      result = Math.min(result, 1 + min(n - coin));
    }
    
    memo[n] = result;
    return result;
  }
  
  const result = min(amount);
  return result === Infinity ? -1 : result;
}

console.log(coinChange([1, 2, 5], 11)); // 3 (5+5+1)
console.log(coinChange([2], 3)); // -1 (impossible)
```

### Path Counting in Grid

```javascript
function uniquePaths(m, n) {
  const memo = {};
  
  function countPaths(row, col) {
    const key = `${row},${col}`;
    if (key in memo) return memo[key];
    
    if (row === m - 1 && col === n - 1) return 1;
    if (row >= m || col >= n) return 0;
    
    memo[key] = countPaths(row + 1, col) + countPaths(row, col + 1);
    return memo[key];
  }
  
  return countPaths(0, 0);
}

console.log(uniquePaths(3, 7)); // 28 unique paths
```

### Top-Down vs Bottom-Up

```javascript
// Top-down (memoization)
function fibTopDown(n, memo = {}) {
  if (n in memo) return memo[n];
  if (n <= 1) return n;
  
  memo[n] = fibTopDown(n - 1, memo) + fibTopDown(n - 2, memo);
  return memo[n];
}

// Bottom-up (tabulation)
function fibBottomUp(n) {
  if (n <= 1) return n;
  
  const dp = [0, 1];
  for (let i = 2; i <= n; i++) {
    dp[i] = dp[i - 1] + dp[i - 2];
  }
  
  return dp[n];
}

console.log(fibTopDown(50)); // 12586269025
console.log(fibBottomUp(50)); // 12586269025
```

**Key Points:**

- Memoization stores results to avoid recomputation
- Transforms exponential complexity to polynomial
- Cache key generation critical for multi-parameter functions
- Top-down (memoization) uses recursion with caching
- Bottom-up (tabulation) uses iteration to fill table
- Memory trade-off: space for time efficiency
- Best for overlapping subproblems with optimal substructure

