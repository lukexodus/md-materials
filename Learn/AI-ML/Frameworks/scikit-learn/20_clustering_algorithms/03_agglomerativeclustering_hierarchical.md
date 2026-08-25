## AgglomerativeClustering Hierarchical


AgglomerativeClustering builds hierarchies of clusters using bottom-up approach, starting with individual points as clusters and iteratively merging closest pairs according to linkage criteria. This method reveals cluster structure at multiple scales without requiring predetermined cluster count.

**Key Points:**

- Creates hierarchical cluster tree (dendrogram) showing merge sequence
- No need to specify cluster count initially - can cut tree at desired level
- Multiple linkage criteria: ward (minimize variance), complete (maximum distance), average, single
- Supports various distance metrics including non-Euclidean measures
- Connectivity constraints enable structured clustering (e.g., image segmentation)
- Deterministic results unlike KMeans random initialization
- Computational complexity O(n³) limits scalability to moderate datasets

Ward linkage minimizes within-cluster variance and works well with Euclidean distances. Complete linkage creates compact spherical clusters, while single linkage can detect arbitrary shapes but suffers from chaining effects.

**Example:**

```python
from sklearn.cluster import AgglomerativeClustering
from sklearn.datasets import make_moons
from sklearn.neighbors import kneighbors_graph
from scipy.cluster.hierarchy import dendrogram, linkage
import matplotlib.pyplot as plt

# Non-spherical dataset where KMeans struggles
X_moons, y_moons = make_moons(n_samples=300, noise=0.1, random_state=42)

# Basic agglomerative clustering with different linkages
agg_ward = AgglomerativeClustering(n_clusters=2, linkage='ward')
agg_complete = AgglomerativeClustering(n_clusters=2, linkage='complete')
agg_average = AgglomerativeClustering(n_clusters=2, linkage='average')

labels_ward = agg_ward.fit_predict(X_moons)
labels_complete = agg_complete.fit_predict(X_moons)
labels_average = agg_average.fit_predict(X_moons)

# Connectivity-constrained clustering
knn_graph = kneighbors_graph(X_moons, n_neighbors=10, include_self=False)
agg_connectivity = AgglomerativeClustering(
    n_clusters=2, 
    linkage='ward',
    connectivity=knn_graph
)
labels_connectivity = agg_connectivity.fit_predict(X_moons)

# Hierarchical clustering without fixed cluster count
Z = linkage(X_moons, method='ward')
# Can determine optimal cuts using dendrogram analysis

# Distance threshold approach
agg_threshold = AgglomerativeClustering(
    n_clusters=None, 
    distance_threshold=1.0,
    linkage='ward'
)
labels_threshold = agg_threshold.fit_predict(X_moons)

print(f"Clusters with threshold: {agg_threshold.n_clusters_}")

# Evaluate different linkage methods
from sklearn.metrics import adjusted_rand_score
print(f"Ward ARI: {adjusted_rand_score(y_moons, labels_ward):.3f}")
print(f"Complete ARI: {adjusted_rand_score(y_moons, labels_complete):.3f}")
print(f"Average ARI: {adjusted_rand_score(y_moons, labels_average):.3f}")
```

AgglomerativeClustering excels with irregular cluster shapes and provides interpretable hierarchical structure. Connectivity constraints enable spatially-aware clustering for image segmentation or network community detection.

