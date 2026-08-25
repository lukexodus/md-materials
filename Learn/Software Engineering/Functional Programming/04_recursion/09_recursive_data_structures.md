## Recursive Data Structures


Recursive data structures are defined in terms of themselves, where each element contains references to other elements of the same type. These structures naturally model hierarchical or nested relationships and are processed using recursive algorithms.

### Definition and Properties

A recursive data structure has a base case (terminal element) and a recursive case (element containing references to similar structures). This self-referential definition mirrors the recursive functions used to traverse them.

**Example:**

```javascript
// Linked List Node
class ListNode {
  constructor(value, next = null) {
    this.value = value;
    this.next = next;  // Reference to another ListNode
  }
}

// Tree Node
class TreeNode {
  constructor(value, children = []) {
    this.value = value;
    this.children = children;  // Array of TreeNodes
  }
}
```

### Linked Lists

Linked lists are the simplest recursive structure: each node contains a value and a reference to the rest of the list (which is itself a linked list or null).

**Example:**

```javascript
// Creating a linked list: 1 -> 2 -> 3
const list = new ListNode(1, 
  new ListNode(2, 
    new ListNode(3)));

// Recursive length calculation
const length = (node) => 
  node === null ? 0 : 1 + length(node.next);

// Recursive search
const contains = (node, target) =>
  node === null ? false :
  node.value === target ? true :
  contains(node.next, target);
```

### Binary Trees

Binary trees consist of nodes where each node has at most two children. The structure naturally decomposes into left and right subtrees, both of which are binary trees.

**Example:**

```javascript
class BinaryNode {
  constructor(value, left = null, right = null) {
    this.value = value;
    this.left = left;
    this.right = right;
  }
}

// Recursive tree operations
const height = (node) =>
  node === null ? 0 :
  1 + Math.max(height(node.left), height(node.right));

const sum = (node) =>
  node === null ? 0 :
  node.value + sum(node.left) + sum(node.right);

const contains = (node, target) =>
  node === null ? false :
  node.value === target ? true :
  contains(node.left, target) || contains(node.right, target);
```

### N-ary Trees

N-ary trees allow each node to have an arbitrary number of children, useful for representing hierarchies like file systems or organizational structures.

**Example:**

```javascript
class NaryNode {
  constructor(value, children = []) {
    this.value = value;
    this.children = children;
  }
}

// File system example
const fileSystem = new NaryNode('root', [
  new NaryNode('documents', [
    new NaryNode('report.pdf'),
    new NaryNode('notes.txt')
  ]),
  new NaryNode('images', [
    new NaryNode('photo1.jpg')
  ])
]);

// Recursive traversal
const printAllFiles = (node, indent = 0) => {
  console.log(' '.repeat(indent) + node.value);
  node.children.forEach(child => 
    printAllFiles(child, indent + 2));
};

// Count all nodes
const countNodes = (node) =>
  1 + node.children.reduce((sum, child) => 
    sum + countNodes(child), 0);
```

### Immutable Operations

Functional programming treats recursive structures immutably, creating new structures rather than modifying existing ones.

**Example:**

```javascript
// Immutable list prepend
const prepend = (value, list) => 
  new ListNode(value, list);

// Immutable tree update
const updateValue = (node, oldVal, newVal) => {
  if (node === null) return null;
  
  return new BinaryNode(
    node.value === oldVal ? newVal : node.value,
    updateValue(node.left, oldVal, newVal),
    updateValue(node.right, oldVal, newVal)
  );
};
```

### Algebraic Data Types

Recursive structures map naturally to algebraic data types, which explicitly model the base and recursive cases.

**Example (conceptual):**

```haskell
-- Haskell-style definition
data List a = Empty | Cons a (List a)
data Tree a = Leaf | Node a (Tree a) (Tree a)

-- Pattern matching on structure
length :: List a -> Int
length Empty = 0
length (Cons _ rest) = 1 + length rest
```

**Key Points:**

- Recursive structures are defined in terms of themselves
- Base cases terminate the recursion (null, empty, leaf)
- Linked lists, trees, and graphs are common examples
- Recursive functions naturally process recursive structures
- Immutable operations create new structures instead of modifying
- Pattern matching elegantly handles different structural cases

---

