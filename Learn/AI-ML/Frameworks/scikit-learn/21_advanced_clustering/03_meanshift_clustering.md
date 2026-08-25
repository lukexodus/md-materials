## MeanShift Clustering


MeanShift discovers clusters by locating density modes through iterative mean-shift procedures, automatically determining cluster numbers without prior specification.

### Density-Based Foundation

MeanShift interprets clustering as finding modes of probability density functions. The algorithm uses kernel density estimation with each point contributing a kernel (typically Gaussian) to the overall density landscape.

### Mean-Shift Procedure

Starting from each data point, the algorithm iteratively shifts toward higher density regions by computing weighted means of neighboring points. The process continues until convergence to density modes, which become cluster centers.

**Example:**

```python
from sklearn.cluster import MeanShift, estimate_bandwidth
from sklearn.datasets import make_blobs
import numpy as np

# Generate data with varying cluster sizes
X_varied, _ = make_blobs(n_samples=500, centers=5, cluster_std=[1.0, 2.5, 0.5, 1.8, 1.2],
                         center_box=(-20.0, 20.0), random_state=42)

# Estimate bandwidth automatically
bandwidth = estimate_bandwidth(X_varied, quantile=0.3, n_samples=200)

# MeanShift clustering
meanshift = MeanShift(
    bandwidth=bandwidth,
    cluster_all=True,
    min_bin_freq=5,
    max_iter=300
)

cluster_labels = meanshift.fit_predict(X_varied)
cluster_centers = meanshift.cluster_centers_

print(f"Estimated bandwidth: {bandwidth:.3f}")
print(f"Number of clusters found: {len(cluster_centers)}")
print(f"Number of points not assigned: {np.sum(cluster_labels == -1)}")
```

### Bandwidth Selection

The `bandwidth` parameter controls kernel width, critically affecting cluster granularity. Small bandwidths create many small clusters, while large bandwidths merge nearby clusters. The `estimate_bandwidth` function provides automatic bandwidth selection using quantile-based methods.

### Automatic Cluster Discovery

MeanShift automatically determines cluster numbers by finding density modes. The `cluster_all` parameter controls whether to assign all points to clusters or mark low-density points as outliers. The `min_bin_freq` parameter filters spurious modes from sparse regions.

### Computational Considerations

MeanShift has O(T·n²) time complexity where T represents iterations and n represents sample count. The algorithm's quadratic complexity limits scalability to moderate-sized datasets. Ball tree structures can accelerate neighbor searches for high-dimensional data.

