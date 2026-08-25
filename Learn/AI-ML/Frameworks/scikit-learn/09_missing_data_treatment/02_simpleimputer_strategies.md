## SimpleImputer Strategies


The `SimpleImputer` class provides fundamental univariate imputation strategies that replace missing values based on simple statistics computed from non-missing values in the same feature.

### Statistical Strategies

**Mean Imputation**: Replaces missing values with the arithmetic mean of non-missing values. This strategy preserves the overall mean but reduces variance and can distort distributions, particularly for skewed data. Best suited for numerical features with approximately normal distributions.

**Median Imputation**: Uses the median value for replacement, making it more robust to outliers than mean imputation. Particularly effective for skewed distributions or when outliers are present in the data.

**Mode Imputation**: Replaces missing values with the most frequent value, applicable to both categorical and numerical data. For categorical features, this maintains the dominant category's prevalence.

**Constant Imputation**: Fills missing values with a user-specified constant value. This approach is useful when domain knowledge suggests a specific default value or when implementing business rules.

### Implementation Considerations

The `SimpleImputer` maintains separate statistics for each feature, making it computationally efficient and suitable for high-dimensional datasets. It supports both dense and sparse matrices, with special handling for sparse matrix efficiency.

**Key points**:

- Handles both numerical and categorical data through appropriate strategy selection
- Maintains feature-wise statistics for consistent transformation across training and test sets
- Supports fit-transform paradigm for proper train-test separation
- Can be integrated into scikit-learn pipelines for streamlined preprocessing workflows

**Example**:

```python
from sklearn.impute import SimpleImputer
import numpy as np

# Numerical imputation with different strategies
data = np.array([[1, 2, np.nan],
                 [4, np.nan, 6],
                 [7, 8, 9],
                 [np.nan, 2, 3]])

# Mean imputation
mean_imputer = SimpleImputer(strategy='mean')
mean_imputed = mean_imputer.fit_transform(data)

# Median imputation for robust handling
median_imputer = SimpleImputer(strategy='median')
median_imputed = median_imputer.fit_transform(data)

# Categorical imputation
categories = np.array([['red', 'small', np.nan],
                      ['blue', np.nan, 'heavy'],
                      ['red', 'large', 'light'],
                      [np.nan, 'small', 'heavy']], dtype=object)

categorical_imputer = SimpleImputer(strategy='most_frequent')
categorical_imputed = categorical_imputer.fit_transform(categories)
```

