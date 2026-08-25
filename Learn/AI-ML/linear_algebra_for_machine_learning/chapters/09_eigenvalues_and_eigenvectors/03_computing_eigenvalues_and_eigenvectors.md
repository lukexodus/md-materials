## Computing Eigenvalues and Eigenvectors

### Definition

An eigenvector of a square matrix $A \in \mathbb{R}^{n \times n}$ is a nonzero vector $v$ that, when multiplied by $A$, only changes in scale (not direction):

$$Av = \lambda v, \quad v \neq 0$$

The scalar $\lambda$ is the **eigenvalue** associated with $v$. This is a direct algebraic definition, not an inference.

### Step 1 — Find Eigenvalues via the Characteristic Polynomial

As established in the prior topic, eigenvalues are the roots of:

$$\det(A - \lambda I) = 0$$

This step produces the set of eigenvalues $\lambda_1, \lambda_2, \ldots, \lambda_n$ (with possible repeats or complex values).

### Step 2 — Find Eigenvectors for Each Eigenvalue

For each eigenvalue $\lambda_i$, substitute it back into $(A - \lambda_i I)v = 0$ and solve this homogeneous linear system for $v$. The solution set (excluding $v=0$) is the **eigenspace** associated with $\lambda_i$; any nonzero vector in that eigenspace is a valid eigenvector.

This is a standard two-step algebraic procedure — a provable method, not an inference.

### Worked Example (Full Procedure)

Let:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}$$

**Finding eigenvalues** (from the prior topic's worked example):

$$\det(A-\lambda I) = \lambda^2 - 7\lambda + 10 = (\lambda-5)(\lambda-2) = 0 \implies \lambda_1 = 5,\ \lambda_2 = 2$$

**Finding the eigenvector for $\lambda_1 = 5$:**

$$A - 5I = \begin{bmatrix}4-5 & 1\\ 2 & 3-5\end{bmatrix} = \begin{bmatrix}-1 & 1\\ 2 & -2\end{bmatrix}$$

Solving $(A-5I)v=0$:

$$-v_1 + v_2 = 0 \implies v_2 = v_1$$

Any vector of the form $v = t\begin{bmatrix}1\\1\end{bmatrix}$ satisfies this. Taking $t=1$:

$$v_1^{\text{(eigenvector)}} = \begin{bmatrix}1\\1\end{bmatrix}$$

**Finding the eigenvector for $\lambda_2 = 2$:**

$$A - 2I = \begin{bmatrix}4-2 & 1\\ 2 & 3-2\end{bmatrix} = \begin{bmatrix}2 & 1\\ 2 & 1\end{bmatrix}$$

Solving $(A-2I)v=0$:

$$2v_1 + v_2 = 0 \implies v_2 = -2v_1$$

Taking $v_1 = 1$:

$$v_2^{\text{(eigenvector)}} = \begin{bmatrix}1\\-2\end{bmatrix}$$

**Verification** (direct substitution, not inference):

$$Av_1 = \begin{bmatrix}4&1\\2&3\end{bmatrix}\begin{bmatrix}1\\1\end{bmatrix} = \begin{bmatrix}5\\5\end{bmatrix} = 5\begin{bmatrix}1\\1\end{bmatrix} = \lambda_1 v_1 \quad \checkmark$$



$$Av_2 = \begin{bmatrix}4&1\\2&3\end{bmatrix}\begin{bmatrix}1\\-2\end{bmatrix} = \begin{bmatrix}2\\-4\end{bmatrix} = 2\begin{bmatrix}1\\-2\end{bmatrix} = \lambda_2 v_2 \quad \checkmark$$

Both checks confirm the eigenpairs directly through substitution.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Eigenvectors Preserve Direction Under A (svg_diagram)</text>
<line x1="40" y1="220" x2="360" y2="220" stroke="#999" stroke-width="1" />
<line x1="200" y1="40" x2="200" y2="280" stroke="#999" stroke-width="1" />
<line x1="200" y1="220" x2="260" y2="160" stroke="#2563eb" stroke-width="2" marker-end="url(#e1)" />
<text x="265" y="155" font-size="11" fill="#2563eb">v₁ = (1,1)</text>
<line x1="200" y1="220" x2="320" y2="80" stroke="#dc2626" stroke-width="2.5" marker-end="url(#e2)" />
<text x="325" y="78" font-size="11" fill="#dc2626">Av₁ = 5v₁</text>
<line x1="200" y1="220" x2="240" y2="280" stroke="#16a34a" stroke-width="2" marker-end="url(#e3)" />
<text x="245" y="290" font-size="11" fill="#16a34a">v₂ = (1,-2)</text>
<line x1="200" y1="220" x2="280" y2="340" stroke="#ea580c" stroke-width="2.5" marker-end="url(#e4)" />
<text x="180" y="295" font-size="11" fill="#ea580c" transform="translate(0,-15)">Av₂ = 2v₂</text>
</svg>

Note that the diagram above compresses the $Av_2$ arrow visually for layout purposes; the algebraic relationship $Av_2 = 2v_2$ is what is mathematically exact, not the specific pixel lengths drawn.

### Normalization Convention

Eigenvectors are only defined up to a scalar multiple — any nonzero scalar multiple of an eigenvector is also a valid eigenvector for the same eigenvalue. By convention, many algorithms and libraries return **normalized** eigenvectors (unit length, $\|v\|=1$). This is a convention adopted for consistency, not a mathematical requirement.

### Larger Systems: Why Direct Computation Doesn't Scale

For matrices larger than about $4\times 4$, there is no general closed-form algebraic solution to the characteristic polynomial's roots — this follows from the Abel–Ruffini theorem, which states that polynomials of degree 5 or higher have no general algebraic (radical) solution formula. This is a proven mathematical result.

[Inference] As a consequence, numerical/iterative methods are generally used in practice for matrices of realistic size in machine learning applications, rather than symbolic root-finding. This is a reasoned consequence of the Abel–Ruffini result combined with standard practice described in numerical linear algebra references, but I do not have access to verify the internal implementation of every specific software library without consulting its official documentation directly.

### Common Numerical Methods (Overview)

- **Power iteration**: repeatedly multiplies a vector by $A$ and renormalizes; converges toward the eigenvector associated with the largest-magnitude eigenvalue. [Inference] Convergence speed is commonly described as depending on the ratio between the largest and second-largest eigenvalue magnitudes — this is a standard reasoned property from the structure of the iteration, but actual convergence behavior on a specific matrix cannot be verified without testing that matrix directly, and I cannot claim this method eliminates the need for other techniques.
- **QR algorithm**: iteratively factors $A$ into $QR$, then reforms $A = RQ$, repeating until the matrix converges toward (approximately) upper triangular/block form, from which eigenvalues can be read off the diagonal. This is a widely documented standard method in numerical linear algebra.
- **Inverse iteration**: a variant of power iteration applied to $(A-\mu I)^{-1}$, used to find the eigenvector closest to a target value $\mu$.

I cannot verify the specific default algorithm used by any particular software version without consulting that library's official documentation directly.

### Special Case: Symmetric Matrices

If $A$ is symmetric ($A = A^T$), the **spectral theorem** guarantees:

- All eigenvalues are real (never complex).
- Eigenvectors corresponding to distinct eigenvalues are orthogonal.
- $A$ can always be fully diagonalized with an orthonormal eigenbasis.

These are proven results from the spectral theorem, not inferred properties. This case is especially relevant in machine learning because covariance matrices, Gram matrices, and Hessians of many loss functions are symmetric.

### Computational Check (Python / NumPy)

```python
import numpy as np

A = np.array([[4, 1], [2, 3]])

eigenvalues, eigenvectors = np.linalg.eig(A)

print("Eigenvalues:", eigenvalues)
print("Eigenvectors (columns):\n", eigenvectors)

# Verify Av = λv for the first eigenpair
v1 = eigenvectors[:, 0]
lambda1 = eigenvalues[0]
print("A @ v1:", A @ v1)
print("lambda1 * v1:", lambda1 * v1)
```

[Unverified] The exact numerical output — including the sign, normalization, and ordering of the returned eigenvectors — may vary depending on the NumPy version and underlying LAPACK implementation used. I cannot verify the precise output without executing this code in your specific environment. Behavior may differ across systems and is not guaranteed to match a specific format.

### Relevance to Machine Learning

- **PCA**: eigenvectors of the covariance matrix define principal component directions; eigenvalues quantify variance explained along each direction.
- **Spectral clustering**: eigenvectors of the graph Laplacian are used to embed data for clustering.
- **PageRank**: the ranking vector is the dominant eigenvector of a transition probability matrix, typically computed via power iteration.
- **Stability analysis**: eigenvalues of the Hessian at a critical point indicate whether it is a local minimum, maximum, or saddle point (all positive eigenvalues → minimum; all negative → maximum; mixed signs → saddle point). This classification is a standard, provable result from multivariable calculus (the second-order condition), not an inference.

### Key Points

- Eigenvalues are found first (via the characteristic polynomial), then eigenvectors are found by solving $(A-\lambda I)v=0$ for each eigenvalue — this is a proven two-step method.
- Eigenvectors are unique only up to scalar multiples; normalization is a convention, not a mathematical necessity.
- No general closed-form solution exists for eigenvalues of matrices larger than $4\times 4$, per the Abel–Ruffini theorem — this is proven, not inferred.
- Symmetric matrices are guaranteed real eigenvalues and orthogonal eigenvectors by the spectral theorem — proven, not inferred.
- Claims about default library algorithms, convergence speed on specific matrices, and exact numerical output formatting are labeled [Inference] or [Unverified] because I do not have access to verify implementation-specific behavior without consulting official documentation or executing code in your exact environment.

### Related Topics

- Characteristic Polynomial (prior topic)
- Diagonalization and Eigendecomposition
- Spectral Theorem for Symmetric Matrices
- Power Iteration and PageRank
- QR Algorithm for Eigenvalue Computation
- Principal Component Analysis (PCA)
- Hessian Matrices and Second-Order Optimality Conditions
- Singular Value Decomposition (SVD) as a Generalization for Non-Square Matrices