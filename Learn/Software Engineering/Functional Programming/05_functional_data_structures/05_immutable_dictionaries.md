## Immutable Dictionaries


Immutable dictionaries are key-value data structures that prohibit modification after creation. Any operation that would alter the dictionary instead produces a new dictionary, preserving the original. This immutability enables safe sharing, concurrent access, and predictable behavior in functional programming.

### Structural Sharing

Immutable dictionaries employ structural sharing to avoid copying the entire structure on modifications. When creating a new version, unchanged portions of the internal tree structure are reused, with only the modified path requiring new nodes. This optimization makes immutable operations practical with minimal memory and time overhead.

**Example:**

```python
# Conceptual representation of structural sharing
original = {'a': 1, 'b': 2, 'c': 3, 'd': 4}
modified = original.with_key('b', 5)
# Only nodes in path to 'b' are copied; 'a', 'c', 'd' nodes shared
```

### Persistent Data Structure Implementation

Immutable dictionaries are typically implemented as persistent data structures using balanced trees like Hash Array Mapped Tries (HAMT) or Red-Black trees. These structures maintain O(log n) performance for operations while enabling efficient structural sharing across versions.

**Example:**

```scala
// Scala immutable Map (uses HAMT internally)
val map1 = Map("x" -> 10, "y" -> 20)
val map2 = map1 + ("z" -> 30)  // Returns new map
val map3 = map2 - "x"           // Returns new map

// map1 remains unchanged
println(map1)  // Map(x -> 10, y -> 20)
```

### Hash Array Mapped Trie (HAMT)

HAMT represents the most common implementation strategy for immutable dictionaries. Keys are hashed, and the hash bits determine the path through a 32-way or 64-way branching tree. Collision handling uses additional tree levels or small arrays at leaf nodes.

The tree structure divides hash codes into segments, with each segment indexing into a node's array of children. Bitmap compression eliminates empty slots, storing only populated entries. This combines fast lookups with memory efficiency.

**Example:**

```clojure
;; Clojure's persistent hash map uses HAMT
(def m1 {:a 1 :b 2 :c 3})
(def m2 (assoc m1 :d 4))  ; New map with structural sharing

;; Internal structure (conceptual):
;; Root node contains bitmap indicating occupied slots
;; Hash of :d determines path through tree levels
;; Only nodes along that path are copied
```

### Operation Complexity

Immutable dictionary operations achieve O(log₃₂ n) or O(log₆₄ n) complexity with HAMT implementations, effectively constant time for practical dataset sizes. The logarithmic base is large due to wide branching factors. Insert, delete, and lookup all maintain this performance.

**Key Points:**

- Lookup: O(log n) with large base, practically constant
- Insert: O(log n) with structural sharing
- Delete: O(log n) creates new version
- Iteration: O(n) across all entries
- Memory: O(n) with sharing benefits

### Functional Update Patterns

Update operations return new dictionaries while preserving originals. Common patterns include adding entries, removing entries, and updating values. Languages provide various syntactic conveniences for these operations.

**Example:**

```haskell
-- Haskell Data.Map (immutable by default)
import qualified Data.Map as Map

original = Map.fromList [("a", 1), ("b", 2)]
added = Map.insert "c" 3 original
removed = Map.delete "a" original
updated = Map.adjust (+10) "b" original

-- All operations return new maps; original unchanged
```

### Merging and Combining

Immutable dictionaries support functional merge operations that combine multiple dictionaries according to specified rules. Merge strategies handle key conflicts through functions that determine resulting values.

**Example:**

```python
# Python with pyrsistent library
from pyrsistent import pmap

dict1 = pmap({'a': 1, 'b': 2})
dict2 = pmap({'b': 3, 'c': 4})

# Union with right preference
merged = dict1.update(dict2)  # {'a': 1, 'b': 3, 'c': 4}

# Custom merge function
def add_values(v1, v2):
    return v1 + v2

# Merge with combining function (conceptual)
combined = dict1.merge(dict2, combine=add_values)
```

### Transient Optimization

Some implementations provide transient variants for building dictionaries through many sequential operations. Transients temporarily allow mutation for performance, then convert back to immutable structures. This optimization avoids intermediate allocation during bulk construction.

**Example:**

```clojure
;; Clojure transient optimization
(def large-map
  (persistent!
    (reduce (fn [m i] (assoc! m i (* i i)))
            (transient {})
            (range 10000))))

;; transient creates mutable builder
;; assoc! mutates during construction
;; persistent! converts to immutable map
```

### Concurrent Access Safety

Immutability eliminates race conditions and synchronization requirements for concurrent reads. Multiple threads safely access the same dictionary without locks. Updates produce new versions visible only to the updating thread until explicitly shared.

**Example:**

```scala
// Scala - safe concurrent access
val sharedMap = Map("counter" -> 0, "status" -> "active")

// Thread 1
val updated1 = sharedMap + ("counter" -> 1)

// Thread 2  
val updated2 = sharedMap + ("counter" -> 2)

// No interference; each thread has independent version
// sharedMap remains unchanged at original value
```

### Memory Efficiency Considerations

While structural sharing minimizes overhead, long-lived reference chains can prevent garbage collection of old versions. Applications should avoid retaining references to obsolete dictionary versions when memory is constrained.

**Example:**

```javascript
// JavaScript with Immutable.js
const { Map } = require('immutable');

let current = Map({counter: 0});

// Problematic - retains all versions
const history = [];
for (let i = 0; i < 10000; i++) {
    current = current.set('counter', i);
    history.push(current);  // Retains every version
}

// Better - only retain current
let current2 = Map({counter: 0});
for (let i = 0; i < 10000; i++) {
    current2 = current2.set('counter', i);
    // Old versions eligible for GC
}
```

### Comparison with Mutable Dictionaries

Immutable dictionaries trade slightly slower individual operations for benefits in reasoning, testing, and concurrency. The performance gap narrows with persistent data structure optimizations. Choose immutable dictionaries when value semantics and predictability outweigh raw performance needs.

**Example:**

```python
# Mutable dictionary
mutable = {'a': 1, 'b': 2}
mutable['c'] = 3  # Modifies in place
# Original state lost

# Immutable dictionary (conceptual Python)
immutable = ImmutableDict({'a': 1, 'b': 2})
updated = immutable.set('c', 3)  # Returns new dict
# immutable still {'a': 1, 'b': 2}
# updated is {'a': 1, 'b': 2, 'c': 3}
```

**Key Points:**

- Immutable dictionaries prevent modification, returning new versions on changes
- Structural sharing via HAMT or balanced trees provides efficiency
- O(log n) operations with large branching factors approach constant time
- Thread-safe reads without synchronization overhead
- Transient builders optimize bulk construction scenarios
- Memory efficiency requires avoiding long reference chains to old versions
- Trade individual operation speed for safety and predictability

