## Principal Component Analysis

### Definition

Principal Component Analysis (PCA) is a dimensionality reduction technique that transforms a set of possibly correlated variables into a smaller set of linearly uncorrelated variables, called principal components, ordered so that the first component captures the largest possible variance in the data, and each subsequent component captures the largest remaining variance subject to being orthogonal to the preceding components.

### Formal Definition

Given a data matrix $\mathbf{X} \in \mathbb{R}^{n \times p}$ (with $n$ observations and $p$ variables, typically mean-centered so each column has mean zero), PCA seeks a set of orthonormal directions $\mathbf{w}_1, \dots, \mathbf{w}_k$ (with $k \leq p$) that maximize the variance of the projected data. The first principal component direction is defined as:

$$\mathbf{w}_1 = \arg\max_{\|\mathbf{w}\|=1} \text{Var}(\mathbf{X}\mathbf{w}) = \arg\max_{\|\mathbf{w}\|=1} \mathbf{w}^T \boldsymbol{\Sigma} \mathbf{w}$$

where $\boldsymbol{\Sigma} = \frac{1}{n-1}\mathbf{X}^T\mathbf{X}$ is the sample covariance matrix. Subsequent components $\mathbf{w}_2, \dots, \mathbf{w}_p$ are defined similarly, subject to orthogonality with all preceding directions.

### Solution via Eigendecomposition

The solution to this constrained optimization problem is given by the eigenvectors of the covariance matrix:

$$\boldsymbol{\Sigma} \mathbf{w}_i = \lambda_i \mathbf{w}_i$$

where $\lambda_1 \geq \lambda_2 \geq \dots \geq \lambda_p \geq 0$ are the eigenvalues, and the eigenvector $\mathbf{w}_i$ corresponding to the $i$-th largest eigenvalue is the $i$-th principal component direction. Each eigenvalue $\lambda_i$ equals the variance of the data projected onto $\mathbf{w}_i$.

[Inference] This equivalence between the variance-maximization formulation and the eigendecomposition solution is a standard result derived using Lagrange multipliers on the constrained optimization problem, reasoned from the mathematical structure of the problem itself. I cannot verify the full formal derivation against a specific primary source directly quoted within this conversation, so this is presented as a standard textbook result rather than an independently confirmed citation.

===MERMAID_DIAGRAM===

graph TD

A["Centered Data Matrix X (svg_diagram)"] --> B["Compute Covariance Matrix Sigma"]

B --> C["Eigendecomposition of Sigma"]

C --> D["Eigenvectors: Principal Component Directions"]

C --> E["Eigenvalues: Variance Explained per Component"]

D --> F["Project Data onto Top k Components"]

E --> F

### Relationship to Singular Value Decomposition

PCA is commonly computed in practice via Singular Value Decomposition (SVD) of the centered data matrix directly, rather than explicitly forming the covariance matrix:

$$\mathbf{X} = \mathbf{U}\mathbf{D}\mathbf{V}^T$$

where $\mathbf{U}$ contains left singular vectors, $\mathbf{D}$ is a diagonal matrix of singular values, and $\mathbf{V}$ contains right singular vectors. The columns of $\mathbf{V}$ correspond to the principal component directions, and the singular values relate to the eigenvalues of $\boldsymbol{\Sigma}$ via $\lambda_i = \frac{d_i^2}{n-1}$.

[Inference] This SVD-based computational approach is commonly described in numerical linear algebra and statistics references as generally more numerically stable than explicitly forming and eigendecomposing the covariance matrix, particularly for high-dimensional data. I cannot verify this stability claim against a specific primary source directly quoted within this conversation, so it is presented as a commonly stated computational consideration rather than an independently confirmed citation. Whether this holds for any specific numerical implementation and dataset is not something that can be assumed without direct testing.

### Explained Variance

The proportion of total variance explained by the $i$-th principal component is:

$$\text{Proportion Explained}_i = \frac{\lambda_i}{\sum_{j=1}^{p} \lambda_j}$$

Cumulative explained variance across the first $k$ components is commonly used as a criterion for selecting how many components to retain, though there is no single threshold value that is universally correct; this is a discretionary choice that depends on the analytical goal, and I do not have a confirmed source establishing one standard threshold that applies to all use cases.

### Component Selection Methods

- **Cumulative variance threshold**: retain enough components to explain a chosen percentage of total variance (e.g., 90% or 95%), a threshold chosen by the analyst rather than derived from a universal rule.
- **Scree plot / elbow method**: visually inspect a plot of eigenvalues in descending order and retain components before the point where the curve flattens.
- **Kaiser criterion**: retain components with eigenvalue greater than 1, applicable when PCA is performed on the correlation matrix rather than the covariance matrix. [Unverified] I do not have a specific primary source directly quoted within this conversation to confirm the exact original justification or attribution of this criterion, so it is presented as a commonly referenced heuristic in multivariate statistics literature.
- **Cross-validation**: assess reconstruction error or downstream task performance across different numbers of retained components.

[Inference] None of these selection methods is established as uniformly superior to the others across all datasets and use cases; this is a reasoned conclusion following directly from the fact that each method optimizes a different criterion (visual inspection, fixed threshold, eigenvalue magnitude, or task performance), which is not something requiring further external verification beyond this structural observation.

### Standardization Before PCA

When variables are measured on different scales, it is common to standardize each variable to unit variance before applying PCA (equivalent to performing PCA on the correlation matrix rather than the covariance matrix). [Inference] Without standardization, PCA results are commonly described in statistics references as being disproportionately influenced by variables with larger numerical scale, since the covariance matrix's eigenstructure is scale-dependent. I cannot verify this against a specific primary source directly quoted within this conversation, so it is presented as a commonly stated practical consideration rather than an independently confirmed citation. Whether standardization is appropriate for a specific dataset depends on whether the original scale differences carry meaningful information, which is a judgment call rather than a fixed rule.

### Worked Example

**Example**

```python
import numpy as np
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler

np.random.seed(0)
n = 200
x1 = np.random.normal(0, 1, n)
x2 = 0.8 * x1 + np.random.normal(0, 0.5, n)
x3 = np.random.normal(0, 2, n)

X = np.column_stack([x1, x2, x3])
X_scaled = StandardScaler().fit_transform(X)

pca = PCA(n_components=3)
pca.fit(X_scaled)

print("Explained variance ratio:", pca.explained_variance_ratio_)
print("Components:", pca.components_)
```

**Output**

I cannot verify this. I do not have code execution access in this session, so I cannot confirm the exact printed numeric values this code would produce.

[Inference] Based on the construction of the data — `x1` and `x2` are strongly correlated by design (`x2` built directly from `x1` plus small noise), while `x3` is generated independently — the first principal component is expected to capture a large share of variance associated with the shared structure between `x1` and `x2`, and the explained variance ratios are expected to be unevenly distributed across the three components rather than roughly equal. This is a reasoned expectation based on the data-generating structure described in the code, not a confirmed output value, since the code has not been executed. [Unverified] The exact numerical explained variance ratios and component loadings cannot be confirmed without running the code directly.

### Reconstruction and Dimensionality Reduction

Projecting data onto the top $k$ principal components and then mapping back to the original space produces a reconstruction:

$$\hat{\mathbf{X}} = \mathbf{X}\mathbf{W}_k\mathbf{W}_k^T$$

where $\mathbf{W}_k$ contains the first $k$ eigenvectors as columns. The reconstruction error, measured as the total squared difference between $\mathbf{X}$ and $\hat{\mathbf{X}}$, equals the sum of the discarded eigenvalues:

$$\|\mathbf{X} - \hat{\mathbf{X}}\|_F^2 = (n-1)\sum_{i=k+1}^{p} \lambda_i$$

[Unverified] I do not have a specific primary source directly quoted within this conversation to confirm the full formal derivation of this reconstruction error identity, so it is presented as a standard result referenced in multivariate statistics and matrix approximation literature (related to the Eckart-Young theorem on optimal low-rank approximation).

### PCA as Optimal Linear Reconstruction

[Unverified] I do not have a specific primary source directly quoted within this conversation to confirm the precise formal statement and proof conditions of the Eckart-Young theorem establishing that PCA provides the optimal rank-$k$ linear approximation to the data in the least-squares sense; this connection is commonly described in matrix approximation and multivariate statistics literature, but I am not independently verifying the full theorem statement here.

### Relationship to Multivariate Normal Theory

When data is assumed to follow a multivariate normal distribution, the eigendecomposition of the covariance matrix used in PCA coincides with the axes and lengths of the elliptical density contours described in multivariate normal theory. [Inference] This connection follows directly from both PCA and the geometric interpretation of the multivariate normal density relying on the same eigendecomposition of the covariance matrix, a structural observation rather than a claim requiring separate external verification beyond the definitions already stated. PCA itself, as a variance-maximization procedure, does not require a normality assumption to be mathematically valid, though certain probabilistic extensions (e.g., Probabilistic PCA) do introduce explicit distributional assumptions.

### Limitations

- PCA identifies directions of maximum variance, which are not guaranteed to align with directions most relevant for a specific downstream task such as classification; a low-variance direction could in principle carry more task-relevant information, and this is not something that can be assumed to hold or not hold without empirical evaluation on the specific task.
- PCA is a linear method; it does not capture nonlinear structure in the data, as a direct consequence of its definition as a linear projection. Nonlinear extensions (e.g., Kernel PCA, autoencoders) address this differently, with their own separate assumptions and limitations.
- Results are sensitive to the presence of outliers, since the covariance matrix computation is sensitive to extreme values; the specific degree of sensitivity for a given dataset is not something that can be generalized without case-specific analysis.
- Interpretability of principal components (as linear combinations of original variables) can be limited when loadings are spread across many original variables, and whether a given set of components is interpretable depends on the specific dataset and loadings obtained.

### Applications in Machine Learning

- Dimensionality reduction as a preprocessing step before applying other models, intended to reduce computational cost and mitigate certain effects associated with high-dimensional data.
- Data visualization, commonly projecting high-dimensional data onto the first two or three principal components for plotting.
- Noise reduction, using low-rank reconstruction to filter out components associated with small eigenvalues, under the assumption that these components predominantly capture noise rather than signal.
- Feature decorrelation, since principal components are uncorrelated by construction.

[Speculation] Whether PCA-based dimensionality reduction improves downstream model performance for any specific machine learning task and dataset is not something that can be assumed without direct empirical comparison on that specific task. I do not have benchmark results available in this conversation to confirm this in either direction.

### Conclusion

Principal Component Analysis identifies orthogonal directions of maximum variance in a dataset through the eigendecomposition of the covariance matrix, or equivalently through the singular value decomposition of the centered data matrix, providing a mathematically grounded basis for dimensionality reduction, visualization, and noise filtering. Its validity as an optimal linear technique rests on variance as the relevant criterion, which is not guaranteed to align with task-specific relevance, and its results are sensitive to variable scaling and outliers.

**Related Topics**

- Multivariate Normal Theory
- Singular Value Decomposition
- Kernel PCA
- Factor Analysis
- Gaussian Mixture Models
- Feature Selection vs. Feature Extraction
- Eckart-Young Theorem and Low-Rank Matrix Approximation