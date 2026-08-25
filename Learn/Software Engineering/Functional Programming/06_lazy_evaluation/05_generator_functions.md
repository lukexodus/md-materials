## Generator Functions


Generator functions are special functions that can pause execution and resume later, enabling lazy evaluation and the creation of iterables that produce values on-demand. They return generator objects that conform to both the iterable and iterator protocols.

### Basic Generator Syntax

**Function Declaration:**

```javascript
function* simpleGenerator() {
  yield 1;
  yield 2;
  yield 3;
}

const gen = simpleGenerator();
console.log(gen.next()); // { value: 1, done: false }
console.log(gen.next()); // { value: 2, done: false }
console.log(gen.next()); // { value: 3, done: false }
console.log(gen.next()); // { value: undefined, done: true }
```

**Generator Expressions:**

```javascript
const generator = function* () {
  yield 'a';
  yield 'b';
};

// Arrow functions cannot be generators
// const invalid = *() => { yield 1; }; // Syntax Error
```

**Method Generators:**

```javascript
const obj = {
  *generatorMethod() {
    yield 1;
    yield 2;
  }
};

class Container {
  *[Symbol.iterator]() {
    yield 'x';
    yield 'y';
  }
}
```

### Generator Execution Model

Generators maintain execution state between yields:

```javascript
function* statefulGenerator() {
  console.log('Start');
  yield 1;
  console.log('After first yield');
  yield 2;
  console.log('After second yield');
  return 'Done';
}

const gen = statefulGenerator();
// Nothing logged yet

gen.next(); // Logs: "Start", returns { value: 1, done: false }
gen.next(); // Logs: "After first yield", returns { value: 2, done: false }
gen.next(); // Logs: "After second yield", returns { value: "Done", done: true }
```

**Local Variables Persist:**

```javascript
function* counter() {
  let count = 0;
  while (true) {
    count++;
    yield count;
  }
}

const cnt = counter();
console.log(cnt.next().value); // 1
console.log(cnt.next().value); // 2
console.log(cnt.next().value); // 3
```

### Infinite Sequences

Generators excel at representing infinite or very large sequences:

```javascript
function* fibonacci() {
  let [prev, curr] = [0, 1];
  while (true) {
    yield curr;
    [prev, curr] = [curr, prev + curr];
  }
}

const fib = fibonacci();
console.log(fib.next().value); // 1
console.log(fib.next().value); // 1
console.log(fib.next().value); // 2
console.log(fib.next().value); // 3
console.log(fib.next().value); // 5
```

**Natural Numbers:**

```javascript
function* naturals(start = 0) {
  let n = start;
  while (true) {
    yield n++;
  }
}

function* take(n, iterable) {
  let count = 0;
  for (const value of iterable) {
    if (count++ >= n) break;
    yield value;
  }
}

const firstTen = [...take(10, naturals(1))];
// [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
```

**Random Stream:**

```javascript
function* randomNumbers(min = 0, max = 1) {
  while (true) {
    yield Math.random() * (max - min) + min;
  }
}

const randoms = randomNumbers(0, 100);
console.log(randoms.next().value); // e.g., 42.7
console.log(randoms.next().value); // e.g., 81.3
```

### Passing Values to Generators

The `next()` method can pass values back into the generator:

```javascript
function* dialogue() {
  const name = yield 'What is your name?';
  const age = yield `Hello ${name}, how old are you?`;
  return `${name} is ${age} years old`;
}

const conv = dialogue();
console.log(conv.next().value);        // "What is your name?"
console.log(conv.next('Alice').value); // "Hello Alice, how old are you?"
console.log(conv.next(30).value);      // "Alice is 30 years old"
```

**Bidirectional Communication:**

```javascript
function* runningAverage() {
  let total = 0;
  let count = 0;
  let average;
  
  while (true) {
    const value = yield average;
    total += value;
    count++;
    average = total / count;
  }
}

const avg = runningAverage();
avg.next();              // Initialize
console.log(avg.next(10).value); // 10
console.log(avg.next(20).value); // 15
console.log(avg.next(30).value); // 20
```

### Error Handling

**Throwing Errors:**

```javascript
function* errorHandling() {
  try {
    yield 1;
    yield 2;
    yield 3;
  } catch (error) {
    console.log('Caught:', error.message);
    yield 'recovered';
  }
}

const gen = errorHandling();
console.log(gen.next().value);  // 1
console.log(gen.next().value);  // 2
console.log(gen.throw(new Error('Something wrong')).value);
// Logs: "Caught: Something wrong"
// Returns: { value: 'recovered', done: false }
```

**Return Method:**

```javascript
function* withCleanup() {
  try {
    yield 1;
    yield 2;
    yield 3;
  } finally {
    console.log('Cleanup');
  }
}

const gen = withCleanup();
console.log(gen.next().value);   // 1
console.log(gen.return('early').value); // Logs "Cleanup", returns "early"
console.log(gen.next());         // { value: undefined, done: true }
```

### Practical Patterns

**Pagination:**

```javascript
function* paginate(items, pageSize) {
  for (let i = 0; i < items.length; i += pageSize) {
    yield items.slice(i, i + pageSize);
  }
}

const data = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
for (const page of paginate(data, 3)) {
  console.log(page);
}
// [1, 2, 3]
// [4, 5, 6]
// [7, 8, 9]
// [10]
```

**Lazy Mapping:**

```javascript
function* lazyMap(fn, iterable) {
  for (const item of iterable) {
    yield fn(item);
  }
}

function* lazyFilter(predicate, iterable) {
  for (const item of iterable) {
    if (predicate(item)) yield item;
  }
}

const numbers = naturals(1);
const evens = lazyFilter(x => x % 2 === 0, numbers);
const doubled = lazyMap(x => x * 2, evens);

console.log([...take(5, doubled)]); // [4, 8, 12, 16, 20]
```

**ID Generator:**

```javascript
function* idGenerator(prefix = 'id') {
  let id = 0;
  while (true) {
    yield `${prefix}_${++id}`;
  }
}

const userIds = idGenerator('user');
console.log(userIds.next().value); // "user_1"
console.log(userIds.next().value); // "user_2"

const postIds = idGenerator('post');
console.log(postIds.next().value); // "post_1"
```

**Key Points:**

- Generators are functions that can pause and resume execution
- They return generator objects that are both iterables and iterators
- Execution doesn't start until first `next()` call
- State and local variables persist between yields
- Perfect for infinite sequences and lazy evaluation
- Support bidirectional communication via `next(value)`
- Can handle errors with `throw()` method
- Can be terminated early with `return()` method
- More memory-efficient than materializing entire sequences

