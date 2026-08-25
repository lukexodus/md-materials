## Scikit-learn Machine Learning


Scikit-learn is designed around NumPy arrays as the primary data structure, with all estimators expecting NumPy arrays or array-like objects for training and prediction.

**Key points:**

- All scikit-learn estimators accept NumPy arrays as input
- Feature matrices (X) and target vectors (y) are expected as NumPy arrays
- Model parameters and predictions are returned as NumPy arrays
- Cross-validation and model evaluation functions work directly with NumPy arrays

**Example:**

```python
import numpy as np
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.linear_model import LinearRegression, LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, mean_squared_error

# Generate synthetic data with NumPy
X = np.random.randn(1000, 20)
y_regression = np.sum(X[:, :3], axis=1) + np.random.randn(1000) * 0.1
y_classification = (y_regression > 0).astype(int)

# Train-test split maintains NumPy array format
X_train, X_test, y_train, y_test = train_test_split(X, y_classification, test_size=0.2)

# Preprocessing with NumPy arrays
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)  # Returns NumPy array
X_test_scaled = scaler.transform(X_test)

# Model training and prediction
clf = RandomForestClassifier()
clf.fit(X_train_scaled, y_train)
predictions = clf.predict(X_test_scaled)  # Returns NumPy array

# Feature importance and model parameters as NumPy arrays
feature_importance = clf.feature_importances_
cross_val_scores = cross_val_score(clf, X_train_scaled, y_train, cv=5)
```

The integration includes support for sparse matrices through NumPy's sparse array interface, and all transformers and estimators maintain the NumPy array contract for consistent data flow through machine learning pipelines.

