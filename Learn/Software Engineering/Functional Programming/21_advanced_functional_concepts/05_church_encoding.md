## Church Encoding


Church encoding represents data structures and operations purely as functions, demonstrating that lambda calculus alone suffices for computation without primitive data types. This encoding transforms numbers, booleans, pairs, lists, and control structures into higher-order functions, revealing the fundamental computational power of function abstraction and application.

**Church booleans:**

```clojure
(def church-true (fn [x y] x))
(def church-false (fn [x y] y))

(def church-if (fn [pred then else]
                 (pred then else)))

(church-if church-true :yes :no)  ;; => :yes
(church-if church-false :yes :no) ;; => :no
```

A Church boolean is a function accepting two arguments and selecting one. `true` selects the first argument, `false` selects the second. The `if` operation becomes simple function application—the predicate function chooses which branch to return.

**Church numerals:**

Church numerals encode natural numbers as iteration counts. A number n is represented as a function that applies another function n times to an argument.

```clojure
(def church-zero (fn [f x] x))
(def church-one (fn [f x] (f x)))
(def church-two (fn [f x] (f (f x))))
(def church-three (fn [f x] (f (f (f x)))))

;; Successor function: adds one to a Church numeral
(def church-succ
  (fn [n]
    (fn [f x]
      (f (n f x)))))

;; Convert Church numeral to integer
(defn church->int [n]
  (n inc 0))

(church->int church-three)              ;; => 3
(church->int (church-succ church-two))  ;; => 3
```

The successor function takes a numeral n and returns a new function that applies f once more than n does. This captures the essence of "add one" through pure function composition.

**Church arithmetic:**

```clojure
(def church-add
  (fn [m n]
    (fn [f x]
      (m f (n f x)))))

(def church-mult
  (fn [m n]
    (fn [f x]
      (m (n f) x))))

(def church-exp
  (fn [m n]
    (n m)))

(church->int (church-add church-two church-three))  ;; => 5
(church->int (church-mult church-two church-three)) ;; => 6
(church->int (church-exp church-two church-three))  ;; => 8
```

Addition applies both numerals' iterations sequentially. Multiplication composes the iterations—apply n iterations, m times. Exponentiation applies the exponent as a function to the base, leveraging the fact that numerals are themselves functions on functions.

**Church pairs:**

```clojure
(def church-pair
  (fn [x y]
    (fn [selector]
      (selector x y))))

(def church-first
  (fn [pair]
    (pair (fn [x y] x))))

(def church-second
  (fn [pair]
    (pair (fn [x y] y))))

(def my-pair (church-pair 42 99))
(church-first my-pair)  ;; => 42
(church-second my-pair) ;; => 99
```

A pair is a function holding two values and accepting a selector function that extracts one. This pattern extends to tuples of arbitrary arity.

**Church lists:**

```clojure
(def church-nil (fn [on-nil on-cons] on-nil))

(def church-cons
  (fn [head tail]
    (fn [on-nil on-cons]
      (on-cons head tail))))

(def church-head
  (fn [list]
    (list nil (fn [h t] h))))

(def church-tail
  (fn [list]
    (list nil (fn [h t] t))))

(def church-is-nil?
  (fn [list]
    (list church-true (fn [h t] church-false))))
```

Lists use the fold pattern—a list is a function accepting handlers for empty and cons cases. This encoding naturally leads to fold-based recursion.

**Significance:**

Church encoding proves that functions alone provide universal computation. Every computable operation reduces to function abstraction and application. Modern functional programming inherits this insight—data structures are often best understood through their elimination forms (how they're consumed) rather than construction.

