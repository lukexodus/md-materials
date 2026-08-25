## Normalizer Functionality


Normalizer scales individual samples to have unit norm, operating row-wise rather than column-wise like other scalers.

**Key points:**

- Works on individual samples (rows), not features (columns)
- Three norm options: l1, l2 (default), max
- Each row is scaled to have unit norm
- Preserves direction/angle between features within each sample

```python
from sklearn.preprocessing import Normalizer

# Different normalization methods
normalizer_l1 = Normalizer(norm='l1')
normalizer_l2 = Normalizer(norm='l2')
normalizer_max = Normalizer(norm='max')

X_norm_l1 = normalizer_l1.fit_transform(X)
X_norm_l2 = normalizer_l2.fit_transform(X)
X_norm_max = normalizer_max.fit_transform(X)

print("L1 normalization:")
print(X_norm_l1)
print(f"L1 norms: {np.linalg.norm(X_norm_l1, ord=1, axis=1)}")

print("\nL2 normalization:")
print(X_norm_l2)
print(f"L2 norms: {np.linalg.norm(X_norm_l2, ord=2, axis=1)}")

print("\nMax normalization:")
print(X_norm_max)
print(f"Max values per row: {np.max(np.abs(X_norm_max), axis=1)}")
```

**Applications:**

- Text processing (TF-IDF vectors)
- Cosine similarity calculations
- Neural networks with specific architectures
- Feature vectors representing proportions or ratios
- Clustering based on direction rather than magnitude

