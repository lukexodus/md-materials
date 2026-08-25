## Y combinator


The Y combinator is the most famous fixed-point combinator, originally defined by Haskell Curry in lambda calculus. Its canonical form is: `Y = λf.(λx.f(x x))(λx.f(x x))`. This combinator enables anonymous recursion through self-application.

In JavaScript notation:

```javascript
const Y = f => 
  (x => x(x))
  (x => f(y => x(x)(y)));
```

The structure mirrors the mathematical definition but adds eta-expansion (`y => x(x)(y)`) to prevent immediate infinite evaluation in strict languages.

**Derivation insight**: The Y combinator exploits self-application to create infinite unfolding. The term `x(x)` applies a function to itself. When wrapped carefully, this self-application generates the recursive behavior we need without explicit names.

**Using Y combinator for recursion**:

```javascript
const factorial = Y(self => n =>
  n <= 1 ? 1 : n * self(n - 1)
);

const fibonacci = Y(self => n =>
  n < 2 ? n : self(n - 1) + self(n - 2)
);

factorial(5);    // 120
fibonacci(10);   // 55
```

The function builder receives `self`, which is the recursive reference created by the combinator's self-application mechanism. Each call to `self` triggers another unfolding of the fixed point.

**Distinction from Z combinator**: The Y combinator is the pure lazy-evaluation form. The Z combinator adds strictness handling. In languages with normal-order evaluation (Haskell), Y works directly. In applicative-order languages (JavaScript, Scheme), Z or eta-expanded Y is required.

The Y combinator demonstrates that recursion emerges from the structure of lambda calculus itself, not as an add-on feature. It encodes the concept "apply a function to its own result indefinitely" using only function abstraction and application.

**Multiple recursion**: You can create mutually recursive functions using a fixed-point combinator on a tuple:

```javascript
const YMulti = f => {
  const tuple = f((...args) => tuple[0](...args), 
                  (...args) => tuple[1](...args));
  return tuple;
};

const [isEven, isOdd] = YMulti((even, odd) => [
  n => n === 0 ? true : odd(n - 1),
  n => n === 0 ? false : even(n - 1)
]);
```

This extends the self-application principle to multiple functions that reference each other.

**Type system implications**: In typed lambda calculus, the Y combinator cannot be given a type in simply-typed systems because it involves self-application, which creates infinite types. Recursive types or type fixpoints are required to type Y properly, connecting it deeply to recursion at the type level.

**[Inference]** The Y combinator's significance extends beyond practical programming. It represents a fundamental discovery about computation: that infinite processes can be encoded finitely through self-reference, and that this self-reference can itself be abstracted into a reusable component.

**Historical context**: The Y combinator predates modern computing and emerged from pure mathematical logic. Its discovery that recursion is not primitive but derivable influenced the theoretical foundations of programming language design and computability theory.

Performance in practice is poor. The nested function applications create overhead, and modern optimizers don't recognize the pattern. For production code, use direct recursion or trampolining. The Y combinator's value lies in its theoretical elegance and what it reveals about the computational power of lambda calculus.

