## Classification vs Regression Problems


**Classification** predicts discrete categorical outputs or class labels. The target variable represents categories, and the goal is to assign input samples to predefined classes. Scikit-learn classification estimators output discrete predictions and provide methods like `predict_proba()` for probability estimates.

**Regression** predicts continuous numerical outputs. The target variable is a real-valued number, and the goal is to estimate a continuous function mapping inputs to outputs. Regression estimators in scikit-learn output continuous values and often provide confidence intervals or prediction intervals.

**Key Points:**

- Classification metrics: `sklearn.metrics.accuracy_score`, `sklearn.metrics.classification_report`
- Regression metrics: `sklearn.metrics.mean_squared_error`, `sklearn.metrics.r2_score`
- Multi-output problems: `sklearn.multioutput.MultiOutputRegressor`, `sklearn.multioutput.MultiOutputClassifier`

**Example:**

```python
# Classification
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_iris

X, y = load_iris(return_X_y=True)
clf = RandomForestClassifier()
clf.fit(X, y)
predictions = clf.predict(X)  # Returns discrete class labels

# Regression
from sklearn.ensemble import RandomForestRegressor
from sklearn.datasets import load_boston

X, y = load_boston(return_X_y=True)
reg = RandomForestRegressor()
reg.fit(X, y)
predictions = reg.predict(X)  # Returns continuous values
```

