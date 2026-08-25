## Function Composition


Function composition combines multiple functions to create new functions, where the output of one function becomes the input of the next. It follows mathematical function composition: `(f ∘ g)(x) = f(g(x))`.

### Basic Composition

```javascript
const add5 = x => x + 5;
const multiply3 = x => x * 3;

// Manual composition (right to left)
const add5ThenMultiply3 = x => multiply3(add5(x));
console.log(add5ThenMultiply3(10)); // (10 + 5) * 3 = 45
```

### Creating a Compose Utility

```javascript
// Right to left composition
const compose = (...fns) => x =>
  fns.reduceRight((acc, fn) => fn(acc), x);

const add5 = x => x + 5;
const multiply3 = x => x * 3;
const subtract2 = x => x - 2;

const computation = compose(subtract2, multiply3, add5);
console.log(computation(10)); // ((10 + 5) * 3) - 2 = 43
```

### Pipe (Left to Right)

```javascript
// Left to right composition (more intuitive for many)
const pipe = (...fns) => x =>
  fns.reduce((acc, fn) => fn(acc), x);

const computation = pipe(add5, multiply3, subtract2);
console.log(computation(10)); // ((10 + 5) * 3) - 2 = 43
```

### Practical Example: Data Transformation

```javascript
const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

const users = [
  { name: "alice", age: 25, score: 85 },
  { name: "bob", age: 30, score: 92 },
  { name: "charlie", age: 35, score: 78 }
];

const getHighScorers = pipe(
  users => users.filter(u => u.score >= 80),
  users => users.map(u => ({ ...u, name: u.name.toUpperCase() })),
  users => users.sort((a, b) => b.score - a.score)
);

console.log(getHighScorers(users));
// [
//   { name: "BOB", age: 30, score: 92 },
//   { name: "ALICE", age: 25, score: 85 }
// ]
```

### Composing with Multiple Arguments

```javascript
const curry = fn => {
  return function curried(...args) {
    if (args.length >= fn.length) {
      return fn(...args);
    }
    return (...nextArgs) => curried(...args, ...nextArgs);
  };
};

const add = curry((a, b) => a + b);
const multiply = curry((a, b) => a * b);
const divide = curry((a, b) => a / b);

const calculate = pipe(
  add(10),
  multiply(2),
  divide(4)
);

console.log(calculate(5)); // ((5 + 10) * 2) / 4 = 7.5
```

### Point-Free Style

```javascript
const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

// With explicit parameters
const processData = data => data.trim().toLowerCase().split(' ');

// Point-free style (no explicit parameter)
const processDataPointFree = pipe(
  str => str.trim(),
  str => str.toLowerCase(),
  str => str.split(' ')
);

console.log(processDataPointFree("  HELLO WORLD  ")); 
// ["hello", "world"]
```

### Debugging Composed Functions

```javascript
const trace = label => value => {
  console.log(`${label}:`, value);
  return value;
};

const pipe = (...fns) => x => fns.reduce((acc, fn) => fn(acc), x);

const computation = pipe(
  x => x + 5,
  trace("After add 5"),
  x => x * 3,
  trace("After multiply 3"),
  x => x - 2,
  trace("Final result")
);

computation(10);
// After add 5: 15
// After multiply 3: 45
// Final result: 43
```

**Key Points:**

- Enables building complex operations from simple functions
- Promotes modularity and reusability
- `compose` goes right-to-left, `pipe` goes left-to-right
- Works best with unary functions (single argument)
- Point-free style eliminates unnecessary parameter declarations
- Debugging requires trace utilities or breaking composition
- Mathematical foundation: associative property allows flexible grouping

---

