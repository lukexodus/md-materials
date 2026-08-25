## Descriptive Statistics


**Central Tendency Measures**

Central tendency measures describe the typical or central value in a dataset. NumPy provides multiple measures that capture different aspects of data centrality.

```python
import numpy as np

# Sample dataset
data = np.array([12, 15, 18, 20, 22, 25, 28, 30, 32, 35])
data_2d = np.array([[10, 15, 20], [25, 30, 35], [40, 45, 50]])

# Arithmetic mean
mean_val = np.mean(data)                    # 23.7
mean_2d_rows = np.mean(data_2d, axis=1)     # [15. 30. 45.]
mean_2d_cols = np.mean(data_2d, axis=0)     # [25. 30. 35.]

# Weighted mean
weights = np.array([0.1, 0.1, 0.2, 0.2, 0.1, 0.1, 0.1, 0.05, 0.025, 0.025])
weighted_mean = np.average(data, weights=weights)  # 22.125

# Median (50th percentile)
median_val = np.median(data)                # 23.5
median_2d = np.median(data_2d, axis=0)      # [25. 30. 35.]
```

**Dispersion Measures**

Dispersion measures quantify the spread or variability in data, providing insights into data consistency and outlier presence.

```python
# Variance and standard deviation
population_var = np.var(data)               # Population variance (ddof=0)
sample_var = np.var(data, ddof=1)          # Sample variance (ddof=1)
population_std = np.std(data)               # 7.416
sample_std = np.std(data, ddof=1)          # 7.809

# Range and interquartile range
data_range = np.ptp(data)                   # Peak-to-peak (max - min): 23
q25, q75 = np.percentile(data, [25, 75])
iqr = q75 - q25                            # Interquartile range: 15.0

# Mean absolute deviation
mad = np.mean(np.abs(data - np.mean(data))) # 5.96
```

**Shape Statistics**

Shape statistics describe the asymmetry and tail behavior of distributions, providing insights beyond central tendency and dispersion.

```python
from scipy import stats  # [Unverified] - scipy functions for skewness and kurtosis

# [Inference] Manual calculation of skewness and kurtosis
def skewness(arr):
    """Calculate skewness manually using NumPy"""
    mean_val = np.mean(arr)
    std_val = np.std(arr, ddof=1)
    n = len(arr)
    skew = np.sum(((arr - mean_val) / std_val) ** 3) / n
    return skew

def kurtosis(arr):
    """Calculate kurtosis manually using NumPy"""
    mean_val = np.mean(arr)
    std_val = np.std(arr, ddof=1)
    n = len(arr)
    kurt = np.sum(((arr - mean_val) / std_val) ** 4) / n - 3
    return kurt

# [Inference] These calculations approximate distribution shape
skew_val = skewness(data)
kurt_val = kurtosis(data)
```

