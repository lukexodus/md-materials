## Generators as Lazy Lists


Generators provide language-level support for lazy evaluation, yielding values on-demand and maintaining internal state between yields. They serve as a practical implementation of lazy lists.

### Generator Basics

Generators are functions that can pause execution and resume later, yielding values one at a time.

**Example:**

```javascript
function* naturalNumbers(start = 0) {
  let n = start;
  while (true) {
    yield n++;
  }
}

function* take(n, generator) {
  let count = 0;
  for (const value of generator) {
    if (count >= n) break;
    yield value;
    count++;
  }
}

const naturals = naturalNumbers();
console.log([...take(5, naturals)]);
```

**Output:**

```
[0, 1, 2, 3, 4]
```

### Generator Composition

Generators can be composed to create complex lazy pipelines.

**Example:**

```javascript
function* map(fn, iterable) {
  for (const value of iterable) {
    yield fn(value);
  }
}

function* filter(predicate, iterable) {
  for (const value of iterable) {
    if (predicate(value)) {
      yield value;
    }
  }
}

function* flatMap(fn, iterable) {
  for (const value of iterable) {
    yield* fn(value);
  }
}

function* range(start, end, step = 1) {
  for (let i = start; i < end; i += step) {
    yield i;
  }
}

const numbers = range(1, 20);
const evens = filter(x => x % 2 === 0, numbers);
const squared = map(x => x * x, evens);

console.log([...squared]);
```

**Output:**

```
[4, 16, 36, 64, 100, 144, 196, 256, 324]
```

### Infinite Generator Patterns

**Example:**

```javascript
function* repeat(value) {
  while (true) {
    yield value;
  }
}

function* cycle(iterable) {
  const cache = [];
  for (const value of iterable) {
    cache.push(value);
    yield value;
  }
  while (true) {
    for (const value of cache) {
      yield value;
    }
  }
}

function* iterate(fn, initial) {
  let current = initial;
  while (true) {
    yield current;
    current = fn(current);
  }
}

const fibonacci = (function* () {
  let [a, b] = [0, 1];
  while (true) {
    yield a;
    [a, b] = [b, a + b];
  }
})();

console.log([...take(10, fibonacci)]);
```

**Output:**

```
[0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

### Generator State Management

Generators maintain internal state between yields, enabling stateful iteration without external mutation.

**Example:**

```javascript
function* runningAverage() {
  let sum = 0;
  let count = 0;
  let value;
  
  while (true) {
    value = yield count === 0 ? 0 : sum / count;
    sum += value;
    count++;
  }
}

const avg = runningAverage();
avg.next();  // Prime the generator

console.log(avg.next(10).value);  // 10
console.log(avg.next(20).value);  // 15
console.log(avg.next(30).value);  // 20
console.log(avg.next(40).value);  // 25
```

**Output:**

```
10
15
20
25
```

### Generator Pipelines

Chaining generators creates efficient data processing pipelines with lazy evaluation.

**Example:**

```javascript
function* chunk(size, iterable) {
  let buffer = [];
  for (const value of iterable) {
    buffer.push(value);
    if (buffer.length === size) {
      yield buffer;
      buffer = [];
    }
  }
  if (buffer.length > 0) {
    yield buffer;
  }
}

function* zip(...iterables) {
  const iterators = iterables.map(it => it[Symbol.iterator]());
  while (true) {
    const results = iterators.map(it => it.next());
    if (results.some(r => r.done)) break;
    yield results.map(r => r.value);
  }
}

function* scan(fn, initial, iterable) {
  let accumulator = initial;
  yield accumulator;
  for (const value of iterable) {
    accumulator = fn(accumulator, value);
    yield accumulator;
  }
}

const numbers = range(1, 11);
const cumulative = scan((acc, x) => acc + x, 0, numbers);

console.log([...cumulative]);
```

**Output:**

```
[0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55]
```

### Generator-Based Stream Processing

**Example:**

```javascript
function* drop(n, iterable) {
  let count = 0;
  for (const value of iterable) {
    if (count >= n) {
      yield value;
    }
    count++;
  }
}

function* takeWhile(predicate, iterable) {
  for (const value of iterable) {
    if (!predicate(value)) break;
    yield value;
  }
}

function* dropWhile(predicate, iterable) {
  let dropping = true;
  for (const value of iterable) {
    if (dropping && predicate(value)) continue;
    dropping = false;
    yield value;
  }
}

const numbers = naturalNumbers(1);
const afterTen = drop(10, numbers);
const lessThanTwenty = takeWhile(x => x < 20, afterTen);

console.log([...lessThanTwenty]);
```

**Output:**

```
[11, 12, 13, 14, 15, 16, 17, 18, 19]
```

**Key Points:**

- Generators provide built-in lazy evaluation support
- Memory efficient: values generated on-demand
- Composable through generator delegation (yield*)
- Maintain state implicitly through function scope
- Enable infinite sequences with finite memory
- Support bidirectional communication via send/yield
- Integrate naturally with for-of loops and spread operator
- Can be prematurely terminated with return() method

---

