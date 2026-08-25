## GradientBoostingRegressor Optimization


GradientBoostingRegressor builds models sequentially, with each new tree correcting errors made by previous trees. This boosting approach often achieves superior predictive performance but requires careful hyperparameter tuning to prevent overfitting and optimize convergence.

### Core Implementation and Sequential Learning

```python
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.model_selection import learning_curve
import matplotlib.pyplot as plt

# Basic gradient boosting configuration
gb_regressor = GradientBoostingRegressor(
    n_estimators=100,          # Number of boosting stages
    learning_rate=0.1,         # Shrinks contribution of each tree
    max_depth=3,               # Depth of individual trees
    min_samples_split=20,      # Minimum samples to split
    min_samples_leaf=10,       # Minimum samples in leaf
    subsample=0.8,             # Fraction of samples for fitting
    max_features='sqrt',       # Features considered for split
    loss='squared_error',      # Loss function
    random_state=42
)

# Fit with early stopping monitoring
gb_regressor.fit(X_train, y_train)

# Monitor training progress
train_scores = gb_regressor.train_score_
plt.figure(figsize=(10, 6))
plt.plot(range(1, len(train_scores) + 1), train_scores, label='Training Score')
plt.xlabel('Boosting Iterations')
plt.ylabel('Loss')
plt.title('Gradient Boosting Training Progress')
plt.legend()
plt.show()
```

### Advanced Loss Functions and Optimization

GradientBoosting supports multiple loss functions for different optimization objectives:

```python
# Different loss functions for various objectives
loss_functions = {
    'squared_error': GradientBoostingRegressor(loss='squared_error', random_state=42),
    'absolute_error': GradientBoostingRegressor(loss='absolute_error', random_state=42),
    'huber': GradientBoostingRegressor(loss='huber', alpha=0.9, random_state=42),
    'quantile': GradientBoostingRegressor(loss='quantile', alpha=0.9, random_state=42)
}

# Compare loss functions
loss_comparison = {}
for loss_name, model in loss_functions.items():
    model.fit(X_train, y_train)
    train_score = model.score(X_train, y_train)
    test_score = model.score(X_test, y_test)
    
    loss_comparison[loss_name] = {
        'train_r2': train_score,
        'test_r2': test_score,
        'overfitting': train_score - test_score
    }
```

### Learning Rate and Number of Estimators Optimization

The relationship between learning rate and number of estimators is crucial for optimal performance:

```python
def optimize_learning_rate_estimators(X_train, y_train, X_val, y_val):
    """
    Systematic optimization of learning rate and n_estimators
    """
    learning_rates = [0.01, 0.05, 0.1, 0.15, 0.2]
    max_estimators = 1000
    
    optimization_results = {}
    
    for lr in learning_rates:
        # Use validation monitoring for early stopping
        gb = GradientBoostingRegressor(
            learning_rate=lr,
            n_estimators=max_estimators,
            max_depth=3,
            subsample=0.8,
            random_state=42,
            validation_fraction=0.2,
            n_iter_no_change=20,  # Early stopping
            tol=0.0001
        )
        
        gb.fit(X_train, y_train)
        
        # Find optimal number of estimators
        val_scores = []
        for i in range(1, gb.n_estimators_ + 1):
            gb_temp = GradientBoostingRegressor(
                learning_rate=lr,
                n_estimators=i,
                max_depth=3,
                subsample=0.8,
                random_state=42
            )
            gb_temp.fit(X_train, y_train)
            val_scores.append(gb_temp.score(X_val, y_val))
        
        best_n_estimators = np.argmax(val_scores) + 1
        best_score = max(val_scores)
        
        optimization_results[lr] = {
            'best_n_estimators': best_n_estimators,
            'best_score': best_score,
            'final_n_estimators': gb.n_estimators_
        }
    
    return optimization_results

# Run optimization
X_temp, X_val, y_temp, y_val = train_test_split(X_train, y_train, test_size=0.2, random_state=42)
lr_optimization = optimize_learning_rate_estimators(X_temp, y_temp, X_val, y_val)
```

### Regularization and Overfitting Control

Multiple regularization techniques help control overfitting in gradient boosting:

```python
# Comprehensive regularization configuration
regularized_gb = GradientBoostingRegressor(
    n_estimators=200,
    learning_rate=0.05,        # Lower learning rate
    max_depth=4,               # Limit tree depth
    min_samples_split=50,      # Higher split threshold
    min_samples_leaf=20,       # Higher leaf threshold
    subsample=0.8,             # Stochastic gradient boosting
    max_features=0.7,          # Feature subsampling
    ccp_alpha=0.01,           # Cost complexity pruning
    validation_fraction=0.1,   # Validation set for monitoring
    n_iter_no_change=10,      # Early stopping patience
    random_state=42
)

# Monitor overfitting during training
regularized_gb.fit(X_train, y_train)

# Plot learning curves
def plot_learning_curves(model, X_train, y_train):
    """Plot training and validation learning curves"""
    train_sizes, train_scores, val_scores = learning_curve(
        model, X_train, y_train, cv=5, 
        train_sizes=np.linspace(0.1, 1.0, 10),
        scoring='r2', n_jobs=-1
    )
    
    plt.figure(figsize=(10, 6))
    plt.plot(train_sizes, np.mean(train_scores, axis=1), 'o-', label='Training Score')
    plt.plot(train_sizes, np.mean(val_scores, axis=1), 'o-', label='Validation Score')
    plt.fill_between(train_sizes, 
                     np.mean(train_scores, axis=1) - np.std(train_scores, axis=1),
                     np.mean(train_scores, axis=1) + np.std(train_scores, axis=1),
                     alpha=0.1)
    plt.xlabel('Training Set Size')
    plt.ylabel('R² Score')
    plt.title('Learning Curves - Gradient Boosting')
    plt.legend()
    plt.grid(True)
    plt.show()

plot_learning_curves(regularized_gb, X_train, y_train)
```

### Feature Interaction and Staged Prediction

Gradient boosting naturally captures feature interactions and provides staged predictions:

```python
# Analyze staged predictions (predictions at each boosting stage)
def analyze_staged_predictions(model, X_test, y_test):
    """
    Analyze how predictions evolve through boosting stages
    """
    staged_predictions = list(model.staged_predict(X_test))
    staged_scores = [r2_score(y_test, pred) for pred in staged_predictions]
    
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.plot(range(1, len(staged_scores) + 1), staged_scores)
    plt.xlabel('Boosting Iterations')
    plt.ylabel('R² Score')
    plt.title('Test Score vs. Boosting Iterations')
    plt.grid(True)
    
    # Show prediction evolution for first few samples
    plt.subplot(1, 2, 2)
    for i in range(min(5, len(X_test))):
        sample_predictions = [pred[i] for pred in staged_predictions]
        plt.plot(range(1, len(sample_predictions) + 1), sample_predictions, 
                alpha=0.7, label=f'Sample {i+1} (True: {y_test[i]:.2f})')
    
    plt.xlabel('Boosting Iterations')
    plt.ylabel('Predicted Value')
    plt.title('Prediction Evolution for Sample Points')
    plt.legend()
    plt.grid(True)
    plt.tight_layout()
    plt.show()
    
    return staged_scores

# Analyze staged predictions
staged_analysis = analyze_staged_predictions(gb_regressor, X_test, y_test)
```

**Key Points**:

- Sequential learning corrects previous model errors
- Highly sensitive to hyperparameter settings
- Requires careful regularization to prevent overfitting
- Provides excellent predictive performance when properly tuned

