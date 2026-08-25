## Iterators and iterables


Iterators and iterables are related but distinct concepts. An iterable is a collection or sequence that can be iterated over—it produces iterators. An iterator is a stateful object that produces successive values from an iteration, tracking position and providing elements on demand.

**Iterable definition:**

An iterable is any object capable of returning an iterator. It represents the concept of "something that can be iterated" without specifying how or maintaining iteration state. Collections like lists, sets, and maps are iterables—they can create iterators but don't themselves track iteration position.

```python
# An iterable
my_list = [1, 2, 3, 4, 5]  # List is iterable

# Can create multiple independent iterators
iter1 = iter(my_list)
iter2 = iter(my_list)

# Each iterator maintains independent state
next(iter1)  # 1
next(iter1)  # 2
next(iter2)  # 1 (independent from iter1)
```

An iterable can be iterated multiple times, each time creating a fresh iterator starting from the beginning. The iterable itself remains unchanged—it's the source of iterators, not an iterator itself.

**Iterator definition:**

An iterator is a stateful object that produces values from an iteration one at a time. It maintains a position or cursor, responds to requests for the next element, and signals when iteration completes. Once exhausted, an iterator typically cannot be reset or reused.

```scala
val iterator = List(1, 2, 3).iterator

iterator.next()  // 1
iterator.next()  // 2
iterator.next()  // 3
iterator.next()  // throws NoSuchElementException

// Iterator is exhausted and cannot be reset
```

Iterators embody the external iteration pattern—callers request elements explicitly, and the iterator maintains all state necessary to track progress and produce successive elements.

**Relationship between iterators and iterables:**

An iterable produces iterators through a standard method (typically called `iterator()`, `iter()`, or `__iter__()`). The iterable is reusable; the iterator is consumable.

```rust
let vec = vec![1, 2, 3, 4, 5];  // Vec is iterable

let iter1 = vec.iter();  // Create first iterator
let iter2 = vec.iter();  // Create second independent iterator

// vec remains usable, iterators are independent
```

This separation allows the same collection to be iterated multiple times simultaneously without interference. Each iterator maintains its own state, tracking its own position through the collection.

**Iterator invalidation:**

Iterators typically become invalid if the underlying collection is modified during iteration. This is a common source of bugs in languages with mutable collections.

```java
List<Integer> list = new ArrayList<>(Arrays.asList(1, 2, 3));
Iterator<Integer> iter = list.iterator();

list.add(4);  // Modifies collection
iter.next();  // May throw ConcurrentModificationException
```

Functional programming with immutable collections avoids this problem entirely. Since collections cannot be modified, iterators remain valid for their lifetime. Creating a "modified" collection returns a new collection, leaving the original and its iterators unaffected.

**One-time iterables:**

Some iterables can only be iterated once. These are often generators, streams, or I/O sources where producing values has effects or consumes resources.

```python
# Generator - one-time iterable
def generate_numbers():
    yield 1
    yield 2
    yield 3

gen = generate_numbers()  # gen is iterable
list(gen)  # [1, 2, 3] - consumes the iterable
list(gen)  # [] - exhausted, cannot iterate again
```

One-time iterables blur the line between iterable and iterator—they're iterables that produce iterators which cannot be recreated once exhausted. Some languages treat generators as both iterable and iterator.

**Infinite iterables:**

Iterables can represent infinite sequences. The iterable itself is finite (a function or object), but the iterators it produces generate unbounded sequences.

```haskell
-- Infinite iterable (lazy list)
naturals :: [Integer]
naturals = [0..]

-- Can create multiple independent iterators
take 5 naturals  -- [0,1,2,3,4]
take 3 naturals  -- [0,1,2] (independent)
```

Iterators over infinite sequences never exhaust naturally. Consumers must explicitly stop iteration through operations like `take`, `takeWhile`, or conditional breaks. Attempting to consume an infinite iterator completely would never terminate.

**Iterator adapters:**

Iterators often support adapters that transform or combine iterations without consuming the underlying iterator immediately. These adapters are themselves iterators, creating chains of lazy transformations.

```rust
let vec = vec![1, 2, 3, 4, 5];
let iter = vec.iter()
    .filter(|&x| x % 2 == 0)  // Returns iterator
    .map(|x| x * 2);          // Returns iterator

// No iteration has occurred yet - transformations are lazy
// Iteration happens when consumed
let result: Vec<_> = iter.collect();
```

Each adapter wraps the previous iterator, building a computation pipeline that executes when elements are actually requested. This provides efficiency through lazy evaluation while maintaining the iterator abstraction.

**Multiple iteration strategies:**

Collections often support multiple iteration strategies through different methods producing different iterators.

```rust
let vec = vec![1, 2, 3];

vec.iter()        // Borrows elements (&T)
vec.iter_mut()    // Mutably borrows elements (&mut T)
vec.into_iter()   // Consumes and owns elements (T)
```

Each strategy produces an iterator with different ownership semantics. The iterable (collection) supports all strategies; the caller chooses which iterator to create based on their needs.

**[Inference] Design rationale:**

Separating iterables from iterators provides flexibility and reusability. Collections remain pure data without iteration state. Iterators encapsulate state and can be passed around, stored, or composed. This separation enables the same collection to participate in multiple iterations simultaneously while keeping iteration state isolated and manageable.

