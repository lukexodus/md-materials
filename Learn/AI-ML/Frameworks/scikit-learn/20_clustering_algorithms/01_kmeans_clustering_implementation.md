## KMeans Clustering Implementation


KMeans partitions data into k clusters by minimizing within-cluster sum of squared distances to cluster centroids. The algorithm iteratively assigns points to nearest centroids and updates centroids to minimize total inertia, converging when assignments stabilize.

**Key Points:**

- Assumes spherical clusters with similar sizes and densities
- Requires pre-specifying number of clusters (k)
- Uses Lloyd's algorithm with random centroid initialization
- Sensitive to initialization - multiple random starts improve results
- Computationally efficient O(tkn) where t=iterations, k=clusters, n=samples
- Performs poorly with non-spherical clusters or varying cluster sizes
- Feature scaling critical for meaningful distance calculations

The algorithm's convergence depends on initialization quality and data distribution. The `init` parameter supports 'k-means++' smart initialization, 'random' initialization, or custom centroid arrays. The `n_init` parameter controls multiple random initializations to find best solution.

**Example:**

```python
from sklearn.cluster import KMeans
from sklearn.datasets import make_blobs
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import silhouette_score, adjusted_rand_score
import numpy as np

# Generate sample data with known clusters
X, y_true = make_blobs(n_samples=1000, centers=4, n_features=2, 
                       random_state=42, cluster_std=1.5)

# Scale features for consistent distance calculations
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Basic KMeans with k-means++ initialization
kmeans = KMeans(n_clusters=4, init='k-means++', n_init=10, random_state=42)
labels = kmeans.fit_predict(X_scaled)

# Evaluate clustering quality
silhouette_avg = silhouette_score(X_scaled, labels)
ari_score = adjusted_rand_score(y_true, labels)

print(f"Silhouette Score: {silhouette_avg:.3f}")
print(f"Adjusted Rand Index: {ari_score:.3f}")
print(f"Inertia: {kmeans.inertia_:.2f}")

# Access cluster centers and predict new points
centers = kmeans.cluster_centers_
new_points = np.array([[0, 0], [2, 2]])
new_labels = kmeans.predict(scaler.transform(new_points))

# Elbow method for optimal k selection
inertias = []
k_range = range(1, 11)
for k in k_range:
    kmeans_k = KMeans(n_clusters=k, random_state=42)
    kmeans_k.fit(X_scaled)
    inertias.append(kmeans_k.inertia_)
```

Optimal cluster number determination often uses elbow method (inertia vs k), silhouette analysis, or gap statistic. KMeans works best when clusters are compact, well-separated, and roughly equal in size.

