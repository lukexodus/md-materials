## Fixed-point combinators


A fixed-point combinator is a higher-order function that computes the fixed point of another function. For a function `f`, a fixed point is a value `x` such that `f(x) = x`. In the context of functions that operate on functions, the fixed-point combinator finds a function that, when applied to itself, reproduces itself.

Fixed-point combinators enable recursion without self-reference. A function can be recursive without naming itself, which is crucial in lambda calculus where functions are anonymous. The combinator transforms a non-recursive function that describes recursion into an actually recursive function.

**Conceptual foundation**: Consider a function `f` that takes itself as a parameter. If we could find `x` where `x = f(x)`, then `x` would be a self-sustaining recursive function. The fixed-point combinator constructs this `x` from `f`.

The mathematical definition in lambda calculus: `FIX f = f (FIX f)`. The combinator applies `f` to its own fixed point, creating infinite unfolding.

**Non-recursive factorial description**:

```javascript
const factorialBuilder = self => n => 
  n <= 1 ? 1 : n * self(n - 1);
```

This describes factorial's logic but doesn't call itself directly. It expects to receive itself as the `self` parameter. A fixed-point combinator converts this into a working recursive function.

**Simple fixed-point combinator** (non-terminating without lazy evaluation):

```javascript
const fix = f => f(fix(f));
```

This definition is elegant but problematic in strict evaluation languages. It creates infinite recursion immediately because `fix(f)` evaluates before `f` receives it.

**Z combinator** (strict evaluation fixed-point combinator):

```javascript
const Z = f => 
  (x => f(v => x(x)(v)))
  (x => f(v => x(x)(v)));

const factorial = Z(factorialBuilder);
```

The Z combinator wraps the self-application in a lambda (`v => x(x)(v)`), delaying evaluation until the function is actually called with an argument. This makes it work in strict languages like JavaScript.

**How it works**: The innermost `x(x)` creates self-replication. When called with a value `v`, it triggers `x(x)(v)`, which recursively generates the same structure. The outer `f` wraps this, giving the function builder access to the recursive reference.

Fixed-point combinators prove that recursion is not a primitive requirement in a language. Any recursive computation can be expressed using only lambda abstraction and application, without built-in recursion mechanisms or variable binding for self-reference.

**[Inference]** The existence of fixed-point combinators demonstrates that Turing completeness emerges from surprisingly minimal foundations. Even purely anonymous functions can express unbounded computation through self-application.

Practical use in modern programming is limited. Named recursion and trampolining are clearer and more maintainable. However, fixed-point combinators provide theoretical insights into the nature of recursion and serve as foundations for advanced type system features like recursive types.

