## Lisp/Scheme concepts


Lisp and Scheme represent functional programming through symbolic computation, code-as-data, and extreme simplicity of core semantics.

**Homoiconicity and code as data**

Lisp code is written as lists—the same data structure the language manipulates. A function call `(+ 1 2)` is a list with three elements. This enables trivial metaprogramming: you construct and manipulate code using the same list operations used for data. The `quote` form prevents evaluation, turning code into data: `'(+ 1 2)` produces a list, not 3.

**Macros for language extension**

Lisp macros operate on syntax trees before evaluation. They receive unevaluated code as data structures, transform them, and return new code to evaluate. This enables creating new control structures and language features as libraries. Macros are hygienic in Scheme (avoiding variable capture) and provide quasiquote/unquote for convenient code templating.

**First-class continuations (Scheme)**

Scheme provides `call/cc` (call-with-current-continuation), reifying the current continuation as a first-class value. Invoking a captured continuation abandons the current computation and returns to the captured point with a value. This enables implementing exceptions, backtracking, coroutines, and other control abstractions in user code. Continuations make the flow of control explicit and programmable.

**Dynamic typing**

Traditional Lisps use dynamic typing—types are checked at runtime, not compile time. This provides flexibility and rapid development but sacrifices compile-time error detection. Typed Racket and other modern Lisps add gradual typing, allowing type annotations where desired while maintaining dynamic typing elsewhere.

**Garbage collection heritage**

Lisp invented garbage collection. Memory management is automatic and transparent. The runtime reclaims unreachable objects without programmer intervention. This enables straightforward functional programming without manual memory tracking.

**Tail call optimization guarantee**

Scheme requires implementations to optimize tail calls, making recursion as efficient as loops. Any call in tail position reuses the current stack frame. This makes recursive functional style practical for iteration—you write recursive functions knowing they won't overflow the stack.

**Lexical scoping and closures**

Scheme introduced lexical scoping to Lisp. Functions capture their defining environment, creating closures. A nested function can access and "close over" variables from its enclosing scope. This enables powerful abstraction patterns—you can return functions that remember their context.

**REPL-driven development**

Lisp pioneered the Read-Eval-Print Loop for interactive development. You develop programs incrementally, testing functions immediately in the REPL. You can redefine functions in a running program, making the edit-compile-run cycle instantaneous. This tight feedback loop influenced modern development environments.

**List-centric data structures**

Lisp's fundamental data structure is the cons cell, building lists and trees. Operations like `car` (first), `cdr` (rest), and `cons` (construct) manipulate these structures. While simple, this uniformity means learning a few operations provides tools for all data manipulation. Modern Lisps add vectors, hash tables, and other efficient structures while maintaining the list as the primary metaphor.

**S-expressions for everything**

Symbolic expressions (s-expressions) are nested lists representing both code and data. Every Lisp program is an s-expression. This uniformity simplifies parsing to nearly trivial complexity and makes program transformation straightforward. The parenthesized prefix notation, while initially unfamiliar, eliminates precedence ambiguity and makes structure explicit.

**Multiple return values and improper lists**

Scheme provides `values` for returning multiple values from functions efficiently, without allocating tuples. Improper lists (ending with an atom rather than nil) support variable-arity function parameters through dotted notation in parameter lists.

**Minimalist core semantics**

Scheme's specification defines an extremely small core language—most features are derived from primitives. The entire language can be understood deeply. This minimalism influenced language design broadly, demonstrating that powerful languages need not be complex.

