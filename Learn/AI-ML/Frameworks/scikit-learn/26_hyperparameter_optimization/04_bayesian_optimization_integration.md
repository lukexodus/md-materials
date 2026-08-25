## Bayesian Optimization Integration


While scikit-learn doesn't include built-in Bayesian optimization, it integrates seamlessly with specialized libraries like scikit-optimize, Optuna, and Hyperopt that use probabilistic models to guide hyperparameter search more intelligently.

**Key points:**

- Uses probabilistic models to predict promising parameter regions
- Balances exploration of unknown areas with exploitation of known good regions
- Typically requires fewer evaluations than random or grid search
- Handles continuous, discrete, and categorical parameters effectively
- Provides uncertainty estimates for parameter importance
- Requires external libraries for implementation

**Example:**

```python
# Using scikit-optimize (skopt)
from skopt import BayesSearchCV
from skopt.space import Real, Categorical, Integer

# Define search space with skopt dimensions
search_space = {
    'n_estimators': Integer(50, 500),
    'max_depth': Categorical([3, 5, 7, 10, None]),
    'min_samples_split': Integer(2, 20),
    'min_samples_leaf': Integer(1, 10),
    'max_features': Real(0.1, 1.0)
}

# Initialize Bayesian optimization
bayes_search = BayesSearchCV(
    estimator=RandomForestClassifier(random_state=42),
    search_spaces=search_space,
    n_iter=50,
    cv=5,
    scoring='accuracy',
    n_jobs=-1,
    random_state=42
)

# Perform Bayesian optimization
bayes_search.fit(X_train, y_train)
print(f"Best parameters: {bayes_search.best_params_}")
print(f"Best cross-validation score: {bayes_search.best_score_:.4f}")

# Analyze optimization progression
import matplotlib.pyplot as plt
plt.figure(figsize=(10, 6))
plt.plot(bayes_search.cv_results_['mean_test_score'])
plt.xlabel('Iteration')
plt.ylabel('Cross-validation Score')
plt.title('Bayesian Optimization Progress')
plt.show()
```

Bayesian optimization excels when evaluations are expensive and the parameter space is complex or high-dimensional.

