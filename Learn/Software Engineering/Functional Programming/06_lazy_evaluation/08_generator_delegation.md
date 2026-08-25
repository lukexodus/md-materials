## Generator Delegation


Generator delegation, implemented with `yield*`, allows one generator to yield all values from another generator, iterator, or iterable. It enables composition of generators and creates powerful abstraction mechanisms for lazy sequences.

### Basic Delegation Syntax

__yield_ with Generators:_*

```javascript
function* inner() {
  yield 1;
  yield 2;
}

function* outer() {
  yield 'start';
  yield* inner();
  yield 'end';
}

console.log([...outer()]); // ['start', 1, 2, 'end']
```

**Without Delegation:**

```javascript
function* outerWithoutDelegation() {
  yield 'start';
  for (const value of inner()) {
    yield value;
  }
  yield 'end';
}

// Same result but more verbose
console.log([...outerWithoutDelegation()]); // ['start', 1, 2, 'end']
```

### Delegation with Iterables

**Array Delegation:**

```javascript
function* delegateArray() {
  yield* [1, 2, 3];
  yield* 'abc';
  yield* new Set([4, 5, 6]);
}

console.log([...delegateArray()]);
// [1, 2, 3, 'a', 'b', 'c', 4, 5, 6]
```

**String Delegation:**

```javascript
function* chars(str) {
  yield* str;
}

console.log([...chars('hello')]); // ['h', 'e', 'l', 'l', 'o']
```

**Map/Set Delegation:**

```javascript
function* delegateMap() {
  const map = new Map([
    ['a', 1],
    ['b', 2]
  ]);
  yield* map;
}

console.log([...delegateMap()]); // [['a', 1], ['b', 2]]
```

### Recursive Delegation

**Tree Traversal:**

```javascript
function* traverse(node) {
  yield node.value;
  
  if (node.children) {
    for (const child of node.children) {
	    yield* traverse(child);
	}
  }
}
	    
const tree = {
  value: 1,
  children: [
    {
      value: 2,
      children: [{ value: 4 }, { value: 5 }]
    },
    {
      value: 3,
      children: [{ value: 6 }]
    }
  ]
};


console.log([...traverse(tree)]); // [1, 2, 4, 5, 3, 6]
````

**Nested Structure Flattening:**
```javascript
function* flatten(arr) {
  for (const item of arr) {
    if (Array.isArray(item)) {
      yield* flatten(item);
    } else {
      yield item;
    }
  }
}

const nested = [1, [2, [3, 4], 5], 6, [7, 8]];
console.log([...flatten(nested)]); // [1, 2, 3, 4, 5, 6, 7, 8]
````

**Directory Tree:**

```javascript
function* walkDirectory(dir) {
  yield dir.name;
  
  if (dir.subdirectories) {
    for (const subdir of dir.subdirectories) {
      yield* walkDirectory(subdir);
    }
  }
  
  if (dir.files) {
    yield* dir.files;
  }
}

const filesystem = {
  name: 'root',
  subdirectories: [
    {
      name: 'src',
      files: ['index.js', 'utils.js'],
      subdirectories: [
        { name: 'components', files: ['App.js'] }
      ]
    },
    { name: 'tests', files: ['test.js'] }
  ]
};

console.log([...walkDirectory(filesystem)]);
// ['root', 'src', 'index.js', 'utils.js', 'components', 'App.js', 'tests', 'test.js']
```

### Delegation with Return Values

**Capturing Return Values:**

```javascript
function* inner() {
  yield 1;
  yield 2;
  return 'inner done';
}

function* outer() {
  const result = yield* inner();
  console.log('Inner returned:', result);
  yield 3;
}

console.log([...outer()]);
// Logs: "Inner returned: inner done"
// [1, 2, 3]
```

**Chaining with Return Values:**

```javascript
function* step1() {
  yield 'step1-a';
  yield 'step1-b';
  return 'result1';
}

function* step2(input) {
  yield `step2-${input}`;
  return 'result2';
}

function* pipeline() {
  const r1 = yield* step1();
  const r2 = yield* step2(r1);
  return r2;
}

const gen = pipeline();
console.log([...gen]); // ['step1-a', 'step1-b', 'step2-result1']
```

### Bidirectional Communication

**Passing Values Through Delegation:**

```javascript
function* inner() {
  const a = yield 1;
  console.log('Inner received:', a);
  const b = yield 2;
  console.log('Inner received:', b);
  return a + b;
}

function* outer() {
  const result = yield* inner();
  console.log('Final result:', result);
  yield result;
}

const gen = outer();
console.log(gen.next());      // { value: 1, done: false }
console.log(gen.next(10));    // Logs "Inner received: 10"
                               // { value: 2, done: false }
console.log(gen.next(20));    // Logs "Inner received: 20"
                               // Logs "Final result: 30"
                               // { value: 30, done: false }
```

**Exception Propagation:**

```javascript
function* inner() {
  try {
    yield 1;
    yield 2;
  } catch (error) {
    console.log('Inner caught:', error.message);
    yield 'recovered';
  }
}

function* outer() {
  try {
    yield* inner();
  } catch (error) {
    console.log('Outer caught:', error.message);
  }
}

const gen = outer();
gen.next();                          // { value: 1, done: false }
gen.throw(new Error('Problem'));     // Logs "Inner caught: Problem"
                                      // { value: 'recovered', done: false }
```

### Lazy Sequence Composition

**Combining Infinite Sequences:**

```javascript
function* fibonacci() {
  let [prev, curr] = [0, 1];
  while (true) {
    yield curr;
    [prev, curr] = [curr, prev + curr];
  }
}

function* primes() {
  yield 2;
  yield 3;
  let candidate = 5;
  while (true) {
    let isPrime = true;
    for (let i = 2; i <= Math.sqrt(candidate); i++) {
      if (candidate % i === 0) {
        isPrime = false;
        break;
      }
    }
    if (isPrime) yield candidate;
    candidate += 2;
  }
}

function* take(n, iterable) {
  let count = 0;
  for (const value of iterable) {
    if (count++ >= n) break;
    yield value;
  }
}

function* interleave(iter1, iter2) {
  const it1 = iter1[Symbol.iterator]();
  const it2 = iter2[Symbol.iterator]();
  
  while (true) {
    const r1 = it1.next();
    if (!r1.done) yield r1.value;
    
    const r2 = it2.next();
    if (!r2.done) yield r2.value;
    
    if (r1.done && r2.done) break;
  }
}

function* combined() {
  yield* take(5, interleave(fibonacci(), primes()));
}

console.log([...combined()]); // [1, 2, 1, 3, 2, 5, 3, 7, 5, 11]
```

**Filter and Map Composition:**

```javascript
function* filter(predicate, iterable) {
  for (const item of iterable) {
    if (predicate(item)) yield item;
  }
}

function* map(fn, iterable) {
  for (const item of iterable) {
    yield fn(item);
  }
}

function* range(start, end) {
  for (let i = start; i < end; i++) {
    yield i;
  }
}

function* pipeline() {
  yield* map(
    x => x * x,
    filter(
      x => x % 2 === 0,
      range(1, 10)
    )
  );
}

console.log([...pipeline()]); // [4, 16, 36, 64]
```

### Advanced Delegation Patterns

**Conditional Delegation:**

```javascript
function* conditionalDelegate(useA) {
  function* sequenceA() {
    yield 'A1';
    yield 'A2';
  }
  
  function* sequenceB() {
    yield 'B1';
    yield 'B2';
  }
  
  yield 'start';
  yield* (useA ? sequenceA() : sequenceB());
  yield 'end';
}

console.log([...conditionalDelegate(true)]);  // ['start', 'A1', 'A2', 'end']
console.log([...conditionalDelegate(false)]); // ['start', 'B1', 'B2', 'end']
```

**Dynamic Delegation:**

```javascript
function* dynamicDelegate(generators) {
  for (const gen of generators) {
    yield* gen();
  }
}

function* gen1() { yield 1; }
function* gen2() { yield 2; }
function* gen3() { yield 3; }

console.log([...dynamicDelegate([gen1, gen2, gen3])]); // [1, 2, 3]
```

**Delegating with Transformation:**

```javascript
function* delegateTransform(iterable, transformFn) {
  for (const value of iterable) {
    if (typeof value === 'function' && value.constructor.name === 'GeneratorFunction') {
      yield* delegateTransform(value(), transformFn);
    } else {
      yield transformFn(value);
    }
  }
}

function* nested() {
  yield 1;
  yield* [2, 3];
}

const transformed = delegateTransform(nested(), x => x * 10);
console.log([...transformed]); // [10, 20, 30]
```

### Performance Considerations

**Memory Efficiency:**

```javascript
function* largeSequence(n) {
  for (let i = 0; i < n; i++) {
    yield i;
  }
}

function* processLarge(n) {
  // Delegates without materializing the entire sequence
  yield* map(x => x * 2, filter(x => x % 2 === 0, largeSequence(n)));
}

// Processes one item at a time, O(1) memory
for (const value of take(10, processLarge(1000000))) {
  console.log(value);
}
```

**Avoiding Unnecessary Delegation:**

```javascript
// Inefficient - delegates to array which is already materialized
function* inefficient() {
  const arr = [1, 2, 3];
  yield* arr;
}

// More direct
function* efficient() {
  yield 1;
  yield 2;
  yield 3;
}

// Or if you must use an array
function* fromArray(arr) {
  for (const item of arr) {
    yield item;
  }
}
```

**Key Points:**

- `yield*` delegates to any iterable (generators, arrays, strings, etc.)
- Maintains lazy evaluation throughout the delegation chain
- Return values from delegated generators can be captured
- Bidirectional communication works through delegation
- Exceptions propagate through the delegation chain
- Essential for recursive generator patterns (tree traversal, flattening)
- Enables composition of infinite sequences
- More memory-efficient than materializing intermediate results
- Can delegate to multiple generators in sequence
- Supports dynamic selection of which generator to delegate to

