## Isolation Forest Algorithms


Isolation Forest detects anomalies by measuring how easily points can be isolated from the rest of the data through recursive random partitioning. Anomalies require fewer random splits to isolate, making this approach highly efficient for large datasets and high-dimensional spaces.

**Key Points:**

- Builds ensemble of isolation trees using random feature selection and split values
- Anomalies have shorter average path lengths to tree leaves than normal points
- No distance calculations or density estimation required
- Linear time complexity O(n) makes it highly scalable
- Works well in high-dimensional spaces without distance metric issues
- Contamination parameter estimates expected anomaly fraction
- Provides continuous anomaly scores based on path length normalization

The algorithm constructs binary trees by randomly selecting features and split values until points are isolated. Path length to isolation correlates inversely with normality - normal points require more splits due to clustering.

**Example:**

```python
from sklearn.ensemble import IsolationForest
from sklearn.datasets import make_classification
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.model_selection import ParameterGrid
import numpy as np
import time

# Generate dataset with known outliers
X_normal, _ = make_classification(
    n_samples=1000, n_features=10, n_informative=8, 
    n_redundant=2, n_clusters_per_class=1, random_state=42
)

# Add anomalous points
np.random.seed(42)
X_anomaly = np.random.uniform(
    low=X_normal.min(axis=0) - 3, 
    high=X_normal.max(axis=0) + 3, 
    size=(100, 10)
)

X_combined = np.vstack([X_normal, X_anomaly])
y_true = np.hstack([np.ones(1000), -np.ones(100)])  # 1=normal, -1=anomaly

# Basic Isolation Forest
iso_forest = IsolationForest(contamination=0.1, random_state=42)
y_pred = iso_forest.fit_predict(X_combined)
anomaly_scores = iso_forest.decision_function(X_combined)

print("Basic Isolation Forest Results:")
print(classification_report(y_true, y_pred))

# Parameter optimization
param_grid = {
    'n_estimators': [50, 100, 200],
    'max_samples': ['auto', 0.5, 0.7, 1.0],
    'contamination': [0.05, 0.1, 0.15, 0.2],
    'max_features': [1.0, 0.5, 0.8]
}

best_score = -1
best_params = {}
results = []

for params in ParameterGrid(param_grid):
    iso_forest_param = IsolationForest(random_state=42, **params)
    
    # Measure training time
    start_time = time.time()
    predictions = iso_forest_param.fit_predict(X_combined)
    training_time = time.time() - start_time
    
    # Calculate F1 score
    from sklearn.metrics import f1_score
    f1 = f1_score(y_true, predictions)
    
    results.append({
        'params': params,
        'f1_score': f1,
        'training_time': training_time
    })
    
    if f1 > best_score:
        best_score = f1
        best_params = params

print(f"\nBest parameters: {best_params}")
print(f"Best F1-score: {best_score:.3f}")

# Scalability analysis
sample_sizes = [1000, 5000, 10000, 50000]
scalability_results = {}

for n_samples in sample_sizes:
    # Generate larger datasets
    X_large, _ = make_classification(
        n_samples=n_samples, n_features=10, random_state=42
    )
    
    # Measure training time
    iso_forest_scale = IsolationForest(n_estimators=100, random_state=42)
    start_time = time.time()
    iso_forest_scale.fit(X_large)
    training_time = time.time() - start_time
    
    scalability_results[n_samples] = training_time

print("\nScalability Analysis:")
for n_samples, time_taken in scalability_results.items():
    print(f"Samples: {n_samples}, Training time: {time_taken:.3f}s")

# High-dimensional performance
dimensions = [10, 50, 100, 500]
high_dim_results = {}

for n_features in dimensions:
    # Generate high-dimensional data
    X_high_dim = np.random.randn(1000, n_features)
    X_high_dim_anomaly = np.random.randn(100, n_features) * 3  # Scaled anomalies
    
    X_high_combined = np.vstack([X_high_dim, X_high_dim_anomaly])
    y_high_true = np.hstack([np.ones(1000), -np.ones(100)])
    
    iso_forest_high = IsolationForest(contamination=0.1, random_state=42)
    y_high_pred = iso_forest_high.fit_predict(X_high_combined)
    
    f1_high = f1_score(y_high_true, y_high_pred)
    high_dim_results[n_features] = f1_high

print("\nHigh-dimensional Performance:")
for n_features, f1_score_val in high_dim_results.items():
    print(f"Features: {n_features}, F1-score: {f1_score_val:.3f}")

# Anomaly score analysis
best_iso_forest = IsolationForest(random_state=42, **best_params)
best_iso_forest.fit(X_combined)
final_scores = best_iso_forest.decision_function(X_combined)

# Separate scores by true class
normal_scores = final_scores[y_true == 1]
anomaly_scores_true = final_scores[y_true == -1]

print(f"\nNormal data scores: mean={normal_scores.mean():.3f}, std={normal_scores.std():.3f}")
print(f"Anomaly scores: mean={anomaly_scores_true.mean():.3f}, std={anomaly_scores_true.std():.3f}")

# Custom threshold optimization
thresholds = np.linspace(final_scores.min(), final_scores.max(), 100)
threshold_results = []

for threshold in thresholds:
    threshold_predictions = np.where(final_scores < threshold, -1, 1)
    threshold_f1 = f1_score(y_true, threshold_predictions)
    
    # Calculate precision and recall
    tp = np.sum((threshold_predictions == -1) & (y_true == -1))
    fp = np.sum((threshold_predictions == -1) & (y_true == 1))
    fn = np.sum((threshold_predictions == 1) & (y_true == -1))
    
    precision = tp / (tp + fp + 1e-7)
    recall = tp / (tp + fn + 1e-7)
    
    threshold_results.append({
        'threshold': threshold,
        'f1': threshold_f1,
        'precision': precision,
        'recall': recall
    })

# Find optimal threshold
optimal_result = max(threshold_results, key=lambda x: x['f1'])
print(f"\nOptimal threshold: {optimal_result['threshold']:.3f}")
print(f"Optimal F1: {optimal_result['f1']:.3f}")
print(f"Precision: {optimal_result['precision']:.3f}")
print(f"Recall: {optimal_result['recall']:.3f}")

# Feature importance through path length analysis
feature_importance = np.zeros(X_combined.shape[1])
for tree in best_iso_forest.estimators_:
    # Simple feature usage frequency as proxy for importance
    feature_usage = np.bincount(tree.tree_.feature[tree.tree_.feature >= 0], 
                                minlength=X_combined.shape[1])
    feature_importance += feature_usage

feature_importance = feature_importance / feature_importance.sum()
print(f"\nTop 3 most important features: {np.argsort(feature_importance)[-3:]}")
```

Isolation Forest provides efficient anomaly detection through ensemble-based path length analysis. Its linear complexity and parameter stability make it ideal for large-scale applications with minimal parameter tuning requirements.

**Conclusion:** Scikit-learn's density estimation methods address diverse unsupervised learning scenarios through different mathematical foundations. Gaussian Mixture Models provide parametric flexibility for multimodal distributions, Kernel Density Estimation offers non-parametric adaptability, novelty detection methods identify deviations from normal patterns, One-Class SVM leverages kernel methods for robust boundary learning, and Isolation Forest provides scalable ensemble-based anomaly detection.

**Next Steps:** Advanced density estimation techniques include deep generative models for complex distributions, streaming anomaly detection for real-time applications, ensemble methods combining multiple density estimators, and domain-specific adaptations incorporating prior knowledge or specialized distance metrics for improved performance in specific application areas.

---

