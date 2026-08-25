## Iterator protocol


The iterator protocol defines the interface iterators must implement to participate in language iteration mechanisms. This protocol standardizes how iterators produce values, signal completion, and integrate with language constructs like loops and comprehensions. Different languages have variations, but common patterns emerge.

**Core iterator methods:**

Most iterator protocols center on a method that produces the next element. Python uses `__next__()`, Java uses `next()`, Rust uses `next()`, JavaScript uses `next()`.

```python
class CounterIterator:
    def __init__(self, max_count):
        self.count = 0
        self.max_count = max_count
    
    def __next__(self):
        if self.count >= self.max_count:
            raise StopIteration
        self.count += 1
        return self.count
    
    def __iter__(self):
        return self
```

The `__next__()` method returns the next element or signals completion. Completion signaling varies by language—Python raises `StopIteration`, Rust returns `Option<T>` (None for completion), Java throws `NoSuchElementException` or requires checking `hasNext()` first.

**Completion signaling:**

Different languages handle iteration completion differently, each with tradeoffs.

Python uses exceptions for control flow—`StopIteration` signals completion. This allows `next()` to return any value type without reserving special completion markers, but uses exceptions for expected control flow.

```python
iterator = iter([1, 2, 3])
while True:
    try:
        value = next(iterator)
        print(value)
    except StopIteration:
        break
```

Rust uses `Option<T>` where `Some(value)` contains the next element and `None` signals completion. This makes completion explicit in the type system without exceptions.

```rust
let mut iter = vec![1, 2, 3].into_iter();
while let Some(value) = iter.next() {
    println!("{}", value);
}
```

JavaScript returns objects with `{ value, done }` structure where `done: true` signals completion. This allows retrieving the final return value alongside completion status.

```javascript
const iterator = [1, 2, 3][Symbol.iterator]();
let result = iterator.next();
while (!result.done) {
    console.log(result.value);
    result = iterator.next();
}
```

**Iterator self-reference:**

Many protocols require iterators to implement the iterable protocol by returning themselves from the iterator-creation method. This allows iterators to be used anywhere iterables are expected.

```python
class MyIterator:
    def __iter__(self):
        return self  # Iterator returns itself
    
    def __next__(self):
        # Produce next value
        pass

# Can use iterator directly in for loops
iterator = MyIterator()
for value in iterator:  # Works because __iter__ returns self
    print(value)
```

This pattern enables iterators to seamlessly integrate with language constructs expecting iterables, avoiding the need to wrap iterators before use.

**State management requirements:**

The iterator protocol implicitly requires iterators to maintain whatever state is necessary to track iteration progress. This might be an index, cursor, internal buffer, or computed values.

```rust
struct RangeIterator {
    current: i32,
    end: i32,
}

impl Iterator for RangeIterator {
    type Item = i32;
    
    fn next(&mut self) -> Option<i32> {
        if self.current < self.end {
            let value = self.current;
            self.current += 1;  // Mutate state
            Some(value)
        } else {
            None
        }
    }
}
```

Mutable state is required even in functional languages because iterators inherently represent changing position through a sequence. The protocol demands methods that mutate iterator state to advance position.

**Type parameters and associated types:**

Strongly-typed languages include element type information in the iterator protocol. Rust uses associated types, Haskell uses type parameters, Java uses generics.

```rust
trait Iterator {
    type Item;  // Associated type for element type
    
    fn next(&mut self) -> Option<Self::Item>;
}

// Implementation specifies concrete Item type
impl Iterator for MyIterator {
    type Item = i32;
    // ...
}
```

Type parameters ensure type safety—the compiler knows what types iterators produce and can verify correct usage at compile time. Generic code can work with iterators of any element type while maintaining type guarantees.

**Additional protocol methods:**

Beyond the core next method, iterator protocols often include optional methods for optimization or convenience.

```rust
trait Iterator {
    type Item;
    fn next(&mut self) -> Option<Self::Item>;
    
    // Optional methods with default implementations
    fn size_hint(&self) -> (usize, Option<usize>) {
        (0, None)
    }
    
    fn count(self) -> usize {
        self.fold(0, |count, _| count + 1)
    }
    
    fn nth(&mut self, n: usize) -> Option<Self::Item> {
        for _ in 0..n {
            self.next()?;
        }
        self.next()
    }
}
```

Implementations can override these methods for efficiency. For example, an array iterator knows its exact size and can implement `size_hint()` to return that information, enabling optimizations in consuming code.

**Double-ended iteration:**

Some iterator protocols support bidirectional iteration through additional methods. Rust's `DoubleEndedIterator` adds `next_back()` to consume elements from the end.

```rust
let mut iter = vec![1, 2, 3, 4, 5].into_iter();
iter.next();        // Some(1) from front
iter.next_back();   // Some(5) from back
iter.next();        // Some(2) from front
iter.next_back();   // Some(4) from back
```

This enables efficient reverse iteration and algorithms that need to examine sequences from both ends simultaneously without collecting into intermediate structures.

**Integration with language constructs:**

Iterator protocols integrate deeply with language syntax. For loops, comprehensions, and destructuring automatically invoke iterator protocol methods.

```python
# for loop automatically calls __iter__() then repeatedly calls __next__()
for value in iterable:
    print(value)

# Comprehensions use iterator protocol
result = [x * 2 for x in iterable]

# Unpacking uses iterator protocol
a, b, c = iterable
```

This syntactic integration makes iterators feel like first-class language features rather than library abstractions. The protocol provides the contract that enables this integration.

