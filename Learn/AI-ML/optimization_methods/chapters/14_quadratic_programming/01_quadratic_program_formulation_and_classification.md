This topic moves past Linear Programming Algorithms into a new subtopic (Quadratic Programming), so I'll update the file to reflect that transition rather than just appending another item to the LP list.## Quadratic Program Formulation and Classification

### Purpose and Motivation

Every method covered across the preceding Linear Programming Algorithms sequence assumed a linear objective. **Quadratic programming (QP)** extends the LP framework by allowing a quadratic term in the objective while keeping all constraints linear — the natural next step in generality after LP, and the entry point into the broader convex optimization landscape that the interior-point/barrier methods sessions gestured toward when noting their generalization beyond LP.

### Standard Formulation

$$\min \; \frac{1}{2} x^T Q x + c^T x$$
$$\text{subject to} \quad Ax \leq b, \quad x \geq 0$$

(equality-constrained and mixed-constraint variants follow directly by substituting the appropriate constraint form, exactly as in the LP standard-form conventions used throughout the prior sessions.)

- $Q$ is an $n \times n$ symmetric matrix (any quadratic form $x^TQx$ can be rewritten with a symmetric $Q$ without loss of generality, since only the symmetric part of a matrix contributes to $x^TQx$).
- The $\frac{1}{2}$ factor is a common convention chosen so that the gradient of the objective is exactly $Qx + c$, without a stray factor of 2 — purely notational, not a substantive modeling choice.
- If $Q = 0$, the QP reduces exactly to an LP, confirming QP as a strict generalization.

### Classification by Definiteness of Q

The single most important structural property of a QP is the **definiteness** of $Q$, since it determines both the geometry of the objective and which solution methods are theoretically guaranteed to work.

| Definiteness of $Q$ | Objective Shape | Problem Class | Solvability |
|---|---|---|---|
| Positive definite ($x^TQx > 0 \; \forall x \neq 0$) | Strictly convex bowl | Convex QP | Unique global minimum; efficiently solvable |
| Positive semidefinite ($x^TQx \geq 0$) | Convex, possibly flat directions | Convex QP | Global minimum exists (possibly non-unique); efficiently solvable |
| Indefinite (mixed signs) | Saddle-shaped | Non-convex QP | Multiple local minima possible; NP-hard in general |
| Negative (semi)definite | Concave bowl (for minimization, unbounded below generally) | Non-convex QP (for minimization) | Problem is typically unbounded unless constraints bound it |

**Why Definiteness Matters**

[Inference] Convex QP inherits essentially the same favorable structure that makes LP tractable: any local minimum is automatically a global minimum, because a convex objective over a convex feasible region (the polyhedron defined by linear constraints) has no spurious local optima to get trapped in. Non-convex QP loses this guarantee entirely — the feasible region is still a polyhedron, but the objective's saddle or concave structure can create multiple local minima, making global optimization NP-hard in general, in sharp contrast to every method covered in the LP sessions.

### Checking Definiteness in Practice

**Eigenvalue Test**

$Q$ is positive semidefinite if and only if all its eigenvalues are non-negative; positive definite if and only if all eigenvalues are strictly positive.

**Leading Principal Minors (Sylvester's Criterion)**

$Q$ is positive definite if and only if every leading principal minor (the determinant of the top-left $k \times k$ submatrix, for $k = 1, \ldots, n$) is strictly positive. A related but distinct test using *all* principal minors (not just leading ones) is required for positive semidefiniteness — the leading-minor-only version is specifically for the strict positive-definite case.

[Inference] In practice, for anything beyond very small $Q$, the eigenvalue test (or a Cholesky factorization attempt, which succeeds only for positive definite matrices) is generally preferred computationally over hand-checking principal minors, since it is more numerically robust and directly usable within solver algorithms.

### Common Sources of Convex QP in Practice

- **Portfolio optimization**: minimizing portfolio variance $x^T \Sigma x$ (where $\Sigma$ is a covariance matrix — always positive semidefinite by construction) subject to linear budget and return constraints is the canonical convex QP application, directly connecting to the Markowitz mean-variance framework.
- **Least-squares problems with linear constraints**: minimizing $\|Ax - b\|_2^2 = x^T(A^TA)x - 2b^TAx + b^Tb$ subject to linear constraints on $x$ is a convex QP, since $A^TA$ is always positive semidefinite.
- **Support vector machine training**: the standard SVM dual formulation (margin maximization subject to linear constraints on the dual variables) is a convex QP with a specific structured $Q$ matrix derived from the kernel (or Gram) matrix of the training data.
- **Trust-region subproblems in nonlinear optimization**: many nonlinear optimization algorithms solve a QP subproblem at each iteration as a local quadratic approximation to a more general nonlinear objective, within a trust-region constraint.

### Relationship to the KKT Conditions

As with LP, an optimal solution to a convex QP must satisfy KKT stationarity, primal feasibility, dual feasibility, and complementary slackness — the same conditions introduced conceptually in the interior-point methods sessions, now applied with a quadratic (rather than linear) objective gradient:

$$Qx^* + c - A^T\lambda^* - \mu^* = 0 \quad \text{(stationarity, with } \lambda^*, \mu^* \text{ the multipliers for inequality and non-negativity constraints)}$$
$$Ax^* \leq b, \quad x^* \geq 0 \quad \text{(primal feasibility)}$$
$$\lambda^*, \mu^* \geq 0 \quad \text{(dual feasibility)}$$
$$\lambda_i^*(Ax^* - b)_i = 0, \quad \mu_j^* x_j^* = 0 \quad \text{(complementary slackness)}$$

For a **convex** QP, these KKT conditions are both necessary and sufficient for global optimality — directly mirroring the LP case. For a **non-convex** QP, KKT conditions remain necessary but are no longer sufficient; a KKT point may only be a local minimum, a saddle point, or (in pathological cases) not even a local minimum without additional second-order conditions.

### Visualizing Convexity Classes

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 680 320">
  <text x="340" y="24" font-size="17" font-weight="bold" text-anchor="middle" fill="#111">QP Objective Shapes by Definiteness (svg_diagram)</text>

  <text x="120" y="55" font-size="13" font-weight="bold" text-anchor="middle" fill="#111">Positive Definite</text>
  <path d="M 40,220 Q 120,80 200,220" fill="none" stroke="#0f9d58" stroke-width="3" />
  <circle cx="120" cy="128" r="5" fill="#0f9d58" />
  <text x="120" y="245" font-size="11" text-anchor="middle" fill="#111">unique global min</text>

  <text x="340" y="55" font-size="13" font-weight="bold" text-anchor="middle" fill="#111">Positive Semidefinite</text>
  <path d="M 260,220 Q 300,140 340,140 Q 380,140 420,220" fill="none" stroke="#4285f4" stroke-width="3" />
  <line x1="320" y1="140" x2="360" y2="140" stroke="#4285f4" stroke-width="3" />
  <text x="340" y="245" font-size="11" text-anchor="middle" fill="#111">flat direction, min set</text>

  <text x="560" y="55" font-size="13" font-weight="bold" text-anchor="middle" fill="#111">Indefinite</text>
  <path d="M 500,90 Q 560,150 620,90" fill="none" stroke="#db4437" stroke-width="3" />
  <path d="M 500,230 Q 560,170 620,230" fill="none" stroke="#db4437" stroke-width="3" opacity="0.5" />
  <circle cx="560" cy="150" r="5" fill="#db4437" />
  <text x="560" y="245" font-size="11" text-anchor="middle" fill="#111">saddle point</text>
</svg>

### Comparison to Linear Programming

| Property | Linear Programming | Convex QP | Non-Convex QP |
|---|---|---|---|
| Objective | Linear | Quadratic, $Q \succeq 0$ | Quadratic, $Q$ indefinite |
| Feasible region | Polyhedron | Polyhedron (same as LP) | Polyhedron (same as LP) |
| Local = global minimum? | Yes | Yes | No, in general |
| Optimal solution location | Always at a vertex (if bounded) | May be interior, on a face, or at a vertex | May be interior, on a face, or at a vertex |
| Worst-case complexity | Polynomial (interior-point) | Polynomial (interior-point, extended barrier) | NP-hard in general |
| KKT sufficiency | Sufficient | Sufficient | Necessary only |

### A Key Structural Departure from LP

[Inference] The fact that a convex QP's optimal solution need not lie at a vertex of the feasible polyhedron — unlike LP, where an optimum always exists at a vertex when the problem is bounded — is the single most consequential structural difference carried forward into solution methods: vertex-enumerating approaches like the simplex family are not directly applicable to general convex QP without substantial modification (such as the active-set method, which explicitly tracks which constraints are binding without requiring the solution to sit at a full vertex), motivating the QP-specific algorithms to be covered in upcoming sessions.

### Relationship to Prior Session Topics

- The KKT framework introduced conceptually across the interior-point sessions generalizes directly here, with the linear objective gradient $c$ replaced by the quadratic gradient $Qx + c$.
- The barrier/central-path machinery from the interior-point sessions extends to convex QP essentially unchanged in structure — a fact previewed explicitly in the interior-point methods session's closing note on generalization to convex optimization.
- Portfolio optimization and least-squares applications connect this session to the earlier probability/statistics sessions on this account (bias-variance tradeoff, estimation) as adjacent but distinct application domains.

### Related Topics

- Active-set methods for convex QP (vertex-free analog of simplex-style pivoting)
- Interior-point methods extended to convex QP
- KKT conditions and second-order optimality conditions in nonlinear programming
- Semidefinite programming (a further generalization beyond QP)
- Support vector machines and their dual QP formulation
- Non-convex QP heuristics and global optimization approaches