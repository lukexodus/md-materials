## Recursion vs Iteration


### Conceptual Differences

**Mental Models** Iteration focuses on step-by-step state changes through loops. Recursion emphasizes problem decomposition into self-similar subproblems. Iteration asks "how do I repeat this process?" while recursion asks "how does this relate to a smaller version?"

```python
# Iterative mindset: modify accumulator in loop
def sum_iterative(lst):
    total = 0
    for item in lst:
        total += item
    return total

# Recursive mindset: current element plus sum of rest
def sum_recursive(lst):
    if not lst:
        return 0
    return lst[0] + sum_recursive(lst[1:])
```

**State Management** Iteration uses mutable variables to track state across loop iterations. Recursion passes state as function parameters, maintaining immutability.

```java
// Iterative: mutable variable
public static int factorialIterative(int n) {
    int result = 1;
    for (int i = 1; i <= n; i++) {
        result *= i;  // Mutate result
    }
    return result;
}

// Recursive: immutable parameters
public static int factorialRecursive(int n) {
    if (n == 0) return 1;
    return n * factorialRecursive(n - 1);
}
```

### Expressiveness and Readability

**Natural Fit for Problem Structure** Recursion naturally expresses problems with self-similar structure. Tree traversal, divide-and-conquer, and mathematical definitions are clearer recursively.

```haskell
-- Recursive tree traversal is natural
data Tree a = Leaf a | Node (Tree a) (Tree a)

inorder :: Tree a -> [a]
inorder (Leaf x) = [x]
inorder (Node left right) = inorder left ++ inorder right

-- Iterative version requires explicit stack management
```

**Code Clarity** Recursive solutions often mirror problem specifications more directly, improving readability.

```scheme
; Recursive definition matches mathematical definition
; merge sort: divide, sort halves, merge
(define (merge-sort lst)
  (if (<= (length lst) 1)
      lst
      (let ((mid (quotient (length lst) 2)))
        (merge (merge-sort (take lst mid))
               (merge-sort (drop lst mid))))))
```

Iterative versions of the same algorithm may be longer and require manual state tracking.

### Performance Characteristics

**Stack Usage** Recursion consumes call stack space proportional to recursion depth. Deep recursion risks stack overflow. Iteration uses constant stack space.

```javascript
// Deep recursion can overflow stack
const countToMillion = (n) => {
  if (n === 1000000) return n;
  return countToMillion(n + 1);
};
// May cause: RangeError: Maximum call stack size exceeded

// Iteration handles arbitrary depth
const countToMillionIter = (n) => {
  while (n < 1000000) {
    n++;
  }
  return n;
};
```

**Tail Call Optimization** [Inference] Languages with tail call optimization convert tail-recursive functions to iterative loops at the compiler level, eliminating stack overhead. Not all languages support this optimization.

```scala
// Tail-recursive - can be optimized to iteration
@tailrec
def sumTailRec(lst: List[Int], acc: Int = 0): Int = lst match {
  case Nil => acc
  case head :: tail => sumTailRec(tail, acc + head)
}
```

**Function Call Overhead** Recursive calls incur function call overhead (parameter passing, stack frame creation). Iteration avoids this overhead, potentially offering better performance for simple operations.

```c
// Iterative: minimal overhead
int sum_iter(int arr[], int n) {
    int sum = 0;
    for (int i = 0; i < n; i++) {
        sum += arr[i];
    }
    return sum;
}

// Recursive: function call overhead for each element
int sum_rec(int arr[], int n) {
    if (n == 0) return 0;
    return arr[n-1] + sum_rec(arr, n-1);
}
```

### Transformation Between Forms

**Recursion to Iteration with Explicit Stack** Non-tail-recursive functions can be converted to iteration by manually managing a stack data structure.

```python
# Recursive tree traversal
def traverse_recursive(node):
    if node is None:
        return
    traverse_recursive(node.left)
    print(node.value)
    traverse_recursive(node.right)

# Iterative with explicit stack
def traverse_iterative(root):
    stack = [(root, False)]
    while stack:
        node, visited = stack.pop()
        if node is None:
            continue
        if visited:
            print(node.value)
        else:
            stack.append((node.right, False))
            stack.append((node, True))
            stack.append((node.left, False))
```

**Tail Recursion to Iteration** Tail-recursive functions translate directly to while loops with parameter updates.

```javascript
// Tail recursive
const factorial = (n, acc = 1) => {
  if (n === 0) return acc;
  return factorial(n - 1, n * acc);
};

// Equivalent iteration
const factorialIter = (n) => {
  let acc = 1;
  while (n > 0) {
    acc = n * acc;
    n = n - 1;
  }
  return acc;
};
```

**Iteration to Recursion with Accumulator** Iterative loops with accumulators convert to tail-recursive functions.

```haskell
-- Iterative style (pseudocode)
-- result = 0
-- for each element in list:
--     result = result + element
-- return result

-- Tail recursive equivalent
sumAcc :: [Int] -> Int -> Int
sumAcc [] acc = acc
sumAcc (x:xs) acc = sumAcc xs (acc + x)

sum' :: [Int] -> Int
sum' lst = sumAcc lst 0
```

### When to Choose Recursion

**Inherently Recursive Problems** Use recursion for problems naturally defined recursively: tree/graph traversal, divide-and-conquer algorithms, parsing, backtracking.

```python
# Directory traversal is naturally recursive
def find_files(directory, extension):
    results = []
    for item in directory:
        if item.is_file() and item.extension == extension:
            results.append(item)
        elif item.is_directory():
            results.extend(find_files(item, extension))
    return results
```

**Functional Programming Contexts** In functional languages without loops or with immutable data, recursion is the primary control structure.

```clojure
; Clojure emphasizes recursion
(defn filter-positive [coll]
  (cond
    (empty? coll) []
    (> (first coll) 0) (cons (first coll) 
                             (filter-positive (rest coll)))
    :else (filter-positive (rest coll))))
```

**Clarity and Maintainability Priority** When recursive solution is significantly clearer and performance is acceptable, prefer recursion.

### When to Choose Iteration

**Performance-Critical Code** Use iteration when function call overhead or stack depth is problematic and tail call optimization is unavailable.

```c
// Performance-critical tight loop
void process_pixels(uint8_t* buffer, size_t size) {
    for (size_t i = 0; i < size; i++) {
        buffer[i] = transform(buffer[i]);
    }
}
```

**Deep Recursion Without TCO** In languages without tail call optimization, deep recursion (thousands of levels) requires iteration.

```javascript
// Node.js has limited stack - use iteration for deep nesting
const deepCount = (n) => {
  let count = 0;
  for (let i = 0; i < n; i++) {
    count++;
  }
  return count;
};
```

**Simple Sequential Processing** For straightforward sequential operations without subproblem structure, iteration is often clearer.

```java
// Simple aggregation - iteration is clear
public static int[] runningSum(int[] nums) {
    int[] result = new int[nums.length];
    result[0] = nums[0];
    for (int i = 1; i < nums.length; i++) {
        result[i] = result[i-1] + nums[i];
    }
    return result;
}
```

### Hybrid Approaches

**Recursion for Structure, Iteration for Inner Loops** Combine both: recursion for high-level problem structure, iteration for performance-critical inner operations.

```python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    
    pivot = arr[0]
    
    # Use iteration for partitioning
    less = []
    greater = []
    for x in arr[1:]:
        if x <= pivot:
            less.append(x)
        else:
            greater.append(x)
    
    # Recursion for divide-and-conquer structure
    return quicksort(less) + [pivot] + quicksort(greater)
```

**Trampolining** [Inference] Trampoline pattern converts stack-consuming recursion into iteration-like execution without rewriting logic.

```javascript
// Trampoline wrapper
const trampoline = (fn) => {
  let result = fn;
  while (typeof result === 'function') {
    result = result();
  }
  return result;
};

// Tail-recursive function returning thunks
const factorialTrampoline = (n, acc = 1) => {
  if (n === 0) return acc;
  return () => factorialTrampoline(n - 1, n * acc);
};

// Execute without stack growth
const result = trampoline(() => factorialTrampoline(10000));
```

**Key Points:**

- Recursion emphasizes problem decomposition; iteration emphasizes state mutation
- Recursion is more natural for self-similar problems; iteration for sequential processing
- Recursion consumes stack space; iteration uses constant space
- Tail call optimization eliminates recursion overhead in supporting languages
- Choose based on problem structure, language features, and performance requirements
- Hybrid approaches combine benefits of both paradigms

