## Mathematical Transformations


Mathematical transformations normalize distributions, handle skewness, and create linear relationships from non-linear data.

```python
from sklearn.preprocessing import (
    PowerTransformer, QuantileTransformer, FunctionTransformer,
    RobustScaler, MinMaxScaler, StandardScaler, Normalizer
)
from sklearn.compose import ColumnTransformer
from sklearn.base import BaseEstimator, TransformerMixin
import numpy as np
import pandas as pd
from scipy import stats
import matplotlib.pyplot as plt

# Generate sample data with different distributions
np.random.seed(42)
data = pd.DataFrame({
    'normal': np.random.normal(10, 3, 1000),
    'skewed': np.random.exponential(2, 1000),
    'heavy_tailed': stats.t.rvs(df=3, size=1000),
    'bimodal': np.concatenate([np.random.normal(-2, 1, 500), np.random.normal(3, 1.5, 500)]),
    'uniform': np.random.uniform(0, 10, 1000),
    'binary': np.random.choice([0, 1], 1000, p=[0.3, 0.7])
})

# 1. Power Transformations
def apply_power_transformations(data):
    """Apply various power transformations"""
    transformations = {}
    
    # Box-Cox transformation (requires positive values)
    positive_data = data[data > 0]
    if len(positive_data) > 0:
        box_cox = PowerTransformer(method='box-cox')
        transformations['box_cox'] = box_cox.fit_transform(positive_data.values.reshape(-1, 1)).flatten()
    
    # Yeo-Johnson transformation (handles negative values)
    yeo_johnson = PowerTransformer(method='yeo-johnson')
    transformations['yeo_johnson'] = yeo_johnson.fit_transform(data.values.reshape(-1, 1)).flatten()
    
    # Manual power transformations
    transformations['sqrt'] = np.sqrt(np.abs(data)) * np.sign(data)
    transformations['log'] = np.log1p(data - data.min() + 1)  # Shift to ensure positive values
    transformations['reciprocal'] = 1 / (data + 1e-8)  # Avoid division by zero
    transformations['square'] = data ** 2
    transformations['cube_root'] = np.cbrt(data)
    
    return transformations

# 2. Quantile Transformations
def apply_quantile_transformations(data):
    """Apply quantile-based transformations"""
    transformations = {}
    
    # Uniform quantile transformer
    uniform_qt = QuantileTransformer(output_distribution='uniform', random_state=42)
    transformations['uniform_quantile'] = uniform_qt.fit_transform(data.values.reshape(-1, 1)).flatten()
    
    # Normal quantile transformer
    normal_qt = QuantileTransformer(output_distribution='normal', random_state=42)
    transformations['normal_quantile'] = normal_qt.fit_transform(data.values.reshape(-1, 1)).flatten()
    
    return transformations

# 3. Trigonometric Transformations
def apply_trigonometric_transformations(data):
    """Apply trigonometric transformations for cyclic features"""
    transformations = {}
    
    # Normalize to [0, 2π] range
    normalized = 2 * np.pi * (data - data.min()) / (data.max() - data.min())
    
    transformations['sin'] = np.sin(normalized)
    transformations['cos'] = np.cos(normalized)
    transformations['tan'] = np.tan(normalized / 4)  # Scale to avoid extreme values
    
    # For encoding cyclical features like hour of day, day of week
    if data.min() >= 0 and data.max() <= 24:  # Assuming hourly data
        hour_angle = 2 * np.pi * data / 24
        transformations['hour_sin'] = np.sin(hour_angle)
        transformations['hour_cos'] = np.cos(hour_angle)
    
    return transformations

# 4. Statistical Transformations
def apply_statistical_transformations(data):
    """Apply statistical transformations"""
    transformations = {}
    
    # Z-score normalization
    transformations['zscore'] = (data - data.mean()) / data.std()
    
    # Robust scaling (using median and IQR)
    median = data.median()
    q75, q25 = np.percentile(data, [75, 25])
    iqr = q75 - q25
    transformations['robust'] = (data - median) / iqr if iqr != 0 else data - median
    
    # Min-max scaling
    transformations['minmax'] = (data - data.min()) / (data.max() - data.min())
    
    # Winsorization (clip extreme values)
    transformations['winsorized'] = np.clip(data, 
                                          np.percentile(data, 5), 
                                          np.percentile(data, 95))
    
    # Rank transformation
    transformations['rank'] = stats.rankdata(data) / len(data)
    
    return transformations

# 5. Custom Mathematical Transformations
class CustomMathTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, transformation='log', epsilon=1e-8):
        self.transformation = transformation
        self.epsilon = epsilon
        self.shift_ = None
        self.scale_ = None
    
    def fit(self, X, y=None):
        X = np.array(X).reshape(-1, 1) if np.array(X).ndim == 1 else np.array(X)
        
        if self.transformation in ['log', 'sqrt']:
            # Ensure positive values
            self.shift_ = -X.min() + self.epsilon if X.min() <= 0 else 0
        elif self.transformation == 'reciprocal':
            # Avoid division by zero
            self.shift_ = self.epsilon
        
        return self
    
    def transform(self, X):
        X = np.array(X).reshape(-1, 1) if np.array(X).ndim == 1 else np.array(X)
        X_shifted = X + self.shift_ if self.shift_ is not None else X
        
        if self.transformation == 'log':
            return np.log1p(X_shifted)
        elif self.transformation == 'sqrt':
            return np.sqrt(X_shifted)
        elif self.transformation == 'reciprocal':
            return 1 / (X_shifted + self.epsilon)
        elif self.transformation == 'arcsin':
            # For proportions/percentages
            return np.arcsin(np.sqrt(np.clip(X_shifted, 0, 1)))
        elif self.transformation == 'logit':
            # For probabilities
            X_clipped = np.clip(X_shifted, self.epsilon, 1 - self.epsilon)
            return np.log(X_clipped / (1 - X_clipped))
        else:
            return X_shifted

# 6. Composite Transformations
def create_transformation_pipeline(feature_types):
    """Create a comprehensive transformation pipeline"""
    transformers = []
    
    for feature_type, columns in feature_types.items():
        if feature_type == 'skewed':
            transformer = PowerTransformer(method='yeo-johnson')
        elif feature_type == 'uniform':
            transformer = QuantileTransformer(output_distribution='normal')
        elif feature_type == 'heavy_tailed':
            transformer = RobustScaler()
        elif feature_type == 'normal':
            transformer = StandardScaler()
        elif feature_type == 'cyclic':
            transformer = Pipeline([
                ('custom', FunctionTransformer(
                    func=lambda X: np.column_stack([
                        np.sin(2 * np.pi * X / X.max()),
                        np.cos(2 * np.pi * X / X.max())
                    ]),
                    validate=False
                ))
            ])
        else:
            transformer = 'passthrough'
        
        transformers.append((feature_type, transformer, columns))
    
    return ColumnTransformer(transformers, remainder='passthrough')

# Apply transformations to sample data
results = {}
for column in data.columns:
    if column != 'binary':  # Skip binary features for some transformations
        print(f"\nTransforming {column} (skewness: {stats.skew(data[column]):.2f}):")
        
        # Power transformations
        power_results = apply_power_transformations(data[column])
        
        # Quantile transformations
        quantile_results = apply_quantile_transformations(data[column])
        
        # Statistical transformations
        stat_results = apply_statistical_transformations(data[column])
        
        # Combine results
        all_results = {**power_results, **quantile_results, **stat_results}
        
        # Calculate skewness reduction
        for transform_name, transformed_data in all_results.items():
            original_skew = abs(stats.skew(data[column]))
            new_skew = abs(stats.skew(transformed_data))
            reduction = ((original_skew - new_skew) / original_skew) * 100 if original_skew != 0 else 0
            print(f"  {transform_name}: skewness {stats.skew(transformed_data):.3f} "
                  f"(reduction: {reduction:.1f}%)")

# Example: Multi-step transformation pipeline
multi_step_pipeline = Pipeline([
    ('outlier_clip', FunctionTransformer(
        func=lambda X: np.clip(X, np.percentile(X, 1), np.percentile(X, 99)),
        validate=False
    )),
    ('power_transform', PowerTransformer(method='yeo-johnson')),
    ('scale', StandardScaler())
])

# Feature type categorization for automated pipeline
feature_types = {
    'skewed': ['skewed'],
    'normal': ['normal'],
    'heavy_tailed': ['heavy_tailed'],
    'uniform': ['uniform', 'bimodal']
}

comprehensive_pipeline = create_transformation_pipeline(feature_types)
transformed_data = comprehensive_pipeline.fit_transform(data)

print(f"\nOriginal data shape: {data.shape}")
print(f"Transformed data shape: {transformed_data.shape}")

# Advanced: Transformation selection based on distribution tests
def select_best_transformation(data, transformations=None):
    """Select best transformation based on normality tests"""
    if transformations is None:
        transformations = [
            ('original', lambda x: x),
            ('log', lambda x: np.log1p(x - x.min() + 1)),
            ('sqrt', lambda x: np.sqrt(x - x.min() + 1e-8)),
            ('box_cox', lambda x: PowerTransformer(method='box-cox').fit_transform(x.reshape(-1, 1)).flatten() if x.min() > 0 else x),
            ('yeo_johnson', lambda x: PowerTransformer(method='yeo-johnson').fit_transform(x.reshape(-1, 1)).flatten())
        ]
    
    best_transform = None
    best_pvalue = 0
    
    for name, transform_func in transformations:
        try:
            transformed = transform_func(data)
            if np.isfinite(transformed).all():
                _, pvalue = stats.shapiro(transformed[:5000])  # Limit sample size for shapiro
                if pvalue > best_pvalue:
                    best_pvalue = pvalue
                    best_transform = (name, transform_func)
        except:
            continue
    
    return best_transform, best_pvalue

# Find best transformation for each column
for column in ['skewed', 'heavy_tailed']:
    best_transform, pvalue = select_best_transformation(data[column])
    print(f"\nBest transformation for {column}: {best_transform[0]} (p-value: {pvalue:.4f})")
```

**Key points:**

- Power transformations (Box-Cox, Yeo-Johnson) normalize skewed distributions
- Quantile transformations map to uniform or normal distributions regardless of original shape
- Trigonometric transformations encode cyclical features like time, angles, or seasons
- Robust scaling handles outliers better than standard scaling

**Example:** For right-skewed data, log transformation reduces skewness from 2.3 to 0.1, making it suitable for linear models

