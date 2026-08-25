## Infinite Sequences


Infinite sequences are data structures that conceptually have no end, made practical through lazy evaluation. They generate values on-demand rather than storing all values in memory.

### Basic Infinite Generator

```javascript
function* infiniteSequence() {
  let i = 0;
  while (true) {
    yield i++;
  }
}

const seq = infiniteSequence();
console.log(seq.next().value); // 0
console.log(seq.next().value); // 1
console.log(seq.next().value); // 2
// Can continue indefinitely
```

### Natural Numbers

```javascript
function* naturals(start = 1) {
  let n = start;
  while (true) {
    yield n++;
  }
}

const takeN = (n, iterable) => {
  const result = [];
  const iterator = iterable[Symbol.iterator]();
  for (let i = 0; i < n; i++) {
    result.push(iterator.next().value);
  }
  return result;
};

console.log(takeN(5, naturals())); // [1, 2, 3, 4, 5]
console.log(takeN(5, naturals(100))); // [100, 101, 102, 103, 104]
```

### Fibonacci Sequence

```javascript
function* fibonacci() {
  let [a, b] = [0, 1];
  while (true) {
    yield a;
    [a, b] = [b, a + b];
  }
}

console.log(takeN(10, fibonacci()));
// [0, 1, 1, 2, 3, 5, 8, 13, 21, 34]

// Get the 1000th Fibonacci number without generating all previous ones
function nth(n, iterable) {
  const iterator = iterable[Symbol.iterator]();
  let result;
  for (let i = 0; i <= n; i++) {
    result = iterator.next().value;
  }
  return result;
}

console.log(nth(20, fibonacci())); // 6765
```

### Prime Numbers

```javascript
function* primes() {
  yield 2;
  const primeList = [2];
  let candidate = 3;
  
  while (true) {
    const isPrime = primeList.every(prime => {
      if (prime * prime > candidate) return true;
      return candidate % prime !== 0;
    });
    
    if (isPrime) {
      primeList.push(candidate);
      yield candidate;
    }
    candidate += 2; // Skip even numbers
  }
}

console.log(takeN(10, primes()));
// [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
```

### Cyclic Sequences

```javascript
function* cycle(iterable) {
  const saved = [];
  for (const item of iterable) {
    yield item;
    saved.push(item);
  }
  while (saved.length > 0) {
    yield* saved;
  }
}

const colors = cycle(['red', 'green', 'blue']);
console.log(takeN(7, colors));
// ['red', 'green', 'blue', 'red', 'green', 'blue', 'red']
```

### Repeat Values

```javascript
function* repeat(value, times = Infinity) {
  for (let i = 0; i < times; i++) {
    yield value;
  }
}

console.log(takeN(5, repeat('hello')));
// ['hello', 'hello', 'hello', 'hello', 'hello']

// Infinite repetition
const infiniteOnes = repeat(1);
console.log(takeN(3, infiniteOnes)); // [1, 1, 1]
```

### Random Number Stream

```javascript
function* randomStream(min = 0, max = 1) {
  while (true) {
    yield Math.random() * (max - min) + min;
  }
}

const randoms = randomStream(1, 100);
console.log(takeN(5, randoms));
// [47.23, 82.91, 15.44, 63.77, 28.12] (example values)
```

### Transforming Infinite Sequences

```javascript
function* map(iterable, fn) {
  for (const item of iterable) {
    yield fn(item);
  }
}

function* filter(iterable, predicate) {
  for (const item of iterable) {
    if (predicate(item)) {
      yield item;
    }
  }
}

// Square all natural numbers
const squares = map(naturals(), x => x * x);
console.log(takeN(5, squares)); // [1, 4, 9, 16, 25]

// Only even squares
const evenSquares = filter(squares, x => x % 2 === 0);
console.log(takeN(5, evenSquares)); // [4, 16, 36, 64, 100]
```

### Merging Infinite Sequences

```javascript
function* merge(...iterables) {
  const iterators = iterables.map(it => it[Symbol.iterator]());
  let index = 0;
  
  while (true) {
    yield iterators[index].next().value;
    index = (index + 1) % iterators.length;
  }
}

const evens = map(naturals(), x => x * 2);
const odds = map(naturals(), x => x * 2 - 1);

const merged = merge(evens, odds);
console.log(takeN(10, merged));
// [2, 1, 4, 3, 6, 5, 8, 7, 10, 9]
```

### Scan (Cumulative Operations)

```javascript
function* scan(iterable, fn, initial) {
  let accumulator = initial;
  yield accumulator;
  
  for (const item of iterable) {
    accumulator = fn(accumulator, item);
    yield accumulator;
  }
}

const runningSum = scan(naturals(), (acc, x) => acc + x, 0);
console.log(takeN(6, runningSum));
// [0, 1, 3, 6, 10, 15] - cumulative sums
```

### Zip Infinite Sequences

```javascript
function* zip(...iterables) {
  const iterators = iterables.map(it => it[Symbol.iterator]());
  
  while (true) {
    const values = iterators.map(it => it.next().value);
    yield values;
  }
}

const coords = zip(naturals(), naturals(10), naturals(100));
console.log(takeN(3, coords));
// [[1, 10, 100], [2, 11, 101], [3, 12, 102]]
```

### TakeWhile for Conditional Limits

```javascript
function* takeWhile(iterable, predicate) {
  for (const item of iterable) {
    if (!predicate(item)) break;
    yield item;
  }
}

const numbersUnder100 = takeWhile(naturals(), x => x < 100);
console.log([...numbersUnder100].length); // 99

const fibsUnder1000 = takeWhile(fibonacci(), x => x < 1000);
console.log([...fibsUnder1000]);
// [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610, 987]
```

### Drop Elements

```javascript
function* drop(n, iterable) {
  const iterator = iterable[Symbol.iterator]();
  
  // Skip first n elements
  for (let i = 0; i < n; i++) {
    iterator.next();
  }
  
  // Yield remaining
  while (true) {
    const { value, done } = iterator.next();
    if (done) break;
    yield value;
  }
}

const after10 = drop(10, naturals());
console.log(takeN(5, after10)); // [11, 12, 13, 14, 15]
```

### Arithmetic Sequences

```javascript
function* arithmeticSequence(start, step) {
  let current = start;
  while (true) {
    yield current;
    current += step;
  }
}

const multiplesOf7 = arithmeticSequence(7, 7);
console.log(takeN(5, multiplesOf7)); // [7, 14, 21, 28, 35]
```

### Geometric Sequences

```javascript
function* geometricSequence(start, ratio) {
  let current = start;
  while (true) {
    yield current;
    current *= ratio;
  }
}

const powersOf2 = geometricSequence(1, 2);
console.log(takeN(10, powersOf2));
// [1, 2, 4, 8, 16, 32, 64, 128, 256, 512]
```

### Haskell-Style Infinite Lists

**Haskell:**

```haskell
-- Natural numbers
nats = [1..]

-- Take first 5
take 5 nats  -- [1,2,3,4,5]

-- Fibonacci
fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
take 10 fibs  -- [0,1,1,2,3,5,8,13,21,34]

-- Primes (simple sieve)
primes = sieve [2..]
  where sieve (p:xs) = p : sieve [x | x <- xs, x `mod` p /= 0]
```

### Date Sequence

```javascript
function* dateSequence(start, intervalMs = 86400000) {
  let current = new Date(start);
  while (true) {
    yield new Date(current);
    current = new Date(current.getTime() + intervalMs);
  }
}

const dailyDates = dateSequence('2024-01-01');
console.log(takeN(3, dailyDates).map(d => d.toISOString().split('T')[0]));
// ['2024-01-01', '2024-01-02', '2024-01-03']
```

**Key Points:**

- Infinite sequences generate values on-demand, never storing the entire sequence
- Enable mathematical and computational patterns without memory constraints
- Composable through standard functional operations (map, filter, zip)
- Require termination conditions (take, takeWhile) for consumption
- Only compute values actually needed by the program
- Natural fit for streams, pagination, and continuous data

---

