## Similarity Measures in High Dimensions

### Overview

High-dimensional similarity measurement is central to machine learning tasks such as nearest-neighbor search, clustering, recommendation systems, and embedding comparison. As dimensionality increases, the geometric and statistical behavior of distance and similarity functions changes in ways that are often counterintuitive. This topic covers the primary similarity measures used in ML and the specific challenges that arise in high-dimensional spaces.

### Core Similarity Measures

#### Cosine Similarity

Cosine similarity measures the cosine of the angle between two vectors, ignoring magnitude and focusing purely on direction.

$$\text{cos\_sim}(\mathbf{u}, \mathbf{v}) = \frac{\mathbf{u} \cdot \mathbf{v}}{\|\mathbf{u}\| \|\mathbf{v}\|}$$

Values range from $-1$ (opposite direction) to $1$ (identical direction), with $0$ indicating orthogonality.

**Key Points**
- Invariant to vector scaling, making it useful when magnitude carries no semantic meaning (e.g., word embeddings, TF-IDF vectors)
- Widely used in NLP and recommendation systems
- Does not satisfy the triangle inequality, so it is not a true metric

**Example**

```
u = [1, 2, 3]
v = [2, 4, 6]
```

Here $\mathbf{v} = 2\mathbf{u}$, so despite different magnitudes, $\text{cos\_sim}(\mathbf{u}, \mathbf{v}) = 1$.

#### Dot Product Similarity

The raw dot product is sometimes used directly as a similarity score, particularly in retrieval systems using approximate nearest neighbor search.

$$\text{sim}(\mathbf{u}, \mathbf{v}) = \mathbf{u} \cdot \mathbf{v}$$

**Key Points**
- Sensitive to vector magnitude, unlike cosine similarity
- Common in transformer attention mechanisms (scaled dot-product attention)
- Computationally cheaper than cosine similarity since it skips normalization

#### Euclidean Distance (L2)

$$d(\mathbf{u}, \mathbf{v}) = \sqrt{\sum_{i=1}^{n} (u_i - v_i)^2}$$

A true metric satisfying non-negativity, symmetry, and the triangle inequality. Often converted to a similarity score via a decreasing function, such as $\text{sim} = \frac{1}{1 + d}$ or a Gaussian kernel.

#### Manhattan Distance (L1)

$$d(\mathbf{u}, \mathbf{v}) = \sum_{i=1}^{n} |u_i - v_i|$$

Less sensitive to outliers than Euclidean distance along any single dimension, since differences are not squared.

#### Jaccard Similarity

Used for set-based or binary vector comparisons.

$$J(A, B) = \frac{|A \cap B|}{|A \cup B|}$$

**Key Points**
- Common for comparing sets of categorical features, tags, or binary presence vectors
- Ranges from $0$ (no overlap) to $1$ (identical sets)

#### Pearson Correlation Similarity

Measures linear correlation between two vectors, effectively cosine similarity on mean-centered vectors.

$$\rho(\mathbf{u}, \mathbf{v}) = \frac{\sum_i (u_i - \bar{u})(v_i - \bar{v})}{\sqrt{\sum_i (u_i - \bar{u})^2} \sqrt{\sum_i (v_i - \bar{v})^2}}$$

Used in collaborative filtering where rating scale offsets between users should be normalized out.

### The Curse of Dimensionality in Similarity Measures

#### Distance Concentration

As dimensionality $n$ grows, for many common distributions (e.g., i.i.d. random vectors), the ratio between the farthest and nearest distances from a query point tends toward $1$.

$$\lim_{n \to \infty} \frac{d_{\max} - d_{\min}}{d_{\min}} \to 0$$

This is a well-established mathematical result under specific distributional assumptions (i.i.d. coordinates with finite variance). It means that in very high dimensions, all points can appear roughly equidistant from a query point, degrading the discriminative power of distance-based methods.

**Key Points**
- This effect is most pronounced for Euclidean (L2) and higher $L_p$ norms
- $L_1$ (Manhattan) distance is comparatively more robust to concentration effects than $L_2$ [Inference: this follows from theoretical analysis in Aggarwal et al.'s work on distance metrics in high dimensions, but the magnitude of the effect depends on the specific data distribution and is not universal across all datasets]
- Fractional norms ($L_p$ with $0 < p < 1$) have been proposed as more discriminative alternatives in some studies [Unverified — effectiveness varies by application and is not a settled recommendation for all ML pipelines]

#### Volume Concentration

In high dimensions, the volume of a hypersphere concentrates increasingly near its surface rather than its center. This affects sampling-based and density-based similarity estimates, since most of the probability mass in common distributions (e.g., high-dimensional Gaussians) lies in a thin shell rather than near the mean.

#### Sparsity of Data

High-dimensional spaces are typically sparse relative to the number of available data points, since the volume of the space grows exponentially with dimension while sample size does not. This makes density estimation and neighbor-based similarity increasingly unreliable without dimensionality reduction or strong structural assumptions.

### Diagram: Effect of Dimensionality on Distance Discrimination

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Distance Concentration with Increasing Dimensionality (svg_diagram)</text>

  <line x1="80" y1="320" x2="650" y2="320" stroke="#333" stroke-width="2"/>
  <line x1="80" y1="320" x2="80" y2="60" stroke="#333" stroke-width="2"/>

  <text x="365" y="355" text-anchor="middle" font-size="14" fill="#333">Number of Dimensions (n)</text>
  <text x="30" y="190" text-anchor="middle" font-size="14" fill="#333" transform="rotate(-90 30 190)">Relative Distance Spread</text>

  <text x="90" y="335" font-size="12" fill="#555">2</text>
  <text x="240" y="335" font-size="12" fill="#555">50</text>
  <text x="400" y="335" font-size="12" fill="#555">500</text>
  <text x="560" y="335" font-size="12" fill="#555">5000</text>

  <path d="M 90 90 Q 200 100, 300 180 T 450 280 T 620 305" stroke="#2563eb" stroke-width="3" fill="none"/>

  <circle cx="90" cy="90" r="5" fill="#2563eb"/>
  <circle cx="300" cy="180" r="5" fill="#2563eb"/>
  <circle cx="450" cy="280" r="5" fill="#2563eb"/>
  <circle cx="620" cy="305" r="5" fill="#2563eb"/>

  <text x="500" y="100" font-size="13" fill="#555">Low-dim: distances</text>
  <text x="500" y="118" font-size="13" fill="#555">well-separated</text>

  <text x="440" y="255" font-size="13" fill="#555">High-dim: distances</text>
  <text x="440" y="273" font-size="13" fill="#555">converge (concentration)</text>

  <line x1="80" y1="320" x2="650" y2="320" stroke="#999" stroke-width="1" stroke-dasharray="4"/>
</svg>

**Note on the diagram:** This is a conceptual illustration of the distance concentration phenomenon, not a plot of empirically measured data. Actual concentration rates depend on the data distribution, norm used, and correlation structure between dimensions. [Inference]

### Mitigation Strategies

#### Dimensionality Reduction

Techniques such as PCA, t-SNE, UMAP, or autoencoders can reduce dimensionality before applying similarity measures, often improving discriminative power. [Inference: this is a widely used practice in ML pipelines, though the degree of improvement is task- and data-dependent, not a guaranteed outcome]

#### Feature Selection and Weighting

Selecting relevant features or applying learned weightings (e.g., via metric learning) can reduce the effective dimensionality that matters for similarity computation.

#### Locality-Sensitive Hashing (LSH)

LSH approximates nearest-neighbor search in high dimensions by hashing similar items into the same buckets with higher probability than dissimilar items, avoiding exhaustive pairwise distance computation.

#### Learned Similarity Metrics

Instead of relying on fixed geometric measures, ML systems increasingly use learned embeddings (e.g., via contrastive learning, Siamese networks) where the embedding space is explicitly optimized so that Euclidean or cosine similarity is meaningful. This does not eliminate the curse of dimensionality but can reduce its practical impact within the learned embedding subspace. [Inference]

### Choosing a Similarity Measure

| Data Type | Common Measure | Rationale |
|---|---|---|
| Dense continuous embeddings | Cosine similarity | Direction matters more than magnitude |
| Sparse binary/categorical | Jaccard similarity | Set-overlap semantics |
| User ratings with bias | Pearson correlation | Normalizes per-user scale |
| Spatial/physical coordinates | Euclidean distance | Matches physical distance intuition |
| Robust to outliers needed | Manhattan distance | Less sensitive to extreme differences |
| Retrieval with ANN indexes | Dot product | Computationally efficient at scale |

This table reflects common practice conventions in ML applications. [Unverified — actual optimal choice depends on empirical validation on the specific dataset and task; no single measure is correct for all cases]

### Computational Considerations

Computing pairwise similarity across a dataset of $m$ points in $n$ dimensions naively costs $O(m^2 n)$, which becomes prohibitive at scale. Approximate methods (LSH, tree-based indexes such as KD-trees or ball trees, graph-based indexes such as HNSW) trade exact accuracy for speed. KD-trees and ball trees degrade toward brute-force performance as dimensionality increases, due to the same concentration effects described above. [Inference]

**Related Topics**
- Dimensionality reduction techniques (PCA, SVD, t-SNE, UMAP)
- Metric learning and learned embedding spaces
- Locality-sensitive hashing and approximate nearest neighbor search
- Kernel methods and the kernel trick
- Eigendecomposition and its role in spectral methods
- Matrix factorization for recommendation systems

