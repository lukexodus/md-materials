## Transformer and Predictor Patterns


**Transformer pattern** implements estimators that modify input data without making predictions. Transformers must implement `fit()` and `transform()` methods, with optional `fit_transform()` for efficiency. Transformers learn parameters from training data and apply consistent transformations to new data.

**Predictor pattern** implements estimators that generate predictions or classifications. Predictors must implement `fit()` and `predict()` methods, with additional methods like `predict_proba()` for probabilistic outputs. Predictors learn decision boundaries or regression functions from training data.

Mixin classes provide specialized functionality: `TransformerMixin` adds `fit_transform()`, `ClassifierMixin` adds `score()` for classification, and `RegressorMixin` adds `score()` for regression.

**Key Points:**

- `TransformerMixin` provides default `fit_transform()` implementation
- `ClassifierMixin` expects discrete target variables and accuracy scoring
- `RegressorMixin` expects continuous target variables and R² scoring
- `check_is_fitted()` validates estimator state before transform/predict
- Transformers should handle both training and inference data consistently

**Example:**

```python
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.utils.validation import check_is_fitted

class LogTransformer(BaseEstimator, TransformerMixin):
    def __init__(self, offset=1.0):
        self.offset = offset
    
    def fit(self, X, y=None):
        # Transformers can ignore y parameter
        X = check_array(X)
        self.n_features_ = X.shape[1]
        return self
    
    def transform(self, X):
        check_is_fitted(self)
        X = check_array(X)
        return np.log(X + self.offset)

# Usage maintains consistent interface
transformer = LogTransformer(offset=0.1)
X_transformed = transformer.fit_transform(X)
```

