## Isomap Embedding


Isomap (Isometric Mapping) extends classical MDS by using geodesic distances instead of Euclidean distances. It constructs a neighborhood graph, computes shortest path distances between all points, then applies classical MDS to these geodesic distances to find a low-dimensional embedding.

The algorithm begins by finding k-nearest neighbors or ε-neighborhoods for each point, creating a graph where edges represent local neighborhoods. Dijkstra's algorithm computes shortest path distances between all pairs of points, approximating geodesic distances along the manifold. Classical MDS then embeds these distances into lower dimensions.

**Key points**: Isomap assumes the manifold is isometric to a convex region of Euclidean space; it requires the neighborhood graph to be connected; performance depends heavily on neighborhood parameter selection; it can handle non-linear manifolds but struggles with holes or complex topologies; computational complexity is O(N³) making it challenging for large datasets.

In scikit-learn, the `Isomap` class provides parameters for number of neighbors, radius for neighborhood selection, number of components, and distance metrics. The method works well for manifolds that can be "unrolled" without tearing or stretching.

**Example**: For Swiss roll data, Isomap successfully unfolds the rolled structure, while PCA would fail to capture the non-linear relationship. However, for datasets with holes or disconnected components, Isomap may produce artifacts.## LocallyLinearEmbedding Methods

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import Isomap
from sklearn.datasets import make_swiss_roll, make_s_curve
from sklearn.decomposition import PCA
from sklearn.neighbors import kneighbors_graph
from mpl_toolkits.mplot3d import Axes3D
import networkx as nx

# Example 1: Isomap on Swiss Roll dataset
n_samples = 1500
X_swiss, color_swiss = make_swiss_roll(n_samples, noise=0.1, random_state=42)

# Apply different methods for comparison
methods = {
    'Original 3D': X_swiss,
    'PCA': PCA(n_components=2).fit_transform(X_swiss),
    'Isomap (k=10)': Isomap(n_neighbors=10, n_components=2).fit_transform(X_swiss),
    'Isomap (k=30)': Isomap(n_neighbors=30, n_components=2).fit_transform(X_swiss)
}

fig = plt.figure(figsize=(16, 4))

# Plot original 3D data
ax1 = fig.add_subplot(141, projection='3d')
ax1.scatter(X_swiss[:, 0], X_swiss[:, 1], X_swiss[:, 2], c=color_swiss, cmap=plt.cm.Spectral)
ax1.set_title('Original 3D Swiss Roll')
ax1.view_init(azim=-66, elev=12)

# Plot 2D embeddings
axes = [fig.add_subplot(142), fig.add_subplot(143), fig.add_subplot(144)]
titles = ['PCA', 'Isomap (k=10)', 'Isomap (k=30)']

for i, (method, embedding) in enumerate(list(methods.items())[1:]):
    scatter = axes[i].scatter(embedding[:, 0], embedding[:, 1], 
                             c=color_swiss, cmap=plt.cm.Spectral)
    axes[i].set_title(titles[i])
    axes[i].set_xlabel('Component 1')
    axes[i].set_ylabel('Component 2')

plt.tight_layout()
plt.show()

# Example 2: Neighborhood connectivity analysis
def check_connectivity(X, k_values):
    """Check if neighborhood graph is connected for different k values"""
    connectivity_results = {}
    
    for k in k_values:
        # Build k-nearest neighbor graph
        knn_graph = kneighbors_graph(X, n_neighbors=k, mode='connectivity', 
                                   include_self=False)
        
        # Convert to NetworkX graph and check connectivity
        G = nx.from_scipy_sparse_matrix(knn_graph)
        is_connected = nx.is_connected(G)
        n_components = nx.number_connected_components(G)
        
        connectivity_results[k] = {
            'connected': is_connected,
            'n_components': n_components
        }
    
    return connectivity_results

# Test connectivity for Swiss roll
k_values = range(5, 51, 5)
connectivity = check_connectivity(X_swiss, k_values)

print("Neighborhood Connectivity Analysis:")
for k, result in connectivity.items():
    print(f"k={k:2d}: Connected={result['connected']}, "
          f"Components={result['n_components']}")

# Find minimum k for connectivity
min_k_connected = min(k for k, result in connectivity.items() 
                     if result['connected'])
print(f"\nMinimum k for connected graph: {min_k_connected}")

# Example 3: Isomap with different distance metrics
from sklearn.datasets import load_digits

digits = load_digits()
X_digits = digits.data
y_digits = digits.target

# Apply Isomap with different distance metrics
distance_metrics = ['euclidean', 'manhattan', 'cosine']
embeddings = {}

for metric in distance_metrics:
    isomap = Isomap(n_neighbors=10, n_components=2, metric=metric)
    embedding = isomap.fit_transform(X_digits)
    embeddings[metric] = embedding

# Plot results
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for i, (metric, embedding) in enumerate(embeddings.items()):
    scatter = axes[i].scatter(embedding[:, 0], embedding[:, 1], 
                             c=y_digits, cmap='tab10', alpha=0.6)
    axes[i].set_title(f'Isomap ({metric} distance)')
    axes[i].set_xlabel('Component 1')
    axes[i].set_ylabel('Component 2')

plt.tight_layout()
plt.show()

# Example 4: Isomap reconstruction error analysis
def compute_reconstruction_error(X_original, X_embedded, isomap_model):
    """Compute reconstruction error for Isomap embedding"""
    # Get geodesic distances from the model
    geodesic_distances = isomap_model.dist_matrix_
    
    # Compute Euclidean distances in embedding space
    from sklearn.metrics.pairwise import euclidean_distances
    embedded_distances = euclidean_distances(X_embedded)
    
    # Calculate normalized reconstruction error
    error = np.sqrt(np.sum((geodesic_distances - embedded_distances)**2) / 
                   np.sum(geodesic_distances**2))
    
    return error

# Test different k values for reconstruction quality
k_range = [5, 10, 15, 20, 30, 40, 50]
errors = []

for k in k_range:
    try:
        isomap = Isomap(n_neighbors=k, n_components=2)
        embedding = isomap.fit_transform(X_swiss)
        error = compute_reconstruction_error(X_swiss, embedding, isomap)
        errors.append(error)
    except:
        errors.append(np.nan)

plt.figure(figsize=(10, 6))
plt.plot(k_range, errors, 'bo-', linewidth=2, markersize=8)
plt.xlabel('Number of Neighbors (k)')
plt.ylabel('Reconstruction Error')
plt.title('Isomap Reconstruction Error vs. Neighborhood Size')
plt.grid(True, alpha=0.3)

# Find optimal k
valid_errors = [(k, e) for k, e in zip(k_range, errors) if not np.isnan(e)]
optimal_k = min(valid_errors, key=lambda x: x[1])[0]
plt.axvline(x=optimal_k, color='red', linestyle='--', 
           label=f'Optimal k={optimal_k}')
plt.legend()
plt.show()

print(f"Optimal number of neighbors: {optimal_k}")
print(f"Minimum reconstruction error: {min(e for e in errors if not np.isnan(e)):.4f}")

# Example 5: Handling disconnected components
def create_disconnected_manifold():
    """Create a dataset with disconnected components"""
    # Create two separate Swiss rolls
    X1, color1 = make_swiss_roll(n_samples=500, noise=0.1, random_state=42)
    X2, color2 = make_swiss_roll(n_samples=500, noise=0.1, random_state=43)
    
    # Separate the components
    X2 += [10, 0, 10]  # Translate second component
    color2 += color1.max() + 1  # Different color range
    
    X_disconnected = np.vstack([X1, X2])
    color_disconnected = np.hstack([color1, color2])
    
    return X_disconnected, color_disconnected

X_disc, color_disc = create_disconnected_manifold()

# Apply Isomap to disconnected data
isomap_disc = Isomap(n_neighbors=10, n_components=2)
try:
    embedding_disc = isomap_disc.fit_transform(X_disc)
    
    fig = plt.figure(figsize=(12, 5))
    
    ax1 = fig.add_subplot(121, projection='3d')
    ax1.scatter(X_disc[:, 0], X_disc[:, 1], X_disc[:, 2], c=color_disc, cmap='viridis')
    ax1.set_title('Disconnected 3D Manifolds')
    
    ax2 = fig.add_subplot(122)
    scatter = ax2.scatter(embedding_disc[:, 0], embedding_disc[:, 1], 
                         c=color_disc, cmap='viridis')
    ax2.set_title('Isomap Embedding (Disconnected)')
    ax2.set_xlabel('Component 1')
    ax2.set_ylabel('Component 2')
    
    plt.tight_layout()
    plt.show()
    
except Exception as e:
    print(f"Isomap failed on disconnected data: {e}")
    print("This demonstrates the importance of connectivity in Isomap")
```

