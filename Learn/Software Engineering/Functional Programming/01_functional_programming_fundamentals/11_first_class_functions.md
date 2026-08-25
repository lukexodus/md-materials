## First-Class Functions


First-class functions mean functions are treated as values—they can be assigned to variables, passed as arguments, returned from other functions, and stored in data structures. This is fundamental to functional programming as it enables functions to be manipulated like any other data type.

### Assignment to Variables

```javascript
const greet = function(name) {
  return `Hello, ${name}!`;
};

const sayHello = greet;
console.log(sayHello("Alice")); // "Hello, Alice!"
```

### Storing in Data Structures

```javascript
const operations = {
  add: (a, b) => a + b,
  subtract: (a, b) => a - b,
  multiply: (a, b) => a * b
};

console.log(operations.add(5, 3)); // 8
```

### Passing as Arguments

```javascript
function execute(fn, value) {
  return fn(value);
}

const double = x => x * 2;
console.log(execute(double, 10)); // 20
```

### Returning from Functions

```javascript
function createMultiplier(factor) {
  return function(number) {
    return number * factor;
  };
}

const triple = createMultiplier(3);
console.log(triple(5)); // 15
```

**Key Points:**

- Functions have the same rights as other values
- Enables dynamic function creation and manipulation
- Foundation for closures and currying
- Allows building abstractions by combining functions

