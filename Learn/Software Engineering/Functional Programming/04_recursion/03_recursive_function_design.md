## Recursive Function Design


### Design Process

**Step 1: Define Function Signature** Specify input parameters and return type. Consider what information is needed for each recursive call.

```haskell
-- Clear signature with types
sumList :: [Int] -> Int
reverseList :: [a] -> [a]
findElement :: Eq a => a -> [a] -> Bool
```

**Step 2: Identify Base Case(s)** Determine the simplest input(s) that can be solved directly. Write these cases first.

```python
def power(base, exponent):
    # Base case: anything to power 0 is 1
    if exponent == 0:
        return 1
```

**Step 3: Assume Recursion Works** Trust that recursive calls on smaller inputs return correct results. Don't try to trace execution mentally.

```javascript
// Assume findMax(rest) correctly finds max in rest
const findMax = (arr) => {
  if (arr.length === 1) return arr[0];
  
  const [first, ...rest] = arr;
  const maxRest = findMax(rest);  // Trust this works
  return first > maxRest ? first : maxRest;
};
```

**Step 4: Combine Subproblem Solution** Determine how to use the recursive result and current element to produce the final answer.

```scala
// Combine current node value with recursive subtree results
def treeSum(tree: Tree): Int = tree match {
  case Empty => 0                // Base case
  case Node(value, left, right) =>
    value + treeSum(left) + treeSum(right)  // Combine
}
```

**Step 5: Verify Progress** Ensure each recursive call moves toward base case. Input must become structurally smaller or a counter must decrease.

```clojure
; Progress: list gets smaller each call
(defn contains? [x lst]
  (cond
    (empty? lst) false                    ; Base case
    (= x (first lst)) true               ; Found
    :else (contains? x (rest lst))))     ; Recurse on smaller list
```

### Helper Functions and Accumulation

**Wrapper Functions** Expose a clean interface while using helper functions with additional parameters for accumulation or state.

```python
# Public interface
def reverse(lst):
    return reverse_helper(lst, [])

# Helper with accumulator
def reverse_helper(lst, acc):
    if not lst:
        return acc
    return reverse_helper(lst[1:], [lst[0]] + acc)
```

**Accumulator Parameters** Pass accumulated results through recursive calls, enabling tail recursion and clearer state management.

```haskell
-- Factorial with accumulator
factorial :: Integer -> Integer
factorial n = factHelper n 1
  where
    factHelper 0 acc = acc
    factHelper n acc = factHelper (n-1) (n*acc)
```

### Common Recursive Patterns

**Linear Recursion** Single recursive call per invocation, typically processing sequences.

```scheme
; Map function - linear recursion
(define (map f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (map f (cdr lst)))))
```

**Binary Recursion** Two recursive calls, common in divide-and-conquer algorithms.

```java
// Binary search - two potential recursive calls
public static int binarySearch(int[] arr, int target, int left, int right) {
    if (left > right) return -1;  // Base case
    
    int mid = (left + right) / 2;
    if (arr[mid] == target) return mid;
    
    if (arr[mid] > target)
        return binarySearch(arr, target, left, mid-1);
    else
        return binarySearch(arr, target, mid+1, right);
}
```

**Tree Recursion** Multiple recursive calls exploring branches, typical in tree algorithms and combinatorics.

```python
# Generate all subsets - tree recursion
def subsets(lst):
    if not lst:
        return [[]]
    
    first, *rest = lst
    subsets_without_first = subsets(rest)
    subsets_with_first = [[first] + s for s in subsets_without_first]
    
    return subsets_without_first + subsets_with_first
```

**Tail Recursion** Recursive call is the last operation, enabling optimization to iteration by compilers.

```javascript
// Tail-recursive GCD
const gcd = (a, b) => {
  if (b === 0) return a;
  return gcd(b, a % b);  // Tail call - no computation after
};
```

### State Management in Recursion

**Explicit State Parameters** Pass state explicitly through parameters rather than using external variables.

```ocaml
(* Count occurrences with explicit counter *)
let rec count_occurrences x lst count =
  match lst with
  | [] -> count
  | h::t -> if h = x 
            then count_occurrences x t (count + 1)
            else count_occurrences x t count
```

**Return Multiple Values** Return tuples or records containing multiple pieces of information from recursive calls.

```haskell
-- Return both minimum and maximum
minMax :: (Ord a) => [a] -> (a, a)
minMax [x] = (x, x)
minMax (x:xs) = 
  let (minRest, maxRest) = minMax xs
  in (min x minRest, max x maxRest)
```

### Validation and Edge Cases

**Input Validation** Check for invalid inputs before beginning recursion.

```python
def nth_element(lst, n):
    if n < 0:
        raise ValueError("Index cannot be negative")
    if not lst:
        raise IndexError("List is empty")
    
    if n == 0:
        return lst[0]
    return nth_element(lst[1:], n-1)
```

**Empty Collection Handling** Explicitly handle empty collections in base cases.

```javascript
// Handling empty array explicitly
const product = (arr) => {
  if (arr.length === 0) return 1;  // Empty product is 1
  if (arr.length === 1) return arr[0];
  
  const [first, ...rest] = arr;
  return first * product(rest);
};
```

### Optimization Considerations

**Memoization for Repeated Subproblems** Cache results of expensive recursive calls when subproblems overlap.

```python
# Fibonacci with memoization
def fib_memo(n, cache={}):
    if n in cache:
        return cache[n]
    if n <= 1:
        return n
    
    cache[n] = fib_memo(n-1, cache) + fib_memo(n-2, cache)
    return cache[n]
```

**Tail Call Optimization Enablement** Structure recursion to be tail-recursive when possible, allowing compiler optimization.

```scala
// Tail-recursive list reversal
@tailrec
def reverse[A](lst: List[A], acc: List[A] = List()): List[A] = 
  lst match {
    case Nil => acc
    case head :: tail => reverse(tail, head :: acc)
  }
```

