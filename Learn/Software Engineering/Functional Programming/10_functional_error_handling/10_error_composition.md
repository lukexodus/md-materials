## Error Composition


Error composition combines multiple potentially failing operations while preserving error information, allowing errors to accumulate or propagate through a computation pipeline. This enables building complex error-handling logic from simple, composable pieces.

The fundamental approach uses algebraic data types (Either, Result, Validation) that encapsulate success or failure states. These types provide combinators for chaining operations, accumulating errors, or choosing between multiple fallible computations.

**Key Points:**

- Enables explicit error handling in function signatures through types like `Result<T, E>`
- Supports both fail-fast semantics (stop at first error) and accumulation (collect all errors)
- Composes through flatMap/bind for sequential operations and applicative operations for parallel validation
- Separates error handling logic from business logic

**Sequential composition (Either/Result monad):**

```javascript
// Result type implementation
class Ok {
  constructor(value) { this.value = value; }
  map(f) { return new Ok(f(this.value)); }
  flatMap(f) { return f(this.value); }
  mapError(f) { return this; }
  getOrElse(defaultValue) { return this.value; }
}

class Err {
  constructor(error) { this.error = error; }
  map(f) { return this; }
  flatMap(f) { return this; }
  mapError(f) { return new Err(f(this.error)); }
  getOrElse(defaultValue) { return defaultValue; }
}

// Usage with sequential composition
const parseUser = (json) => {
  try {
    return new Ok(JSON.parse(json));
  } catch (e) {
    return new Err('Invalid JSON');
  }
};

const validateAge = (user) => {
  return user.age >= 18 
    ? new Ok(user) 
    : new Err('User must be 18 or older');
};

const saveToDb = (user) => {
  // Simulated DB operation
  return Math.random() > 0.1 
    ? new Ok({ id: 123, ...user }) 
    : new Err('Database connection failed');
};

// Composing operations - stops at first error
const processUser = (json) => {
  return parseUser(json)
    .flatMap(validateAge)
    .flatMap(saveToDb);
};

const result = processUser('{"name":"Alice","age":25}');
// Ok({ id: 123, name: 'Alice', age: 25 }) or Err('...')
```

**Parallel composition with error accumulation:**

```javascript
// Validation type that accumulates errors
class Valid {
  constructor(value) { this.value = value; }
  static of(value) { return new Valid(value); }
}

class Invalid {
  constructor(errors) { this.errors = Array.isArray(errors) ? errors : [errors]; }
  static of(error) { return new Invalid([error]); }
}

// Applicative combination
const combine = (v1, v2, f) => {
  if (v1 instanceof Valid && v2 instanceof Valid) {
    return new Valid(f(v1.value, v2.value));
  }
  if (v1 instanceof Invalid && v2 instanceof Invalid) {
    return new Invalid([...v1.errors, ...v2.errors]);
  }
  return v1 instanceof Invalid ? v1 : v2;
};

// Validation functions
const validateName = (name) => 
  name && name.length >= 2 
    ? new Valid(name) 
    : Invalid.of('Name must be at least 2 characters');

const validateEmail = (email) => 
  email && email.includes('@') 
    ? new Valid(email) 
    : Invalid.of('Invalid email format');

const validateAge = (age) => 
  age >= 18 
    ? new Valid(age) 
    : Invalid.of('Must be 18 or older');

// Accumulating all validation errors
const validateUser = (name, email, age) => {
  const nameV = validateName(name);
  const emailV = validateEmail(email);
  const ageV = validateAge(age);
  
  return combine(
    combine(nameV, emailV, (n, e) => ({ name: n, email: e })),
    ageV,
    (user, a) => ({ ...user, age: a })
  );
};

const result = validateUser('A', 'invalid', 15);
// Invalid(['Name must be at least 2 characters', 'Invalid email format', 'Must be 18 or older'])
```

**Railway-oriented programming:**

```javascript
// Using Either for railway-oriented error handling
const divide = (a, b) => 
  b === 0 ? new Err('Division by zero') : new Ok(a / b);

const sqrt = (n) => 
  n < 0 ? new Err('Cannot take square root of negative number') : new Ok(Math.sqrt(n));

const pipeline = (a, b) => 
  divide(a, b)
    .flatMap(sqrt)
    .map(result => result * 2);

console.log(pipeline(16, 4)); // Ok(4)
console.log(pipeline(16, 0)); // Err('Division by zero')
console.log(pipeline(-16, 4)); // Err('Cannot take square root of negative number')
```

**Error recovery and fallback:**

```javascript
// Recovering from errors
const fetchUserFromPrimary = (id) => 
  Math.random() > 0.5 ? new Ok({ id, source: 'primary' }) : new Err('Primary DB down');

const fetchUserFromCache = (id) => 
  new Ok({ id, source: 'cache' });

const getUser = (id) => {
  const result = fetchUserFromPrimary(id);
  return result instanceof Err 
    ? fetchUserFromCache(id) 
    : result;
};

// Or using an orElse combinator
class Result {
  orElse(alternative) {
    return this instanceof Ok ? this : alternative();
  }
}

const getUser2 = (id) => 
  fetchUserFromPrimary(id).orElse(() => fetchUserFromCache(id));
```

**Considerations:**

- [Inference] Choose between fail-fast (Either/Result) and accumulation (Validation) based on whether you need all errors or just the first one
- Type signatures become more verbose but provide explicit documentation of failure modes
- Requires consistent use throughout the codebase to avoid mixing exceptions with Result types
- Performance overhead is minimal but exists due to wrapper object allocation
- [Inference] Error accumulation works best for independent validations; dependent validations still need sequential composition

---

