## LinearSVC Implementation


LinearSVC provides a specialized implementation for linear SVMs using liblinear library, optimized for large datasets with linear decision boundaries. Unlike standard SVC with linear kernel, LinearSVC uses different optimization algorithms that scale better with sample size.

**Key Points:**

- Uses coordinate descent algorithm instead of SMO (Sequential Minimal Optimization)
- Significantly faster training for large datasets (>10,000 samples)
- Memory efficient - doesn't store support vectors explicitly
- Supports both L1 and L2 regularization penalties
- Limited to linear kernels only
- Different default parameters than SVC

The dual parameter controls solver choice - `dual=False` uses primal optimization (faster for n_samples > n_features), while `dual=True` uses dual optimization (better for n_samples < n_features). Loss functions include squared_hinge (L2) and hinge (L1).

**Example:**

```python
from sklearn.svm import LinearSVC
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

# Standard LinearSVC with L2 regularization
linear_svc = LinearSVC(C=1.0, penalty='l2', loss='squared_hinge', dual=True, random_state=42)

# L1 regularization for feature selection
linear_svc_l1 = LinearSVC(C=1.0, penalty='l1', loss='squared_hinge', dual=False, random_state=42)

# Pipeline with scaling for better performance
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('svc', LinearSVC(C=1.0, max_iter=10000, random_state=42))
])

pipeline.fit(X_train, y_train)
predictions = pipeline.predict(X_test)

# Access coefficients for feature importance
feature_importance = abs(linear_svc.coef_[0])
```

LinearSVC requires feature scaling for optimal performance since it's sensitive to feature magnitudes. The max_iter parameter often needs adjustment for convergence on complex datasets.

