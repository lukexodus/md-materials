## Lambda Calculus Basics


Lambda calculus is a formal system for expressing computation through function abstraction and application. Created by Alonzo Church in the 1930s, it consists of three syntactic elements and two reduction rules, yet captures all computable functions.

**Syntax:**

Lambda terms have three forms:

- **Variables**: `x`, `y`, `z` (identifiers)
- **Abstraction**: `λx.M` (function definition, where M is the body)
- **Application**: `(M N)` (function M applied to argument N)

The lambda symbol (λ) introduces a function binding a variable. The dot separates the parameter from the body. Parentheses indicate application.

**Examples:**

```
λx.x           ; Identity function
λx.λy.x        ; Constant function (returns first argument, ignores second)
λf.λx.f(f x)   ; Apply f twice to x
(λx.x x)(λx.x x) ; Self-application
```

**Variable binding and scope:**

In `λx.M`, the variable x is **bound** in M. The scope of x extends throughout M. Variables not bound by any lambda are **free variables**. The term `λx.x y` has x bound and y free.

**Alpha equivalence:**

Renaming bound variables doesn't change a term's meaning. `λx.x` and `λy.y` are α-equivalent—they represent the same function. Alpha conversion allows renaming to avoid variable capture during substitution.

```
λx.λy.x  ≡  λa.λb.a   ; Same function, different variable names
```

**Currying convention:**

Multiple parameters are expressed through nested abstractions. `λx.λy.M` is abbreviated as `λxy.M`. Application is left-associative: `M N P` means `((M N) P)`.

```
λxy.x y     ; Abbreviation for λx.λy.x y
f g h       ; Abbreviation for (f g) h
```

**Pure lambda calculus:**

The pure system contains only variables, abstraction, and application. No primitive numbers, booleans, or arithmetic operators exist—these are encoded as functions (Church encoding). This minimalism demonstrates that functions suffice for all computation.

**Evaluation strategies:**

Lambda calculus allows multiple evaluation orders:

- **Normal order**: Always reduce the leftmost outermost redex first
- **Applicative order**: Reduce arguments before applying functions (call-by-value)
- **Lazy evaluation**: Reduce only when needed, memoize results

Different strategies may diverge on whether evaluation terminates, though normal order guarantees finding a normal form if one exists (by the standardization theorem).

**Computational completeness:**

Lambda calculus is Turing-complete. Every computable function expressible in any programming language has an equivalent lambda term. Recursion, despite lacking explicit self-reference syntax, emerges through fixed-point combinators like the Y combinator.

**Connection to functional programming:**

Modern functional languages are lambda calculus with added features:

- Named definitions (syntactic sugar for let-binding)
- Primitive types (optimization, not theoretical necessity)
- Pattern matching (structured decomposition)
- Type systems (constraint on valid terms)

Understanding lambda calculus provides insight into function semantics, closure behavior, and why certain language features (like lexical scoping) are fundamental rather than arbitrary design choices.

