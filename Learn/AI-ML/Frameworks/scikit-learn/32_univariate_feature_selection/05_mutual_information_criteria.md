## Mutual Information Criteria


Mutual information measures the amount of information obtained about one variable through observing another variable, capturing both linear and non-linear relationships.

**Key points:**

- `mutual_info_classif`: For classification tasks
- `mutual_info_regression`: For regression tasks
- Captures non-linear relationships that other methods might miss
- Does not assume any specific distribution
- Values range from 0 (independent) to higher values (more dependent)
- More computationally intensive than statistical tests

```python
from sklearn.feature_selection import mutual_info_classif, mutual_info_regression
from sklearn.datasets import make_classification, make_regression
import matplotlib.pyplot as plt

# Classification example
X_classif, y_classif = make_classification(n_samples=1000, n_features=20, 
                                          n_informative=10, n_redundant=5, 
                                          random_state=42)

mi_scores_classif = mutual_info_classif(X_classif, y_classif, random_state=42)

# Select features using mutual information
selector_mi = SelectKBest(score_func=mutual_info_classif, k=10)
X_classif_selected = selector_mi.fit_transform(X_classif, y_classif)

print("Mutual Information Classification Results:")
mi_rankings = np.argsort(mi_scores_classif)[::-1]
for i in range(10):
    idx = mi_rankings[i]
    print(f"Feature {idx}: MI Score={mi_scores_classif[idx]:.4f}")

# Regression example
X_reg, y_reg = make_regression(n_samples=1000, n_features=15, 
                              n_informative=8, random_state=42)

mi_scores_reg = mutual_info_regression(X_reg, y_reg, random_state=42)

# Compare with F-test for regression
f_scores_reg, _ = f_regression(X_reg, y_reg)

# Normalize scores for comparison
mi_normalized = mi_scores_reg / np.max(mi_scores_reg)
f_normalized = f_scores_reg / np.max(f_scores_reg)

print(f"\nCorrelation between MI and F-test scores: {np.corrcoef(mi_normalized, f_normalized)[0,1]:.4f}")
```

**Configuration parameters:**

- `discrete_features`: Specify which features are discrete
- `n_neighbors`: Number of neighbors for k-NN entropy estimation
- `copy`: Whether to make a copy of the data
- `random_state`: For reproducible results

