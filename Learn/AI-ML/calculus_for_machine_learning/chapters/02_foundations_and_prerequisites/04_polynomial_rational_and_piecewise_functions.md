## Polynomial, Rational, and Piecewise Functions

### Polynomial Functions

A polynomial function has the general form:

$$f(x) = a_n x^n + a_{n-1}x^{n-1} + \cdots + a_1 x + a_0$$

where $n$ is a non-negative integer (the **degree**) and $a_n \neq 0$.

**Key Points**

- Domain: $\mathbb{R}$ for all polynomials (no restrictions)
- Range: depends on degree and leading coefficient
- Polynomials are continuous and differentiable everywhere on $\mathbb{R}$
- The degree determines the maximum number of real roots and the general shape of the graph

#### Degree and Range Behavior

| Degree | Example | End Behavior | Typical Range |
|---|---|---|---|
| 0 (constant) | $f(x) = 5$ | Flat | $\{5\}$ |
| 1 (linear) | $f(x) = 2x + 1$ | Opposite ends diverge | $\mathbb{R}$ |
| 2 (quadratic) | $f(x) = x^2$ | Both ends → same sign infinity | $[0, \infty)$ or $(-\infty, c]$ |
| 3 (cubic) | $f(x) = x^3$ | Opposite ends diverge | $\mathbb{R}$ |
| Even degree | $f(x) = x^4 - 2x^2$ | Both ends → $+\infty$ or $-\infty$ | Bounded on one side |
| Odd degree | $f(x) = x^5 - x$ | Opposite ends diverge | $\mathbb{R}$ |

**Example**

For $f(x) = x^2 - 4x + 3$:

Vertex form: $f(x) = (x-2)^2 - 1$

Minimum value is $-1$ at $x = 2$, so:

$$\text{Range} = [-1, \infty)$$

### Relevance of Polynomials to Machine Learning

- Polynomial regression models fit data using polynomial basis functions
- Loss surfaces for linear regression with squared error are quadratic (degree 2) in the parameters, which guarantees a single global minimum for convex cases
- [Inference] Higher-degree polynomial features can increase model flexibility but may also increase risk of overfitting; the specific effect depends on data, regularization, and model configuration, so this cannot be stated as a general rule for every case

### Rational Functions

A rational function is a ratio of two polynomials:

$$f(x) = \frac{p(x)}{q(x)}, \quad q(x) \neq 0$$

**Key Points**

- Domain excludes all $x$ where $q(x) = 0$
- Vertical asymptotes occur at values excluded from the domain (where the denominator is zero and the numerator is not simultaneously zero at that point)
- Horizontal or slant asymptotes describe end behavior, depending on the relative degrees of $p(x)$ and $q(x)$

#### Asymptote Rules

| Condition | Horizontal Asymptote |
|---|---|
| $\deg(p) < \deg(q)$ | $y = 0$ |
| $\deg(p) = \deg(q)$ | $y = \dfrac{\text{leading coeff of } p}{\text{leading coeff of } q}$ |
| $\deg(p) > \deg(q)$ | None (may have slant/oblique asymptote) |

**Example**

$f(x) = \dfrac{x^2 - 1}{x - 1}$

Factoring: $f(x) = \dfrac{(x-1)(x+1)}{x-1}$

For $x \neq 1$, this simplifies to $f(x) = x + 1$, but $x = 1$ remains excluded from the domain (a removable discontinuity, not a vertical asymptote):

$$\text{Domain} = (-\infty, 1) \cup (1, \infty)$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Rational Function with Vertical Asymptote (svg_diagram)</text>

  <line x1="50" y1="220" x2="650" y2="220" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="40" x2="350" y2="240" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="225" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="45" font-size="11" font-family="sans-serif">y</text>

  <line x1="450" y1="40" x2="450" y2="240" stroke="#dc2626" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="460" y="55" font-size="11" font-family="sans-serif" fill="#dc2626">x = 1 (excluded)</text>

  <path d="M 100 210 Q 250 190 340 60" fill="none" stroke="#1d4ed8" stroke-width="2.5" />
  <path d="M 460 210 Q 550 130 620 60" fill="none" stroke="#1d4ed8" stroke-width="2.5" />

  <text x="150" y="240" font-size="10" text-anchor="middle" font-family="sans-serif">domain excludes x=1</text>
</svg>

### Relevance of Rational Functions to Machine Learning

- Some normalization and regularization formulas involve rational expressions (e.g., certain learning rate schedules, attention scaling factors)
- [Inference] Domains of rational functions matter when a denominator could theoretically reach zero during computation (such as a variance term in a normalization layer); many implementations add a small constant $\epsilon$ to denominators to avoid division by zero, but I cannot verify whether this technique is used in every specific framework or layer without checking that implementation's source directly

### Piecewise Functions

A piecewise function is defined by different expressions over different intervals of its domain.

$$f(x) = \begin{cases} \text{expression 1} & \text{if } x \in \text{interval 1} \\ \text{expression 2} & \text{if } x \in \text{interval 2} \\ \vdots & \vdots \end{cases}$$

**Key Points**

- Each piece has its own sub-domain, and the sub-domains together must cover the full domain without overlap (unless values agree at boundaries)
- Continuity at boundary points must be checked separately; a piecewise function is not automatically continuous
- Differentiability at boundary points requires matching one-sided derivatives, in addition to continuity

**Example**

The absolute value function is a classic piecewise definition:

$$|x| = \begin{cases} x & x \ge 0 \\ -x & x < 0 \end{cases}$$

This function is continuous everywhere but not differentiable at $x = 0$, since the left-hand derivative ($-1$) and right-hand derivative ($+1$) do not match.

### Piecewise Functions Relevant to Machine Learning

| Function | Definition | Continuous? | Differentiable Everywhere? |
|---|---|---|---|
| ReLU | $\begin{cases} x & x \ge 0 \\ 0 & x < 0 \end{cases}$ | Yes | No (kink at $x=0$) |
| Leaky ReLU | $\begin{cases} x & x \ge 0 \\ \alpha x & x < 0 \end{cases}$, $\alpha$ small | Yes | No (kink at $x=0$) |
| Hinge loss | $\max(0, 1 - y \cdot f(x))$ | Yes | No (kink at boundary) |
| Huber loss | Quadratic near 0, linear beyond threshold | Yes | Yes (constructed to match derivatives at the boundary) |

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 260">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">ReLU as a Piecewise Function (svg_diagram)</text>

  <line x1="50" y1="200" x2="650" y2="200" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="40" x2="350" y2="220" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="205" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="45" font-size="11" font-family="sans-serif">y</text>

  <line x1="100" y1="200" x2="350" y2="200" stroke="#1d4ed8" stroke-width="3" />
  <line x1="350" y1="200" x2="600" y2="70" stroke="#1d4ed8" stroke-width="3" />
  <circle cx="350" cy="200" r="5" fill="#1d4ed8" />

  <text x="470" y="130" font-size="11" font-family="sans-serif" fill="#1d4ed8">f(x) = x, x ≥ 0</text>
  <text x="200" y="190" font-size="11" font-family="sans-serif" fill="#1d4ed8">f(x) = 0, x &lt; 0</text>
  <text x="360" y="215" font-size="10" font-family="sans-serif" fill="#b91c1c">kink at x=0 (non-differentiable)</text>
</svg>

**Example**

Huber loss is defined to avoid the non-differentiability issue of pure absolute-error loss near zero:

$$L_\delta(a) = \begin{cases} \frac{1}{2}a^2 & |a| \le \delta \\ \delta\left(|a| - \frac{1}{2}\delta\right) & |a| > \delta \end{cases}$$

At $a = \delta$, both the function value and derivative match between the two pieces, giving a differentiable transition. This is a verifiable property of the algebraic construction of the formula itself.

### Checking Continuity and Differentiability at Piecewise Boundaries

**General procedure:**

1. Confirm both one-sided limits at the boundary point are equal to each other and to the function value (continuity check)
2. Confirm both one-sided derivatives at the boundary point are equal (differentiability check)

$$\lim_{x \to c^-} f(x) = \lim_{x \to c^+} f(x) = f(c) \quad \text{(continuity)}$$

$$\lim_{x \to c^-} f'(x) = \lim_{x \to c^+} f'(x) \quad \text{(differentiability)}$$

**Key Points**

- ReLU passes the continuity check at $x=0$ but fails the differentiability check
- [Inference] Subgradient methods are commonly used in optimization to handle points where a piecewise function like ReLU or hinge loss is not differentiable, since a single well-defined derivative does not exist at the kink; whether a specific framework implements subgradients or an alternative convention (such as assigning a fixed value like 0 at the kink) is implementation-specific and I cannot verify this for any particular library without checking its documentation directly

### Summary Comparison

| Property | Polynomial | Rational | Piecewise |
|---|---|---|---|
| Domain | $\mathbb{R}$ | $\mathbb{R}$ minus zeros of denominator | Depends on definition |
| Continuity | Always continuous | Continuous except at excluded points | Must be checked at boundaries |
| Differentiability | Always differentiable | Differentiable on domain | Must be checked at boundaries |
| Common ML use | Regression basis functions, loss surfaces | Normalization terms, rate schedules | Activation functions, robust loss functions |

**Related Topics**

- Limits at points of discontinuity
- One-sided limits and derivatives
- Subgradients and non-smooth optimization
- Asymptotic behavior and end behavior analysis
- Continuity formal definition ($\epsilon$-$\delta$)