## PCA via SVD

### Overview

Principal Component Analysis (PCA) is a dimensionality reduction technique that finds orthogonal directions of maximum variance in data. While PCA is often introduced via the eigendecomposition of a covariance matrix, computing it through Singular Value Decomposition (SVD) is the numerically preferred method in practice, since it avoids explicitly forming the covariance matrix and is more stable for ill-conditioned data.

### Prerequisite Concepts

- $Singular Value Decomposition (SVD)$: factorization of any matrix into orthogonal and diagonal components
- $Eigendecomposition$: factorization of a square matrix into eigenvectors and eigenvalues
- $Variance$ and $covariance$: measures of spread and joint variability
- $Orthogonality$: perpendicularity of vectors, meaning zero dot product

### Problem Setup

Given a data matrix $X \in \mathbb{R}^{n \times d}$, where $n$ is the number of samples and $d$ is the number of features, PCA seeks a lower-dimensional representation that retains as much variance as possible.

**Step 1: Center the data**

$$X_c = X - \bar{X}$$

where $\bar{X}$ is the row vector of column-wise means, broadcast across all $n$ rows. Centering is required because PCA measures variance around the mean; skipping this step produces directions dominated by the mean offset rather than true spread.

**Step 2: Relation to covariance**

The (biased) covariance matrix of the centered data is:

$$C = \frac{1}{n} X_c^T X_c$$

Classical PCA finds the eigenvectors of $C$. However, forming $C$ explicitly squares the condition number of the data, which can amplify numerical errors — this is the core motivation for using SVD directly on $X_c$ instead.

### The SVD Formulation

The Singular Value Decomposition of the centered data matrix is:

$$X_c = U \Sigma V^T$$

where:
- $U \in \mathbb{R}^{n \times n}$ is orthogonal; its columns are the left singular vectors
- $\Sigma \in \mathbb{R}^{n \times d}$ is diagonal (rectangular diagonal), containing non-negative singular values $\sigma_1 \geq \sigma_2 \geq \dots \geq 0$
- $V \in \mathbb{R}^{d \times d}$ is orthogonal; its columns are the right singular vectors

**Key Points**
- The columns of $V$ are the **principal component directions** (the same vectors obtained from eigendecomposing $C$)
- The singular values relate to the eigenvalues of $C$ by $\lambda_i = \frac{\sigma_i^2}{n}$ (or $n-1$ for the unbiased estimator)
- The projected data (PCA scores) can be computed as $X_c V$, which simplifies to $U\Sigma$
- SVD works directly on $X_c$, so $C$ never needs to be formed explicitly

### Why SVD Is Preferred Over Eigendecomposition of the Covariance Matrix

| Aspect | Eigendecomposition of $C$ | SVD of $X_c$ |
|---|---|---|
| Numerical stability | Lower (condition number squared) | Higher |
| Memory for large $d$ | Requires forming $d \times d$ matrix | Not required |
| Computational cost | $O(nd^2 + d^3)$ | $O(\min(nd^2, n^2d))$ |
| Handles $n < d$ efficiently | Less naturally | More naturally |

[Inference] For very high-dimensional, low-sample datasets (e.g., genomics, where $d \gg n$), SVD-based approaches are generally favored in practice because they avoid instantiating a large, poorly conditioned covariance matrix, though exact performance depends on implementation and hardware.

### Deriving Principal Components from SVD

Starting from $X_c = U\Sigma V^T$, substitute into the covariance matrix:

$$C = \frac{1}{n} X_c^T X_c = \frac{1}{n} (U\Sigma V^T)^T (U\Sigma V^T) = \frac{1}{n} V \Sigma^T U^T U \Sigma V^T$$

Since $U^T U = I$ (orthogonality):

$$C = \frac{1}{n} V \Sigma^T \Sigma V^T = V \Lambda V^T$$

where $\Lambda = \frac{\Sigma^T \Sigma}{n}$ is diagonal, containing the eigenvalues $\lambda_i = \frac{\sigma_i^2}{n}$.

This confirms that $V$ (from SVD) contains the same eigenvectors as those obtained from eigendecomposing $C$ directly, without ever computing $C$.

### Projecting Data onto Principal Components

To reduce dimensionality from $d$ to $k$ components:

1. Select the first $k$ columns of $V$, denoted $V_k \in \mathbb{R}^{d \times k}$
2. Project: $Z = X_c V_k \in \mathbb{R}^{n \times k}$

Equivalently, using the SVD factors directly:

$$Z = U_k \Sigma_k$$

where $U_k$ and $\Sigma_k$ contain the first $k$ columns/singular values.

### Explained Variance

The proportion of total variance captured by the first $k$ components is:

$$\text{Explained Variance Ratio} = \frac{\sum_{i=1}^{k} \sigma_i^2}{\sum_{i=1}^{d} \sigma_i^2}$$

This ratio is commonly used to choose $k$ — for example, selecting the smallest $k$ such that cumulative explained variance exceeds a threshold like 95%. [Inference] The 95% threshold is a common heuristic rather than a universal rule; appropriate thresholds vary by application and downstream task sensitivity.

### Diagram: PCA via SVD Pipeline

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 260">
  <text x="450" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">PCA via SVD Pipeline (svg_diagram)</text>

  <rect x="20" y="60" width="140" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="90" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Raw Data</text>
  <text x="90" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">X (n × d)</text>

  <line x1="160" y1="90" x2="200" y2="90" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="200" y="60" width="140" height="60" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="270" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Center Data</text>
  <text x="270" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">X_c = X − mean</text>

  <line x1="340" y1="90" x2="380" y2="90" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="380" y="60" width="140" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="450" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Apply SVD</text>
  <text x="450" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">X_c = UΣVᵀ</text>

  <line x1="520" y1="90" x2="560" y2="90" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="560" y="60" width="150" height="60" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="635" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Select Top k</text>
  <text x="635" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">V_k, Σ_k</text>

  <line x1="710" y1="90" x2="750" y2="90" stroke="#5f6368" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="750" y="60" width="130" height="60" rx="6" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" />
  <text x="815" y="85" font-size="13" text-anchor="middle" fill="#1a1a1a">Projected Data</text>
  <text x="815" y="102" font-size="12" text-anchor="middle" fill="#1a1a1a">Z = U_kΣ_k</text>

  <text x="450" y="160" font-size="12" text-anchor="middle" fill="#5f6368">Singular values σ_i ranked by magnitude determine variance contribution per component</text>
  <text x="450" y="185" font-size="12" text-anchor="middle" fill="#5f6368">Explained variance ratio = Σσᵢ² (top k) / Σσᵢ² (all)</text>

  </svg>

### Worked Example

Consider a small dataset with $n = 4$ samples and $d = 2$ features:

$$X = \begin{bmatrix} 2 & 0 \\ 0 & 2 \\ -2 & 0 \\ 0 & -2 \end{bmatrix}$$

**Step 1 — Center:** The column means are $(0, 0)$, so $X_c = X$ (already centered).

**Step 2 — Apply SVD:** For this symmetric, balanced dataset, the SVD yields singular values $\sigma_1 = \sigma_2 = 2\sqrt{2}$ [Unverified — exact numeric values depend on solver convention; sign and ordering of singular vectors are not unique], with right singular vectors aligned along the diagonals of the coordinate system due to the symmetry of the data.

**Step 3 — Select components:** Since $\sigma_1 = \sigma_2$, both directions capture equal variance — this dataset has no dominant direction, so dimensionality reduction to $k=1$ would discard 50% of the variance.

**Interpretation:** This example illustrates a degenerate case where PCA provides no compression benefit, useful for building intuition about when PCA is and is not effective.

### Practical Implementation Notes

- Most numerical libraries (e.g., NumPy, SciPy, scikit-learn) compute PCA internally via SVD rather than eigendecomposition, precisely for the stability reasons described above [Unverified — exact internal implementation details may vary by library version]
- Sign ambiguity: SVD does not guarantee a consistent sign for singular vectors across different runs or implementations; this does not affect the subspace spanned but can affect interpretability of individual component signs
- For $n < d$ (more features than samples), computing the "thin" or "economy" SVD is typically more efficient than the full SVD
- Standardization (scaling features to unit variance) prior to PCA is often necessary when features have different units or scales, since PCA is sensitive to the relative magnitude of feature variances

### Common Pitfalls

- Forgetting to center the data before applying SVD, which conflates variance with mean offset
- Applying PCA to unscaled features with heterogeneous units, causing high-variance features to dominate the components regardless of their actual importance
- Assuming principal components are inherently interpretable — they are linear combinations of original features and do not always correspond to meaningful real-world concepts
- Treating explained variance ratio as a guarantee of downstream model performance; high variance capture does not eliminate the possibility that discarded components contained task-relevant signal [Inference]

### Conclusion

Computing PCA via SVD provides the same principal components and projections as covariance-matrix eigendecomposition, but with better numerical properties and efficiency, particularly for high-dimensional or ill-conditioned data. This equivalence — $V$ from SVD matching the eigenvectors of $C$, and $\sigma_i^2/n$ matching the eigenvalues — is the mathematical bridge that makes SVD the standard practical route to PCA.

**Related Topics**
- Truncated SVD and randomized SVD for large-scale data
- Whitening transformations using PCA
- Kernel PCA for nonlinear dimensionality reduction
- Relationship between PCA and Linear Discriminant Analysis (LDA)
- Choosing the number of components via scree plots and cross-validation
- PCA for data compression and noise reduction
- Connections between SVD, PCA, and low-rank matrix approximation (Eckart–Young theorem)