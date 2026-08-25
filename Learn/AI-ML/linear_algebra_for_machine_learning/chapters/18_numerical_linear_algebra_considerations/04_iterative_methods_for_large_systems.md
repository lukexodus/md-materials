## Iterative Methods for Large Systems

### Overview

Iterative methods solve linear systems $A\mathbf{x} = \mathbf{b}$ by generating a sequence of successively better approximate solutions, rather than computing an exact answer through direct factorization. They are the standard approach for large, sparse systems common in machine learning, where direct methods such as LU decomposition become computationally prohibitive.

### Direct vs Iterative Methods

**Key Points**
- Direct methods (LU, Cholesky, QR decomposition) compute an exact solution, subject to floating-point rounding, in a predetermined, finite number of operations, typically $O(n^3)$ for a dense $n \times n$ system
- Iterative methods instead produce a sequence of approximations that converge toward the solution, stopping once a chosen accuracy threshold is reached, which can require far fewer operations per iteration on large sparse systems
- Iterative methods are generally preferred when $A$ is large and sparse, since they can exploit sparsity (only nonzero entries need be stored and multiplied) in ways that direct factorization methods often cannot fully preserve, as factorization can introduce "fill-in" — new nonzero entries not present in the original matrix [Inference: this general trade-off is a standard, well-established characterization in numerical linear algebra literature; the actual crossover point where iterative methods outperform direct methods depends on matrix size, sparsity pattern, and desired accuracy]

### Jacobi and Gauss-Seidel Methods

#### Jacobi Method

Splits $A = D + R$, where $D$ is the diagonal of $A$ and $R$ contains the remaining off-diagonal entries, then iterates:

$$\mathbf{x}^{(k+1)} = D^{-1}(\mathbf{b} - R\mathbf{x}^{(k)})$$

**Key Points**
- Each component of $\mathbf{x}^{(k+1)}$ is updated using only values from the previous iteration $\mathbf{x}^{(k)}$, making the method straightforward to parallelize, since updates for different components do not depend on each other within the same iteration
- Convergence is guaranteed for matrices that are diagonally dominant, meaning each diagonal entry's magnitude exceeds the sum of the magnitudes of the other entries in its row — a standard sufficient (though not necessary) condition established in numerical linear algebra theory [Inference: diagonal dominance as a sufficient convergence condition for the Jacobi method is a well-established theoretical result]

#### Gauss-Seidel Method

Similar to Jacobi, but uses already-updated components within the same iteration:

$$x_i^{(k+1)} = \frac{1}{a_{ii}}\left(b_i - \sum_{j<i} a_{ij}x_j^{(k+1)} - \sum_{j>i} a_{ij}x_j^{(k)}\right)$$

**Key Points**
- Using updated values immediately, rather than waiting for the next full iteration, typically produces faster convergence than Jacobi on the same system, though this is not guaranteed for every matrix [Inference: Gauss-Seidel generally converging faster than Jacobi is a commonly cited comparative result in numerical linear algebra references, but the relative advantage is problem-dependent and not universal across all matrices]
- The sequential dependency between component updates makes Gauss-Seidel harder to parallelize directly compared to Jacobi

### The Conjugate Gradient Method

Conjugate gradient (CG) is designed specifically for symmetric positive definite systems and is one of the most widely used iterative methods in ML-adjacent numerical computing.

**Key Points**
- CG generates a sequence of search directions that are mutually conjugate with respect to $A$ (i.e., $\mathbf{d}_i^T A \mathbf{d}_j = 0$ for $i \neq j$), which guarantees that, in exact arithmetic, the method converges to the exact solution in at most $n$ iterations for an $n \times n$ system [Inference: this exact finite-termination property is a well-established theoretical result for CG under exact arithmetic; in practice, floating-point rounding error can cause the method to require more iterations or fail to reach this theoretical bound exactly]
- In practice, far fewer than $n$ iterations are often needed to reach acceptable accuracy, particularly when $A$ is well-conditioned, since the convergence rate depends on the condition number $\kappa(A)$ (as discussed under condition number and error sensitivity), not solely on system size [Inference: this practical behavior is widely documented in numerical optimization literature; the specific number of iterations needed for a given accuracy threshold depends on the specific matrix's eigenvalue distribution and is not fixed across all problems]
- CG requires only matrix-vector products with $A$, not explicit access to or storage of $A$ itself, making it well suited to very large, implicitly-defined, or sparse systems where forming $A$ explicitly would be impractical

### Diagram: Iterative Convergence Toward a Solution

<svg viewBox="0 0 700 360" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Iterative Approximation Sequence (svg_diagram)</text>

  <ellipse cx="380" cy="200" rx="180" ry="90" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="380" cy="200" rx="130" ry="65" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <ellipse cx="380" cy="200" rx="80" ry="40" fill="none" stroke="#cbd5e1" stroke-width="1.5"/>
  <circle cx="380" cy="200" r="4" fill="#16a34a"/>
  <text x="380" y="230" text-anchor="middle" font-size="12" fill="#16a34a">exact solution x*</text>

  <path d="M 130 90 L 220 130 L 290 160 L 335 180 L 360 192" stroke="#2563eb" stroke-width="2.5" fill="none"/>
  <circle cx="130" cy="90" r="4" fill="#1e3a8a"/>
  <text x="120" y="75" font-size="12" fill="#333">x(0)</text>
  <circle cx="220" cy="130" r="4" fill="#1e3a8a"/>
  <text x="220" y="118" font-size="12" fill="#333">x(1)</text>
  <circle cx="290" cy="160" r="4" fill="#1e3a8a"/>
  <text x="298" y="150" font-size="12" fill="#333">x(2)</text>
  <circle cx="335" cy="180" r="4" fill="#1e3a8a"/>
  <text x="343" y="172" font-size="12" fill="#333">x(3)</text>

  <text x="350" y="340" text-anchor="middle" font-size="12" fill="#555">Each iteration produces a closer approximation; stopping is based on a chosen tolerance</text>
</svg>

This is a conceptual illustration of iterative approximation, not a plot generated from a specific numerical run. [Inference] The exact path and number of steps needed depends on the specific matrix, method, and starting point.

### Preconditioning

**Key Points**
- Preconditioning transforms a system $A\mathbf{x} = \mathbf{b}$ into an equivalent system with more favorable conditioning, typically $M^{-1}A\mathbf{x} = M^{-1}\mathbf{b}$ for some matrix $M$ chosen to approximate $A$ while being easier to invert
- This directly addresses the condition-number dependence of iterative methods' convergence rate, since a well-chosen preconditioner reduces the effective condition number of the system being iterated on [Inference: the general mechanism by which preconditioning improves convergence is well established in numerical linear algebra theory; the degree of improvement for a specific preconditioner and matrix is problem-dependent and not guaranteed in advance]
- Common preconditioners include diagonal (Jacobi) preconditioning, incomplete Cholesky factorization, and incomplete LU factorization, each trading off preconditioner construction cost against resulting convergence speedup

### GMRES for Non-Symmetric Systems

**Key Points**
- Generalized Minimal Residual (GMRES) extends the iterative approach to general non-symmetric systems, where conjugate gradient's theoretical guarantees do not apply
- GMRES minimizes the residual norm $\|\mathbf{b} - A\mathbf{x}^{(k)}\|$ over a growing Krylov subspace at each iteration, at the cost of needing to store an increasing number of basis vectors as iterations proceed, unless restarted periodically [Inference: this memory growth characteristic and the common practice of restarting are well-documented properties of the standard GMRES algorithm]

### Stochastic and Randomized Iterative Methods

**Key Points**
- Stochastic gradient descent, covered under gradient descent as vector updates, can itself be viewed as an iterative method for approximately solving certain large-scale optimization problems, using random subsets of data rather than the full system at each step
- Randomized methods such as randomized Kaczmarz iteratively project onto hyperplanes defined by randomly selected rows of a linear system, offering convergence guarantees in expectation for certain problem classes [Unverified — specific convergence guarantees depend on the chosen randomized method, the properties of the matrix involved, and the particular theoretical framework used to analyze it; this is an active area of numerical analysis research and not a single settled universal result]

### Applications in Machine Learning

**Key Points**
- Large-scale linear regression and ridge regression problems, where the design matrix is too large for direct factorization, are commonly solved using conjugate gradient or related iterative methods rather than the normal equations approach directly [Inference: this reflects standard practice described in numerical optimization and ML literature for large-scale problems, though the specific solver chosen in a given implementation varies by library and problem size]
- Iterative methods underlie some large-scale kernel machine and Gaussian process computations, where the relevant matrices (e.g., kernel matrices) can be too large to store or factor directly, making matrix-vector-product-only methods necessary
- Graph-based algorithms, including some formulations of PageRank, are solved via iterative methods (power iteration, a related iterative technique) applied to large sparse matrices representing graph structure

### Related Topics

- Condition number and error sensitivity
- Numerical stability of algorithms
- Gradient descent as vector updates
- Eigenvalues and power iteration
- Sparse matrix representations and operations
- Preconditioning techniques for optimization
