## Independent Component Analysis


Independent Component Analysis (ICA) separates multivariate signals into additive, independent components, making it particularly useful for blind source separation and finding hidden factors in data.

**Key points:**

- Finds statistically independent components rather than orthogonal ones
- Assumes data is a linear mixture of independent sources
- Components are not ordered by importance (unlike PCA)
- Excellent for signal separation and noise reduction
- Requires non-Gaussian data for effective separation

```python
from sklearn.decomposition import FastICA
from scipy import signal
import numpy as np

# Generate mixed signals example
np.random.seed(42)
n_samples = 2000
time = np.linspace(0, 8, n_samples)

# Create source signals
s1 = np.sin(2 * time) + 0.5 * np.sin(10 * time)  # Mixed frequencies
s2 = signal.sawtooth(2 * np.pi * time)  # Sawtooth wave
s3 = np.sign(np.sin(3 * time))  # Square wave

# Stack sources
S = np.c_[s1, s2, s3]
S += 0.2 * np.random.normal(size=S.shape)  # Add noise

# Create mixing matrix
A = np.array([[1, 1, 1],
              [0.5, 2, 1.0],
              [1.5, 1.0, 2.0]])

# Mix signals
X_mixed = np.dot(S, A.T)

# Apply ICA to separate signals
ica = FastICA(n_components=3, random_state=42)
S_restored = ica.fit_transform(X_mixed)

# Visualize results
fig, axes = plt.subplots(3, 3, figsize=(15, 10))

# Plot original sources
for i in range(3):
    axes[0, i].plot(time[:500], S[:500, i])
    axes[0, i].set_title(f'Original Source {i+1}')
    axes[0, i].set_ylabel('Amplitude')

# Plot mixed signals
for i in range(3):
    axes[1, i].plot(time[:500], X_mixed[:500, i])
    axes[1, i].set_title(f'Mixed Signal {i+1}')
    axes[1, i].set_ylabel('Amplitude')

# Plot restored sources
for i in range(3):
    axes[2, i].plot(time[:500], S_restored[:500, i])
    axes[2, i].set_title(f'ICA Component {i+1}')
    axes[2, i].set_xlabel('Time')
    axes[2, i].set_ylabel('Amplitude')

plt.tight_layout()
plt.show()

# Measure separation quality
def separation_quality(S_true, S_estimated):
    """Calculate separation quality using correlation"""
    correlations = []
    for i in range(S_true.shape[1]):
        best_match = 0
        for j in range(S_estimated.shape[1]):
            corr = np.abs(np.corrcoef(S_true[:, i], S_estimated[:, j])[0, 1])
            if corr > best_match:
                best_match = corr
        correlations.append(best_match)
    return np.mean(correlations)

quality_score = separation_quality(S, S_restored)
print(f"Signal separation quality: {quality_score:.4f}")
```

**ICA for real-world data applications:**

```python
# Apply ICA to image data (facial expressions)
from sklearn.datasets import fetch_olivetti_faces

# Load face dataset
faces = fetch_olivetti_faces(shuffle=True, random_state=42)
X_faces = faces.data

# Apply ICA to find independent facial components
ica_faces = FastICA(n_components=50, random_state=42, max_iter=1000)
X_faces_ica = ica_faces.fit_transform(X_faces)

# Compare with PCA
pca_faces = PCA(n_components=50)
X_faces_pca = pca_faces.fit_transform(X_faces)

# Visualize components
fig, axes = plt.subplots(2, 10, figsize=(20, 4))

# PCA components (eigenfaces)
for i in range(10):
    axes[0, i].imshow(pca_faces.components_[i].reshape(64, 64), cmap='gray')
    axes[0, i].set_title(f'PC {i+1}')
    axes[0, i].axis('off')

# ICA components (independent facial features)
for i in range(10):
    axes[1, i].imshow(ica_faces.components_[i].reshape(64, 64), cmap='gray')
    axes[1, i].set_title(f'IC {i+1}')
    axes[1, i].axis('off')

axes[0, 0].set_ylabel('PCA\nComponents')
axes[1, 0].set_ylabel('ICA\nComponents')
plt.tight_layout()
plt.show()

# Reconstruction quality comparison
def reconstruction_error(X_original, X_transformed, transformer):
    """Calculate reconstruction error"""
    if hasattr(transformer, 'inverse_transform'):
        X_reconstructed = transformer.inverse_transform(X_transformed)
    else:
        # For ICA, use mixing matrix to reconstruct
        X_reconstructed = np.dot(X_transformed, transformer.components_)
        X_reconstructed += transformer.mean_
    
    mse = np.mean((X_original - X_reconstructed) ** 2)
    return mse

pca_error = reconstruction_error(X_faces, X_faces_pca, pca_faces)
print(f"PCA reconstruction error: {pca_error:.6f}")
print(f"ICA focuses on independence rather than reconstruction quality")
```

