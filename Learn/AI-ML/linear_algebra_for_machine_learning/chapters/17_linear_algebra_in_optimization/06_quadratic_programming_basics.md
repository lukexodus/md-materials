## Quadratic Programming Basics

### Overview

Quadratic programming (QP) optimizes a quadratic objective function subject to linear constraints. It sits between linear programming (linear objective, linear constraints) and general nonlinear programming in complexity, and its structure connects directly to the quadratic forms, matrix positive-definiteness, and KKT conditions covered in prior topics.

### Standard Form

$$\min_{\mathbf{w}} \ \frac{1}{2}\mathbf{w}^T Q \mathbf{w} + \mathbf{c}^T \mathbf{w}$$



$$\text{subject to} \quad A\mathbf{w} \le \mathbf{b}, \quad E\mathbf{w} = \mathbf{d}$$

where $Q \in \mathbb{R}^{n \times n}$ is symmetric, $\mathbf{c} \in \mathbb{R}^n$, and $A$, $E$ encode inequality and equality constraints respectively.

**Key Points**

- $\frac{1}{2}\mathbf{w}^T Q \mathbf{w}$ is the quadratic form component, $\mathbf{c}^T \mathbf{w}$ is a linear term
- The factor $\frac{1}{2}$ is a notational convention that simplifies the gradient to $Q\mathbf{w} + \mathbf{c}$, avoiding a stray factor of 2
- Constraints are restricted to linear (affine) forms, which is what distinguishes QP from general nonlinear programming with quadratic objectives

### Convexity of the QP

**Key Points**

- The problem is convex if and only if $Q$ is positive semi-definite, directly connecting QP to the quadratic form classification covered under convexity
- Convex QPs have the property that any local minimum is a global minimum, and efficient algorithms with polynomial-time complexity guarantees exist for this case [Inference: polynomial-time solvability of convex QP is an established result in optimization theory under standard assumptions; practical solve time in a specific implementation depends on problem size, sparsity, and solver choice]
- Non-convex QPs (indefinite $Q$) are generally NP-hard in the worst case, since they may contain multiple local minima and the problem includes certain combinatorial problems as special cases [Inference: NP-hardness of general non-convex QP is a known theoretical result in complexity theory; this does not imply every non-convex QP instance encountered in practice is intractable to solve well]

### KKT Conditions for QP

Applying the general KKT conditions (covered under constrained optimization) to the QP standard form gives a system that is linear in $\mathbf{w}$ and the multipliers, due to the quadratic objective's linear gradient:

$$Q\mathbf{w}^* + \mathbf{c} + A^T\boldsymbol{\mu} + E^T\boldsymbol{\lambda} = 0$$



$$E\mathbf{w}^* = \mathbf{d}$$



$$A\mathbf{w}^* \le \mathbf{b}, \quad \boldsymbol{\mu} \ge 0$$



$$\mu_i(A\mathbf{w}^* - \mathbf{b})_i = 0 \ \ \forall i$$

**Key Points**

- Because $\nabla(\frac{1}{2}\mathbf{w}^TQ\mathbf{w} + \mathbf{c}^T\mathbf{w}) = Q\mathbf{w} + \mathbf{c}$ is linear in $\mathbf{w}$, the stationarity condition is a linear equation rather than a general nonlinear one, which is the structural reason QP is more tractable than general nonlinear programming
- Complementary slackness again determines which inequality constraints are active at the solution, exactly as in the general KKT framework

### Equality-Constrained QP: Direct Linear Solve

When only equality constraints are present, the KKT system reduces to the same block linear system introduced under constrained optimization:

$$\begin{bmatrix} Q & E^T \\ E & 0 \end{bmatrix} \begin{bmatrix} \mathbf{w}^* \\ \boldsymbol{\lambda} \end{bmatrix} = \begin{bmatrix} -\mathbf{c} \\ \mathbf{d} \end{bmatrix}$$

**Key Points**

- This system can be solved directly via matrix factorization (e.g., LU or a symmetric indefinite factorization), without iterative optimization, when $Q$ is well-conditioned
- The coefficient matrix is called the KKT matrix; it is invertible under standard regularity conditions, including $Q$ being positive definite on the null space of $E$ and $E$ having full row rank [Inference: these are standard sufficient conditions from numerical optimization theory for KKT matrix invertibility; a specific problem instance's conditioning also affects numerical stability of the solve]

### Diagram: Feasible Region and Quadratic Objective Contours

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
<text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">QP: Quadratic Contours Within a Linear Feasible Region (svg_diagram)</text>
<ellipse cx="380" cy="220" rx="220" ry="110" fill="none" stroke="#cbd5e1" stroke-width="1.5" />
<ellipse cx="380" cy="220" rx="160" ry="80" fill="none" stroke="#cbd5e1" stroke-width="1.5" />
<ellipse cx="380" cy="220" rx="100" ry="50" fill="none" stroke="#cbd5e1" stroke-width="1.5" />
<ellipse cx="380" cy="220" rx="40" ry="20" fill="none" stroke="#cbd5e1" stroke-width="1.5" />
<circle cx="380" cy="220" r="3" fill="#94a3b8" />
<text x="600" y="150" font-size="12" fill="#94a3b8">unconstrained</text>
<text x="600" y="166" font-size="12" fill="#94a3b8">minimum</text>
<polygon points="120,320 300,120 480,150 420,320" fill="#dbeafe" fill-opacity="0.5" stroke="#2563eb" stroke-width="2" />
<text x="150" y="340" font-size="12" fill="#2563eb">feasible region (A w ≤ b)</text>
<circle cx="330" cy="200" r="5" fill="#16a34a" />
<text x="345" y="195" font-size="12" fill="#16a34a">constrained optimum</text>
<line x1="330" y1="200" x2="380" y2="220" stroke="#555" stroke-width="1" stroke-dasharray="3" />
</svg>

This is a conceptual illustration, not a plot from a specific numerical instance. [Inference] The constrained optimum lies on the boundary of the feasible region in this depiction because the unconstrained minimum falls outside it; if the unconstrained minimum lies within the feasible region, the constrained and unconstrained optima coincide.

### Active Set Methods

**Key Points**

- Active set methods solve QP by guessing which inequality constraints are active (satisfied with equality) at the optimum, solving the resulting equality-constrained QP directly, then checking and updating the guessed active set
- This iterative process of adding or removing constraints from the working active set continues until the KKT conditions are satisfied
- Effective for QPs of small to moderate size, particularly when a good initial guess of the active set is available (e.g., warm-starting from a nearby solved problem) [Inference: this characterization reflects general properties of active set methods described in numerical optimization literature; relative performance versus other QP methods depends on problem size, sparsity, and structure]

### Interior Point Methods

**Key Points**

- Interior point methods approach the solution by traversing the interior of the feasible region, using a barrier function to penalize proximity to constraint boundaries, rather than explicitly tracking an active set
- Generally scale more favorably than active set methods for large, sparse QPs, though relative performance depends on problem structure [Inference: this general scaling comparison reflects common findings in numerical optimization literature, but is not a universal ranking across all QP instances]
- Widely used in large-scale QP solvers, including implementations underlying some SVM training routines

### Connection to SVM Training

**Key Points**

- The SVM dual problem (introduced under constrained optimization) is itself a QP: a quadratic objective in the dual variables $\boldsymbol{\mu}$ subject to a linear equality constraint and box (interval) inequality constraints
- Specialized QP solvers exploiting this specific structure, such as sequential minimal optimization (SMO), decompose the large QP into a sequence of very small subproblems (often solvable in closed form) rather than treating it as one large generic QP [Inference: SMO's decomposition strategy is a documented, well-established algorithmic approach; comparative solve-time performance versus generic QP solvers depends on dataset size and implementation]

### Portfolio Optimization as an Applied QP Example

**Key Points**

- Mean-variance portfolio optimization minimizes portfolio variance $\mathbf{w}^T \Sigma \mathbf{w}$ (a quadratic form using the covariance matrix $\Sigma$) subject to linear constraints such as target return and weights summing to one
- $\Sigma$ being positive semi-definite (a property of valid covariance matrices) ensures this specific QP instance is convex, connecting statistical properties of covariance matrices directly to the tractability of the resulting optimization problem

### Related Topics

- Constrained optimization with linear algebra
- Lagrange multipliers and KKT conditions
- Convexity and positive semi-definite matrices
- Support vector machines and the kernel trick
- Newton's method and the Hessian
- Covariance matrices and their properties