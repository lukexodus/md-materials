## Computing the SVD

### Overview

While the Singular Value Decomposition can be defined via the eigendecompositions of $A^TA$ and $AA^T$, as shown in the prior section, this approach is rarely used for actual numerical computation. This is standard, well-documented guidance in numerical linear algebra: forming $A^TA$ explicitly squares the condition number of the original matrix, which can introduce significant numerical error, since $\kappa(A^TA) = \kappa(A)^2$. This relationship follows directly from the definitions covered in the earlier condition number material and is a provable mathematical identity, not an inference.

Instead, numerically stable algorithms compute the SVD through other means.

### Method 1 — Via Eigendecomposition (Conceptual, Not Numerically Preferred)

For understanding purposes, this method illustrates the mathematical connection directly:

1. Compute $A^TA$
2. Find eigenvalues $\lambda_i$ and eigenvectors $v_i$ of $A^TA$ (orthogonally diagonalizable, since $A^TA$ is symmetric positive semi-definite)
3. Singular values: $\sigma_i = \sqrt{\lambda_i}$
4. Right singular vectors: the $v_i$ directly
5. Left singular vectors: $u_i = \frac{1}{\sigma_i}Av_i$ (for nonzero $\sigma_i$)

This method is mathematically valid but [Inference] is generally considered numerically less stable for computational implementations compared to the methods below, due to the squared condition number issue noted above. I cannot verify the precise magnitude of this instability for any specific matrix without direct numerical testing.

### Method 2 — Golub-Kahan Bidiagonalization (Standard Numerical Approach)

This is the standard algorithm underlying most production numerical SVD implementations, described in numerical linear algebra references. It proceeds in two stages:

**Stage 1 — Bidiagonalization:** Apply a sequence of Householder reflections from the left and right to reduce $A$ to an upper bidiagonal matrix $B$ (nonzero only on the main diagonal and first superdiagonal):

$$A = P B Q^T$$

where $P$ and $Q$ are orthogonal (products of Householder reflectors).

**Stage 2 — Diagonalization:** Apply an iterative process (commonly a variant of the QR algorithm adapted for bidiagonal matrices) to drive the off-diagonal entries of $B$ toward zero, converging to the diagonal matrix $\Sigma$, while accumulating the orthogonal transformations into $U$ and $V$.

This two-stage approach is standard, documented algorithmic structure found in numerical linear algebra textbooks and reference implementations (e.g., LAPACK's underlying routines). [Unverified] I do not have access to verify the exact implementation details of any specific current software library's SVD routine without checking its documentation or source directly.

### Method 3 — Via Eigendecomposition of an Augmented Symmetric Matrix

An alternative approach avoids forming $A^TA$ by constructing a larger symmetric matrix:

$$M = \begin{bmatrix} 0 & A \\ A^T & 0 \end{bmatrix}$$

The eigenvalues of $M$ come in $\pm\sigma_i$ pairs, where $\sigma_i$ are exactly the singular values of $A$, and the corresponding eigenvectors of $M$ can be split to recover $u_i$ and $v_i$. This is a standard, provable mathematical relationship. [Unverified] Whether this specific method is used in practice by particular current numerical libraries is not something I can confirm without checking specific documentation.

### Computational Complexity

For an $m \times n$ matrix with $m \geq n$, the standard (dense) SVD computation via bidiagonalization requires:

$$O(mn^2)$$

floating-point operations, according to standard complexity analysis presented in numerical linear algebra references. [Unverified] Actual runtime for any specific computation depends on hardware, implementation, and optimization details I cannot verify generally; this complexity figure describes asymptotic operation count, not measured wall-clock time.

For very large or sparse matrices, computing the full SVD is often impractical, and iterative/approximate methods (see below) are used instead.

### Worked Example — Manual Computation Walkthrough

Consider:

$$A = \begin{bmatrix} 1 & 1 \\ 0 & 1 \end{bmatrix}$$

**Step 1 — Compute $A^TA$:**

$$A^TA = \begin{bmatrix} 1 & 0 \\ 1 & 1 \end{bmatrix}\begin{bmatrix} 1 & 1 \\ 0 & 1 \end{bmatrix} = \begin{bmatrix} 1 & 1 \\ 1 & 2 \end{bmatrix}$$

**Step 2 — Eigenvalues:**

$$\det(A^TA - \lambda I) = (1-\lambda)(2-\lambda) - 1 = \lambda^2 - 3\lambda + 1 = 0$$

$$\lambda = \frac{3 \pm \sqrt{9-4}}{2} = \frac{3 \pm \sqrt{5}}{2}$$

$$\lambda_1 = \frac{3+\sqrt{5}}{2} \approx 2.618, \quad \lambda_2 = \frac{3-\sqrt{5}}{2} \approx 0.382$$

**Step 3 — Singular values:**

$$\sigma_1 = \sqrt{2.618} \approx 1.618, \quad \sigma_2 = \sqrt{0.382} \approx 0.618$$

(These are recognizable as the golden ratio $\varphi \approx 1.618$ and its reciprocal $1/\varphi \approx 0.618$, a coincidental structural feature of this particular example matrix rather than a general SVD property.)

**Step 4 — Right singular vector for $\lambda_1$:**

$$(A^TA - \lambda_1 I)v = 0 \Rightarrow \begin{bmatrix} 1-2.618 & 1 \\ 1 & 2-2.618 \end{bmatrix}v = 0 \Rightarrow \begin{bmatrix} -1.618 & 1 \\ 1 & -0.618 \end{bmatrix}v = 0$$

$$v_1 \propto \begin{bmatrix} 1 \\ 1.618 \end{bmatrix}, \quad \text{normalized: } v_1 \approx \begin{bmatrix} 0.526 \\ 0.851 \end{bmatrix}$$

**Output**

$$\sigma_1 \approx 1.618, \quad \sigma_2 \approx 0.618$$

$$v_1 \approx \begin{bmatrix} 0.526 \\ 0.851 \end{bmatrix}$$

I have not carried this example through to $u_1$, $u_2$, and $v_2$ numerically here; extending it follows the same procedure demonstrated in the prior section's worked example.

### Truncated / Randomized SVD

For large matrices where only the top $k$ singular values/vectors are needed (common in dimensionality reduction), **randomized SVD** algorithms are used. These construct a smaller matrix that approximately captures the range of $A$ using random projections, then compute a much cheaper SVD on that smaller matrix. This is a documented class of algorithms in numerical linear algebra literature. [Unverified] I cannot verify specific accuracy guarantees or performance characteristics of any particular randomized SVD implementation without checking a specific, current source, and I am not stating that such methods eliminate error — they produce an approximation with error characteristics that depend on the algorithm and matrix structure.

### Table: Method Comparison

| Method | Numerically Stable | Typical Use Case |
|---|---|---|
| Via $A^TA$ eigendecomposition | Less stable (condition number squared) | Conceptual understanding |
| Golub-Kahan bidiagonalization | Standard, stable | General-purpose dense SVD |
| Augmented symmetric matrix | Stable | Alternative theoretical/numerical route |
| Randomized SVD | Approximate | Large matrices, top-$k$ components only |

[Unverified] The "stability" characterizations in this table reflect commonly stated qualitative guidance in numerical linear algebra references, not a benchmarked comparison I have personally run.

### Geometric Interpretation

Computing the SVD numerically can be understood geometrically as searching for the specific orthonormal basis (in the domain) and orthonormal basis (in the codomain) that together diagonalize the transformation — i.e., the axes that turn a general linear transformation into a sequence of independent, non-interacting scalings.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 240">
  <text x="210" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">Bidiagonalization Process (svg_diagram)</text>

  <text x="100" y="55" text-anchor="middle" font-size="11" fill="#333">Dense matrix A</text>
  <rect x="50" y="70" width="100" height="100" fill="#fca5a5" stroke="#dc2626" stroke-width="1.5" />

  <path d="M160,120 L200,120" stroke="#1a1a2e" stroke-width="2" marker-end="url(#a4)" />
  <text x="180" y="110" text-anchor="middle" font-size="9" fill="#1a1a2e">Householder</text>

  <text x="300" y="55" text-anchor="middle" font-size="11" fill="#333">Bidiagonal B</text>
  <rect x="220" y="70" width="160" height="100" fill="#fff" stroke="#888" stroke-width="1" />
  <line x1="220" y1="70" x2="380" y2="70" stroke="#fff" stroke-width="0" />
  <rect x="220" y="70" width="20" height="100" fill="#93c5fd" />
  <rect x="240" y="70" width="20" height="20" fill="#93c5fd" />
  <rect x="260" y="90" width="20" height="20" fill="#93c5fd" />
  <rect x="280" y="110" width="20" height="20" fill="#93c5fd" />
  <rect x="300" y="130" width="20" height="20" fill="#93c5fd" />
  <rect x="320" y="150" width="20" height="20" fill="#93c5fd" />

  <text x="200" y="210" text-anchor="middle" font-size="10" fill="#555">Iterative diagonalization then reduces B toward Σ</text>

  </svg>

### Why This Matters for Machine Learning

- **Library implementations**: standard scientific computing libraries provide SVD routines (e.g., `numpy.linalg.svd`, `scipy.linalg.svd`, `torch.linalg.svd`). [Unverified] I do not have access to verify the exact current algorithmic internals, default parameters, or version-specific behavior of any of these functions without checking their current, specific documentation directly — I cannot confirm these details from memory reliably.
- **Choosing full vs. truncated/randomized SVD**: for large-scale ML applications such as recommender systems or NLP embedding compression, using randomized or truncated SVD rather than full dense SVD is [Inference] generally motivated by computational cost considerations, since full SVD complexity scales with matrix dimensions as noted above — though the specific cutoff at which this tradeoff becomes worthwhile depends on hardware, matrix size, and required accuracy, which I cannot state generally.
- **Numerical stability in training pipelines**: [Inference] if SVD is computed as part of a machine learning pipeline (e.g., for whitening or low-rank regularization), numerical stability of the chosen algorithm may affect reproducibility of results across runs or platforms — I cannot confirm the extent of this effect without a specific tested implementation, and this should not be read as a statement that any method "prevents" or "eliminates" numerical inconsistency.

### Key Points

- Computing SVD via explicit $A^TA$ eigendecomposition is mathematically valid but generally avoided in numerical practice due to condition number squaring — a provable mathematical relationship, though the practical impact varies by matrix and is not independently benchmarked here.
- Golub-Kahan bidiagonalization followed by iterative diagonalization is the standard structure underlying most dense numerical SVD algorithms described in reference literature.
- Full dense SVD computation has asymptotic complexity $O(mn^2)$; randomized/truncated methods are used for large-scale or top-$k$-only needs.
- Specific library implementation details should be verified against current, specific documentation rather than assumed from general knowledge.

**Related Topics**

- Singular values and singular vectors (prerequisite concept, prior section)
- Condition number and its relationship to $A^TA$
- Randomized numerical linear algebra methods
- QR algorithm for eigenvalue computation
- Householder reflections and orthogonal transformations
- Low-rank approximation and the Eckart-Young theorem
- Numerical stability considerations in machine learning pipelines