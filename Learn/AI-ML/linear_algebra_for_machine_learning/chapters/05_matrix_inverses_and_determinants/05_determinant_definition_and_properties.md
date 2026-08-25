## Determinant Definition and Properties

### Definition

The determinant is a scalar function defined on square matrices, $\det: \mathbb{R}^{n\times n} \to \mathbb{R}$, that encodes several intrinsic properties of a matrix — most notably invertibility, and the scaling factor a linear transformation applies to volume.

For a $1\times 1$ matrix:

$$\det([a]) = a$$

For a $2\times 2$ matrix:

$$\det\begin{pmatrix} a & b \\ c & d \end{pmatrix} = ad - bc$$

For a $3\times 3$ matrix, using cofactor expansion along the first row:

$$\det\begin{pmatrix} a & b & c \\ d & e & f \\ g & h & i \end{pmatrix} = a(ei - fh) - b(di - fg) + c(dh - eg)$$

### General Definition via Cofactor Expansion

For an $n \times n$ matrix $A$, the determinant can be defined recursively by expanding along any row $i$:

$$\det(A) = \sum_{j=1}^{n} (-1)^{i+j} a_{ij} M_{ij}$$

where $M_{ij}$ is the **minor** — the determinant of the $(n-1)\times(n-1)$ submatrix formed by deleting row $i$ and column $j$ — and $(-1)^{i+j} M_{ij}$ is called the **cofactor**, denoted $C_{ij}$.

This expansion can equivalently be done along any column, and yields the same result regardless of which row or column is chosen.

### Leibniz Formula

An equivalent, non-recursive definition uses permutations:

$$\det(A) = \sum_{\sigma \in S_n} \text{sgn}(\sigma) \prod_{i=1}^{n} a_{i,\sigma(i)}$$

where $S_n$ is the set of all permutations of $\{1, \dots, n\}$ and $\text{sgn}(\sigma)$ is $+1$ for even permutations and $-1$ for odd permutations. This formula is rarely used computationally due to its $O(n!)$ complexity, but it is the basis for several theoretical proofs.

### Geometric Interpretation

The absolute value of the determinant represents the scaling factor of volume (or area, in 2D) that a linear transformation applies to a unit hypercube. The sign indicates whether the transformation preserves or reverses orientation.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 260" font-family="sans-serif">
  <text x="240" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Determinant as Area Scaling (svg_diagram)</text>

  
  <g>
    <line x1="40" y1="200" x2="180" y2="200" stroke="#888" stroke-width="1" />
    <line x1="40" y1="200" x2="40" y2="70" stroke="#888" stroke-width="1" />
    <polygon points="40,200 130,200 130,110 40,110" fill="#a3c9f7" stroke="#2b6cb0" stroke-width="2" />
    <text x="85" y="230" font-size="12" text-anchor="middle" fill="#333">Unit square (Area = 1)</text>
    <text x="85" y="245" font-size="11" text-anchor="middle" fill="#555">e1, e2 basis</text>
  </g>

  
  <line x1="200" y1="150" x2="250" y2="150" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />
  <text x="225" y="140" font-size="11" text-anchor="middle" fill="#333">A</text>

  
  <g>
    <line x1="270" y1="200" x2="440" y2="200" stroke="#888" stroke-width="1" />
    <line x1="270" y1="200" x2="270" y2="70" stroke="#888" stroke-width="1" />
    <polygon points="270,200 400,190 370,90 240,100" fill="#f7c9a3" stroke="#c05621" stroke-width="2" />
    <text x="335" y="230" font-size="12" text-anchor="middle" fill="#333">Parallelogram (Area = |det A|)</text>
  </g>

  </svg>

### Key Properties

**Multiplicativity**
$$\det(AB) = \det(A)\det(B)$$

**Transpose invariance**
$$\det(A^T) = \det(A)$$

**Inverse relation**
If $A$ is invertible:
$$\det(A^{-1}) = \frac{1}{\det(A)}$$

**Invertibility criterion**
$A$ is invertible if and only if $\det(A) \neq 0$. A matrix with $\det(A) = 0$ is called **singular**.

**Scalar multiplication**
For an $n \times n$ matrix and scalar $k$:
$$\det(kA) = k^n \det(A)$$

**Identity**
$$\det(I_n) = 1$$

**Row/column swap**
Swapping two rows (or columns) multiplies the determinant by $-1$.

**Row/column scaling**
Multiplying a single row (or column) by scalar $k$ multiplies the determinant by $k$.

**Row addition invariance**
Adding a multiple of one row to another row does not change the determinant.

**Linear dependence**
If any row or column is a linear combination of others (including a zero row/column), then $\det(A) = 0$.

**Triangular matrices**
For upper or lower triangular matrices, the determinant equals the product of the diagonal entries:
$$\det(A) = \prod_{i=1}^n a_{ii}$$

This property makes determinant computation via LU decomposition efficient, since triangular factors reduce the calculation to a simple product.

**Block matrices**
For a block triangular matrix:
$$\det\begin{pmatrix} A & B \\ 0 & D \end{pmatrix} = \det(A)\det(D)$$

### Computation via Row Reduction

Direct cofactor expansion has factorial time complexity and is impractical beyond small matrices. In practice, determinants are computed using LU decomposition ($A = LU$, or $PA = LU$ with row pivoting), reducing the cost to $O(n^3)$:

$$\det(A) = (-1)^s \prod_{i=1}^n u_{ii}$$

where $u_{ii}$ are the diagonal entries of the upper triangular factor $U$, and $s$ is the number of row swaps performed during pivoting.

### Worked Example

Compute the determinant of:

$$A = \begin{pmatrix} 2 & 1 & 1 \\ 1 & 3 & 2 \\ 1 & 0 & 0 \end{pmatrix}$$

Expanding along the third row (efficient here due to the zeros):

$$\det(A) = 1 \cdot (-1)^{3+1}\begin{vmatrix}1 & 1 \\ 3 & 2\end{vmatrix} + 0 + 0$$

$$= 1 \cdot (1\cdot 2 - 1\cdot 3) = 1\cdot(-1) = -1$$

Since $\det(A) = -1 \neq 0$, $A$ is invertible.

### Relevance to Machine Learning

- **Checking invertibility**: Before computing $A^{-1}$ (e.g., in the normal equations $\theta = (X^TX)^{-1}X^Ty$ for linear regression), a zero or near-zero determinant signals a singular or ill-conditioned matrix.
- **Covariance matrices**: The determinant of a covariance matrix appears in the multivariate Gaussian density formula, related to the "volume" of the distribution's spread.
- **Change of variables**: In probability and generative modeling (e.g., normalizing flows), the Jacobian determinant quantifies how a transformation rescales probability density.
- **Numerical stability**: In practice, a determinant close to zero (relative to matrix scale) is often used as a rough indicator of near-singularity, though condition number is generally considered a more reliable diagnostic. [Inference] This is a common practical heuristic in numerical linear algebra, though specific thresholds and reliability depend on context and are not universal.

### Common Pitfalls

- Determinant values can be extremely large or small for high-dimensional matrices due to the $k^n$ scaling property, which can cause floating-point overflow/underflow in numerical implementations. [Unverified] Exact behavior depends on the specific numerical library and floating-point precision used.
- A near-zero determinant does not by itself precisely quantify how close a matrix is to being singular in a numerically meaningful way; condition number is generally preferred for this purpose. [Inference] This is a widely cited guideline in numerical linear algebra references, though I cannot verify a single universal source for this claim.

**Related Topics**
- Matrix inverse computation (adjugate method, Gauss-Jordan elimination)
- LU decomposition and its use in solving linear systems
- Condition number and numerical stability
- Eigenvalues and their relationship to the determinant (product of eigenvalues)
- Cramer's Rule for solving linear systems
- Jacobian determinants and change of variables in multivariable calculus
- Singular Value Decomposition (SVD) as a more numerically robust alternative to determinant-based analysis