## Higher-Order Functions


Higher-order functions either take one or more functions as arguments, return a function as result, or both. They enable abstraction over actions, not just values, making code more declarative and reusable.

### Functions Taking Function Arguments

```javascript
const numbers = [1, 2, 3, 4, 5];

// map is a higher-order function
const doubled = numbers.map(n => n * 2);
console.log(doubled); // [2, 4, 6, 8, 10]

// filter is a higher-order function
const evens = numbers.filter(n => n % 2 === 0);
console.log(evens); // [2, 4]

// reduce is a higher-order function
const sum = numbers.reduce((acc, n) => acc + n, 0);
console.log(sum); // 15
```

### Functions Returning Functions

```javascript
function withLogging(fn) {
  return function(...args) {
    console.log(`Calling with: ${args}`);
    const result = fn(...args);
    console.log(`Result: ${result}`);
    return result;
  };
}

const add = (a, b) => a + b;
const addWithLogging = withLogging(add);
addWithLogging(3, 4);
// Calling with: 3,4
// Result: 7
```

### Custom Higher-Order Functions

```javascript
function times(n) {
  return function(fn) {
    for (let i = 0; i < n; i++) {
      fn(i);
    }
  };
}

const threeTimes = times(3);
threeTimes(i => console.log(`Iteration ${i}`));
// Iteration 0
// Iteration 1
// Iteration 2
```

### Practical Application: Array Processing

```javascript
const users = [
  { name: "Alice", age: 25, active: true },
  { name: "Bob", age: 30, active: false },
  { name: "Charlie", age: 35, active: true }
];

const activeUserNames = users
  .filter(user => user.active)
  .map(user => user.name)
  .map(name => name.toUpperCase());

console.log(activeUserNames); // ["ALICE", "CHARLIE"]
```

**Key Points:**

- Abstract control flow and operations
- Enable declarative programming style
- Common built-ins: `map`, `filter`, `reduce`, `forEach`, `sort`, `find`
- Create decorators and middleware patterns
- Reduce code duplication through parameterization

