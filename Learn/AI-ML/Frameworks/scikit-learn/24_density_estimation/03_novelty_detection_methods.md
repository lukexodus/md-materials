## Novelty Detection Methods


Novelty detection identifies data points that differ significantly from training distribution, assuming training data contains only normal examples. These methods learn decision boundaries around normal data regions and flag points outside these boundaries as novel or anomalous.

**Key Points:**

- Assumes training data represents normal behavior without outliers
- Learns decision function separating normal region from potential novelties
- One-class classification approach focusing on single class characterization
- Applications include fraud detection, system monitoring, quality control
- Threshold tuning controls sensitivity-specificity trade-off
- Evaluation requires labeled test data with known normal/anomalous examples
- Different from outlier detection which identifies anomalies within training data

Novelty detection algorithms construct boundaries around normal data using various approaches: distance-based (k-nearest neighbors), reconstruction-based (autoencoders), or margin-based (one-class SVM). Performance depends on normal data representativeness and novelty types.

**Example:**

```python
from sklearn.svm import OneClassSVM
from sklearn.neighbors import LocalOutlierFactor
from sklearn.ensemble import IsolationForest
from sklearn.datasets import make_blobs
from sklearn.metrics import classification_report, roc_auc_score
import numpy as np

# Generate normal training data
X_train, _ = make_blobs(n_samples=500, centers=1, n_features=2, 
                        cluster_std=1.0, random_state=42)

# Generate test data with novelties
X_test_normal, _ = make_blobs(n_samples=200, centers=1, n_features=2,
                              cluster_std=1.0, random_state=43)
X_test_novel = np.random.uniform(low=-6, high=6, size=(50, 2))
X_test = np.vstack([X_test_normal, X_test_novel])
y_test = np.hstack([np.ones(200), -np.ones(50)])  # 1=normal, -1=novel

# One-Class SVM novelty detection
oc_svm = OneClassSVM(kernel='rbf', gamma='scale', nu=0.1)
oc_svm.fit(X_train)
y_pred_svm = oc_svm.predict(X_test)
decision_scores_svm = oc_svm.decision_function(X_test)

# Local Outlier Factor (set novelty=True for novelty detection)
lof = LocalOutlierFactor(n_neighbors=20, novelty=True)
lof.fit(X_train)
y_pred_lof = lof.predict(X_test)
decision_scores_lof = lof.decision_function(X_test)

# Isolation Forest
iso_forest = IsolationForest(contamination=0.2, random_state=42)
iso_forest.fit(X_train)
y_pred_iso = iso_forest.predict(X_test)
decision_scores_iso = iso_forest.decision_function(X_test)

# Evaluate methods
methods = {
    'One-Class SVM': (y_pred_svm, decision_scores_svm),
    'LOF': (y_pred_lof, decision_scores_lof),
    'Isolation Forest': (y_pred_iso, decision_scores_iso)
}

for method_name, (predictions, scores) in methods.items():
    auc_score = roc_auc_score(y_test, scores)
    print(f"\n{method_name}:")
    print(f"AUC Score: {auc_score:.3f}")
    print(classification_report(y_test, predictions))

# Parameter sensitivity analysis
nu_values = [0.05, 0.1, 0.15, 0.2, 0.25]
gamma_values = ['scale', 'auto', 0.001, 0.01, 0.1, 1.0]

best_auc = 0
best_params = {}

for nu in nu_values:
    for gamma in gamma_values:
        oc_svm_param = OneClassSVM(kernel='rbf', gamma=gamma, nu=nu)
        oc_svm_param.fit(X_train)
        scores_param = oc_svm_param.decision_function(X_test)
        auc_param = roc_auc_score(y_test, scores_param)
        
        if auc_param > best_auc:
            best_auc = auc_param
            best_params = {'nu': nu, 'gamma': gamma}

print(f"\nBest One-Class SVM parameters: {best_params}")
print(f"Best AUC: {best_auc:.3f}")

# Threshold optimization for decision function
thresholds = np.linspace(decision_scores_svm.min(), decision_scores_svm.max(), 100)
best_threshold = 0
best_f1 = 0

from sklearn.metrics import f1_score

for threshold in thresholds:
    y_pred_threshold = np.where(decision_scores_svm >= threshold, 1, -1)
    f1_threshold = f1_score(y_test, y_pred_threshold)
    
    if f1_threshold > best_f1:
        best_f1 = f1_threshold
        best_threshold = threshold

print(f"Optimal threshold: {best_threshold:.3f}, F1-score: {best_f1:.3f}")
```

Novelty detection requires careful validation with realistic test data containing both normal and novel examples. Parameter tuning balances false positive and false negative rates based on application requirements.

