## Tree Recursion


Tree recursion occurs when a function makes multiple recursive calls, creating a branching call structure that resembles a tree. This pattern appears in problems involving combinations, permutations, and exploring multiple decision paths.

### Branching Recursion

Tree recursion branches into multiple recursive paths, with each call potentially spawning several more calls. The recursion tree expands exponentially unless pruned.

**Example:**

```javascript
// Fibonacci: each call spawns two more
const fib = (n) =>
  n <= 1 ? n :
  fib(n - 1) + fib(n - 2);

// Call tree for fib(5):
//           fib(5)
//          /      \
//      fib(4)    fib(3)
//      /   \      /   \
//   fib(3) fib(2) fib(2) fib(1)
//    / \    / \    / \
//  ...  ... ... ... ... ...
```

### Exponential Time Complexity

Naive tree recursion often has exponential time complexity because the same subproblems are solved repeatedly in different branches.

**Example:**

```javascript
// O(2^n) - exponential growth
const fib = (n) => {
  if (n <= 1) return n;
  return fib(n - 1) + fib(n - 2);
};

// fib(40) makes 331,160,281 function calls
// fib(50) would take years without optimization
```

### Combinatorial Problems

Tree recursion naturally models problems exploring all possible combinations or permutations.

**Example:**

```javascript
// Generate all subsets of an array
const subsets = (arr, index = 0) => {
  if (index === arr.length) return [[]];
  
  const subsetsWithout = subsets(arr, index + 1);
  const subsetsWithCurrent = subsetsWithout.map(subset => 
    [arr[index], ...subset]);
  
  return [...subsetsWithout, ...subsetsWithCurrent];
};

// subsets([1, 2, 3]) => [[], [3], [2], [2,3], [1], [1,3], [1,2], [1,2,3]]
```

### Backtracking

Tree recursion powers backtracking algorithms that explore solution spaces by trying possibilities and abandoning paths that don't lead to solutions.

**Example:**

```javascript
// Generate all valid parentheses combinations
const generateParens = (n) => {
  const result = [];
  
  const backtrack = (current, open, close) => {
    if (current.length === 2 * n) {
      result.push(current);
      return;
    }
    
    if (open < n) {
      backtrack(current + '(', open + 1, close);
    }
    if (close < open) {
      backtrack(current + ')', open, close + 1);
    }
  };
  
  backtrack('', 0, 0);
  return result;
};

// generateParens(3) => ["((()))", "(()())", "(())()", "()(())", "()()()"]
```

### Multiple Recursive Paths

Problems requiring exploration of multiple alternatives at each step naturally use tree recursion.

**Example:**

```javascript
// Count paths in grid (can move right or down)
const countPaths = (rows, cols, r = 0, c = 0) => {
  if (r === rows - 1 && c === cols - 1) return 1;
  if (r >= rows || c >= cols) return 0;
  
  return countPaths(rows, cols, r + 1, c) +  // down
         countPaths(rows, cols, r, c + 1);    // right
};

// countPaths(3, 3) => 6 unique paths
```

### Tree Traversal Patterns

Tree recursion implements various traversal strategies for exploring tree structures.

**Example:**

```javascript
// Pre-order traversal (root, left, right)
const preorder = (node, visit) => {
  if (node === null) return;
  visit(node.value);
  preorder(node.left, visit);
  preorder(node.right, visit);
};

// In-order traversal (left, root, right)
const inorder = (node, visit) => {
  if (node === null) return;
  inorder(node.left, visit);
  visit(node.value);
  inorder(node.right, visit);
};

// Post-order traversal (left, right, root)
const postorder = (node, visit) => {
  if (node === null) return;
  postorder(node.left, visit);
  postorder(node.right, visit);
  visit(node.value);
};
```

### Optimization Opportunities

Tree recursion benefits from memoization, dynamic programming, or iterative solutions to avoid redundant computation.

**Example:**

```javascript
// Convert tree recursion to iteration with explicit stack
const fibIterative = (n) => {
  if (n <= 1) return n;
  
  let prev = 0, curr = 1;
  for (let i = 2; i <= n; i++) {
    [prev, curr] = [curr, prev + curr];
  }
  return curr;
};
```

**Key Points:**

- Tree recursion makes multiple recursive calls per invocation
- Creates branching call structure resembling a tree
- Often has exponential time complexity without optimization
- Natural fit for combinatorial and backtracking problems
- Same subproblems may be computed multiple times
- Traversal patterns (pre/in/post-order) use tree recursion
- Benefits significantly from memoization and dynamic programming

---

