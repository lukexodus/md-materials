## Multi-class Classification Strategies


SVMs are inherently binary classifiers, but scikit-learn automatically handles multi-class problems using two main strategies: One-vs-Rest (OvR) and One-vs-One (OvO). The choice affects training time, prediction speed, and memory usage.

**Key Points:**

- One-vs-Rest (OvR): Trains n_classes binary classifiers, each separating one class from all others
- One-vs-One (OvO): Trains n_classes*(n_classes-1)/2 binary classifiers for each pair of classes
- OvR faster training but potentially less accurate for imbalanced datasets
- OvO more robust but quadratic complexity in number of classes
- Decision function aggregation differs between strategies
- Automatic strategy selection based on estimator type

SVC uses OvO by default while LinearSVC uses OvR. The `decision_function_shape` parameter in SVC allows switching between 'ovr' and 'ovo' modes for consistency with other classifiers.

**Example:**

```python
from sklearn.svm import SVC
from sklearn.datasets import make_classification
from sklearn.multiclass import OneVsRestClassifier, OneVsOneClassifier

# Multi-class dataset
X_multi, y_multi = make_classification(
    n_samples=1000, n_features=20, n_classes=4, 
    n_informative=15, n_redundant=5, random_state=42
)

# SVC with One-vs-One (default)
svc_ovo = SVC(kernel='rbf', decision_function_shape='ovo')
svc_ovo.fit(X_train, y_train)

# SVC with One-vs-Rest
svc_ovr = SVC(kernel='rbf', decision_function_shape='ovr') 
svc_ovr.fit(X_train, y_train)

# Explicit multi-class wrappers
ovr_classifier = OneVsRestClassifier(SVC(kernel='rbf'))
ovo_classifier = OneVsOneClassifier(SVC(kernel='rbf'))

# Compare decision functions
decision_ovo = svc_ovo.decision_function(X_test)  # Shape: (n_samples, n_classes*(n_classes-1)/2)
decision_ovr = svc_ovr.decision_function(X_test)  # Shape: (n_samples, n_classes)

# Performance comparison
print(f"OvO accuracy: {svc_ovo.score(X_test, y_test):.3f}")
print(f"OvR accuracy: {svc_ovr.score(X_test, y_test):.3f}")
```

Strategy selection depends on dataset size, class balance, and computational constraints. OvO generally provides better accuracy but requires more memory and training time.

