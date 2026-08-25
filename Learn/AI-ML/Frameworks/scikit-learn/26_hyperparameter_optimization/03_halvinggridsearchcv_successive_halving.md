## HalvingGridSearchCV Successive Halving


HalvingGridSearchCV uses successive halving to efficiently identify promising parameter combinations by starting with small resource allocations and progressively eliminating poor performers while increasing resources for remaining candidates.

**Key points:**

- Starts evaluation with minimal resources (small datasets or few iterations)
- Eliminates worst-performing parameter combinations at each stage
- Doubles resources for remaining candidates in subsequent rounds
- Provides significant speedup over traditional grid search
- Maintains high probability of finding optimal parameters
- Available in sklearn.experimental.enable_halving_search_cv

**Example:**

```python
from sklearn.experimental import enable_halving_search_cv
from sklearn.model_selection import HalvingGridSearchCV

# Enable experimental feature
param_grid = {
    'n_estimators': [50, 100, 200, 300, 400, 500],
    'max_depth': [3, 5, 7, 10, None],
    'min_samples_split': [2, 5, 10, 15],
    'min_samples_leaf': [1, 2, 4, 8]
}

# Initialize HalvingGridSearchCV
halving_search = HalvingGridSearchCV(
    estimator=RandomForestClassifier(random_state=42),
    param_grid=param_grid,
    factor=2,  # Factor by which resources increase each iteration
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    random_state=42
)

# Fit with successive halving
halving_search.fit(X_train, y_train)
print(f"Best parameters: {halving_search.best_params_}")
print(f"Best cross-validation score: {halving_search.best_score_:.4f}")
print(f"Number of iterations: {halving_search.n_iterations_}")

# Analyze resource allocation progression
for i in range(halving_search.n_iterations_):
    results = halving_search.cv_results_
    n_candidates = sum(results[f'iter_{i}'])
    n_resources = halving_search.n_resources_[i]
    print(f"Iteration {i}: {n_candidates} candidates, {n_resources} resources")
```

Successive halving is particularly effective for expensive models or large datasets where traditional grid search becomes prohibitively slow.

