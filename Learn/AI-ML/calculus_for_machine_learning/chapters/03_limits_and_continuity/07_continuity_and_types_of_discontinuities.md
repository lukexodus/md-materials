## Continuity and Types of Discontinuities

### Formal Definition of Continuity

A function $f(x)$ is continuous at a point $x = a$ if and only if all three conditions hold:

$$1.\ f(a) \text{ is defined} \qquad 2.\ \lim_{x \to a} f(x) \text{ exists} \qquad 3.\ \lim_{x \to a} f(x) = f(a)$$

If any one of these three conditions fails, the function is discontinuous at $x = a$. [Inference] This three-condition formulation is the standard definition presented across most calculus references, though some texts state it more compactly as a single combined limit condition.

A function is continuous on an interval if it is continuous at every point within that interval.

### Left-Hand and Right-Hand Continuity

Continuity can also be expressed in terms of one-sided limits:

$$\lim_{x \to a^-} f(x) = \lim_{x \to a^+} f(x) = f(a)$$

If the left-hand limit and right-hand limit both exist, are equal to each other, and equal $f(a)$, the function is continuous at that point. This decomposition is particularly useful for identifying discontinuities at piecewise function boundaries.

### Type 1: Removable Discontinuity

A removable discontinuity occurs when $\lim_{x \to a} f(x)$ exists (the left and right limits agree), but either $f(a)$ is undefined or $f(a)$ does not equal the limit value. The discontinuity can be "removed" by redefining the function at that single point.

**Example**

$$f(x) = \frac{x^2 - 4}{x - 2}$$

At $x = 2$, the function is undefined (denominator is zero), but:

$$\lim_{x \to 2} \frac{x^2-4}{x-2} = \lim_{x \to 2}(x+2) = 4$$

Since the limit exists and equals $4$, this is a removable discontinuity — redefining $f(2) = 4$ would make the function continuous at that point.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 350">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Removable Discontinuity (svg_diagram)</text>
  <line x1="40" y1="300" x2="460" y2="300" stroke="#999" stroke-width="1" />
  <line x1="250" y1="30" x2="250" y2="320" stroke="#999" stroke-width="1" />
  <line x1="60" y1="260" x2="240" y2="120" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <line x1="260" y1="100" x2="440" y2="60" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <circle cx="250" cy="110" r="6" fill="white" stroke="#1a5fb4" stroke-width="2" />
  <text x="255" y="100" font-size="11" fill="#555">hole at x = 2</text>
</svg>

### Type 2: Jump Discontinuity

A jump discontinuity occurs when both the left-hand and right-hand limits exist but are not equal to each other:

$$\lim_{x \to a^-} f(x) \neq \lim_{x \to a^+} f(x)$$

Unlike a removable discontinuity, this cannot be fixed by redefining a single point, since the function approaches two genuinely different values from each side.

**Example**

$$f(x) = \begin{cases} x + 1 & x < 1 \\ x - 1 & x \geq 1 \end{cases}$$

$$\lim_{x \to 1^-} f(x) = 2, \qquad \lim_{x \to 1^+} f(x) = 0$$

Since $2 \neq 0$, there is a jump discontinuity at $x = 1$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 350">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Jump Discontinuity (svg_diagram)</text>
  <line x1="40" y1="300" x2="460" y2="300" stroke="#999" stroke-width="1" />
  <line x1="250" y1="30" x2="250" y2="320" stroke="#999" stroke-width="1" />
  <line x1="80" y1="230" x2="248" y2="100" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <circle cx="250" cy="98" r="6" fill="white" stroke="#1a5fb4" stroke-width="2" />
  <line x1="252" y1="200" x2="420" y2="80" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <circle cx="250" cy="200" r="6" fill="#1a5fb4" />
  <text x="260" y="230" font-size="11" fill="#555">x = 1</text>
</svg>

### Type 3: Infinite Discontinuity

An infinite discontinuity occurs when one or both one-sided limits diverge to $\infty$ or $-\infty$ as $x \to a$. This type is directly connected to vertical asymptotes.

**Example**

$$f(x) = \frac{1}{x-3}$$

$$\lim_{x \to 3^-} f(x) = -\infty, \qquad \lim_{x \to 3^+} f(x) = +\infty$$

Neither one-sided limit exists as a finite value, so the discontinuity at $x = 3$ is classified as infinite.

### Type 4: Oscillating Discontinuity

An oscillating discontinuity occurs when the function oscillates infinitely as $x$ approaches $a$, such that neither the left-hand nor right-hand limit settles on a single value.

**Example**

$$f(x) = \sin\left(\frac{1}{x}\right) \text{ at } x = 0$$

As $x \to 0$, $\frac{1}{x} \to \pm\infty$, causing $\sin(1/x)$ to oscillate between $-1$ and $1$ infinitely often without approaching any single value. [Inference] This is a commonly cited standard example of oscillating discontinuity in calculus references, though it is sometimes categorized under "essential discontinuities" rather than as its own separate type depending on the textbook.

### Removable vs. Non-Removable: Classification Summary

| Discontinuity Type | Limit Exists? | Left = Right Limit? | Can Be "Fixed"? |
|---|---|---|---|
| Removable | Yes | Yes | Yes (redefine one point) |
| Jump | One-sided limits exist | No | No |
| Infinite | No (diverges) | N/A | No |
| Oscillating | No | N/A | No |

I cannot verify that every calculus curriculum uses identical terminology for these categories; some sources group jump, infinite, and oscillating discontinuities together under the umbrella term "essential discontinuity" or "non-removable discontinuity."

### Piecewise Functions and Continuity Checks

For piecewise-defined functions, continuity at boundary points must be checked explicitly using the three-condition definition above, rather than assumed.

**Example**

$$f(x) = \begin{cases} x^2 & x \leq 2 \\ 3x - 2 & x > 2 \end{cases}$$

At $x = 2$: $\lim_{x \to 2^-} x^2 = 4$, and $\lim_{x \to 2^+} (3x-2) = 4$. Since both one-sided limits equal $4$, and $f(2) = 2^2 = 4$, the function is continuous at $x = 2$.

### Relevance to Machine Learning

Continuity properties are directly relevant to several ML contexts:

- **Activation function design**: Functions like ReLU, defined as $f(x) = \max(0, x)$, are continuous everywhere but not differentiable at $x = 0$. [Inference] This distinction between continuity and differentiability is mathematically well-established, and the ReLU non-differentiability point is a commonly cited property, though how specific frameworks handle the gradient at exactly $x=0$ (e.g., defaulting to $0$ or $1$) is an implementation choice I cannot verify is standardized across all libraries.
- **Loss function requirements**: Many optimization algorithms, including gradient descent, assume or benefit from continuity of the loss function, since discontinuities can create regions where gradient information is unreliable or undefined. [Unverified] I do not have a specific verified source confirming this as a strict mathematical requirement across all gradient-based optimizers, since some methods are designed to handle certain forms of non-smoothness.
- **Data preprocessing and step functions**: Discretization or binning procedures applied to continuous input data can introduce artificial jump discontinuities into otherwise continuous relationships. [Speculation] This is a plausible general observation based on the structure of discretization, but I do not have a specific verified source describing this exact framing in ML literature.

Claims regarding how any specific ML framework or library handles discontinuous or non-differentiable functions internally are not guaranteed to reflect current implementation behavior, since behavior may vary by version and is not something I can verify without direct inspection of source code or documentation.

**Next Steps**

- Intermediate Value Theorem: formal statement and applications to root-finding
- Derivatives via limits: the difference quotient and formal derivative definition
- Differentiability implies continuity (and why the converse is false)
- L'Hôpital's Rule: formal statement and valid application conditions
- Squeeze Theorem

If any part of this response is later found to conflict with a verified source:
> Correction: I made an unverified claim. That was incorrect.