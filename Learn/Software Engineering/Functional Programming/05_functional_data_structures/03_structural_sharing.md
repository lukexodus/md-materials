## Structural Sharing


Structural sharing is the technique that makes persistent data structures efficient. Instead of copying entire structures on modification, only the path from the root to the changed element is copied, while unchanged subtrees are shared between versions.

```
Original tree:        After modifying leaf:
      A                     A'
     / \                   / \
    B   C                 B'  C (shared)
   / \ / \               / \ / \
  D  E F  G             D' E F  G (shared)

Only A, B, and D are copied; C, E, F, G are shared
```

For a binary tree of height h, this means:

- Time complexity: O(h) = O(log n) for n elements
- Space complexity: O(h) = O(log n) new nodes
- Shared nodes: O(n - h) = O(n) nodes reused

```javascript
// Conceptual implementation of structural sharing in a binary tree
class Node {
    constructor(value, left = null, right = null) {
        this.value = value;
        this.left = left;
        this.right = right;
    }
    
    // Update creates new path, shares unchanged subtrees
    update(path, newValue) {
        if (path.length === 0) {
            return new Node(newValue, this.left, this.right);
        }
        
        const [direction, ...rest] = path;
        if (direction === 'left') {
            return new Node(
                this.value,
                this.left ? this.left.update(rest, newValue) : null,
                this.right  // Shared - not copied
            );
        } else {
            return new Node(
                this.value,
                this.left,  // Shared - not copied
                this.right ? this.right.update(rest, newValue) : null
            );
        }
    }
}

// Usage
const tree1 = new Node(1,
    new Node(2, new Node(4), new Node(5)),
    new Node(3, new Node(6), new Node(7))
);

const tree2 = tree1.update(['left', 'left'], 99);
// tree1 unchanged, tree2 shares most nodes with tree1
```

Hash Array Mapped Tries (HAMT) use structural sharing for efficient persistent maps and sets:

```clojure
;; Clojure's persistent map uses HAMT with structural sharing
(def m1 (zipmap (range 1000) (range 1000)))  ; 1000 entries
(def m2 (assoc m1 500 :modified))            ; Modify one entry

;; m2 shares most of its structure with m1
;; Only the path to key 500 is copied (~6 nodes for 1000 entries)
```

The branching factor affects efficiency. Common implementations use:

- **Binary trees**: 2-way branching, height = log₂(n)
- **32-way tries**: Used in Clojure, height ≈ log₃₂(n)
- **Hash tables**: HAMT with 32-way branching at each level

```scala
// Scala Vector uses 32-way branching
val v1 = Vector.range(0, 1000)
val v2 = v1.updated(500, 9999)

// With 32-way branching:
// Height = log₃₂(1000) ≈ 2
// Only ~2 nodes copied, rest shared
```

**Key Points:**

- Only modified paths are copied, unchanged parts are shared
- Achieves O(log n) time and space for modifications
- Memory efficiency increases with structure size
- Higher branching factors reduce tree height
- Enables cheap snapshots and version control
- GC can reclaim unreferenced versions

**Example:**

```python
# Conceptual persistent list with structural sharing
class PersistentList:
    class Node:
        def __init__(self, value, next_node=None):
            self.value = value
            self.next = next_node
    
    def __init__(self, head=None):
        self.head = head
    
    def cons(self, value):
        """Add element to front - O(1), shares tail"""
        new_head = self.Node(value, self.head)
        return PersistentList(new_head)
    
    def tail(self):
        """Get rest of list - O(1), shares structure"""
        if self.head is None:
            return PersistentList()
        return PersistentList(self.head.next)
    
    def to_python_list(self):
        result = []
        current = self.head
        while current:
            result.append(current.value)
            current = current.next
        return result

# Usage
list1 = PersistentList()
list2 = list1.cons(3).cons(2).cons(1)  # [1, 2, 3]
list3 = list2.cons(0)                   # [0, 1, 2, 3]

# list2 and list3 share nodes [1, 2, 3]
print(list2.to_python_list())  # [1, 2, 3]
print(list3.to_python_list())  # [0, 1, 2, 3]
```

