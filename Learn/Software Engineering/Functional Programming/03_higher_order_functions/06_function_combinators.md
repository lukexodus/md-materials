## Function Combinators


Function combinators are higher-order functions that combine multiple functions to create new functions. They represent fundamental patterns of function composition and control flow, forming the algebraic foundation of functional programming.

### Core Combinators

**Identity Combinator (I):**

```javascript
const I = (x) => x;

// Useful as default or no-op
[1, 2, 3].map(I); // [1, 2, 3]
```

**Constant Combinator (K):**

```javascript
const K = (x) => (y) => x;

const alwaysTrue = K(true);
alwaysTrue(false); // true

// Useful for default values
const getOrDefault = (value, defaultValue) => 
  value !== undefined ? value : K(defaultValue)();
```

**Compose (B Combinator):**

```javascript
const compose = (...fns) => (x) =>
  fns.reduceRight((acc, fn) => fn(acc), x);

const addOne = (x) => x + 1;
const double = (x) => x * 2;
const square = (x) => x * x;

const transform = compose(square, double, addOne);
transform(3); // ((3 + 1) * 2)² = 64
```

**Pipe (reverse compose):**

```javascript
const pipe = (...fns) => (x) =>
  fns.reduce((acc, fn) => fn(acc), x);

const transform = pipe(addOne, double, square);
transform(3); // same as compose but left-to-right
```

### Function Application Combinators

**Apply (A Combinator):**

```javascript
const apply = (fn) => (x) => fn(x);

const applyDouble = apply(double);
applyDouble(5); // 10
```

**Flip:**

```javascript
const flip = (fn) => (a) => (b) => fn(b)(a);

const subtract = (a) => (b) => a - b;
const flippedSubtract = flip(subtract);

subtract(10)(3); // 7
flippedSubtract(10)(3); // -7
```

**Converge (fork combinator):**

```javascript
const converge = (combiner, ...branches) => {
  return (...args) => {
    const results = branches.map(fn => fn(...args));
    return combiner(...results);
  };
};

const average = converge(
  (sum, length) => sum / length,
  (arr) => arr.reduce((a, b) => a + b, 0),
  (arr) => arr.length
);

average([1, 2, 3, 4, 5]); // 3
```

### Control Flow Combinators

**Alternation (Alt):**

```javascript
const alt = (fn1, fn2) => {
  return (...args) => {
    try {
      return fn1(...args);
    } catch {
      return fn2(...args);
    }
  };
};

const safeParse = alt(
  (str) => JSON.parse(str),
  (str) => null
);
```

**Tap (K combinator variant):**

```javascript
const tap = (fn) => (x) => {
  fn(x);
  return x;
};

const logAndContinue = tap(console.log);

pipe(
  addOne,
  logAndContinue, // logs but doesn't transform
  double
)(5); // logs 6, returns 12
```

**Trampoline (for recursion optimization):**

```javascript
const trampoline = (fn) => {
  return (...args) => {
    let result = fn(...args);
    while (typeof result === 'function') {
      result = result();
    }
    return result;
  };
};

const factorial = trampoline((n, acc = 1) => {
  if (n <= 1) return acc;
  return () => factorial(n - 1, n * acc);
});

factorial(10000); // doesn't blow the stack
```

### Advanced Combinators

**Y Combinator (fixed-point combinator):**

```javascript
const Y = (f) => {
  return ((x) => f((y) => x(x)(y)))
         ((x) => f((y) => x(x)(y)));
};

const factorial = Y((recurse) => (n) =>
  n <= 1 ? 1 : n * recurse(n - 1)
);

factorial(5); // 120
```

**S Combinator (substitution):**

```javascript
const S = (f) => (g) => (x) => f(x)(g(x));

const add = (a) => (b) => a + b;
const square = (x) => x * x;

const computation = S(add)(square);
computation(3); // 3 + 9 = 12
```

**Psi Combinator (on):**

```javascript
const on = (binaryFn) => (unaryFn) => (a) => (b) =>
  binaryFn(unaryFn(a))(unaryFn(b));

const compareByLength = on((a) => (b) => a - b)((str) => str.length);

['aaa', 'b', 'cc'].sort(compareByLength); // ['b', 'cc', 'aaa']
```

### Practical Combinator Patterns

**Monad Bind (chain):**

```javascript
const chain = (fn) => (monad) => monad.flatMap(fn);

const safeDivide = (a) => (b) =>
  b === 0 ? Nothing() : Just(a / b);

const result = chain(safeDivide(10))(Just(2)); // Just(5)
```

**Applicative Apply:**

```javascript
const ap = (fnWrapper) => (valueWrapper) =>
  fnWrapper.flatMap(fn => valueWrapper.map(fn));

const add = (a) => (b) => a + b;
ap(Just(add(2)))(Just(3)); // Just(5)
```

**Key Points:**

- Combinators form a complete computational basis (SKI calculus)
- They eliminate the need for variable names in lambda calculus
- Point-free style emerges naturally from combinator use
- Understanding combinators deepens comprehension of functional patterns
- Most practical code uses a small subset (compose, pipe, tap, converge)
- Combinators are language-agnostic and appear across all FP languages

