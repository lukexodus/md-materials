## First-Order and Second-Order Convexity Conditions

### Overview

Convexity conditions provide checkable, calculus-based tests for whether a function is convex, without needing to verify the definition directly via the epigraph or the line-segment inequality for every pair of points. First-order conditions use gradient information; second-order conditions use the Hessian.

### First-Order Convexity Condition

**Statement**

Let $f: \mathbb{R}^n \to \mathbb{R}$ be differentiable on a convex set $\mathcal{D}$. Then $f$ is convex on $\mathcal{D}$ if and only if:

$$f(y) \geq f(x) + \nabla f(x)^T (y - x) \quad \forall x, y \in \mathcal{D}$$

**Interpretation**

The first-order Taylor approximation of $f$ at any point $x$ is a **global underestimator** of $f$. Geometrically, the tangent plane (or tangent line, in 1D) at any point on the graph of a convex function lies entirely at or below the graph.

This is a powerful characterization: it converts a global condition (convexity, which is about all pairs of points) into a statement that can be checked using only local derivative information, but it holds globally because of the inequality direction.

**Strict convexity variant**

$f$ is strictly convex on $\mathcal{D}$ if and only if:

$$f(y) > f(x) + \nabla f(x)^T (y - x) \quad \forall x, y \in \mathcal{D}, \, x \neq y$$

**Concavity variant**

Reversing the inequality gives the first-order condition for concavity:

$$f(y) \leq f(x) + \nabla f(x)^T (y - x)$$

**Proof sketch (forward direction)**

Assume $f$ is convex. For $t \in (0, 1]$:

$$f(x + t(y-x)) \leq (1-t)f(x) + t f(y)$$

Rearranging:

$$f(y) \geq f(x) + \frac{f(x + t(y-x)) - f(x)}{t}$$

Taking $t \to 0^+$, the right-hand fraction converges to the directional derivative $\nabla f(x)^T (y-x)$, giving the result.

**Proof sketch (reverse direction)**

Assume the first-order inequality holds for all $x, y$. Let $z = \lambda x + (1-\lambda) y$ for $\lambda \in [0,1]$. Applying the inequality at $z$ with target points $x$ and $y$ separately, then combining with weights $\lambda$ and $(1-\lambda)$, recovers the definition of convexity. [Inference: full algebraic recovery is a routine but multi-step derivation; the key mechanism — combining two supporting-hyperplane inequalities at $z$ — is what does the work.]

### One-Dimensional Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
<text x="250" y="20" text-anchor="middle" font-size="14" font-weight="bold" fill="#222">Tangent Line as Global Underestimator (svg_diagram)</text>
<line x1="40" y1="280" x2="470" y2="280" stroke="#444" stroke-width="1.5" />
<line x1="60" y1="300" x2="60" y2="40" stroke="#444" stroke-width="1.5" />
<path d="M 70 260 Q 200 40 430 250" stroke="#1f6feb" stroke-width="2.5" fill="none" />
<line x1="90" y1="330" x2="380" y2="90" stroke="#e05252" stroke-width="2" stroke-dasharray="0" />
<circle cx="230" cy="150" r="4" fill="#111" />
<text x="238" y="145" font-size="12" fill="#111">x, f(x)</text>
<text x="360" y="200" font-size="12" fill="#1f6feb">f(y)</text>
<text x="120" y="300" font-size="11" fill="#e05252">tangent line: f(x) + ∇f(x)ᵀ(y−x)</text>
<text x="380" y="270" font-size="11" fill="#444">y</text>
</svg>

The blue curve is a convex function; the red line is its tangent at $x$. The tangent lies below the curve everywhere, illustrating the first-order condition.

### Second-Order Convexity Condition

**Statement**

Let $f: \mathbb{R}^n \to \mathbb{R}$ be twice differentiable on an open convex set $\mathcal{D}$. Then:

$$f \text{ is convex on } \mathcal{D} \iff \nabla^2 f(x) \succeq 0 \quad \forall x \in \mathcal{D}$$

where $\nabla^2 f(x)$ is the Hessian matrix and $\succeq 0$ denotes positive semidefiniteness (all eigenvalues $\geq 0$, equivalently $v^T \nabla^2 f(x) v \geq 0$ for all $v \in \mathbb{R}^n$).

**Strict convexity — sufficient but not necessary**

$$\nabla^2 f(x) \succ 0 \, \forall x \in \mathcal{D} \implies f \text{ is strictly convex on } \mathcal{D}$$

The converse does **not** hold in general. A standard counterexample is $f(x) = x^4$, which is strictly convex on $\mathbb{R}$ but has $f''(0) = 0$, so the Hessian is not positive definite everywhere.

**One-dimensional case**

For $f: \mathbb{R} \to \mathbb{R}$, the condition reduces to:

$$f''(x) \geq 0 \quad \forall x \in \mathcal{D}$$

**Concavity variant**

$$f \text{ is concave} \iff \nabla^2 f(x) \preceq 0 \quad \forall x \in \mathcal{D} \text{ (negative semidefinite)}$$

### Checking Positive Semidefiniteness in Practice

**Key Points**

- Eigenvalue test: compute eigenvalues of $\nabla^2 f(x)$; convex if all $\geq 0$ at every $x \in \mathcal{D}$.
- Leading principal minors test (Sylvester's criterion) applies to positive **definiteness**, not semidefiniteness directly; for semidefiniteness, all principal minors (not just leading ones) must be $\geq 0$. [Unverified: some texts state the leading-minors-only version as sufficient for semidefiniteness under additional continuity assumptions — this varies by source and is easy to misstate, so the all-principal-minors form is the safe default to use.]
- For diagonal or block-diagonal Hessians, semidefiniteness reduces to checking each diagonal entry/block.
- Quadratic forms $f(x) = x^T A x + b^T x + c$ are convex iff $A \succeq 0$, directly by this theorem since $\nabla^2 f(x) = 2A$ is constant.

### Worked Example 1: Quadratic Function

**Example**

Let $f(x_1, x_2) = 2x_1^2 + x_2^2 - 2x_1 x_2$.

Gradient:

$$\nabla f(x) = \begin{bmatrix} 4x_1 - 2x_2 \\ 2x_2 - 2x_1 \end{bmatrix}$$

Hessian:

$$\nabla^2 f(x) = \begin{bmatrix} 4 & -2 \\ -2 & 2 \end{bmatrix}$$

Check positive semidefiniteness via leading principal minors (valid here since we are testing definiteness, not just semidefiniteness, and the result is confirmed independently via eigenvalues below):

- $M_1 = 4 > 0$
- $M_2 = \det \begin{bmatrix} 4 & -2 \\ -2 & 2 \end{bmatrix} = 8 - 4 = 4 > 0$

Both leading principal minors are strictly positive, so $\nabla^2 f(x) \succ 0$ (constant, positive definite everywhere).

**Output**

$f$ is strictly convex on $\mathbb{R}^2$.

Cross-check via eigenvalues: solving $\det(A - \lambda I) = 0$ gives $\lambda^2 - 6\lambda + 4 = 0$, so $\lambda = 3 \pm \sqrt{5}$, both positive. This confirms positive definiteness.

### Worked Example 2: Log-Sum-Exp

**Example**

$f(x) = \log\left(\sum_{i=1}^n e^{x_i}\right)$, the log-sum-exp function, frequently encountered in softmax and multinomial logistic regression contexts.

Let $z_i = e^{x_i}$ and $S = \sum_i z_i$. The Hessian works out to:

$$\nabla^2 f(x) = \frac{1}{S} \text{diag}(z) - \frac{1}{S^2} z z^T$$

where $z = (z_1, \dots, z_n)^T$.

For any $v \in \mathbb{R}^n$:

$$v^T \nabla^2 f(x) v = \frac{1}{S}\sum_i z_i v_i^2 - \frac{1}{S^2}\left(\sum_i z_i v_i\right)^2$$

By the Cauchy–Schwarz inequality applied to vectors $\sqrt{z_i}$ and $\sqrt{z_i} v_i$:

$$\left(\sum_i z_i v_i\right)^2 \leq \left(\sum_i z_i\right)\left(\sum_i z_i v_i^2\right) = S \sum_i z_i v_i^2$$

Substituting back shows $v^T \nabla^2 f(x) v \geq 0$ for all $v$, so $\nabla^2 f(x) \succeq 0$.

**Output**

Log-sum-exp is convex on $\mathbb{R}^n$ (not strictly convex — equality in Cauchy–Schwarz occurs when $v$ is constant across coordinates with nonzero $z_i$, giving a zero eigenvalue direction).

### Relationship Between First- and Second-Order Conditions

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 560 260">
<text x="280" y="20" text-anchor="middle" font-size="14" font-weight="bold" fill="#222">Condition Hierarchy (svg_diagram)</text>
<rect x="40" y="50" width="220" height="60" rx="6" fill="#eef4ff" stroke="#1f6feb" stroke-width="1.5" />
<text x="150" y="75" text-anchor="middle" font-size="12" fill="#111">Zeroth-order</text>
<text x="150" y="92" text-anchor="middle" font-size="11" fill="#333">Jensen's inequality</text>
<rect x="40" y="140" width="220" height="60" rx="6" fill="#eef4ff" stroke="#1f6feb" stroke-width="1.5" />
<text x="150" y="165" text-anchor="middle" font-size="12" fill="#111">First-order</text>
<text x="150" y="182" text-anchor="middle" font-size="11" fill="#333">tangent underestimates f</text>
<rect x="300" y="140" width="220" height="60" rx="6" fill="#eef4ff" stroke="#1f6feb" stroke-width="1.5" />
<text x="410" y="165" text-anchor="middle" font-size="12" fill="#111">Second-order</text>
<text x="410" y="182" text-anchor="middle" font-size="11" fill="#333">Hessian PSD</text>
<line x1="150" y1="110" x2="150" y2="140" stroke="#444" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="260" y1="170" x2="300" y2="170" stroke="#444" stroke-width="1.5" marker-end="url(#arrow)" />
<text x="150" y="230" text-anchor="middle" font-size="11" fill="#555">equivalent (differentiable f)</text>
<text x="410" y="230" text-anchor="middle" font-size="11" fill="#555">equivalent (twice-diff. f)</text>
</svg>

All three characterizations — Jensen's inequality (zeroth-order/definitional), the first-order tangent condition, and the second-order Hessian condition — are logically equivalent **when the relevant differentiability assumptions hold**. Weaker smoothness (e.g., $f$ convex but not differentiable) requires falling back to the zeroth-order definition or subgradient-based generalizations, which fall outside these two conditions.

### Common Pitfalls

**Key Points**

- Confusing "Hessian PSD at a point" with "Hessian PSD everywhere on the domain" — convexity requires the latter, not a single point.
- Forgetting that the domain $\mathcal{D}$ must itself be convex for these theorems to apply as stated; the conditions describe convexity *on a convex set*, not general behavior on disconnected or non-convex domains.
- Assuming $\nabla^2 f \succ 0$ is necessary for strict convexity (it is only sufficient — see $x^4$ counterexample above).
- Applying the first-order condition with the inequality direction reversed by mistake (easy to do when switching between convex/concave contexts).

### Related Topics

- Jensen's inequality and the zeroth-order (epigraph/line-segment) definition of convexity
- Strong convexity and its quantitative strengthening of the second-order condition ($\nabla^2 f \succeq mI$)
- Subgradients and subdifferentials for nonsmooth convex functions
- Convexity-preserving operations (nonnegative sums, composition rules, pointwise supremum)
- Quasi-convexity as a weaker structural property
- Convex conjugate functions and duality