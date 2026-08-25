## One-Sided Limits

### Definition

A one-sided limit describes the value a function approaches as $x$ approaches a point $c$ from only one direction — either from the left or from the right.

**Left-hand limit:**

$$\lim_{x \to c^-} f(x) = L$$

This means $f(x)$ approaches $L$ as $x$ approaches $c$ through values less than $c$.

**Right-hand limit:**

$$\lim_{x \to c^+} f(x) = M$$

This means $f(x)$ approaches $M$ as $x$ approaches $c$ through values greater than $c$.

This is a standard, verifiable mathematical definition found in any calculus reference.

### Relationship to the Two-Sided Limit

The two-sided limit exists at $c$ if and only if both one-sided limits exist and are equal:

$$\lim_{x \to c} f(x) = L \iff \lim_{x \to c^-} f(x) = \lim_{x \to c^+} f(x) = L$$

If the left-hand and right-hand limits differ, the two-sided limit does not exist at $c$, even if both one-sided limits individually exist. This is a verifiable mathematical property directly derivable from the definition of a limit.

### Example: A Function with Unequal One-Sided Limits

Consider the piecewise function:

$$f(x) = \begin{cases} x + 1 & x < 2 \\ x^2 & x \ge 2 \end{cases}$$

Left-hand limit at $x = 2$:

$$\lim_{x \to 2^-} f(x) = \lim_{x \to 2^-} (x+1) = 3$$

Right-hand limit at $x = 2$:

$$\lim_{x \to 2^+} f(x) = \lim_{x \to 2^+} x^2 = 4$$

Since $3 \neq 4$, the two-sided limit $\lim_{x \to 2} f(x)$ does not exist. This is a directly verifiable computation from the given piecewise definition.

### Visualizing a Jump Discontinuity

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 280">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">One-Sided Limits at a Jump Discontinuity (svg_diagram)</text>

  <line x1="60" y1="230" x2="650" y2="230" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="40" x2="350" y2="250" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="235" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="45" font-size="11" font-family="sans-serif">y</text>

  <line x1="150" y1="200" x2="350" y2="150" stroke="#1d4ed8" stroke-width="2.5" />
  <circle cx="350" cy="150" r="6" fill="white" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="200" y="190" font-size="10" font-family="sans-serif" fill="#1d4ed8">left branch: x+1</text>

  <line x1="350" y1="110" x2="550" y2="60" stroke="#15803d" stroke-width="2.5" />
  <circle cx="350" cy="110" r="6" fill="#15803d" stroke="#15803d" stroke-width="2.5" />
  <text x="400" y="90" font-size="10" font-family="sans-serif" fill="#15803d">right branch: x²</text>

  <text x="355" y="245" font-size="10" font-family="sans-serif" fill="#6b7280">x = 2</text>
  <text x="365" y="155" font-size="10" font-family="sans-serif" fill="#1d4ed8">L = 3</text>
  <text x="365" y="115" font-size="10" font-family="sans-serif" fill="#15803d">M = 4</text>
</svg>

This diagram is a conceptual, schematic illustration of the jump discontinuity described in the example and is not a precisely scaled plot.

### Notation Summary

| Notation | Meaning |
|---|---|
| $x \to c^-$ | $x$ approaches $c$ from values less than $c$ |
| $x \to c^+$ | $x$ approaches $c$ from values greater than $c$ |
| $\lim_{x \to c^-} f(x)$ | Left-hand limit |
| $\lim_{x \to c^+} f(x)$ | Right-hand limit |

### Common Contexts Where One-Sided Limits Are Necessary

#### Piecewise Functions

Any function with a different rule on either side of a boundary point requires checking one-sided limits separately at that boundary, as shown in the example above.

#### Functions with Restricted Domains

For functions defined only on one side of a point, only one one-sided limit is meaningful.

**Example**

$f(x) = \sqrt{x}$ has domain $[0, \infty)$. At $x = 0$, only the right-hand limit is defined:

$$\lim_{x \to 0^+} \sqrt{x} = 0$$

The left-hand limit $\lim_{x \to 0^-} \sqrt{x}$ does not exist, since $\sqrt{x}$ is undefined for $x < 0$. This is a directly verifiable consequence of the domain restriction.

#### Vertical Asymptotes

One-sided limits can differ in sign when a function has a vertical asymptote.

**Example**

For $f(x) = \dfrac{1}{x}$ at $x = 0$:

$$\lim_{x \to 0^-} \frac{1}{x} = -\infty, \qquad \lim_{x \to 0^+} \frac{1}{x} = +\infty$$

Both one-sided limits are infinite (and unequal in sign), so the two-sided limit does not exist. This is a directly verifiable computation.

### Relevance to Machine Learning

#### ReLU Activation Function

$$\text{ReLU}(x) = \begin{cases} x & x \ge 0 \\ 0 & x < 0 \end{cases}$$

At $x = 0$:

$$\lim_{x \to 0^-} \text{ReLU}(x) = 0, \qquad \lim_{x \to 0^+} \text{ReLU}(x) = 0$$

Both one-sided limits equal 0, so the two-sided limit exists and equals $\text{ReLU}(0) = 0$; the function is continuous at $x = 0$. This is a directly verifiable computation from the piecewise definition.

**Key Points**

- [Inference] Although ReLU is continuous at $x = 0$, checking the one-sided *derivatives* (not limits of the function itself) at that point reveals a mismatch, which is why ReLU is not differentiable at $x = 0$. This distinction between continuity and differentiability is a standard concept in calculus curricula. I cannot verify that this exact explanatory framing is presented identically across all sources discussing ReLU, though the underlying mathematical facts (continuity holding, differentiability failing) are directly verifiable through the respective limit computations.

#### Piecewise Loss Functions

Functions like Huber loss are defined piecewise, so verifying their continuity (and differentiability) at the transition point requires checking one-sided limits of both the function and its derivative, matching the general procedure described above for piecewise functions.

**Key Points**

- [Unverified] Whether a specific software implementation of a piecewise loss function explicitly performs one-sided limit checks internally, versus simply relying on the closed-form derivative being mathematically continuous by construction, depends on the implementation and cannot be confirmed without checking that specific library's source code directly.

#### Domain Boundaries in Custom Functions

[Inference] When defining custom activation or loss functions with restricted domains (such as functions involving square roots or logarithms), one-sided limits at domain boundaries can be relevant to verifying whether the function behaves as intended near the edge of its valid input range. I cannot verify without a specific citation that this exact practice is universally followed in machine learning model design, though the underlying mathematical reasoning about domain boundaries and one-sided limits is a standard calculus concept.

### Summary Table

| Concept | Condition |
|---|---|
| Two-sided limit exists | Left-hand limit = right-hand limit |
| Jump discontinuity | Left-hand limit ≠ right-hand limit (both finite) |
| Vertical asymptote (one-sided) | One or both one-sided limits are infinite |
| Domain-restricted point | Only one one-sided limit is defined |

**Related Topics**

- Formal $\epsilon$-$\delta$ definition of one-sided limits
- Continuity at a point (formal definition)
- Differentiability and one-sided derivatives
- Piecewise function analysis
- Limits at infinity vs. one-sided limits at finite points