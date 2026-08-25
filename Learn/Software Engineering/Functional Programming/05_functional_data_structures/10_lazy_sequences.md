## Lazy Sequences


Lazy sequences defer computation until values are actually needed, enabling efficient processing of potentially large or infinite datasets. Elements are computed on-demand rather than eagerly evaluated.

### Lazy Evaluation Mechanics

Computation is delayed through:

- **Thunks**: Zero-argument functions that encapsulate deferred computation
- **Memoization**: Caching computed values to avoid recomputation
- **Generators**: Language constructs that yield values on demand

### Lazy List Implementation

**Example:**

```javascript
class LazyList {
  constructor(head, tailThunk) {
    this.head = head;
    this._tailThunk = tailThunk;
    this._tailCache = null;
  }
  
  get tail() {
    if (this._tailCache === null && this._tailThunk !== null) {
      this._tailCache = this._tailThunk();
    }
    return this._tailCache;
  }
  
  static empty() {
    return null;
  }
  
  static cons(head, tailThunk) {
    return new LazyList(head, tailThunk);
  }
}

function take(n, lazyList) {
  if (n === 0 || lazyList === null) return [];
  return [lazyList.head, ...take(n - 1, lazyList.tail)];
}

function map(fn, lazyList) {
  if (lazyList === null) return null;
  
  return LazyList.cons(
    fn(lazyList.head),
    () => map(fn, lazyList.tail)
  );
}

function filter(predicate, lazyList) {
  if (lazyList === null) return null;
  
  if (predicate(lazyList.head)) {
    return LazyList.cons(
      lazyList.head,
      () => filter(predicate, lazyList.tail)
    );
  }
  
  return filter(predicate, lazyList.tail);
}

// Create lazy list of natural numbers
function naturals(n = 0) {
  return LazyList.cons(n, () => naturals(n + 1));
}

const nums = naturals();
const evens = filter(x => x % 2 === 0, nums);
const doubledEvens = map(x => x * 2, evens);

console.log(take(5, doubledEvens));
```

**Output:**

```
[0, 4, 8, 12, 16]
```

### Benefits of Laziness

**Key Points:**

- Memory efficiency: Only computed values are stored
- Infinite data structure support
- Composition without intermediate structures
- Short-circuit evaluation: Stops when result is determined
- Separation of data generation from consumption

### Lazy Operations

**Example:**

```javascript
function range(start, end) {
  if (start > end) return null;
  return LazyList.cons(start, () => range(start + 1, end));
}

function drop(n, lazyList) {
  if (n === 0 || lazyList === null) return lazyList;
  return drop(n - 1, lazyList.tail);
}

function zipWith(fn, list1, list2) {
  if (list1 === null || list2 === null) return null;
  
  return LazyList.cons(
    fn(list1.head, list2.head),
    () => zipWith(fn, list1.tail, list2.tail)
  );
}

const ones = LazyList.cons(1, () => ones);  // Infinite ones
const fibonacci = LazyList.cons(0, () =>
  LazyList.cons(1, () =>
    zipWith((a, b) => a + b, fibonacci, fibonacci.tail)
  )
);

console.log(take(10, fibonacci));
```

**Output:**

```
[0, 1, 1, 2, 3, 5, 8, 13, 21, 34]
```

### Memoization in Lazy Sequences

Caching computed values prevents redundant calculations while maintaining lazy semantics.

**Example:**

```javascript
function memoizedLazyList(generator) {
  const cache = new Map();
  
  function get(index) {
    if (cache.has(index)) {
      return cache.get(index);
    }
    
    const value = generator(index);
    cache.set(index, value);
    return value;
  }
  
  return { get };
}

const squares = memoizedLazyList(n => n * n);
console.log(squares.get(5));  // Computed
console.log(squares.get(5));  // Retrieved from cache
```

