## Principal Component Selection


Principal Component Analysis (PCA) finds orthogonal directions of maximum variance in the data, creating uncorrelated components that capture the most important patterns in high-dimensional datasets.

**Key points:**

- Finds linear combinations of features that maximize variance
- Components are orthogonal and ordered by explained variance
- Reduces dimensionality while preserving as much variance as possible
- Sensitive to feature scaling and outliers
- Assumes linear relationships between features

```python
from sklearn.decomposition import PCA
from sklearn.datasets import load_digits
import pandas as pd

# Load digits dataset for visualization
digits = load_digits()
X_digits, y_digits = digits.data, digits.target

# Apply PCA with different numbers of components
scaler = StandardScaler()
X_digits_scaled = scaler.fit_transform(X_digits)

# Determine optimal number of components
pca_full = PCA()
pca_full.fit(X_digits_scaled)

# Plot explained variance
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.plot(range(1, len(pca_full.explained_variance_ratio_) + 1), 
         np.cumsum(pca_full.explained_variance_ratio_))
plt.xlabel('Number of Components')
plt.ylabel('Cumulative Explained Variance Ratio')
plt.title('PCA Explained Variance')
plt.grid(True)

# Find number of components for 95% variance
n_components_95 = np.argmax(np.cumsum(pca_full.explained_variance_ratio_) >= 0.95) + 1
plt.axhline(y=0.95, color='r', linestyle='--', label=f'95% at {n_components_95} components')
plt.legend()

# Apply PCA with optimal components
pca_optimal = PCA(n_components=n_components_95)
X_digits_pca = pca_optimal.fit_transform(X_digits_scaled)

print(f"Original dimensions: {X_digits.shape[1]}")
print(f"Reduced dimensions: {X_digits_pca.shape[1]}")
print(f"Variance preserved: {np.sum(pca_optimal.explained_variance_ratio_):.4f}")

# Visualize first two components
plt.subplot(1, 2, 2)
scatter = plt.scatter(X_digits_pca[:, 0], X_digits_pca[:, 1], c=y_digits, cmap='tab10', alpha=0.7)
plt.xlabel(f'First PC (explained var: {pca_optimal.explained_variance_ratio_[0]:.3f})')
plt.ylabel(f'Second PC (explained var: {pca_optimal.explained_variance_ratio_[1]:.3f})')
plt.title('PCA: First Two Components')
plt.colorbar(scatter)

plt.tight_layout()
plt.show()

# Analyze component loadings
def analyze_pca_components(pca_model, feature_names, n_components=3):
    """Analyze and interpret PCA components"""
    components_df = pd.DataFrame(
        pca_model.components_[:n_components].T,
        columns=[f'PC{i+1}' for i in range(n_components)],
        index=feature_names if feature_names is not None else range(len(pca_model.components_[0]))
    )
    
    for i in range(n_components):
        print(f"\nPrincipal Component {i+1} (Explained Variance: {pca_model.explained_variance_ratio_[i]:.4f}):")
        # Get top contributing features
        component_loadings = np.abs(pca_model.components_[i])
        top_features = np.argsort(component_loadings)[-5:][::-1]
        
        for feature_idx in top_features:
            loading = pca_model.components_[i, feature_idx]
            feature_name = feature_names[feature_idx] if feature_names is not None else f"Feature_{feature_idx}"
            print(f"  {feature_name}: {loading:.4f}")
    
    return components_df

# For breast cancer dataset (more interpretable features)
X_breast, y_breast = load_breast_cancer(return_X_y=True)
breast_features = load_breast_cancer().feature_names

X_breast_scaled = StandardScaler().fit_transform(X_breast)
pca_breast = PCA(n_components=5)
X_breast_pca = pca_breast.fit_transform(X_breast_scaled)

components_analysis = analyze_pca_components(pca_breast, breast_features, n_components=3)
```

**Advanced PCA techniques:**

- **Incremental PCA**: For large datasets that don't fit in memory
- **Sparse PCA**: When you want interpretable components with few non-zero loadings
- **Kernel PCA**: For capturing non-linear relationships

```python
from sklearn.decomposition import IncrementalPCA, SparsePCA, KernelPCA

# Incremental PCA for large datasets
ipca = IncrementalPCA(n_components=10, batch_size=100)
X_ipca = ipca.fit_transform(X_digits_scaled)

# Sparse PCA for interpretability
spca = SparsePCA(n_components=5, alpha=0.1, random_state=42)
X_spca = spca.fit_transform(X_breast_scaled)

print(f"Sparse PCA - Non-zero loadings in first component: {np.count_nonzero(spca.components_[0])}")

# Kernel PCA for non-linear relationships
kpca = KernelPCA(n_components=10, kernel='rbf', gamma=0.01)
X_kpca = kpca.fit_transform(X_digits_scaled)

print(f"Original shape: {X_digits_scaled.shape}")
print(f"Kernel PCA shape: {X_kpca.shape}")
```

