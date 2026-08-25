## RandomForestRegressor Ensemble


RandomForestRegressor combines multiple decision trees through bootstrap aggregating (bagging) and random feature selection, reducing overfitting while maintaining interpretability. This ensemble method creates diverse trees by training each on different subsets of data and features.

### Core Implementation and Configuration

```python
from sklearn.ensemble import RandomForestRegressor
from sklearn.datasets import load_diabetes
from sklearn.model_selection import cross_val_score

# Load sample dataset
diabetes = load_diabetes()
X, y = diabetes.data, diabetes.target

# Basic random forest configuration
rf_regressor = RandomForestRegressor(
    n_estimators=100,          # Number of trees
    max_depth=10,              # Maximum depth per tree
    min_samples_split=5,       # Minimum samples to split
    min_samples_leaf=2,        # Minimum samples in leaf
    max_features='sqrt',       # Features per split
    bootstrap=True,            # Bootstrap sampling
    random_state=42,
    n_jobs=-1                  # Parallel processing
)

# Fit the ensemble
rf_regressor.fit(X_train, y_train)
predictions = rf_regressor.predict(X_test)
```

### Advanced Ensemble Configuration

**Bootstrap and Sampling Control**:

```python
# Customized bootstrap sampling
advanced_rf = RandomForestRegressor(
    n_estimators=200,
    bootstrap=True,              # Enable bootstrap sampling
    max_samples=0.8,            # Fraction of samples per tree
    oob_score=True,             # Out-of-bag score calculation
    warm_start=False,           # Enable incremental training
    random_state=42
)

# Access out-of-bag score
advanced_rf.fit(X_train, y_train)
oob_score = advanced_rf.oob_score_
print(f"Out-of-bag R² score: {oob_score:.4f}")
```

**Feature Randomness Configuration**:

```python
# Different feature selection strategies
feature_strategies = {
    'sqrt_features': RandomForestRegressor(max_features='sqrt'),      # √n_features
    'log2_features': RandomForestRegressor(max_features='log2'),      # log₂(n_features)
    'third_features': RandomForestRegressor(max_features=0.33),       # 1/3 of features
    'all_features': RandomForestRegressor(max_features=None),         # All features
}

# Compare strategies
for name, model in feature_strategies.items():
    scores = cross_val_score(model, X_train, y_train, cv=5, scoring='r2')
    print(f"{name}: {scores.mean():.4f} ± {scores.std():.4f}")
```

### Parallel Processing and Scalability

RandomForest naturally supports parallel processing for improved performance:

```python
import time
from joblib import parallel_backend

# Compare parallel processing backends
backends = ['threading', 'multiprocessing']
n_jobs_options = [1, 2, 4, -1]  # -1 uses all available cores

performance_results = {}

for backend in backends:
    for n_jobs in n_jobs_options:
        with parallel_backend(backend):
            rf = RandomForestRegressor(
                n_estimators=200,
                n_jobs=n_jobs,
                random_state=42
            )
            
            start_time = time.time()
            rf.fit(X_train, y_train)
            training_time = time.time() - start_time
            
            performance_results[f'{backend}_{n_jobs}'] = training_time
```

### Incremental Learning and Model Updates

```python
# Incremental training with warm_start
incremental_rf = RandomForestRegressor(
    n_estimators=50,
    warm_start=True,
    random_state=42
)

# Initial training
incremental_rf.fit(X_train, y_train)
initial_score = incremental_rf.score(X_test, y_test)

# Add more estimators incrementally
for additional_trees in [25, 50, 75]:
    incremental_rf.n_estimators += additional_trees
    incremental_rf.fit(X_train, y_train)
    current_score = incremental_rf.score(X_test, y_test)
    print(f"Trees: {incremental_rf.n_estimators}, R²: {current_score:.4f}")
```

### Prediction Intervals and Uncertainty Quantification

Random forests provide natural uncertainty estimates through prediction variance:

```python
def predict_with_uncertainty(rf_model, X, confidence=0.95):
    """
    Generate predictions with uncertainty intervals
    """
    # Get predictions from all trees
    tree_predictions = np.array([tree.predict(X) for tree in rf_model.estimators_])
    
    # Calculate statistics
    mean_pred = np.mean(tree_predictions, axis=0)
    std_pred = np.std(tree_predictions, axis=0)
    
    # Confidence intervals
    z_score = 1.96 if confidence == 0.95 else 2.576  # 95% or 99%
    lower_bound = mean_pred - z_score * std_pred
    upper_bound = mean_pred + z_score * std_pred
    
    return {
        'prediction': mean_pred,
        'std': std_pred,
        'lower_bound': lower_bound,
        'upper_bound': upper_bound
    }

# Generate predictions with uncertainty
uncertainty_results = predict_with_uncertainty(rf_regressor, X_test)
```

**Key Points**:

- Reduces overfitting through ensemble averaging
- Provides natural feature importance rankings
- Handles large datasets efficiently with parallel processing
- Offers uncertainty quantification through prediction variance

