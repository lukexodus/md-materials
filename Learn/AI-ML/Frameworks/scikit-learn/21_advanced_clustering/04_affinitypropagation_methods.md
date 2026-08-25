## AffinityPropagation Methods


AffinityPropagation discovers clusters by passing messages between data points to identify exemplars (cluster centers) that best represent other points through similarity-based optimization.

### Message Passing Algorithm

The algorithm exchanges two types of messages: responsibility r(i,k) indicating how well point k serves as exemplar for point i, and availability a(i,k) indicating how appropriate point k is as exemplar for point i based on other points' preferences.

### Similarity Matrix

AffinityPropagation requires pairwise similarity matrices, typically negative squared Euclidean distances. The `preference` parameter (diagonal values) influences exemplar selection - higher preferences increase likelihood of becoming exemplars.

**Example:**

```python
from sklearn.cluster import AffinityPropagation
from sklearn.datasets import make_blobs
from sklearn.metrics.pairwise import euclidean_distances
import numpy as np

# Generate clustered data
X_ap, _ = make_blobs(n_samples=200, centers=6, cluster_std=1.0, random_state=42)

# Calculate similarity matrix
similarities = -euclidean_distances(X_ap, squared=True)

# Automatic preference setting
median_similarity = np.median(similarities)

# AffinityPropagation clustering
ap = AffinityPropagation(
    preference=median_similarity,
    damping=0.9,
    max_iter=300,
    convergence_iter=15,
    random_state=42
)

cluster_labels = ap.fit_predict(X_ap)
exemplars = ap.cluster_centers_indices_
n_clusters = len(exemplars)

print(f"Number of clusters: {n_clusters}")
print(f"Exemplar indices: {exemplars}")
print(f"Number of iterations: {ap.n_iter_}")
```

### Damping Factor

The `damping` parameter (0.5-1.0) controls message update rates to prevent oscillations. Higher damping values increase stability but slow convergence. The algorithm maintains message history and updates incrementally to achieve stability.

### Preference Impact

Preference values significantly affect cluster numbers and quality. Higher preferences create more clusters by encouraging more points to become exemplars. The median similarity provides a balanced starting point, while preference arrays enable point-specific exemplar propensities.

### Convergence Control

The `convergence_iter` parameter specifies consecutive iterations required for convergence detection. The `max_iter` parameter prevents infinite loops in difficult optimization landscapes. The algorithm may not converge for certain similarity matrices or parameter combinations.

