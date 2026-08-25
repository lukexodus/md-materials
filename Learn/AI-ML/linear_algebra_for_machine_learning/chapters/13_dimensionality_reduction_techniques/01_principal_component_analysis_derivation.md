## Principal Component Analysis Derivation

### Overview

Principal Component Analysis (PCA) is one of the most widely used dimensionality reduction techniques in machine learning, and its mathematical foundation draws directly on the eigen decomposition and SVD concepts covered in prior topics. This section derives PCA from first principles via two equivalent formulations — variance maximization and reconstruction error minimization — before connecting both to the computational methods (eigen decomposition of the covariance matrix, or direct SVD of the data matrix) used in practice.

### Problem Setup

Given a data matrix $X \in \mathbb{R}^{n \times d}$ with $n$ samples and $d$ features, PCA seeks a lower-dimensional representation that preserves as much of the data's variance as possible.

**Key Points**
- Data is first **centered** by subtracting the feature-wise mean, so that $\bar{X} = X - \mathbf{1}\mu^T$ has zero mean along each feature, where $\mu$ is the vector of feature means. Centering is a necessary preprocessing step, since PCA's variance-based formulation implicitly assumes the data is centered at the origin.
- Some formulations also **standardize** each feature to unit variance before applying PCA, which is generally recommended when features are on different scales, since PCA is sensitive to the relative scale of input variables. [Inference: whether standardization is appropriate depends on whether relative feature scale carries meaningful information for the specific application]
- The goal is to find a set of $k \ll d$ orthonormal directions (principal components) that capture the maximum possible variance in the data.

### Formulation 1: Variance Maximization

The first and most common derivation seeks the direction of maximum variance directly.

#### First Principal Component

We seek a unit vector $w_1 \in \mathbb{R}^d$ (with $\|w_1\| = 1$) such that the projected data $\bar{X}w_1$ has maximum variance:

$$\text{Var}(\bar{X}w_1) = \frac{1}{n-1} w_1^T \bar{X}^T \bar{X} w_1 = w_1^T S w_1$$

where $S = \frac{1}{n-1}\bar{X}^T\bar{X}$ is the sample covariance matrix.

This becomes a constrained optimization problem:

$$\max_{w_1} \; w_1^T S w_1 \quad \text{subject to} \quad w_1^Tw_1 = 1$$

**Key Points**
- Using a Lagrange multiplier $\lambda_1$, the constrained optimization problem's stationary points satisfy $Sw_1 = \lambda_1 w_1$, which is precisely the eigenvalue equation for $S$.
- Substituting back into the objective shows that the maximum variance achieved equals $\lambda_1$, meaning the optimal $w_1$ is the eigenvector of $S$ corresponding to the **largest** eigenvalue.
- This directly explains why PCA is computed via eigen decomposition: the first principal component is the dominant eigenvector of the covariance matrix.

#### Subsequent Principal Components

Each subsequent component $w_j$ is found by maximizing variance subject to both the unit-norm constraint and orthogonality to all previously found components:

$$\max_{w_j} \; w_j^T S w_j \quad \text{subject to} \quad w_j^Tw_j = 1, \quad w_j^Tw_i = 0 \; \forall i < j$$

**Key Points**
- Because $S$ is symmetric, the Spectral Theorem (covered in the eigen decomposition topic) guarantees that eigenvectors corresponding to distinct eigenvalues are automatically orthogonal, satisfying the orthogonality constraint naturally rather than requiring it to be separately enforced in most cases.
- The full solution is therefore the complete eigen decomposition of $S = W\Lambda W^T$, with eigenvalues sorted in descending order $\lambda_1 \geq \lambda_2 \geq \dots \geq \lambda_d \geq 0$, and $w_j$ being the eigenvector associated with the $j$-th largest eigenvalue.
- Non-negativity of eigenvalues follows because $S$ is positive semi-definite by construction (it is a sum/average of outer products), consistent with variance being non-negative.

### Formulation 2: Reconstruction Error Minimization

An alternative and complementary derivation frames PCA as finding the $k$-dimensional linear subspace that minimizes reconstruction error when data is projected onto it and mapped back.

For a set of orthonormal basis vectors $W = [w_1, \dots, w_k]$, the reconstruction of a point $x_i$ is $WW^Tx_i$, and the objective is:

$$\min_{W} \sum_{i=1}^{n} \|x_i - WW^Tx_i\|^2 \quad \text{subject to} \quad W^TW = I_k$$

**Key Points**
- This objective can be shown to be algebraically equivalent to the variance maximization formulation: minimizing reconstruction error is equivalent to maximizing the variance captured in the retained subspace, since total variance in the data is fixed and splits between "captured" and "lost" components.
- This equivalence explains why PCA is simultaneously described as "the directions of maximum variance" and "the best linear low-dimensional approximation of the data," which are two views of the same underlying mathematical structure.
- This formulation directly connects to the Eckart-Young theorem from the SVD topic: minimizing reconstruction error under an orthonormal projection is precisely what optimal low-rank approximation via SVD achieves.

### Two Equivalent Computational Routes

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300">
  <text x="400" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Two Paths to PCA (svg_diagram)</text>

  <rect x="60" y="60" width="220" height="50" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="170" y="90" font-size="12" text-anchor="middle" fill="#1a1a1a">Centered data matrix X̄</text>

  <rect x="60" y="150" width="220" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="170" y="175" font-size="12" text-anchor="middle" fill="#1a1a1a">Form S = X̄^T X̄ / (n-1)</text>
  <text x="170" y="193" font-size="12" text-anchor="middle" fill="#1a1a1a">Eigen decompose S</text>

  <rect x="520" y="150" width="220" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="630" y="175" font-size="12" text-anchor="middle" fill="#1a1a1a">Directly compute</text>
  <text x="630" y="193" font-size="12" text-anchor="middle" fill="#1a1a1a">SVD of X̄ = UΣV^T</text>

  <rect x="290" y="250" width="220" height="40" rx="8" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" />
  <text x="400" y="275" font-size="12" text-anchor="middle" fill="#1a1a1a">Same principal components</text>

  <line x1="170" y1="110" x2="170" y2="145" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow5)" />
  <line x1="280" y1="85" x2="630" y2="145" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow5)" />
  <line x1="170" y1="210" x2="360" y2="248" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow5)" />
  <line x1="630" y1="210" x2="440" y2="248" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow5)" />

  </svg>

**Route A: Eigen decomposition of the covariance matrix**

$$S = \frac{1}{n-1}\bar{X}^T\bar{X} = W\Lambda W^T$$

Principal components are columns of $W$; explained variance per component is given directly by $\lambda_i$.

**Route B: Direct SVD of the centered data matrix**

$$\bar{X} = U\Sigma V^T$$

**Key Points**
- Comparing the two routes: since $\bar{X}^T\bar{X} = V\Sigma^TU^TU\Sigma V^T = V\Sigma^2V^T$, it follows that $V$ from the SVD equals $W$ from the eigen decomposition of $S$, and $\lambda_i = \frac{\sigma_i^2}{n-1}$.
- Route B is generally preferred in practice, as established in the prior "choosing the right decomposition" topic, since it avoids explicitly forming $\bar{X}^T\bar{X}$, which squares the condition number of the data and can degrade numerical accuracy, particularly when $d$ is large relative to $n$.
- The projected (transformed) data in $k$ dimensions is given directly by $U_k\Sigma_k$ (the first $k$ columns of $U$ scaled by the first $k$ singular values), avoiding an additional matrix multiplication step that Route A would require ($\bar{X}W_k$).

### Explained Variance and Component Selection

**Key Points**
- The proportion of total variance explained by the $j$-th principal component is $\frac{\lambda_j}{\sum_{i=1}^{d}\lambda_i}$, and cumulative explained variance for the first $k$ components is $\frac{\sum_{i=1}^{k}\lambda_i}{\sum_{i=1}^{d}\lambda_i}$.
- A common heuristic for choosing $k$ is to retain enough components to reach a target cumulative explained variance threshold (e.g., 90% or 95%), though this threshold is a practical convention rather than a universally correct value and should be chosen based on the specific application's tolerance for information loss. [Unverified: the appropriateness of any specific threshold percentage is domain- and task-dependent]
- A **scree plot** (eigenvalues plotted in descending order) is commonly used to visually identify an "elbow" where additional components contribute diminishing explained variance, though identifying this elbow can be subjective in practice.

**Example**

For a dataset with eigenvalues $\lambda = (8.2, 3.1, 1.4, 0.6, 0.2)$, total variance is $13.5$. The first two components explain $\frac{8.2+3.1}{13.5} \approx 76.3\%$ of total variance, which [Inference] may or may not be sufficient depending on the downstream task's tolerance for information loss.

### Derivation Summary Table

| Aspect | Variance Maximization View | Reconstruction Error View |
|---|---|---|
| Objective | Maximize $w^TSw$ | Minimize $\sum_i \|x_i - WW^Tx_i\|^2$ |
| Constraint | $\|w\|=1$, orthogonal to prior components | $W^TW = I_k$ |
| Solution | Top-$k$ eigenvectors of $S$ | Top-$k$ eigenvectors of $S$ (equivalent) |
| Connects to | Eigen decomposition topic | SVD / Eckart-Young topic |
| Intuition | "Capture the most spread" | "Lose the least information" |

### Practical Considerations in the Derivation

**Key Points**
- **Sign ambiguity**: Eigenvectors (and singular vectors) are only determined up to sign; $w_i$ and $-w_i$ are equally valid solutions, meaning the sign of a given principal component's loadings is not inherently meaningful and can vary across implementations or runs.
- **Degenerate eigenvalues**: When two or more eigenvalues are equal (or very close), the corresponding eigenvectors are not uniquely determined, only the subspace they span is; small numerical perturbations can cause the specific directions returned to vary between runs. [Unverified: sensitivity in this scenario depends on the specific numerical algorithm and data]
- **Assumption of linearity**: This derivation assumes the directions of maximum variance are linear subspaces; datasets with strongly nonlinear structure may be poorly represented by PCA regardless of how many components are retained, motivating nonlinear extensions such as kernel PCA or autoencoders.
- **Scale sensitivity**: Because PCA maximizes variance, features with larger numeric scale mechanically dominate the principal components unless standardized first, which can produce misleading results if the original feature scales do not reflect genuine relative importance.

### Conclusion

PCA's derivation reveals it as a direct application of two decompositions studied in this sequence: eigen decomposition of the covariance matrix and SVD of the centered data matrix produce mathematically equivalent principal components, with the variance-maximization and reconstruction-error-minimization perspectives offering complementary justifications for the same underlying eigenvectors. In practice, the SVD route is generally favored for its superior numerical stability, reinforcing the broader theme from the decomposition-selection topic that avoiding explicit formation of $A^TA$-type products is a recurring best practice in applied linear algebra for machine learning.

**Related Topics**
- Kernel PCA and Nonlinear Dimensionality Reduction
- Autoencoders as a Nonlinear Generalization of PCA
- Factor Analysis vs. PCA
- Explained Variance and Scree Plot Interpretation
- Whitening Transformations Using PCA
- Incremental and Online PCA for Streaming Data
- t-SNE and UMAP for Visualization-Oriented Dimensionality Reduction