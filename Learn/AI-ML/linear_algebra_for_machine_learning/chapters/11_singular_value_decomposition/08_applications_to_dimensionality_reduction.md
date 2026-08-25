## Applications to Dimensionality Reduction

### Overview

Dimensionality reduction is the process of representing high-dimensional data using fewer dimensions while preserving as much meaningful structure as possible. Linear algebra provides the mathematical foundation for the most widely used linear dimensionality reduction techniques, most of which build directly on eigendecomposition and SVD concepts covered in the prior sections of this material.

### Principal Component Analysis (PCA) — Full Derivation

**Goal:** find a lower-dimensional linear subspace that captures the maximum possible variance in the data.

**Step 1 — Center the data:**

$$X_c = X - \bar{X}$$

where $\bar{X}$ is the mean of each feature (column), subtracted from every row. Centering is a standard, required preprocessing step for PCA as classically defined.

**Step 2 — Compute the covariance matrix:**

$$C = \frac{1}{n-1}X_c^TX_c$$

$C$ is always symmetric positive semi-definite, a standard, provable property of covariance matrices constructed this way.

**Step 3 — Orthogonally diagonalize $C$:**

$$C = Q\Lambda Q^T$$

using the spectral theorem covered earlier in this material, since $C$ is symmetric. The eigenvectors (columns of $Q$) are the **principal components**; the eigenvalues (diagonal of $\Lambda$) represent the variance captured along each principal component direction.

**Step 4 — Project onto the top $k$ components:**

$$X_{\text{reduced}} = X_c Q_k$$

where $Q_k$ contains only the $k$ eigenvectors with the largest eigenvalues. This step is a direct application of the low-rank approximation and Eckart-Young-Mirsky theorem covered earlier, applied specifically to variance-maximizing directions.

### PCA via SVD (Equivalent, Numerically Preferred)

Rather than explicitly forming $C = X_c^TX_c$ (which squares the condition number, as discussed in the SVD computation section), PCA is commonly computed directly via the SVD of the centered data matrix:

$$X_c = U\Sigma V^T$$

Here, $V$'s columns are the principal components (equivalent to $Q$ above), and the eigenvalues of $C$ relate to the singular values by $\lambda_i = \sigma_i^2/(n-1)$. This equivalence is a standard, provable mathematical result, directly following from the SVD-eigendecomposition relationship established in the earlier section on that topic.

### Worked Example

Consider a small centered dataset (already mean-subtracted) with 2 features:

$$X_c = \begin{bmatrix} 2 & 1 \\ 0 & -1 \\ -2 & 0 \end{bmatrix}$$

**Step 1 — Covariance matrix** (using $n-1 = 2$):

$$X_c^TX_c = \begin{bmatrix} 2 & 0 & -2 \\ 1 & -1 & 0 \end{bmatrix}\begin{bmatrix} 2 & 1 \\ 0 & -1 \\ -2 & 0 \end{bmatrix} = \begin{bmatrix} 8 & 2 \\ 2 & 2 \end{bmatrix}$$

$$C = \frac{1}{2}\begin{bmatrix} 8 & 2 \\ 2 & 2 \end{bmatrix} = \begin{bmatrix} 4 & 1 \\ 1 & 1 \end{bmatrix}$$

**Step 2 — Eigenvalues of $C$:**

$$\det(C - \lambda I) = (4-\lambda)(1-\lambda) - 1 = \lambda^2 - 5\lambda + 3 = 0$$

$$\lambda = \frac{5 \pm \sqrt{25-12}}{2} = \frac{5 \pm \sqrt{13}}{2}$$

$$\lambda_1 \approx 4.303, \quad \lambda_2 \approx 0.697$$

**Output**

$$\text{Total variance} = \lambda_1 + \lambda_2 \approx 5.0$$

$$\text{Proportion of variance captured by PC1} = \frac{4.303}{5.0} \approx 0.861$$

The first principal component captures approximately 86.1% of the total variance in this specific example dataset — a direct computation from these exact eigenvalues, not a general property of PCA.

### Table: Common Dimensionality Reduction Techniques

| Method | Linear/Nonlinear | Core Linear Algebra Tool | Preserves |
|---|---|---|---|
| PCA | Linear | Eigendecomposition / SVD of covariance matrix | Maximum variance |
| Truncated SVD | Linear | SVD (no centering required) | Maximum captured "energy" |
| Linear Discriminant Analysis (LDA) | Linear | Generalized eigenvalue problem | Class separability |
| t-SNE | Nonlinear | Not primarily linear-algebra-based | Local neighborhood structure |
| UMAP | Nonlinear | Not primarily linear-algebra-based | Local/global neighborhood structure |

[Unverified] This table lists commonly cited categorizations found in machine learning references. I cannot verify current best-practice recommendations for choosing among these methods for any specific dataset or task without checking current, specific sources, and inclusion here is not a claim that any one method is superior in general.

### PCA vs. Truncated SVD — Practical Distinction

Although mathematically closely related, PCA (as classically defined) requires centering the data first, while truncated SVD can be applied directly to uncentered data. This distinction was noted in the prior section: for sparse data, centering typically destroys sparsity (subtracting a nonzero mean from zero entries makes them nonzero), so [Inference] truncated SVD is often preferred over classical PCA specifically for sparse datasets, for the reasons discussed in that section — this is a reasoned application of the sparsity concepts covered earlier, not a separately confirmed empirical claim made here.

### Geometric Interpretation

PCA can be visualized as finding the rotation of the coordinate axes that aligns them with the directions of maximum spread in the data, then keeping only the axes with the greatest spread and discarding the rest.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 440 260">
  <text x="220" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a2e">PCA: Finding Directions of Maximum Variance (svg_diagram)</text>

  <line x1="220" y1="230" x2="220" y2="50" stroke="#ccc" stroke-width="1" />
  <line x1="90" y1="140" x2="350" y2="140" stroke="#ccc" stroke-width="1" />

  <ellipse cx="220" cy="140" rx="120" ry="45" fill="#bfdbfe" opacity="0.5" transform="rotate(-25 220 140)" />
  <circle cx="160" cy="170" r="3" fill="#1e3a8a" />
  <circle cx="190" cy="155" r="3" fill="#1e3a8a" />
  <circle cx="220" cy="140" r="3" fill="#1e3a8a" />
  <circle cx="250" cy="128" r="3" fill="#1e3a8a" />
  <circle cx="280" cy="112" r="3" fill="#1e3a8a" />
  <circle cx="200" cy="120" r="3" fill="#1e3a8a" />
  <circle cx="240" cy="160" r="3" fill="#1e3a8a" />

  <line x1="140" y1="180" x2="300" y2="100" stroke="#dc2626" stroke-width="2.5" />
  <text x="305" y="95" font-size="10" fill="#dc2626">PC1 (max variance)</text>

  <line x1="195" y1="105" x2="245" y2="175" stroke="#059669" stroke-width="2.5" />
  <text x="250" y="180" font-size="10" fill="#059669">PC2 (orthogonal, less variance)</text>
</svg>

### Reconstruction and Information Loss

Projecting data onto $k < n$ principal components is inherently lossy (unless $k$ equals the original dimensionality and no rank deficiency exists). The reconstruction error is governed by the same Eckart-Young-Mirsky-derived formulas covered in the low-rank approximation section:

$$\text{Reconstruction error (Frobenius)} = \sqrt{\sum_{i=k+1}^{r}\sigma_i^2}$$

This is not a new result but a direct restatement of the earlier theorem in the specific context of PCA/dimensionality reduction.

### Why This Matters for Machine Learning

- **Preprocessing for downstream models**: dimensionality reduction is commonly used to reduce the number of input features before training other models, [Inference] which may reduce computational cost and can help with issues related to the curse of dimensionality — though the actual effect on any specific downstream model's performance depends on the dataset and model, and I cannot verify this improves outcomes in general without testing a specific case.
- **Visualization**: reducing data to 2 or 3 dimensions via PCA is a standard, widely documented technique for visualizing high-dimensional datasets, since human visual perception is limited to a small number of dimensions.
- **Noise reduction**: as discussed in the low-rank approximation section, if noise is spread across many small-variance directions while signal is concentrated in a few high-variance directions, dimensionality reduction can [Inference] reduce noise contribution in the retained lower-dimensional representation — this is a reasoned extension of the earlier noise discussion, not independently confirmed here, and should not be read as a claim that dimensionality reduction removes or eliminates noise in general.
- **Feature engineering in high-dimensional domains**: fields such as genomics, image processing, and text analysis (via the truncated SVD/LSA connection discussed in the prior section) commonly apply dimensionality reduction due to the high native dimensionality of the raw data. [Unverified] I cannot confirm specific current best practices or performance outcomes in any of these specific domains without checking current, specific sources.

I cannot verify performance claims, adoption rates, or implementation-specific behavior of any current software library's dimensionality reduction functions without checking their current, specific documentation directly. Any statement above describing what a technique "can" or "may" do should not be read as a guarantee of that outcome for a specific dataset.

### Key Points

- PCA is derived directly from orthogonal diagonalization of the covariance matrix, or equivalently, from the SVD of the centered data matrix — both are standard, provable equivalences established in earlier sections.
- The choice of retained dimensions $k$ trades off reconstruction fidelity against reduced dimensionality, governed by the same Eckart-Young-Mirsky error formulas as general low-rank approximation.
- Truncated SVD (no centering) is often preferred over classical PCA for sparse data, since centering destroys sparsity.
- PCA and truncated SVD are linear techniques; nonlinear alternatives (t-SNE, UMAP) exist for cases where linear structure does not adequately capture the data's geometry, though those methods rely less directly on the linear algebra concepts covered in this material.

**Related Topics**

- Orthogonal diagonalization and the spectral theorem (direct prerequisite)
- Singular values and singular vectors, and truncated SVD (direct prerequisite)
- Low-rank matrix approximation and the Eckart-Young-Mirsky theorem
- Covariance and correlation matrices
- Linear Discriminant Analysis and generalized eigenvalue problems
- Whitening transformations and decorrelation
- Nonlinear dimensionality reduction methods (t-SNE, UMAP) as a contrast to linear techniques