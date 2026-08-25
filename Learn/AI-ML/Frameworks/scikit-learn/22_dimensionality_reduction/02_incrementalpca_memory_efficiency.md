## IncrementalPCA Memory Efficiency


IncrementalPCA processes data in batches, enabling PCA on datasets too large to fit in memory while maintaining mathematical equivalence to standard PCA.

**Key points:**

- Processes data incrementally in mini-batches
- Memory-efficient for large datasets
- Mathematically equivalent to standard PCA
- Supports online learning and streaming data

```python
from sklearn.decomposition import IncrementalPCA
import numpy as np

# Generate large dataset simulation
def generate_large_dataset(n_samples=10000, n_features=1000, batch_size=200):
    """Simulate large dataset processing"""
    np.random.seed(42)
    # Generate data in batches to simulate large dataset
    for i in range(0, n_samples, batch_size):
        current_batch_size = min(batch_size, n_samples - i)
        X_batch = np.random.randn(current_batch_size, n_features)
        # Add some structure to the data
        X_batch[:, :50] += np.random.randn(50) * 3  # First 50 features have higher variance
        yield X_batch

# Incremental PCA fitting
ipca = IncrementalPCA(n_components=50, batch_size=200)

# Fit incrementally
for X_batch in generate_large_dataset():
    ipca.partial_fit(X_batch)

print(f"Explained variance ratio (first 10): {ipca.explained_variance_ratio_[:10]}")
print(f"Total variance explained: {ipca.explained_variance_ratio_.sum():.3f}")
```

**Comparing IncrementalPCA with standard PCA:**

```python
# Generate comparable dataset
X_large, _ = make_classification(n_samples=5000, n_features=500, n_informative=100, 
                                n_redundant=50, random_state=42)
X_large_scaled = StandardScaler().fit_transform(X_large)

# Standard PCA
pca_standard = PCA(n_components=50)
start_time = time.time()
X_pca_standard = pca_standard.fit_transform(X_large_scaled)
pca_time = time.time() - start_time

# Incremental PCA
ipca_comparison = IncrementalPCA(n_components=50, batch_size=500)
start_time = time.time()
X_pca_incremental = ipca_comparison.fit_transform(X_large_scaled)
ipca_time = time.time() - start_time

# Compare results
correlation = np.corrcoef(X_pca_standard.flatten(), X_pca_incremental.flatten())[0, 1]
print(f"Standard PCA time: {pca_time:.3f}s")
print(f"Incremental PCA time: {ipca_time:.3f}s")
print(f"Correlation between results: {abs(correlation):.6f}")

# Variance explanation comparison
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.plot(pca_standard.explained_variance_ratio_[:20], 'b-o', label='Standard PCA', markersize=4)
plt.plot(ipca_comparison.explained_variance_ratio_[:20], 'r--s', label='Incremental PCA', markersize=4)
plt.xlabel('Component')
plt.ylabel('Explained Variance Ratio')
plt.legend()
plt.title('Explained Variance Comparison')

plt.subplot(1, 2, 2)
plt.plot(np.cumsum(pca_standard.explained_variance_ratio_), 'b-', label='Standard PCA')
plt.plot(np.cumsum(ipca_comparison.explained_variance_ratio_), 'r--', label='Incremental PCA')
plt.xlabel('Component')
plt.ylabel('Cumulative Explained Variance')
plt.legend()
plt.title('Cumulative Variance Comparison')
```

**Streaming data processing:**

```python
class StreamingPCAProcessor:
    def __init__(self, n_components, batch_size=100):
        self.ipca = IncrementalPCA(n_components=n_components, batch_size=batch_size)
        self.n_samples_seen = 0
        self.is_fitted = False
    
    def process_batch(self, X_batch):
        """Process a new batch of data"""
        if not self.is_fitted:
            self.ipca.partial_fit(X_batch)
            self.is_fitted = True
        else:
            # Update with new batch
            self.ipca.partial_fit(X_batch)
        
        self.n_samples_seen += X_batch.shape[0]
        return self.ipca.transform(X_batch)
    
    def get_components(self):
        """Get current principal components"""
        if self.is_fitted:
            return self.ipca.components_
        return None
    
    def get_explained_variance_ratio(self):
        """Get current explained variance ratios"""
        if self.is_fitted:
            return self.ipca.explained_variance_ratio_
        return None

# **Example** usage with streaming data
streaming_processor = StreamingPCAProcessor(n_components=20)

# Simulate streaming data processing
explained_variance_history = []
for i, X_batch in enumerate(generate_large_dataset(n_samples=2000, batch_size=100)):
    X_transformed = streaming_processor.process_batch(X_batch)
    
    if i % 5 == 0:  # Record every 5 batches
        var_ratio = streaming_processor.get_explained_variance_ratio()
        if var_ratio is not None:
            explained_variance_history.append(var_ratio.copy())

# Plot evolution of explained variance
plt.figure(figsize=(10, 6))
for i, var_ratio in enumerate(explained_variance_history):
    plt.plot(var_ratio[:10], alpha=0.7, label=f'After {(i+1)*5} batches')

plt.xlabel('Component')
plt.ylabel('Explained Variance Ratio')
plt.title('Evolution of Explained Variance in Streaming PCA')
plt.legend()
plt.grid(True)
```

