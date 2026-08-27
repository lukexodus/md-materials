## Vector Spaces, Norms, and Inner Products

### Vector Spaces

A vector space $V$ over a field $\mathbb{R}$ is a set closed under vector addition and scalar multiplication, satisfying eight axioms: associativity and commutativity of addition, existence of a zero vector, existence of additive inverses, compatibility of scalar multiplication with field multiplication, identity element of scalar multiplication, and distributivity of scalar multiplication over vector and field addition.

In optimization, the working space is almost always $\mathbb{R}^n$, the space of $n$-dimensional real column vectors. Optimization variables $x \in \mathbb{R}^n$ live here, and the geometry of $\mathbb{R}^n$ (lines, hyperplanes, convex sets) underlies the entire theory of feasible regions and descent directions.

**Subspaces and Affine Sets**

A subspace $S \subseteq \mathbb{R}^n$ is a subset closed under addition and scalar multiplication, and it always contains the origin. An affine set is a translated subspace: $A = x_0 + S = \{x_0 + s : s \in S\}$. Affine sets do not necessarily pass through the origin. Constraint sets of the form $\{x : Ax = b\}$ in linear and quadratic programming are affine sets, and understanding their structure is essential for characterizing feasible regions.

**Span, Basis, and Dimension**

The span of a set of vectors $\{v_1, \dots, v_k\}$ is the set of all their linear combinations. A basis is a linearly independent spanning set, and the number of vectors in any basis of $V$ is the dimension of $V$, denoted $\dim(V)$. For $\mathbb{R}^n$, $\dim(\mathbb{R}^n) = n$, and the standard basis $\{e_1, \dots, e_n\}$ is the canonical choice.

**Linear Independence**

Vectors $v_1, \dots, v_k$ are linearly independent if $\sum_i c_i v_i = 0$ implies $c_i = 0$ for all $i$. Linear independence governs the rank of Jacobian and Hessian matrices in optimization: when constraint gradients are linearly independent at a point, that point is called a regular point, a condition (LICQ — Linear Independence Constraint Qualification) required for the Karush-Kuhn-Tucker (KKT) conditions to be necessary for optimality.

### Norms

A norm is a function $\|\cdot\| : V \to \mathbb{R}$ satisfying three axioms:

$$\|x\| \geq 0, \text{ with } \|x\| = 0 \iff x = 0 \quad \text{(positive definiteness)}$$

$$\|\alpha x\| = |\alpha| \, \|x\| \quad \text{(absolute homogeneity)}$$

$$\|x + y\| \leq \|x\| + \|y\| \quad \text{(triangle inequality)}$$

Norms quantify the "size" of a vector and, critically, the "size" of a step or error in an optimization algorithm — convergence criteria are almost always stated as $\|x_k - x^*\| < \epsilon$ for some norm.

**Common Norms on $\mathbb{R}^n$**

The $p$-norm family is defined as:

$$\|x\|_p = \left( \sum_{i=1}^n |x_i|^p \right)^{1/p}$$

- **$\ell_1$ norm** ($p=1$): $\|x\|_1 = \sum_i |x_i|$. Used in sparse optimization (LASSO, compressed sensing) because it promotes sparsity in solutions.
- **$\ell_2$ norm (Euclidean)** ($p=2$): $\|x\|_2 = \sqrt{\sum_i x_i^2} = \sqrt{x^T x}$. The default norm for gradient magnitudes, trust-region radii, and convergence checks.
- **$\ell_\infty$ norm** ($p \to \infty$): $\|x\|_\infty = \max_i |x_i|$. Used for box-constraint feasibility and worst-case error bounds.

**Matrix Norms**

Matrix norms extend the concept to linear operators. The induced (operator) norm is:

$$\|A\| = \sup_{x \neq 0} \frac{\|Ax\|}{\|x\|}$$

The spectral norm $\|A\|_2$ equals the largest singular value of $A$, and it bounds how much a linear map can amplify a vector's length — relevant when analyzing the conditioning of Hessian matrices and the stability of Newton-type steps. The Frobenius norm $\|A\|_F = \sqrt{\sum_{i,j} A_{ij}^2}$ treats $A$ as a flattened vector and is common in regularization terms for matrix-valued optimization variables.

**Norm Equivalence**

[Inference — standard result, stated generally without full proof] All norms on a finite-dimensional vector space are equivalent, meaning for any two norms $\|\cdot\|_a, \|\cdot\|_b$ there exist constants $c_1, c_2 > 0$ such that:

$$c_1 \|x\|_a \leq \|x\|_b \leq c_2 \|x\|_a \quad \forall x$$

This matters practically: convergence in one norm implies convergence in any other norm on $\mathbb{R}^n$, so algorithm analysis can choose whichever norm is most convenient (often $\ell_2$ for smoothness arguments, $\ell_\infty$ for box constraints) without loss of generality regarding convergence *behavior*, though convergence *rates* and constants are norm-dependent.

### Inner Products

An inner product $\langle \cdot, \cdot \rangle : V \times V \to \mathbb{R}$ satisfies:

$$\langle x, y \rangle = \langle y, x \rangle \quad \text{(symmetry)}$$

$$\langle \alpha x + \beta y, z \rangle = \alpha \langle x, z \rangle + \beta \langle y, z \rangle \quad \text{(bilinearity)}$$

$$\langle x, x \rangle \geq 0, \text{ with equality iff } x = 0 \quad \text{(positive definiteness)}$$

The standard (Euclidean) inner product on $\mathbb{R}^n$ is $\langle x, y \rangle = x^T y = \sum_i x_i y_i$, and it induces the $\ell_2$ norm via $\|x\|_2 = \sqrt{\langle x, x \rangle}$.

**Geometric Interpretation**

$$\langle x, y \rangle = \|x\|_2 \|y\|_2 \cos\theta$$

where $\theta$ is the angle between $x$ and $y$. This relationship is the foundation of descent-direction analysis: a direction $d$ is a descent direction for a function $f$ at $x$ if $\langle \nabla f(x), d \rangle < 0$, i.e., $d$ makes an obtuse angle with the gradient.

**Cauchy-Schwarz Inequality**

$$|\langle x, y \rangle| \leq \|x\|_2 \|y\|_2$$

with equality iff $x$ and $y$ are linearly dependent. This inequality is used constantly in convergence proofs to bound inner products of gradients and search directions.

**Orthogonality**

Vectors $x, y$ are orthogonal if $\langle x, y \rangle = 0$. Orthogonal sets simplify projections onto subspaces (relevant for equality-constrained optimization, where the feasible directions form a subspace orthogonal to the constraint gradients), and orthogonal/orthonormal bases underlie eigendecomposition and the numerical stability of algorithms like QR-based least-squares solvers.

**Weighted Inner Products**

For a symmetric positive-definite matrix $M$, $\langle x, y \rangle_M = x^T M y$ defines a valid inner product, inducing the norm $\|x\|_M = \sqrt{x^T M x}$. This generalization appears directly in optimization: Newton's method implicitly uses the inner product weighted by the Hessian, and quasi-Newton methods (BFGS, DFP) construct successive approximations to this weighted geometry.

### Illustration: Gradient, Descent Direction, and Inner Product Angle (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 340">
  <text x="260" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#111">Descent Direction via Inner Product (svg_diagram)</text>

  <line x1="60" y1="280" x2="460" y2="280" stroke="#ccc" stroke-width="1" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#ccc" stroke-width="1" />

  <circle cx="260" cy="200" r="3" fill="#111" />
  <text x="266" y="196" font-size="12" fill="#111">x</text>

  <line x1="260" y1="200" x2="380" y2="120" stroke="#c0392b" stroke-width="2" marker-end="url(#arrow)" />
  <text x="386" y="118" font-size="13" fill="#c0392b">∇f(x)</text>

  <line x1="260" y1="200" x2="150" y2="260" stroke="#2980b9" stroke-width="2" marker-end="url(#arrow)" />
  <text x="90" y="272" font-size="13" fill="#2980b9">d (descent dir.)</text>

  <path d="M 300 190 A 30 30 0 0 1 285 165" fill="none" stroke="#555" stroke-width="1.2" />
  <text x="300" y="175" font-size="11" fill="#555">θ &gt; 90°</text>

  <text x="60" y="310" font-size="12" fill="#333">⟨∇f(x), d⟩ = ‖∇f(x)‖‖d‖cosθ &lt; 0  ⟺  θ obtuse  ⟺  d decreases f</text>
</svg>

### Related Topics

- **Matrix decompositions**: eigendecomposition, singular value decomposition (SVD), QR, Cholesky
- **Positive definite and semidefinite matrices**: quadratic forms and their role in convexity
- **Gradients, Jacobians, and Hessians**: multivariable differentiation foundations
- **Convex sets and convex functions**: geometric prerequisites for convex optimization theory
- **Projections and orthogonal decomposition**: relevant to constrained and proximal methods