## Decorator Pattern Functional


The decorator pattern in functional programming adds behavior to functions or data without modifying their original implementation. This is achieved through function composition, higher-order functions, and data transformation pipelines.

**Function Wrapping**

The simplest decorator wraps a function with additional behavior before or after execution:

```javascript
const withLogging = (fn) => (...args) => {
  console.log(`Calling ${fn.name} with:`, args);
  const result = fn(...args);
  console.log(`Result:`, result);
  return result;
};

const add = (a, b) => a + b;
const loggedAdd = withLogging(add);

loggedAdd(2, 3); // Logs input and output, returns 5
```

**Timing Decorator**

Measures execution time of any function:

```javascript
const withTiming = (fn) => (...args) => {
  const start = performance.now();
  const result = fn(...args);
  const end = performance.now();
  console.log(`${fn.name} took ${end - start}ms`);
  return result;
};

const expensiveOperation = withTiming((n) => {
  let sum = 0;
  for (let i = 0; i < n; i++) sum += i;
  return sum;
});
```

**Memoization Decorator**

Caches function results based on input arguments:

```javascript
const withMemoization = (fn) => {
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

const fibonacci = withMemoization((n) => {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
});
```

**Error Handling Decorator**

Wraps functions with try-catch and returns error objects instead of throwing:

```javascript
const withErrorHandling = (fn) => (...args) => {
  try {
    const result = fn(...args);
    return { success: true, data: result };
  } catch (error) {
    return { success: false, error: error.message };
  }
};

const riskyOperation = withErrorHandling((x) => {
  if (x < 0) throw new Error('Negative input');
  return Math.sqrt(x);
});
```

**Retry Decorator**

Automatically retries failed operations with configurable attempts and delay:

```javascript
const withRetry = (maxAttempts = 3, delay = 1000) => (fn) => async (...args) => {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn(...args);
    } catch (error) {
      if (attempt === maxAttempts) throw error;
      await new Promise(resolve => setTimeout(resolve, delay * attempt));
    }
  }
};

const fetchData = withRetry(3, 500)(async (url) => {
  const response = await fetch(url);
  if (!response.ok) throw new Error('Fetch failed');
  return response.json();
});
```

**Validation Decorator**

Validates function inputs before execution:

```javascript
const withValidation = (validators) => (fn) => (...args) => {
  for (let i = 0; i < validators.length; i++) {
    const error = validators[i](args[i]);
    if (error) throw new Error(error);
  }
  return fn(...args);
};

const isPositive = (n) => n <= 0 ? 'Must be positive' : null;
const isString = (s) => typeof s !== 'string' ? 'Must be string' : null;

const processData = withValidation([isString, isPositive])((name, count) => {
  return `Processing ${count} items for ${name}`;
});
```

**Composition of Multiple Decorators**

Decorators can be chained or composed using function composition utilities:

```javascript
const compose = (...fns) => (x) => fns.reduceRight((acc, fn) => fn(acc), x);

const pipe = (...fns) => (x) => fns.reduce((acc, fn) => fn(acc), x);

const enhancedFunction = compose(
  withLogging,
  withTiming,
  withMemoization,
  withErrorHandling
)((x) => x * x);

// Or using pipe for left-to-right reading
const enhancedFunctionPipe = pipe(
  withErrorHandling,
  withMemoization,
  withTiming,
  withLogging
)((x) => x * x);
```

**Throttling and Debouncing Decorators**

Controls function execution frequency:

```javascript
const withThrottle = (delay) => (fn) => {
  let lastCall = 0;
  
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      return fn(...args);
    }
  };
};

const withDebounce = (delay) => (fn) => {
  let timeoutId;
  
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

const searchAPI = withDebounce(300)((query) => {
  fetch(`/api/search?q=${query}`);
});
```

**Data Transformation Decorators**

Decorators can transform data structures by wrapping them with additional properties or methods:

```javascript
const withMetadata = (data) => ({
  ...data,
  _metadata: {
    version: '1.0',
    timestamp: Date.now(),
    source: 'api'
  }
});

const withFreezable = (data) => ({
  ...data,
  freeze: function() { return Object.freeze(this); },
  isFrozen: function() { return Object.isFrozen(this); }
});

const decorateData = compose(withFreezable, withMetadata);

const enhancedData = decorateData({ name: 'Item', value: 42 });
```

**Conditional Decorators**

Apply decorators based on runtime conditions:

```javascript
const withConditionalDecorator = (condition, decorator) => (fn) => 
  condition ? decorator(fn) : fn;

const isDevelopment = process.env.NODE_ENV === 'development';

const apiCall = withConditionalDecorator(
  isDevelopment,
  withLogging
)((endpoint) => fetch(endpoint));
```

**Authorization Decorator**

Wraps functions with permission checks:

```javascript
const withAuthorization = (requiredRole) => (fn) => (user, ...args) => {
  if (!user || user.role !== requiredRole) {
    throw new Error('Unauthorized');
  }
  return fn(user, ...args);
};

const deleteUser = withAuthorization('admin')((user, userId) => {
  // Delete logic
  return `User ${userId} deleted by ${user.name}`;
});
```

