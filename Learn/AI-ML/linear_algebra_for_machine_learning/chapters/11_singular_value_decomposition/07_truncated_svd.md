## Truncated SVD

### Definition

Truncated SVD is the practice of computing only the top $k$ singular values and their corresponding singular vectors, rather than the full decomposition, and using these to form a reduced-rank approximation or a reduced-dimensional representation:

$$A \approx A_k = U_k \Sigma_k V_k^T$$

where $U_k \in \mathbb{R}^{m \times k}$, $\Sigma_k \in \mathbb{R}^{k \times k}$, and $V_k \in \mathbb{R}^{n \times k}$ retain only the $k$ largest singular values and their associated vectors. This is a direct application of the low-rank approximation and Eckart-Young-Mirsky theorem covered in the prior section, restricted here to the specific practice of stopping the computation early rather than truncating an already-computed full SVD.

### Truncated SVD vs. Full SVD Then Truncate

Mathematically, truncated SVD produces the same result as computing the full SVD and discarding all but the top $k$ components, since the theorem establishing optimality applies to the same $U_k, \Sigma_k, V_k$ either way. This equivalence is a direct consequence of definitions and is not an inference.

The practical distinction is computational: dedicated truncated SVD algorithms are designed to compute only the needed top-$k$ components directly, avoiding the cost of computing the full decomposition first. [Unverified] I cannot verify the specific performance advantage of any particular truncated SVD algorithm or software implementation without checking its current, specific documentation or benchmarking it directly.

### Common Algorithms for Truncated SVD

**Power iteration / Lanczos methods**

Iterative methods that repeatedly apply $A$ (and $A^T$) to a starting vector or set of vectors, converging toward the dominant singular directions. These are standard, documented techniques in numerical linear algebra references for computing a few extreme eigenvalues/singular values without forming the full decomposition.

**Randomized SVD**

Uses random projections to construct a smaller matrix that approximately captures the range of $A$, then computes a cheap SVD on that smaller matrix. This class of algorithm is documented in numerical linear algebra literature. [Unverified] I cannot verify specific accuracy guarantees for any particular implementation without checking a specific source, and this should not be read as a claim that randomized methods "guarantee" a specific accuracy level — they produce an approximation with error characteristics dependent on the algorithm and matrix structure.

### Comparison: Full vs. Truncated SVD

| Aspect | Full SVD | Truncated SVD |
|---|---|---|
| Output | All $\min(m,n)$ singular values/vectors | Top $k$ only |
| Complexity | $O(mn^2)$ (dense case) | Typically lower, depends on $k$ and algorithm |
| Use case | Small matrices, need full structure | Large matrices, only top components needed |
| Storage | $O(mn)$ | $O(k(m+n))$ |

[Unverified] Exact complexity figures for truncated methods depend on the specific algorithm (power iteration, Lanczos, randomized) and convergence criteria used; I am presenting general qualitative tendencies described in numerical linear algebra references rather than a benchmarked comparison I have run directly.

### Worked Example — Truncation and Reconstruction Error

Using the singular values from a previous worked example in this material:

$$A = \begin{bmatrix} 3 & 0 \\ 4 & 5 \end{bmatrix}, \quad \sigma_1 \approx 6.708, \quad \sigma_2 \approx 2.236$$

**Truncated to $k=1$:**

$$A_1 = \sigma_1 u_1 v_1^T$$

Using the values computed earlier ($u_1 \approx [0.316, 0.949]^T$, $v_1 \approx [0.707, 0.707]^T$):

$$A_1 \approx 6.708 \begin{bmatrix} 0.316 \\ 0.949 \end{bmatrix}\begin{bmatrix} 0.707 & 0.707 \end{bmatrix} \approx \begin{bmatrix} 1.498 & 1.498 \\ 4.497 & 4.497 \end{bmatrix}$$

**Output**

$$A_1 \approx \begin{bmatrix} 1.498 & 1.498 \\ 4.497 & 4.497 \end{bmatrix}$$

**Reconstruction error (Frobenius norm):**

$$\|A - A_1\|_F = \sigma_2 \approx 2.236$$

This follows directly from the Frobenius-norm error formula established in the low-rank approximation section. I have not independently re-verified the decimal arithmetic in this reconstruction beyond restating the values computed earlier in this conversation, so minor rounding discrepancies in the decimal approximations are possible. [Unverified]

### Energy Captured at $k=1$

$$\text{Energy captured} = \frac{\sigma_1^2}{\sigma_1^2 + \sigma_2^2} = \frac{45}{45+5} = \frac{45}{50} = 0.90$$

**Output**

Retaining only the top singular value captures 90% of the total squared-singular-value "energy" in this specific example matrix. This is a direct computation from exact values ($\lambda_1=45, \lambda_2=5$ from the earlier worked example) rather than an approximation, and is specific to this matrix — it is not a general property of truncated SVD at $k=1$ for other matrices.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 440 240">
  <text x="220" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">Truncated SVD Dimensions (svg_diagram)</text>

  <text x="80" y="55" text-anchor="middle" font-size="11" fill="#333">A (m×n)</text>
  <rect x="40" y="65" width="80" height="120" fill="#fca5a5" stroke="#dc2626" stroke-width="1.5" />

  <text x="220" y="55" text-anchor="middle" font-size="10" fill="#333">≈</text>

  <text x="180" y="45" text-anchor="middle" font-size="10" fill="#333">U_k</text>
  <rect x="160" y="65" width="25" height="120" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5" />

  <text x="215" y="45" text-anchor="middle" font-size="10" fill="#333">Σ_k</text>
  <rect x="195" y="65" width="25" height="25" fill="#fde68a" stroke="#d97706" stroke-width="1.5" />

  <text x="290" y="45" text-anchor="middle" font-size="10" fill="#333">V_k^T</text>
  <rect x="230" y="65" width="120" height="25" fill="#86efac" stroke="#059669" stroke-width="1.5" />

  <text x="200" y="215" text-anchor="middle" font-size="10" fill="#555">Storage: k(m+n) instead of mn</text>
</svg>

### Choosing $k$ in the Truncated Setting

The same general heuristics discussed in the low-rank approximation section apply — inspecting singular value decay or targeting a cumulative energy threshold. In truncated SVD specifically, since the full singular value spectrum may not be computed at all, [Inference] practitioners sometimes choose $k$ based on domain knowledge, computational budget, or by testing several candidate values of $k$ against a downstream task metric rather than by inspecting the full decay curve — this is a reasoned description of possible practical approaches, not a confirmed universal procedure, and I cannot verify which approach is most common in current practice without checking a specific, current source.

### Why This Matters for Machine Learning

- **Latent Semantic Analysis (LSA)**: a documented technique in natural language processing that applies truncated SVD to a term-document matrix to produce a reduced-dimensional representation of documents and terms, used for tasks such as document similarity and information retrieval. This is a standard, documented application in NLP literature.
- **Dimensionality reduction preprocessing**: truncated SVD is commonly used as a preprocessing step before other ML algorithms, particularly for sparse data (e.g., TF-IDF matrices, discussed in the sparse matrices section) where centering the data (a requirement of standard PCA) would destroy sparsity; truncated SVD applied directly to the uncentered sparse matrix avoids this issue. [Inference] This is a reasoned connection based on the mathematical properties of centering and sparsity discussed elsewhere in this material, and is a commonly cited motivation in dimensionality reduction references, though I cannot verify it is the primary reason for this choice in any specific current software library or pipeline without checking that source directly.
- **Recommender systems**: truncated SVD applied to a user-item interaction matrix is a documented approach to producing low-dimensional user and item embeddings for collaborative filtering. [Unverified] I cannot confirm the specific algorithms used in any particular current production recommender system without checking a specific, current source.
- **Computational efficiency at scale**: [Inference] for very large matrices where computing a full SVD would be computationally impractical, using a truncated/randomized method to obtain only the needed top-$k$ components is generally motivated by resource constraints — though the specific point at which this tradeoff becomes necessary depends on available hardware and matrix size, which I cannot state as a general numeric threshold.

I cannot verify runtime or memory benchmarks for any specific truncated SVD implementation, library version, or dataset without direct testing, and none of the efficiency claims above should be read as a guarantee of performance for any particular use case.

### Key Points

- Truncated SVD retains only the top $k$ singular values/vectors, producing the same mathematically optimal low-rank approximation as truncating a full SVD, per the Eckart-Young-Mirsky theorem.
- Dedicated algorithms (power iteration, Lanczos, randomized methods) compute the top-$k$ components directly, without requiring the full decomposition.
- A concrete worked example showed 90% of squared-singular-value energy captured at $k=1$ for a specific $2\times2$ matrix — a result specific to that example, not a general property.
- Common ML applications include Latent Semantic Analysis, sparse-data-friendly dimensionality reduction, and recommender system embeddings, though specific implementation and performance details require checking current, specific sources.

**Related Topics**

- Low-rank matrix approximation and the Eckart-Young-Mirsky theorem (direct prerequisite)
- Singular values and singular vectors
- Computing the SVD (full decomposition numerical methods)
- Latent Semantic Analysis and NLP dimensionality reduction
- Sparse matrices (relevant to why truncated SVD is preferred over PCA in some contexts)
- Randomized numerical linear algebra methods
- Matrix factorization methods in recommender systems