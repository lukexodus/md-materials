## LocallyLinearEmbedding Methods


Locally Linear Embedding (LLE) preserves local linear relationships by assuming each point can be reconstructed as a linear combination of its neighbors. The algorithm finds these reconstruction weights, then uses them to find a low-dimensional embedding where the same linear relationships hold.

LLE operates in three stages: neighbor finding, weight computation, and embedding computation. First, it identifies k nearest neighbors for each point. Then it finds weights that best reconstruct each point from its neighbors by solving a constrained least squares problem. Finally, it computes low-dimensional coordinates that preserve these reconstruction relationships.

Scikit-learn implements several LLE variants through the `LocallyLinearEmbedding` class. Standard LLE works well for manifolds without holes but can suffer from regularization issues. Modified LLE adds regularization to handle cases where k > d (neighbors exceed intrinsic dimensionality). Hessian LLE uses Hessian-based weights to better preserve local geometry. LTSA (Local Tangent Space Alignment) aligns local tangent spaces rather than using reconstruction weights.

**Key points**: LLE is computationally efficient with O(DN log k + N k³) complexity; it naturally handles non-linear manifolds; the choice of k significantly affects results; it can struggle with non-uniform sampling and outliers; different variants handle specific geometric cases better.

**Example**: For face images with varying pose and lighting, LLE can discover a low-dimensional representation where similar faces cluster together, with smooth transitions between different expressions or orientations.

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import LocallyLinearEmbedding
from sklearn.datasets import make_swiss_roll, load_digits, fetch_olivetti_faces
from sklearn.preprocessing import StandardScaler
from sklearn.neighbors import NearestNeighbors
import warnings
warnings.filterwarnings('ignore')

# Example 1: Comparison of LLE variants on Swiss Roll
n_samples = 1000
X_swiss, color_swiss = make_swiss_roll(n_samples, noise=0.1, random_state=42)

# Different LLE methods
lle_methods = {
    'Standard LLE': {'method': 'standard'},
    'Modified LLE': {'method': 'modified', 'hessian_tol': 1e-4},
    'Hessian LLE': {'method': 'hessian', 'hessian_tol': 1e-4},
    'LTSA': {'method': 'ltsa'}
}

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
axes = axes.ravel()

for i, (name, params) in enumerate(lle_methods.items()):
    try:
        lle = LocallyLinearEmbedding(n_neighbors=12, n_components=2, 
                                   eigen_solver='auto', **params)
        X_lle = lle.fit_transform(X_swiss)
        
        scatter = axes[i].scatter(X_lle[:, 0], X_lle[:, 1], 
                                 c=color_swiss, cmap=plt.cm.Spectral)
        axes[i].set_title(f'{name}\nReconstruction Error: {lle.reconstruction_error_:.3f}')
        axes[i].set_xlabel('Component 1')
        axes[i].set_ylabel('Component 2')
        
    except Exception as e:
        axes[i].text(0.5, 0.5, f'{name}\nFailed: {str(e)[:50]}...', 
                    transform=axes[i].transAxes, ha='center', va='center')
        axes[i].set_title(name)

plt.tight_layout()
plt.show()

# Example 2: Neighborhood size optimization
def evaluate_lle_embedding(X, embedding, n_neighbors, method='standard'):
    """Evaluate LLE embedding quality using multiple metrics"""
    from sklearn.neighbors import NearestNeighbors
    
    # Trustworthiness metric
    nbrs_orig = NearestNeighbors(n_neighbors=n_neighbors+1).fit(X)
    _, indices_orig = nbrs_orig.kneighbors(X)
    
    nbrs_embed = NearestNeighbors(n_neighbors=n_neighbors+1).fit(embedding)
    _, indices_embed = nbrs_embed.kneighbors(embedding)
    
    trustworthiness = 0
    for i in range(X.shape[0]):
        orig_neighbors = set(indices_orig[i, 1:])
        embed_neighbors = set(indices_embed[i, 1:])
        trustworthiness += len(orig_neighbors.intersection(embed_neighbors)) / n_neighbors
    
    return trustworthiness / X.shape[0]

# Test different k values
k_values = range(5, 31, 2)
results = {'standard': [], 'modified': [], 'hessian': [], 'ltsa': []}

X_test = X_swiss[:500]  # Use subset for speed
color_test = color_swiss[:500]

for k in k_values:
    for method in results.keys():
        try:
            if method == 'standard':
                lle = LocallyLinearEmbedding(n_neighbors=k, n_components=2, method=method)
            else:
                lle = LocallyLinearEmbedding(n_neighbors=k, n_components=2, method=method, 
                                           hessian_tol=1e-4)
            
            embedding = lle.fit_transform(X_test)
            quality = evaluate_lle_embedding(X_test, embedding, k)
            results[method].append((k, quality, lle.reconstruction_error_))
            
        except:
            results[method].append((k, 0, np.inf))

# Plot optimization results
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

for method, method_results in results.items():
    if method_results:
        k_vals, qualities, errors = zip(*method_results)
        ax1.plot(k_vals, qualities, 'o-', label=method, linewidth=2)
        
        valid_errors = [e for e in errors if e != np.inf]
        if valid_errors:
            ax2.plot(k_vals[:len(valid_errors)], valid_errors, 'o-', label=method, linewidth=2)

ax1.set_xlabel('Number of Neighbors (k)')
ax1.set_ylabel('Trustworthiness')
ax1.set_title('LLE Quality vs. Neighborhood Size')
ax1.legend()
ax1.grid(True, alpha=0.3)

ax2.set_xlabel('Number of Neighbors (k)')
ax2.set_ylabel('Reconstruction Error')
ax2.set_title('LLE Reconstruction Error vs. Neighborhood Size')
ax2.legend()
ax2.grid(True, alpha=0.3)
ax2.set_yscale('log')

plt.tight_layout()
plt.show()

# Example 3: LLE on face images
try:
    # Load Olivetti faces dataset
    faces = fetch_olivetti_faces(shuffle=True, random_state=42)
    X_faces = faces.data
    
    # Use subset for demonstration
    n_faces = 200
    X_faces_subset = X_faces[:n_faces]
    
    # Apply standard LLE
    lle_faces = LocallyLinearEmbedding(n_neighbors=10, n_components=2, 
                                      method='modified', hessian_tol=1e-4)
    X_faces_lle = lle_faces.fit_transform(X_faces_subset)
    
    # Visualize embedding
    plt.figure(figsize=(12, 5))
    
    plt.subplot(121)
    # Show some original faces
    for i in range(25):
        plt.subplot(5, 10, i+1)
        plt.imshow(X_faces_subset[i].reshape(64, 64), cmap='gray')
        plt.axis('off')
    plt.suptitle('Original Face Images (subset)')
    
    plt.subplot(122)
    scatter = plt.scatter(X_faces_lle[:, 0], X_faces_lle[:, 1], 
                         c=range(n_faces), cmap='viridis', alpha=0.7)
    plt.title(f'LLE Embedding of Faces\nReconstruction Error: {lle_faces.reconstruction_error_:.3f}')
    plt.xlabel('LLE Component 1')
    plt.ylabel('LLE Component 2')
    plt.colorbar(scatter, label='Face Index')
    
    plt.tight_layout()
    plt.show()
    
except Exception as e:
    print(f"Face dataset example failed: {e}")
    print("This might be due to network issues in downloading the dataset")

# Example 4: Reconstruction weights analysis
def analyze_reconstruction_weights(X, n_neighbors=10):
    """Analyze the reconstruction weights computed by LLE"""
    lle = LocallyLinearEmbedding(n_neighbors=n_neighbors, n_components=2, method='standard')
    
    # Access the reconstruction weights (not directly available, so we'll compute them)
    from sklearn.neighbors import NearestNeighbors
    
    nbrs = NearestNeighbors(n_neighbors=n_neighbors+1).fit(X)
    _, indices = nbrs.kneighbors(X)
    
    weights = np.zeros((X.shape[0], X.shape[0]))
    
    for i in range(X.shape[0]):
        # Get neighbors (excluding self)
        neighbors = indices[i, 1:]
        
        # Solve for reconstruction weights
        Z = X[neighbors] - X[i]  # Center neighbors around current point
        C = np.dot(Z, Z.T)  # Local covariance matrix
        
        # Add regularization if needed
        if len(neighbors) > Z.shape[1]:
            C += 1e-3 * np.eye(len(neighbors))
        
        # Solve for weights
        try:
            w = np.linalg.solve(C, np.ones(len(neighbors)))
            w /= w.sum()  # Normalize weights to sum to 1
            weights[i, neighbors] = w
        except:
            # Fallback for singular matrices
            w = np.ones(len(neighbors)) / len(neighbors)
            weights[i, neighbors] = w
    
    return weights

# Analyze weights for a small subset
X_small = X_swiss[:100]
weights = analyze_reconstruction_weights(X_small, n_neighbors=8)

# Visualize weight distribution
plt.figure(figsize=(12, 8))

plt.subplot(221)
plt.imshow(weights, cmap='viridis', aspect='auto')
plt.title('Reconstruction Weight Matrix')
plt.xlabel('Data Point Index')
plt.ylabel('Data Point Index')
plt.colorbar()

plt.subplot(222)
weight_sums = weights.sum(axis=1)
plt.hist(weight_sums, bins=20, alpha=0.7)
plt.title('Distribution of Weight Sums')
plt.xlabel('Sum of Weights')
plt.ylabel('Frequency')

plt.subplot(223)
non_zero_weights = weights[weights > 1e-10]
plt.hist(non_zero_weights, bins=30, alpha=0.7)
plt.title('Distribution of Non-zero Weights')
plt.xlabel('Weight Value')
plt.ylabel('Frequency')

plt.subplot(224)
sparsity = (weights > 1e-10).sum(axis=1)
plt.hist(sparsity, bins=range(1, 15), alpha=0.7)
plt.title('Number of Non-zero Weights per Point')
plt.xlabel('Number of Non-zero Weights')
plt.ylabel('Frequency')

plt.tight_layout()
plt.show()

print(f"Average sparsity (non-zero weights per point): {sparsity.mean():.2f}")
print(f"Weight sum statistics: mean={weight_sums.mean():.3f}, std={weight_sums.std():.3f}")

# Example 5: Comparison with PCA on high-dimensional data
from sklearn.decomposition import PCA

# Generate high-dimensional data with intrinsic structure
np.random.seed(42)
n_samples = 800
# Create 2D manifold embedded in higher dimensions
t = np.random.uniform(0, 4*np.pi, n_samples)
s = np.random.uniform(0, 1, n_samples)

# Parametric surface (like a twisted ribbon)
X_3d = np.column_stack([
    t * np.cos(t) + 0.1 * s * np.sin(t),
    t * np.sin(t) + 0.1 * s * np.cos(t),
    s + 0.05 * t
])

# Embed in higher dimensions with noise
embedding_matrix = np.random.randn(3, 50)
X_high_dim = np.dot(X_3d, embedding_matrix) + 0.1 * np.random.randn(n_samples, 50)

# Compare PCA vs LLE on high-dimensional data
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_high_dim)

lle_hd = LocallyLinearEmbedding(n_neighbors=15, n_components=2, method='modified')
X_lle_hd = lle_hd.fit_transform(X_high_dim)

# Create color coding based on parameter t
color_param = t

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Original 3D structure
ax1 = fig.add_subplot(131, projection='3d')
scatter1 = ax1.scatter(X_3d[:, 0], X_3d[:, 1], X_3d[:, 2], 
                      c=color_param, cmap='viridis')
ax1.set_title('Original 3D Manifold')
ax1.set_xlabel('X')
ax1.set_ylabel('Y')
ax1.set_zlabel('Z')

# PCA embedding
scatter2 = axes[1].scatter(X_pca[:, 0], X_pca[:, 1], 
                          c=color_param, cmap='viridis')
axes[1].set_title(f'PCA Embedding\nExplained Variance: {pca.explained_variance_ratio_.sum():.3f}')
axes[1].set_xlabel('PC 1')
axes[1].set_ylabel('PC 2')

# LLE embedding
scatter3 = axes[2].scatter(X_lle_hd[:, 0], X_lle_hd[:, 1], 
                          c=color_param, cmap='viridis')
axes[2].set_title(f'LLE Embedding\nReconstruction Error: {lle_hd.reconstruction_error_:.3f}')
axes[2].set_xlabel('LLE 1')
axes[2].set_ylabel('LLE 2')

plt.tight_layout()
plt.show()

print(f"PCA explained variance ratio: {pca.explained_variance_ratio_}")
print(f"LLE reconstruction error: {lle_hd.reconstruction_error_:.6f}")

# Example 6: Robustness to noise analysis
def add_noise_and_test(X_clean, noise_levels, n_neighbors=12):
    """Test LLE robustness to different noise levels"""
    results = []
    
    for noise_level in noise_levels:
        # Add Gaussian noise
        noise = np.random.normal(0, noise_level, X_clean.shape)
        X_noisy = X_clean + noise
        
        # Apply LLE
        try:
            lle = LocallyLinearEmbedding(n_neighbors=n_neighbors, n_components=2, 
                                       method='modified', hessian_tol=1e-4)
            embedding = lle.fit_transform(X_noisy)
            error = lle.reconstruction_error_
            
            results.append({
                'noise_level': noise_level,
                'reconstruction_error': error,
                'embedding': embedding,
                'success': True
            })
        except:
            results.append({
                'noise_level': noise_level,
                'reconstruction_error': np.inf,
                'embedding': None,
                'success': False
            })
    
    return results

# Test noise robustness
noise_levels = [0.0, 0.05, 0.1, 0.15, 0.2, 0.3, 0.5]
X_clean = X_swiss[:300]  # Use smaller subset
color_clean = color_swiss[:300]

np.random.seed(42)
noise_results = add_noise_and_test(X_clean, noise_levels)

# Plot results
fig, axes = plt.subplots(2, 4, figsize=(16, 8))
axes = axes.ravel()

for i, result in enumerate(noise_results[:7]):  # Show first 7 results
    if result['success']:
        scatter = axes[i].scatter(result['embedding'][:, 0], result['embedding'][:, 1], 
                                 c=color_clean, cmap='viridis', alpha=0.6)
        axes[i].set_title(f'Noise Level: {result["noise_level"]:.2f}\n'
                         f'Recon. Error: {result["reconstruction_error"]:.3f}')
    else:
        axes[i].text(0.5, 0.5, f'Failed\nNoise Level: {result["noise_level"]:.2f}', 
                    transform=axes[i].transAxes, ha='center', va='center')
        axes[i].set_title(f'Noise Level: {result["noise_level"]:.2f}')
    
    axes[i].set_xlabel('LLE 1')
    axes[i].set_ylabel('LLE 2')

# Plot reconstruction error vs noise
if len(noise_results) > 7:
    successful_results = [r for r in noise_results if r['success']]
    noise_vals = [r['noise_level'] for r in successful_results]
    errors = [r['reconstruction_error'] for r in successful_results]
    
    axes[7].plot(noise_vals, errors, 'ro-', linewidth=2, markersize=8)
    axes[7].set_xlabel('Noise Level')
    axes[7].set_ylabel('Reconstruction Error')
    axes[7].set_title('LLE Robustness to Noise')
    axes[7].grid(True, alpha=0.3)
    axes[7].set_yscale('log')

plt.tight_layout()
plt.show()

print("\nNoise Robustness Summary:")
for result in noise_results:
    if result['success']:
        print(f"Noise {result['noise_level']:.2f}: Error = {result['reconstruction_error']:.4f}")
    else:
        print(f"Noise {result['noise_level']:.2f}: FAILED")
```

