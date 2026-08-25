## DecisionTreeClassifier Usage


The DecisionTreeClassifier serves as the foundation for all tree-based methods in scikit-learn. It builds a binary tree by recursively splitting the data based on feature values that maximize information gain or minimize impurity.

**Key points:**

- Uses CART (Classification and Regression Trees) algorithm
- Supports multiple splitting criteria: gini, entropy, and log_loss
- Handles both numerical and categorical features
- Provides feature importance scores
- Prone to overfitting without proper regularization

```python
from sklearn.tree import DecisionTreeClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report
import numpy as np

# Generate sample data
X, y = make_classification(n_samples=1000, n_features=10, n_classes=3, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Basic usage
dt_classifier = DecisionTreeClassifier(
    criterion='gini',           # or 'entropy', 'log_loss'
    max_depth=5,               # prevent overfitting
    min_samples_split=20,      # minimum samples to split
    min_samples_leaf=10,       # minimum samples in leaf
    max_features='sqrt',       # feature sampling
    random_state=42
)

dt_classifier.fit(X_train, y_train)
y_pred = dt_classifier.predict(X_test)
```

The algorithm supports extensive hyperparameter tuning for controlling tree growth. The `max_depth` parameter prevents overfitting by limiting tree depth, while `min_samples_split` and `min_samples_leaf` ensure statistical significance of splits. The `max_features` parameter introduces randomness by considering only a subset of features at each split.

**Example** of advanced configuration:

```python
# Advanced configuration with cost complexity pruning
dt_advanced = DecisionTreeClassifier(
    criterion='entropy',
    max_depth=None,           # allow full growth initially
    min_samples_split=2,
    min_samples_leaf=1,
    max_features=None,
    ccp_alpha=0.01,          # cost complexity pruning
    class_weight='balanced'   # handle class imbalance
)

# Get feature importance
feature_importance = dt_classifier.feature_importances_
```

