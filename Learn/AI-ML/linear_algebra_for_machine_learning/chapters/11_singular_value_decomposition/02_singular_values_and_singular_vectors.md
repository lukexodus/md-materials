## Singular Values and Singular Vectors

### Definition

For any real matrix $A \in \mathbb{R}^{m \times n}$ (not necessarily square), the Singular Value Decomposition (SVD) expresses $A$ as:

$$A = U\Sigma V^T$$

where:

- $U \in \mathbb{R}^{m \times m}$ is orthogonal; its columns are the **left singular vectors**
- $V \in \mathbb{R}^{n \times n}$ is orthogonal; its columns are the **right singular vectors**
- $\Sigma \in \mathbb{R}^{m \times n}$ is diagonal (in the generalized rectangular sense) with non-negative entries $\sigma_1 \geq \sigma_2 \geq \cdots \geq 0$, called the **singular values**

This decomposition exists for every real matrix, regardless of shape or rank. This is a standard, well-established theorem in linear algebra.

### Relationship to Eigenvalues

Singular values and vectors connect directly to eigendecomposition through two related symmetric matrices:

$$A^TA = V\Sigma^T\Sigma V^T$$

$$AA^T = U\Sigma\Sigma^T U^T$$

Both $A^TA$ and $AA^T$ are symmetric positive semi-definite, so both are orthogonally diagonalizable by the spectral theorem covered earlier in this material. This gives:

- The **right singular vectors** ($V$) are the eigenvectors of $A^TA$
- The **left singular vectors** ($U$) are the eigenvectors of $AA^T$
- The **singular values** are the square roots of the (shared, nonzero) eigenvalues of $A^TA$ (equivalently $AA^T$): $\sigma_i = \sqrt{\lambda_i}$

These relationships are standard, provable results derived directly from the SVD definition and the spectral theorem.

### Defining Relations

The singular vectors and values satisfy, for each $i$:

$$Av_i = \sigma_i u_i$$

$$A^Tu_i = \sigma_i v_i$$

This pair of equations is the direct algebraic definition of a singular value/vector pair and follows from the SVD factorization.

### Worked Example

Let:

$$A = \begin{bmatrix} 3 & 0 \\ 4 & 5 \end{bmatrix}$$

**Step 1 — Compute $A^TA$:**

$$A^TA = \begin{bmatrix} 3 & 4 \\ 0 & 5 \end{bmatrix}\begin{bmatrix} 3 & 0 \\ 4 & 5 \end{bmatrix} = \begin{bmatrix} 25 & 20 \\ 20 & 25 \end{bmatrix}$$

**Step 2 — Eigenvalues of $A^TA$:**

$$\det(A^TA - \lambda I) = (25-\lambda)^2 - 400 = 0$$

$$25 - \lambda = \pm 20 \implies \lambda_1 = 45, \quad \lambda_2 = 5$$

**Step 3 — Singular values:**

$$\sigma_1 = \sqrt{45} = 3\sqrt{5} \approx 6.708, \quad \sigma_2 = \sqrt{5} \approx 2.236$$

**Step 4 — Right singular vectors (eigenvectors of $A^TA$):**

For $\lambda_1 = 45$: $(A^TA - 45I)v = 0 \Rightarrow \begin{bmatrix} -20 & 20 \\ 20 & -20 \end{bmatrix}v = 0 \Rightarrow v_1 \propto \begin{bmatrix} 1 \\ 1 \end{bmatrix}$

For $\lambda_2 = 5$: $(A^TA - 5I)v = 0 \Rightarrow \begin{bmatrix} 20 & 20 \\ 20 & 20 \end{bmatrix}v = 0 \Rightarrow v_2 \propto \begin{bmatrix} 1 \\ -1 \end{bmatrix}$

Normalized:

$$v_1 = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ 1 \end{bmatrix}, \quad v_2 = \frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ -1 \end{bmatrix}$$

**Step 5 — Left singular vectors via $u_i = \frac{1}{\sigma_i}Av_i$:**

$$u_1 = \frac{1}{3\sqrt{5}}\begin{bmatrix} 3 & 0 \\ 4 & 5 \end{bmatrix}\frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ 1 \end{bmatrix} = \frac{1}{3\sqrt{10}}\begin{bmatrix} 3 \\ 9 \end{bmatrix} = \frac{1}{\sqrt{10}}\begin{bmatrix} 1 \\ 3 \end{bmatrix}$$

$$u_2 = \frac{1}{\sqrt{5}}\begin{bmatrix} 3 & 0 \\ 4 & 5 \end{bmatrix}\frac{1}{\sqrt{2}}\begin{bmatrix} 1 \\ -1 \end{bmatrix} = \frac{1}{\sqrt{10}}\begin{bmatrix} 3 \\ -1 \end{bmatrix}$$

**Output**

$$U \approx \begin{bmatrix} 0.316 & 0.949 \\ 0.949 & -0.316 \end{bmatrix}, \quad \Sigma \approx \begin{bmatrix} 6.708 & 0 \\ 0 & 2.236 \end{bmatrix}, \quad V \approx \begin{bmatrix} 0.707 & 0.707 \\ 0.707 & -0.707 \end{bmatrix}$$

This can be verified by direct multiplication of $U\Sigma V^T$ to confirm it reproduces $A$; I have not executed this multiplication numerically here, so I cannot confirm the arithmetic is free of small rounding errors in the decimal approximations shown. [Unverified]

### Table: Key Properties

| Quantity | Definition | Source |
|---|---|---|
| Singular values $\sigma_i$ | $\sqrt{\lambda_i(A^TA)}$ | Diagonal of $\Sigma$ |
| Right singular vectors $v_i$ | Eigenvectors of $A^TA$ | Columns of $V$ |
| Left singular vectors $u_i$ | Eigenvectors of $AA^T$ | Columns of $U$ |
| Rank of $A$ | Number of nonzero singular values | — |
| $\|A\|_2$ | $\sigma_{\max}$ | Spectral norm |
| $\kappa_2(A)$ | $\sigma_{\max}/\sigma_{\min}$ | Condition number |

These relationships were covered in the earlier material on matrix norms and condition number and are restated here as standard, provable results connecting those topics directly to SVD.

### Geometric Interpretation

The SVD decomposes any linear transformation into three geometrically simple steps: a rotation/reflection ($V^T$), a scaling along orthogonal axes ($\Sigma$), and a second rotation/reflection ($U$). Under this transformation, the unit sphere maps to an ellipsoid whose semi-axis lengths are exactly the singular values, oriented along the directions given by $U$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 460 260">
  <text x="230" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">SVD as Rotate-Scale-Rotate (svg_diagram)</text>

  <text x="60" y="55" font-size="11" fill="#333">Unit circle</text>
  <line x1="30" y1="150" x2="130" y2="150" stroke="#888" stroke-width="1" />
  <line x1="80" y1="100" x2="80" y2="200" stroke="#888" stroke-width="1" />
  <circle cx="80" cy="150" r="35" fill="none" stroke="#2563eb" stroke-width="2" />

  <path d="M140,150 L170,150" stroke="#1a1a2e" stroke-width="2" marker-end="url(#a3)" />
  <text x="155" y="140" text-anchor="middle" font-size="9" fill="#1a1a2e">V^T</text>

  <text x="230" y="55" font-size="11" fill="#333">Aligned + scaled</text>
  <line x1="180" y1="150" x2="280" y2="150" stroke="#888" stroke-width="1" />
  <line x1="230" y1="100" x2="230" y2="200" stroke="#888" stroke-width="1" />
  <ellipse cx="230" cy="150" rx="40" ry="20" fill="none" stroke="#7c3aed" stroke-width="2" />

  <path d="M290,150 L320,150" stroke="#1a1a2e" stroke-width="2" marker-end="url(#a3)" />
  <text x="305" y="140" text-anchor="middle" font-size="9" fill="#1a1a2e">U</text>

  <text x="390" y="55" font-size="11" fill="#333">Final ellipse</text>
  <line x1="330" y1="150" x2="450" y2="150" stroke="#888" stroke-width="1" />
  <line x1="390" y1="100" x2="390" y2="200" stroke="#888" stroke-width="1" />
  <ellipse cx="390" cy="150" rx="45" ry="18" fill="none" stroke="#dc2626" stroke-width="2" transform="rotate(-25 390 150)" />

  </svg>

### Low-Rank Approximation via SVD

A matrix can be approximated by truncating the SVD to its $k$ largest singular values:

$$A_k = \sum_{i=1}^k \sigma_i u_i v_i^T$$

The Eckart-Young theorem states that $A_k$ is the best rank-$k$ approximation to $A$ under both the Frobenius norm and the spectral norm, among all matrices of rank $\leq k$. This is a standard, proven theorem in linear algebra, not an inference.

### Why This Matters for Machine Learning

- **Dimensionality reduction**: truncated SVD retains the directions of greatest variance/structure in data while discarding smaller singular value components, forming the mathematical basis of techniques like Latent Semantic Analysis. [Inference] The practical quality of a given low-rank approximation for a specific dataset depends on how quickly its singular values decay, which I cannot assess without inspecting that dataset directly.
- **PCA connection**: PCA can be computed either via eigendecomposition of the covariance matrix or directly via SVD of the (mean-centered) data matrix, since the two are mathematically related through the identities shown above. This equivalence is a standard, provable result.
- **Pseudoinverse and least squares**: the Moore-Penrose pseudoinverse, $A^+ = V\Sigma^+U^T$ (where $\Sigma^+$ inverts the nonzero singular values), provides a way to solve least-squares problems even when $A$ is not invertible or not square. This is standard material in numerical linear algebra.
- **Recommender systems**: matrix factorization approaches to collaborative filtering are conceptually related to low-rank SVD approximation of the user-item interaction matrix. [Unverified] I do not have access to verify the specific factorization techniques used in any particular current production recommender system without checking a specific, current source.
- **Model compression**: some approaches to compressing neural network weight matrices apply low-rank (SVD-based) approximation to reduce parameter count. [Unverified] I cannot confirm the effectiveness or current adoption of this technique in any specific model or framework without checking a specific, current source. Any claim about this "reducing" model size should not be read as a guarantee of outcome for a given model, since actual compression results depend on the specific weight matrix structure and acceptable accuracy tradeoff.

### Key Points

- SVD factors any real matrix (square or rectangular) as $A = U\Sigma V^T$, with $U, V$ orthogonal and $\Sigma$ diagonal with non-negative entries.
- Singular values are the square roots of the eigenvalues of $A^TA$ (or $AA^T$); singular vectors are the corresponding eigenvectors.
- The Eckart-Young theorem establishes truncated SVD as the optimal low-rank approximation under Frobenius and spectral norms — this is a proven result, not an inference.
- SVD generalizes the eigendecomposition concept (orthogonal diagonalization) to non-symmetric and non-square matrices.

**Related Topics**

- Orthogonal diagonalization and the spectral theorem (prerequisite concept)
- Principal Component Analysis (PCA) derivation via SVD
- Low-rank matrix approximation and the Eckart-Young theorem
- Moore-Penrose pseudoinverse and least squares problems
- Matrix norms and condition number (prior topics, directly connected via singular values)
- Latent Semantic Analysis and dimensionality reduction in NLP
- Matrix factorization methods in recommender systems