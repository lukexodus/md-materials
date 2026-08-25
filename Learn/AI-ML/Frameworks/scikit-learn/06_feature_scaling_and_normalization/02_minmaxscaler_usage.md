## MinMaxScaler Usage


MinMaxScaler transforms features to a fixed range, typically [0,1], by scaling each feature proportionally between its minimum and maximum values.

**Key points:**

- Formula: (x - min) / (max - min)
- Default range is [0,1], customizable with feature_range parameter
- Preserves relationships between data points
- Sensitive to outliers as they define the min/max bounds

```python
from sklearn.preprocessing import MinMaxScaler

# Initialize MinMaxScaler with different ranges
scaler_01 = MinMaxScaler()  # Default [0,1]
scaler_custom = MinMaxScaler(feature_range=(-1, 1))

# Transform data
X_minmax_01 = scaler_01.fit_transform(X)
X_minmax_custom = scaler_custom.fit_transform(X)

print("MinMax [0,1]:")
print(X_minmax_01)
print(f"Min: {X_minmax_01.min(axis=0)}")
print(f"Max: {X_minmax_01.max(axis=0)}")

print("\nMinMax [-1,1]:")
print(X_minmax_custom)
```

**Applications:**

- Neural networks (especially when using sigmoid/tanh activations)
- Image processing (pixel values)
- Bounded optimization algorithms
- When you need features in a specific range
- Algorithms sensitive to feature magnitude

