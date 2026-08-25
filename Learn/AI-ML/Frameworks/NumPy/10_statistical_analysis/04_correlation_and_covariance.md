## Correlation and Covariance


**Correlation Analysis**

```python
# Generate correlated data
n_samples = 1000
x1 = np.random.normal(0, 1, n_samples)
x2 = 0.8 * x1 + 0.6 * np.random.normal(0, 1, n_samples)  # Correlated with x1
x3 = np.random.normal(0, 1, n_samples)  # Independent

data_matrix = np.column_stack([x1, x2, x3])

# Pearson correlation coefficient
correlation_matrix = np.corrcoef(data_matrix.T)
# [[1.    0.8   0.05 ]
#  [0.8   1.    0.04 ]
#  [0.05  0.04  1.   ]]

# Pairwise correlations
corr_x1_x2 = np.corrcoef(x1, x2)[0, 1]  # Should be approximately 0.8
```

**Covariance Analysis**

```python
# Covariance matrix
covariance_matrix = np.cov(data_matrix.T)

# Manual covariance calculation
def covariance(x, y):
    """Calculate covariance between two variables"""
    x_mean, y_mean = np.mean(x), np.mean(y)
    return np.mean((x - x_mean) * (y - y_mean))

manual_cov = covariance(x1, x2)

# Population vs sample covariance
pop_cov = np.cov(x1, x2, ddof=0)  # Population covariance
sample_cov = np.cov(x1, x2, ddof=1)  # Sample covariance (default)
```

**Rank Correlation**

```python
# [Inference] Spearman rank correlation implementation
def spearman_correlation(x, y):
    """Calculate Spearman rank correlation"""
    x_ranks = np.argsort(np.argsort(x)) + 1
    y_ranks = np.argsort(np.argsort(y)) + 1
    return np.corrcoef(x_ranks, y_ranks)[0, 1]

# Example with non-linear relationship
x_nonlinear = np.random.uniform(0, 10, 100)
y_nonlinear = x_nonlinear ** 2 + np.random.normal(0, 5, 100)

pearson_nonlinear = np.corrcoef(x_nonlinear, y_nonlinear)[0, 1]
spearman_nonlinear = spearman_correlation(x_nonlinear, y_nonlinear)
```

