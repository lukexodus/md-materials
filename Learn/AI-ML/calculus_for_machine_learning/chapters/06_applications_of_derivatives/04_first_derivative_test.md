## First Derivative Test

### Definition

The first derivative test determines whether a critical point of a function is a local maximum, local minimum, or neither, by examining the sign of $f'(x)$ on either side of that point.

A critical point $x = c$ occurs where $f'(c) = 0$ or $f'(c)$ is undefined, provided $c$ is in the domain of $f$.

### Core Principle

If $f$ is continuous at $c$ and differentiable on an open interval around $c$ (except possibly at $c$ itself), then:

- If $f'(x)$ changes from positive to negative at $c$, $f$ has a **local maximum** at $c$.
- If $f'(x)$ changes from negative to positive at $c$, $f$ has a **local minimum** at $c$.
- If $f'(x)$ does not change sign at $c$, $f$ has **neither** a local max nor a local min at $c$ (often a saddle-like flat point or inflection-adjacent behavior).

### Procedure

1. Find $f'(x)$.
2. Solve $f'(x) = 0$ and identify any points where $f'(x)$ is undefined, to locate critical points.
3. Partition the domain into intervals using these critical points.
4. Evaluate the sign of $f'(x)$ in each interval (using a test point).
5. Compare signs across adjacent intervals to classify each critical point.

### Sign Chart (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="30" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">First Derivative Sign Chart (svg_diagram)</text>

  <line x1="60" y1="140" x2="640" y2="140" stroke="#333" stroke-width="2" />
  <line x1="220" y1="130" x2="220" y2="150" stroke="#333" stroke-width="2" />
  <line x1="480" y1="130" x2="480" y2="150" stroke="#333" stroke-width="2" />

  <text x="220" y="170" font-size="13" text-anchor="middle" fill="#1a1a1a">c₁</text>
  <text x="480" y="170" font-size="13" text-anchor="middle" fill="#1a1a1a">c₂</text>

  <text x="140" y="120" font-size="14" text-anchor="middle" fill="#0a6b0a">f'(x) &gt; 0</text>
  <text x="350" y="120" font-size="14" text-anchor="middle" fill="#b30000">f'(x) &lt; 0</text>
  <text x="560" y="120" font-size="14" text-anchor="middle" fill="#0a6b0a">f'(x) &gt; 0</text>

  <path d="M 90 105 L 200 105" stroke="#0a6b0a" stroke-width="3" marker-end="url(#arrowg)" />
  <path d="M 240 105 L 460 105" stroke="#b30000" stroke-width="3" marker-end="url(#arrowr)" />
  <path d="M 500 105 L 610 105" stroke="#0a6b0a" stroke-width="3" marker-end="url(#arrowg)" />

  <circle cx="220" cy="140" r="6" fill="#1a1a1a" />
  <circle cx="480" cy="140" r="6" fill="#1a1a1a" />

  <text x="220" y="200" font-size="13" text-anchor="middle" fill="#1a1a1a">Local Max</text>
  <text x="480" y="200" font-size="13" text-anchor="middle" fill="#1a1a1a">Local Min</text>

  <text x="350" y="235" font-size="12" text-anchor="middle" fill="#555">Sign change: + → − indicates max; − → + indicates min</text>
</svg>

### Worked Example

Let $f(x) = x^3 - 3x^2 - 9x + 5$.

**Step 1 — Derivative:**
$$f'(x) = 3x^2 - 6x - 9$$

**Step 2 — Critical points:**
$$3x^2 - 6x - 9 = 0 \implies x^2 - 2x - 3 = 0 \implies (x-3)(x+1) = 0$$
$$x = -1, \quad x = 3$$

**Step 3 — Test intervals:** $(-\infty, -1)$, $(-1, 3)$, $(3, \infty)$

**Step 4 — Sign evaluation:**

| Interval | Test point | $f'(x)$ sign | Behavior |
|---|---|---|---|
| $(-\infty, -1)$ | $x = -2$ | $f'(-2) = 12 + 12 - 9 = 15 > 0$ | increasing |
| $(-1, 3)$ | $x = 0$ | $f'(0) = -9 < 0$ | decreasing |
| $(3, \infty)$ | $x = 4$ | $f'(4) = 48 - 24 - 9 = 15 > 0$ | increasing |

**Step 5 — Classification:**
- At $x = -1$: $f'$ changes $+ \to -$ → local maximum, $f(-1) = 10$
- At $x = 3$: $f'$ changes $- \to +$ → local minimum, $f(3) = -22$

### Relevance to Machine Learning

In gradient-based optimization, the first derivative test conceptually parallels how gradient descent identifies stationary points where $\nabla L(\theta) = 0$.

- The sign-change logic underlies why gradient descent moves opposite to the gradient direction: it tracks where the loss $L$ transitions from decreasing to increasing.
- [Inference] For univariate loss functions or single-parameter slices of a loss surface, the first derivative test can be used to distinguish local minima from local maxima along that slice.
- [Unverified] Whether a given optimizer implementation explicitly performs sign-change analysis is not something this response can confirm; most practical ML optimizers (SGD, Adam, etc.) rely on gradient magnitude and direction rather than explicit sign-chart construction. Behavior may vary by framework and implementation, and no guarantee is made regarding convergence to a minimum versus a maximum or saddle point.
- In multivariable settings (typical in ML), the first derivative test alone is insufficient — a zero-gradient point could be a saddle point. This is why the second derivative test (via the Hessian) becomes necessary for full classification. [Inference]

### Limitations

- The test does not classify critical points where $f'(x)$ does not change sign (e.g., $f(x) = x^3$ at $x = 0$, which is a saddle point, not a max or min).
- In multivariate calculus, the direct analog requires a gradient sign analysis, which is not well-defined the same way in higher dimensions — this motivates the transition to the second derivative test using the Hessian matrix.
- [Unverified] This response does not verify behavior for every edge case (e.g., discontinuous derivatives, piecewise functions); such cases require direct application of the definition rather than reliance on general claims.

### Key Points

- First derivative test classifies critical points using sign changes of $f'(x)$.
- $+ \to -$ signals a local maximum; $- \to +$ signals a local minimum; no change signals neither.
- Requires continuity at the critical point and differentiability nearby (except possibly at the point itself).
- Directly connects to gradient-based reasoning in ML optimization, though multivariable ML settings require extensions (Hessian-based second derivative test) for full rigor.

**Related Topics**
- Second derivative test and concavity
- Hessian matrix and multivariable critical point classification
- Saddle points in high-dimensional loss surfaces
- Convexity and its role in optimization guarantees
- Gradient descent and stationary point analysis
- Inflection points and second derivative sign analysis