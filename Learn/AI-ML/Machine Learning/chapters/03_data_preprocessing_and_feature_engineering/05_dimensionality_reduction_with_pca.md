## Dimensionality Reduction — Principal Component Analysis

### Overview

Principal Component Analysis (PCA) is a linear dimensionality reduction technique that transforms a dataset with potentially correlated features into a smaller set of uncorrelated variables called principal components, while retaining as much variance (information) from the original data as possible. It is widely used for visualization, noise reduction, and as a preprocessing step before applying machine learning models.

### Core Concept

PCA identifies new axes (principal components) along which the data varies the most. The first principal component captures the direction of maximum variance in the data; the second principal component captures the next-highest variance direction while being orthogonal (uncorrelated) to the first, and so on.

**Key Points**

- Principal components are linear combinations of the original features.
- Each successive component captures less variance than the previous one.
- Components are orthogonal to each other by construction.

### Mathematical Foundation

#### Standardization

Because PCA is sensitive to the scale of input features, features are typically standardized (zero mean, unit variance) before applying PCA.

$$z = \frac{x - \mu}{\sigma}$$

#### Covariance Matrix

PCA computes the covariance matrix of the standardized features to understand how features vary together.

$$\Sigma = \frac{1}{n-1} X^T X$$

#### Eigendecomposition

The eigenvectors of the covariance matrix represent the principal component directions, and the corresponding eigenvalues represent the amount of variance explained by each component.

$$\Sigma v = \lambda v$$

Where $v$ is an eigenvector (principal component direction) and $\lambda$ is its corresponding eigenvalue (variance explained).

#### Projection

The original data is projected onto the top $k$ eigenvectors (those with the largest eigenvalues) to obtain the reduced-dimensional representation.

$$X_{reduced} = X \cdot V_k$$

Where $V_k$ is the matrix of the top $k$ eigenvectors.

### Explained Variance

Each principal component has an associated explained variance ratio, indicating the proportion of total dataset variance captured by that component.

$$\text{Explained Variance Ratio}_i = \frac{\lambda_i}{\sum_{j=1}^{n} \lambda_j}$$

**Key Points**

- Plotting cumulative explained variance against the number of components is a documented, standard method for choosing how many components to retain.
- A common approach cited in applied practice is retaining enough components to explain approximately 90–95% of total variance. [Inference] The appropriate threshold depends on the specific dataset and downstream task; I cannot verify that this range is optimal for any given use case.

### Implementation Example

```python
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
import numpy as np

# Standardize the data
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Apply PCA
pca = PCA(n_components=0.95)  # retain 95% of variance
X_reduced = pca.fit_transform(X_scaled)

print("Number of components selected:", pca.n_components_)
print("Explained variance ratio:", pca.explained_variance_ratio_)
```

**Example**

For a dataset with 50 original features, PCA might reduce it to, for instance, 12 components while retaining 95% of the variance. The exact number of components depends entirely on the correlation structure of the specific dataset being used; I do not have access to information that would let me state a universal number of components for a general case.

### Scree Plot

A scree plot visualizes the explained variance (or eigenvalue) of each principal component in descending order, helping to identify an "elbow" point where additional components contribute diminishing returns.

```mermaid
flowchart LR
    A[Component 1<br/>High Variance] --> B[Component 2<br/>Lower Variance]
    B --> C[Component 3<br/>Lower Still]
    C --> D[Component 4<br/>Marginal]
    D --> E[Component 5+<br/>Near Zero]
```

```python
import matplotlib.pyplot as plt

plt.plot(range(1, len(pca.explained_variance_ratio_) + 1),
         pca.explained_variance_ratio_, marker='o')
plt.xlabel('Principal Component')
plt.ylabel('Explained Variance Ratio')
plt.title('Scree Plot')
plt.show()
```

### Geometric Interpretation Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 400">
<text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">PCA — Principal Component Directions (svg_diagram)</text>
<line x1="350" y1="200" x2="350" y2="60" stroke="#ccc" stroke-width="1" />
<line x1="350" y1="200" x2="350" y2="340" stroke="#ccc" stroke-width="1" />
<line x1="150" y1="200" x2="550" y2="200" stroke="#ccc" stroke-width="1" />
<g>
<ellipse cx="350" cy="200" rx="150" ry="60" fill="#e8f0fe" stroke="#4285f4" stroke-width="1" opacity="0.5" transform="rotate(-30 350 200)" />
</g>
<circle cx="280" cy="240" r="3" fill="#555" />
<circle cx="300" cy="220" r="3" fill="#555" />
<circle cx="320" cy="215" r="3" fill="#555" />
<circle cx="340" cy="205" r="3" fill="#555" />
<circle cx="360" cy="195" r="3" fill="#555" />
<circle cx="380" cy="185" r="3" fill="#555" />
<circle cx="400" cy="175" r="3" fill="#555" />
<circle cx="420" cy="165" r="3" fill="#555" />
<circle cx="310" cy="230" r="3" fill="#555" />
<circle cx="390" cy="170" r="3" fill="#555" />
<line x1="230" y1="245" x2="470" y2="155" stroke="#ea4335" stroke-width="2.5" marker-end="url(#arrowRed)" />
<text x="475" y="150" font-size="13" fill="#ea4335" font-weight="bold">PC1</text>
<line x1="380" y1="130" x2="320" y2="270" stroke="#34a853" stroke-width="2.5" marker-end="url(#arrowGreen)" />
<text x="330" y="285" font-size="13" fill="#34a853" font-weight="bold">PC2</text>
<text x="350" y="370" font-size="12" text-anchor="middle" fill="#555">PC1 aligns with the direction of maximum variance; PC2 is orthogonal to PC1</text>
</svg>

### Advantages

**Key Points**

- Reduces dimensionality while retaining as much variance as mathematically possible for a given number of linear components.
- Removes multicollinearity between features, since resulting components are uncorrelated by construction.
- Can reduce computational cost and memory requirements for downstream models by decreasing feature count.
- Can assist in visualizing high-dimensional data by projecting onto 2 or 3 principal components.

### Limitations

**Key Points**

- Principal components are linear combinations of original features, so PCA cannot capture non-linear relationships in the data.
- Resulting components are typically not directly interpretable in terms of the original feature meanings.
- Sensitive to feature scaling; features with larger numeric ranges can dominate the variance calculation if not standardized first.
- [Inference] PCA may discard components with low variance that could still carry predictive signal relevant to the target variable, since PCA does not use the target variable in its calculations. I cannot verify how significant this effect is for any specific dataset without testing it directly.

### PCA vs. Feature Selection

| Aspect | PCA | Feature Selection |
| --- | --- | --- |
| Output | New transformed components | Subset of original features |
| Interpretability | Lower (components are combinations) | Higher (original features retained) |
| Uses target variable | No (standard PCA) | Often yes (e.g., wrapper/embedded methods) |
| Captures non-linear relations | No | Depends on method used |

[Inference] This comparison reflects general, commonly documented properties of standard PCA versus typical feature selection methods. I cannot verify that this comparison holds precisely for every implementation or variant (e.g., kernel PCA, which does capture non-linear relationships).

### Variants of PCA

#### Kernel PCA

Applies a kernel function to project data into a higher-dimensional space before performing PCA, allowing it to capture non-linear relationships.

```python
from sklearn.decomposition import KernelPCA

kpca = KernelPCA(n_components=2, kernel='rbf')
X_kpca = kpca.fit_transform(X_scaled)
```

#### Incremental PCA

Processes data in mini-batches rather than requiring the entire dataset to fit in memory, useful for very large datasets.

```python
from sklearn.decomposition import IncrementalPCA

ipca = IncrementalPCA(n_components=10, batch_size=100)
X_ipca = ipca.fit_transform(X_scaled)
```

#### Sparse PCA

Produces components with sparse loadings (many coefficients set to zero), which can improve interpretability compared to standard PCA.

```python
from sklearn.decomposition import SparsePCA

spca = SparsePCA(n_components=10, alpha=1.0)
X_spca = spca.fit_transform(X_scaled)
```

### Common Pitfalls

- **Skipping Standardization**: Applying PCA without standardizing features first can cause features with larger scales to disproportionately influence the resulting components.
- **Fitting on Full Dataset Before Train/Test Split**: Fitting PCA on the entire dataset (including test data) before splitting can leak information from the test set into the training process.
- **Over-Reducing Dimensionality**: Retaining too few components can discard meaningful variance and degrade downstream model performance. [Unverified] The precise point at which this occurs depends on the dataset and task; I do not have access to a general rule that applies across all cases.
- **Assuming Interpretability**: Treating principal components as if they have the same real-world meaning as original features can lead to incorrect conclusions, since components are abstract linear combinations.

### Conclusion

PCA is a documented, standard technique for reducing dimensionality by transforming correlated features into a smaller number of uncorrelated principal components ordered by explained variance. It is most effective when relationships in the data are approximately linear and when some loss of interpretability is an acceptable tradeoff for reduced dimensionality and computational cost. [Inference] Whether PCA is the most suitable dimensionality reduction technique for a specific project depends on the nature of the data and the goals of the analysis; I cannot verify this without information about that specific case.

### Related Topics

- Feature selection methods (as an alternative to dimensionality reduction)
- t-SNE and UMAP for non-linear dimensionality reduction and visualization
- Linear Discriminant Analysis (LDA) as a supervised alternative to PCA
- Autoencoders for non-linear dimensionality reduction in deep learning
- Multicollinearity and its effects on regression models
- Explained variance and component selection strategies