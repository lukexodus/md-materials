## Converting Recursion to Iteration


Converting recursion to iteration eliminates stack overflow risks and often improves performance by removing function call overhead. The transformation typically involves explicit stack management or state tracking through loops.

### Simple Tail Recursion

```javascript
// Recursive
function sumRecursive(n, acc = 0) {
  if (n <= 0) return acc;
  return sumRecursive(n - 1, acc + n);
}

// Iterative
function sumIterative(n) {
  let acc = 0;
  while (n > 0) {
    acc += n;
    n--;
  }
  return acc;
}

console.log(sumIterative(100000)); // Fast, no stack overflow
```

### Factorial Conversion

```javascript
// Recursive
function factorialRec(n) {
  if (n <= 1) return 1;
  return n * factorialRec(n - 1);
}

// Iterative
function factorialIter(n) {
  let result = 1;
  for (let i = 2; i <= n; i++) {
    result *= i;
  }
  return result;
}

console.log(factorialIter(20)); // 2432902008176640000
```

### Tree Traversal with Explicit Stack

```javascript
class TreeNode {
  constructor(value, left = null, right = null) {
    this.value = value;
    this.left = left;
    this.right = right;
  }
}

// Recursive inorder traversal
function inorderRecursive(node, result = []) {
  if (!node) return result;
  inorderRecursive(node.left, result);
  result.push(node.value);
  inorderRecursive(node.right, result);
  return result;
}

// Iterative inorder traversal
function inorderIterative(root) {
  const result = [];
  const stack = [];
  let current = root;
  
  while (current || stack.length > 0) {
    // Go to leftmost node
    while (current) {
      stack.push(current);
      current = current.left;
    }
    
    // Process node
    current = stack.pop();
    result.push(current.value);
    
    // Move to right subtree
    current = current.right;
  }
  
  return result;
}

const tree = new TreeNode(4,
  new TreeNode(2, new TreeNode(1), new TreeNode(3)),
  new TreeNode(6, new TreeNode(5), new TreeNode(7))
);

console.log(inorderIterative(tree)); // [1, 2, 3, 4, 5, 6, 7]
```

### Fibonacci Conversion

```javascript
// Recursive
function fibRec(n, memo = {}) {
  if (n in memo) return memo[n];
  if (n <= 1) return n;
  memo[n] = fibRec(n - 1, memo) + fibRec(n - 2, memo);
  return memo[n];
}

// Iterative
function fibIter(n) {
  if (n <= 1) return n;
  
  let prev = 0, curr = 1;
  for (let i = 2; i <= n; i++) {
    [prev, curr] = [curr, prev + curr];
  }
  return curr;
}

console.log(fibIter(100)); // 354224848179262000000
```

### Binary Search Conversion

```javascript
// Recursive
function binarySearchRec(arr, target, left = 0, right = arr.length - 1) {
  if (left > right) return -1;
  
  const mid = Math.floor((left + right) / 2);
  
  if (arr[mid] === target) return mid;
  if (arr[mid] > target) return binarySearchRec(arr, target, left, mid - 1);
  return binarySearchRec(arr, target, mid + 1, right);
}

// Iterative
function binarySearchIter(arr, target) {
  let left = 0, right = arr.length - 1;
  
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    
    if (arr[mid] === target) return mid;
    if (arr[mid] > target) {
      right = mid - 1;
    } else {
      left = mid + 1;
    }
  }
  
  return -1;
}

const sorted = [1, 3, 5, 7, 9, 11, 13, 15];
console.log(binarySearchIter(sorted, 7)); // 3
```

### Deep Tree Traversal

```javascript
// Recursive postorder
function postorderRec(node, result = []) {
  if (!node) return result;
  postorderRec(node.left, result);
  postorderRec(node.right, result);
  result.push(node.value);
  return result;
}

// Iterative postorder (two stacks)
function postorderIter(root) {
  if (!root) return [];
  
  const result = [];
  const stack1 = [root];
  const stack2 = [];
  
  while (stack1.length > 0) {
    const node = stack1.pop();
    stack2.push(node);
    
    if (node.left) stack1.push(node.left);
    if (node.right) stack1.push(node.right);
  }
  
  while (stack2.length > 0) {
    result.push(stack2.pop().value);
  }
  
  return result;
}

console.log(postorderIter(tree)); // [1, 3, 2, 5, 7, 6, 4]
```

### Quicksort Conversion

```javascript
// Recursive quicksort
function quicksortRec(arr) {
  if (arr.length <= 1) return arr;
  
  const pivot = arr[arr.length - 1];
  const left = arr.slice(0, -1).filter(x => x <= pivot);
  const right = arr.slice(0, -1).filter(x => x > pivot);
  
  return [...quicksortRec(left), pivot, ...quicksortRec(right)];
}

// Iterative quicksort
function quicksortIter(arr) {
  const stack = [[0, arr.length - 1]];
  
  while (stack.length > 0) {
    const [low, high] = stack.pop();
    if (low >= high) continue;
    
    // Partition
    const pivot = arr[high];
    let i = low - 1;
    
    for (let j = low; j < high; j++) {
      if (arr[j] <= pivot) {
        i++;
        [arr[i], arr[j]] = [arr[j], arr[i]];
      }
    }
    
    [arr[i + 1], arr[high]] = [arr[high], arr[i + 1]];
    const pivotIndex = i + 1;
    
    // Push subproblems
    stack.push([low, pivotIndex - 1]);
    stack.push([pivotIndex + 1, high]);
  }
  
  return arr;
}

const unsorted = [3, 7, 8, 5, 2, 1, 9, 5, 4];
console.log(quicksortIter([...unsorted])); // [1, 2, 3, 4, 5, 5, 7, 8, 9]
```

### Path Finding with Stack

```javascript
// Recursive path finding
function findPathRec(graph, start, end, visited = new Set()) {
  if (start === end) return [end];
  visited.add(start);
  
  for (const neighbor of graph[start] || []) {
    if (!visited.has(neighbor)) {
      const path = findPathRec(graph, neighbor, end, visited);
      if (path) return [start, ...path];
    }
  }
  
  return null;
}

// Iterative path finding
function findPathIter(graph, start, end) {
  const stack = [[start, [start]]];
  const visited = new Set();
  
  while (stack.length > 0) {
    const [node, path] = stack.pop();
    
    if (node === end) return path;
    if (visited.has(node)) continue;
    
    visited.add(node);
    
    for (const neighbor of graph[node] || []) {
      if (!visited.has(neighbor)) {
        stack.push([neighbor, [...path, neighbor]]);
      }
    }
  }
  
  return null;
}

const graph = {
  A: ['B', 'C'],
  B: ['D', 'E'],
  C: ['F'],
  D: [],
  E: ['F'],
  F: []
};

console.log(findPathIter(graph, 'A', 'F')); // ['A', 'C', 'F']
```

### General Conversion Strategy

```javascript
// Generic stack-based conversion template
function iterativeTemplate(initialState) {
  const stack = [initialState];
  const results = [];
  
  while (stack.length > 0) {
    const state = stack.pop();
    
    // Base case check
    if (isBaseCase(state)) {
      results.push(processBaseCase(state));
      continue;
    }
    
    // Push recursive cases onto stack
    const subproblems = generateSubproblems(state);
    stack.push(...subproblems);
  }
  
  return combineResults(results);
}
```

**Key Points:**

- Tail recursion converts directly to loops
- Non-tail recursion requires explicit stack management
- Stack holds pending operations and state
- Iterative solutions avoid stack overflow
- Often better performance (no call overhead)
- Trade-off: code may be less readable
- Tree/graph traversals are common conversion candidates
- Consider work-stealing for parallel iterative approaches

---

