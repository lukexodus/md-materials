## BaggingClassifier Implementation


Bagging (Bootstrap Aggregating) trains multiple instances of the same base classifier on different bootstrap samples of the training data, reducing variance and overfitting.

**Key points:**

- Reduces overfitting by averaging predictions from multiple models
- Works especially well with high-variance classifiers (e.g., decision trees)
- Supports both feature and sample subsampling
- Enables parallel training of base classifiers

```python
from sklearn.ensemble import BaggingClassifier
import numpy as np

# Basic bagging with decision trees
bagging = BaggingClassifier(
    base_estimator=DecisionTreeClassifier(random_state=42),
    n_estimators=100,
    random_state=42,
    n_jobs=-1  # Parallel processing
)

# Advanced bagging configuration
bagging_advanced = BaggingClassifier(
    base_estimator=DecisionTreeClassifier(max_depth=10, random_state=42),
    n_estimators=200,
    max_samples=0.8,      # Use 80% of samples for each base estimator
    max_features=0.8,     # Use 80% of features for each base estimator
    bootstrap=True,       # Bootstrap sampling with replacement
    bootstrap_features=False,  # Sample features without replacement
    oob_score=True,       # Compute out-of-bag score
    random_state=42,
    n_jobs=-1
)

bagging_advanced.fit(X_train, y_train)
print(f"OOB Score: {bagging_advanced.oob_score_:.4f}")
```

**Out-of-bag evaluation and feature importance:**

```python
# OOB decision function (probability estimates)
oob_decision = bagging_advanced.oob_decision_function_
oob_predictions = np.argmax(oob_decision, axis=1)

# Feature importance aggregation
if hasattr(bagging_advanced.base_estimator, 'feature_importances_'):
    # Collect feature importances from all estimators
    importances = np.array([est.feature_importances_ 
                           for est in bagging_advanced.estimators_])
    mean_importance = np.mean(importances, axis=0)
    std_importance = np.std(importances, axis=0)
    
    # Plot feature importance with error bars
    import matplotlib.pyplot as plt
    indices = np.argsort(mean_importance)[::-1]
    plt.figure(figsize=(10, 6))
    plt.title("Bagging Feature Importance")
    plt.bar(range(X_train.shape[1]), mean_importance[indices],
            yerr=std_importance[indices], capsize=3)
    plt.xticks(range(X_train.shape[1]), indices)
```

**Custom bagging strategies:**

```python
# Balanced bagging for imbalanced datasets
from imblearn.ensemble import BalancedBaggingClassifier
balanced_bagging = BalancedBaggingClassifier(
    base_estimator=DecisionTreeClassifier(),
    n_estimators=100,
    sampling_strategy='auto',
    replacement=False,
    random_state=42
)

# Time series bagging (no bootstrap, sequential sampling)
class TimeSeriesBagging(BaggingClassifier):
    def _generate_indices(self, random_state, bootstrap):
        # Override to use sequential windows instead of bootstrap
        n_samples = self.n_samples_
        window_size = int(n_samples * self.max_samples)
        start_idx = random_state.randint(0, n_samples - window_size)
        return np.arange(start_idx, start_idx + window_size)
```

