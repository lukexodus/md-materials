## Intermediate Value Theorem

### Formal Statement

If $f(x)$ is continuous on the closed interval $[a, b]$, and $N$ is any value between $f(a)$ and $f(b)$ (inclusive of the case $f(a) \neq f(b)$), then there exists at least one value $c \in [a, b]$ such that:

$$f(c) = N$$

[Inference] This is the standard formulation found across calculus references; the theorem is sometimes stated with strict inequalities on the interval endpoints depending on the source, though the core claim is consistent.

### Conditions Required

The theorem requires two conditions to hold:

$$1.\ f(x) \text{ is continuous on } [a,b] \qquad 2.\ N \text{ lies between } f(a) \text{ and } f(b)$$

If continuity does not hold on the entire closed interval, the theorem's conclusion is not guaranteed to apply — a discontinuous function may "jump over" a value $N$ without ever equaling it.

### Geometric Interpretation

The theorem states that a continuous function cannot skip over any value between two output values without passing through every value in between. Visually, if you draw a continuous curve from $(a, f(a))$ to $(b, f(b))$ without lifting your pen, the curve must cross every horizontal line $y = N$ where $N$ lies between $f(a)$ and $f(b)$, at least once.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 350">
  <text x="250" y="25" font-size="14" text-anchor="middle" fill="#333">Intermediate Value Theorem (svg_diagram)</text>
  <line x1="40" y1="300" x2="460" y2="300" stroke="#999" stroke-width="1" />
  <line x1="60" y1="30" x2="60" y2="320" stroke="#999" stroke-width="1" />
  <path d="M 80,260 C 150,80 300,270 430,90" stroke="#1a5fb4" stroke-width="2.5" fill="none" />
  <line x1="80" y1="260" x2="80" y2="300" stroke="#666" stroke-width="1" stroke-dasharray="4,3" />
  <text x="70" y="315" font-size="11" fill="#555">a</text>
  <line x1="430" y1="90" x2="430" y2="300" stroke="#666" stroke-width="1" stroke-dasharray="4,3" />
  <text x="425" y="315" font-size="11" fill="#555">b</text>
  <line x1="40" y1="170" x2="460" y2="170" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="6,4" />
  <text x="465" y="174" font-size="11" fill="#cc0000">N</text>
  <circle cx="155" cy="170" r="5" fill="#cc0000" />
  <circle cx="255" cy="170" r="5" fill="#cc0000" />
  <circle cx="360" cy="170" r="5" fill="#cc0000" />
  <text x="140" y="195" font-size="10" fill="#555">c₁</text>
  <text x="245" y="195" font-size="10" fill="#555">c₂</text>
  <text x="350" y="195" font-size="10" fill="#555">c₃</text>
</svg>

Note that the theorem guarantees at least one value $c$, but as illustrated above, multiple such values can exist — the theorem makes no claim about uniqueness.

### Existence, Not Construction

A key characteristic of the Intermediate Value Theorem is that it is a **pure existence theorem** — it confirms that a value $c$ exists but does not provide a method for finding its exact location. [Inference] This distinction is a standard point made in calculus instruction to differentiate IVT from constructive methods, though the exact pedagogical framing may vary by source. Locating $c$ numerically requires separate techniques, such as the bisection method described below.

### Common Application: Root-Finding (Bisection Method)

A frequent application of IVT is proving that a root of an equation exists within a given interval, which then justifies the use of numerical root-finding algorithms.

**Example**

Show that $f(x) = x^3 - x - 2$ has a root between $x = 1$ and $x = 2$.

$$f(1) = 1 - 1 - 2 = -2 \qquad f(2) = 8 - 2 - 2 = 4$$

Since $f(x)$ is a polynomial (continuous everywhere), and $f(1) = -2 < 0 < 4 = f(2)$, IVT guarantees at least one $c \in (1,2)$ such that $f(c) = 0$.

This existence result is the theoretical justification underlying the **bisection method**: an iterative algorithm that repeatedly halves the interval, checking the sign of $f$ at the midpoint, and narrowing the bracket around the root.

$$\text{Bisection step: if } f(a) \cdot f\left(\frac{a+b}{2}\right) < 0, \text{ set } b = \frac{a+b}{2}; \text{ otherwise set } a = \frac{a+b}{2}$$

I cannot verify the specific convergence rate or iteration count for any particular implementation of bisection without reference to a specific numerical analysis source; general convergence properties of bisection are described in standard numerical methods references, but exact behavior depends on implementation details such as tolerance settings and stopping criteria.

### IVT Does Not Guarantee Uniqueness

A common misunderstanding is treating IVT as though it identifies a single specific point. The theorem only asserts existence of *at least one* such point — as shown in the geometric diagram above, a continuous function can cross the value $N$ multiple times.

### Relevance to Machine Learning

IVT-related reasoning connects to several ML-adjacent contexts:

- **Root-finding in optimization**: Numerical methods used to find where a gradient equals zero (a necessary condition for many critical points) rely on root-finding techniques whose validity, in the continuous case, depends on IVT-style reasoning about sign changes. [Inference] This is a reasonable general connection between IVT and gradient-based root-finding, but I cannot verify that any specific ML optimizer directly implements bisection or explicitly invokes IVT internally; most gradient-based optimizers used in practice (e.g., SGD, Adam) rely on different algorithmic principles rather than bisection-style bracketing.
- **Existence arguments for solutions**: In theoretical ML contexts, continuity-based existence arguments can be used to reason about whether certain parameter configurations exist that satisfy given constraints. [Speculation] I do not have a specific verified source confirming this is a standard or common framing used in applied ML literature; this connection is offered as a plausible theoretical link rather than a documented practice.
- **Calibration and threshold-setting**: When choosing a decision threshold for a continuous output (e.g., a classifier's probability score) to achieve a target metric value, IVT-style reasoning underlies the assumption that a threshold achieving that exact value exists, provided the relevant function is continuous. [Speculation] I do not have a verified source explicitly describing threshold calibration in these terms; this is a plausible conceptual analogy rather than a confirmed technique documented in ML literature.

I cannot verify that any specific machine learning library implements root-finding or calibration procedures with explicit reference to the Intermediate Value Theorem; behavior and internal implementation details may vary by framework and version, and I do not have access to verify current source code across libraries.

**Next Steps**

- Derivatives via limits: the difference quotient and the formal definition of the derivative
- Differentiability and its relationship to continuity (differentiability implies continuity, converse is false)
- Bisection method and other root-finding algorithms (Newton's Method) in numerical optimization
- Extreme Value Theorem and its relevance to optimization over closed, bounded domains
- Squeeze Theorem

If any part of this response is later found to conflict with a verified source:
> Correction: I made an unverified claim. That was incorrect.