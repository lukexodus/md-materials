## FeatureUnion Combinations


FeatureUnion enables parallel processing of different feature extraction methods, combining their outputs horizontally to create richer feature representations. This approach is particularly valuable when different transformation methods capture complementary aspects of the data.

**Key points:**

- Applies multiple transformers in parallel to the same input data
- Concatenates results horizontally to create combined feature matrix
- Supports different transformation approaches on identical data
- Enables ensemble-style feature engineering
- Can be nested within pipelines for complex workflows
- Supports weighted combinations of transformer outputs

**Example:**

```python
from sklearn.pipeline import FeatureUnion
from sklearn.decomposition import PCA, TruncatedSVD
from sklearn.feature_selection import SelectKBest, SelectPercentile
from sklearn.preprocessing import MinMaxScaler, RobustScaler
import numpy as np

# Create sample data with different characteristics
np.random.seed(42)
X_mixed = np.random.randn(1000, 20)
X_mixed[:, :10] += np.random.randn(1000, 10) * 2  # High variance features
X_mixed[:, 10:] += np.random.randn(1000, 10) * 0.1  # Low variance features
y_mixed = (X_mixed[:, 0] + X_mixed[:, 5] + X_mixed[:, 15] > 0).astype(int)

X_train, X_test, y_train, y_test = train_test_split(X_mixed, y_mixed, test_size=0.2, random_state=42)

# Create feature union for dimensionality reduction
dimensionality_union = FeatureUnion([
    ('pca', PCA(n_components=5)),
    ('svd', TruncatedSVD(n_components=5)),
    ('select_best', SelectKBest(f_classif, k=5))
])

# Feature union with different scaling approaches
scaling_union = FeatureUnion([
    ('standard_scaled', Pipeline([
        ('scaler', StandardScaler()),
        ('select', SelectKBest(f_classif, k=8))
    ])),
    ('robust_scaled', Pipeline([
        ('scaler', RobustScaler()),
        ('select', SelectPercentile(f_classif, percentile=40))
    ])),
    ('minmax_scaled', Pipeline([
        ('scaler', MinMaxScaler()),
        ('pca', PCA(n_components=6))
    ]))
])

# Complete pipeline with feature union
feature_union_pipeline = Pipeline([
    ('feature_union', scaling_union),
    ('final_scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

# Fit and evaluate
feature_union_pipeline.fit(X_train, y_train)
union_score = feature_union_pipeline.score(X_test, y_test)
print(f"Feature Union Pipeline Accuracy: {union_score:.4f}")

# Compare with simple pipeline
simple_pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(n_estimators=100, random_state=42))
])

simple_pipeline.fit(X_train, y_train)
simple_score = simple_pipeline.score(X_test, y_test)
print(f"Simple Pipeline Accuracy: {simple_score:.4f}")

# Analyze feature union output
X_union_features = feature_union_pipeline.named_steps['feature_union'].transform(X_test)
print(f"Original features: {X_test.shape[1]}")
print(f"Feature union output: {X_union_features.shape[1]}")

# Custom transformer for feature union
class StatisticalFeatures:
    def fit(self, X, y=None):
        return self
    
    def transform(self, X):
        """Extract statistical features"""
        features = np.column_stack([
            np.mean(X, axis=1),      # Mean
            np.std(X, axis=1),       # Standard deviation
            np.median(X, axis=1),    # Median
            np.percentile(X, 25, axis=1),  # Q1
            np.percentile(X, 75, axis=1),  # Q3
            np.max(X, axis=1) - np.min(X, axis=1)  # Range
        ])
        return features
    
    def get_feature_names_out(self, input_features=None):
        return ['mean', 'std', 'median', 'q1', 'q3', 'range']

# Advanced feature union with custom transformers
advanced_union = FeatureUnion([
    ('original_features', SelectKBest(f_classif, k=10)),
    ('statistical_features', StatisticalFeatures()),
    ('pca_features', PCA(n_components=5)),
    ('interaction_features', PolynomialFeatures(degree=2, interaction_only=True, include_bias=False))
])

advanced_pipeline = Pipeline([
    ('feature_union', advanced_union),
    ('feature_selection', SelectKBest(f_classif, k=30)),
    ('classifier', RandomForestClassifier(random_state=42))
])

advanced_pipeline.fit(X_train, y_train)
advanced_score = advanced_pipeline.score(X_test, y_test)
print(f"Advanced Feature Union Accuracy: {advanced_score:.4f}")
```

**Weighted Feature Union:**

```python
from sklearn.pipeline import FeatureUnion
from sklearn.base import BaseEstimator, TransformerMixin

class WeightedFeatureUnion(FeatureUnion):
    def __init__(self, transformer_list, weights=None, n_jobs=None, 
                 transformer_weights=None, verbose=False):
        super().__init__(transformer_list, n_jobs, transformer_weights, verbose)
        self.weights = weights
    
    def transform(self, X):
        """Transform X separately by each transformer, then concatenate with weights"""
        Xs = []
        for name, transformer in self.transformer_list:
            X_transformed = transformer.transform(X)
            if self.weights and name in self.weights:
                X_transformed = X_transformed * self.weights[name]
            Xs.append(X_transformed)
        return np.concatenate(Xs, axis=1)

# Usage with weights
weighted_union = WeightedFeatureUnion([
    ('pca', PCA(n_components=10)),
    ('statistical', StatisticalFeatures()),
    ('selected', SelectKBest(f_classif, k=8))
], weights={'pca': 1.5, 'statistical': 2.0, 'selected': 1.0})
```

FeatureUnion excels when different transformation approaches provide complementary information and when feature diversity enhances model performance.

