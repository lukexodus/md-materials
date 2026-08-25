## Higher-Order Functions and Pure Functions


### Understanding Higher-Order Functions

Higher-order functions are functions that either take one or more functions as arguments, return a function as their result, or both. This concept is fundamental to functional programming and enables powerful abstractions and composition patterns in JavaScript and other languages.

**Key Points:**

- Functions are treated as first-class citizens in JavaScript
- Enable function composition and transformation
- Create abstraction layers for operations on data
- Provide a foundation for many functional programming patterns
- Allow for more modular and reusable code

### Characteristics of Higher-Order Functions

Higher-order functions operate on or with other functions. They typically:

- Accept functions as parameters
- Return functions as values
- May transform the input functions
- Create closures to preserve state
- Enable partial application or currying

### Common Built-in Higher-Order Functions in JavaScript

#### Array Methods

JavaScript arrays provide several built-in higher-order functions:

```javascript
// map - transforms each element
const numbers = [1, 2, 3, 4, 5];
const doubled = numbers.map(num => num * 2);
// doubled: [2, 4, 6, 8, 10]

// filter - selects elements based on a predicate
const even = numbers.filter(num => num % 2 === 0);
// even: [2, 4]

// reduce - accumulates values
const sum = numbers.reduce((acc, num) => acc + num, 0);
// sum: 15

// forEach - performs an action for each element
numbers.forEach(num => console.log(num));

// find - returns first matching element
const firstEven = numbers.find(num => num % 2 === 0);
// firstEven: 2

// some/every - check conditions
const hasEven = numbers.some(num => num % 2 === 0); // true
const allPositive = numbers.every(num => num > 0); // true
```

#### Function Manipulation

```javascript
// setTimeout is a higher-order function
setTimeout(() => console.log('Delayed execution'), 1000);

// Event listeners
document.getElementById('button').addEventListener('click', () => {
  console.log('Button clicked');
});
```

### Creating Higher-Order Functions

#### Function Composition

```javascript
// Compose two functions
const compose = (f, g) => x => f(g(x));

const addOne = x => x + 1;
const double = x => x * 2;

const addOneThenDouble = compose(double, addOne);
console.log(addOneThenDouble(3)); // (3 + 1) * 2 = 8

// Compose multiple functions (right to left)
const composeMultiple = (...fns) => x => 
  fns.reduceRight((acc, fn) => fn(acc), x);

// Pipe (left to right composition)
const pipe = (...fns) => x => 
  fns.reduce((acc, fn) => fn(acc), x);
```

#### Higher-Order Functions for Transformation

```javascript
// Function that creates a logging wrapper
const withLogging = fn => {
  return function(...args) {
    console.log(`Calling function with args: ${args}`);
    const result = fn(...args);
    console.log(`Function returned: ${result}`);
    return result;
  };
};

const add = (a, b) => a + b;
const loggedAdd = withLogging(add);

loggedAdd(2, 3);
// Logs:
// Calling function with args: 2,3
// Function returned: 5
```

#### Partial Application and Currying

```javascript
// Partial application: pre-filling some arguments
const partial = (fn, ...presetArgs) => {
  return function(...laterArgs) {
    return fn(...presetArgs, ...laterArgs);
  };
};

const add = (a, b, c) => a + b + c;
const add5 = partial(add, 5);
console.log(add5(10, 15)); // 5 + 10 + 15 = 30

// Currying: transforming a function with multiple arguments
// into a sequence of functions each with a single argument
const curry = (fn) => {
  const arity = fn.length;
  
  return function curried(...args) {
    if (args.length >= arity) {
      return fn(...args);
    }
    
    return function(...moreArgs) {
      return curried(...args, ...moreArgs);
    };
  };
};

const curriedAdd = curry((a, b, c) => a + b + c);
console.log(curriedAdd(1)(2)(3)); // 6
```

#### Memoization

```javascript
// Memoization for caching function results
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

const expensiveCalculation = (n) => {
  console.log(`Computing for ${n}...`);
  return n * n;
};

const memoizedCalc = memoize(expensiveCalculation);

console.log(memoizedCalc(4)); // Computing for 4... 16
console.log(memoizedCalc(4)); // 16 (from cache)
```

### Advanced Higher-Order Function Patterns

#### Function Decorators

```javascript
// Retry function execution
const withRetry = (fn, maxAttempts = 3, delay = 500) => {
  return async function(...args) {
    let attempts = 0;
    while (attempts < maxAttempts) {
      try {
        return await fn(...args);
      } catch (error) {
        attempts++;
        if (attempts >= maxAttempts) throw error;
        console.log(`Attempt ${attempts} failed, retrying...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  };
};

const fetchData = async (url) => {
  const response = await fetch(url);
  if (!response.ok) throw new Error('Request failed');
  return response.json();
};

const reliableFetch = withRetry(fetchData);
```

#### Function Throttling and Debouncing

```javascript
// Throttle: limits how often a function can be called
const throttle = (fn, limit) => {
  let throttling = false;
  
  return function(...args) {
    if (!throttling) {
      throttling = true;
      fn.apply(this, args);
      
      setTimeout(() => {
        throttling = false;
      }, limit);
    }
  };
};

// Debounce: delays execution until after a quiet period
const debounce = (fn, delay) => {
  let timeoutId;
  
  return function(...args) {
    clearTimeout(timeoutId);
    
    timeoutId = setTimeout(() => {
      fn.apply(this, args);
    }, delay);
  };
};

// Usage examples
const handleScroll = () => console.log('Scrolled');
const efficientScroll = throttle(handleScroll, 300);

const handleSearch = (query) => console.log(`Searching for: ${query}`);
const debouncedSearch = debounce(handleSearch, 500);
```

#### Function Combinators

```javascript
// Combinators are higher-order functions that combine functions in various ways
const identity = x => x;
const constant = x => () => x;

// Flip argument order
const flip = fn => (a, b) => fn(b, a);

// Apply a function to arguments conditionally
const unless = (predicate, fn) => 
  (...args) => predicate(...args) ? identity(...args) : fn(...args);

// Conditionally choose between two functions
const ifElse = (predicate, onTrue, onFalse) => 
  (...args) => predicate(...args) ? onTrue(...args) : onFalse(...args);

// Usage
const divide = (a, b) => a / b;
const flippedDivide = flip(divide);

console.log(divide(10, 2)); // 5
console.log(flippedDivide(10, 2)); // 0.2

const increment = x => x + 1;
const incrementUnlessZero = unless(x => x === 0, increment);

console.log(incrementUnlessZero(5)); // 6
console.log(incrementUnlessZero(0)); // 0
```

### Pure Functions

Pure functions are a core concept in functional programming that complement higher-order functions.

### Understanding Pure Functions

Pure functions are functions that:

1. Given the same inputs, always return the same output
2. Produce no side effects
3. Rely only on their input parameters and not on external state

**Key Points:**

- Predictable behavior with guaranteed outputs for given inputs
- No mutations of input parameters
- No external state modifications
- No dependency on external mutable state
- No I/O operations within the function

### Benefits of Pure Functions

- **Predictability**: Same input always yields same output
- **Testability**: Easy to test without mocks or complex setup
- **Memoization**: Results can be cached since outputs only depend on inputs
- **Parallelization**: Can be executed in parallel without conflicts
- **Reasoning**: Simpler to understand and reason about
- **Reusability**: Can be composed with other pure functions safely

### Examples of Pure Functions

```javascript
// Pure function
function add(a, b) {
  return a + b;
}

// Pure function
function calculateTax(amount, rate) {
  return amount * rate;
}

// Pure function (creates new array)
function appendToArray(array, item) {
  return [...array, item];
}

// Pure function with object (creates new object)
function updateProperty(obj, key, value) {
  return { ...obj, [key]: value };
}
```

### Examples of Impure Functions

```javascript
// Impure: depends on external state
let counter = 0;
function incrementCounter() {
  counter++;
  return counter;
}

// Impure: modifies input parameter
function addToArray(array, item) {
  array.push(item); // Mutates the original array
  return array;
}

// Impure: uses random values
function getRandomNumber() {
  return Math.random();
}

// Impure: side effects (I/O)
function logMessage(message) {
  console.log(message);
}

// Impure: depends on the current time
function getCurrentHour() {
  return new Date().getHours();
}
```

### Converting Impure to Pure Functions

```javascript
// Impure
let total = 0;
function addToTotal(value) {
  total += value;
  return total;
}

// Pure version
function addToTotal(currentTotal, value) {
  return currentTotal + value;
}

// Impure
function processUser(user) {
  user.lastLogin = new Date();
  user.loginCount++;
  return user;
}

// Pure version
function processUser(user) {
  return {
    ...user,
    lastLogin: new Date(),
    loginCount: (user.loginCount || 0) + 1
  };
}

// Impure
function fetchUserData(userId) {
  return fetch(`/api/users/${userId}`).then(r => r.json());
}

// Purer version (injects dependencies)
function createFetchUserData(httpClient) {
  return function(userId) {
    return httpClient(`/api/users/${userId}`).then(r => r.json());
  };
}
```

### Working with Side Effects

Real applications need side effects (I/O, DOM manipulation, etc.). We can handle them in a more controlled way:

```javascript
// Separate pure and impure parts
function calculateTotalWithTax(items) {
  // Pure calculation
  return items.reduce((sum, item) => sum + item.price, 0) * 1.08;
}

// Impure wrapper that handles side effects
function displayTotal(items) {
  const total = calculateTotalWithTax(items);
  // Side effect
  document.getElementById('total').textContent = `$${total.toFixed(2)}`;
}

// Push side effects to the boundaries
function processPurchase(user, items) {
  // Pure functions
  const total = calculateTotalWithTax(items);
  const updatedUser = updateUserBalance(user, total);
  const receipt = generateReceipt(user, items, total);
  
  // Side effects at boundaries
  saveUserToDatabase(updatedUser);
  sendReceiptEmail(receipt);
  updateUI(updatedUser, receipt);
  
  return {
    user: updatedUser,
    receipt
  };
}
```

### Property-Based Testing with Pure Functions

Pure functions are ideal for property-based testing:

```javascript
// Using a library like fast-check or jsverify
test('reversing a string twice returns the original string', () => {
  fc.assert(
    fc.property(fc.string(), str => {
      const reversed = reverseString(str);
      const reversedTwice = reverseString(reversed);
      return str === reversedTwice;
    })
  );
});

test('sorting is idempotent', () => {
  fc.assert(
    fc.property(fc.array(fc.integer()), arr => {
      const sorted = sortArray(arr);
      const sortedTwice = sortArray(sorted);
      return arraysEqual(sorted, sortedTwice);
    })
  );
});
```

### Pure Function Composition

Pure functions compose particularly well:

```javascript
// All pure functions
const add = (a, b) => a + b;
const multiply = (a, b) => a * b;
const square = x => x * x;
const addThenSquare = x => square(add(x, 10));

// Composing multiple pure functions
const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

const processNumber = pipe(
  x => add(x, 10),
  square,
  x => multiply(x, 2)
);

console.log(processNumber(5)); // ((5 + 10)² * 2) = 450
```

### Combining Higher-Order Functions and Pure Functions

Higher-order functions often return pure functions, creating powerful patterns:

```javascript
// Higher-order function returning a pure function
const createMultiplier = factor => number => number * factor;

const double = createMultiplier(2);
const triple = createMultiplier(3);

console.log(double(5)); // 10
console.log(triple(5)); // 15

// Composition with pure functions
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);

const addTax = rate => price => price * (1 + rate);
const applyDiscount = discount => price => price * (1 - discount);
const formatPrice = price => `$${price.toFixed(2)}`;

const calculateFinalPrice = compose(
  formatPrice,
  addTax(0.08),
  applyDiscount(0.1)
);

console.log(calculateFinalPrice(100)); // $97.20
```

### Functional Error Handling

Pure functions can handle errors elegantly:

```javascript
// Using Option/Maybe pattern
const Maybe = {
  just: value => ({
    map: fn => Maybe.just(fn(value)),
    flatMap: fn => fn(value),
    getOrElse: () => value,
    isNothing: () => false,
    toString: () => `Just(${value})`
  }),
  nothing: () => ({
    map: () => Maybe.nothing(),
    flatMap: () => Maybe.nothing(),
    getOrElse: defaultValue => defaultValue,
    isNothing: () => true,
    toString: () => 'Nothing'
  }),
  fromValue: value => 
    value === null || value === undefined ? Maybe.nothing() : Maybe.just(value)
};

// Using Either pattern for more explicit errors
const Either = {
  right: value => ({
    map: fn => Either.right(fn(value)),
    flatMap: fn => fn(value),
    getOrElse: () => value,
    isLeft: () => false,
    toString: () => `Right(${value})`
  }),
  left: error => ({
    map: () => Either.left(error),
    flatMap: () => Either.left(error),
    getOrElse: defaultValue => defaultValue,
    isLeft: () => true,
    toString: () => `Left(${error})`
  })
};

// Division that handles errors
const safeDivide = (a, b) => 
  b === 0 ? Either.left('Division by zero') : Either.right(a / b);

// Usage
const result = safeDivide(10, 2)
  .map(result => result * 2)
  .getOrElse('Error occurred');

console.log(result); // 10

const errorResult = safeDivide(10, 0)
  .map(result => result * 2)
  .getOrElse('Error occurred');

console.log(errorResult); // Error occurred
```

### Real-World Example: Data Processing Pipeline

Combining pure and higher-order functions for data processing:

```javascript
// Sample data
const orders = [
  { id: 1, customer: 'john', items: [{ product: 'Book', price: 10 }, { product: 'Pen', price: 5 }], status: 'completed' },
  { id: 2, customer: 'alice', items: [{ product: 'Laptop', price: 1000 }], status: 'pending' },
  { id: 3, customer: 'bob', items: [{ product: 'Headphones', price: 100 }, { product: 'Mouse', price: 25 }], status: 'completed' }
];

// Pure functions for data processing
const isCompleted = order => order.status === 'completed';
const calculateOrderTotal = order => order.items.reduce((sum, item) => sum + item.price, 0);
const addTax = (amount, rate = 0.08) => amount * (1 + rate);
const formatCurrency = amount => `$${amount.toFixed(2)}`;

// Higher-order function for analysis
const analyzeOrders = (orders, filterFn) => {
  const filteredOrders = orders.filter(filterFn);
  
  const orderTotals = filteredOrders.map(order => ({
    id: order.id,
    customer: order.customer,
    total: calculateOrderTotal(order),
    totalWithTax: addTax(calculateOrderTotal(order))
  }));
  
  const grandTotal = orderTotals.reduce((sum, order) => sum + order.total, 0);
  const grandTotalWithTax = orderTotals.reduce((sum, order) => sum + order.totalWithTax, 0);
  
  return {
    orders: orderTotals,
    count: orderTotals.length,
    grandTotal,
    grandTotalWithTax,
    formattedGrandTotal: formatCurrency(grandTotal),
    formattedGrandTotalWithTax: formatCurrency(grandTotalWithTax)
  };
};

// Usage
const completedOrdersAnalysis = analyzeOrders(orders, isCompleted);
console.log(completedOrdersAnalysis);
/*
{
  orders: [
    { id: 1, customer: 'john', total: 15, totalWithTax: 16.2 },
    { id: 3, customer: 'bob', total: 125, totalWithTax: 135 }
  ],
  count: 2,
  grandTotal: 140,
  grandTotalWithTax: 151.2,
  formattedGrandTotal: '$140.00',
  formattedGrandTotalWithTax: '$151.20'
}
*/
```

### Performance Considerations

When working with pure and higher-order functions:

- Be mindful of recursive function calls and stack limits
- Consider memoization for expensive pure functions
- Avoid excessive object creation in hot code paths
- Use transducers for optimized compositions of map/filter/reduce operations
- Consider specialized data structures like Immutable.js for pure operations on large datasets

### Best Practices

- Keep functions small and focused on a single task
- Document the expected inputs and outputs clearly
- Use meaningful names that describe what the function does
- Consider using TypeScript or JSDoc for better type safety
- Avoid deeply nested higher-order functions that become hard to read
- Use linters and static analysis tools to enforce pure function practices
- Write tests to validate the purity of your functions

**Conclusion:** Higher-order functions and pure functions form the backbone of functional programming in JavaScript. Higher-order functions enable powerful abstractions, composition, and transformations, while pure functions provide predictability, testability, and reasoning benefits. By combining these concepts, developers can create more maintainable, reusable, and robust code. The composability of these functions allows for building complex behavior from simple building blocks, leading to cleaner and more expressive code. As functional programming continues to influence modern JavaScript development, mastering these concepts becomes increasingly valuable for building scalable and maintainable applications.

Consider exploring functional programming libraries like Ramda or functional data structures like Immutable.js to further enhance your functional programming practices in JavaScript.

---

