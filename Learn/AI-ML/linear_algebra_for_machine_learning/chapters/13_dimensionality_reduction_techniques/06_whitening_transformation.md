## Whitening Transformation

### Overview

Whitening is a linear transformation that decorrelates the components of a random vector or dataset and rescales them to have unit variance. When built on top of PCA, whitening produces a representation where all output features are uncorrelated and equally scaled — a property useful for numerical conditioning, certain optimization algorithms, and preprocessing for models sensitive to feature scale.

### Prerequisite Concepts

- $PCA$ via $SVD$ (eigenvectors, singular values, projections)
- $Covariance matrix$ and its diagonalization
- $Identity matrix$ and the concept of an isotropic (spherical) distribution
- Matrix inversion and square roots of diagonal matrices

### The Goal of Whitening

Given centered data $X_c \in \mathbb{R}^{n \times d}$ with covariance matrix $C$, whitening seeks a linear transformation $W$ such that the transformed data $Z = X_c W$ has covariance equal to the identity matrix:

$$\text{Cov}(Z) = I$$

This means every transformed feature has unit variance, and all pairs of transformed features are uncorrelated (covariance of zero between any pair).

**Key Points**
- Whitening removes both correlation between features and differences in feature scale simultaneously
- It is distinct from standardization (z-scoring), which only removes scale differences per feature independently and does not address correlation between features
- The name "whitening" derives from the analogy to white noise, which has a flat, uncorrelated spectrum

### Deriving the Whitening Transformation via SVD

Starting from the SVD of centered data:

$$X_c = U \Sigma V^T$$

The covariance matrix is:

$$C = \frac{X_c^T X_c}{n-1} = \frac{V \Sigma^T \Sigma V^T}{n-1} = V \Lambda V^T$$

where $\Lambda = \frac{\Sigma^T \Sigma}{n-1}$ is diagonal with entries $\lambda_i = \frac{\sigma_i^2}{n-1}$.

**PCA whitening** is defined as:

$$Z = X_c V \Lambda^{-1/2}$$

Substituting $X_c = U\Sigma V^T$ and using $V^T V = I$:

$$Z = U \Sigma V^T V \Lambda^{-1/2} = U \Sigma \Lambda^{-1/2}$$

Since $\Lambda^{-1/2}$ has entries $\frac{1}{\sigma_i / \sqrt{n-1}} = \frac{\sqrt{n-1}}{\sigma_i}$, this simplifies to:

$$Z = U \sqrt{n-1}$$

**Interpretation:** After whitening, the transformed data is simply a rescaled version of the left singular vectors $U$, which are already orthonormal — confirming that $\text{Cov}(Z) = I$ by construction, since $U^TU = I$.

### Verifying the Whitening Property

$$\text{Cov}(Z) = \frac{Z^T Z}{n-1} = \frac{(n-1) U^T U}{n-1} = U^T U = I$$

This confirms the transformed features have unit variance and zero covariance between all pairs, satisfying the definition of whitening.

### Diagram: Effect of Whitening on Data Geometry

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 780 320">
  <text x="390" y="25" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Whitening Transformation: Geometric Effect (svg_diagram)</text>

  <text x="150" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Original Data</text>
  <line x1="30" y1="170" x2="270" y2="170" stroke="#c4c4c4" stroke-width="1" />
  <line x1="150" y1="70" x2="150" y2="270" stroke="#c4c4c4" stroke-width="1" />
  <ellipse cx="150" cy="170" rx="100" ry="40" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" transform="rotate(30, 150, 170)" />
  <text x="150" y="290" font-size="11" text-anchor="middle" fill="#5f6368">Correlated, unequal variance</text>

  <text x="390" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">After PCA (rotation only)</text>
  <line x1="270" y1="170" x2="510" y2="170" stroke="#c4c4c4" stroke-width="1" />
  <line x1="390" y1="70" x2="390" y2="270" stroke="#c4c4c4" stroke-width="1" />
  <ellipse cx="390" cy="170" rx="100" ry="40" fill="#fef7e0" stroke="#f9ab00" stroke-width="2" />
  <text x="390" y="290" font-size="11" text-anchor="middle" fill="#5f6368">Uncorrelated, unequal variance</text>

  <text x="630" y="55" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">After Whitening</text>
  <line x1="510" y1="170" x2="750" y2="170" stroke="#c4c4c4" stroke-width="1" />
  <line x1="630" y1="70" x2="630" y2="270" stroke="#c4c4c4" stroke-width="1" />
  <circle cx="630" cy="170" r="55" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="630" y="290" font-size="11" text-anchor="middle" fill="#5f6368">Uncorrelated, unit variance</text>

  <line x1="270" y1="170" x2="290" y2="170" stroke="none" />
  <path d="M 275 170 L 265 165 L 265 175 Z" fill="#5f6368" />
  <path d="M 515 170 L 505 165 L 505 175 Z" fill="#5f6368" />
</svg>

### The Full Whitening Formula (General Form)

For a general covariance matrix $C$ with eigendecomposition $C = V\Lambda V^T$, the whitening matrix is:

$$W = V \Lambda^{-1/2} V^T$$

This is known as **ZCA whitening** (Zero-phase Component Analysis whitening) when applied as $Z = X_c W$, and differs from PCA whitening in an important way.

**Key Points**
- PCA whitening ($Z = X_c V \Lambda^{-1/2}$) rotates the data into the eigenbasis before rescaling, so the whitened output is expressed in the rotated (principal component) coordinate system
- ZCA whitening ($Z = X_c V \Lambda^{-1/2} V^T$) rotates back into the original coordinate system after rescaling, so the whitened output remains aligned with the original features
- Both produce identity covariance, but ZCA whitening tends to preserve more visual/interpretive resemblance to the original data, which is why it is sometimes preferred for image preprocessing [Inference — based on common usage patterns in image processing literature; not a strict mathematical requirement]

### PCA Whitening vs. ZCA Whitening

| Aspect | PCA Whitening | ZCA Whitening |
|---|---|---|
| Formula | $Z = X_c V \Lambda^{-1/2}$ | $Z = X_c V \Lambda^{-1/2} V^T$ |
| Output coordinate system | Rotated (PC basis) | Original feature basis |
| Covariance of output | $I$ | $I$ |
| Common use case | General preprocessing, dimensionality reduction combined with whitening | Image preprocessing, preserving spatial interpretability |

### Numerical Stability: The Epsilon Term

In practice, singular values near zero cause $\Lambda^{-1/2}$ to blow up, amplifying noise in low-variance directions. A small regularization constant $\epsilon$ is commonly added:

$$Z = X_c V (\Lambda + \epsilon I)^{-1/2}$$

**Key Points**
- Without regularization, whitening can dramatically amplify noise present in near-zero-variance directions, since dividing by a near-zero singular value produces very large scaling factors
- The choice of $\epsilon$ is a hyperparameter; larger values reduce noise amplification but cause the output to deviate further from exact unit variance in low-variance directions
- [Inference] In practice, $\epsilon$ is often tuned empirically based on downstream task performance rather than derived analytically, though some conventions set it relative to the smallest retained eigenvalue

### Whitening Combined with Dimensionality Reduction

Whitening is frequently combined with truncation to the top $k$ components:

$$Z_k = X_c V_k \Lambda_k^{-1/2}$$

where $V_k$ contains the top $k$ eigenvectors and $\Lambda_k$ the corresponding top $k$ eigenvalues.

**Key Points**
- This simultaneously reduces dimensionality (from $d$ to $k$) and equalizes variance across retained dimensions
- Discarding low-variance components before whitening also mitigates the noise amplification problem, since the smallest (most unstable) singular values are excluded entirely rather than regularized

### Worked Example

Consider centered 2D data with covariance matrix:

$$C = \begin{bmatrix} 4 & 2 \\ 2 & 2 \end{bmatrix}$$

**Step 1 — Eigendecomposition:** [Unverified — exact eigenvector signs and precise decimal values depend on solver; illustrative values shown] Approximate eigenvalues are $\lambda_1 \approx 5.24$ and $\lambda_2 \approx 0.76$, with corresponding orthogonal eigenvectors forming $V$.

**Step 2 — Construct $\Lambda^{-1/2}$:**

$$\Lambda^{-1/2} \approx \begin{bmatrix} 0.437 & 0 \\ 0 & 1.147 \end{bmatrix}$$

**Step 3 — Apply whitening:** Each data point is projected onto the eigenvectors (via $V$) and then rescaled by these factors. The direction with originally larger variance ($\lambda_1$) is scaled down more aggressively (factor 0.437) than the direction with smaller variance ($\lambda_2$, factor 1.147), equalizing the spread in both directions.

**Interpretation:** Directions of high original variance are compressed, and directions of low original variance are stretched, until both have unit variance — this is the defining mechanical behavior of whitening.

### Applications in Machine Learning

- **Preprocessing for algorithms sensitive to feature scale and correlation**, such as certain clustering or distance-based methods [Inference — benefit depends on the specific algorithm and dataset]
- **Independent Component Analysis (ICA)**, where whitening is typically a required preprocessing step before applying ICA's core algorithm, since ICA assumes uncorrelated inputs as a starting point
- **Image preprocessing**, particularly ZCA whitening, historically used in some computer vision pipelines prior to the widespread adoption of deep learning normalization techniques such as batch normalization [Unverified — historical prevalence varies by era and application; modern deep learning pipelines often use alternative normalization schemes instead]
- **Improving optimization conditioning**, since whitened features can produce more isotropic loss landscapes for certain gradient-based methods, though this benefit is architecture- and optimizer-dependent [Inference]

### Common Pitfalls

- Applying whitening without regularization on data with near-zero variance directions, causing severe noise amplification
- Confusing whitening with simple standardization (z-scoring per feature), which does not remove inter-feature correlation
- Whitening the training and test sets independently rather than fitting the whitening transform on training data and applying the same transform to test data — this causes data leakage or inconsistent transformations
- Assuming whitening is universally beneficial for all downstream models; models robust to feature scale and correlation (e.g., some tree-based methods) may see no benefit from whitening [Inference]

### Conclusion

Whitening extends PCA by not only decorrelating features through rotation but also equalizing their variance through rescaling by $\Lambda^{-1/2}$, producing output with identity covariance. The choice between PCA whitening and ZCA whitening, along with the regularization constant $\epsilon$, should be guided by the downstream application, with particular caution around noise amplification in low-variance directions.

**Related Topics**
- Independent Component Analysis (ICA) and its reliance on whitened inputs
- Batch normalization and layer normalization as alternative deep learning-era approaches
- Mahalanobis distance and its relationship to whitened feature spaces
- Regularized covariance estimation for stabilizing whitening in high dimensions
- ZCA-cor whitening as a variant using correlation rather than covariance matrices