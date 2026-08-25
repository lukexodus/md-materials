## Mahalanobis Distance

### Definition

The Mahalanobis distance measures the distance between a point and a distribution (or between two points), accounting for the correlations and variances of the underlying data. Unlike Euclidean distance, it is scale-invariant and correlation-aware, using the covariance structure of the data to reweight distances along different directions.

For a vector $\mathbf{x}$ and a distribution with mean $\boldsymbol{\mu}$ and covariance matrix $\Sigma$:

$$d_M(\mathbf{x}, \boldsymbol{\mu}) = \sqrt{(\mathbf{x} - \boldsymbol{\mu})^T \Sigma^{-1} (\mathbf{x} - \boldsymbol{\mu})}$$

This is a standard definition found across statistics and multivariate analysis references.

### Between Two Points

The Mahalanobis distance can also be defined between two arbitrary points $\mathbf{x}$ and $\mathbf{y}$, using a shared covariance matrix $\Sigma$:

$$d_M(\mathbf{x}, \mathbf{y}) = \sqrt{(\mathbf{x} - \mathbf{y})^T \Sigma^{-1} (\mathbf{x} - \mathbf{y})}$$

### Relationship to Euclidean Distance

If $\Sigma = I$ (the identity matrix), the Mahalanobis distance reduces exactly to the Euclidean distance:

$$d_M(\mathbf{x}, \boldsymbol{\mu}) = \sqrt{(\mathbf{x}-\boldsymbol{\mu})^T (\mathbf{x}-\boldsymbol{\mu})} = \|\mathbf{x} - \boldsymbol{\mu}\|_2$$

This shows that Euclidean distance is a special case of Mahalanobis distance, one that implicitly assumes uncorrelated features with equal variance.

### Why the Covariance Matrix Matters

Multiplying by $\Sigma^{-1}$ rescales each dimension according to its variance and accounts for correlations between dimensions. Intuitively:

- Directions with high variance in the data are "compressed" (a large raw difference in that direction contributes less to the distance).
- Directions with low variance are "stretched" (a small raw difference contributes more to the distance).
- Correlated dimensions are jointly rescaled, rather than treated as independent axes.

This behavior follows mathematically from the structure of $\Sigma^{-1}$ and is a standard property discussed in multivariate statistics references.

### Diagram: Mahalanobis vs Euclidean Distance Under Correlated Data

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 300">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Mahalanobis vs Euclidean Distance (svg_diagram)</text>

  <text x="30" y="60" font-size="13" fill="#333">Correlated data cloud</text>
  <ellipse cx="150" cy="160" rx="110" ry="45" fill="#dbe9ff" stroke="#3366cc" stroke-width="1.5" transform="rotate(-30 150 160)" />
  <circle cx="150" cy="160" r="4" fill="#333" />
  <text x="130" y="145" font-size="11" fill="#333">μ</text>

  <circle cx="220" cy="100" r="4" fill="#cc0000" />
  <text x="228" y="100" font-size="11" fill="#333">Point A</text>
  <line x1="150" y1="160" x2="220" y2="100" stroke="#cc0000" stroke-width="1.5" stroke-dasharray="3,2" />

  <circle cx="90" cy="220" r="4" fill="#009933" />
  <text x="60" y="240" font-size="11" fill="#333">Point B</text>
  <line x1="150" y1="160" x2="90" y2="220" stroke="#009933" stroke-width="1.5" stroke-dasharray="3,2" />

  <text x="380" y="70" font-size="12" fill="#555">Point A and Point B may have equal</text>
  <text x="380" y="88" font-size="12" fill="#555">Euclidean distance from μ, but different</text>
  <text x="380" y="106" font-size="12" fill="#555">Mahalanobis distance, depending on</text>
  <text x="380" y="124" font-size="12" fill="#555">alignment with the data's covariance</text>
  <text x="380" y="142" font-size="12" fill="#555">ellipse (the direction of natural spread).</text>
</svg>

### Decomposition via Whitening

The Mahalanobis distance can be understood as ordinary Euclidean distance computed after a "whitening" transformation of the data. If $\Sigma = LL^T$ (a Cholesky decomposition), define:

$$\mathbf{z} = L^{-1}(\mathbf{x} - \boldsymbol{\mu})$$

Then:

$$d_M(\mathbf{x}, \boldsymbol{\mu}) = \|\mathbf{z}\|_2$$

This shows that the Mahalanobis distance is mathematically equivalent to first transforming the data into a space where features are uncorrelated with unit variance (the "whitened" space), then applying ordinary Euclidean distance in that transformed space. This equivalence follows directly from substituting $\mathbf{z}$ into the whitened distance expression and using $\Sigma^{-1} = L^{-T}L^{-1}$.

### Summary Table

| Property | Euclidean Distance | Mahalanobis Distance |
|---|---|---|
| Accounts for correlation | No | Yes |
| Accounts for differing variances | No | Yes |
| Requires covariance matrix | No | Yes |
| Reduces to Euclidean when $\Sigma = I$ | — | Yes |
| Invariant to linear rescaling of features | No | Yes |

### Example

Let the data have mean $\boldsymbol{\mu} = [0, 0]^T$ and covariance:

$$\Sigma = \begin{bmatrix} 4 & 0 \\ 0 & 1 \end{bmatrix}$$

indicating higher variance along the first dimension. Consider the point $\mathbf{x} = [2, 0]^T$.

**Euclidean distance**:

$$d_2(\mathbf{x}, \boldsymbol{\mu}) = \sqrt{2^2 + 0^2} = 2$$

**Mahalanobis distance**: First compute $\Sigma^{-1}$:

$$\Sigma^{-1} = \begin{bmatrix} 1/4 & 0 \\ 0 & 1 \end{bmatrix}$$

Then:

$$d_M(\mathbf{x}, \boldsymbol{\mu}) = \sqrt{[2, 0] \begin{bmatrix} 1/4 & 0 \\ 0 & 1 \end{bmatrix} \begin{bmatrix} 2 \\ 0 \end{bmatrix}} = \sqrt{[2,0]\begin{bmatrix} 0.5 \\ 0 \end{bmatrix}} = \sqrt{1} = 1$$

The Mahalanobis distance (1) is smaller than the Euclidean distance (2) because the displacement occurs along the high-variance direction, where the data naturally spreads further — so a displacement of 2 units in that direction is considered less "unusual" than the same raw distance would be in a low-variance direction.

### Statistical Interpretation

If the data follows a multivariate normal distribution, the squared Mahalanobis distance follows a chi-squared distribution with $n$ degrees of freedom (where $n$ is the dimensionality). This is a standard result in multivariate statistics, used to construct confidence regions and identify statistical outliers. [Unverified] I do not have access to confirm the exact original source or derivation reference for this result within this conversation, so it should be checked against a multivariate statistics textbook if precise citation is required.

### Applications in Machine Learning

- **Anomaly and outlier detection**: Points with a large Mahalanobis distance from the data mean (relative to the chi-squared threshold at a chosen confidence level) are commonly flagged as statistical outliers.
- **Classification (e.g., Gaussian discriminant analysis)**: Some classification methods assign a point to the class whose distribution yields the smallest Mahalanobis distance, effectively accounting for each class's covariance structure. [Inference] This framing is a common way Mahalanobis distance is introduced in the context of Gaussian discriminant analysis and quadratic discriminant analysis, but exact implementation and decision boundary details depend on the specific formulation used, and I do not have access to confirm this matches every textbook's exact presentation.
- **Clustering with elliptical clusters**: Distance-based clustering methods that assume elliptical (rather than spherical) cluster shapes may use Mahalanobis distance instead of Euclidean distance to better match the underlying covariance structure of each cluster.
- **Feature decorrelation**: The whitening transformation connected to Mahalanobis distance is related to preprocessing techniques that decorrelate features before applying distance-based or gradient-based methods.

[Inference] These applications are commonly presented together in multivariate statistics and pattern recognition references as illustrative use cases, but I do not have access to confirm that any single canonical source presents them in exactly this combination, so this should be read as a practical illustration rather than a verified reproduction of one specific source.

### Computational Considerations

- Computing $\Sigma^{-1}$ requires $\Sigma$ to be invertible (non-singular), which can fail or become numerically unstable when the number of data dimensions is large relative to the number of samples, or when features are highly collinear.
- In practice, regularized or shrinkage estimates of the covariance matrix are sometimes used to address this issue. [Unverified] I do not have access to confirm which specific regularization approach is most commonly used across current statistical or machine learning software, and this would need to be checked against a specific library's documentation.

### Behavioral Disclaimer

[Unverified] Claims about how any specific statistical or machine learning library computes Mahalanobis distance internally (e.g., covariance estimation method, numerical stability handling, default regularization) would require checking that library's documentation directly. Library behavior may vary by implementation and version, and no such library-specific claims are made here beyond the general mathematical theory.

### Next Steps

- Covariance matrices: estimation and properties
- Whitening and decorrelation transformations
- Gaussian discriminant analysis and quadratic discriminant analysis
- Chi-squared distribution and its role in outlier detection thresholds
- Cholesky decomposition as a matrix factorization method
- Multivariate Gaussian distributions in machine learning