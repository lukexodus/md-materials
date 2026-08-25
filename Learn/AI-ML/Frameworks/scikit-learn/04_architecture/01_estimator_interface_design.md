## Estimator Interface Design


The **estimator** serves as the foundational design pattern in scikit-learn, providing a unified interface for all machine learning algorithms. Every estimator implements a consistent set of methods and follows standardized conventions for parameter handling, state management, and data processing.

All estimators inherit from `sklearn.base.BaseEstimator`, which provides core functionality including parameter introspection, cloning capabilities, and consistent `__repr__` methods. The estimator stores all constructor parameters as instance attributes with identical names, enabling automatic parameter discovery and validation.

**Key Points:**

- Constructor parameters become instance attributes: `self.parameter = parameter`
- No validation or computation occurs in `__init__` - only parameter storage
- `get_params()` and `set_params()` methods enable parameter introspection and modification
- `clone()` function creates copies with identical parameters but reset state
- Estimators are stateless until `fit()` is called

**Example:**

```python
from sklearn.base import BaseEstimator, ClassifierMixin
from sklearn.utils.validation import check_X_y, check_array

class CustomClassifier(BaseEstimator, ClassifierMixin):
    def __init__(self, learning_rate=0.01, max_iter=100):
        # Store parameters without modification
        self.learning_rate = learning_rate
        self.max_iter = max_iter
    
    def fit(self, X, y):
        # Validation and computation only in fit()
        X, y = check_X_y(X, y)
        self.classes_ = np.unique(y)
        self.coef_ = np.random.random(X.shape[1])
        return self
    
    def predict(self, X):
        X = check_array(X)
        return np.random.choice(self.classes_, X.shape[0])
```

