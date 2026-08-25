## Clojure Concepts


Clojure is a dynamic, general-purpose language that emphasizes immutability, first-class functions, and a Lisp syntax. It runs on the JVM, CLR, and JavaScript engines.

**Persistent Data Structures**

Clojure's core data structures (lists, vectors, maps, sets) are immutable and persistent. Structural sharing allows efficient copies—when you "modify" a structure, only the changed portions are created anew while unchanged parts are shared between versions. This enables O(log n) or better performance for operations that would be O(n) with naive copying.

```clojure
(def v1 [1 2 3 4])
(def v2 (conj v1 5))  ; Creates new vector, shares structure with v1
```

**Sequences and Lazy Evaluation**

The sequence abstraction unifies operations across different collections. Sequences can be lazy, computing elements only when needed. Functions like `map`, `filter`, and `take` return lazy sequences.

```clojure
(def infinite-nums (iterate inc 0))
(take 5 (filter even? infinite-nums))  ; (0 2 4 6 8)
```

**Atoms, Refs, and Agents**

Clojure provides coordinated state management through reference types:

- **Atoms**: Synchronous, independent state changes using compare-and-swap
- **Refs**: Coordinated, synchronous changes within Software Transactional Memory (STM) transactions
- **Agents**: Asynchronous, independent state changes

```clojure
(def counter (atom 0))
(swap! counter inc)  ; Atomic update

(dosync
  (alter ref1 inc)
  (alter ref2 dec))  ; Coordinated transaction
```

**Protocols and Multimethods**

Protocols define polymorphic behavior similar to interfaces, dispatching on type. Multimethods provide more flexible polymorphism, dispatching on arbitrary functions of arguments.

```clojure
(defprotocol Drawable
  (draw [this]))

(defmulti area :shape)
(defmethod area :circle [c] (* Math/PI (:radius c) (:radius c)))
(defmethod area :rectangle [r] (* (:width r) (:height r)))
```

**Macros**

Clojure macros operate on code as data (homoiconicity). They transform code at compile-time, enabling language extensions and DSLs.

```clojure
(defmacro unless [condition & body]
  `(if (not ~condition)
     (do ~@body)))

(unless false (println "Executed"))
```

**Transducers**

Transducers are composable algorithmic transformations decoupled from input/output sources. They eliminate intermediate collections and can be applied to various contexts (collections, channels, streams).

```clojure
(def xf (comp (filter odd?) (map #(* % %))))
(transduce xf + 0 [1 2 3 4 5])  ; 35
```

**Core.async**

The `core.async` library provides CSP-style concurrency with channels and go blocks. Channels enable communication between concurrent processes without explicit locking.

```clojure
(require '[clojure.core.async :refer [chan go >! <!]])

(def c (chan))
(go (>! c "hello"))
(go (println (<! c)))
```

**Spec**

`clojure.spec` provides runtime validation, generative testing, and documentation. Specs describe data shapes and function contracts.

```clojure
(require '[clojure.spec.alpha :as s])

(s/def ::age (s/and int? #(> % 0)))
(s/def ::person (s/keys :req [::name ::age]))
(s/valid? ::person {::name "Alice" ::age 30})
```

