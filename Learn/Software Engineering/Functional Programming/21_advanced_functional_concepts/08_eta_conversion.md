## Eta Conversion


Eta conversion expresses the principle of extensionality: two functions producing identical outputs for all inputs are considered equal. This rule allows simplifying redundant lambda abstractions and reveals when functions are behaviorally equivalent despite syntactic differences.

**Eta reduction rule:**

```
λx.(f x)  →η  f
```

Provided x does not appear free in f. This states that a function taking x and immediately passing it to f is equivalent to f itself. The lambda abstraction adds no computational content—it merely receives and forwards.

**Examples:**

```
λx.(+ 1 x)  →η  (+ 1)
λy.(map f y)  →η  (map f)
λz.((λx.x) z)  →η  (λx.x)
```

The first curries addition. The second eliminates the redundant list parameter. The third unwraps an identity function application.

**Point-free style connection:**

Eta reduction enables point-free (tacit) programming by eliminating explicit parameter mentions:

```clojure
;; Point-ful style
(defn add-one [x] (+ 1 x))

;; Point-free (after eta reduction)
(def add-one (partial + 1))

;; Point-ful composition
(defn process [data] (vec (filter even? (map inc data))))

;; Point-free composition
(def process (comp vec (partial filter even?) (partial map inc)))
```

**Eta expansion rule:**

The reverse direction also holds:

```
f  →η  λx.(f x)
```

Eta expansion wraps a function in a lambda that immediately applies it. This transformation is useful for delaying evaluation or making implicit parameters explicit for clarity.

**When eta conversion applies:**

Eta conversion requires the variable x to not appear free in f. Otherwise, the transformation changes meaning:

```
λx.(x x)  ≠η  x   ; INVALID - x is free in (x x)
λx.((λy.x) x)  ≠η  (λy.x)  ; INVALID - x is free in (λy.x)
```

The restriction ensures the function's behavior depends only on the parameter's value, not on other occurrences of that variable name.

**Extensional equality:**

Eta conversion formalizes extensionality: functions are equal if they behave identically on all inputs. `λx.(f x)` and `f` always produce the same result when applied, hence they're considered the same function.

This contrasts with intensional equality (syntactic equivalence). Intensionally, `λx.(+ 1 x)` differs from `(+ 1)`. Extensionally, they're identical since `(λx.(+ 1 x)) n` and `((+ 1) n)` always yield the same value.

**Practical implications:**

**Code simplification:**

```clojure
;; Before eta reduction
(map (fn [x] (inc x)) data)

;; After eta reduction  
(map inc data)
```

**Reasoning about equivalence:**

```clojure
;; These are eta-equivalent
(fn [x] (f (g x)))
(comp f g)
```

**Optimization opportunities** [Inference]:

Compilers use eta conversion for optimization. Eta reducing `λx.(f x)` to `f` eliminates an unnecessary function allocation and call. Conversely, eta expanding can expose opportunities for other optimizations like function inlining.

**Limitations in strict languages** [Inference]:

Eta conversion assumes termination. In strict evaluation, `f` and `λx.(f x)` differ when `f` is undefined (diverges or errors):

```
⊥  ≠  λx.(⊥ x)   ; In strict semantics
```

The left side immediately diverges, while the right side only diverges when applied. Lazy languages treat these as equivalent since they diverge on the same inputs.

**Relationship to beta reduction:**

Eta and beta reduction together form the **βη-calculus**. While beta defines computation (function application), eta defines function equivalence. A term in **βη-normal form** has no beta or eta redexes—it's fully simplified both computationally and structurally.

```
λx.(λy.y) x
→β λx.x       ; Beta reduction
→η (λy.y)     ; Then eta reduction reveals identity

; Or equivalently:
λx.(λy.y) x
→η (λy.y)     ; Eta reduction first
```

Both paths reach the same normal form, demonstrating confluence across both reduction types.

