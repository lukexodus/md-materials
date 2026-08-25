## GridSearchCV Exhaustive Search


GridSearchCV performs an exhaustive search over specified parameter values using cross-validation to evaluate each combination. This brute-force approach guarantees finding the optimal combination within the specified parameter grid.

**Key points:**

- Tests every possible combination of hyperparameters in the specified grid
- Uses k-fold cross-validation to evaluate each combination
- Returns the best parameters and corresponding cross-validation score
- Provides detailed results for all tested combinations
- Supports parallel processing to reduce computation time

**Example:**

```python
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

# Generate sample data
X, y = make_classification(n_samples=1000, n_features=20, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Define parameter grid
param_grid = {
    'n_estimators': [100, 200, 300],
    'max_depth': [3, 5, 7, None],
    'min_samples_split': [2, 5, 10],
    'min_samples_leaf': [1, 2, 4]
}

# Initialize model and GridSearchCV
rf = RandomForestClassifier(random_state=42)
grid_search = GridSearchCV(
    estimator=rf,
    param_grid=param_grid,
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    verbose=1
)

# Fit and find best parameters
grid_search.fit(X_train, y_train)
print(f"Best parameters: {grid_search.best_params_}")
print(f"Best cross-validation score: {grid_search.best_score_:.4f}")
```

The exhaustive nature makes GridSearchCV computationally expensive but guarantees optimal results within the specified parameter space. It's most suitable for small parameter grids or when computational resources are abundant.

