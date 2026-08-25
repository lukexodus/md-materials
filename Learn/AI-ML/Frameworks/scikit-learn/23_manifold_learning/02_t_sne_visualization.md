## t-SNE Visualization


t-Distributed Stochastic Neighbor Embedding (t-SNE) is specifically designed for data visualization, excelling at revealing local structure and clusters in high-dimensional datasets. It constructs probability distributions over pairs of points in both high-dimensional and low-dimensional spaces, then minimizes the divergence between these distributions.

In scikit-learn, t-SNE is implemented through the `TSNE` class with key parameters including perplexity (balancing local vs global structure), learning rate, number of iterations, and initialization method. The algorithm first computes pairwise similarities using Gaussian distributions in high-dimensional space, then uses t-distributions in low-dimensional space to avoid crowding problems.

**Key points**: t-SNE is non-deterministic and results vary between runs; perplexity typically ranges from 5-50 depending on dataset size; it's computationally expensive for large datasets; the method preserves local structure better than global structure; clusters that appear close in t-SNE may not be close in original space.

**Example**: For gene expression data visualization, t-SNE can reveal cell type clusters that aren't apparent in the original high-dimensional gene space, with different perplexity values highlighting different granularities of clustering.## Isomap Embedding

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.manifold import TSNE
from sklearn.datasets import load_digits, make_swiss_roll
from sklearn.preprocessing import StandardScaler
import seaborn as sns

# Example 1: t-SNE on digits dataset
digits = load_digits()
X_digits, y_digits = digits.data, digits.target

# Standardize the data
scaler = StandardScaler()
X_digits_scaled = scaler.fit_transform(X_digits)

# Apply t-SNE with different perplexity values
perplexities = [5, 30, 50]
fig, axes = plt.subplots(1, 3, figsize=(15, 5))

for i, perp in enumerate(perplexities):
    tsne = TSNE(n_components=2, perplexity=perp, random_state=42, 
                learning_rate=200, n_iter=1000)
    X_tsne = tsne.fit_transform(X_digits_scaled)
    
    scatter = axes[i].scatter(X_tsne[:, 0], X_tsne[:, 1], 
                             c=y_digits, cmap='tab10', s=20, alpha=0.7)
    axes[i].set_title(f't-SNE (perplexity={perp})')
    axes[i].set_xlabel('t-SNE 1')
    axes[i].set_ylabel('t-SNE 2')

plt.tight_layout()
plt.show()

# Example 2: t-SNE parameter optimization
def evaluate_tsne_quality(X, embedding, k=10):
    """Calculate trustworthiness metric for t-SNE quality assessment"""
    from sklearn.neighbors import NearestNeighbors
    
    # Find k-nearest neighbors in original space
    nbrs_orig = NearestNeighbors(n_neighbors=k+1).fit(X)
    _, indices_orig = nbrs_orig.kneighbors(X)
    
    # Find k-nearest neighbors in embedding space
    nbrs_embed = NearestNeighbors(n_neighbors=k+1).fit(embedding)
    _, indices_embed = nbrs_embed.kneighbors(embedding)
    
    # Calculate trustworthiness
    n = X.shape[0]
    trustworthiness = 0
    
    for i in range(n):
        orig_neighbors = set(indices_orig[i, 1:])  # Exclude self
        embed_neighbors = set(indices_embed[i, 1:])  # Exclude self
        trustworthiness += len(orig_neighbors.intersection(embed_neighbors)) / k
    
    return trustworthiness / n

# Test different parameters
perplexity_range = [5, 10, 30, 50, 100]
learning_rates = [10, 50, 200, 1000]

results = []
for perp in perplexity_range:
    for lr in learning_rates:
        tsne = TSNE(n_components=2, perplexity=perp, learning_rate=lr,
                   random_state=42, n_iter=1000)
        embedding = tsne.fit_transform(X_digits_scaled[:500])  # Subset for speed
        
        quality = evaluate_tsne_quality(X_digits_scaled[:500], embedding)
        results.append({'perplexity': perp, 'learning_rate': lr, 'quality': quality})

# Find best parameters
best_result = max(results, key=lambda x: x['quality'])
print(f"Best parameters: perplexity={best_result['perplexity']}, "
      f"learning_rate={best_result['learning_rate']}, "
      f"quality={best_result['quality']:.3f}")

# Example 3: t-SNE for high-dimensional text-like data
np.random.seed(42)
# Simulate high-dimensional sparse data (like TF-IDF features)
n_samples, n_features = 1000, 5000
X_sparse = np.random.exponential(0.1, (n_samples, n_features))
X_sparse[X_sparse < 0.05] = 0  # Make it sparse

# Create artificial labels for visualization
y_sparse = np.repeat(range(10), n_samples // 10)

# Apply t-SNE with early exaggeration and PCA initialization
tsne_sparse = TSNE(n_components=2, perplexity=30, random_state=42,
                  init='pca', early_exaggeration=12, learning_rate='auto')
X_tsne_sparse = tsne_sparse.fit_transform(X_sparse)

plt.figure(figsize=(10, 8))
scatter = plt.scatter(X_tsne_sparse[:, 0], X_tsne_sparse[:, 1], 
                     c=y_sparse, cmap='tab10', alpha=0.6)
plt.title('t-SNE on High-Dimensional Sparse Data')
plt.xlabel('t-SNE 1')
plt.ylabel('t-SNE 2')
plt.colorbar(scatter)
plt.show()

print(f"Final KL divergence: {tsne_sparse.kl_divergence_:.2f}")
print(f"Number of iterations: {tsne_sparse.n_iter_}")
```

