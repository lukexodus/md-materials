## Generator Protocol


The generator protocol defines how generators interact with iteration consumers. It consists of the iterator protocol (with `next()`, `return()`, and `throw()` methods) and makes generators both iterators and iterables.

### Iterator Protocol Implementation

Generators automatically implement the iterator protocol:

```javascript
function* simpleGen() {
  yield 1;
  yield 2;
  yield 3;
}

const gen = simpleGen();

// Generator objects have next(), return(), throw()
console.log(typeof gen.next);   // 'function'
console.log(typeof gen.return); // 'function'
console.log(typeof gen.throw);  // 'function'

// And they have Symbol.iterator
console.log(typeof gen[Symbol.iterator]); // 'function'
```

**next() Method:**

```javascript
function* protocolDemo() {
  yield 'a';
  yield 'b';
  return 'c';
}

const gen = protocolDemo();

console.log(gen.next()); // { value: 'a', done: false }
console.log(gen.next()); // { value: 'b', done: false }
console.log(gen.next()); // { value: 'c', done: true }
console.log(gen.next()); // { value: undefined, done: true }
```

### Iterable Protocol

Generators are self-iterating:

```javascript
function* selfIterating() {
  yield 1;
  yield 2;
  yield 3;
}

const gen = selfIterating();

// Generator is its own iterator
console.log(gen[Symbol.iterator]() === gen); // true

// Can be used with for...of
for (const value of selfIterating()) {
  console.log(value);
}
// 1
// 2
// 3

// Can be spread
console.log([...selfIterating()]); // [1, 2, 3]

// Can be destructured
const [first, second, ...rest] = selfIterating();
```

### return() Method

The `return()` method terminates the generator and optionally provides a return value:

```javascript
function* withReturn() {
  try {
    yield 1;
    yield 2;
    yield 3;
  } finally {
    console.log('Cleanup in finally');
  }
}

const gen = withReturn();
console.log(gen.next());         // { value: 1, done: false }
console.log(gen.return('early')); // Logs "Cleanup in finally"
                                  // { value: 'early', done: true }
console.log(gen.next());         // { value: undefined, done: true }
```

**Without Return Value:**

```javascript
function* simpleReturn() {
  yield 1;
  yield 2;
}

const gen = simpleReturn();
gen.next();      // { value: 1, done: false }
gen.return();    // { value: undefined, done: true }
gen.next();      // { value: undefined, done: true }
```

**Return Interception:**

```javascript
function* interceptReturn() {
  try {
    yield 1;
    yield 2;
  } finally {
    yield 'cleanup';
    return 'final';
  }
}

const gen = interceptReturn();
console.log(gen.next());   // { value: 1, done: false }
console.log(gen.return()); // { value: 'cleanup', done: false }
console.log(gen.next());   // { value: 'final', done: true }
```

### throw() Method

The `throw()` method throws an exception into the generator at the current yield point:

```javascript
function* withThrow() {
  try {
    yield 1;
    yield 2;
    yield 3;
  } catch (error) {
    console.log('Caught:', error.message);
    yield 'recovered';
  }
}

const gen = withThrow();
console.log(gen.next());  // { value: 1, done: false }
console.log(gen.throw(new Error('Oops')));
// Logs: "Caught: Oops"
// { value: 'recovered', done: false }
console.log(gen.next());  // { value: undefined, done: true }
```

**Uncaught Exceptions:**

```javascript
function* unhandledThrow() {
  yield 1;
  yield 2;
}

const gen = unhandledThrow();
gen.next(); // { value: 1, done: false }

try {
  gen.throw(new Error('Unhandled'));
} catch (error) {
  console.log('Exception propagated:', error.message);
}
// Logs: "Exception propagated: Unhandled"

console.log(gen.next()); // { value: undefined, done: true }
```

### Protocol Compliance Patterns

**Manual Iterator Implementation:**

```javascript
function createManualIterator(values) {
  let index = 0;
  
  return {
    next() {
      if (index < values.length) {
        return { value: values[index++], done: false };
      }
      return { value: undefined, done: true };
    },
    [Symbol.iterator]() {
      return this;
    }
  };
}

const manual = createManualIterator([1, 2, 3]);
console.log([...manual]); // [1, 2, 3]
```

**Generator Equivalent:**

```javascript
function* generatorIterator(values) {
  for (const value of values) {
    yield value;
  }
}

const gen = generatorIterator([1, 2, 3]);
console.log([...gen]); // [1, 2, 3]
```

### Composing with Protocol Methods

**Controlled Iteration:**

```javascript
function* controlledGenerator() {
  let i = 0;
  while (true) {
    const command = yield i;
    if (command === 'reset') {
      i = 0;
    } else if (command === 'skip') {
      i += 2;
    } else {
      i++;
    }
  }
}

const gen = controlledGenerator();
console.log(gen.next().value);          // 0
console.log(gen.next().value);          // 1
console.log(gen.next('skip').value);    // 3
console.log(gen.next().value);          // 4
console.log(gen.next('reset').value);   // 0
```

**State Machine:**

```javascript
function* stateMachine() {
  let state = 'idle';
  
  while (true) {
    const action = yield state;
    
    switch (state) {
      case 'idle':
        if (action === 'start') state = 'running';
        break;
      case 'running':
        if (action === 'pause') state = 'paused';
        if (action === 'stop') state = 'idle';
        break;
      case 'paused':
        if (action === 'resume') state = 'running';
        if (action === 'stop') state = 'idle';
        break;
    }
  }
}

const machine = stateMachine();
console.log(machine.next().value);           // 'idle'
console.log(machine.next('start').value);    // 'running'
console.log(machine.next('pause').value);    // 'paused'
console.log(machine.next('resume').value);   // 'running'
console.log(machine.next('stop').value);     // 'idle'
```

### Integration with Async Operations

**Callback to Generator:**

```javascript
function runGenerator(generatorFn) {
  const gen = generatorFn();
  
  function handle(result) {
    if (result.done) return;
    
    result.value.then(
      value => handle(gen.next(value)),
      error => handle(gen.throw(error))
    );
  }
  
  handle(gen.next());
}

function* asyncTask() {
  try {
    const result1 = yield Promise.resolve(10);
    console.log('Result 1:', result1);
    
    const result2 = yield Promise.resolve(result1 * 2);
    console.log('Result 2:', result2);
  } catch (error) {
    console.log('Error:', error);
  }
}

runGenerator(asyncTask);
// Result 1: 10
// Result 2: 20
```

### Custom Protocol Extensions

**Extended Generator:**

```javascript
function* extendedGenerator() {
  yield 1;
  yield 2;
  yield 3;
}

const gen = extendedGenerator();

// Add custom methods
gen.peek = function() {
  const snapshot = this.next();
  // Can't truly peek without consuming, this is illustrative
  return snapshot.value;
};

gen.skip = function(n) {
  for (let i = 0; i < n; i++) {
    const result = this.next();
    if (result.done) break;
  }
  return this;
};
```

**Protocol Wrapper:**

```javascript
function wrapGenerator(gen) {
  return {
    next: (...args) => gen.next(...args),
    return: (...args) => gen.return(...args),
    throw: (...args) => gen.throw(...args),
    [Symbol.iterator]() { return this; },
    
    // Custom methods
    toArray() {
      return [...gen];
    },
    
    forEach(fn) {
      for (const value of gen) {
        fn(value);
      }
    }
  };
}

function* numbers() {
  yield 1;
  yield 2;
  yield 3;
}

const wrapped = wrapGenerator(numbers());
console.log(wrapped.toArray()); // [1, 2, 3]
```

### Protocol Debugging

**Logging Wrapper:**

```javascript
function* loggingGenerator(gen) {
  let result = gen.next();
  
  while (!result.done) {
    console.log('Yielded:', result.value);
    const input = yield result.value;
    console.log('Received:', input);
    result = gen.next(input);
  }
  
  return result.value;
}

function* original() {
  const a = yield 1;
  const b = yield a + 1;
  return b + 1;
}

const logged = loggingGenerator(original());
console.log(logged.next());      // Logs: "Yielded: 1"
console.log(logged.next(10));    // Logs: "Received: 10", "Yielded: 11"
console.log(logged.next(20));    // Logs: "Received: 20"
```

**Key Points:**

- Generators implement both iterator and iterable protocols automatically
- The `next()` method advances execution and returns `{ value, done }`
- The `return()` method terminates the generator early
- The `throw()` method injects exceptions into the generator
- Generators are self-iterating: `gen[Symbol.iterator]() === gen`
- Protocol compliance enables use with for...of, spread, destructuring
- finally blocks execute when `return()` is called
- Thrown exceptions can be caught or will terminate the generator
- Protocol methods enable sophisticated control flow patterns
- Understanding the protocol is essential for generator composition

