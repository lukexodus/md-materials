## RobustScaler Applications


RobustScaler uses median and interquartile range (IQR) instead of mean and standard deviation, making it robust to outliers.

**Key points:**

- Formula: (x - median) / IQR where IQR = Q3 - Q1
- Centers data around median with IQR scaling
- Less sensitive to outliers than StandardScaler
- Doesn't guarantee specific bounds like MinMaxScaler

```python
from sklearn.preprocessing import RobustScaler

# Create data with outliers
X_outliers = np.array([[1, 2],
                       [2, 3],
                       [3, 4],
                       [4, 5],
                       [100, 200]])  # Outlier

# Compare StandardScaler vs RobustScaler
standard_scaler = StandardScaler()
robust_scaler = RobustScaler()

X_standard = standard_scaler.fit_transform(X_outliers)
X_robust = robust_scaler.fit_transform(X_outliers)

print("Original data with outlier:")
print(X_outliers)
print("\nStandardScaler result:")
print(X_standard)
print("\nRobustScaler result:")
print(X_robust)
```

**Applications:**

- Datasets with significant outliers
- Preprocessing for outlier detection algorithms
- Time series data with anomalies
- Financial data with extreme values
- Medical data with measurement errors

