## Iterable protocol


The iterable protocol defines how objects expose the ability to be iterated. It specifies how to obtain an iterator from an iterable object, enabling uniform iteration over different collection types. This protocol is simpler than the iterator protocol—it primarily requires a single method that produces iterators.

**Core iterable method:**

The iterable protocol centers on a method that returns an iterator. Python uses `__iter__()`, Java uses `iterator()`, JavaScript uses `[Symbol.iterator]()`, Rust uses `into_iter()`, `iter()`, or `iter_mut()`.

```python
class MyCollection:
    def __init__(self, data):
        self.data = data
    
    def __iter__(self):
        return MyIterator(self.data)

class MyIterator:
    def __init__(self, data):
        self.data = data
        self.index = 0
    
    def __next__(self):
        if self.index >= len(self.data):
            raise StopIteration
        value = self.data[self.index]
        self.index += 1
        return value
    
    def __iter__(self):
        return self
```

The `__iter__()` method creates and returns a fresh iterator positioned at the beginning. Each call to `__iter__()` produces an independent iterator, allowing multiple simultaneous iterations over the same iterable.

**Idempotency and multiple iterations:**

Calling the iterable protocol method multiple times should produce multiple independent iterators. This allows reusing collections and iterating them multiple times without exhausting the iterable.

```scala
val list = List(1, 2, 3, 4, 5)

val iter1 = list.iterator  // First iterator
val iter2 = list.iterator  // Second independent iterator

iter1.next()  // 1
iter1.next()  // 2
iter2.next()  // 1 (independent position)
```

The iterable remains unchanged—it's a factory for iterators. This contrasts with one-time iterables (generators) that produce iterators which cannot be recreated once exhausted.

**Stateless vs stateful iterables:**

Collections implementing the iterable protocol should be stateless regarding iteration. The iterable shouldn't track any current position or iteration state—that responsibility belongs to iterators.

```rust
struct MyCollection {
    data: Vec<i32>,
    // No iteration state here
}

impl MyCollection {
    fn iter(&self) -> MyIterator {
        MyIterator {
            data: &self.data,
            index: 0,  // State lives in iterator
        }
    }
}
```

Keeping iterables stateless allows them to participate in multiple concurrent iterations. Each iterator maintains its own state, preventing interference between iterations.

**Language integration:**

The iterable protocol integrates with language-level iteration constructs. When a language construct needs to iterate, it calls the iterable protocol method to obtain an iterator, then uses the iterator protocol to consume elements.

```python
# for loop calls __iter__() on the iterable
for value in my_collection:
    print(value)

# Internally:
# iterator = my_collection.__iter__()
# while True:
#     try:
#         value = iterator.__next__()
#         print(value)
#     except StopIteration:
#         break
```

This automatic invocation makes the protocol transparent to users—they write natural-looking loops without explicitly calling protocol methods.

**Type system representation:**

Typed languages represent the iterable protocol through interfaces, traits, or type classes. These specify the contract implementers must fulfill.

```rust
// Rust doesn't have an Iterable trait, but collections implement methods
// that return iterators. The pattern is:

impl MyCollection {
    fn iter(&self) -> impl Iterator<Item = &T> {
        // Return iterator over borrowed elements
    }
    
    fn into_iter(self) -> impl Iterator<Item = T> {
        // Return iterator over owned elements
    }
}
```

```java
// Java's Iterable interface
public interface Iterable<T> {
    Iterator<T> iterator();
}

public class MyCollection<T> implements Iterable<T> {
    public Iterator<T> iterator() {
        return new MyIterator<>(this);
    }
}
```

Type system integration enables generic programming—functions can accept any iterable type and iterate uniformly regardless of concrete collection type.

**One-time iterable special case:**

Generators and streams often implement the iterable protocol but produce iterators only once. They blur the iterable-iterator distinction by being both.

```python
def my_generator():
    yield 1
    yield 2
    yield 3

gen = my_generator()  # gen is iterable
iter1 = iter(gen)      # Returns gen itself
iter2 = iter(gen)      # Returns gen again (same object)

list(iter1)  # [1, 2, 3] - exhausts gen
list(iter2)  # [] - gen already exhausted
```

Generators return themselves from `__iter__()`, making them both iterable and iterator. This violates the typical separation but works for one-time use cases where creating multiple independent iterators doesn't make sense.

**Implementing iterable for custom types:**

Custom types become iterable by implementing the protocol method. This allows them to participate in language iteration constructs and work with iteration-based libraries.

```javascript
class Range {
    constructor(start, end) {
        this.start = start;
        this.end = end;
    }
    
    [Symbol.iterator]() {
        let current = this.start;
        const end = this.end;
        
        return {
            next() {
                if (current < end) {
                    return { value: current++, done: false };
                } else {
                    return { done: true };
                }
            }
        };
    }
}

// Now Range works with for-of loops
for (let n of new Range(1, 5)) {
    console.log(n);  // 1, 2, 3, 4
}
```

Implementing the protocol grants full language integration—the custom type works anywhere built-in collections work.

**Lazy iterable implementations:**

Iterables can represent lazy computations by returning iterators that compute elements on demand rather than storing them.

```haskell
-- Infinite lazy iterable
naturals :: [Integer]
naturals = [0..]

-- Iterable computed from function
iterate :: (a -> a) -> a -> [a]
iterate f x = x : iterate f (f x)

-- Powers of 2
powersOf2 = iterate (*2) 1  -- [1, 2, 4, 8, 16, ...]
```

The iterable itself is just a description or function—no elements exist until an iterator requests them. This enables representing infinite sequences or expensive computations efficiently.

**Relationship with collection interfaces:**

The iterable protocol is often the minimal interface for sequences. Collections may implement additional protocols (indexable, sized, reversible) but iteration is fundamental.

```typescript
interface Iterable<T> {
    [Symbol.iterator](): Iterator<T>;
}

// Collections can implement Iterable plus additional capabilities
interface Collection<T> extends Iterable<T> {
    size: number;
    isEmpty(): boolean;
}
```

This layering allows generic code to work at different abstraction levels—some code only needs iteration (iterable), while other code requires random access (indexable) or size information (sized).

