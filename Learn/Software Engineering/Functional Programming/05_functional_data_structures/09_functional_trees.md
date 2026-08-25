## Functional Trees


Functional trees are immutable, persistent data structures that maintain previous versions when modified. Instead of mutating nodes in place, operations create new nodes while sharing unchanged subtrees, achieving efficiency through structural sharing.

### Structure and Representation

Functional trees typically represent hierarchical data where each node is immutable. Common implementations include:

**Binary trees**: Each node has at most two children **N-ary trees**: Nodes can have multiple children **Rose trees**: Nodes with arbitrary number of children and data

### Immutability and Structural Sharing

When modifying a functional tree, only the path from root to the modified node is copied. Unchanged subtrees are shared between versions.

**Key Points:**

- Modifications create new tree versions without destroying old ones
- O(log n) space overhead for modifications due to path copying
- Enables persistent data structures with version history
- Thread-safe by default due to immutability
- Garbage collection handles unreferenced versions

**Example:**

```javascript
class TreeNode {
  constructor(value, left = null, right = null) {
    this.value = value;
    this.left = left;
    this.right = right;
  }
}

function insert(tree, value) {
  if (tree === null) {
    return new TreeNode(value);
  }
  
  if (value < tree.value) {
    return new TreeNode(
      tree.value,
      insert(tree.left, value),  // New left subtree
      tree.right                  // Shared right subtree
    );
  } else {
    return new TreeNode(
      tree.value,
      tree.left,                  // Shared left subtree
      insert(tree.right, value)   // New right subtree
    );
  }
}

const tree1 = insert(null, 5);
const tree2 = insert(tree1, 3);
const tree3 = insert(tree2, 7);

console.log(tree1.value);  // 5
console.log(tree2.left.value);  // 3
console.log(tree3.right.value);  // 7
```

**Output:**

```
5
3
7
```

### Tree Traversal

Functional tree traversals return lazy sequences or use recursion without mutation.

**Example:**

```javascript
function* inorderTraversal(tree) {
  if (tree === null) return;
  
  yield* inorderTraversal(tree.left);
  yield tree.value;
  yield* inorderTraversal(tree.right);
}

function* preorderTraversal(tree) {
  if (tree === null) return;
  
  yield tree.value;
  yield* preorderTraversal(tree.left);
  yield* preorderTraversal(tree.right);
}

const tree = new TreeNode(5,
  new TreeNode(3, new TreeNode(1), new TreeNode(4)),
  new TreeNode(7, new TreeNode(6), new TreeNode(9))
);

console.log([...inorderTraversal(tree)]);
console.log([...preorderTraversal(tree)]);
```

**Output:**

```
[1, 3, 4, 5, 6, 7, 9]
[5, 3, 1, 4, 7, 6, 9]
```

### Zipper Pattern

Zippers provide efficient navigation and modification of trees by maintaining context of the current focus point.

**Example:**

```javascript
class TreeZipper {
  constructor(focus, path = []) {
    this.focus = focus;  // Current node
    this.path = path;    // Breadcrumbs to root
  }
  
  goLeft() {
    if (this.focus.left === null) return null;
    
    return new TreeZipper(
      this.focus.left,
      [{ direction: 'left', node: this.focus }, ...this.path]
    );
  }
  
  goRight() {
    if (this.focus.right === null) return null;
    
    return new TreeZipper(
      this.focus.right,
      [{ direction: 'right', node: this.focus }, ...this.path]
    );
  }
  
  goUp() {
    if (this.path.length === 0) return null;
    
    const [parent, ...rest] = this.path;
    const newNode = parent.direction === 'left'
      ? new TreeNode(parent.node.value, this.focus, parent.node.right)
      : new TreeNode(parent.node.value, parent.node.left, this.focus);
    
    return new TreeZipper(newNode, rest);
  }
  
  modify(fn) {
    return new TreeZipper(
      new TreeNode(fn(this.focus.value), this.focus.left, this.focus.right),
      this.path
    );
  }
}
```

### Red-Black Trees and Balanced Trees

Functional implementations of self-balancing trees maintain invariants through pattern matching and recursive reconstruction.

**Key Points:**

- Balancing operations create new nodes along rebalancing path
- Color information (red/black) stored immutably in nodes
- Rotations produce new subtrees without mutation
- Maintain O(log n) height guarantee

