## Method Chaining


Method chaining, also called fluent interfaces, is a pattern where methods return the object itself (or a transformed version), enabling sequential method calls in a single expression. In functional programming, this manifests as operations that return new transformable values rather than mutating state.

**Key Points:**

- Each method returns a value that supports further chaining
- Creates readable, left-to-right or top-to-bottom data transformation pipelines
- Immutable chaining returns new instances; mutable chaining modifies and returns `this`
- Popular in libraries like jQuery, Lodash, and array methods in JavaScript
- Trade-off between fluency and functional purity

The distinction between mutable and immutable chaining is critical:

Mutable chaining (OOP style):

```javascript
class Calculator {
  constructor(value = 0) {
    this.value = value;
  }
  
  add(n) {
    this.value += n;
    return this; // Returns mutated object
  }
  
  multiply(n) {
    this.value *= n;
    return this;
  }
  
  getValue() {
    return this.value;
  }
}

const result = new Calculator(5)
  .add(3)
  .multiply(2)
  .getValue(); // 16
```

Immutable chaining (functional style):

```javascript
const Calculator = (value) => ({
  add: (n) => Calculator(value + n),
  multiply: (n) => Calculator(value * n),
  getValue: () => value
});

const result = Calculator(5)
  .add(3)
  .multiply(2)
  .getValue(); // 16
```

Each operation creates a new Calculator instance, preserving immutability.

**Example with native JavaScript arrays:**

Arrays naturally support method chaining through immutable operations:

```javascript
const numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

const result = numbers
  .filter(n => n % 2 === 0)      // [2, 4, 6, 8, 10]
  .map(n => n * n)                // [4, 16, 36, 64, 100]
  .reduce((sum, n) => sum + n, 0); // 220
```

Each method returns a new array (or final value), maintaining immutability while providing fluent syntax.

**Example of building a custom chainable data structure:**

```javascript
const Collection = (items = []) => ({
  map: (fn) => Collection(items.map(fn)),
  filter: (fn) => Collection(items.filter(fn)),
  reduce: (fn, init) => items.reduce(fn, init),
  take: (n) => Collection(items.slice(0, n)),
  sort: (fn) => Collection([...items].sort(fn)),
  value: () => items
});

const data = [
  { name: 'Alice', age: 30, score: 85 },
  { name: 'Bob', age: 25, score: 92 },
  { name: 'Charlie', age: 35, score: 78 },
  { name: 'Diana', age: 28, score: 95 }
];

const topScorers = Collection(data)
  .filter(person => person.score > 80)
  .sort((a, b) => b.score - a.score)
  .take(2)
  .map(person => person.name)
  .value();

// ['Diana', 'Bob']
```

**Pipeline operator proposal:**

JavaScript has a stage 2 proposal for a pipeline operator that would make functional chaining more natural:

```javascript
// Current chaining
const result = value
  |> double
  |> increment
  |> square;

// Instead of
const result = square(increment(double(value)));
```

This syntax makes left-to-right data flow explicit without requiring methods or special wrapper objects.

**Key Points on effective method chaining:**

- Ensure each step returns a chainable value
- Consider naming conventions that indicate transformation vs termination (`.value()`, `.run()`, `.exec()`)
- Balance fluency with clarity—overly long chains can be hard to debug
- Use intermediate variables for complex chains to improve readability
- Method chaining naturally supports lazy evaluation in some implementations

**Example with lazy evaluation:**

```javascript
const LazyCollection = (items = []) => {
  const operations = [];
  
  return {
    map: (fn) => {
      operations.push({ type: 'map', fn });
      return LazyCollection(items);
    },
    filter: (fn) => {
      operations.push({ type: 'filter', fn });
      return LazyCollection(items);
    },
    value: () => {
      return operations.reduce((acc, op) => {
        if (op.type === 'map') return acc.map(op.fn);
        if (op.type === 'filter') return acc.filter(op.fn);
        return acc;
      }, items);
    }
  };
};
```

This defers execution until `.value()` is called, potentially optimizing performance by combining operations.

**Conclusion:** Method chaining in functional programming prioritizes immutability and pure transformations. While it shares syntax with object-oriented fluent interfaces, functional chaining emphasizes data transformation pipelines over stateful object manipulation. The pattern excels at expressing sequential transformations clearly while maintaining referential transparency.

