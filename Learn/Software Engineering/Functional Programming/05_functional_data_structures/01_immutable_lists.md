## Immutable Lists


Immutable lists are fundamental data structures where elements cannot be modified after creation. Any operation that appears to modify the list actually creates a new list, leaving the original unchanged. This immutability guarantees referential transparency and thread safety.

```javascript
// JavaScript (using immutable patterns)
const originalList = [1, 2, 3, 4, 5];

// "Modifying" creates new lists
const withAddedElement = [...originalList, 6];
const withRemovedElement = originalList.filter(x => x !== 3);
const doubled = originalList.map(x => x * 2);

console.log(originalList);        // [1, 2, 3, 4, 5] - unchanged
console.log(withAddedElement);    // [1, 2, 3, 4, 5, 6]
console.log(withRemovedElement);  // [1, 2, 4, 5]
console.log(doubled);             // [2, 4, 6, 8, 10]
```

Operations on immutable lists follow a pattern where transformation operations return new structures rather than mutating existing ones. This eliminates entire classes of bugs related to unexpected mutations and makes reasoning about code significantly easier.

```haskell
-- Haskell: lists are immutable by default
originalList = [1, 2, 3, 4, 5]

-- All operations create new lists
withAddedElement = originalList ++ [6]
withPrepended = 0 : originalList
doubled = map (*2) originalList
filtered = filter (>3) originalList

-- originalList remains [1, 2, 3, 4, 5]
```

Common operations on immutable lists include:

- **Prepending**: Adding elements to the front (O(1) in linked lists)
- **Mapping**: Transforming each element
- **Filtering**: Selecting elements based on predicates
- **Folding**: Reducing to a single value
- **Concatenation**: Combining lists

```scala
// Scala immutable lists
val original = List(1, 2, 3, 4, 5)

// Prepending (efficient)
val prepended = 0 :: original  // List(0, 1, 2, 3, 4, 5)

// Appending (less efficient)
val appended = original :+ 6   // List(1, 2, 3, 4, 5, 6)

// Transformation
val squared = original.map(x => x * x)  // List(1, 4, 9, 16, 25)

// Filtering
val evens = original.filter(_ % 2 == 0)  // List(2, 4)

// Folding
val sum = original.foldLeft(0)(_ + _)   // 15
```

**Key Points:**

- Operations return new lists instead of modifying existing ones
- Original data remains unchanged, enabling safe sharing
- Eliminates temporal coupling and state-related bugs
- Prepending is typically O(1), appending is O(n)
- Enables safe concurrent access without locks

**Example:**

```clojure
;; Clojure: persistent lists
(def original '(1 2 3 4 5))

;; cons adds to front
(def with-zero (cons 0 original))  ;; (0 1 2 3 4 5)

;; conj on lists prepends
(def with-prepended (conj original 0))  ;; (0 1 2 3 4 5)

;; original unchanged
original  ;; (1 2 3 4 5)

;; Various transformations
(map inc original)           ;; (2 3 4 5 6)
(filter even? original)      ;; (2 4)
(reduce + original)          ;; 15
(take 3 original)            ;; (1 2 3)
(drop 2 original)            ;; (3 4 5)
```

