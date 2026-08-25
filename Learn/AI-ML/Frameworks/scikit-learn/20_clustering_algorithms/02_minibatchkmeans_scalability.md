## MiniBatchKMeans Scalability


MiniBatchKMeans implements a variant using mini-batches of data for centroid updates, significantly reducing computation time for large datasets while maintaining clustering quality. This approach enables clustering millions of samples that would be infeasible with standard KMeans.

**Key Points:**

- Processes random mini-batches instead of entire dataset per iteration
- Dramatically faster training - often 3-10x speedup over standard KMeans
- Lower memory requirements suitable for out-of-core processing
- Slightly reduced clustering quality compared to full KMeans
- Convergence typically faster in wall-clock time despite more iterations
- Ideal for large datasets (>10,000 samples) or streaming data scenarios
- Batch size parameter controls memory-speed trade-off

The algorithm maintains moving averages of cluster centers updated with each mini-batch. Larger batch sizes improve stability but increase memory usage. The `max_no_improvement` parameter enables early stopping when convergence stalls.

**Example:**

```python
from sklearn.cluster import MiniBatchKMeans
from sklearn.datasets import make_blobs
import time

# Large dataset for scalability demonstration
X_large, _ = make_blobs(n_samples=100000, centers=20, n_features=50, 
                        random_state=42, cluster_std=2.0)

# Standard KMeans timing
start_time = time.time()
kmeans_standard = KMeans(n_clusters=20, random_state=42)
kmeans_standard.fit(X_large)
standard_time = time.time() - start_time

# MiniBatchKMeans with different batch sizes
start_time = time.time()
minibatch_kmeans = MiniBatchKMeans(
    n_clusters=20, 
    batch_size=1000,
    max_no_improvement=10,
    random_state=42
)
minibatch_kmeans.fit(X_large)
minibatch_time = time.time() - start_time

print(f"Standard KMeans time: {standard_time:.2f}s")
print(f"MiniBatch KMeans time: {minibatch_time:.2f}s")
print(f"Speedup: {standard_time/minibatch_time:.1f}x")

# Quality comparison
standard_inertia = kmeans_standard.inertia_
minibatch_inertia = minibatch_kmeans.inertia_
print(f"Quality ratio: {minibatch_inertia/standard_inertia:.3f}")

# Partial fit for streaming data
streaming_kmeans = MiniBatchKMeans(n_clusters=20, random_state=42)
for batch_start in range(0, len(X_large), 5000):
    batch_end = min(batch_start + 5000, len(X_large))
    streaming_kmeans.partial_fit(X_large[batch_start:batch_end])
```

MiniBatchKMeans excels in production environments requiring fast clustering updates or when memory constraints prevent loading entire datasets. The slight quality trade-off is often acceptable given substantial performance gains.

