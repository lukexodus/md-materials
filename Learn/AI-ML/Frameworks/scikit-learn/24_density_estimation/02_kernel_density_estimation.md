## Kernel Density Estimation


Kernel Density Estimation (KDE) provides non-parametric density estimation by placing kernel functions at each data point and summing their contributions. This approach makes no distributional assumptions and adapts to arbitrary data shapes through bandwidth parameter selection.

**Key Points:**

- Non-parametric method requiring no distributional assumptions
- Places kernel (typically Gaussian) at each training point with bandwidth parameter controlling smoothness
- Bandwidth selection critical - too small causes overfitting, too large oversmooths
- Supports various kernel functions: gaussian, tophat, epanechnikov, exponential, linear, cosine
- Cross-validation or likelihood-based methods for optimal bandwidth selection
- Scales poorly with dimensionality due to curse of dimensionality
- Provides smooth probability density estimates for visualization and sampling

The estimator computes density as weighted sum of kernels centered at training points. Bandwidth acts as smoothing parameter - smaller values create more detailed but noisier estimates, while larger values produce smoother but less accurate densities.

**Example:**

```python
from sklearn.neighbors import KernelDensity
from sklearn.model_selection import GridSearchCV
from sklearn.datasets import make_moons
import numpy as np

# Generate complex shaped dataset
X, _ = make_moons(n_samples=500, noise=0.1, random_state=42)

# Basic KDE with different kernels
kernels = ['gaussian', 'tophat', 'epanechnikov', 'exponential', 'linear', 'cosine']
kernel_results = {}

for kernel in kernels:
    kde = KernelDensity(kernel=kernel, bandwidth=0.2)
    kde.fit(X)
    log_likelihood = kde.score_samples(X)
    kernel_results[kernel] = {
        'kde': kde,
        'mean_log_likelihood': np.mean(log_likelihood)
    }

# Display kernel comparison
for kernel, results in kernel_results.items():
    print(f"{kernel}: Mean log-likelihood = {results['mean_log_likelihood']:.3f}")

# Bandwidth optimization using cross-validation
bandwidth_range = np.logspace(-2, 1, 20)
grid_search = GridSearchCV(
    KernelDensity(kernel='gaussian'),
    {'bandwidth': bandwidth_range},
    cv=5,
    scoring='neg_mean_squared_error'
)
grid_search.fit(X)

optimal_bandwidth = grid_search.best_params_['bandwidth']
print(f"Optimal bandwidth: {optimal_bandwidth:.3f}")

# Fit optimal KDE model
kde_optimal = KernelDensity(kernel='gaussian', bandwidth=optimal_bandwidth)
kde_optimal.fit(X)

# Density estimation on grid for visualization
x_min, x_max = X[:, 0].min() - 1, X[:, 0].max() + 1
y_min, y_max = X[:, 1].min() - 1, X[:, 1].max() + 1
xx, yy = np.meshgrid(np.linspace(x_min, x_max, 100),
                     np.linspace(y_min, y_max, 100))

grid_points = np.vstack([xx.ravel(), yy.ravel()]).T
log_density = kde_optimal.score_samples(grid_points)
density_grid = np.exp(log_density).reshape(xx.shape)

# Sample generation from density estimate
n_samples = 200
new_samples = kde_optimal.sample(n_samples, random_state=42)

# Multidimensional KDE performance analysis
dimensions = [1, 2, 5, 10, 20]
performance_results = {}

for dim in dimensions:
    # Generate high-dimensional data
    X_high_dim = np.random.multivariate_normal(
        mean=np.zeros(dim),
        cov=np.eye(dim),
        size=1000
    )
    
    kde_high_dim = KernelDensity(kernel='gaussian', bandwidth=0.5)
    kde_high_dim.fit(X_high_dim)
    
    # Cross-validation score
    scores = []
    for train_idx in range(0, 900, 100):
        train_data = X_high_dim[train_idx:train_idx+100]
        test_data = X_high_dim[train_idx+100:train_idx+200]
        kde_temp = KernelDensity(kernel='gaussian', bandwidth=0.5)
        kde_temp.fit(train_data)
        scores.append(kde_temp.score(test_data))
    
    performance_results[dim] = np.mean(scores)

print("KDE performance vs dimensionality:")
for dim, score in performance_results.items():
    print(f"Dimension {dim}: Score = {score:.3f}")
```

KDE provides flexible density estimation without parametric assumptions. Bandwidth selection through cross-validation balances bias-variance trade-off, while kernel choice affects boundary behavior and computational efficiency.

