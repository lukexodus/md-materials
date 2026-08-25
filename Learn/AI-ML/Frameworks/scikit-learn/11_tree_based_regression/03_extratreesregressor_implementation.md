## ExtraTreesRegressor Implementation


ExtraTreesRegressor (Extremely Randomized Trees) extends the random forest concept by introducing additional randomness in split selection. Instead of searching for the best split among random features, it randomly selects both features and split thresholds, creating highly diverse trees with reduced computational complexity.

### Core Implementation and Distinctions

```python
from sklearn.ensemble import ExtraTreesRegressor
import numpy as np
from sklearn.model_selection import validation_curve

# Basic Extra Trees configuration
et_regressor = ExtraTreesRegressor(
    n_estimators=100,
    max_depth=None,            # Unlimited depth by default
    min_samples_split=2,       # More aggressive splitting
    min_samples_leaf=1,        # Single sample leaves allowed
    max_features='sqrt',       # Random feature selection
    bootstrap=False,           # Uses entire dataset by default
    random_state=42,
    n_jobs=-1
)

# Compare with Random Forest
rf_comparison = RandomForestRegressor(
    n_estimators=100,
    max_depth=None,
    bootstrap=True,
    random_state=42,
    n_jobs=-1
)

# Fit both models
et_regressor.fit(X_train, y_train)
rf_comparison.fit(X_train, y_train)

# Performance comparison
et_score = et_regressor.score(X_test, y_test)
rf_score = rf_comparison.score(X_test, y_test)
print(f"Extra Trees R²: {et_score:.4f}")
print(f"Random Forest R²: {rf_score:.4f}")
```

### Advanced Configuration and Optimization

**Bootstrap vs. Pasting Comparison**:

```python
# Compare bootstrap vs pasting (sampling without replacement)
bootstrap_et = ExtraTreesRegressor(
    n_estimators=100,
    bootstrap=True,
    max_samples=0.8,  # 80% of samples per tree
    random_state=42
)

pasting_et = ExtraTreesRegressor(
    n_estimators=100,
    bootstrap=False,  # Uses entire dataset
    random_state=42
)

# Evaluate both approaches
bootstrap_scores = cross_val_score(bootstrap_et, X_train, y_train, cv=5, scoring='r2')
pasting_scores = cross_val_score(pasting_et, X_train, y_train, cv=5, scoring='r2')

print(f"Bootstrap: {bootstrap_scores.mean():.4f} ± {bootstrap_scores.std():.4f}")
print(f"Pasting: {pasting_scores.mean():.4f} ± {pasting_scores.std():.4f}")
```

**Hyperparameter Sensitivity Analysis**:

```python
# Analyze sensitivity to key hyperparameters
param_ranges = {
    'n_estimators': [10, 25, 50, 100, 200, 500],
    'max_features': [0.1, 0.3, 0.5, 'sqrt', 'log2', None],
    'min_samples_split': [2, 5, 10, 20, 50],
    'min_samples_leaf': [1, 2, 5, 10, 20]
}

sensitivity_results = {}

for param_name, param_range in param_ranges.items():
    train_scores, val_scores = validation_curve(
        ExtraTreesRegressor(random_state=42, n_jobs=-1),
        X_train, y_train,
        param_name=param_name,
        param_range=param_range,
        cv=5, scoring='r2'
    )
    
    sensitivity_results[param_name] = {
        'param_range': param_range,
        'train_scores': train_scores,
        'val_scores': val_scores,
        'best_idx': np.argmax(val_scores.mean(axis=1))
    }
```

### Computational Efficiency Analysis

Extra Trees often provides computational advantages over Random Forest:

```python
import time
from sklearn.metrics import accuracy_score

def compare_computational_efficiency(X_train, y_train, X_test, y_test, n_trials=5):
    """
    Compare computational efficiency between ExtraTrees and RandomForest
    """
    models = {
        'ExtraTrees': ExtraTreesRegressor(n_estimators=100, random_state=42, n_jobs=-1),
        'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
    }
    
    results = {}
    
    for model_name, model in models.items():
        times = []
        scores = []
        
        for trial in range(n_trials):
            # Training time
            start_time = time.time()
            model.fit(X_train, y_train)
            training_time = time.time() - start_time
            
            # Prediction time
            start_time = time.time()
            predictions = model.predict(X_test)
            prediction_time = time.time() - start_time
            
            # Performance
            score = r2_score(y_test, predictions)
            
            times.append({'train': training_time, 'predict': prediction_time})
            scores.append(score)
        
        results[model_name] = {
            'avg_train_time': np.mean([t['train'] for t in times]),
            'avg_predict_time': np.mean([t['predict'] for t in times]),
            'avg_score': np.mean(scores),
            'score_std': np.std(scores)
        }
    
    return results

# Run efficiency comparison
efficiency_results = compare_computational_efficiency(X_train, y_train, X_test, y_test)
```

### Noise Robustness and Outlier Handling

Extra Trees' additional randomness often provides better robustness to noise:

```python
def test_noise_robustness(X_clean, y_clean, noise_levels=[0.1, 0.2, 0.3, 0.5]):
    """
    Test model robustness to various noise levels
    """
    models = {
        'ExtraTrees': ExtraTreesRegressor(n_estimators=100, random_state=42),
        'RandomForest': RandomForestRegressor(n_estimators=100, random_state=42),
        'DecisionTree': DecisionTreeRegressor(random_state=42)
    }
    
    noise_results = {}
    
    for noise_level in noise_levels:
        # Add noise to target variable
        noise = np.random.normal(0, noise_level * np.std(y_clean), size=y_clean.shape)
        y_noisy = y_clean + noise
        
        X_train, X_test, y_train, y_test = train_test_split(
            X_clean, y_noisy, test_size=0.2, random_state=42
        )
        
        level_results = {}
        for model_name, model in models.items():
            model.fit(X_train, y_train)
            score = model.score(X_test, y_test)
            level_results[model_name] = score
        
        noise_results[noise_level] = level_results
    
    return noise_results

# Test noise robustness
noise_analysis = test_noise_robustness(X, y)
```

**Key Points**:

- Higher randomness reduces overfitting risk
- Computationally faster than Random Forest
- Better generalization on noisy datasets
- May sacrifice some accuracy for robustness

