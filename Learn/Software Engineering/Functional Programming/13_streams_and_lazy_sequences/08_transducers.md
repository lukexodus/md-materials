## Transducers


Transducers are composable algorithmic transformations decoupled from input and output sources. They define the essence of a transformation—map, filter, take—independent of the data structure being processed. A transducer transforms a reducing function into another reducing function.

**Core concept:**

Traditional operations are tied to specific collection types. Transducers abstract the transformation logic:

```clojure
;; Traditional: specific to collections
(map inc [1 2 3])  ;; => [2 3 4]
(filter odd? [1 2 3])  ;; => [1 3]

;; Transducer: collection-agnostic
(def xf (comp (map inc) (filter odd?)))
;; Can be applied to any reducible context
```

A transducer has the signature:

```
(a -> r -> r) -> (a -> r -> r)
```

Where:

- `a` is input element type
- `r` is accumulated result type
- The transducer transforms one reducing function into another

**Structure:**

Transducers wrap reducing functions with transformation logic:

```clojure
(defn mapping [f]
  (fn [rf]
    (fn 
      ([] (rf))                    ; init
      ([result] (rf result))       ; completion
      ([result input]              ; step
        (rf result (f input))))))

(defn filtering [pred]
  (fn [rf]
    (fn
      ([] (rf))
      ([result] (rf result))
      ([result input]
        (if (pred input)
          (rf result input)
          result)))))
```

**Composition:**

Transducers compose with function composition, and the composition order is intuitive:

```clojure
(def xf
  (comp
    (map inc)
    (filter even?)
    (take 5)))
```

This reads left-to-right: increment, keep evens, take 5.

**Application contexts:**

Transducers separate transformation from:

- **Collection type**: apply to vectors, lists, sets, streams
- **Processing model**: eager, lazy, asynchronous
- **Input/output**: files, channels, observables

The same transducer works across contexts:

```clojure
(into [] xf (range 100))           ; eager, vector
(sequence xf (range 100))          ; lazy sequence
(transduce xf + 0 (range 100))     ; reduce with +
```

**Advantages:**

- **Efficiency**: Single pass through data, no intermediate collections
- **Reusability**: Same logic applies to any reducible source
- **Composability**: Build complex transformations from simple pieces
- **Performance**: Fusion happens naturally through function composition

**Implementation details:**

Transducers maintain state through closure over the reducing function. Early termination is signaled by wrapping results in a completion marker. Stateful transducers (like `take`, `partition`) manage state in the closure.

**Example with state:**

```clojure
(defn take-while [pred]
  (fn [rf]
    (fn
      ([] (rf))
      ([result] (rf result))
      ([result input]
        (if (pred input)
          (rf result input)
          (reduced result))))))  ; signals early termination
```

The `reduced` wrapper indicates completion, preventing further processing.

Transducers unify operations across eager collections, lazy sequences, asynchronous streams, and parallel processing without duplicating logic or creating intermediate structures.

