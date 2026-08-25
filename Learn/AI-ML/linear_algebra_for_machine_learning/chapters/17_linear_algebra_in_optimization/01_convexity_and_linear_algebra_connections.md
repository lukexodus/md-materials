## Convexity and Linear Algebra Connections

### Overview

Convexity is a geometric and analytic property that underlies why many machine learning optimization problems are tractable. Linear algebra provides the structural tools — subspaces, eigenvalues, quadratic forms, and norms — used to define, test, and exploit convexity in loss functions, constraint sets, and feasible regions.

### Convex Sets

A set $C \subseteq \mathbb{R}^n$ is convex if, for any two points in $C$, the line segment connecting them lies entirely within $C$.

$$\forall \mathbf{x}, \mathbf{y} \in C, \ \forall \lambda \in [0,1]: \quad \lambda \mathbf{x} + (1-\lambda)\mathbf{y} \in C$$

**Key Points**
- Linear subspaces, affine subspaces, and hyperplanes are all convex sets
- Intersections of convex sets are convex; unions generally are not
- Balls defined by any norm (e.g., $\{\mathbf{x} : \|\mathbf{x}\| \le r\}$) are convex, a direct consequence of the triangle inequality property of norms

#### Diagram: Convex vs Non-Convex Sets

<svg viewBox="0 0 700 320" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Convex vs Non-Convex Sets (svg_diagram)</text>

  <text x="175" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Convex</text>
  <path d="M 90 100 Q 175 70, 260 100 Q 280 160, 260 220 Q 175 250, 90 220 Q 70 160, 90 100 Z" fill="#dbeafe" stroke="#2563eb" stroke-width="2"/>
  <circle cx="120" cy="140" r="4" fill="#1e3a8a"/>
  <circle cx="220" cy="190" r="4" fill="#1e3a8a"/>
  <line x1="120" y1="140" x2="220" y2="190" stroke="#1e3a8a" stroke-width="2" stroke-dasharray="4"/>
  <text x="175" y="290" text-anchor="middle" font-size="12" fill="#555">Segment stays inside</text>

  <text x="525" y="60" text-anchor="middle" font-size="14" font-weight="bold" fill="#333">Non-Convex</text>
  <path d="M 440 100 Q 480 130, 460 160 Q 440 190, 480 220 Q 520 250, 560 220 Q 600 190, 580 160 Q 560 130, 610 100 Q 525 80, 440 100 Z" fill="#fee2e2" stroke="#dc2626" stroke-width="2"/>
  <circle cx="460" cy="115" r="4" fill="#7f1d1d"/>
  <circle cx="590" cy="115" r="4" fill="#7f1d1d"/>
  <line x1="460" y1="115" x2="590" y2="115" stroke="#7f1d1d" stroke-width="2" stroke-dasharray="4"/>
  <text x="525" y="290" text-anchor="middle" font-size="12" fill="#555">Segment exits the set</text>
</svg>

### Convex Functions

A function $f: \mathbb{R}^n \to \mathbb{R}$ is convex if its domain is a convex set and:

$$f(\lambda \mathbf{x} + (1-\lambda)\mathbf{y}) \le \lambda f(\mathbf{x}) + (1-\lambda) f(\mathbf{y}) \quad \forall \mathbf{x}, \mathbf{y}, \ \lambda \in [0,1]$$

Geometrically, the line segment (chord) between any two points on the function's graph lies on or above the graph.

**Key Points**
- Strict convexity replaces $\le$ with $<$ for $\lambda \in (0,1)$, $\mathbf{x} \neq \mathbf{y}$, and implies a unique global minimum if one exists
- A convex function's sublevel sets $\{\mathbf{x} : f(\mathbf{x}) \le c\}$ are always convex sets
- Concave functions satisfy the reverse inequality; $f$ is concave if and only if $-f$ is convex

### The Hessian and Second-Order Conditions

For twice-differentiable functions, convexity connects directly to linear algebra through the Hessian matrix $H$, the matrix of second partial derivatives.

$$H_{ij} = \frac{\partial^2 f}{\partial x_i \partial x_j}$$

**Key Points**
- $f$ is convex on a convex domain if and only if $H$ is positive semi-definite ($\mathbf{v}^T H \mathbf{v} \ge 0$ for all $\mathbf{v}$) everywhere on that domain
- $f$ is strictly convex if $H$ is positive definite ($\mathbf{v}^T H \mathbf{v} > 0$ for all $\mathbf{v} \neq \mathbf{0}$) everywhere, though positive definiteness is a sufficient, not necessary, condition for strict convexity
- Positive semi-definiteness of $H$ is equivalent to all eigenvalues of $H$ being non-negative, linking convexity directly to the spectral properties of a matrix

**Example**

For $f(\mathbf{x}) = \mathbf{x}^T A \mathbf{x}$ with symmetric $A$:

$$H = 2A$$

so $f$ is convex if and only if $A$ is positive semi-definite. This is the direct link between quadratic forms and convexity used throughout ML, particularly in analyzing loss surfaces of linear and ridge regression.

### Quadratic Forms and Positive Definiteness

A quadratic form $Q(\mathbf{x}) = \mathbf{x}^T A \mathbf{x}$ classifies as follows based on the eigenvalues of symmetric $A$:

| Eigenvalues of $A$ | Classification | Shape of $Q$ |
|---|---|---|
| All $\lambda_i > 0$ | Positive definite | Convex bowl, unique minimum at origin |
| All $\lambda_i \ge 0$, some $= 0$ | Positive semi-definite | Convex, flat directions along zero-eigenvalue eigenvectors |
| All $\lambda_i < 0$ | Negative definite | Concave bowl, unique maximum |
| Mixed signs | Indefinite | Saddle shape, neither convex nor concave |

**Key Points**
- This classification underlies why the loss surface of ordinary least squares regression, $f(\mathbf{w}) = \|X\mathbf{w} - \mathbf{y}\|_2^2$, is convex: its Hessian is $2X^TX$, which is always positive semi-definite regardless of $X$
- Ridge regression adds $\lambda \|\mathbf{w}\|_2^2$, whose Hessian contribution $2\lambda I$ is positive definite for $\lambda > 0$, which can convert a positive semi-definite Hessian into a strictly positive definite one, guaranteeing a unique minimum. [Inference: this is a standard, well-established result in ridge regression theory, following directly from the algebra of adding $2\lambda I$ to $2X^TX$]

### Norms as Convex Functions

All norms are convex functions, a direct consequence of the triangle inequality and absolute homogeneity properties that define a norm.

$$\|\lambda \mathbf{x} + (1-\lambda)\mathbf{y}\| \le \|\lambda \mathbf{x}\| + \|(1-\lambda)\mathbf{y}\| = \lambda\|\mathbf{x}\| + (1-\lambda)\|\mathbf{y}\|$$

**Key Points**
- This is why $L_1$ and $L_2$ regularization terms preserve convexity of a loss function when added to an already-convex base loss, since a sum of convex functions is convex
- $L_1$ norm regularization (Lasso) is convex but not strictly convex nor smooth at zero, which produces sparse solutions rather than a single unique minimum path
- $L_2$ norm squared is strictly convex, contributing to the uniqueness of ridge regression solutions

### Convexity in Machine Learning Optimization

#### Why Convexity Matters

**Key Points**
- For convex functions, any local minimum is also a global minimum, removing the risk of optimization algorithms becoming trapped in suboptimal local minima
- Convex optimization problems have well-developed theoretical guarantees regarding convergence of gradient-based methods, under appropriate conditions on step size and smoothness [Inference: convergence guarantees in convex optimization theory are well established in the mathematical literature, but actual convergence in a specific implementation depends on step size selection, numerical precision, and problem conditioning, and is not automatic in practice]
- Many core ML models are convex: linear regression, ridge regression, logistic regression, and linear SVMs all have convex loss functions

#### Non-Convexity in Modern ML

Neural network loss surfaces are generally non-convex due to the composition of nonlinear activation functions across multiple layers.

**Key Points**
- Non-convex loss surfaces can contain multiple local minima, saddle points, and plateaus
- [Speculation] Some research suggests that in high-dimensional neural network loss landscapes, many local minima may have similar loss values to the global minimum, though this is an active and not fully settled area of research, and findings vary across architectures and datasets
- Despite non-convexity, gradient-based methods (SGD, Adam, etc.) are used successfully to train deep networks in practice; this empirical success does not follow from convex optimization theory and is a separate area of ongoing theoretical study [Unverified as a general guarantee — behavior varies substantially by architecture, initialization, and optimizer, and no universal theoretical explanation for this success is settled]

### Convex Optimization and Linear Algebra Tools

#### Projections onto Convex Sets

Projecting a point onto a convex set is a well-defined, unique operation, in contrast to projection onto non-convex sets, which may have multiple equally valid nearest points.

$$\text{proj}_C(\mathbf{x}) = \arg\min_{\mathbf{y} \in C} \|\mathbf{x} - \mathbf{y}\|_2$$

This uniqueness relies on convexity of $C$ combined with the strict convexity of the squared Euclidean norm.

#### Duality and Linear Algebra

Convex optimization duality (e.g., Lagrangian duality) relies heavily on linear algebra operations — particularly linear combinations of constraints via Lagrange multipliers and matrix representations of constraint gradients — to transform constrained problems into related unconstrained or lower-dimensional problems.

### Related Topics

- Positive definite and positive semi-definite matrices
- Eigenvalues, eigenvectors, and spectral decomposition
- Gradient descent and convergence properties
- Regularization (L1/L2) and its geometric interpretation
- Quadratic forms and their applications in ML loss functions
- Lagrangian duality and constrained optimization

