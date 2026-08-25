## Currying


Currying is the transformation of a function with multiple arguments into a sequence of functions, each taking a single argument. Named after mathematician Haskell Curry, it converts a function `f(a, b, c)` into `f(a)(b)(c)`.

### Transformation Mechanics

A curried function doesn't take all arguments at once. Instead, it takes the first argument and returns a new function that takes the next argument, and so on, until all arguments are provided.

```javascript
// Non-curried
const add = (a, b, c) => a + b + c;
add(1, 2, 3); // 6

// Curried
const curriedAdd = a => b => c => a + b + c;
curriedAdd(1)(2)(3); // 6
```

### Auto-Currying Implementation

```javascript
const curry = (fn) => {
  return function curried(...args) {
    if (args.length >= fn.length) {
      return fn.apply(this, args);
    }
    return (...nextArgs) => curried(...args, ...nextArgs);
  };
};

const multiply = (a, b, c) => a * b * c;
const curriedMultiply = curry(multiply);

curriedMultiply(2)(3)(4);        // 24
curriedMultiply(2, 3)(4);        // 24
curriedMultiply(2)(3, 4);        // 24
```

### Practical Applications

**Configuration Builders**

```javascript
const createLogger = level => prefix => message => 
  console[level](`[${prefix}] ${message}`);

const errorLogger = createLogger('error');
const appErrorLogger = errorLogger('APP');
const dbErrorLogger = errorLogger('DATABASE');

appErrorLogger('Connection failed');  // [APP] Connection failed
dbErrorLogger('Query timeout');       // [DATABASE] Query timeout
```

**Data Processing Pipelines**

```javascript
const map = fn => array => array.map(fn);
const filter = predicate => array => array.filter(predicate);

const double = x => x * 2;
const isEven = x => x % 2 === 0;

const doubleEvens = array => map(double)(filter(isEven)(array));
doubleEvens([1, 2, 3, 4, 5, 6]); // [4, 8, 12]
```

### Composition Benefits

Currying enables pointfree style and function composition:

```javascript
const compose = (...fns) => x => fns.reduceRight((v, f) => f(v), x);

const addTax = rate => price => price * (1 + rate);
const discount = percentage => price => price * (1 - percentage);
const formatPrice = price => `$${price.toFixed(2)}`;

const finalPrice = compose(
  formatPrice,
  addTax(0.08),
  discount(0.1)
);

finalPrice(100); // "$97.20"
```

### Language Support

**Haskell** - All functions are curried by default:

```haskell
add :: Int -> Int -> Int -> Int
add x y z = x + y + z

add 1 2 3        -- 6
(add 1) 2 3      -- 6
((add 1) 2) 3    -- 6
```

**JavaScript/TypeScript** - Manual implementation required or libraries like Ramda:

```javascript
import { curry } from 'ramda';

const greet = curry((greeting, name) => `${greeting}, ${name}!`);
const sayHello = greet('Hello');
sayHello('Alice'); // "Hello, Alice!"
```

**Key Points:**

- Transforms multi-argument functions into unary function chains
- Enables partial application at each step
- Facilitates composition and reusability
- Creates specialized functions from general ones

---

