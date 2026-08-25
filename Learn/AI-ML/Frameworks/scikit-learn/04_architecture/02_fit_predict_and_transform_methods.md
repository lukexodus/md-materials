## Fit, Predict, and Transform Methods


**fit() method** trains the estimator on input data and stores learned parameters as instance attributes ending with underscore. The method always returns `self` to enable method chaining. Fitted parameters are distinguished from constructor parameters by the trailing underscore convention.

**predict() method** generates predictions on new data using previously learned parameters. This method requires the estimator to be fitted first and typically validates input data format and dimensions. Prediction methods vary by estimator type but maintain consistent interfaces.

**transform() method** applies learned transformations to input data, used primarily by preprocessing and dimensionality reduction estimators. Like predict(), transform() requires prior fitting and returns modified data rather than predictions.

**Key Points:**

- `fit()` always returns `self` for method chaining
- Learned parameters use trailing underscores: `coef_`, `classes_`, `feature_importances_`
- `predict()` and `transform()` validate fitted state using `check_is_fitted()`
- `fit_transform()` combines fit() and transform() for efficiency
- `predict_proba()`, `predict_log_proba()`, `decision_function()` provide additional prediction interfaces

**Example:**

```python
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris

X, y = load_iris(return_X_y=True)

# Transformer pattern
scaler = StandardScaler()
scaler.fit(X)  # Learn mean and std
X_scaled = scaler.transform(X)  # Apply transformation

# Or combined
X_scaled = scaler.fit_transform(X)

# Predictor pattern  
clf = RandomForestClassifier()
clf.fit(X_scaled, y)  # Learn decision boundaries
predictions = clf.predict(X_scaled)  # Generate predictions
probabilities = clf.predict_proba(X_scaled)  # Get class probabilities
```

