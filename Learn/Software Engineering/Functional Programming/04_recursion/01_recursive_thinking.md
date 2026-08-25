## Recursive Thinking


Recursive thinking involves solving problems by breaking them down into smaller instances of the same problem. Instead of thinking in terms of loops and incremental state changes, recursive thinking focuses on self-similar problem structures and combining solutions to subproblems.

### Problem Decomposition

**Self-Similarity Recognition** Identify when a problem contains smaller versions of itself. A list can be viewed as an element plus a smaller list. A tree consists of a node and smaller subtrees. This self-similar structure suggests recursive solutions.

```haskell
-- A list is either:
-- 1. Empty []
-- 2. An element followed by a list (x:xs)

-- A binary tree is either:
-- 1. Empty
-- 2. A node with left and right subtrees
data Tree a = Empty | Node a (Tree a) (Tree a)
```

**Reduction to Simpler Cases** Each recursive step reduces problem complexity. The reduction must eventually reach a trivially solvable case. Consider calculating factorial: `n!` depends on `(n-1)!`, which is a simpler problem.

```python
# Factorial reduces problem size
# 5! = 5 × 4!
# 4! = 4 × 3!
# 3! = 3 × 2!
# 2! = 2 × 1!
# 1! = 1 (base case)
```

### Structural Recursion

**Following Data Structure Shape** Recursive functions naturally follow the structure of recursive data types. Processing a list recursively handles the first element, then recursively processes the remaining list.

```scheme
; Sum of list follows list structure
(define (sum lst)
  (if (null? lst)
      0                           ; empty list case
      (+ (car lst)               ; first element
         (sum (cdr lst)))))      ; plus sum of rest
```

**Pattern Matching on Structure** Many functional languages support pattern matching, making recursive structure explicit.

```ocaml
let rec length = function
  | [] -> 0                        (* empty list *)
  | _::rest -> 1 + length rest     (* element + rest *)
```

### Thinking in Terms of Subproblems

**Trust the Recursion** Assume the recursive call correctly solves the smaller problem. Focus on combining the subproblem solution with the current step. This "leap of faith" simplifies reasoning.

```javascript
// Calculate length of array recursively
const length = (arr) => {
  if (arr.length === 0) return 0;
  
  // Trust that length(rest) correctly returns length of remaining elements
  const [first, ...rest] = arr;
  return 1 + length(rest);
};
```

**Combining Results** After the recursive call returns, combine its result with the current element or state. The combination operation defines the overall computation.

```python
# Reverse a list: first element goes to end
def reverse(lst):
    if not lst:
        return []
    return reverse(lst[1:]) + [lst[0]]
    # Combine: reversed tail + first element
```

### Multiple Recursion

**Branching Recursion** Some problems require multiple recursive calls. Tree traversal, divide-and-conquer algorithms, and combinatorial problems often exhibit this pattern.

```haskell
-- Fibonacci with two recursive calls
fibonacci :: Int -> Int
fibonacci 0 = 0
fibonacci 1 = 1
fibonacci n = fibonacci (n-1) + fibonacci (n-2)
```

**Mutual Recursion** Functions can be mutually recursive, calling each other. Useful for parsing, state machines, and problems with alternating phases.

```javascript
const isEven = (n) => n === 0 ? true : isOdd(n - 1);
const isOdd = (n) => n === 0 ? false : isEven(n - 1);
```

### Accumulator Pattern

**Building Results Incrementally** Accumulator parameters carry intermediate results through recursive calls, transforming recursion into a more iteration-like form while maintaining functional style.

```scala
// Tail-recursive sum with accumulator
def sum(list: List[Int], acc: Int = 0): Int = list match {
  case Nil => acc
  case head :: tail => sum(tail, acc + head)
}
```

This pattern enables tail-call optimization and clearer reasoning about accumulated state.

### Recursive Invariants

**Maintaining Properties** Define properties that hold before and after each recursive call. These invariants help verify correctness and guide implementation.

```python
# Invariant: result list contains all elements from input
def filter_positive(lst, result=[]):
    # Invariant: result contains all positive numbers seen so far
    if not lst:
        return result
    
    head, *tail = lst
    if head > 0:
        return filter_positive(tail, result + [head])
    else:
        return filter_positive(tail, result)
```

