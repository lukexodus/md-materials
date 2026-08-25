## Custom Higher-Order Functions


Custom higher-order functions are user-defined functions that either accept functions as parameters, return functions as results, or both. They enable the creation of reusable, composable abstractions tailored to specific domain needs beyond the standard library offerings like `map`, `filter`, and `reduce`.

### Creating Custom HOFs

The fundamental pattern involves accepting function parameters to customize behavior:

```javascript
const retry = (fn, maxAttempts, delay) => {
  return async (...args) => {
    for (let attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await fn(...args);
      } catch (error) {
        if (attempt === maxAttempts) throw error;
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  };
};

const fetchWithRetry = retry(fetch, 3, 1000);
```

### Utility Patterns

**Memoization HOF:**

```javascript
const memoize = (fn) => {
  const cache = new Map();
  return (...args) => {
    const key = JSON.stringify(args);
    if (cache.has(key)) return cache.get(key);
    const result = fn(...args);
    cache.set(key, result);
    return result;
  };
};

const expensiveCalculation = memoize((n) => {
  return n * n * n;
});
```

**Debounce HOF:**

```javascript
const debounce = (fn, wait) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), wait);
  };
};

const handleSearch = debounce((query) => {
  console.log(`Searching for: ${query}`);
}, 300);
```

**Throttle HOF:**

```javascript
const throttle = (fn, limit) => {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};
```

### Advanced Patterns

**Once HOF (execute only once):**

```javascript
const once = (fn) => {
  let called = false;
  let result;
  return (...args) => {
    if (!called) {
      called = true;
      result = fn(...args);
    }
    return result;
  };
};

const initialize = once(() => {
  console.log('Initializing...');
  return { initialized: true };
});
```

**Before/After Hooks:**

```javascript
const withHooks = (fn, { before, after }) => {
  return (...args) => {
    if (before) before(...args);
    const result = fn(...args);
    if (after) after(result);
    return result;
  };
};

const processData = withHooks(
  (data) => data.map(x => x * 2),
  {
    before: (data) => console.log('Processing:', data),
    after: (result) => console.log('Result:', result)
  }
);
```

**Conditional Execution:**

```javascript
const when = (predicate, fn) => {
  return (...args) => {
    return predicate(...args) ? fn(...args) : args[0];
  };
};

const doubleIfEven = when(
  (x) => x % 2 === 0,
  (x) => x * 2
);
```

### Domain-Specific HOFs

**Validation HOF:**

```javascript
const validate = (validatorFn, errorMsg) => {
  return (fn) => {
    return (...args) => {
      if (!validatorFn(...args)) {
        throw new Error(errorMsg);
      }
      return fn(...args);
    };
  };
};

const divide = validate(
  (a, b) => b !== 0,
  'Division by zero'
)((a, b) => a / b);
```

**Pipeline Builder:**

```javascript
const pipeline = (...fns) => {
  return (initialValue) => {
    return fns.reduce((value, fn) => fn(value), initialValue);
  };
};

const processUser = pipeline(
  (user) => ({ ...user, name: user.name.toUpperCase() }),
  (user) => ({ ...user, age: user.age + 1 }),
  (user) => ({ ...user, timestamp: Date.now() })
);
```

**Key Points:**

- Custom HOFs encapsulate cross-cutting concerns (logging, validation, caching)
- They promote DRY principles by abstracting common patterns
- Type safety becomes important; consider TypeScript for complex HOFs
- Performance overhead exists but is usually negligible compared to benefits
- Naming should clearly convey the HOF's purpose and behavior

