## Custom Imputation Methods


Beyond the built-in imputers, scikit-learn's architecture allows for sophisticated custom imputation strategies tailored to specific domain requirements and data characteristics.

### Creating Custom Imputers

Custom imputers should inherit from `BaseEstimator` and `TransformerMixin` to ensure compatibility with scikit-learn pipelines and cross-validation procedures.

**Base Implementation Structure**: A custom imputer must implement `fit()`, `transform()`, and typically `fit_transform()` methods following scikit-learn conventions.

**State Management**: The `fit()` method should compute and store necessary statistics or parameters, while `transform()` applies the imputation logic using these stored parameters.

**Input Validation**: Robust custom imputers include comprehensive input validation, handle edge cases, and provide informative error messages.

### Advanced Custom Strategies

**Domain-Specific Imputation**: Leverage business rules, domain knowledge, or external data sources for imputation. For example, imputing missing demographic information based on geographic location or imputing missing sensor readings based on environmental conditions.

**Time-Series Aware Imputation**: For temporal data, implement forward-fill, backward-fill, linear interpolation, or seasonal decomposition-based imputation strategies.

**Group-Based Imputation**: Perform imputation within specific groups or clusters, allowing for different imputation strategies for different subpopulations in the data.

**Machine Learning-Based Imputation**: Implement sophisticated ML models for imputation, such as autoencoders, generative adversarial networks, or deep learning approaches.

### Integration with Existing Workflows

**Pipeline Compatibility**: Custom imputers should be designed to work seamlessly within scikit-learn pipelines, supporting both training and inference workflows.

**Cross-Validation Support**: Proper implementation ensures that custom imputers work correctly with cross-validation procedures, preventing data leakage between folds.

**Parameter Tuning**: Custom imputers can expose hyperparameters for tuning through grid search or other optimization techniques.

**Key points**:

- Requires understanding of scikit-learn's transformer interface
- Enables domain-specific and problem-tailored imputation strategies
- Must handle edge cases and provide robust error handling
- Should maintain consistency with scikit-learn conventions for broader compatibility
- Can incorporate external data sources and business logic

**Example**:

```python
from sklearn.base import BaseEstimator, TransformerMixin
import numpy as np
import pandas as pd

class GroupedImputer(BaseEstimator, TransformerMixin):
    """Custom imputer that performs imputation within groups."""
    
    def __init__(self, groupby_column, strategy='mean'):
        self.groupby_column = groupby_column
        self.strategy = strategy
        self.group_statistics_ = {}
    
    def fit(self, X, y=None):
        """Compute group-wise statistics for imputation."""
        if isinstance(X, np.ndarray):
            raise ValueError("GroupedImputer requires DataFrame input")
        
        self.feature_names_ = X.columns.tolist()
        self.group_statistics_ = {}
        
        for group_value in X[self.groupby_column].unique():
            if pd.isna(group_value):
                continue
            
            group_data = X[X[self.groupby_column] == group_value]
            group_stats = {}
            
            for column in X.columns:
                if column == self.groupby_column:
                    continue
                
                if self.strategy == 'mean':
                    group_stats[column] = group_data[column].mean()
                elif self.strategy == 'median':
                    group_stats[column] = group_data[column].median()
                elif self.strategy == 'mode':
                    group_stats[column] = group_data[column].mode().iloc[0] if not group_data[column].mode().empty else np.nan
                
            self.group_statistics_[group_value] = group_stats
        
        return self
    
    def transform(self, X):
        """Apply group-wise imputation."""
        X_imputed = X.copy()
        
        for group_value, group_stats in self.group_statistics_.items():
            group_mask = X_imputed[self.groupby_column] == group_value
            
            for column, fill_value in group_stats.items():
                if not pd.isna(fill_value):
                    X_imputed.loc[group_mask, column] = X_imputed.loc[group_mask, column].fillna(fill_value)
        
        return X_imputed

class TimeSeriesImputer(BaseEstimator, TransformerMixin):
    """Custom imputer for time series data."""
    
    def __init__(self, method='linear', time_column=None):
        self.method = method
        self.time_column = time_column
    
    def fit(self, X, y=None):
        """Time series imputers typically don't need fitting."""
        return self
    
    def transform(self, X):
        """Apply time series specific imputation."""
        X_imputed = X.copy()
        
        if self.time_column and self.time_column in X_imputed.columns:
            X_imputed = X_imputed.sort_values(by=self.time_column)
        
        if self.method == 'forward_fill':
            X_imputed = X_imputed.fillna(method='ffill')
        elif self.method == 'backward_fill':
            X_imputed = X_imputed.fillna(method='bfill')
        elif self.method == 'linear':
            X_imputed = X_imputed.interpolate(method='linear')
        elif self.method == 'polynomial':
            X_imputed = X_imputed.interpolate(method='polynomial', order=2)
        
        return X_imputed

# Usage examples
# Sample data creation
sample_data = pd.DataFrame({
    'group': ['A', 'A', 'B', 'B', 'A', 'B'],
    'feature1': [1, np.nan, 3, 4, np.nan, 6],
    'feature2': [10, 20, np.nan, 40, 50, np.nan]
})

# Group-based imputation
group_imputer = GroupedImputer(groupby_column='group', strategy='mean')
group_imputed = group_imputer.fit_transform(sample_data)

# Time series data
ts_data = pd.DataFrame({
    'timestamp': pd.date_range('2023-01-01', periods=10, freq='D'),
    'value': [1, 2, np.nan, 4, np.nan, 6, 7, np.nan, 9, 10]
})

ts_imputer = TimeSeriesImputer(method='linear', time_column='timestamp')
ts_imputed = ts_imputer.fit_transform(ts_data)
```

