## Function Decorators as HOF


Function decorators are higher-order functions that take a function as input and return an enhanced or modified version. They wrap existing functionality with additional behavior without modifying the original function.

### Core Decorator Pattern

```javascript
// Basic decorator structure
const decorator = (fn) => {
  return (...args) => {
    // Before logic
    const result = fn(...args);
    // After logic
    return result;
  };
};

const greet = (name) => `Hello, ${name}`;
const decoratedGreet = decorator(greet);
```

### Practical Decorator Implementations

**Logging Decorator**

```javascript
const withLogging = (fn) => {
  return (...args) => {
    console.log(`Calling ${fn.name} with:`, args);
    const result = fn(...args);
    console.log(`${fn.name} returned:`, result);
    return result;
  };
};

const multiply = (a, b) => a * b;
const loggedMultiply = withLogging(multiply);

loggedMultiply(3, 4);
// Calling multiply with: [3, 4]
// multiply returned: 12
```

**Timing Decorator**

```javascript
const withTiming = (fn) => {
  return (...args) => {
    const start = performance.now();
    const result = fn(...args);
    const end = performance.now();
    console.log(`${fn.name} took ${(end - start).toFixed(2)}ms`);
    return result;
  };
};

const expensiveOperation = (n) => {
  let sum = 0;
  for (let i = 0; i < n; i++) sum += i;
  return sum;
};

const timedOperation = withTiming(expensiveOperation);
timedOperation(1000000); // expensiveOperation took 2.45ms
```

**Memoization Decorator**

```javascript
const withMemoization = (fn) => {
  const cache = new Map();
  return (...args) => {
    const key = JSON.stringify(args);
    if (cache.has(key)) {
      console.log('Cache hit');
      return cache.get(key);
    }
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
};

const fibonacci = (n) => {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
};

const memoizedFib = withMemoization(fibonacci);
memoizedFib(40); // Slow first time
memoizedFib(40); // Instant second time - Cache hit
```

**Error Handling Decorator**

```javascript
const withErrorHandling = (fn, fallbackValue = null) => {
  return (...args) => {
    try {
      return fn(...args);
    } catch (error) {
      console.error(`Error in ${fn.name}:`, error.message);
      return fallbackValue;
    }
  };
};

const parseJSON = (str) => JSON.parse(str);
const safeParseJSON = withErrorHandling(parseJSON, {});

safeParseJSON('{"valid": "json"}'); // { valid: 'json' }
safeParseJSON('invalid json');      // {} - Returns fallback
```

### Composing Decorators

```javascript
const compose = (...decorators) => (fn) => 
  decorators.reduceRight((decorated, decorator) => decorator(decorated), fn);

const businessLogic = (x) => x * 2;

const enhanced = compose(
  withLogging,
  withTiming,
  withMemoization
)(businessLogic);

enhanced(5);
// Logs timing, caches result, logs input/output
```

### Parameterized Decorators

```javascript
const withRetry = (maxAttempts = 3, delay = 1000) => (fn) => {
  return async (...args) => {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn(...args);
      } catch (error) {
        if (attempt === maxAttempts) throw error;
        console.log(`Attempt ${attempt} failed, retrying...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  };
};

const fetchData = async (url) => {
  const response = await fetch(url);
  if (!response.ok) throw new Error('Fetch failed');
  return response.json();
};

const resilientFetch = withRetry(3, 2000)(fetchData);
resilientFetch('/api/data'); // Retries up to 3 times
```

### Validation Decorator

```javascript
const withValidation = (schema) => (fn) => {
  return (...args) => {
    const errors = [];
    args.forEach((arg, index) => {
      const validator = schema[index];
      if (validator && !validator(arg)) {
        errors.push(`Argument ${index} failed validation`);
      }
    });
    
    if (errors.length > 0) {
      throw new Error(errors.join(', '));
    }
    
    return fn(...args);
  };
};

const isString = (val) => typeof val === 'string';
const isPositive = (val) => typeof val === 'number' && val > 0;

const createUser = (name, age) => ({ name, age });

const validatedCreateUser = withValidation([isString, isPositive])(createUser);

validatedCreateUser('Alice', 30);  // { name: 'Alice', age: 30 }
// validatedCreateUser('Bob', -5);  // Throws error
```

### Rate Limiting Decorator

```javascript
const withRateLimit = (maxCalls, timeWindow) => (fn) => {
  const calls = [];
  return (...args) => {
    const now = Date.now();
    const recentCalls = calls.filter(time => now - time < timeWindow);
    
    if (recentCalls.length >= maxCalls) {
      throw new Error('Rate limit exceeded');
    }
    
    calls.push(now);
    return fn(...args);
  };
};

const apiCall = (endpoint) => fetch(endpoint);
const limitedApiCall = withRateLimit(5, 60000)(apiCall); // 5 calls per minute

// Can call 5 times within a minute, 6th throws error
```

### Debounce Decorator

```javascript
const withDebounce = (delay) => (fn) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    return new Promise((resolve) => {
      timeoutId = setTimeout(() => {
        resolve(fn(...args));
      }, delay);
    });
  };
};

const searchAPI = (query) => fetch(`/api/search?q=${query}`);
const debouncedSearch = withDebounce(300)(searchAPI);

// Only executes after 300ms of no calls
inputElement.addEventListener('input', (e) => {
  debouncedSearch(e.target.value);
});
```

### Language-Specific Decorators

**Python:**

```python
def with_logging(fn):
    def wrapper(*args, **kwargs):
        print(f"Calling {fn.__name__}")
        result = fn(*args, **kwargs)
        print(f"Result: {result}")
        return result
    return wrapper

@with_logging
def add(a, b):
    return a + b

add(3, 5)  # Logs call and result
```

**TypeScript:**

```typescript
function readonly(target: any, key: string) {
  Object.defineProperty(target, key, {
    writable: false
  });
}

class Example {
  @readonly
  name: string = "immutable";
}
```

### Decorator Factories

```javascript
const withPrefix = (prefix) => (fn) => {
  return (...args) => {
    const result = fn(...args);
    return `${prefix}: ${result}`;
  };
};

const greet = (name) => `Hello, ${name}`;

const formalGreet = withPrefix('FORMAL')(greet);
const casualGreet = withPrefix('CASUAL')(greet);

formalGreet('Alice'); // "FORMAL: Hello, Alice"
casualGreet('Bob');   // "CASUAL: Hello, Bob"
```

**Key Points:**

- Decorators wrap functions to add behavior without modification
- Enable separation of concerns (logging, validation, timing separate from logic)
- Composable for building complex functionality
- Support both synchronous and asynchronous operations
- Create reusable cross-cutting concerns
- Maintain function signatures while enhancing behavior

