## Functions, Domain, and Range

### Definition of a Function

A function $f$ is a rule that assigns exactly one output to each input from a specified set. Formally, $f: A \to B$ maps every element of set $A$ to exactly one element of set $B$.

$$f: X \to Y, \quad y = f(x)$$

- $X$ is the **domain** (set of valid inputs)
- $Y$ is the **codomain** (set the outputs are drawn from)
- The **range** (or image) is the actual subset of $Y$ produced by applying $f$ to every element of $X$

**Key Points**

- Every input maps to exactly one output; this is what distinguishes a function from a general relation
- Two different inputs may map to the same output (not required to be one-to-one)
- The range is always a subset of the codomain, and may be a proper subset

### Domain

The domain is the complete set of input values for which a function is defined.

#### Common Domain Restrictions

| Function Type | Restriction | Example |
|---|---|---|
| Rational (division) | Denominator $\neq 0$ | $f(x) = \frac{1}{x}$, domain: $x \neq 0$ |
| Square root (even roots) | Radicand $\ge 0$ | $f(x) = \sqrt{x}$, domain: $x \ge 0$ |
| Logarithm | Argument $> 0$ | $f(x) = \ln(x)$, domain: $x > 0$ |
| Polynomial | None | $f(x) = x^3 + 2x$, domain: $\mathbb{R}$ |

**Example**

For $f(x) = \frac{1}{x - 3}$, the domain excludes $x = 3$:

$$\text{Domain} = (-\infty, 3) \cup (3, \infty)$$

### Range

The range is the set of all actual output values a function produces over its domain.

**Example**

For $f(x) = x^2$ with domain $\mathbb{R}$:

$$\text{Range} = [0, \infty)$$

This is because squaring any real number produces a non-negative result, and every non-negative real number is achievable.

### Visualizing Domain and Range

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Function Mapping: Domain to Range (svg_diagram)</text>

  <ellipse cx="160" cy="180" rx="120" ry="120" fill="#dbeafe" stroke="#1e3a8a" stroke-width="1.5" />
  <text x="160" y="70" font-size="13" text-anchor="middle" font-family="sans-serif">Domain X</text>

  <ellipse cx="540" cy="180" rx="120" ry="120" fill="#dcfce7" stroke="#14532d" stroke-width="1.5" />
  <text x="540" y="70" font-size="13" text-anchor="middle" font-family="sans-serif">Codomain Y</text>

  <circle cx="130" cy="140" r="5" fill="#1e3a8a" />
  <text x="105" y="135" font-size="11" font-family="sans-serif">-2</text>
  <circle cx="130" cy="180" r="5" fill="#1e3a8a" />
  <text x="105" y="185" font-size="11" font-family="sans-serif">0</text>
  <circle cx="130" cy="220" r="5" fill="#1e3a8a" />
  <text x="105" y="230" font-size="11" font-family="sans-serif">2</text>

  <circle cx="570" cy="140" r="5" fill="#14532d" />
  <text x="600" y="135" font-size="11" font-family="sans-serif">4</text>
  <circle cx="570" cy="220" r="5" fill="#14532d" />
  <text x="600" y="230" font-size="11" font-family="sans-serif">0</text>
  <circle cx="600" cy="260" r="5" fill="#9ca3af" />
  <text x="630" y="265" font-size="11" font-family="sans-serif" fill="#6b7280">(unused)</text>

  <line x1="135" y1="140" x2="565" y2="140" stroke="#334155" stroke-width="1.5" />
  <line x1="135" y1="220" x2="565" y2="220" stroke="#334155" stroke-width="1.5" />
  <line x1="135" y1="180" x2="565" y2="220" stroke="#334155" stroke-width="1.5" />

  <text x="350" y="300" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#475569">Range = {4, 0} ⊂ Codomain Y</text>
</svg>

### Determining Domain and Range Algebraically

**Steps for finding domain:**

1. Identify operations that impose restrictions (division, even roots, logarithms)
2. Set denominators $\neq 0$ and solve
3. Set radicands (under even roots) $\ge 0$ and solve
4. Set logarithm arguments $> 0$ and solve
5. Combine all restrictions (intersection of conditions)

**Steps for finding range:**

1. Analyze the behavior of the function (increasing, decreasing, bounded)
2. Identify minimum/maximum values, if any
3. Consider asymptotic behavior as $x \to \pm\infty$ or near domain boundaries

**Example**

$f(x) = \sqrt{4 - x^2}$

Domain: requires $4 - x^2 \ge 0 \Rightarrow x^2 \le 4 \Rightarrow x \in [-2, 2]$

Range: this is the upper half of a circle of radius 2, so output ranges from $0$ (at $x = \pm 2$) to $2$ (at $x = 0$):

$$\text{Range} = [0, 2]$$

### Functions Relevant to Machine Learning

| Function | Formula | Domain | Range |
|---|---|---|---|
| Linear | $f(x) = wx + b$ | $\mathbb{R}$ | $\mathbb{R}$ (if $w \neq 0$) |
| Sigmoid | $f(x) = \frac{1}{1 + e^{-x}}$ | $\mathbb{R}$ | $(0, 1)$ |
| ReLU | $f(x) = \max(0, x)$ | $\mathbb{R}$ | $[0, \infty)$ |
| Softmax (component) | $f(x_i) = \frac{e^{x_i}}{\sum_j e^{x_j}}$ | $\mathbb{R}^n$ | $(0, 1)$ per component |
| Log-loss / cross-entropy | $-\log(p)$ | $p \in (0, 1]$ | $[0, \infty)$ |
| Softplus | $\ln(1 + e^x)$ | $\mathbb{R}$ | $(0, \infty)$ |

**Key Points**

- The domain of a loss function is often constrained by the range of the activation function feeding into it (e.g., log-loss requires $p \in (0, 1]$, which matches sigmoid/softmax output)
- [Inference] Mismatches between a function's theoretical domain and the actual values encountered in practice (such as $p = 0$ being passed to $-\log(p)$) can cause numerical errors like `NaN` or `-inf` in computation; this behavior depends on the specific numerical library and floating-point handling used, and is not guaranteed to occur or not occur in all implementations. [Unverified] whether a specific framework applies internal clipping to avoid this.

### Composite Functions and Domain Restrictions

When composing functions $f(g(x))$, the domain of the composite depends on both the domain of $g$ and the domain of $f$ applied to the range of $g$.

$$\text{Domain}(f \circ g) = \{x \in \text{Domain}(g) : g(x) \in \text{Domain}(f)\}$$

**Example**

If $g(x) = x^2 - 9$ and $f(x) = \sqrt{x}$, then $f(g(x)) = \sqrt{x^2 - 9}$ requires:

$$x^2 - 9 \ge 0 \Rightarrow x \le -3 \text{ or } x \ge 3$$

$$\text{Domain} = (-\infty, -3] \cup [3, \infty)$$

**Relevance to Machine Learning**

Neural networks are compositions of functions (layers). The domain of each layer's activation function constrains what values can validly propagate forward. [Inference] Errors in one layer's output (e.g., producing negative values passed into a function expecting non-negative input) can propagate through subsequent layers, though the specific effect depends on architecture and is not something that can be stated as a general guarantee across all models.

### One-to-One and Onto Functions

- **One-to-one (injective)**: distinct inputs map to distinct outputs; $f(a) = f(b) \Rightarrow a = b$
- **Onto (surjective)**: every element of the codomain is achieved by some input; range = codomain
- **Bijective**: both injective and surjective; the function has a well-defined inverse

**Relevance to Machine Learning**

Invertibility matters in areas such as normalizing flows, where transformations must be bijective so that the change-of-variables formula for probability density can be applied. [Unverified] whether a specific model architecture strictly enforces bijectivity in implementation versus approximating it.

### Vertical Line Test (Graphical Check)

A curve represents a function if and only if no vertical line intersects it more than once. This is a graphical heuristic, not a formal proof method.

**Related Topics**

- Limits and continuity of functions
- Inverse functions
- Piecewise-defined functions
- Function composition
- Multivariable functions and domains in $\mathbb{R}^n$
The previous response on **Functions, Domain, and Range** was already complete — it ended with the **Related Topics** section. There is no missing continuation.

For clarity, here is confirmation of the last section that was delivered, followed by the completion marker as requested.

**Related Topics**

- Limits and continuity of functions
- Inverse functions
- Piecewise-defined functions
- Function composition
- Multivariable functions and domains in $\mathbb{R}^n$