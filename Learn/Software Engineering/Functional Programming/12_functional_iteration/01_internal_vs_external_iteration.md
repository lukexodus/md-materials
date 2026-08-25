## Internal vs external iteration


Internal and external iteration represent fundamentally different control flow patterns for traversing collections. External iteration gives the caller control over iteration progress, while internal iteration transfers control to the collection or iteration function. This distinction affects composability, control flow, and how iteration integrates with functional programming patterns.

**External iteration characteristics:**

External iteration places the caller in control. The caller explicitly requests each element, decides when to continue, and can stop iteration at any point. The iterator is a stateful object that tracks position and responds to requests for the next element.

```python
# External iteration
iterator = iter([1, 2, 3, 4, 5])
while True:
    try:
        value = next(iterator)
        if value > 3:
            break
        print(value)
    except StopIteration:
        break
```

The calling code drives iteration. It decides whether to request the next element, can interleave operations between elements, and maintains complete control over iteration flow. The iterator merely responds to requests—it doesn't determine how or when elements are consumed.

**Internal iteration characteristics:**

Internal iteration inverts control. The caller passes a function to the collection or iterator, which then applies that function to each element. The collection controls iteration progress, deciding when and how to traverse elements.

```haskell
-- Internal iteration
forEach [1, 2, 3, 4, 5] print

-- Or with higher-order functions
map (*2) [1, 2, 3, 4, 5]
filter (>3) [1, 2, 3, 4, 5]
```

The collection determines iteration order and timing. The caller provides behavior (the function to apply) but surrenders control over iteration mechanics. Early termination requires special mechanisms like exceptions or short-circuiting combinators.

**Control flow implications:**

External iteration allows arbitrary control flow within the iteration loop. The caller can break early, skip elements conditionally, or perform complex branching based on iteration state.

```rust
// External iteration with complex control flow
let mut iter = vec![1, 2, 3, 4, 5].into_iter();
let mut sum = 0;
loop {
    match iter.next() {
        Some(x) if x % 2 == 0 => sum += x,
        Some(x) if x > 4 => break,
        Some(_) => continue,
        None => break,
    }
}
```

Internal iteration makes complex control flow awkward. Early termination requires either processing all elements or using control flow mechanisms like exceptions that break functional programming principles. Skipping elements requires building that logic into the passed function.

**Composability differences:**

Internal iteration composes naturally through function composition. Operations like map, filter, and reduce chain together declaratively, each receiving the output of the previous operation.

```scala
// Internal iteration composition
List(1, 2, 3, 4, 5)
  .filter(_ % 2 == 0)
  .map(_ * 2)
  .reduce(_ + _)
```

Each operation is independent and composable. The pipeline expresses what to compute, not how to iterate. This declarative style aligns with functional programming principles.

External iteration composition requires manually connecting iterators, typically through wrapper iterators that transform or filter the underlying iterator. This is more verbose but provides finer control.

```python
# External iteration composition
iterator = iter([1, 2, 3, 4, 5])
filtered = filter(lambda x: x % 2 == 0, iterator)
mapped = map(lambda x: x * 2, filtered)
result = sum(mapped)
```

**State management:**

External iterators carry explicit state—a position, index, or cursor tracking progress. This state must be managed, passed around, and eventually cleaned up. Multiple consumers of an iterator must coordinate or clone the iterator.

```java
Iterator<Integer> iter = list.iterator();
processFirst(iter);  // Advances iterator
processRest(iter);   // Continues from where processFirst stopped
// State is shared and mutation is visible
```

Internal iteration hides state within the iteration mechanism. The collection or iterator manages position internally, and consumer functions remain stateless. This eliminates state coordination problems but reduces flexibility.

**Laziness and evaluation:**

External iteration naturally supports laziness. Elements are computed only when requested via `next()`. Infinite sequences work because the consumer controls how many elements to request.

```haskell
-- External iteration (conceptual)
let naturals = iterate (+1) 0
take 10 naturals  -- Only evaluates 10 elements
```

Internal iteration can support laziness through lazy evaluation of the collection itself, but the iteration function typically processes all elements it receives. Short-circuiting requires special combinators like `takeWhile` or `find`.

**Performance considerations:**

External iteration incurs overhead from iterator state management and function calls per element. Each `next()` call is a method invocation with associated costs. However, external iteration allows fine-grained control over resource usage and can stop immediately when conditions are met.

Internal iteration can optimize better since the collection controls iteration. It can use specialized loops, vectorization, or parallel execution without exposing these details to callers. The collection knows its structure and can iterate efficiently.

**Parallel execution:**

Internal iteration enables automatic parallelization. Since the collection controls iteration, it can distribute work across threads transparently.

```java
// Internal iteration - easily parallelized
list.parallelStream()
    .filter(x -> x % 2 == 0)
    .map(x -> x * 2)
    .sum();
```

External iteration parallelizes awkwardly because the caller controls iteration order. Splitting work requires manually partitioning the iterator and coordinating results.

**[Inference] Choosing between patterns:**

Internal iteration dominates in functional programming because it composes naturally, hides state, and expresses intent declaratively. External iteration provides more control and works better for complex iteration logic, resource management, or interleaving multiple iterations. Languages often support both—internal for typical functional operations, external for scenarios requiring fine control.

