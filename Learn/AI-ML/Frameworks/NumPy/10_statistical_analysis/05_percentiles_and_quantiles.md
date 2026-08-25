## Percentiles and Quantiles


**Percentile Calculations**

```python
# Generate sample data
data = np.random.gamma(2, 2, size=1000)

# Common percentiles
percentiles_5 = np.percentile(data, [5, 25, 50, 75, 95])
# [0.41, 1.52, 2.77, 4.98, 9.12] (approximate values)

# Quantile calculations (equivalent to percentiles)
quantiles = np.quantile(data, [0.05, 0.25, 0.5, 0.75, 0.95])

# Deciles (10% intervals)
deciles = np.percentile(data, np.arange(10, 100, 10))

# Custom percentile ranges
custom_percentiles = np.percentile(data, [1, 5, 10, 90, 95, 99])
```

**Multidimensional Percentiles**

```python
# 2D data percentiles
data_2d = np.random.normal(0, 1, size=(100, 5))

# Percentiles along different axes
percentiles_axis0 = np.percentile(data_2d, [25, 50, 75], axis=0)  # Along columns
percentiles_axis1 = np.percentile(data_2d, [25, 50, 75], axis=1)  # Along rows

# Global percentiles (all elements)
global_percentiles = np.percentile(data_2d, [25, 50, 75])
```

**Percentile-based Statistics**

```python
# Percentile-based measures
def percentile_statistics(data):
    """Calculate various percentile-based statistics"""
    q25, q50, q75 = np.percentile(data, [25, 50, 75])
    
    stats = {
        'median': q50,
        'iqr': q75 - q25,
        'lower_fence': q25 - 1.5 * (q75 - q25),
        'upper_fence': q75 + 1.5 * (q75 - q25),
        'midhinge': (q25 + q75) / 2,
        'trimean': (q25 + 2*q50 + q75) / 4
    }
    return stats

# Outlier detection using percentiles
def detect_outliers_iqr(data):
    """Detect outliers using IQR method"""
    q25, q75 = np.percentile(data, [25, 75])
    iqr = q75 - q25
    lower_bound = q25 - 1.5 * iqr
    upper_bound = q75 + 1.5 * iqr
    return (data < lower_bound) | (data > upper_bound)

outliers = detect_outliers_iqr(data)
outlier_values = data[outliers]
```

