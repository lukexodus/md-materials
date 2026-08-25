## QuantileUniformTransformer


QuantileUniformTransformer maps features to a uniform distribution using quantiles, making it robust to outliers and non-linear transformations.

**Key points:**

- Maps features to uniform distribution [0,1] or normal distribution
- Uses quantiles to determine transformation
- Handles outliers by clipping to specified quantile range
- Non-linear transformation that can improve model performance

```python
from sklearn.preprocessing import QuantileTransformer
import matplotlib.pyplot as plt

# Create skewed data
np.random.seed(42)
X_skewed = np.random.exponential(2, (1000, 1))

# Apply QuantileTransformer
qt_uniform = QuantileTransformer(output_distribution='uniform', random_state=42)
qt_normal = QuantileTransformer(output_distribution='normal', random_state=42)

X_uniform = qt_uniform.fit_transform(X_skewed)
X_normal = qt_normal.fit_transform(X_skewed)

print("Original data stats:")
print(f"Mean: {X_skewed.mean():.3f}, Std: {X_skewed.std():.3f}")
print(f"Min: {X_skewed.min():.3f}, Max: {X_skewed.max():.3f}")

print("\nUniform transformation stats:")
print(f"Mean: {X_uniform.mean():.3f}, Std: {X_uniform.std():.3f}")
print(f"Min: {X_uniform.min():.3f}, Max: {X_uniform.max():.3f}")

print("\nNormal transformation stats:")
print(f"Mean: {X_normal.mean():.3f}, Std: {X_normal.std():.3f}")
```

**Applications:**

- Highly skewed distributions
- Data with heavy tails or extreme outliers
- Preprocessing for algorithms assuming normal distributions
- Non-linear feature transformations
- Density estimation and anomaly detection

