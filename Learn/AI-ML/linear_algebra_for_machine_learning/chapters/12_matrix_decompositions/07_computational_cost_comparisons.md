## Computational Cost Comparisons

### Overview

Building on the qualitative decision framework from the prior topic, this section provides a rigorous, quantitative treatment of computational cost across QR, eigen decomposition, and SVD. It covers asymptotic complexity, memory footprint, the impact of matrix structure (sparse, symmetric, low-rank), and how these costs manifest in real machine learning workloads at scale.

### Asymptotic Complexity Summary

For an $m \times n$ matrix (assume $m \geq n$ unless noted), the dominant computational costs are:

| Decomposition | Method | Flop Count (approx.) | Notes |
|---|---|---|---|
| QR | Householder | $2mn^2 - \frac{2}{3}n^3$ | Standard dense algorithm |
| QR | Modified Gram-Schmidt | $2mn^2$ | Similar order, different constant |
| QR | Givens Rotations | $O(mn^2)$, higher constant | More expensive per-operation but sparse-friendly |
| Eigen decomposition | Symmetric (QR algorithm / divide-and-conquer) | $O(n^3)$, typically $\frac{4}{3}n^3$ to $9n^3$ | Depends on whether eigenvectors are also needed |
| Eigen decomposition | Non-symmetric (general) | $O(n^3)$, typically $10n^3$ to $25n^3$ | Higher constant due to Hessenberg reduction + QR iteration |
| SVD | Full (Golub-Kahan) | $O(mn^2)$ to $O(mn \cdot \min(m,n))$ | Roughly $4mn^2 + 8n^3$ for $m \geq n$ |
| SVD | Thin/reduced | Lower than full, same asymptotic order | Avoids computing unneeded columns of $U$ |

[Unverified: exact flop constants vary across textbooks and implementations; figures above reflect commonly cited approximations and should be treated as order-of-magnitude guidance rather than precise benchmarks]

**Key Points**
- All three decompositions share the same fundamental asymptotic order, $O(n^3)$ for square matrices, meaning cost scales cubically with matrix dimension in the general dense case.
- The differences between decompositions lie primarily in the constant factor multiplying $n^3$, not the asymptotic order itself, so for very large $n$, all three eventually become expensive in a similar qualitative sense.
- SVD is generally the most expensive of the three per matrix element processed, since it typically involves an iterative refinement phase (bidiagonalization followed by iterative diagonalization) beyond a single triangularization step.

### Why Symmetric Matrices Are Cheaper

**Key Points**
- Symmetric eigenvalue algorithms exploit the structure of $A = A^T$ to roughly halve the storage and computation compared to general non-symmetric eigen decomposition, since only the upper or lower triangle needs to be processed in intermediate steps.
- The tridiagonalization step (reducing a symmetric matrix to tridiagonal form before iterative eigenvalue extraction) is significantly cheaper than the Hessenberg reduction required for general non-symmetric matrices.
- This is a key reason SVD of a data matrix $X$ is often preferred over eigen decomposition of $X^TX$ in PCA: even though $X^TX$ is symmetric and thus cheaper to decompose per-element than a general matrix, forming $X^TX$ itself costs $O(mn^2)$ flops and, more importantly, squares the condition number, which is a stability rather than a pure cost concern. [Fact, cost tradeoff is well documented; stability caveat reiterated from prior topic]

### Memory Footprint Comparison

| Decomposition | Storage Required (dense, $m \times n$, $m \geq n$) |
|---|---|
| QR (thin) | $Q$: $mn$, $R$: $\frac{n(n+1)}{2}$ (upper triangular) |
| Eigen decomposition (symmetric) | $V$: $n^2$, $\Lambda$: $n$ (diagonal only needs storing) |
| Eigen decomposition (general) | $V$: $n^2$ (possibly complex), $\Lambda$: $n$ (possibly complex) |
| SVD (thin) | $U$: $mn$ (or $mr$), $\Sigma$: $\min(m,n)$, $V$: $n^2$ (or $nr$) |
| SVD (truncated rank-$k$) | $U$: $mk$, $\Sigma$: $k$, $V$: $nk$ |

**Key Points**
- Truncated SVD offers the most favorable memory scaling for large, high-dimensional data when only a low-rank approximation is needed, since storage scales linearly with $k$ rather than with the full matrix dimensions.
- For very large $m$ (e.g., millions of samples) with modest $n$ (features), thin QR and thin SVD avoid the $O(m^2)$ storage blowup that full-form $U$ or $Q$ would otherwise require.
- Complex-valued storage for non-symmetric eigen decomposition (when eigenvalues are complex) roughly doubles memory requirements compared to the real symmetric case, an often-overlooked cost consideration. [Inference: doubling is an approximation based on typical complex-number storage as two floats; actual overhead depends on implementation]

### Impact of Matrix Structure on Cost

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300">
  <text x="400" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Cost Reduction from Matrix Structure (svg_diagram)</text>

  <rect x="60" y="60" width="150" height="180" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="135" y="260" font-size="12" text-anchor="middle" fill="#1a1a1a">Dense, general</text>
  <text x="135" y="276" font-size="11" text-anchor="middle" fill="#5f6368">Baseline O(n^3)</text>

  <rect x="250" y="60" width="150" height="130" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="325" y="260" font-size="12" text-anchor="middle" fill="#1a1a1a">Symmetric</text>
  <text x="325" y="276" font-size="11" text-anchor="middle" fill="#5f6368">~half the constant</text>

  <rect x="440" y="60" width="150" height="80" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="515" y="260" font-size="12" text-anchor="middle" fill="#1a1a1a">Sparse</text>
  <text x="515" y="276" font-size="11" text-anchor="middle" fill="#5f6368">Scales with nonzeros</text>

  <rect x="630" y="60" width="150" height="40" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="705" y="260" font-size="12" text-anchor="middle" fill="#1a1a1a">Low-rank (k ≪ n)</text>
  <text x="705" y="276" font-size="11" text-anchor="middle" fill="#5f6368">Scales with k, not n</text>

  <text x="400" y="55" font-size="11" fill="#5f6368" text-anchor="middle">(bar height represents relative computational cost)</text>
</svg>

**Key Points**
- **Sparse matrices**: When $A$ has few nonzero entries, specialized sparse decomposition algorithms (e.g., sparse QR, Lanczos-based eigenvalue/SVD methods) scale with the number of nonzeros rather than $O(n^3)$, offering substantial savings for structured data like graph adjacency matrices or one-hot encoded features. [Inference: actual speedup magnitude depends heavily on sparsity pattern and chosen algorithm]
- **Low-rank matrices**: If $A$ is known or assumed to have low intrinsic rank $k \ll n$, randomized SVD algorithms can compute an approximate decomposition in roughly $O(mnk)$ time rather than $O(mn^2)$, a substantial saving when $k$ is small relative to matrix dimensions.
- **Banded and structured matrices**: Matrices with special structure (banded, block-diagonal, Toeplitz) admit specialized algorithms that can reduce cost below the general dense case, though such structure is less commonly present in raw machine learning data matrices and more common in specific model formulations (e.g., time-series covariance structures).

### Randomized Algorithms: A Practical Cost Reduction

**Key Points**
- Randomized SVD (e.g., the Halko-Martinsson-Tropp algorithm) approximates the top-$k$ singular values/vectors by projecting the matrix onto a random low-dimensional subspace first, then performing a much smaller exact decomposition, reducing typical cost from $O(mn^2)$ to approximately $O(mnk + k^2(m+n))$.
- This approach trades exactness for speed: the resulting approximation is generally very close to the true truncated SVD for matrices with rapidly decaying singular values, but accuracy can degrade for matrices without a clear low-rank structure. [Unverified: accuracy degradation extent depends on singular value decay profile and oversampling parameters used]
- Similar randomized or iterative ideas (e.g., Lanczos iteration for top eigenvalues, randomized range finders) extend to eigen decomposition and QR-related tasks, particularly relevant when only a few dominant components are needed rather than the full decomposition — a common scenario in PCA with a small target dimensionality.

### Cost in Realistic Machine Learning Contexts

**Key Points**
- **PCA on high-dimensional data** (e.g., $n = 10{,}000$ features): Computing full SVD directly can be prohibitively expensive; practitioners typically use truncated or randomized SVD targeting only the first few dozen or hundred components, since downstream use (visualization, dimensionality reduction) rarely requires the full spectrum.
- **Least squares in large-scale regression**: When $m$ (samples) is very large but $n$ (features) is modest, thin QR decomposition costs scale linearly in $m$ ($O(mn^2)$), making it tractable even for datasets with millions of rows, provided $n$ remains small to moderate.
- **Spectral clustering on large graphs**: Computing all eigenvalues of a graph Laplacian is often infeasible for large graphs; iterative methods (Lanczos) targeting only the smallest few eigenvalues are used instead, since spectral clustering typically only requires a small number of leading eigenvectors.
- **Recommender systems at scale**: Exact SVD on a full user-item matrix (potentially millions by millions) is generally impractical; stochastic gradient descent-based matrix factorization or randomized SVD variants are used as more scalable alternatives. [Inference: the specific choice between these alternatives depends on system constraints such as update frequency requirements and available parallelism]

### Practical Cost-Reduction Heuristics

**Key Points**
- Prefer **thin/reduced forms** over full forms whenever the extra basis vectors (null space directions) are not needed, since this avoids unnecessary computation and storage without any loss of relevant information.
- Exploit **symmetry** whenever present by using dedicated symmetric solvers rather than general-purpose routines, since this roughly halves computational cost for eigen decomposition.
- Use **truncated or randomized methods** when only a small number of leading components (top singular values/eigenvalues) are needed, rather than computing the full decomposition and discarding most of it afterward.
- Consider **sparse-aware algorithms** whenever the matrix has significant sparsity, since general dense routines ignore this structure and waste computation on known-zero entries.
- Be cautious about premature optimization: for small to moderate matrix sizes common in many applied ML tasks (e.g., $n$ in the hundreds), the cost differences between decompositions are often negligible in absolute wall-clock time, and correctness/stability should typically take priority over micro-optimizing decomposition choice. [Inference: this is a general engineering heuristic rather than a strict rule, and thresholds vary by application latency requirements]

### Conclusion

While QR, eigen decomposition, and SVD share the same cubic asymptotic order for dense square matrices, their practical costs diverge significantly based on matrix symmetry, sparsity, target rank, and whether full or reduced forms are used. In realistic machine learning settings, the dominant cost-saving strategies are exploiting symmetry, using thin or truncated forms, and adopting randomized or iterative algorithms when only partial spectral information is required — considerations that often matter more in practice than the underlying decomposition choice itself.

**Related Topics**
- Randomized Numerical Linear Algebra in Depth
- Lanczos and Arnoldi Iteration for Partial Spectra
- Sparse Matrix Storage Formats and Algorithms
- GPU-Accelerated Linear Algebra for Large-Scale ML
- Stochastic Gradient Descent-Based Matrix Factorization
- Benchmarking Numerical Libraries: LAPACK, MKL, and cuSOLVER
- Out-of-Core and Distributed Decomposition Algorithms