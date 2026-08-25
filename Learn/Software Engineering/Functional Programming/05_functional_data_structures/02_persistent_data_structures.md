## Persistent Data Structures


Persistent data structures preserve previous versions when modified, allowing access to both old and new versions efficiently. Unlike naive copying (which would be O(n) for every operation), persistent structures use structural sharing to achieve near-constant time operations.

```javascript
// Conceptual example using Immutable.js
const { List } = require('immutable');

const v1 = List([1, 2, 3, 4, 5]);
const v2 = v1.push(6);
const v3 = v2.set(2, 99);

console.log(v1.toArray());  // [1, 2, 3, 4, 5]
console.log(v2.toArray());  // [1, 2, 3, 4, 5, 6]
console.log(v3.toArray());  // [1, 2, 99, 4, 5, 6]

// All three versions coexist efficiently
```

Persistent data structures achieve efficiency through structural sharing - different versions share unchanged portions of their structure. For tree-based structures, this typically means O(log n) time and space overhead for modifications.

```scala
// Scala Vector (persistent, tree-based)
val v1 = Vector(1, 2, 3, 4, 5)
val v2 = v1.updated(2, 99)     // O(log n)
val v3 = v2 :+ 6               // O(log n)

// All versions remain accessible
println(v1)  // Vector(1, 2, 3, 4, 5)
println(v2)  // Vector(1, 2, 99, 4, 5)
println(v3)  // Vector(1, 2, 99, 4, 5, 6)
```

Common persistent data structures include:

- **Persistent Lists**: Singly-linked lists with O(1) prepend
- **Persistent Vectors**: Tree-based with O(log n) random access and updates
- **Persistent Maps**: Hash array mapped tries (HAMT) with O(log n) operations
- **Persistent Sets**: Similar to maps, O(log n) operations
- **Persistent Queues**: Dual-list implementation with amortized O(1) operations

```clojure
;; Clojure persistent vector
(def v1 [1 2 3 4 5])
(def v2 (assoc v1 2 99))    ;; Update index 2
(def v3 (conj v2 6))        ;; Append

v1  ;; [1 2 3 4 5]
v2  ;; [1 2 99 4 5]
v3  ;; [1 2 99 4 5 6]

;; Persistent map
(def m1 {:a 1 :b 2 :c 3})
(def m2 (assoc m1 :d 4))
(def m3 (dissoc m2 :b))

m1  ;; {:a 1, :b 2, :c 3}
m2  ;; {:a 1, :b 2, :c 3, :d 4}
m3  ;; {:a 1, :c 3, :d 4}
```

**Key Points:**

- All versions remain accessible after modifications
- Modifications create new versions without full copying
- Typically O(log n) time complexity for operations
- Space efficient through structural sharing
- Enables time-travel debugging and undo/redo functionality
- Safe for concurrent access across versions

**Example:**

```python
# Python using pyrsistent
from pyrsistent import v, m

# Persistent vector
v1 = v(1, 2, 3, 4, 5)
v2 = v1.set(2, 99)
v3 = v2.append(6)

print(v1)  # pvector([1, 2, 3, 4, 5])
print(v2)  # pvector([1, 2, 99, 4, 5])
print(v3)  # pvector([1, 2, 99, 4, 5, 6])

# Persistent map
m1 = m(a=1, b=2, c=3)
m2 = m1.set('d', 4)
m3 = m2.remove('b')

print(m1)  # pmap({'a': 1, 'b': 2, 'c': 3})
print(m2)  # pmap({'a': 1, 'b': 2, 'c': 3, 'd': 4})
print(m3)  # pmap({'a': 1, 'c': 3, 'd': 4})
```

