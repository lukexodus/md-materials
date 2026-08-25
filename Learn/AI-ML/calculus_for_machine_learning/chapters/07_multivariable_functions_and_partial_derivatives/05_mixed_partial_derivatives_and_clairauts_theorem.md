## Mixed Partial Derivatives and Clairaut's Theorem

### Definition of Mixed Partial Derivatives

For a multivariable function $f(x, y)$, a mixed partial derivative is obtained by differentiating with respect to one variable, then differentiating the result with respect to a different variable.

The two second-order mixed partials are:

$$f_{xy} = \frac{\partial}{\partial y}\left(\frac{\partial f}{\partial x}\right) = \frac{\partial^2 f}{\partial y \, \partial x}$$

$$f_{yx} = \frac{\partial}{\partial x}\left(\frac{\partial f}{\partial y}\right) = \frac{\partial^2 f}{\partial x \, \partial y}$$

**Key Points**
- $f_{xy}$ means: differentiate with respect to $x$ first, then $y$.
- $f_{yx}$ means: differentiate with respect to $y$ first, then $x$.
- Notation conventions differ across textbooks — some read subscript order left-to-right as "order of differentiation," others reverse it. Always confirm the convention used by the source. [Unverified] — notation conventions vary by textbook and are not universally standardized.

### Computing Mixed Partials — Worked Example

Let $f(x, y) = x^3y^2 + \sin(xy)$.

**Step 1: First partial derivatives**

$$f_x = 3x^2y^2 + y\cos(xy)$$

$$f_y = 2x^3y + x\cos(xy)$$

**Step 2: Mixed partial $f_{xy}$ (differentiate $f_x$ with respect to $y$)**

$$f_{xy} = 6x^2y + \cos(xy) - xy\sin(xy)$$

**Step 3: Mixed partial $f_{yx}$ (differentiate $f_y$ with respect to $x$)**

$$f_{yx} = 6x^2y + \cos(xy) - xy\sin(xy)$$

**Example**
Both mixed partials produce the identical expression:
$$f_{xy} = f_{yx} = 6x^2y + \cos(xy) - xy\sin(xy)$$

This equality is not a coincidence for this specific function — it reflects a general result under certain conditions, described next.

### Clairaut's Theorem (Equality of Mixed Partials)

**Statement:** If $f(x, y)$ has mixed partial derivatives $f_{xy}$ and $f_{yx}$ that are both continuous on an open region containing a point $(a, b)$, then:

$$f_{xy}(a, b) = f_{yx}(a, b)$$

This result is a standard theorem in multivariable calculus, commonly attributed to Alexis Clairaut. [Unverified] — the historical attribution and exact original statement are not confirmed here; textbooks may present slightly different hypotheses (e.g., Schwarz's theorem is a closely related/alternative formulation).

**Key Points**
- The theorem requires continuity of the mixed partials in a neighborhood of the point — not merely that they exist at the point.
- When the hypothesis holds, the order of differentiation does not affect the result.
- Functions encountered in typical machine learning contexts (polynomials, exponentials, sigmoids, softmax, common loss functions) are generally smooth ($C^\infty$) on their relevant domains, so Clairaut's theorem's conditions are typically satisfied. [Inference] — this is a reasonable expectation based on the smoothness of common functions, but it is not a guarantee for every function encountered in practice; pathological or piecewise-defined functions may fail the continuity requirement.

### Counterexample — When Clairaut's Theorem Fails

A classical example where $f_{xy}(0,0) \neq f_{yx}(0,0)$ is:

$$f(x, y) = \begin{cases} \dfrac{xy(x^2 - y^2)}{x^2 + y^2} & (x,y) \neq (0,0) \\ 0 & (x,y) = (0,0) \end{cases}$$

For this function, direct computation gives:

$$f_{xy}(0,0) = -1, \qquad f_{yx}(0,0) = 1$$

**Key Points**
- This occurs because the mixed partial derivatives are not continuous at $(0,0)$, so the hypothesis of Clairaut's theorem is not satisfied there.
- This example is widely cited in calculus textbooks as the standard counterexample. [Unverified] — the specific numeric values above should be independently verified against a primary textbook source before being cited as authoritative, since transcription errors are possible.

### Geometric and Practical Interpretation

Mixed partial derivatives describe how the rate of change in one direction itself changes as you move in another direction.

- $f_{xy}$: how the slope in the $x$-direction changes as $y$ varies.
- $f_{yx}$: how the slope in the $y$-direction changes as $x$ varies.

When Clairaut's theorem applies, these two descriptions agree — the surface's curvature "twist" is direction-independent at that point.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380" font-family="sans-serif">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Mixed Partial Derivative Paths (svg_diagram)</text>

  <line x1="80" y1="320" x2="560" y2="320" stroke="#333" stroke-width="2" />
  <line x1="80" y1="320" x2="80" y2="60" stroke="#333" stroke-width="2" />
  <text x="570" y="325" font-size="14" fill="#333">x</text>
  <text x="70" y="55" font-size="14" fill="#333">y</text>

  <circle cx="150" cy="280" r="5" fill="#1a1a1a" />
  <text x="130" y="300" font-size="12" fill="#1a1a1a">f(x,y)</text>

  <path d="M150,280 C 250,260 300,200 380,150" stroke="#2563eb" stroke-width="2.5" fill="none" marker-end="url(#arrow1)" />
  <text x="260" y="230" font-size="13" fill="#2563eb">Step 1: ∂/∂x</text>

  <path d="M380,150 C 420,130 460,110 500,90" stroke="#dc2626" stroke-width="2.5" fill="none" marker-end="url(#arrow2)" />
  <text x="400" y="110" font-size="13" fill="#dc2626">Step 2: ∂/∂y → f_xy</text>

  <path d="M150,280 C 180,220 220,170 260,130" stroke="#16a34a" stroke-width="2.5" stroke-dasharray="6,4" fill="none" marker-end="url(#arrow3)" />
  <text x="150" y="190" font-size="13" fill="#16a34a">Step 1: ∂/∂y</text>

  <path d="M260,130 C 340,110 420,100 500,90" stroke="#ea580c" stroke-width="2.5" stroke-dasharray="6,4" fill="none" marker-end="url(#arrow4)" />
  <text x="300" y="90" font-size="13" fill="#ea580c">Step 2: ∂/∂x → f_yx</text>

  <circle cx="500" cy="90" r="6" fill="#1a1a1a" />
  <text x="440" y="70" font-size="13" font-weight="bold" fill="#1a1a1a">Same endpoint if continuous</text>

  </svg>

### Relevance to Machine Learning

Mixed partial derivatives appear in machine learning primarily through the **Hessian matrix**, which organizes all second-order partial derivatives (including mixed ones) of a multivariable loss function.

$$H = \begin{bmatrix} f_{xx} & f_{xy} \\ f_{yx} & f_{yy} \end{bmatrix}$$

**Key Points**
- When Clairaut's theorem's conditions hold, $f_{xy} = f_{yx}$, which makes the Hessian matrix symmetric.
- A symmetric Hessian allows use of certain numerical methods and eigenvalue-based analyses (e.g., for identifying saddle points, local minima) that rely on matrix symmetry. [Inference] — this reflects standard linear algebra properties of symmetric matrices, applied to the specific context of Hessians in optimization; specific claims about which algorithms rely on this should be verified against the source describing that algorithm.
- Automatic differentiation frameworks (e.g., PyTorch, TensorFlow) compute second-order derivatives, and their internal correctness with respect to Clairaut's theorem depends on implementation details. [Unverified] — no specific claim is made here about the internal behavior of any named framework without direct documentation access; behavior may vary by version and should be confirmed against current official documentation.

### Higher-Order Mixed Partials

For functions of three or more variables, mixed partials extend naturally:

$$f_{xyz} = \frac{\partial^3 f}{\partial z \, \partial y \, \partial x}$$

**Key Points**
- A generalized version of Clairaut's theorem extends to higher-order mixed partials, provided all relevant partials up to that order are continuous. [Inference] — this follows by repeated application of the two-variable case, assuming each intermediate mixed partial satisfies the continuity condition at each step; this is not chained without labeling: each application requires its own continuity check and is not automatically guaranteed by the two-variable result alone.
- In practice, for smooth functions (like those built from standard activation functions and loss functions), all orderings of partial differentiation typically agree. [Inference] — based on general smoothness properties of common function classes, not a confirmed statement about every possible function.

### Common Pitfalls

- Assuming $f_{xy} = f_{yx}$ always holds without checking continuity — this does not hold universally; it depends on the continuity hypothesis of Clairaut's theorem.
- Confusing the order-of-operations notation between $f_{xy}$ (subscript order) and $\frac{\partial^2 f}{\partial y \partial x}$ (which reads right-to-left in some conventions) — always verify against the specific textbook's stated convention. [Unverified] — convention differences are not confirmed to be standardized across all sources.
- Applying the theorem to piecewise or non-smooth functions without verifying continuity of the mixed partials at the point of interest.

### Conclusion

Mixed partial derivatives measure how a function's rate of change in one variable is itself affected by changes in another variable. Clairaut's theorem states that when both mixed partials are continuous near a point, the order of differentiation does not affect the result — a property that underlies the symmetry of the Hessian matrix used throughout optimization in machine learning. This equality is conditional, not universal, and does not hold for functions where the continuity requirement fails, as demonstrated by the standard counterexample above.

**Related Topics**
- The Hessian matrix and second-order optimization conditions
- Symmetric matrices and their eigenvalue properties in optimization
- Taylor series expansion for multivariable functions
- Convexity and concavity via second-derivative tests
- Automatic differentiation and computational graphs for second-order derivatives
- Saddle point identification using the second-derivative test (determinant of the Hessian)