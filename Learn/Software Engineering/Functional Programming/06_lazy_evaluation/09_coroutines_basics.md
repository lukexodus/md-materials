## Coroutines Basics


Coroutines are functions that can suspend execution and resume later, maintaining their state between suspensions. Unlike regular functions that run to completion, coroutines can yield control back to the caller and be resumed from where they left off.

### Generator Functions as Coroutines

```javascript
function* simpleCoroutine() {
  console.log('Started');
  yield 1;
  console.log('Resumed after first yield');
  yield 2;
  console.log('Resumed after second yield');
  yield 3;
  console.log('Completed');
}

const coro = simpleCoroutine();
console.log(coro.next()); // Started, { value: 1, done: false }
console.log(coro.next()); // Resumed after first yield, { value: 2, done: false }
console.log(coro.next()); // Resumed after second yield, { value: 3, done: false }
console.log(coro.next()); // Completed, { value: undefined, done: true }
```

### State Preservation

```javascript
function* counter(start = 0) {
  let count = start;
  while (true) {
    const increment = yield count;
    count += increment || 1;
  }
}

const c = counter(10);
console.log(c.next().value);    // 10
console.log(c.next(5).value);   // 15 (10 + 5)
console.log(c.next(3).value);   // 18 (15 + 3)
console.log(c.next().value);    // 19 (18 + 1)
```

### Bidirectional Communication

```javascript
function* dataProcessor() {
  let data = null;
  while (true) {
    data = yield data ? data.toUpperCase() : 'Waiting for data';
  }
}

const processor = dataProcessor();
console.log(processor.next().value);           // "Waiting for data"
console.log(processor.next('hello').value);    // "HELLO"
console.log(processor.next('world').value);    // "WORLD"
```

### Cooperative Multitasking

```javascript
function* task1() {
  console.log('Task 1: Step 1');
  yield;
  console.log('Task 1: Step 2');
  yield;
  console.log('Task 1: Step 3');
}

function* task2() {
  console.log('Task 2: Step 1');
  yield;
  console.log('Task 2: Step 2');
  yield;
  console.log('Task 2: Step 3');
}

function runTasks(...tasks) {
  const iterators = tasks.map(task => task());
  let completed = 0;
  
  while (completed < iterators.length) {
    iterators.forEach((iterator, index) => {
      const result = iterator.next();
      if (result.done && completed < iterators.length) {
        completed++;
      }
    });
  }
}

runTasks(task1, task2);
// Interleaves execution: Task 1 Step 1, Task 2 Step 1, Task 1 Step 2, etc.
```

### Pipeline Processing

```javascript
function* mapGenerator(iterable, fn) {
  for (const item of iterable) {
    yield fn(item);
  }
}

function* filterGenerator(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

function* range(start, end) {
  for (let i = start; i <= end; i++) {
    yield i;
  }
}

// Create pipeline without processing until consumed
const numbers = range(1, 10);
const doubled = mapGenerator(numbers, x => x * 2);
const evens = filterGenerator(doubled, x => x % 4 === 0);

// Only now does computation happen
for (const num of evens) {
  console.log(num); // 4, 8, 12, 16, 20
}
```

### Async Coroutines

```javascript
async function* asyncDataFetcher(urls) {
  for (const url of urls) {
    const response = await fetch(url);
    const data = await response.json();
    yield data;
  }
}

// Usage
const urls = ['/api/user/1', '/api/user/2', '/api/user/3'];
const fetcher = asyncDataFetcher(urls);

for await (const userData of fetcher) {
  console.log(userData); // Processes each user as it arrives
}
```

### Delegation with yield*

```javascript
function* inner() {
  yield 'a';
  yield 'b';
}

function* outer() {
  yield 1;
  yield* inner(); // Delegate to another generator
  yield 2;
}

const gen = outer();
console.log([...gen]); // [1, 'a', 'b', 2]
```

### Early Termination

```javascript
function* dataStream() {
  try {
    yield 1;
    yield 2;
    yield 3;
    yield 4;
  } finally {
    console.log('Cleanup: Stream closed');
  }
}

const stream = dataStream();
console.log(stream.next().value); // 1
console.log(stream.next().value); // 2
stream.return('stopped');         // Cleanup: Stream closed
console.log(stream.next());       // { value: undefined, done: true }
```

### Error Handling

```javascript
function* errorHandler() {
  try {
    yield 1;
    yield 2;
    yield 3;
  } catch (e) {
    console.log('Caught:', e.message);
    yield 'error handled';
  }
}

const gen = errorHandler();
console.log(gen.next().value);              // 1
console.log(gen.throw(new Error('Oops')).value); // Caught: Oops, "error handled"
```

### Python-Style Coroutines

**Python:**

```python
def producer():
    for i in range(5):
        print(f"Producing {i}")
        yield i

def consumer():
    while True:
        value = yield
        print(f"Consuming {value}")

# Generator-based coroutine
gen = producer()
for item in gen:
    print(item)
```

### Real-World Example: Parser

```javascript
function* tokenizer(input) {
  let current = 0;
  
  while (current < input.length) {
    let char = input[current];
    
    if (/\s/.test(char)) {
      current++;
      continue;
    }
    
    if (/[0-9]/.test(char)) {
      let value = '';
      while (/[0-9]/.test(input[current])) {
        value += input[current++];
      }
      yield { type: 'NUMBER', value };
      continue;
    }
    
    if (/[a-z]/i.test(char)) {
      let value = '';
      while (/[a-z]/i.test(input[current])) {
        value += input[current++];
      }
      yield { type: 'WORD', value };
      continue;
    }
    
    throw new Error(`Unknown character: ${char}`);
  }
}

const tokens = tokenizer('hello 123 world 456');
console.log([...tokens]);
// [
//   { type: 'WORD', value: 'hello' },
//   { type: 'NUMBER', value: '123' },
//   { type: 'WORD', value: 'world' },
//   { type: 'NUMBER', value: '456' }
// ]
```

**Key Points:**

- Coroutines suspend and resume execution while maintaining state
- Enable bidirectional communication via `yield` and `next(value)`
- Support cooperative multitasking and pipeline processing
- Can be composed using `yield*` for delegation
- Provide `return()` and `throw()` for control flow
- Form the foundation of lazy evaluation

---

