## RandomizedSearchCV Efficiency


RandomizedSearchCV samples a fixed number of parameter combinations from specified distributions, offering significant computational savings while maintaining good performance discovery capabilities.

**Key points:**

- Samples random combinations instead of testing all possibilities
- Allows specification of probability distributions for continuous parameters
- Provides better exploration of parameter space with limited computational budget
- Often finds near-optimal solutions much faster than exhaustive search
- Particularly effective when some hyperparameters have minimal impact on performance

**Example:**

```python
from sklearn.model_selection import RandomizedSearchCV
from scipy.stats import randint, uniform
import numpy as np

# Define parameter distributions
param_distributions = {
    'n_estimators': randint(50, 500),
    'max_depth': [3, 5, 7, 10, None],
    'min_samples_split': randint(2, 20),
    'min_samples_leaf': randint(1, 10),
    'max_features': uniform(0.1, 0.8)
}

# Initialize RandomizedSearchCV
random_search = RandomizedSearchCV(
    estimator=RandomForestClassifier(random_state=42),
    param_distributions=param_distributions,
    n_iter=100,  # Number of parameter settings sampled
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    random_state=42,
    verbose=1
)

# Fit and evaluate
random_search.fit(X_train, y_train)
print(f"Best parameters: {random_search.best_params_}")
print(f"Best cross-validation score: {random_search.best_score_:.4f}")

# Compare with GridSearchCV results
print(f"Time saved compared to exhaustive search: ~{len(param_grid['n_estimators']) * len(param_grid['max_depth']) * len(param_grid['min_samples_split']) * len(param_grid['min_samples_leaf']) / 100:.1f}x")
```

RandomizedSearchCV excels in high-dimensional parameter spaces and when working with limited time or computational resources.

