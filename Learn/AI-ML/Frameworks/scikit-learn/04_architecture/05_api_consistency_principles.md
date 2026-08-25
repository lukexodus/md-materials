## API Consistency Principles


**Parameter validation** occurs in `fit()` methods rather than constructors, allowing parameter inspection and modification without triggering expensive validation. Input data validation uses utilities from `sklearn.utils.validation` to ensure consistent format and type checking.

**State management** distinguishes between hyperparameters (set at construction) and learned parameters (computed during fitting). Hyperparameters use standard names without underscores, while learned parameters always end with underscores.

**Return value conventions** ensure predictable method behavior: `fit()` always returns `self`, `transform()` and `predict()` return arrays with consistent shapes, and optional methods follow established naming patterns.

**Key Points:**

- Hyperparameters: `n_estimators`, `learning_rate`, `max_depth`
- Learned parameters: `coef_`, `classes_`, `feature_importances_`
- Input validation: `check_X_y()`, `check_array()`, `check_is_fitted()`
- Consistent shapes: input samples × features, output samples × targets/classes
- Method chaining: `fit()` returns `self` for pipeline construction

**Example:**

```python
from sklearn.utils.validation import check_X_y, check_array, check_is_fitted
from sklearn.base import BaseEstimator, RegressorMixin

class ConsistentRegressor(BaseEstimator, RegressorMixin):
    def __init__(self, alpha=1.0, fit_intercept=True):
        # Store parameters without validation
        self.alpha = alpha
        self.fit_intercept = fit_intercept
    
    def fit(self, X, y):
        # Validate inputs in fit method
        X, y = check_X_y(X, y)
        
        # Store learned parameters with underscores
        self.coef_ = np.random.random(X.shape[1])
        if self.fit_intercept:
            self.intercept_ = np.random.random()
        
        # Store training metadata
        self.n_features_in_ = X.shape[1]
        return self  # Enable method chaining
    
    def predict(self, X):
        # Check fitted state and validate input
        check_is_fitted(self)
        X = check_array(X)
        
        # Consistent output shape
        predictions = X @ self.coef_
        if hasattr(self, 'intercept_'):
            predictions += self.intercept_
        return predictions
```

**Conclusion:** Scikit-learn's architecture achieves remarkable consistency through its estimator interface design, enabling seamless integration of diverse machine learning algorithms. The fit/predict/transform pattern provides intuitive workflows, while pipeline architecture enables complex processing chains with unified interfaces. The transformer and predictor patterns establish clear contracts for different estimator types, and consistent API principles ensure predictable behavior across the entire library. This architectural foundation allows users to combine components flexibly while maintaining reliable, reproducible machine learning workflows.

---

