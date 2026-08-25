## KernelPCA Nonlinear Reduction


Kernel PCA extends PCA to nonlinear dimensionality reduction by implicitly mapping data to higher-dimensional feature spaces using kernel functions.

**Key points:**

- Uses kernel trick to capture nonlinear relationships
- Maps data to high-dimensional space implicitly
- Supports various kernels: RBF, polynomial, sigmoid, custom
- More computationally expensive than linear PCA

```python
from sklearn.decomposition import KernelPCA
from sklearn.datasets import make_swiss_roll, make_circles

# Generate nonlinear datasets
swiss_roll, swiss_colors = make_swiss_roll(n_samples=1000, random_state=42)
circles, circle_colors = make_circles(n_samples=1000, factor=0.3, noise=0.1, random_state=42)

# Different kernel types
kernels = {
    'linear': KernelPCA(n_components=2, kernel='linear'),
    'rbf': KernelPCA(n_components=2, kernel='rbf', gamma=0.1),
    'poly': KernelPCA(n_components=2, kernel='poly', degree=3),
    'sigmoid': KernelPCA(n_components=2, kernel='sigmoid', gamma=0.01)
}

# Apply Kernel PCA to circles dataset
fig, axes = plt.subplots(2, 3, figsize=(15, 10))

# Original data
axes[0, 0].scatter(circles[:, 0], circles[:, 1], c=circle_colors, cmap='viridis')
axes[0, 0].set_title('Original Circles Data')

# Standard PCA for comparison
pca_linear = PCA(n_components=2)
circles_pca = pca_linear.fit_transform(circles)
axes[0, 1].scatter(circles_pca[:, 0], circles_pca[:, 1], c=circle_colors, cmap='viridis')
axes[0, 1].set_title('Standard PCA')

# Kernel PCA results
plot_idx = 2
for kernel_name, kpca in kernels.items():
    if kernel_name == 'linear':
        continue
    
    circles_kpca = kpca.fit_transform(circles)
    row = 0 if plot_idx < 5 else 1
    col = plot_idx if plot_idx < 5 else plot_idx - 3
    
    axes[row, col].scatter(circles_kpca[:, 0], circles_kpca[:, 1], 
                          c=circle_colors, cmap='viridis')
    axes[row, col].set_title(f'Kernel PCA ({kernel_name})')
    plot_idx += 1

plt.tight_layout()
```

**RBF Kernel PCA parameter tuning:**

```python
# Grid search for optimal gamma in RBF kernel
from sklearn.model_selection import GridSearchCV
from sklearn.pipeline import Pipeline
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

# Create pipeline with Kernel PCA and classifier
def evaluate_kpca_gamma(X, y, gamma_values):
    results = {}
    
    for gamma in gamma_values:
        # Apply Kernel PCA
        kpca = KernelPCA(n_components=10, kernel='rbf', gamma=gamma)
        X_kpca = kpca.fit_transform(X)
        
        # Train classifier on reduced data
        X_train, X_test, y_train, y_test = train_test_split(
            X_kpca, y, test_size=0.3, random_state=42)
        
        clf = LogisticRegression()
        clf.fit(X_train, y_train)
        accuracy = clf.score(X_test, y_test)
        
        results[gamma] = {
            'accuracy': accuracy,
            'n_components': X_kpca.shape[1],
            'kpca': kpca
        }
    
    return results

# Test different gamma values
gamma_values = [0.001, 0.01, 0.1, 1.0, 10.0]
results = evaluate_kpca_gamma(circles, circle_colors, gamma_values)

# Plot results
gammas = list(results.keys())
accuracies = [results[g]['accuracy'] for g in gammas]

plt.figure(figsize=(10, 6))
plt.semilogx(gammas, accuracies, 'bo-')
plt.xlabel('Gamma Parameter')
plt.ylabel('Classification Accuracy')
plt.title('Kernel PCA RBF Gamma Parameter Tuning')
plt.grid(True)

best_gamma = gammas[np.argmax(accuracies)]
print(f"Best gamma: {best_gamma} with accuracy: {max(accuracies):.3f}")
```

**Custom kernel implementation:**

```python
# Custom kernel function
def custom_polynomial_kernel(X, Y=None, degree=3, coef0=1):
    """Custom polynomial kernel with different parameters"""
    if Y is None:
        Y = X
    return (np.dot(X, Y.T) + coef0) ** degree

# Using custom kernel with Kernel PCA
from sklearn.metrics.pairwise import pairwise_kernels

class CustomKernelPCA:
    def __init__(self, n_components, kernel_func, **kernel_params):
        self.n_components = n_components
        self.kernel_func = kernel_func
        self.kernel_params = kernel_params
        
    def fit_transform(self, X):
        # Compute kernel matrix
        K = self.kernel_func(X, **self.kernel_params)
        
        # Center kernel matrix
        n = K.shape[0]
        one_n = np.ones((n, n)) / n
        K_centered = K - one_n @ K - K @ one_n + one_n @ K @ one_n
        
        # Eigendecomposition
        eigenvals, eigenvecs = np.linalg.eigh(K_centered)
        
        # Sort by eigenvalues (descending)
        idx = np.argsort(eigenvals)[::-1]
        eigenvals = eigenvals[idx]
        eigenvecs = eigenvecs[:, idx]
        
        # Select top components
        self.eigenvals_ = eigenvals[:self.n_components]
        self.eigenvecs_ = eigenvecs[:, :self.n_components]
        
        # Transform data
        return self.eigenvecs_ * np.sqrt(np.maximum(self.eigenvals_, 0))

# **Example** usage
custom_kpca = CustomKernelPCA(n_components=2, kernel_func=custom_polynomial_kernel, 
                             degree=3, coef0=1)
circles_custom = custom_kpca.fit_transform(circles)

plt.figure(figsize=(12, 4))
plt.subplot(1, 3, 1)
plt.scatter(circles[:, 0], circles[:, 1], c=circle_colors)
plt.title('Original Data')

plt.subplot(1, 3, 2)
plt.scatter(circles_custom[:, 0], circles_custom[:, 1], c=circle_colors)
plt.title('Custom Kernel PCA')

# Compare with scikit-learn's polynomial kernel
kpca_poly = KernelPCA(n_components=2, kernel='poly', degree=3, coef0=1)
circles_sklearn = kpca_poly.fit_transform(circles)
plt.subplot(1, 3, 3)
plt.scatter(circles_sklearn[:, 0], circles_sklearn[:, 1], c=circle_colors)
plt.title('Scikit-learn Polynomial Kernel PCA')
```

