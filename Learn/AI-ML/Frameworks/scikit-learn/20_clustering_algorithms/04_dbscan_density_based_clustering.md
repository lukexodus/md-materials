## DBSCAN Density-Based Clustering


DBSCAN (Density-Based Spatial Clustering of Applications with Noise) groups points in high-density regions while marking isolated points as noise. This approach discovers clusters of arbitrary shapes and automatically determines cluster count based on data density patterns.

**Key Points:**

- Defines clusters as dense regions separated by sparse areas
- Two key parameters: eps (neighborhood radius) and min_samples (minimum points per cluster)
- Automatically determines cluster count and handles noise/outliers
- Discovers non-spherical clusters that challenge centroid-based methods
- No assumption about cluster sizes or shapes
- Sensitive to parameter choice - requires domain knowledge or systematic tuning
- Performance degrades in high-dimensional spaces due to curse of dimensionality

Core points have at least min_samples neighbors within eps distance. Border points lie within eps of core points but aren't core themselves. Noise points satisfy neither condition and remain unclustered.

**Example:**

```python
from sklearn.cluster import DBSCAN
from sklearn.datasets import make_moons, make_circles
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import NearestNeighbors
import numpy as np

# Complex shaped dataset
X_complex, _ = make_circles(n_samples=300, factor=0.6, noise=0.1, random_state=42)
X_complex = StandardScaler().fit_transform(X_complex)

# Basic DBSCAN clustering
dbscan = DBSCAN(eps=0.3, min_samples=5)
labels = dbscan.fit_predict(X_complex)

# Identify core samples, noise points
core_samples_mask = np.zeros_like(labels, dtype=bool)
core_samples_mask[dbscan.core_sample_indices_] = True

n_clusters = len(set(labels)) - (1 if -1 in labels else 0)
n_noise = list(labels).count(-1)

print(f"Estimated clusters: {n_clusters}")
print(f"Noise points: {n_noise}")

# Parameter selection using k-distance plot
def plot_k_distance(X, k=5):
    neighbors = NearestNeighbors(n_neighbors=k)
    neighbors_fit = neighbors.fit(X)
    distances, indices = neighbors_fit.kneighbors(X)
    distances = np.sort(distances[:, k-1], axis=0)
    return distances

# Find optimal eps using elbow in k-distance plot
distances = plot_k_distance(X_complex, k=5)
# Optimal eps often at "elbow" of sorted k-distances

# Multiple datasets comparison
datasets = [
    make_moons(n_samples=300, noise=0.1, random_state=42)[0],
    make_circles(n_samples=300, factor=0.6, noise=0.1, random_state=42)[0],
    make_blobs(n_samples=300, centers=4, random_state=42)[0]
]

for i, X_data in enumerate(datasets):
    X_scaled = StandardScaler().fit_transform(X_data)
    
    # Grid search for optimal parameters
    eps_values = np.arange(0.1, 1.0, 0.1)
    min_samples_values = range(3, 10)
    
    best_score = -1
    best_params = {}
    
    for eps in eps_values:
        for min_samples in min_samples_values:
            dbscan_test = DBSCAN(eps=eps, min_samples=min_samples)
            labels_test = dbscan_test.fit_predict(X_scaled)
            
            if len(set(labels_test)) > 1:  # At least one cluster found
                score = silhouette_score(X_scaled, labels_test)
                if score > best_score:
                    best_score = score
                    best_params = {'eps': eps, 'min_samples': min_samples}
    
    print(f"Dataset {i+1} best params: {best_params}, score: {best_score:.3f}")
```

DBSCAN parameter tuning requires understanding data density distribution. The k-distance plot method helps identify appropriate eps values, while min_samples typically ranges from 3-10 depending on dataset dimensionality and noise levels.

