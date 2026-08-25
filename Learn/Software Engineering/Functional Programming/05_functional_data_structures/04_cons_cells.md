## Cons Cells


Cons cells (short for "construct") are the fundamental building blocks of functional linked lists. A cons cell is a pair containing a value (the head/car) and a reference to the rest of the list (the tail/cdr).

```scheme
; Lisp/Scheme notation
; (cons 1 (cons 2 (cons 3 nil)))
; Represents the list [1, 2, 3]

(define list1 (cons 1 (cons 2 (cons 3 '()))))

; Access operations
(car list1)  ; 1 (first element)
(cdr list1)  ; (2 3) (rest of list)

; Building lists
(cons 0 list1)  ; (0 1 2 3)
```

Structure of cons cells:

```
[1 | •]  →  [2 | •]  →  [3 | •]  →  nil
 ↑           ↑           ↑
head        head        head
```

Each cons cell contains:

1. A value (car/head/first)
2. A pointer to the next cell (cdr/tail/rest)
3. The last cell points to nil/empty list

```haskell
-- Haskell list constructor (:) is cons
list1 = 1 : 2 : 3 : []  -- [1, 2, 3]
list2 = 1 : []          -- [1]
empty = []              -- []

-- Pattern matching on cons cells
head :: [a] -> a
head (x:xs) = x  -- x is car, xs is cdr

tail :: [a] -> [a]
tail (x:xs) = xs

-- Recursive operations
sum :: [Int] -> Int
sum [] = 0
sum (x:xs) = x + sum xs
```

Cons cells enable efficient prepending (O(1)) and structural sharing:

```ocaml
(* OCaml *)
let list1 = [1; 2; 3]               (* [1; 2; 3] *)
let list2 = 0 :: list1              (* [0; 1; 2; 3] *)
let list3 = -1 :: list2             (* [-1; 0; 1; 2; 3] *)

(* list2 and list3 share list1's cells *)
(* Only new cons cells are allocated *)

(* Pattern matching *)
let rec length lst =
  match lst with
  | [] -> 0                         (* empty list *)
  | head :: tail -> 1 + length tail (* cons cell *)

(* Multiple lists can share tails *)
let shared_tail = [3; 4; 5]
let list_a = 1 :: 2 :: shared_tail  (* [1; 2; 3; 4; 5] *)
let list_b = 10 :: 20 :: shared_tail (* [10; 20; 3; 4; 5] *)
(* Both share [3; 4; 5] *)
```

Common operations on cons cell lists:

```clojure
;; Clojure
(def list1 '(1 2 3 4 5))

;; cons - prepend element
(cons 0 list1)           ;; (0 1 2 3 4 5)

;; first - get head
(first list1)            ;; 1

;; rest - get tail
(rest list1)             ;; (2 3 4 5)

;; Recursive traversal
(defn sum [lst]
  (if (empty? lst)
    0
    (+ (first lst) (sum (rest lst)))))

(sum list1)              ;; 15

;; List sharing
(def tail '(3 4 5))
(def list-a (cons 1 (cons 2 tail)))  ;; (1 2 3 4 5)
(def list-b (cons 10 tail))          ;; (10 3 4 5)
;; Both share tail (3 4 5)
```

**Key Points:**

- Cons cells form singly-linked lists
- Prepending (cons) is O(1)
- Appending is O(n) - requires traversing entire list
- Natural fit for recursive algorithms
- Enables automatic structural sharing
- Pattern matching works elegantly with cons structure
- Foundation for many functional data structures

**Example:**

```racket
; Racket
(define (make-range n)
  (if (= n 0)
      '()
      (cons n (make-range (- n 1)))))

(define list1 (make-range 5))  ; '(5 4 3 2 1)

; Prepending shares structure
(define list2 (cons 6 list1))   ; '(6 5 4 3 2 1)
(define list3 (cons 7 list1))   ; '(7 5 4 3 2 1)

; list2 and list3 share list1's cells

; Recursive operations with cons
(define (map-list f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (map-list f (cdr lst)))))

(map-list (lambda (x) (* x 2)) list1)
; '(10 8 6 4 2)

; Filter using cons
(define (filter-list pred lst)
  (cond
    [(null? lst) '()]
    [(pred (car lst))
     (cons (car lst) (filter-list pred (cdr lst)))]
    [else (filter-list pred (cdr lst))]))

(filter-list even? list1)
; '(4 2)
```

**Conclusion:** Functional data structures fundamentally differ from imperative structures by embracing immutability. Through cons cells and structural sharing, persistent data structures achieve the seemingly impossible: cheap modifications while preserving all previous versions. This enables fearless sharing of data across different parts of a program, simplifies concurrent programming, and makes reasoning about code dramatically easier—all while maintaining practical performance characteristics through clever use of structural sharing.

