## Distance Metrics: Euclidean and Manhattan

### Definition

A distance metric is a function $d: \mathbb{R}^n \times \mathbb{R}^n \to \mathbb{R}$ that quantifies how far apart two points (vectors) are. A valid metric must satisfy four properties for all vectors $\mathbf{x}, \mathbf{y}, \mathbf{z} \in \mathbb{R}^n$:

1. **Non-negativity**: $d(\mathbf{x}, \mathbf{y}) \geq 0$
2. **Identity of indiscernibles**: $d(\mathbf{x}, \mathbf{y}) = 0 \iff \mathbf{x} = \mathbf{y}$
3. **Symmetry**: $d(\mathbf{x}, \mathbf{y}) = d(\mathbf{y}, \mathbf{x})$
4. **Triangle inequality**: $d(\mathbf{x}, \mathbf{z}) \leq d(\mathbf{x}, \mathbf{y}) + d(\mathbf{y}, \mathbf{z})$

These are standard axioms defining a metric space in mathematics.

### Relationship to Norms

Both distance metrics covered here are induced by a corresponding vector norm, via:

$$d(\mathbf{x}, \mathbf{y}) = \|\mathbf{x} - \mathbf{y}\|$$

This connects directly to the vector norms discussed in the earlier topic on vector norms.

### Euclidean Distance

#### Definition

$$d_2(\mathbf{x}, \mathbf{y}) = \|\mathbf{x} - \mathbf{y}\|_2 = \sqrt{\sum_{i=1}^n (x_i - y_i)^2}$$

This is the induced distance from the L2 norm, corresponding to ordinary straight-line distance between two points, generalized to $n$ dimensions.

#### Geometric Interpretation

In 2D or 3D, Euclidean distance matches physical, intuitive notions of "distance" — the length of a straight line segment connecting two points. This generalizes directly via the Pythagorean theorem to higher dimensions.

### Manhattan Distance

#### Definition

$$d_1(\mathbf{x}, \mathbf{y}) = \|\mathbf{x} - \mathbf{y}\|_1 = \sum_{i=1}^n |x_i - y_i|$$

This is the induced distance from the L1 norm. It is also called "taxicab distance" or "city block distance," since it corresponds to the distance traveled along a grid of perpendicular streets, rather than a direct diagonal path.

### Summary Table

| Property | Euclidean Distance | Manhattan Distance |
|---|---|---|
| Formula | $\sqrt{\sum_i (x_i-y_i)^2}$ | $\sum_i \|x_i - y_i\|$ |
| Induced norm | L2 | L1 |
| Geometric path | straight line | grid-based path |
| Sensitivity to outliers | higher (squares differences) | lower (linear differences) |

### Diagram: Euclidean vs Manhattan Path

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Euclidean vs Manhattan Distance (svg_diagram)</text>

  <line x1="60" y1="60" x2="60" y2="240" stroke="#ccc" stroke-width="1" />
  <line x1="60" y1="240" x2="500" y2="240" stroke="#ccc" stroke-width="1" />

  <circle cx="100" cy="200" r="5" fill="#cc0000" />
  <text x="80" y="225" font-size="12" fill="#333">Point A</text>

  <circle cx="380" cy="90" r="5" fill="#cc0000" />
  <text x="390" y="90" font-size="12" fill="#333">Point B</text>

  <line x1="100" y1="200" x2="380" y2="90" stroke="#339933" stroke-width="2" />
  <text x="200" y="130" font-size="12" fill="#006622">Euclidean (straight line)</text>

  <path d="M 100 200 L 380 200 L 380 90" fill="none" stroke="#cc6600" stroke-width="2" stroke-dasharray="5,3" />
  <text x="150" y="215" font-size="12" fill="#994400">Manhattan (grid path)</text>

  <text x="20" y="270" font-size="11" fill="#555">Both paths connect the same two points using different distance definitions.</text>
</svg>

### Example

Let $\mathbf{x} = [1, 2]^T$ and $\mathbf{y} = [4, 6]^T$.

**Euclidean distance**:

$$d_2(\mathbf{x}, \mathbf{y}) = \sqrt{(1-4)^2 + (2-6)^2} = \sqrt{9 + 16} = \sqrt{25} = 5$$

**Manhattan distance**:

$$d_1(\mathbf{x}, \mathbf{y}) = |1-4| + |2-6| = 3 + 4 = 7$$

Consistent with the general norm inequality $\|\mathbf{v}\|_2 \leq \|\mathbf{v}\|_1$ (covered in the vector norms topic), Euclidean distance is less than or equal to Manhattan distance for the same pair of points.

### Choosing Between Euclidean and Manhattan Distance

[Inference] The choice between Euclidean and Manhattan distance is commonly discussed in machine learning literature as being dependent on the structure and dimensionality of the data, but I do not have access to a single authoritative source confirming universal guidance for when one should be preferred over the other, so the points below should be read as commonly cited considerations rather than confirmed rules.

- **High-dimensional data**: [Inference] Some sources discuss Euclidean distance as becoming less discriminative in very high-dimensional spaces (a phenomenon sometimes associated with the "curse of dimensionality"), with Manhattan distance occasionally suggested as an alternative in such settings, but I cannot verify the specific conditions under which this holds without checking a dedicated source, and this should not be treated as a general rule for all high-dimensional datasets.
- **Outlier sensitivity**: Because Euclidean distance squares the differences before summing, larger discrepancies in any single dimension have a proportionally larger effect on the total distance than under Manhattan distance, where differences contribute linearly.
- **Grid-like or categorical-adjacent data**: Manhattan distance is sometimes preferred when movement or comparison is naturally constrained to axis-aligned steps, such as in certain routing or grid-based problems.

### Applications in Machine Learning

- **k-nearest neighbors (kNN)**: Both distance metrics are commonly used as the similarity measure for identifying nearest neighbors, with the choice of metric directly affecting which points are considered "close."
- **k-means clustering**: Standard k-means typically uses Euclidean distance in its objective function (minimizing squared Euclidean distances to cluster centroids); variants using other distance metrics exist but change the underlying optimization properties. [Unverified] I do not have access to confirm implementation-specific defaults or behavior of any particular k-means software library without checking its documentation directly.
- **Regularization connections**: The L1 and L2 norms underlying Manhattan and Euclidean distance, respectively, are the same norms used in Lasso (L1) and Ridge (L2) regularization, discussed in the earlier vector norms topic.
- **Anomaly detection**: Distance-based anomaly detection methods flag points that are far (by a chosen metric) from the bulk of the data distribution.

### Behavioral Disclaimer

[Unverified] Claims about how any specific machine learning library computes or optimizes distance metrics internally (e.g., algorithmic shortcuts, default distance metric choices) would require checking that library's documentation directly. Library behavior may vary by implementation and version, and no such library-specific claims are made here beyond the general mathematical theory.

### Next Steps

- Minkowski distance as the general $L_p$ family of distance metrics
- Cosine similarity and its distinction from distance metrics
- Mahalanobis distance and covariance-aware distance measures
- Distance metrics in k-nearest neighbors and k-means clustering
- Curse of dimensionality and its effect on distance-based methods
- Metric learning: learning a task-specific distance function