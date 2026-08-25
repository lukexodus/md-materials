## Multimethods


Multimethods decouple function dispatch from data type definitions, allowing behavior to be defined externally based on multiple argument types. Unlike methods attached to classes, multimethods exist independently and can be extended without modifying original type definitions.

**Definition structure:**

Multimethods consist of:

- **Generic function**: Declares name and signature
- **Methods**: Specific implementations for type combinations
- **Dispatch strategy**: Determines which method to invoke

```clojure
;; Generic function declaration
(defmulti encounter
  "Handles interactions between game entities"
  (fn [entity1 entity2] [(type entity1) (type entity2)]))

;; Method definitions
(defmethod encounter [::Monster ::Player] [m p]
  (attack m p))

(defmethod encounter [::Player ::Monster] [p m]
  (defend-or-attack p m))

(defmethod encounter [::Monster ::Monster] [m1 m2]
  (territorial-dispute m1 m2))
```

**Dispatch functions:**

The dispatch function computes a dispatch value from arguments:

```clojure
(defmulti area
  "Calculate area based on shape type"
  :shape-type)  ; Keyword dispatch on :shape-type field

(defmethod area :circle [shape]
  (* Math/PI (:radius shape) (:radius shape)))

(defmethod area :rectangle [shape]
  (* (:width shape) (:height shape)))

(defmethod area :triangle [shape]
  (* 0.5 (:base shape) (:height shape)))
```

Any function can serve as dispatcher—type-based, value-based, or arbitrary computation.

**Hierarchies:**

Explicit hierarchies determine dispatch preferences:

```clojure
(derive ::Dog ::Animal)
(derive ::Cat ::Animal)
(derive ::Mammal ::Animal)
(derive ::Dog ::Mammal)

(defmulti feed (fn [animal food] [(type animal) (type food)]))

(defmethod feed [::Animal ::Food] [a f]
  (println "Generic feeding"))

(defmethod feed [::Dog ::Meat] [d m]
  (println "Dog eats meat eagerly"))

;; Dispatching a ::Dog with ::Meat uses the more specific method
```

The hierarchy creates a dispatch lattice where more specific methods override general ones.

**Default methods:**

Handle cases without specific implementations:

```clojure
(defmethod encounter :default [e1 e2]
  (println "No specific interaction defined"))
```

The `:default` method catches all unmatched dispatch values.

**Dynamic extension:**

New methods can be added at runtime without modifying existing code:

```clojure
;; Original multimethod
(defmulti render :type)
(defmethod render :button [component] ...)
(defmethod render :label [component] ...)

;; Later, in different namespace/library
(defmethod render :slider [component]
  (render-slider component))
```

This solves the expression problem's behavioral extension dimension—new operations are addable without touching original definitions.

**Preference declaration:**

Resolve ambiguities explicitly:

```clojure
(defmulti foo (fn [x y] [(type x) (type y)]))

(defmethod foo [::A ::B] [x y] 1)
(defmethod foo [::C ::D] [x y] 2)

;; If ::E derives from both ::A and ::C
(derive ::E ::A)
(derive ::E ::C)

;; Prefer first method when ambiguous
(prefer-method foo [::A ::B] [::C ::D])
```

Preferences establish ordering when multiple methods match equally specifically.

**Implementation dispatch:**

**[Inference]** Multimethods likely use dispatch tables with caching:

1. Compute dispatch value via dispatch function
2. Look up method in dispatch table
3. Cache result for subsequent calls with same dispatch value
4. Fall back to hierarchy search if exact match not found

**Value-based dispatch:**

Beyond types, dispatch on arbitrary values:

```clojure
(defmulti tax-rate :income-bracket)

(defmethod tax-rate :low [person] 0.10)
(defmethod tax-rate :medium [person] 0.20)
(defmethod tax-rate :high [person] 0.35)

;; Dispatch value comes from data, not types
(tax-rate {:income-bracket :medium :income 50000})
```

**Multi-arity multimethods:**

Different implementations for different argument counts:

```clojure
(defmulti format-output
  (fn [& args] (count args)))

(defmethod format-output 1 [[x]]
  (str "Single: " x))

(defmethod format-output 2 [[x y]]
  (str "Pair: " x ", " y))
```

**Protocol comparison:**

Protocols provide type-based single dispatch with better performance:

```clojure
;; Protocol (single dispatch, faster)
(defprotocol IShape
  (area [this]))

(deftype Circle [radius]
  IShape
  (area [this] (* Math/PI radius radius)))

;; Multimethod (multiple dispatch, more flexible)
(defmulti area :shape-type)
(defmethod area :circle [shape]
  (* Math/PI (:radius shape) (:radius shape)))
```

**[Inference]** Protocols likely dispatch through virtual tables attached to types. Multimethods dispatch through centralized tables with more overhead but greater flexibility.

**Use cases:**

Multimethods excel when:

- Dispatch logic depends on multiple arguments
- New behaviors must extend existing types externally
- Dispatch criteria involves values, not just types
- Hierarchical override semantics are needed

The tradeoff is runtime dispatch overhead versus architectural flexibility and the ability to solve the expression problem for operations.

---

