## Intuitive Notion of a Limit

### What a Limit Describes

A limit describes the value that a function $f(x)$ approaches as $x$ approaches some point $c$, regardless of whether $f(x)$ is actually defined at $c$.

$$\lim_{x \to c} f(x) = L$$

This reads: "as $x$ gets arbitrarily close to $c$, $f(x)$ gets arbitrarily close to $L$."

**Key Points**

- The limit concerns the behavior of $f$ *near* $c$, not necessarily the value *at* $c$
- $f(c)$ may be undefined, and the limit can still exist
- $f(c)$ may be defined but differ from the limit value
- Limits are foundational to defining derivatives, integrals, and continuity

This is a standard, verifiable mathematical definition found in any calculus reference.

### Approaching from Both Sides

A limit exists at $c$ only if the function approaches the same value from both the left side and the right side of $c$.

$$\lim_{x \to c^-} f(x) = \lim_{x \to c^+} f(x) = L \implies \lim_{x \to c} f(x) = L$$

If the left-hand and right-hand limits differ, the two-sided limit does not exist at that point.

**Example**

Consider $f(x) = \dfrac{x^2 - 4}{x - 2}$ at $x = 2$.

The function is undefined at $x = 2$ (division by zero), but for $x \neq 2$:

$$f(x) = \frac{(x-2)(x+2)}{x-2} = x + 2$$

As $x$ approaches 2 from either side, $f(x)$ approaches $4$:

$$\lim_{x \to 2} f(x) = 4$$

even though $f(2)$ itself is undefined. This is a verifiable algebraic and limit computation.

### Numerical Intuition: Approaching a Value

| $x$ | $f(x) = x + 2$ (for $x \neq 2$) |
|---|---|
| 1.9 | 3.9 |
| 1.99 | 3.99 |
| 1.999 | 3.999 |
| 2.001 | 4.001 |
| 2.01 | 4.01 |
| 2.1 | 4.1 |

As $x$ gets closer to 2 from either direction, $f(x)$ gets closer to 4. This table illustrates the intuitive numerical approach to estimating a limit and is directly computable by substitution.

### Visualizing a Limit with a Removable Discontinuity

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 280">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Limit at a Point of Removable Discontinuity (svg_diagram)</text>

  <line x1="60" y1="230" x2="650" y2="230" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="40" x2="350" y2="250" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="235" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="45" font-size="11" font-family="sans-serif">y</text>

  <line x1="100" y1="210" x2="600" y2="70" stroke="#1d4ed8" stroke-width="2.5" />

  <circle cx="350" cy="140" r="6" fill="white" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="360" y="130" font-size="11" font-family="sans-serif" fill="#1d4ed8">f(2) undefined</text>

  <line x1="350" y1="230" x2="350" y2="140" stroke="#b91c1c" stroke-width="1" stroke-dasharray="4,4" />
  <line x1="60" y1="140" x2="350" y2="140" stroke="#b91c1c" stroke-width="1" stroke-dasharray="4,4" />
  <text x="65" y="135" font-size="10" font-family="sans-serif" fill="#b91c1c">L = 4</text>
  <text x="355" y="245" font-size="10" font-family="sans-serif" fill="#b91c1c">x = 2</text>
</svg>

This diagram is a conceptual, schematic illustration of the removable discontinuity described in the example above, not a precisely scaled plot.

### Limits That Do Not Exist

A limit can fail to exist for several reasons:

| Reason | Description | Example |
|---|---|---|
| Jump discontinuity | Left and right limits differ | Step function at the jump point |
| Unbounded behavior | Function grows without bound near the point | $\dfrac{1}{x}$ as $x \to 0$ |
| Oscillation | Function oscillates infinitely without settling | $\sin\left(\dfrac{1}{x}\right)$ as $x \to 0$ |

These are standard classifications found in calculus references and are verifiable through direct analysis of each function's behavior.

**Example**

For $f(x) = \dfrac{1}{x}$:

$$\lim_{x \to 0^-} f(x) = -\infty, \qquad \lim_{x \to 0^+} f(x) = +\infty$$

Since these one-sided limits are not equal (and neither is finite), $\lim_{x \to 0} f(x)$ does not exist in the conventional (finite) sense.

### Why Limits Matter Before Formal Definitions

The intuitive notion of "getting arbitrarily close" precedes the formal $\epsilon$-$\delta$ definition of a limit, which provides a rigorous way to state precisely what "arbitrarily close" means. The intuitive version is typically introduced first for conceptual understanding, with the formal definition following separately.

### Relevance to Machine Learning

#### Derivatives as Limits

The derivative of a function is itself defined as a limit:

$$f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$

This is the formal definition of the derivative, which underlies gradient computation used throughout machine learning optimization (e.g., gradient descent). This is a standard, verifiable calculus definition.

#### Convergence of Sequences in Optimization

[Inference] Gradient descent and related optimization algorithms are often discussed in terms of whether a sequence of parameter values or loss values converges to a limiting value as the number of iterations increases; this framing draws on the same limiting concept discussed here. I cannot verify without a specific citation that this exact framing is used identically across all optimization literature, though the general connection between limits and convergence is a standard mathematical relationship.

#### Asymptotic Behavior of Activation Functions

Limits describe the boundary behavior of activation functions:

$$\lim_{x \to \infty} \sigma(x) = 1, \qquad \lim_{x \to -\infty} \sigma(x) = 0$$

for the sigmoid function $\sigma(x) = \dfrac{1}{1+e^{-x}}$. This is a verifiable mathematical limit computation.

**Key Points**

- [Inference] Understanding these limiting values can help explain why sigmoid outputs saturate near 0 or 1 for large-magnitude inputs, which is sometimes discussed in relation to the vanishing gradient problem. I cannot verify without a specific citation that this exact causal explanation is presented identically across all sources discussing vanishing gradients, though the mathematical saturation behavior itself is directly verifiable from the limit computation above.

### Summary

| Concept | Description |
|---|---|
| Limit | Value a function approaches near a point |
| Two-sided limit | Requires left-hand limit = right-hand limit |
| Limit existence | Independent of whether $f(c)$ is defined |
| Formal follow-up | $\epsilon$-$\delta$ definition provides rigor |

**Related Topics**

- Formal $\epsilon$-$\delta$ definition of a limit
- One-sided limits
- Limits at infinity and horizontal asymptotes
- Continuity and its relationship to limits
- Derivative as a limit of a difference quotient