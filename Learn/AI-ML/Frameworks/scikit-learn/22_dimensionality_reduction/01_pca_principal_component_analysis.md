## PCA Principal Component Analysis


Principal Component Analysis finds orthogonal linear combinations of features that maximize variance, providing optimal low-dimensional representation for Gaussian-distributed data.

**Key points:**

- Finds principal components as eigenvectors of covariance matrix
- Components ordered by explained variance (eigenvalues)
- Preserves maximum variance in reduced dimensions
- Assumes linear relationships and centered data

```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from sklearn.datasets import load_digits, make_classification
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split

# Load high-dimensional dataset
digits = load_digits()
X, y = digits.data, digits.target

# Standardize features (important for PCA)
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Basic PCA implementation
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X_scaled)

print(f"Original shape: {X.shape}")
print(f"Transformed shape: {X_pca.shape}")
print(f"Explained variance ratio: {pca.explained_variance_ratio_}")
print(f"Total variance explained: {pca.explained_variance_ratio_.sum():.3f}")

# Visualize 2D PCA projection
plt.figure(figsize=(10, 8))
scatter = plt.scatter(X_pca[:, 0], X_pca[:, 1], c=y, cmap='tab10', alpha=0.7)
plt.colorbar(scatter)
plt.xlabel(f'PC1 ({pca.explained_variance_ratio_[0]:.1%} variance)')
plt.ylabel(f'PC2 ({pca.explained_variance_ratio_[1]:.1%} variance)')
plt.title('PCA of Digits Dataset')
```

**Determining optimal number of components:**

```python
# Explained variance analysis
pca_full = PCA()
pca_full.fit(X_scaled)

# Plot cumulative explained variance
cumvar = np.cumsum(pca_full.explained_variance_ratio_)
plt.figure(figsize=(12, 5))

plt.subplot(1, 2, 1)
plt.plot(range(1, len(cumvar) + 1), cumvar, 'bo-')
plt.axhline(y=0.95, color='r', linestyle='--', label='95% variance')
plt.axhline(y=0.99, color='g', linestyle='--', label='99% variance')
plt.xlabel('Number of Components')
plt.ylabel('Cumulative Explained Variance')
plt.legend()
plt.grid(True)

plt.subplot(1, 2, 2)
plt.plot(range(1, 21), pca_full.explained_variance_ratio_[:20], 'ro-')
plt.xlabel('Component Number')
plt.ylabel('Individual Explained Variance')
plt.title('Scree Plot')
plt.grid(True)

# Find components for 95% variance
n_components_95 = np.argmax(cumvar >= 0.95) + 1
print(f"Components needed for 95% variance: {n_components_95}")
```

**PCA for reconstruction and denoising:**

```python
# Reconstruction with different numbers of components
def reconstruct_image(X, n_components):
    pca_recon = PCA(n_components=n_components)
    X_transformed = pca_recon.fit_transform(X)
    X_reconstructed = pca_recon.inverse_transform(X_transformed)
    return X_reconstructed, pca_recon.explained_variance_ratio_.sum()

# Compare reconstructions
fig, axes = plt.subplots(2, 4, figsize=(15, 8))
original_image = X[0].reshape(8, 8)
axes[0, 0].imshow(original_image, cmap='gray')
axes[0, 0].set_title('Original')

components_list = [1, 5, 10, 20]
for i, n_comp in enumerate(components_list):
    recon, var_exp = reconstruct_image(X_scaled, n_comp)
    recon_image = recon[0].reshape(8, 8)
    
    axes[0, i+1].imshow(recon_image, cmap='gray')
    axes[0, i+1].set_title(f'{n_comp} components\n({var_exp:.1%} variance)')

# Reconstruction error analysis
reconstruction_errors = []
component_range = range(1, 65)

for n_comp in component_range:
    pca_temp = PCA(n_components=n_comp)
    X_temp = pca_temp.fit_transform(X_scaled)
    X_recon = pca_temp.inverse_transform(X_temp)
    mse = np.mean((X_scaled - X_recon) ** 2)
    reconstruction_errors.append(mse)

axes[1, 0].plot(component_range, reconstruction_errors)
axes[1, 0].set_xlabel('Number of Components')
axes[1, 0].set_ylabel('Reconstruction Error (MSE)')
axes[1, 0].set_title('PCA Reconstruction Error')
axes[1, 0].grid(True)
```

**Advanced PCA techniques:**

```python
# Whitened PCA (uncorrelated components with unit variance)
pca_whitened = PCA(n_components=10, whiten=True)
X_whitened = pca_whitened.fit_transform(X_scaled)

print(f"Whitened data covariance:\n{np.cov(X_whitened.T)[:3, :3]}")

# Probabilistic PCA with missing values
from sklearn.experimental import enable_iterative_imputer
from sklearn.impute import IterativeImputer

# Introduce missing values
X_missing = X_scaled.copy()
missing_mask = np.random.random(X_missing.shape) < 0.1
X_missing[missing_mask] = np.nan

# Impute and apply PCA
imputer = IterativeImputer(random_state=42)
X_imputed = imputer.fit_transform(X_missing)
pca_imputed = PCA(n_components=10)
X_pca_imputed = pca_imputed.fit_transform(X_imputed)
```

