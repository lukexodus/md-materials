## Base Case and Recursive Case


### Base Case Fundamentals

**Termination Condition** The base case defines when recursion stops. It handles the simplest problem instance that can be solved without further recursion. Without a proper base case, recursion continues indefinitely.

```clojure
; Base case: empty list
(defn sum [lst]
  (if (empty? lst)
    0                    ; Base case returns concrete value
    (+ (first lst) (sum (rest lst)))))
```

**Direct Solution** Base cases return results directly without recursive calls. The answer is immediately known for these trivial inputs.

```java
// Multiple base cases for Fibonacci
public static int fibonacci(int n) {
    if (n == 0) return 0;  // Base case 1
    if (n == 1) return 1;  // Base case 2
    return fibonacci(n-1) + fibonacci(n-2);
}
```

### Identifying Base Cases

**Smallest Valid Input** Determine the smallest or simplest input for which the problem can be solved trivially. For collections, this is often the empty collection or single-element collection.

```haskell
-- Finding maximum in list
maximum' :: (Ord a) => [a] -> a
maximum' [x] = x                           -- Base: single element
maximum' (x:xs) = max x (maximum' xs)      -- Recursive case
```

**Boundary Conditions** Identify natural boundaries in the problem domain. For numeric recursion, boundaries are often zero or one. For tree structures, empty trees or leaf nodes.

```python
# Tree height - empty tree is base case
def height(tree):
    if tree is None:           # Base case: empty tree
        return 0
    return 1 + max(height(tree.left), height(tree.right))
```

**Multiple Base Cases** Complex problems may require several base cases handling different trivial scenarios.

```javascript
// Merge sorted arrays - multiple base cases
const merge = (arr1, arr2) => {
  if (arr1.length === 0) return arr2;  // Base case 1
  if (arr2.length === 0) return arr1;  // Base case 2
  
  if (arr1[0] < arr2[0]) {
    return [arr1[0], ...merge(arr1.slice(1), arr2)];
  } else {
    return [arr2[0], ...merge(arr1, arr2.slice(1))];
  }
};
```

### Recursive Case Structure

**Progress Toward Base Case** Each recursive call must move closer to a base case. This typically involves reducing input size, counting down a number, or traversing a data structure.

```scheme
; Countdown ensures progress toward base case 0
(define (countdown n)
  (if (= n 0)
      '()
      (cons n (countdown (- n 1)))))  ; n decreases each call
```

**Subproblem Formation** The recursive case constructs a smaller subproblem and calls the function recursively on it. The subproblem must be structurally smaller to ensure termination.

```ocaml
(* Remove element from list *)
let rec remove x = function
  | [] -> []                              (* Base case *)
  | h::t -> if h = x then t              (* Found: return rest *)
            else h :: remove x t          (* Recursive: keep h, recurse on t *)
```

**Combining Subproblem Solutions** After the recursive call returns, combine its result with the current element or computation. This combination defines the overall algorithm.

```python
# QuickSort: combine sorted sublists with pivot
def quicksort(arr):
    if len(arr) <= 1:              # Base case
        return arr
    
    pivot = arr[0]
    less = [x for x in arr[1:] if x <= pivot]
    greater = [x for x in arr[1:] if x > pivot]
    
    # Combine: sorted less + pivot + sorted greater
    return quicksort(less) + [pivot] + quicksort(greater)
```

### Relationship Between Cases

**Complementary Conditions** Base case and recursive case conditions must be complementary, covering all possible inputs without overlap.

```haskell
-- Conditions must be exhaustive
factorial :: Integer -> Integer
factorial 0 = 1                    -- Base case: n == 0
factorial n = n * factorial (n-1)  -- Recursive case: n > 0
-- Together they cover all non-negative integers
```

**Trust Boundary** The base case is where trust begins. Recursive cases assume recursive calls work correctly for smaller inputs, building trust upward.

### Common Base Case Errors

**Missing Base Case** Forgetting the base case causes infinite recursion and stack overflow.

```javascript
// WRONG: No base case
const badSum = (arr) => {
  const [first, ...rest] = arr;
  return first + badSum(rest);  // Never terminates
};
```

**Incorrect Base Case Condition** Base case condition that never triggers or doesn't cover all stopping scenarios.

```python
# WRONG: Base case never reached for negative numbers
def bad_countdown(n):
    if n == 0:
        return []
    return [n] + bad_countdown(n - 1)

# bad_countdown(-5) causes infinite recursion
```

**Base Case Without Return** Forgetting to return a value in the base case.

```java
// WRONG: Base case doesn't return
public static int badLength(List<Integer> list) {
    if (list.isEmpty()) {
        // Missing return statement
    }
    return 1 + badLength(list.subList(1, list.size()));
}
```

