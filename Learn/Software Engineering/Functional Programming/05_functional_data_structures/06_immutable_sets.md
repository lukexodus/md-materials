## Immutable Sets


Immutable sets are unordered collections of unique elements that prohibit modification after creation. Operations that would alter the set return new sets with structural sharing. They provide mathematical set semantics with functional programming guarantees.

### Implementation Strategies

Immutable sets typically build on the same persistent data structures as immutable dictionaries, often using HAMT implementations where values are omitted or represented with unit types. The key serves as both identifier and stored value, with uniqueness enforced by the underlying structure.

**Example:**

```scala
// Scala immutable Set
val set1 = Set(1, 2, 3, 4)
val set2 = set1 + 5        // Returns new set with 5
val set3 = set2 - 2        // Returns new set without 2

println(set1)  // Set(1, 2, 3, 4) - unchanged
println(set3)  // Set(1, 3, 4, 5)
```

### Membership Testing

Membership tests determine whether elements exist in the set. Immutable sets achieve O(log n) lookup complexity through tree-based structures or effectively constant time with hash-based implementations like HAMT.

**Example:**

```haskell
-- Haskell Data.Set (balanced tree implementation)
import qualified Data.Set as Set

numbers = Set.fromList [1, 3, 5, 7, 9]

hasFive = Set.member 5 numbers     -- True
hasSix = Set.member 6 numbers      -- False

-- Pattern matching on membership
case Set.member x mySet of
    True  -> processFound x
    False -> processNotFound x
```

### Set Operations

Immutable sets support standard mathematical operations including union, intersection, difference, and symmetric difference. These operations create new sets while preserving input sets through structural sharing.

**Example:**

```python
# Python with frozenset (built-in immutable set)
set1 = frozenset([1, 2, 3, 4])
set2 = frozenset([3, 4, 5, 6])

union = set1 | set2              # {1, 2, 3, 4, 5, 6}
intersection = set1 & set2       # {3, 4}
difference = set1 - set2         # {1, 2}
symmetric_diff = set1 ^ set2     # {1, 2, 5, 6}

# All operations return new sets; originals unchanged
```

### Union Efficiency

Union operations merge two sets into a new set containing all elements from both. With structural sharing, unchanged subtrees from both input sets are reused in the result, minimizing allocation and copying.

**Example:**

```clojure
;; Clojure persistent set union
(def set-a #{1 2 3 4 5})
(def set-b #{4 5 6 7 8})

(def combined (clojure.set/union set-a set-b))
;; #{1 2 3 4 5 6 7 8}

;; Structural sharing reuses nodes from both input sets
;; Only nodes for conflicting/new elements require allocation
```

### Intersection and Difference

Intersection produces sets containing only elements present in all input sets. Difference removes elements of one set from another. Both operations benefit from structural sharing when results overlap significantly with input sets.

**Example:**

```fsharp
// F# immutable Set
let setA = Set.ofList [1; 2; 3; 4; 5]
let setB = Set.ofList [4; 5; 6; 7; 8]

let common = Set.intersect setA setB      // set [4; 5]
let onlyInA = Set.difference setA setB    // set [1; 2; 3]

// Filter-like operations
let evens = Set.filter (fun x -> x % 2 = 0) setA  // set [2; 4]
```

### Subset and Superset Relations

Immutable sets support querying subset and superset relationships, determining whether one set contains all elements of another. These predicates enable algebraic reasoning about set containment.

**Example:**

```python
# Python frozenset subset checks
all_colors = frozenset(['red', 'blue', 'green', 'yellow'])
primary = frozenset(['red', 'blue', 'yellow'])
rgb = frozenset(['red', 'green', 'blue'])

is_subset = primary.issubset(all_colors)      # True
is_superset = all_colors.issuperset(rgb)      # True
proper_subset = rgb < all_colors              # True (proper)
```

### Filtering and Transformation

Functional operations like filter and map apply to immutable sets, producing new sets. Map operations must handle uniqueness constraints—multiple inputs mapping to the same output collapse to a single element.

**Example:**

```scala
// Scala set transformations
val numbers = Set(1, 2, 3, 4, 5, 6)

val evens = numbers.filter(_ % 2 == 0)        // Set(2, 4, 6)
val doubled = numbers.map(_ * 2)              // Set(2, 4, 6, 8, 10, 12)

// Map can reduce size due to uniqueness
val modulo = Set(1, 2, 3, 4, 5).map(_ % 3)   // Set(0, 1, 2)
// 3%3=0, 4%3=1, 5%3=2 collapse with earlier values
```

### Ordered vs Unordered Sets

Standard immutable sets maintain no particular element order. Ordered immutable sets (like TreeSet) maintain elements in sorted order, typically implemented with balanced trees. This enables range queries and ordered iteration at the cost of requiring comparable elements.

**Example:**

```java
// Java with Guava's ImmutableSet and ImmutableSortedSet
ImmutableSet<Integer> unordered = ImmutableSet.of(3, 1, 4, 1, 5);
// Elements in arbitrary order, duplicates eliminated

ImmutableSortedSet<Integer> ordered = ImmutableSortedSet.of(3, 1, 4, 1, 5);
// Elements in sorted order: [1, 3, 4, 5]

// Range operations on sorted sets
SortedSet<Integer> range = ordered.subSet(2, 5);  // [3, 4]
```

### Set Comprehension Patterns

Functional languages support set comprehensions and builder patterns for constructing immutable sets from expressions and predicates. These declarative constructs improve readability for complex set creation.

**Example:**

```haskell
-- Haskell set comprehension
import qualified Data.Set as Set

-- Set of squares less than 100
squares = Set.fromList [x*x | x <- [1..10], x*x < 100]

-- Set of even numbers from another set
evens = Set.filter even (Set.fromList [1..20])

-- Cartesian product elements
pairs = Set.fromList [(x,y) | x <- [1,2,3], y <- ['a','b']]
```

### Performance Characteristics

Immutable set operations achieve logarithmic complexity for individual element operations and linear complexity for bulk operations like union and intersection. Tree-based implementations provide O(log n) guarantees while hash-based approaches approach O(1) for membership tests.

**Key Points:**

- Insert: O(log n) with structural sharing
- Delete: O(log n) creating new version
- Membership: O(log n) to O(1) depending on implementation
- Union/Intersection: O(n + m) where n, m are set sizes
- Iteration: O(n) across all elements

### Memory Considerations

Structural sharing between set versions minimizes memory overhead, but applications retaining many intermediate set versions can accumulate significant memory. Bulk operations that build temporary intermediate results benefit from transient optimizations where available.

**Example:**

```clojure
;; Clojure transient sets for bulk construction
(defn build-large-set [n]
  (persistent!
    (reduce (fn [s i] (conj! s i))
            (transient #{})
            (range n))))

;; Transient accumulation avoids intermediate immutable sets
;; Final persistent! call produces immutable result
```

### Use Case Selection

Choose immutable sets when element uniqueness, mathematical set semantics, and safe sharing are priorities. The immutability guarantee enables fearless concurrent access and simplifies reasoning about data flow. For performance-critical scenarios with localized mutation, mutable sets may be preferable.

**Key Points:**

- Immutable sets enforce uniqueness with no modification after creation
- Built on persistent data structures like HAMT or balanced trees
- Support mathematical operations: union, intersection, difference
- Structural sharing optimizes memory and performance
- O(log n) operations with hash-based approaches nearing O(1)
- Ordered variants enable sorted iteration and range queries
- Thread-safe reads without synchronization
- Choose based on sharing needs versus raw performance requirements

