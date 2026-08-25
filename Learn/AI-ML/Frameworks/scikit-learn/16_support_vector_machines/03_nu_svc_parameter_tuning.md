## Nu-SVC Parameter Tuning


Nu-SVC provides an alternative parameterization using the nu parameter instead of C, controlling both error tolerance and support vector fraction. This formulation offers more intuitive parameter interpretation and automatic margin optimization.

**Key Points:**

- Nu parameter (0 < nu ≤ 1) represents upper bound on training error fraction
- Nu also represents lower bound on support vector fraction
- Automatic selection of optimal margin width
- More stable across different datasets than C parameterization
- Computationally more expensive than standard SVC
- Better theoretical guarantees for generalization

The nu parameter directly controls model complexity - lower values create simpler models with fewer support vectors, while higher values allow more complex decision boundaries with increased support vector usage.

**Example:**

```python
from sklearn.svm import NuSVC
from sklearn.model_selection import GridSearchCV
from sklearn.metrics import classification_report

# Basic Nu-SVC with different nu values
nu_svc_conservative = NuSVC(nu=0.1, kernel='rbf', gamma='scale')
nu_svc_flexible = NuSVC(nu=0.5, kernel='rbf', gamma='scale')

# Grid search for optimal nu parameter
param_grid = {
    'nu': [0.1, 0.2, 0.3, 0.4, 0.5, 0.7],
    'gamma': ['scale', 'auto', 0.001, 0.01, 0.1, 1],
    'kernel': ['rbf', 'poly', 'sigmoid']
}

nu_svc = NuSVC(random_state=42)
grid_search = GridSearchCV(
    nu_svc, param_grid, cv=5, scoring='accuracy', n_jobs=-1
)

grid_search.fit(X_train, y_train)
best_nu_svc = grid_search.best_estimator_

# Compare support vector counts
print(f"Support vectors: {len(best_nu_svc.support_)}")
print(f"Support vector ratio: {len(best_nu_svc.support_) / len(X_train):.3f}")
```

Nu-SVC particularly benefits datasets where traditional C parameter tuning proves difficult or when explicit control over support vector fraction is desired.

