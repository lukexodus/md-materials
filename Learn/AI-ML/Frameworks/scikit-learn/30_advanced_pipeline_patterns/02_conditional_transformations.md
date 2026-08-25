## Conditional Transformations


### Dynamic Transformation Selection

Conditional transformations adapt processing steps based on data characteristics, feature properties, or runtime conditions. This flexibility enables pipelines to handle diverse data types and quality scenarios automatically.

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import PowerTransformer, QuantileTransformer

class ConditionalTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, threshold_skew=1.0):
        self.threshold_skew = threshold_skew
        self.transformer_ = None
        self.skewness_ = None
    
    def fit(self, X, y=None):
        from scipy.stats import skew
        self.skewness_ = np.abs(skew(X, axis=0))
        
        # Choose transformer based on skewness
        if np.mean(self.skewness_) > self.threshold_skew:
            self.transformer_ = PowerTransformer(method='yeo-johnson')
        else:
            self.transformer_ = StandardScaler()
        
        self.transformer_.fit(X)
        return self
    
    def transform(self, X):
        return self.transformer_.transform(X)

# Pipeline with conditional transformation
conditional_pipeline = Pipeline([
    ('imputer', SimpleImputer()),
    ('conditional', ConditionalTransformer(threshold_skew=0.5)),
    ('classifier', LogisticRegression())
])
```

### Feature-Specific Processing

Different features often require specialized processing approaches. Conditional transformations can apply different techniques based on feature characteristics, data types, or statistical properties.

```python
class FeatureSpecificTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, high_cardinality_threshold=50):
        self.high_cardinality_threshold = high_cardinality_threshold
        self.transformers_ = {}
        self.feature_types_ = {}
    
    def fit(self, X, y=None):
        for i, col in enumerate(X.columns if hasattr(X, 'columns') else range(X.shape[1])):
            if X.iloc[:, i].dtype == 'object' if hasattr(X, 'iloc') else False:
                unique_values = len(np.unique(X.iloc[:, i]))
                if unique_values > self.high_cardinality_threshold:
                    self.transformers_[i] = TargetEncoder()
                    self.feature_types_[i] = 'high_cardinality_cat'
                else:
                    self.transformers_[i] = OneHotEncoder(sparse_output=False)
                    self.feature_types_[i] = 'low_cardinality_cat'
            else:
                # Check for outliers in numerical features
                q1, q3 = np.percentile(X.iloc[:, i], [25, 75])
                iqr = q3 - q1
                outlier_ratio = np.sum((X.iloc[:, i] < q1 - 1.5*iqr) | 
                                     (X.iloc[:, i] > q3 + 1.5*iqr)) / len(X)
                
                if outlier_ratio > 0.1:
                    self.transformers_[i] = RobustScaler()
                    self.feature_types_[i] = 'robust_numerical'
                else:
                    self.transformers_[i] = StandardScaler()
                    self.feature_types_[i] = 'standard_numerical'
        
        # Fit each transformer
        for i, transformer in self.transformers_.items():
            if hasattr(X, 'iloc'):
                transformer.fit(X.iloc[:, [i]], y)
            else:
                transformer.fit(X[:, [i]], y)
        
        return self
    
    def transform(self, X):
        transformed_features = []
        for i, transformer in self.transformers_.items():
            if hasattr(X, 'iloc'):
                feature_data = X.iloc[:, [i]]
            else:
                feature_data = X[:, [i]]
            transformed = transformer.transform(feature_data)
            transformed_features.append(transformed)
        
        return np.hstack(transformed_features)
```

### Runtime Adaptation

Advanced conditional transformations can adapt to runtime conditions, data drift, or performance requirements, enabling pipelines to maintain effectiveness across different deployment scenarios.

```python
class AdaptiveTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, performance_threshold=0.8, fallback_simple=True):
        self.performance_threshold = performance_threshold
        self.fallback_simple = fallback_simple
        self.primary_transformer = None
        self.fallback_transformer = None
        self.use_fallback = False
    
    def fit(self, X, y=None):
        # Try complex transformation first
        self.primary_transformer = Pipeline([
            ('poly', PolynomialFeatures(degree=2)),
            ('selection', SelectKBest(k=min(20, X.shape[1] * 2)))
        ])
        
        self.fallback_transformer = StandardScaler()
        
        # Evaluate transformation effectiveness
        try:
            X_transformed = self.primary_transformer.fit_transform(X)
            # Simple validation: check if transformation creates too many NaN/inf
            if np.isfinite(X_transformed).mean() < self.performance_threshold:
                self.use_fallback = True
        except Exception:
            self.use_fallback = True
        
        if self.use_fallback and self.fallback_simple:
            self.fallback_transformer.fit(X)
        
        return self
    
    def transform(self, X):
        if self.use_fallback and self.fallback_simple:
            return self.fallback_transformer.transform(X)
        else:
            return self.primary_transformer.transform(X)
```

