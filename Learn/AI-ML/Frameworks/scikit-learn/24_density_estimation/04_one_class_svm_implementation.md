## One-Class SVM Implementation


One-Class SVM learns a decision function that captures normal data region by finding the hyperplane that best separates data from the origin with maximum margin. This approach maps data to high-dimensional space where separation becomes feasible, making it effective for complex data distributions.

**Key Points:**

- Maps data to high-dimensional feature space using kernel functions
- Finds hyperplane separating data from origin with maximum margin
- Nu parameter controls training error upper bound and support vector fraction
- Gamma parameter controls kernel coefficient for RBF kernels
- Robust to outliers in training data when nu is appropriately set
- Scales well to high-dimensional data through kernel trick
- Decision function provides continuous anomaly scores

The algorithm maximizes margin between data and origin in kernel space. Support vectors define the boundary, and the nu parameter acts similarly to Nu-SVC, controlling both error tolerance and model complexity.

**Example:**

```python
from sklearn.svm import OneClassSVM
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import validation_curve
from sklearn.datasets import fetch_openml
import numpy as np

# Load realistic dataset (using digits for demonstration)
digits = fetch_openml('mnist_784', version=1, parser='auto')
X_digits = digits.data[:1000]  # Subset for computational efficiency
y_digits = digits.target[:1000]

# Use only digit '0' as normal class for novelty detection
normal_mask = (y_digits == '0')
X_normal = X_digits[normal_mask]
X_anomaly = X_digits[~normal_mask][:100]  # Sample of other digits

# Preprocessing
scaler = StandardScaler()
X_normal_scaled = scaler.fit_transform(X_normal)
X_anomaly_scaled = scaler.transform(X_anomaly)

# One-Class SVM with different kernels
kernels = ['rbf', 'poly', 'sigmoid']
kernel_results = {}

for kernel in kernels:
    if kernel == 'rbf':
        oc_svm = OneClassSVM(kernel=kernel, gamma='scale', nu=0.1)
    elif kernel == 'poly':
        oc_svm = OneClassSVM(kernel=kernel, degree=3, nu=0.1)
    else:  # sigmoid
        oc_svm = OneClassSVM(kernel=kernel, gamma='scale', nu=0.1)
    
    oc_svm.fit(X_normal_scaled)
    
    # Evaluate on normal and anomalous data
    normal_scores = oc_svm.decision_function(X_normal_scaled)
    anomaly_scores = oc_svm.decision_function(X_anomaly_scaled)
    
    # Calculate separation quality
    normal_predictions = oc_svm.predict(X_normal_scaled)
    anomaly_predictions = oc_svm.predict(X_anomaly_scaled)
    
    normal_acceptance = np.mean(normal_predictions == 1)
    anomaly_rejection = np.mean(anomaly_predictions == -1)
    
    kernel_results[kernel] = {
        'normal_acceptance': normal_acceptance,
        'anomaly_rejection': anomaly_rejection,
        'support_vectors': len(oc_svm.support_)
    }

for kernel, results in kernel_results.items():
    print(f"{kernel}: Normal acceptance: {results['normal_acceptance']:.3f}, "
          f"Anomaly rejection: {results['anomaly_rejection']:.3f}, "
          f"Support vectors: {results['support_vectors']}")

# Nu parameter validation curve
nu_range = np.logspace(-3, -0.5, 10)
train_scores, validation_scores = validation_curve(
    OneClassSVM(kernel='rbf', gamma='scale'),
    X_normal_scaled, np.ones(len(X_normal_scaled)),  # Dummy labels for validation
    param_name='nu', param_range=nu_range,
    cv=5, scoring='accuracy'
)

optimal_nu_idx = np.argmax(np.mean(validation_scores, axis=1))
optimal_nu = nu_range[optimal_nu_idx]

print(f"Optimal nu parameter: {optimal_nu:.4f}")

# Final model with optimal parameters
final_oc_svm = OneClassSVM(kernel='rbf', gamma='scale', nu=optimal_nu)
final_oc_svm.fit(X_normal_scaled)

# Decision boundary analysis
decision_scores_normal = final_oc_svm.decision_function(X_normal_scaled)
decision_scores_anomaly = final_oc_svm.decision_function(X_anomaly_scaled)

print(f"Normal data score range: [{decision_scores_normal.min():.3f}, {decision_scores_normal.max():.3f}]")
print(f"Anomaly score range: [{decision_scores_anomaly.min():.3f}, {decision_scores_anomaly.max():.3f}]")

# Support vector analysis
support_vector_indices = final_oc_svm.support_
print(f"Support vector ratio: {len(support_vector_indices) / len(X_normal_scaled):.3f}")
print(f"Expected ratio (nu): {optimal_nu:.3f}")

# Custom threshold setting
thresholds = np.linspace(-2, 1, 100)
precision_scores = []
recall_scores = []

for threshold in thresholds:
    # Create combined test set
    X_test_combined = np.vstack([X_normal_scaled, X_anomaly_scaled])
    y_test_combined = np.hstack([np.ones(len(X_normal_scaled)), 
                                 -np.ones(len(X_anomaly_scaled))])
    
    scores_combined = final_oc_svm.decision_function(X_test_combined)
    predictions = np.where(scores_combined >= threshold, 1, -1)
    
    # Calculate precision and recall for anomaly detection
    true_positives = np.sum((predictions == -1) & (y_test_combined == -1))
    false_positives = np.sum((predictions == -1) & (y_test_combined == 1))
    false_negatives = np.sum((predictions == 1) & (y_test_combined == -1))
    
    precision = true_positives / (true_positives + false_positives + 1e-7)
    recall = true_positives / (true_positives + false_negatives + 1e-7)
    
    precision_scores.append(precision)
    recall_scores.append(recall)

# Find optimal threshold balancing precision and recall
f1_scores = 2 * (np.array(precision_scores) * np.array(recall_scores)) / \
            (np.array(precision_scores) + np.array(recall_scores) + 1e-7)

optimal_threshold_idx = np.argmax(f1_scores)
optimal_threshold = thresholds[optimal_threshold_idx]

print(f"Optimal threshold: {optimal_threshold:.3f}")
print(f"Best F1-score: {f1_scores[optimal_threshold_idx]:.3f}")
```

One-Class SVM provides robust novelty detection through kernel-based margin maximization. Parameter optimization and threshold tuning enable fine-grained control over detection sensitivity for specific applications.

