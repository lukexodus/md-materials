## Statistical Functions


**Central Tendency Measures**

```python
# Sample data
data = np.array([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])
data_2d = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

# Mean calculations
mean_all = np.mean(data)          # 5.5
mean_2d = np.mean(data_2d)        # 5.0
mean_axis0 = np.mean(data_2d, axis=0)  # [4. 5. 6.]
mean_axis1 = np.mean(data_2d, axis=1)  # [2. 5. 8.]

# Median
median_val = np.median(data)      # 5.5
median_2d = np.median(data_2d, axis=0)  # [4. 5. 6.]
```

**Variance and Standard Deviation**

```python
# Variance calculations
var_population = np.var(data)     # Population variance (ddof=0)
var_sample = np.var(data, ddof=1) # Sample variance (ddof=1)

# Standard deviation
std_population = np.std(data)     # Population std
std_sample = np.std(data, ddof=1) # Sample std

# 2D array statistics
var_2d = np.var(data_2d, axis=0)  # Variance along columns
std_2d = np.std(data_2d, axis=1)  # Std along rows
```

**Percentiles and Quantiles**

```python
# Percentile calculations
data_large = np.random.normal(0, 1, 1000)
percentiles = np.percentile(data_large, [25, 50, 75])
quantiles = np.quantile(data_large, [0.25, 0.5, 0.75])

# Interquartile range
q75, q25 = np.percentile(data_large, [75, 25])
iqr = q75 - q25
```

