## StandardScaler Implementation


StandardScaler transforms features to have zero mean and unit variance by subtracting the mean and dividing by the standard deviation. This transformation assumes features follow a Gaussian distribution.

**Key points:**

- Formula: (x - μ) / σ where μ is mean and σ is standard deviation
- Results in features with mean=0 and std=1
- Preserves the shape of the original distribution
- Sensitive to outliers since it uses mean and standard deviation

```python
from sklearn.preprocessing import StandardScaler
import numpy as np

# Create sample data
X = np.array([[1, 2, 3],
              [4, 5, 6],
              [7, 8, 9],
              [10, 11, 12]])

# Initialize and fit StandardScaler
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

print("Original data:")
print(X)
print("\nScaled data:")
print(X_scaled)
print(f"\nMean: {X_scaled.mean(axis=0)}")
print(f"Std: {X_scaled.std(axis=0)}")
```

**Applications:**

- Linear regression, logistic regression, neural networks
- Principal Component Analysis (PCA)
- Support Vector Machines (SVM)
- K-means clustering
- Any algorithm that uses distance calculations

