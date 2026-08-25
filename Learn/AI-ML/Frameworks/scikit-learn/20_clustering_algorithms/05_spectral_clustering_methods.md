## Spectral Clustering Methods


Spectral clustering uses eigenvalue decomposition of similarity matrices to perform dimensionality reduction before applying standard clustering algorithms. This approach excels at finding non-convex clusters by leveraging graph-theoretic properties of data relationships.

**Key Points:**

- Constructs similarity graph from data using various affinity measures
- Performs eigendecomposition on graph Laplacian matrix
- Projects data into lower-dimensional eigenspace where clusters become separable
- Applies KMeans to eigenspace embeddings for final clustering
- Handles non-convex cluster shapes that challenge traditional methods
- Requires careful selection of affinity parameters and number of eigenvectors
- Computational complexity O(n³) limits scalability without approximations

The algorithm builds affinity matrices using RBF kernels, k-nearest neighbors, or custom similarity functions. Graph Laplacian normalization affects clustering behavior - unnormalized, symmetric, and random walk normalizations suit different data characteristics.

**Example:**

```python
from sklearn.cluster import SpectralClustering
from sklearn.datasets import make_moons, make_circles
from sklearn.neighbors import kneighbors_graph
from sklearn.metrics import normalized_mutual_info_score
import numpy as np

# Non-convex datasets where spectral clustering excels
X_moons, y_moons = make_moons(n_samples=300, noise=0.1, random_state=42)
X_circles, y_circles = make_circles(n_samples=300, factor=0.6, noise=0.1, random_state=42)

# Basic spectral clustering with RBF affinity
spectral_rbf = SpectralClustering(
    n_clusters=2, 
    affinity='rbf', 
    gamma=1.0,
    random_state=42
)
labels_rbf = spectral_rbf.fit_predict(X_moons)

# Spectral clustering with nearest neighbors affinity
spectral_nn = SpectralClustering(
    n_clusters=2,
    affinity='nearest_neighbors',
    n_neighbors=10,
    random_state=42
)
labels_nn = spectral_nn.fit_predict(X_moons)

# Custom affinity matrix
def custom_affinity(X):
    from sklearn.metrics.pairwise import rbf_kernel
    return rbf_kernel(X, gamma=0.5)

affinity_matrix = custom_affinity(X_moons)
spectral_custom = SpectralClustering(
    n_clusters=2,
    affinity='precomputed',
    random_state=42
)
labels_custom = spectral_custom.fit_predict(affinity_matrix)

# Parameter tuning for different datasets
datasets = [(X_moons, y_moons, "Moons"), (X_circles, y_circles, "Circles")]

for X, y_true, name in datasets:
    best_nmi = 0
    best_params = {}
    
    # Grid search over key parameters
    gamma_values = [0.1, 0.5, 1.0, 2.0, 5.0]
    n_neighbors_values = [5, 10, 15, 20]
    
    for gamma in gamma_values:
        spectral = SpectralClustering(
            n_clusters=2, 
            affinity='rbf', 
            gamma=gamma,
            random_state=42
        )
        labels = spectral.fit_predict(X)
        nmi = normalized_mutual_info_score(y_true, labels)
        
        if nmi > best_nmi:
            best_nmi = nmi
            best_params = {'affinity': 'rbf', 'gamma': gamma}
    
    for n_neighbors in n_neighbors_values:
        spectral = SpectralClustering(
            n_clusters=2,
            affinity='nearest_neighbors',
            n_neighbors=n_neighbors,
            random_state=42
        )
        labels = spectral.fit_predict(X)
        nmi = normalized_mutual_info_score(y_true, labels)
        
        if nmi > best_nmi:
            best_nmi = nmi
            best_params = {'affinity': 'nearest_neighbors', 'n_neighbors': n_neighbors}
    
    print(f"{name} dataset - Best NMI: {best_nmi:.3f}, Params: {best_params}")

# Eigenspace analysis
from sklearn.manifold import SpectralEmbedding

# Extract eigenspace embeddings
embedding = SpectralEmbedding(n_components=2, affinity='rbf', gamma=1.0)
X_embedded = embedding.fit_transform(X_moons)

# Apply KMeans to embeddings (what spectral clustering does internally)
kmeans_embedded = KMeans(n_clusters=2, random_state=42)
labels_embedded = kmeans_embedded.fit_predict(X_embedded)

print(f"Manual spectral NMI: {normalized_mutual_info_score(y_moons, labels_embedded):.3f}")
```

Spectral clustering transforms complex cluster identification into simpler problems by leveraging graph connectivity. Parameter selection depends on data density and local neighborhood structure, often requiring experimentation with affinity measures and their parameters.

**Conclusion:** Scikit-learn's clustering algorithms address diverse unsupervised learning scenarios through different mathematical foundations. KMeans provides efficient partitioning for spherical clusters, MiniBatchKMeans scales to massive datasets, AgglomerativeClustering reveals hierarchical structure, DBSCAN discovers arbitrary shapes while handling noise, and SpectralClustering leverages graph theory for complex geometries.

**Next Steps:** Advanced techniques include ensemble clustering methods combining multiple algorithms, semi-supervised clustering incorporating limited labeled data, streaming clustering for real-time applications, and specialized distance metrics or kernel functions tailored to specific domain requirements.

---

