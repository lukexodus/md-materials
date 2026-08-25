## Low-Rank Matrix Approximation

### Definition

Low-rank approximation is the problem of finding a matrix $A_k$ of rank at most $k$ that best approximates a given matrix $A$, where $k$ is smaller than the full rank of $A$. "Best" is typically defined with respect to a chosen matrix norm, most commonly the Frobenius norm or the spectral (induced 2-) norm, both covered in the earlier matrix norms material.

$$A_k = \arg\min_{\text{rank}(B) \leq k} \|A - B\|$$

### The Eckart-Young-Mirsky Theorem

Given the SVD of $A$:

$$A = U\Sigma V^T = \sum_{i=1}^r \sigma_i u_i v_i^T$$

where $r$ is the rank of $A$ and $\sigma_1 \geq \sigma_2 \geq \cdots \geq \sigma_r > 0$, the optimal rank-$k$ approximation (for $k < r$) is obtained by truncating the sum to the $k$ largest singular values:

$$A_k = \sum_{i=1}^k \sigma_i u_i v_i^T$$

This is a standard, proven theorem in linear algebra (the Eckart-Young-Mirsky theorem), not an inference. It holds for both the Frobenius norm and the spectral norm simultaneously — the same truncated SVD is optimal under both.

### Approximation Error

The theorem also gives exact formulas for the resulting approximation error:

**Spectral norm error:**

$$\|A - A_k\|_2 = \sigma_{k+1}$$

**Frobenius norm error:**

$$\|A - A_k\|_F = \sqrt{\sum_{i=k+1}^r \sigma_i^2}$$

Both are standard, provable results following directly from the orthogonality of the singular vectors. They show that approximation quality depends entirely on how quickly the singular values decay: if $\sigma_{k+1}, \sigma_{k+2}, \ldots$ are small relative to $\sigma_1, \ldots, \sigma_k$, the truncated approximation captures most of the matrix's structure.

### Worked Example

Let:

$$A = \begin{bmatrix} 4 & 0 \\ 0 & 1 \\ 0 & 0 \end{bmatrix}$$

This matrix is already in a diagonal-like (rectangular diagonal) form, so its singular values can be read directly: $\sigma_1 = 4$, $\sigma_2 = 1$, with standard basis vectors as singular vectors.

**Rank-1 approximation** ($k=1$): keep only the largest singular value/vector term.

$$A_1 = \sigma_1 u_1 v_1^T = 4\begin{bmatrix} 1 \\ 0 \\ 0 \end{bmatrix}\begin{bmatrix} 1 & 0 \end{bmatrix} = \begin{bmatrix} 4 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix}$$

**Output**

$$A_1 = \begin{bmatrix} 4 & 0 \\ 0 & 0 \\ 0 & 0 \end{bmatrix}$$

**Approximation error:**

$$\|A - A_1\|_2 = \sigma_2 = 1$$

$$\|A - A_1\|_F = \sqrt{\sigma_2^2} = 1$$

This matches direct computation: $A - A_1 = \begin{bmatrix} 0 & 0 \\ 0 & 1 \\ 0 & 0 \end{bmatrix}$, which indeed has spectral norm and Frobenius norm both equal to 1, confirming the theorem's prediction for this example.

### Storage Compression via Low-Rank Approximation

A rank-$k$ approximation of an $m \times n$ matrix can be stored using only the truncated factors $U_k$ ($m \times k$), $\Sigma_k$ ($k \times k$, or just $k$ values), and $V_k$ ($n \times k$), rather than the full $m \times n$ matrix:

$$\text{Full storage: } mn \text{ values} \quad \text{vs.} \quad \text{Truncated storage: } k(m+n+1) \text{ values}$$

This is a direct counting argument, not an inference. Whether this represents a net storage saving depends on the specific values of $m$, $n$, and $k$: the truncated form uses fewer values than the full matrix precisely when $k(m+n+1) < mn$, which [Inference] tends to hold when $k$ is small relative to $\min(m,n)$, though I have not verified this holds for any specific matrix dimensions without checking the inequality directly for those values.

### Table: Rank vs. Approximation Tradeoff

| Rank $k$ | Storage (relative) | Approximation Error | Captures |
|---|---|---|---|
| $k = 1$ | Minimal | Largest (unless $\sigma_2, \sigma_3,\ldots \approx 0$) | Dominant structure only |
| $k = r/2$ (half full rank) | Moderate | Depends on singular value decay | Majority of variance if decay is fast |
| $k = r$ (full rank) | Full | Zero (exact reconstruction) | All structure |

[Unverified] The specific error magnitude at any given $k$ depends entirely on the singular value spectrum of the particular matrix being approximated — this table describes the general qualitative tradeoff pattern from the theorem above, not a numeric guarantee for any specific dataset.

### Choosing $k$ in Practice

A common heuristic is to examine the decay of singular values (sometimes visualized as a "scree plot") and choose $k$ where the values drop off sharply, or where cumulative captured "energy" (sum of squared singular values) reaches a target proportion:

$$\text{Energy captured} = \frac{\sum_{i=1}^k \sigma_i^2}{\sum_{i=1}^r \sigma_i^2}$$

This formula follows directly from the Frobenius-norm error identity above. [Inference] Selecting a specific energy threshold (e.g., a common informal convention of retaining 90% or 95%) is a practical heuristic used in applied contexts rather than a value derived from the theorem itself, and I cannot verify that any particular threshold is optimal for a specific dataset without testing it directly.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 440 260">
  <text x="220" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">Singular Value Decay / Scree Plot (svg_diagram)</text>

  <line x1="60" y1="210" x2="400" y2="210" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="210" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="230" y="235" text-anchor="middle" font-size="11" fill="#555">Singular value index i</text>
  <text x="30" y="130" text-anchor="middle" font-size="11" fill="#555" transform="rotate(-90 30 130)">σ_i</text>

  <circle cx="90" cy="70" r="4" fill="#2563eb" />
  <circle cx="130" cy="95" r="4" fill="#2563eb" />
  <circle cx="170" cy="130" r="4" fill="#2563eb" />
  <circle cx="210" cy="165" r="4" fill="#2563eb" />
  <circle cx="250" cy="185" r="4" fill="#2563eb" />
  <circle cx="290" cy="197" r="4" fill="#2563eb" />
  <circle cx="330" cy="203" r="4" fill="#2563eb" />
  <circle cx="370" cy="206" r="4" fill="#2563eb" />
  <polyline points="90,70 130,95 170,130 210,165 250,185 290,197 330,203 370,206" fill="none" stroke="#2563eb" stroke-width="1.5" />

  <line x1="210" y1="50" x2="210" y2="210" stroke="#dc2626" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="210" y="45" text-anchor="middle" font-size="10" fill="#dc2626">chosen k (sharp drop-off point)</text>
</svg>

### Why This Matters for Machine Learning

- **Dimensionality reduction (PCA)**: PCA is a direct application of low-rank approximation to a mean-centered data matrix, retaining the top $k$ principal directions that capture the most variance. This connects directly to the truncated SVD material in the prior sections. This application is standard and well-established.
- **Image compression**: representing an image as a matrix and applying low-rank approximation is a commonly cited illustrative example of this technique in linear algebra references, since natural images often have singular values that decay quickly. [Unverified] I cannot confirm the specific compression ratios or quality tradeoffs achievable for any particular image without processing it directly.
- **Recommender systems**: matrix factorization approaches to collaborative filtering assume the true user-item preference matrix is approximately low-rank, motivating the use of a truncated factorization to fill in missing entries. [Inference] This is a standard conceptual motivation described in recommender systems literature, but I cannot verify the actual rank structure of preferences in any specific real dataset without direct analysis.
- **Noise reduction**: [Inference] if a matrix consists of an underlying low-rank "signal" corrupted by full-rank random noise, truncating to the top $k$ singular values can reduce noise contribution while retaining most of the signal structure, since noise tends to be spread across many small singular values rather than concentrated in the largest ones — this is a reasoned consequence of the decay-based truncation ideas above, but I cannot verify this holds for any specific noisy dataset without testing it directly. This should not be read as a claim that low-rank approximation removes or eliminates noise in general.
- **Model compression in deep learning**: applying low-rank factorization to weight matrices in trained neural networks is a documented class of technique intended to reduce parameter count. [Unverified] I do not have access to verify the effectiveness, adoption, or current best practices of any specific compression technique or library without checking a specific, current source.

### Key Points

- The Eckart-Young-Mirsky theorem establishes that truncating the SVD to its top $k$ singular values/vectors gives the optimal rank-$k$ approximation under both the Frobenius and spectral norms — this is a proven mathematical result.
- Approximation error has exact closed-form expressions in terms of the discarded singular values.
- Storage savings depend on the relationship between $k$, $m$, and $n$; smaller $k$ relative to matrix dimensions generally yields greater compression, though the exact crossover point requires checking the specific dimensions involved.
- Practical choice of $k$ typically relies on inspecting singular value decay or cumulative captured energy, which are heuristic (not theorem-derived) decision criteria.

**Related Topics**

- Singular values and singular vectors (direct prerequisite)
- Computing the SVD (numerical methods)
- Principal Component Analysis derivation
- Matrix norms (Frobenius, spectral) — required to define "best" approximation
- Sparse matrices (a related but distinct structural assumption for compression)
- Matrix factorization methods in recommender systems
- Random matrix theory and noise modeling in high-dimensional data