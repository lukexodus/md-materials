## Beta Reduction


Beta reduction is the fundamental computation rule in lambda calculus, defining how function application evaluates. It replaces a bound variable throughout the function body with the supplied argument, mechanizing the notion of "calling a function."

**Beta reduction rule:**

```
(λx.M) N  →β  M[x := N]
```

This notation means: applying the function `λx.M` to argument `N` reduces to the body `M` with all free occurrences of `x` replaced by `N`. The bracketed substitution `M[x := N]` denotes textual replacement.

**Simple examples:**

```
(λx.x) 5
→β 5

(λx.x x) y
→β y y

(λx.λy.x) a b
→β (λy.a) b
→β a
```

The identity function applied to 5 returns 5. Self-application duplicates the argument. The constant function discards its second argument.

**Substitution mechanics:**

Substitution must avoid variable capture. When substituting `N` for `x` in `M`, any free variables in `N` must not become accidentally bound by lambdas in `M`.

```
(λx.λy.x) y
→β λy.y   ; WRONG - y captured!
```

The free `y` in the argument should remain free after substitution, but naïve replacement makes it bound. Alpha conversion prevents this:

```
(λx.λy.x) y
≡α (λx.λz.x) y   ; Rename to avoid capture
→β λz.y          ; Correct - y stays free
```

**Capture-avoiding substitution definition** [Inference]:

```
x[x := N] = N
y[x := N] = y                    (if y ≠ x)
(M₁ M₂)[x := N] = (M₁[x := N])(M₂[x := N])
(λx.M)[x := N] = λx.M            (x is shadowed)
(λy.M)[x := N] = λy.(M[x := N])  (if y ≠ x and y not free in N)
(λy.M)[x := N] = λz.(M[y := z][x := N])  (rename y to fresh z if needed)
```

**Reduction strategies:**

Multiple redexes (reducible expressions) may exist simultaneously. Different reduction orders affect performance and termination:

```
(λx.λy.y) ((λz.z z)(λz.z z))
```

**Normal order** reduces the leftmost outermost redex first:

```
→β λy.y   ; Discard argument without evaluating it
```

**Applicative order** reduces arguments first:

```
→β (λx.λy.y)((λz.z z)(λz.z z))
→β (λx.λy.y)((λz.z z)(λz.z z))
→β ...     ; Infinite loop
```

Normal order terminates while applicative order diverges. The Church-Rosser theorem guarantees that if a term has a normal form, normal order finds it.

**Multi-step reduction:**

Terms often require multiple beta reductions:

```
(λx.x x)(λy.y)
→β (λy.y)(λy.y)
→β λy.y
```

The notation `→β*` represents zero or more beta reductions. A term in **normal form** contains no redexes—no further reduction is possible.

**Confluence:**

Beta reduction is confluent: if a term reduces to multiple different terms via different paths, those terms can reduce further to a common result. This diamond property ensures evaluation order affects efficiency but not the final answer (when it exists).

```
      M
     / \
   M₁   M₂
     \ /
      N
```

**Computational interpretation:**

Beta reduction is function execution. The lambda calculus program runs by repeatedly finding and reducing redexes until reaching normal form (the answer) or diverging. Modern functional language interpreters implement optimized versions of beta reduction with environment-based substitution instead of textual replacement.

