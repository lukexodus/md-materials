## Currying vs Partial Application


While often confused, currying and partial application are distinct concepts that serve different purposes in functional programming.

### Conceptual Differences

**Currying:**

- Always transforms to single-argument functions
- Returns nested functions automatically
- Arity always becomes 1 at each step
- Pure transformation technique

**Partial Application:**

- Fixes some arguments, returns function expecting the rest
- Can handle multiple arguments at once
- Resulting function can have any arity
- Argument-fixing technique

### Implementation Comparison

```javascript
// Currying - sequential single arguments
const curriedSum = a => b => c => a + b + c;
curriedSum(1)(2)(3); // Must provide one at a time

// Partial Application - fix any number of arguments
const sum = (a, b, c) => a + b + c;
const partial = (fn, ...fixedArgs) => 
  (...remainingArgs) => fn(...fixedArgs, ...remainingArgs);

const add5 = partial(sum, 5);
add5(10, 15); // 30 - takes remaining 2 arguments at once
```

### Argument Handling

**Currying:**

```javascript
const curry = fn => {
  const arity = fn.length;
  return function curried(...args) {
    if (args.length >= arity) return fn(...args);
    return (...nextArgs) => curried(...args, ...nextArgs);
  };
};

const volume = (l, w, h) => l * w * h;
const curriedVolume = curry(volume);

// All equivalent ways to call
curriedVolume(2)(3)(4);      // 24
curriedVolume(2, 3)(4);      // 24
curriedVolume(2)(3, 4);      // 24
curriedVolume(2, 3, 4);      // 24
```

**Partial Application:**

```javascript
const partial = (fn, ...fixedArgs) => {
  return (...remainingArgs) => fn(...fixedArgs, ...remainingArgs);
};

const volume = (l, w, h) => l * w * h;

const box2x3 = partial(volume, 2, 3);
box2x3(4); // 24 - only takes remaining argument

const length2 = partial(volume, 2);
length2(3, 4); // 24 - takes remaining 2 arguments
```

### Use Case Scenarios

**When to Use Currying:**

```javascript
// Building reusable configurations
const fetch = curry((method, url, body) => 
  window.fetch(url, { method, body: JSON.stringify(body) })
);

const get = fetch('GET');
const post = fetch('POST');
const put = fetch('PUT');

// Clean API usage
get('/api/users');
post('/api/users', { name: 'Alice' });
```

**When to Use Partial Application:**

```javascript
// Event handlers with pre-configured data
const handleClick = (userId, action, event) => {
  console.log(`User ${userId} performed ${action}`);
};

const userClickHandler = partial(handleClick, '12345');
button.addEventListener('click', userClickHandler('submit'));

// Database queries with preset filters
const query = (table, where, limit, offset) => { /* ... */ };
const userQuery = partial(query, 'users', { active: true });
userQuery(10, 0); // Get first 10 active users
```

### Interoperability

```javascript
// Partial application can create curried-like behavior
const partialRight = (fn, ...fixedArgs) => 
  (...remainingArgs) => fn(...remainingArgs, ...fixedArgs);

const divide = (a, b) => a / b;
const divideBy10 = partialRight(divide, 10);
divideBy10(100); // 10

// Currying enables partial application naturally
const curriedDivide = a => b => a / b;
const divideBy10Curried = curriedDivide(100); // Partial application via currying
divideBy10Curried(10); // 10
```

### Performance Considerations

[Inference] Currying may introduce more function call overhead:

```javascript
// Curried - 3 function calls
curriedSum(1)(2)(3);

// Partial - 2 function calls
const add1 = partial(sum, 1);
add1(2, 3);

// Direct - 1 function call
sum(1, 2, 3);
```

### Library Support

**Ramda (JavaScript):**

```javascript
import { curry, partial } from 'ramda';

const add3 = (a, b, c) => a + b + c;

const curried = curry(add3);
curried(1)(2)(3);

const partialed = partial(add3, [1, 2]);
partialed(3);
```

**Lodash (JavaScript):**

```javascript
import { curry, partial } from 'lodash';

// Similar API but different implementations
```

**Key Points:**

- Currying: transforms to unary functions sequentially
- Partial application: fixes arguments, returns function expecting rest
- Currying is a specific transformation; partial application is argument fixing
- Both enable function specialization and reusability
- Choose based on use case: currying for composition, partial for configuration

---

