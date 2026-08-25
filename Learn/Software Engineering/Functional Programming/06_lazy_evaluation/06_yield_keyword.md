## Yield Keyword


The `yield` keyword is the mechanism by which generator functions pause execution and produce values. It acts as a two-way communication channel between the generator and its consumer, enabling both value production and consumption.

### Basic Yield Semantics

**Value Production:**

```javascript
function* basicYield() {
  yield 1;
  yield 2 + 3;
  yield Math.random();
  yield 'string';
  yield { key: 'value' };
  yield [1, 2, 3];
}

const gen = basicYield();
console.log(gen.next()); // { value: 1, done: false }
console.log(gen.next()); // { value: 5, done: false }
console.log(gen.next()); // { value: <random>, done: false }
```

**Yield Expression:**

```javascript
function* yieldExpression() {
  const result = yield 10;
  console.log('Received:', result);
  return result * 2;
}

const gen = yieldExpression();
gen.next();           // { value: 10, done: false }
gen.next(5);          // Logs "Received: 5", returns { value: 10, done: true }
```

### Yield Behavior

**Pausing Execution:**

```javascript
function* demonstratePause() {
  console.log('Before first yield');
  yield 1;
  console.log('Between yields');
  yield 2;
  console.log('After last yield');
}

const gen = demonstratePause();
// Nothing logged yet

gen.next();
// Logs: "Before first yield"
// Returns: { value: 1, done: false }

gen.next();
// Logs: "Between yields"
// Returns: { value: 2, done: false }

gen.next();
// Logs: "After last yield"
// Returns: { value: undefined, done: true }
```

**Yield in Expressions:**

```javascript
function* yieldInExpressions() {
  const x = (yield 1) + (yield 2);
  return x;
}

const gen = yieldInExpressions();
gen.next();      // { value: 1, done: false }
gen.next(10);    // { value: 2, done: false }
gen.next(20);    // { value: 30, done: true } (10 + 20)
```

### Conditional Yielding

**Yield with Conditions:**

```javascript
function* conditionalYield(n) {
  for (let i = 0; i < n; i++) {
    if (i % 2 === 0) {
      yield i;
    }
  }
}

console.log([...conditionalYield(10)]); // [0, 2, 4, 6, 8]
```

**Early Termination:**

```javascript
function* yieldUntilCondition(predicate) {
  let i = 0;
  while (true) {
    if (predicate(i)) return;
    yield i;
    i++;
  }
}

const gen = yieldUntilCondition(x => x >= 5);
console.log([...gen]); // [0, 1, 2, 3, 4]
```

### Yield with Side Effects

**Logging:**

```javascript
function* yieldWithLogging(items) {
  for (const item of items) {
    console.log(`Yielding: ${item}`);
    yield item;
  }
}

for (const val of yieldWithLogging([1, 2, 3])) {
  console.log(`Received: ${val}`);
}
// Yielding: 1
// Received: 1
// Yielding: 2
// Received: 2
// Yielding: 3
// Received: 3
```

**Stateful Yielding:**

```javascript
function* yieldWithState() {
  let state = { count: 0, sum: 0 };
  
  while (true) {
    const input = yield state;
    state.count++;
    state.sum += input;
  }
}

const gen = yieldWithState();
gen.next();           // { value: { count: 0, sum: 0 }, done: false }
gen.next(10);         // { value: { count: 1, sum: 10 }, done: false }
gen.next(20);         // { value: { count: 2, sum: 30 }, done: false }
```

### Yield in Loops

**While Loops:**

```javascript
function* infiniteSequence(start = 0, step = 1) {
  let current = start;
  while (true) {
    yield current;
    current += step;
  }
}

const seq = infiniteSequence(0, 2);
console.log(seq.next().value); // 0
console.log(seq.next().value); // 2
console.log(seq.next().value); // 4
```

**For Loops:**

```javascript
function* range(start, end, step = 1) {
  for (let i = start; i < end; i += step) {
    yield i;
  }
}

console.log([...range(0, 10, 2)]); // [0, 2, 4, 6, 8]
```

**Iterating Collections:**

```javascript
function* yieldFromArray(arr) {
  for (let i = 0; i < arr.length; i++) {
    yield arr[i];
  }
}

// More idiomatic
function* yieldFromIterable(iterable) {
  for (const item of iterable) {
    yield item;
  }
}
```

### Multiple Yields per Iteration

**Yielding Multiple Values:**

```javascript
function* multipleYields(n) {
  for (let i = 0; i < n; i++) {
    yield i;
    yield i * 2;
    yield i * 3;
  }
}

console.log([...multipleYields(3)]);
// [0, 0, 0, 1, 2, 3, 2, 4, 6]
```

**Expanding Values:**

```javascript
function* expandItems(items) {
  for (const item of items) {
    yield item.id;
    yield item.name;
    yield item.value;
  }
}

const data = [
  { id: 1, name: 'A', value: 10 },
  { id: 2, name: 'B', value: 20 }
];

console.log([...expandItems(data)]);
// [1, 'A', 10, 2, 'B', 20]
```

### Yield with Destructuring

**Yielding Tuples:**

```javascript
function* yieldPairs() {
  yield [1, 2];
  yield [3, 4];
  yield [5, 6];
}

for (const [a, b] of yieldPairs()) {
  console.log(`a=${a}, b=${b}`);
}
// a=1, b=2
// a=3, b=4
// a=5, b=6
```

**Yielding Objects:**

```javascript
function* yieldRecords() {
  yield { id: 1, name: 'Alice' };
  yield { id: 2, name: 'Bob' };
}

for (const { id, name } of yieldRecords()) {
  console.log(`${id}: ${name}`);
}
// 1: Alice
// 2: Bob
```

### Advanced Patterns

**Lazy Evaluation Chain:**

```javascript
function* lazyTransform(iterable, transformFn) {
  for (const item of iterable) {
    const transformed = transformFn(item);
    if (transformed !== undefined) {
      yield transformed;
    }
  }
}

const numbers = range(1, 10);
const doubled = lazyTransform(numbers, x => x * 2);
const filtered = lazyTransform(doubled, x => x > 10 ? x : undefined);

console.log([...filtered]); // [12, 14, 16, 18]
```

**Cooperative Multitasking:**

```javascript
function* task(name, duration) {
  for (let i = 0; i < duration; i++) {
    console.log(`${name}: step ${i}`);
    yield;
  }
}

function* scheduler(tasks) {
  const generators = tasks.map(t => t());
  
  while (generators.length > 0) {
    for (let i = generators.length - 1; i >= 0; i--) {
      const result = generators[i].next();
      if (result.done) {
        generators.splice(i, 1);
      }
    }
    yield;
  }
}

const schedule = scheduler([
  () => task('Task A', 3),
  () => task('Task B', 2)
]);

[...schedule];
// Task A: step 0
// Task B: step 0
// Task A: step 1
// Task B: step 1
// Task A: step 2
```

**Memoized Generator:**

```javascript
function* memoizedGenerator(generatorFn) {
  const cache = [];
  const gen = generatorFn();
  
  let index = 0;
  while (true) {
    if (index < cache.length) {
      yield cache[index++];
    } else {
      const { value, done } = gen.next();
      if (done) return;
      cache.push(value);
      yield value;
      index++;
    }
  }
}

function* expensiveSequence() {
  let i = 0;
  while (true) {
    console.log('Computing...');
    yield i++;
  }
}

const memo = memoizedGenerator(expensiveSequence);
console.log([...take(3, memo)]); // Computes 3 times
console.log([...take(3, memo)]); // Uses cache, no computation
```

**Key Points:**

- `yield` pauses execution and produces a value to the consumer
- The yielded value becomes the `value` property of the iteration result
- `yield` expressions can receive values passed via `next(value)`
- Can appear anywhere an expression is valid (assignments, returns, conditions)
- Multiple yields can occur in a single loop iteration
- Yield without a value produces `undefined`
- Cannot be used in arrow functions or regular functions
- Cannot be used inside nested non-generator functions
- Essential for implementing lazy evaluation and infinite sequences

