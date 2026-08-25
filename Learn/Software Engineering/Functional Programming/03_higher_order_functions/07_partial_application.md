## Partial Application


Partial application is the technique of fixing a number of arguments to a function, producing another function of smaller arity. It transforms a function of multiple parameters into a sequence of functions, each taking fewer parameters until all are satisfied.

### Basic Partial Application

**Manual Implementation:**

```javascript
const add = (a, b, c) => a + b + c;

const addFive = (b, c) => add(5, b, c);
addFive(3, 2); // 10

const addFiveAndThree = (c) => add(5, 3, c);
addFiveAndThree(2); // 10
```

**Generic Partial Function:**

```javascript
const partial = (fn, ...fixedArgs) => {
  return (...remainingArgs) => {
    return fn(...fixedArgs, ...remainingArgs);
  };
};

const multiply = (a, b, c) => a * b * c;
const double = partial(multiply, 2);
double(3, 4); // 24

const triple = partial(multiply, 3);
const tripleAndFour = partial(triple, 4);
tripleAndFour(5); // 60
```

### Partial vs Currying

Partial application and currying are related but distinct:

```javascript
// Currying: transform to unary functions
const curriedAdd = (a) => (b) => (c) => a + b + c;
curriedAdd(1)(2)(3); // 6

// Partial: fix some arguments
const partialAdd = partial(add, 1);
partialAdd(2, 3); // 6

// Curried allows partial at each step
const curriedPartial = curriedAdd(1); // fix first
curriedPartial(2)(3); // 6
```

### Advanced Partial Application

**Partial from Right:**

```javascript
const partialRight = (fn, ...fixedArgs) => {
  return (...remainingArgs) => {
    return fn(...remainingArgs, ...fixedArgs);
  };
};

const divide = (a, b) => a / b;
const divideByTwo = partialRight(divide, 2);
divideByTwo(10); // 5
```

**Placeholder Support:**

```javascript
const _ = Symbol('placeholder');

const partialWithPlaceholder = (fn, ...args) => {
  return (...restArgs) => {
    const allArgs = [...args];
    let restIndex = 0;
    
    for (let i = 0; i < allArgs.length; i++) {
      if (allArgs[i] === _) {
        allArgs[i] = restArgs[restIndex++];
      }
    }
    
    return fn(...allArgs, ...restArgs.slice(restIndex));
  };
};

const greet = (greeting, name, punctuation) => 
  `${greeting}, ${name}${punctuation}`;

const greetWithPlaceholder = partialWithPlaceholder(greet, 'Hello', _, '!');
greetWithPlaceholder('Alice'); // "Hello, Alice!"

const customGreet = partialWithPlaceholder(greet, _, 'Bob', '!');
customGreet('Hi'); // "Hi, Bob!"
```

### Practical Applications

**Event Handlers:**

```javascript
const handleClick = (id, event) => {
  console.log(`Button ${id} clicked`, event);
};

// Without partial
button1.addEventListener('click', (e) => handleClick('btn1', e));
button2.addEventListener('click', (e) => handleClick('btn2', e));

// With partial
button1.addEventListener('click', partial(handleClick, 'btn1'));
button2.addEventListener('click', partial(handleClick, 'btn2'));
```

**Configuration:**

```javascript
const fetchFromAPI = (baseURL, endpoint, options) => {
  return fetch(`${baseURL}${endpoint}`, options);
};

const fetchFromMyAPI = partial(fetchFromAPI, 'https://api.example.com');
const fetchUsers = partial(fetchFromMyAPI, '/users');

fetchUsers({ method: 'GET' });
```

**Array Methods:**

```javascript
const map = (fn, array) => array.map(fn);
const filter = (predicate, array) => array.filter(predicate);

const double = (x) => x * 2;
const isEven = (x) => x % 2 === 0;

const mapDouble = partial(map, double);
const filterEven = partial(filter, isEven);

mapDouble([1, 2, 3]); // [2, 4, 6]
filterEven([1, 2, 3, 4]); // [2, 4]
```

**Function Specialization:**

```javascript
const log = (level, timestamp, message) => {
  console.log(`[${level}] ${timestamp}: ${message}`);
};

const logError = partial(log, 'ERROR');
const logErrorNow = partial(logError, new Date().toISOString());

logErrorNow('Database connection failed');
// [ERROR] 2024-01-15T10:30:00.000Z: Database connection failed
```

### Partial Application with Methods

**Binding Context:**

```javascript
const partialMethod = (obj, methodName, ...fixedArgs) => {
  return (...remainingArgs) => {
    return obj[methodName](...fixedArgs, ...remainingArgs);
  };
};

const user = {
  name: 'Alice',
  greet(greeting, punctuation) {
    return `${greeting}, I'm ${this.name}${punctuation}`;
  }
};

const userGreetHello = partialMethod(user, 'greet', 'Hello');
userGreetHello('!'); // "Hello, I'm Alice!"
```

### Composition with Partial Application

**Building Pipelines:**

```javascript
const add = (a, b) => a + b;
const multiply = (a, b) => a * b;
const power = (base, exp) => Math.pow(base, exp);

const addFive = partial(add, 5);
const multiplyByThree = partial(multiply, 3);
const square = partial(power, _, 2);

const transform = pipe(
  addFive,
  multiplyByThree,
  square
);

transform(2); // ((2 + 5) * 3)² = 441
```

**Factory Pattern:**

```javascript
const createValidator = (type, min, max, value) => {
  const validators = {
    number: (v) => typeof v === 'number' && v >= min && v <= max,
    string: (v) => typeof v === 'string' && v.length >= min && v.length <= max
  };
  return validators[type](value);
};

const validateAge = partial(createValidator, 'number', 0, 120);
const validateUsername = partial(createValidator, 'string', 3, 20);

validateAge(25); // true
validateUsername('alice'); // true
validateUsername('ab'); // false
```

### Performance Considerations

**Memoization with Partial:**

```javascript
const memoizedPartial = (fn, ...fixedArgs) => {
  const cache = new Map();
  
  return (...remainingArgs) => {
    const key = JSON.stringify(remainingArgs);
    if (cache.has(key)) {
      return cache.get(key);
    }
    const result = fn(...fixedArgs, ...remainingArgs);
    cache.set(key, result);
    return result;
  };
};

const expensiveCalculation = (multiplier, base, exponent) => {
  console.log('Calculating...');
  return multiplier * Math.pow(base, exponent);
};

const calculateWithTwo = memoizedPartial(expensiveCalculation, 2);
calculateWithTwo(3, 4); // Calculating... 162
calculateWithTwo(3, 4); // 162 (from cache)
```

**Key Points:**

- Partial application reduces function arity progressively
- Differs from currying: partial takes multiple args, currying always takes one
- Enables code reuse through function specialization
- Natural fit for callbacks and event handlers
- Placeholder support increases flexibility
- Combines naturally with composition and pipelines
- Creates intermediate functions that can be named and reused
- Essential for point-free programming style

