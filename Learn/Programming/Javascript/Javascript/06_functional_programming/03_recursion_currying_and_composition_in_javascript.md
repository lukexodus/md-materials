## Recursion, Currying, and Composition in JavaScript


### Understanding Recursion

Recursion is a programming technique where a function calls itself to solve a problem. In JavaScript, recursive functions are powerful tools for tasks that can be broken down into similar sub-problems.

**Key Points**:

- A recursive function must have a base case to prevent infinite recursion
- Each recursive call should work on a smaller subset of the original problem
- Recursion can often replace complex iteration
- JavaScript has a call stack limit (typically around 10,000), beyond which you'll get a stack overflow error

### Implementing Recursion

A classic example of recursion is calculating factorial:

```javascript
function factorial(n) {
  // Base case
  if (n <= 1) {
    return 1;
  }
  
  // Recursive case
  return n * factorial(n - 1);
}

console.log(factorial(5)); // 120 (5 * 4 * 3 * 2 * 1)
```

Recursive functions are particularly elegant for traversing hierarchical data structures like trees:

```javascript
function traverseTree(node) {
  // Process current node
  console.log(node.value);
  
  // Base case: no children
  if (!node.children || node.children.length === 0) {
    return;
  }
  
  // Recursive case: process each child
  node.children.forEach(child => traverseTree(child));
}

const tree = {
  value: 'root',
  children: [
    {
      value: 'child1',
      children: [
        { value: 'grandchild1', children: [] },
        { value: 'grandchild2', children: [] }
      ]
    },
    {
      value: 'child2',
      children: []
    }
  ]
};

traverseTree(tree);
```

### Tail Call Optimization

A special form of recursion called tail recursion can prevent stack overflow issues:

```javascript
function factorialTail(n, accumulator = 1) {
  // Base case
  if (n <= 1) {
    return accumulator;
  }
  
  // Tail recursive call - the result doesn't need further processing
  return factorialTail(n - 1, n * accumulator);
}

console.log(factorialTail(5)); // 120

// Note: While this is proper tail recursion, JavaScript engines
// (except Safari) don't automatically optimize tail calls despite
// ECMAScript 6 specifying that they should
```

### Understanding Currying

Currying transforms a function with multiple arguments into a sequence of functions, each taking a single argument. This technique is named after mathematician Haskell Curry.

**Key Points**:

- Currying creates a chain of functions, each accepting one argument
- It enables partial application of functions
- Curried functions are highly composable
- It helps create reusable function templates

### Implementing Currying

```javascript
// Regular function with multiple arguments
function add(x, y, z) {
  return x + y + z;
}

// Curried version
function curriedAdd(x) {
  return function(y) {
    return function(z) {
      return x + y + z;
    };
  };
}

// Using the curried function
console.log(add(1, 2, 3)); // 6
console.log(curriedAdd(1)(2)(3)); // 6

// With arrow functions (more concise)
const arrowCurriedAdd = x => y => z => x + y + z;
console.log(arrowCurriedAdd(1)(2)(3)); // 6

// Partial application
const addOne = curriedAdd(1);
const addOneAndTwo = addOne(2);
console.log(addOneAndTwo(3)); // 6
```

### Generic Curry Function

Creating a curry function that works with any function:

```javascript
function curry(fn) {
  return function curried(...args) {
    // If we have enough arguments, call the original function
    if (args.length >= fn.length) {
      return fn.apply(this, args);
    }
    
    // Otherwise, return a function that collects more arguments
    return function(...moreArgs) {
      return curried.apply(this, args.concat(moreArgs));
    };
  };
}

// Example usage:
function multiply(a, b, c) {
  return a * b * c;
}

const curriedMultiply = curry(multiply);

console.log(curriedMultiply(2)(3)(4)); // 24
console.log(curriedMultiply(2, 3)(4)); // 24
console.log(curriedMultiply(2)(3, 4)); // 24
console.log(curriedMultiply(2, 3, 4)); // 24
```

### Real-World Currying Applications

```javascript
// Event handling with currying
function handleEvent(eventType) {
  return function(element) {
    return function(callback) {
      element.addEventListener(eventType, callback);
      return function() {
        element.removeEventListener(eventType, callback);
      };
    };
  };
}

const onClick = handleEvent('click');
const onHover = handleEvent('mouseover');

// Usage:
// const btn = document.getElementById('myButton');
// const clickHandler = onClick(btn)((e) => console.log('clicked!', e));
// clickHandler(); // Remove the event listener

// Creating a configurable formatter
const formatter = locale => currency => value => 
  new Intl.NumberFormat(locale, {
    style: 'currency',
    currency
  }).format(value);

const formatUSD = formatter('en-US')('USD');
const formatEUR = formatter('de-DE')('EUR');

console.log(formatUSD(1234.56)); // $1,234.56
console.log(formatEUR(1234.56)); // 1.234,56 €

// Filter creator
const filterBy = property => value => array => 
  array.filter(item => item[property] === value);

const filterByColor = filterBy('color');
const filterRed = filterByColor('red');

const items = [
  { color: 'red', size: 'small' },
  { color: 'blue', size: 'medium' },
  { color: 'red', size: 'large' }
];

console.log(filterRed(items)); // [{ color: 'red', size: 'small' }, { color: 'red', size: 'large' }]
```

### Understanding Function Composition

Function composition is a technique where the output of one function becomes the input of another function. It's a fundamental concept in functional programming.

**Key Points**:

- Combines multiple functions into a single function
- Executes from right to left (in traditional mathematical notation)
- Creates pipelines of data transformation
- Enhances code reusability and readability
- Promotes the creation of small, focused functions

### Implementing Composition

```javascript
// Simple functions to compose
const double = x => x * 2;
const increment = x => x + 1;
const square = x => x * x;

// Manual composition
const manualComposition = x => square(increment(double(x)));

console.log(manualComposition(3)); // 49: square(increment(double(3))) = square(increment(6)) = square(7) = 49

// Creating a compose function (right-to-left execution)
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);

// Creating a pipeline (left-to-right execution)
const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

// Using the compose function
const composed = compose(square, increment, double);
console.log(composed(3)); // 49

// Using the pipe function (more intuitive order for some)
const piped = pipe(double, increment, square);
console.log(piped(3)); // 49
```

### Advanced Composition Techniques

```javascript
// Point-free style programming
const map = fn => array => array.map(fn);
const filter = predicate => array => array.filter(predicate);
const reduce = (reducer, initial) => array => array.reduce(reducer, initial);

// Creating specialized functions with composition
const sum = reduce((acc, val) => acc + val, 0);
const doubleAll = map(x => x * 2);
const getEvens = filter(x => x % 2 === 0);

// Composing them together
const sumOfDoubledEvens = pipe(
  getEvens,
  doubleAll,
  sum
);

console.log(sumOfDoubledEvens([1, 2, 3, 4, 5, 6])); // 24 (2+4+6 -> 4+8+12 -> 24)

// Handling multiple arguments with composition
const prop = key => obj => obj[key];
const propEq = (key, value) => obj => obj[key] === value;
const sortBy = key => array => [...array].sort((a, b) => {
  const valueA = typeof a[key] === 'string' ? a[key].toLowerCase() : a[key];
  const valueB = typeof b[key] === 'string' ? b[key].toLowerCase() : b[key];
  
  if (valueA < valueB) return -1;
  if (valueA > valueB) return 1;
  return 0;
});

// Working with objects
const people = [
  { name: 'Alice', age: 30, role: 'developer' },
  { name: 'Bob', age: 25, role: 'designer' },
  { name: 'Charlie', age: 35, role: 'developer' },
  { name: 'Diana', age: 28, role: 'manager' }
];

const getDevelopers = filter(propEq('role', 'developer'));
const sortByAge = sortBy('age');
const getNames = map(prop('name'));

const developerNamesByAge = pipe(
  getDevelopers,
  sortByAge,
  getNames
);

console.log(developerNamesByAge(people)); // ['Alice', 'Charlie']
```

### Combining Recursion, Currying, and Composition

These three techniques are powerful on their own, but they can be exceptionally powerful when combined:

```javascript
// Recursive function for deep tree traversal
const traverse = (visit) => {
  // Inner recursive function
  const inner = (tree) => {
    visit(tree);
    
    if (tree.children && tree.children.length > 0) {
      tree.children.forEach(inner);
    }
  };
  
  return inner;
};

// Function to transform a node
const transformNode = (transformer) => (node) => {
  return {
    ...node,
    value: transformer(node.value)
  };
};

// Specific transformers
const uppercase = str => typeof str === 'string' ? str.toUpperCase() : str;
const addExclamation = str => typeof str === 'string' ? `${str}!` : str;

// Compose transformers
const emphasize = compose(addExclamation, uppercase);

// Create visitor function
const logValue = node => console.log(node.value);

// Define tree
const tree = {
  value: 'hello',
  children: [
    {
      value: 'world',
      children: [
        { value: 'this', children: [] },
        { value: 'is', children: [] }
      ]
    },
    {
      value: 'amazing',
      children: []
    }
  ]
};

// Use composition to create our traversal function
const processTree = pipe(
  transformNode(emphasize),  // First transform the node
  logValue                   // Then log its value
);

// Traverse the tree with our composed processor
const traverseWithProcessor = traverse(processTree);
traverseWithProcessor(tree);

// Output:
// HELLO!
// WORLD!
// THIS!
// IS!
// AMAZING!

// Let's add currying to the mix for a flexible sum function
const sumCurried = (reducer) => (initial) => {
  const recursiveSum = (array, index = 0, accumulator = initial) => {
    // Base case
    if (index >= array.length) {
      return accumulator;
    }
    
    // Recursive case
    const newAccumulator = reducer(accumulator, array[index], index, array);
    return recursiveSum(array, index + 1, newAccumulator);
  };
  
  return recursiveSum;
};

// Create specific sum functions
const simpleSum = sumCurried((acc, val) => acc + val)(0);
const sumOfSquares = sumCurried((acc, val) => acc + val * val)(0);
const sumOfEvenDoubles = sumCurried((acc, val) => acc + (val % 2 === 0 ? val * 2 : 0))(0);

console.log(simpleSum([1, 2, 3, 4])); // 10
console.log(sumOfSquares([1, 2, 3, 4])); // 30 (1+4+9+16)
console.log(sumOfEvenDoubles([1, 2, 3, 4])); // 12 (0+4+0+8)
```

### Performance Considerations

```javascript
// Memoization for recursive functions
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

// Fibonacci without memoization (very inefficient)
function fibonacci(n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}

// Fibonacci with memoization
const memoizedFibonacci = memoize(function(n) {
  if (n <= 1) return n;
  return memoizedFibonacci(n - 1) + memoizedFibonacci(n - 2);
});

// Timing comparison
console.time('Regular Fibonacci');
console.log(fibonacci(30));
console.timeEnd('Regular Fibonacci');

console.time('Memoized Fibonacci');
console.log(memoizedFibonacci(30));
console.timeEnd('Memoized Fibonacci');

// Optimizing composition with lazy evaluation
function lazyCompose(...fns) {
  return function(initialValue) {
    return fns.reduceRight((value, fn) => fn(value), initialValue);
  };
}

// Using an iterator for large data processing
function* mapGenerator(iterable, mapFn) {
  for (const item of iterable) {
    yield mapFn(item);
  }
}

function* filterGenerator(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

// Create a large array for demonstration
const largeArray = Array.from({ length: 1000000 }, (_, i) => i);

// Process only what we need using generators
function getFirstEvenSquareOver1Million() {
  const evenNumbers = filterGenerator(largeArray, x => x % 2 === 0);
  const squares = mapGenerator(evenNumbers, x => x * x);
  
  for (const square of squares) {
    if (square > 1000000) {
      return square;
    }
  }
}

console.time('First Even Square Over 1M');
console.log(getFirstEvenSquareOver1Million());
console.timeEnd('First Even Square Over 1M');
```

### Memory and Stack Limitations

```javascript
// Trampoline pattern to avoid stack overflow
function trampoline(fn) {
  return function trampolined(...args) {
    let result = fn(...args);
    
    while (typeof result === 'function') {
      result = result();
    }
    
    return result;
  };
}

// A function that would normally cause stack overflow
function recursiveCountDown(n) {
  if (n <= 0) {
    return 'Done!';
  }
  
  return () => recursiveCountDown(n - 1);
}

const safeCountDown = trampoline(recursiveCountDown);

// This won't overflow the stack
console.log(safeCountDown(10000)); // Done!

// Handling large data sets with chunking
function processLargeArray(array, processorFn, chunkSize = 1000) {
  return new Promise((resolve, reject) => {
    const results = [];
    let index = 0;
    
    function doChunk() {
      const chunk = array.slice(index, index + chunkSize);
      index += chunkSize;
      
      // Process this chunk
      try {
        const chunkResults = chunk.map(processorFn);
        results.push(...chunkResults);
        
        // Schedule next chunk or resolve
        if (index < array.length) {
          setTimeout(doChunk, 0); // Give back control to the event loop
        } else {
          resolve(results);
        }
      } catch (err) {
        reject(err);
      }
    }
    
    // Start processing
    doChunk();
  });
}

// Example use
// processLargeArray(Array(1000000).fill(1), x => x * 2)
//   .then(results => console.log('Processed', results.length, 'items'));

// Using iteration instead of recursion for large operations
function iterativeFactorial(n) {
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// Using worker threads for CPU-intensive operations
// In a real application, you would use Worker threads or Web Workers
function simulateWorker(data, processFn) {
  return new Promise(resolve => {
    // Simulate sending to a worker thread
    setTimeout(() => {
      const result = processFn(data);
      resolve(result);
    }, 0);
  });
}
```

### Practical Applications

```javascript
// Data processing pipeline
const processUserData = pipe(
  // Get users from a specific country
  filter(user => user.country === 'USA'),
  
  // Sort by age
  sortBy('age'),
  
  // Transform user format
  map(user => ({
    fullName: `${user.firstName} ${user.lastName}`,
    age: user.age,
    email: user.email
  })),
  
  // Keep only users over 18
  filter(user => user.age >= 18)
);

// Event handling with currying
const addEventToElements = eventType => selector => handler => {
  const elements = document.querySelectorAll(selector);
  elements.forEach(el => el.addEventListener(eventType, handler));
  
  // Return a function to clean up
  return () => {
    elements.forEach(el => el.removeEventListener(eventType, handler));
  };
};

const addClickHandler = addEventToElements('click');
const addHoverHandler = addEventToElements('mouseover');

// Usage example:
/*
const buttonClickHandler = addClickHandler('button.primary')(event => {
  console.log('Button clicked:', event.target.textContent);
});

// Later, to remove:
buttonClickHandler();
*/

// Functional form validation
const required = fieldName => value => 
  value ? null : `${fieldName} is required`;

const minLength = (fieldName, length) => value => 
  !value || value.length >= length ? null : `${fieldName} must be at least ${length} characters`;

const maxLength = (fieldName, length) => value => 
  !value || value.length <= length ? null : `${fieldName} cannot exceed ${length} characters`;

const validateEmail = fieldName => value => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return !value || emailRegex.test(value) ? null : `${fieldName} must be a valid email`;
};

// Combining validators
const combineValidators = (...validators) => value => {
  for (const validator of validators) {
    const error = validator(value);
    if (error) return error;
  }
  return null;
};

// Create specific field validators
const validateUsername = combineValidators(
  required('Username'),
  minLength('Username', 3),
  maxLength('Username', 20)
);

const validatePasswordField = combineValidators(
  required('Password'),
  minLength('Password', 8),
  maxLength('Password', 100)
);

const validateEmailField = combineValidators(
  required('Email'),
  validateEmail('Email')
);

// Usage example
console.log(validateUsername('')); // Username is required
console.log(validateUsername('ab')); // Username must be at least 3 characters
console.log(validateUsername('validusername')); // null (valid)

// Recursive directory walker implementation
/*
function walkDirectoryRecursive(dir, onFile, onDir) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  // Call onDir for current directory
  onDir && onDir(dir);
  
  // Process entries
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    
    if (entry.isDirectory()) {
      // Recursively walk subdirectory
      walkDirectoryRecursive(fullPath, onFile, onDir);
    } else if (entry.isFile()) {
      // Process file
      onFile && onFile(fullPath);
    }
  }
}
*/
```

### Integrating with Modern JavaScript Frameworks

```javascript
// React hooks that use these concepts

// Custom hook using recursion for deep object comparison
function useDeepCompare(value) {
  const ref = useRef();
  
  function deepCompare(obj1, obj2) {
    // Handle primitive types
    if (obj1 === obj2) return true;
    
    // Handle null/undefined cases
    if (obj1 == null || obj2 == null) return false;
    
    // Different types
    if (typeof obj1 !== typeof obj2) return false;
    
    // Handle arrays
    if (Array.isArray(obj1) && Array.isArray(obj2)) {
      if (obj1.length !== obj2.length) return false;
      return obj1.every((item, index) => deepCompare(item, obj2[index]));
    }
    
    // Handle objects
    if (typeof obj1 === 'object') {
      const keys1 = Object.keys(obj1);
      const keys2 = Object.keys(obj2);
      
      if (keys1.length !== keys2.length) return false;
      
      return keys1.every(key => 
        keys2.includes(key) && deepCompare(obj1[key], obj2[key])
      );
    }
    
    return false;
  }
  
  if (!deepCompare(value, ref.current)) {
    ref.current = value;
  }
  
  return ref.current;
}

// Function composition with Redux
import { createStore, applyMiddleware, compose } from 'redux';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import rootReducer from './reducers';

// Functional composition of middleware
const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;

const store = createStore(
  rootReducer,
  composeEnhancers(
    applyMiddleware(thunk, logger)
  )
);

// Currying with Redux action creators
const createAction = type => payload => ({ type, payload });

const addTodo = createAction('ADD_TODO');
const removeTodo = createAction('REMOVE_TODO');
const toggleTodo = createAction('TOGGLE_TODO');

// Usage:
// dispatch(addTodo({ text: 'Learn Redux', completed: false }));

// Functional composition with React components
// Higher-order components using composition
const withLogging = Component => props => {
  console.log('Rendering component with props:', props);
  return <Component {...props} />;
};

const withAuthentication = Component => props => {
  if (!props.isAuthenticated) {
    return <div>Please log in to view this content</div>;
  }
  return <Component {...props} />;
};

const withErrorBoundary = Component => {
  return class ErrorBoundary extends React.Component {
    state = { hasError: false };
    
    static getDerivedStateFromError() {
      return { hasError: true };
    }
    
    componentDidCatch(error, info) {
      console.error('Error caught in error boundary:', error, info);
    }
    
    render() {
      if (this.state.hasError) {
        return <div>Something went wrong!</div>;
      }
      return <Component {...this.props} />;
    }
  };
};

// Compose HOCs
const enhance = compose(
  withErrorBoundary,
  withAuthentication,
  withLogging
);

// Usage:
const EnhancedComponent = enhance(MyComponent);

// Using recursion in React for rendering nested components
function NestedList({ items }) {
  if (!items || items.length === 0) {
    return null;
  }
  
  return (
    <ul>
      {items.map((item, index) => (
        <li key={index}>
          {item.text}
          {item.children && <NestedList items={item.children} />}
        </li>
      ))}
    </ul>
  );
}

// Vue.js composable using currying and composition
// composables/useApiRequest.js
import { ref, computed } from 'vue';

export function useApiRequest(baseUrl) {
  // Curried function for endpoint specification
  return (endpoint) => {
    const data = ref(null);
    const error = ref(null);
    const loading = ref(false);
    
    // Curried function for HTTP method
    const request = (method) => (body = null) => {
      loading.value = true;
      error.value = null;
      
      const options = {
        method,
        headers: { 'Content-Type': 'application/json' }
      };
      
      if (body && ['POST', 'PUT', 'PATCH'].includes(method)) {
        options.body = JSON.stringify(body);
      }
      
      return fetch(`${baseUrl}${endpoint}`, options)
        .then(response => {
          if (!response.ok) {
            throw new Error(`HTTP error ${response.status}`);
          }
          return response.json();
        })
        .then(result => {
          data.value = result;
          return result;
        })
        .catch(err => {
          error.value = err.message;
          return null;
        })
        .finally(() => {
          loading.value = false;
        });
    };
    
    // Create specific HTTP method functions
    const get = request('GET');
    const post = request('POST');
    const put = request('PUT');
    const patch = request('PATCH');
    const del = request('DELETE');
    
    // Computed properties
    const hasData = computed(() => data.value !== null);
    const hasError = computed(() => error.value !== null);
    
    return {
      data,
      error,
      loading,
      hasData,
      hasError,
      get,
      post,
      put,
      patch,
      del
    };
  };
}

// Usage:
// const api = useApiRequest('https://api.example.com');
// const users = api('/users');
// users.get(); // Fetch users
// users.post({ name: 'John' }); // Create a user
```

### Functional Libraries

```javascript
// Popular functional programming libraries

// Using Ramda for composition and currying
import * as R from 'ramda';

// Currying with Ramda
const multiply = R.curry((a, b) => a * b);
const double = multiply(2);
console.log(double(4)); // 8

// Composition with Ramda
const shout = R.compose(
  R.toUpper,
  R.concat(R.__, '!'),
  R.replace(/\s+/g, ' ')
);

console.log(shout('hello  world')); // "HELLO WORLD!"

// Point-free style with Ramda
const isAdult = R.propSatisfies(R.gte(R.__, 18), 'age');
const getFullName = R.converge(
  R.unapply(R.join(' ')), 
  [R.prop('firstName'), R.prop('lastName')]
);

const getAdultNames = R.pipe(
  R.filter(isAdult),
  R.map(getFullName)
);

const people = [
  { firstName: 'John', lastName: 'Doe', age: 20 },
  { firstName: 'Jane', lastName: 'Smith', age: 15 },
  { firstName: 'Bob', lastName: 'Johnson', age: 25 }
];

console.log(getAdultNames(people)); // ['John Doe', 'Bob Johnson']

// Using Lodash/FP
import _ from 'lodash/fp';

// Currying and partial application
const greet = _.curry((greeting, name) => `${greeting}, ${name}!`);
const sayHello = greet('Hello');
console.log(sayHello('World')); // "Hello, World!"

// Composition
const process = _.flow(
  _.toLower,
  _.words,
  _.uniq,
  _.size
);

console.log(process('Hello Hello WORLD')); // 2 (unique words: "hello", "world")

// Working with collections
const getActiveTodoNames = _.flow(
  _.filter({active: true}),
  _.map('name'),
  _.sortBy(_.identity)
);

const todos = [
  { name: 'Write code', active: true },
  { name: 'Read docs', active: false },
  { name: 'Fix bugs', active: true }
];

console.log(getActiveTodoNames(todos)); // ['Fix bugs', 'Write code']

// Using RxJS for functional reactive programming
import { of, from } from 'rxjs';
import { map, filter, reduce, tap, mergeMap } from 'rxjs/operators';

// Creating observables
const numbers$ = of(1, 2, 3, 4, 5);

// Composing operations
const result$ = numbers$.pipe(
  tap(x => console.log('Processing:', x)),
  filter(x => x % 2 === 0),
  map(x => x * 10),
  reduce((acc, val) => acc + val, 0)
);

result$.subscribe(
  result => console.log('Result:', result),
  error => console.error('Error:', error),
  () => console.log('Complete!')
);
// Output:
// Processing: 1
// Processing: 2
// Processing: 3
// Processing: 4
// Processing: 5
// Result: 60 (20 + 40)
// Complete!

// Complex composition with RxJS
from(fetch('https://api.example.com/users').then(res => res.json()))
  .pipe(
    mergeMap(users => from(users)),
    filter(user => user.active),
    map(user => ({
      fullName: `${user.firstName} ${user.lastName}`,
      email: user.email
    })),
    tap(user => console.log(`Processing user: ${user.fullName}`))
  )
  .subscribe(
    user => saveUserToDatabase(user),
    error => logError(error),
    () => notifyComplete()
  );

// Using Immutable.js for functional data structures
import { List, Map } from 'immutable';

// Creating immutable data structures
const list = List([1, 2, 3, 4]);
const map = Map({ name: 'John', age: 30 });

// Functional operations
const newList = list
  .filter(x => x % 2 === 0)
  .map(x => x * 10);

console.log(newList.toJS()); // [20, 40]
console.log(list.toJS()); // Original is untouched: [1, 2, 3, 4]

// Functional updates
const newMap = map
  .set('age', 31)
  .update('name', name => name.toUpperCase());

console.log(newMap.toJS()); // { name: 'JOHN', age: 31 }
console.log(map.toJS()); // Original is untouched: { name: 'John', age: 30 }

// Using fp-ts for typed functional programming
import { pipe } from 'fp-ts/function';
import { Option, some, none, map, getOrElse } from 'fp-ts/Option';
import { Either, right, left, fold } from 'fp-ts/Either';

// Working with Option (Maybe) monad
const findUser = (id: number): Option<User> => {
  const user = database.find(user => user.id === id);
  return user ? some(user) : none;
};

const getUsername = (user: User): string => user.name;

const displayUsername = (id: number): string =>
  pipe(
    findUser(id),
    map(getUsername),
    getOrElse(() => 'User not found')
  );

console.log(displayUsername(1)); // 'John Doe' or 'User not found'

// Working with Either (Result) monad
const divide = (a: number, b: number): Either<string, number> =>
  b === 0 ? left('Division by zero') : right(a / b);

const displayResult = (a: number, b: number): string =>
  pipe(
    divide(a, b),
    fold(
      (error) => `Error: ${error}`,
      (result) => `Result: ${result}`
    )
  );

console.log(displayResult(10, 2)); // 'Result: 5'
console.log(displayResult(10, 0)); // 'Error: Division by zero'
```

### Testing Functional Code

```javascript
// Unit testing pure functions is straightforward

// Example Jest tests for our functions
// compose.js
export const add = x => y => x + y;
export const multiply = x => y => x * y;
export const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);
export const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);

// compose.test.js
import { add, multiply, pipe, compose } from './compose';

describe('Functional utilities', () => {
  test('add is curried and adds two numbers', () => {
    expect(add(2)(3)).toBe(5);
    
    const addTwo = add(2);
    expect(addTwo(3)).toBe(5);
    expect(addTwo(5)).toBe(7);
  });
  
  test('multiply is curried and multiplies two numbers', () => {
    expect(multiply(2)(3)).toBe(6);
    
    const double = multiply(2);
    expect(double(3)).toBe(6);
    expect(double(5)).toBe(10);
  });
  
  test('pipe composes functions from left to right', () => {
    const addTwo = add(2);
    const double = multiply(2);
    const square = x => x * x;
    
    const pipeline = pipe(addTwo, double, square);
    
    // (2 + 3) = 5, 5 * 2 = 10, 10 * 10 = 100
    expect(pipeline(3)).toBe(100);
  });
  
  test('compose composes functions from right to left', () => {
    const addTwo = add(2);
    const double = multiply(2);
    const square = x => x * x;
    
    const composed = compose(square, double, addTwo);
    
    // (2 + 3) = 5, 5 * 2 = 10, 10 * 10 = 100
    expect(composed(3)).toBe(100);
  });
});

// Property-based testing with JSVerify
import jsc from 'jsverify';
import { add, multiply, compose } from './compose';

describe('Property-based tests for functional utilities', () => {
  test('associativity of composition', () => {
    // f ∘ (g ∘ h) = (f ∘ g) ∘ h
    jsc.assert(jsc.forall('nat', n => {
      const f = x => x + 1;
      const g = x => x * 2;
      const h = x => x - 3;
      
      const left = compose(f, compose(g, h))(n);
      const right = compose(compose(f, g), h)(n);
      
      return left === right;
    }));
  });
  
  test('identity element', () => {
    // f ∘ id = id ∘ f = f
    const identity = x => x;
    
    jsc.assert(jsc.forall('nat', n => {
      const f = x => x * 2;
      
      return compose(f, identity)(n) === f(n) && compose(identity, f)(n) === f(n);
    }));
  });
  
  test('currying and uncurrying are inverses', () => {
    const curry = fn => x => y => fn(x, y);
    const uncurry = fn => (x, y) => fn(x)(y);
    
    jsc.assert(jsc.forall('nat', 'nat', (a, b) => {
      const fn = (x, y) => x + y;
      const curried = curry(fn);
      const uncurried = uncurry(curried);
      
      return fn(a, b) === curried(a)(b) && fn(a, b) === uncurried(a, b);
    }));
  });
});

// Testing recursive functions
import { factorial, fibonacci } from './recursion';

describe('Recursive functions', () => {
  test('factorial calculates correctly', () => {
    expect(factorial(0)).toBe(1);
    expect(factorial(1)).toBe(1);
    expect(factorial(5)).toBe(120);
    expect(factorial(10)).toBe(3628800);
  });
  
  test('factorial throws error for negative numbers', () => {
    expect(() => factorial(-1)).toThrow();
  });
  
  test('fibonacci calculates correctly', () => {
    expect(fibonacci(0)).toBe(0);
    expect(fibonacci(1)).toBe(1);
    expect(fibonacci(2)).toBe(1);
    expect(fibonacci(3)).toBe(2);
    expect(fibonacci(4)).toBe(3);
    expect(fibonacci(5)).toBe(5);
    expect(fibonacci(10)).toBe(55);
  });
});

// Testing with mocks while preserving function purity
import { fetchUserData, processUserData } from './userService';
import * as api from './api';

// Mock the API module
jest.mock('./api');

describe('User service', () => {
  test('fetchUserData calls API and processes the result', async () => {
    // Setup
    const mockUserData = { id: 1, name: 'John', role: 'admin' };
    api.getUser.mockResolvedValue(mockUserData);
    
    // Execute
    const result = await fetchUserData(1);
    
    // Verify
    expect(api.getUser).toHaveBeenCalledWith(1);
    expect(result).toEqual({
      id: 1,
      displayName: 'JOHN',
      isAdmin: true
    });
  });
  
  test('processUserData transforms user data correctly', () => {
    // Since this is a pure function, we can test it directly
    const input = { id: 1, name: 'John', role: 'admin' };
    const expected = {
      id: 1,
      displayName: 'JOHN',
      isAdmin: true
    };
    
    expect(processUserData(input)).toEqual(expected);
  });
});

// Testing function composition
import { formatUser, filterActiveUsers, sortByName } from './userUtils';

describe('User utility composition', () => {
  test('formatUser transforms user correctly', () => {
    const user = { firstName: 'John', lastName: 'Doe', age: 30 };
    const formatted = formatUser(user);
    
    expect(formatted).toEqual({
      fullName: 'John Doe',
      age: 30
    });
  });
  
  test('filterActiveUsers returns only active users', () => {
    const users = [
      { id: 1, active: true },
      { id: 2, active: false },
      { id: 3, active: true }
    ];
    
    const result = filterActiveUsers(users);
    
    expect(result).toHaveLength(2);
    expect(result.map(u => u.id)).toEqual([1, 3]);
  });
  
  test('compositions can be tested end-to-end', () => {
    const users = [
      { firstName: 'John', lastName: 'Doe', age: 30, active: true },
      { firstName: 'Jane', lastName: 'Smith', age: 25, active: false },
      { firstName: 'Bob', lastName: 'Johnson', age: 40, active: true }
    ];
    
    const processUsers = pipe(
      filterActiveUsers,
      map(formatUser),
      sortByName
    );
    
    const result = processUsers(users);
    
    expect(result).toEqual([
      { fullName: 'Bob Johnson', age: 40 },
      { fullName: 'John Doe', age: 30 }
    ]);
  });
});
```

### Advanced Concepts and Pitfalls

```javascript
// Monads in JavaScript
// A Monad is a design pattern that allows for sequential computation chaining

// Maybe Monad implementation
class Maybe {
  constructor(value) {
    this._value = value;
  }
  
  static of(value) {
    return new Maybe(value);
  }
  
  static just(value) {
    return new Maybe(value);
  }
  
  static nothing() {
    return new Maybe(null);
  }
  
  isNothing() {
    return this._value === null || this._value === undefined;
  }
  
  map(fn) {
    if (this.isNothing()) {
      return Maybe.nothing();
    }
    return Maybe.of(fn(this._value));
  }
  
  flatMap(fn) {
    if (this.isNothing()) {
      return Maybe.nothing();
    }
    const result = fn(this._value);
    return result instanceof Maybe ? result : Maybe.of(result);
  }
  
  getOrElse(defaultValue) {
    return this.isNothing() ? defaultValue : this._value;
  }
}

// Example usage
function findUser(id) {
  // Imagine this is a database query
  const users = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' }
  ];
  
  const user = users.find(user => user.id === id);
  return user ? Maybe.just(user) : Maybe.nothing();
}

function getAddress(user) {
  return user.address ? Maybe.just(user.address) : Maybe.nothing();
}

// Without Maybe
function getUserStreet(userId) {
  const user = findUserRaw(userId);
  if (!user) return 'Unknown';
  
  if (!user.address) return 'No address';
  
  return user.address.street || 'No street';
}

// With Maybe
function getUserStreetMaybe(userId) {
  return findUser(userId)
    .flatMap(getAddress)
    .map(address => address.street)
    .getOrElse('Unknown street');
}

// Common pitfalls to avoid

// 1. Mutating data in supposedly pure functions
function impurePush(array, item) {
  array.push(item); // Mutates the array!
  return array;
}

// Pure alternative
function purePush(array, item) {
  return [...array, item]; // Returns a new array
}

// 2. Side effects in functional code
function fetchWithSideEffect(url) {
  let result;
  
  fetch(url)
    .then(res => res.json())
    .then(data => {
      result = data; // Side effect: assigns to external variable
      console.log('Data fetched!'); // Side effect: console.log
    });
  
  return result; // This will be undefined!
}

// Better approach
async function fetchFunctional(url) {
  const response = await fetch(url);
  return response.json();
}

// 3. Stack overflow with deep recursion
function deeplyNested(n) {
  if (n <= 0) return 0;
  return 1 + deeplyNested(n - 1);
}

// deeplyNested(10000); // Stack overflow!

// Using trampoline for safety
function trampolined(fn) {
  return function(...args) {
    let result = fn(...args);
    
    while (typeof result === 'function') {
      result = result();
    }
    
    return result;
  };
}

const safeNested = trampolined(function nested(n) {
  if (n <= 0) return 0;
  return () => 1 + nested(n - 1);
});

// safeNested(10000); // Works!

// 4. Performance concerns with excessive function creation
function badCurryingExample() {
  const values = Array.from({ length: 1000000 }, (_, i) => i);
  
  // This creates a new curried function for each array element!
  const processed = values.map(
    value => value => value * 2
  );
  
  // Now we have to call each function
  return processed.map(fn => fn());
}

// Better approach
function betterExample() {
  const values = Array.from({ length: 1000000 }, (_, i) => i);
  
  // Create the function once
  const double = value => value * 2;
  
  // Apply it to each element
  return values.map(double);
}

// 5. Overusing recursion when iteration would be clearer
function factorial(n) {
  if (n <= 1) return 1;
  return n * factorial(n - 1);
}

function iterativeFactorial(n) {
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

// 6. Memory leaks with closures
function createCounter() {
  // This array will be kept in memory as long as the increment function exists
  const history = [];
  
  return function increment() {
    const newValue = history.length + 1;
    history.push(newValue);
    return newValue;
  };
}

// If we use this counter a lot, the history array grows indefinitely
const count = createCounter();

// 7. Breaking referential transparency
let globalState = 0;

// Not referentially transparent because it depends on external state
function addToGlobal(x) {
  return x + globalState; // Result changes if globalState changes
}

// 8. Excessive function composition
function overComposition(data) {
  return pipe(
    map(item => item.value),
    filter(value => value > 0),
    map(value => value * 2),
    map(value => value.toString()),
    map(str => str + '!'),
    map(str => str.toUpperCase()),
    map(str => `<div>${str}</div>`),
    join('')
  )(data);
}

// Could be simplified to:
function betterComposition(data) {
  return pipe(
    filter(item => item.value > 0),
    map(item => `<div>${(item.value * 2)}!</div>`.toUpperCase()),
    join('')
  )(data);
}

// 9. Ignoring the debugging experience
function hardToDebug(data) {
  return compose(
    sum,
    map(square),
    filter(isEven),
    map(addOne)
  )(data);
}

// With debugging points
function debuggable(data) {
  const step1 = map(addOne)(data);
  console.log('After addOne:', step1);
  
  const step2 = filter(isEven)(step1);
  console.log('After filtering evens:', step2);
  
  const step3 = map(square)(step2);
  console.log('After squaring:', step3);
  
  return sum(step3);
}

// 10. Improper handling of asynchronous operations
function asyncComposition(userId) {
  return getUser(userId) // Returns a Promise
    .then(user => {
      return {
        ...user,
        // This doesn't work as expected because map expects an array, not a Promise
        orders: map(formatOrder)(user.orders)
      };
    });
}

// Correct approach
function properAsyncComposition(userId) {
  return getUser(userId)
    .then(user => ({
      ...user,
      orders: user.orders.map(formatOrder)
    }));
}

// 11. Not handling edge cases in recursive functions
function badRecursiveSum(arr) {
  // Doesn't handle empty array!
  return arr[0] + badRecursiveSum(arr.slice(1));
}

function goodRecursiveSum(arr) {
  if (arr.length === 0) return 0;
  return arr[0] + goodRecursiveSum(arr.slice(1));
}

// 12. Not accounting for JavaScript's non-tail-call optimization in most environments
function recursiveFactorial(n) {
  if (n <= 1) return 1;
  return n * recursiveFactorial(n - 1); // Not tail recursive
}

function tailRecursiveFactorial(n, acc = 1) {
  if (n <= 1) return acc;
  return tailRecursiveFactorial(n - 1, n * acc); // Tail recursive
}

// Even this will overflow in many JS environments for large n
// since JS engines don't optimize tail calls except in strict mode
// and even then, it's not guaranteed across all engines
```

---
