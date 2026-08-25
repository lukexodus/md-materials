## Hyperparameter Tuning


Effective hyperparameter tuning is crucial for neural network performance. The parameter space is large and complex, requiring systematic approaches to find optimal configurations while avoiding overfitting to validation data.

**Key points:**

- Learning rate affects convergence speed and stability
- Network architecture determines model capacity
- Regularization strength controls overfitting
- Solver choice impacts optimization dynamics
- Early stopping prevents overtraining

### Grid Search Implementation

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.metrics import make_scorer, f1_score

# Define comprehensive parameter grid
param_grid = {
    'hidden_layer_sizes': [
        (50,), (100,), (200,),
        (50, 50), (100, 100), (100, 50),
        (150, 100, 50), (200, 100, 50, 25)
    ],
    'activation': ['tanh', 'relu'],
    'solver': ['adam', 'lbfgs'],
    'alpha': [0.0001, 0.001, 0.01, 0.1],
    'learning_rate_init': [0.001, 0.01, 0.1],
    'max_iter': [200, 300, 500]
}

# Custom scoring for multi-class problems
f1_scorer = make_scorer(f1_score, average='weighted')

# Randomized search for initial exploration
random_search = RandomizedSearchCV(
    MLPClassifier(random_state=42, early_stopping=True),
    param_grid,
    n_iter=50,  # Number of parameter combinations to try
    cv=3,
    scoring=f1_scorer,
    n_jobs=-1,
    random_state=42,
    verbose=1
)

print("Starting randomized hyperparameter search...")
random_search.fit(X_train_scaled, y_train)

print(f"\nBest parameters from random search:")
for param, value in random_search.best_params_.items():
    print(f"{param}: {value}")
print(f"Best cross-validation score: {random_search.best_score_:.4f}")
```

### Bayesian Optimization Approach

```python
# Implement manual Bayesian-style optimization
def objective_function(params):
    """Objective function for hyperparameter optimization."""
    mlp = MLPClassifier(
        hidden_layer_sizes=params['hidden_layer_sizes'],
        activation=params['activation'],
        solver=params['solver'],
        alpha=params['alpha'],
        learning_rate_init=params['learning_rate_init'],
        max_iter=params['max_iter'],
        early_stopping=True,
        validation_fraction=0.1,
        random_state=42
    )
    
    # Cross-validation score
    from sklearn.model_selection import cross_val_score
    scores = cross_val_score(mlp, X_train_scaled, y_train, cv=3, scoring='accuracy')
    return np.mean(scores)

# Systematic parameter exploration
architecture_candidates = [(100,), (100, 50), (150, 100, 50)]
activation_candidates = ['relu', 'tanh']
solver_candidates = ['adam', 'lbfgs']
alpha_candidates = [0.0001, 0.001, 0.01]
lr_candidates = [0.001, 0.01, 0.1]

best_score = 0
best_params = None
optimization_history = []

for arch in architecture_candidates:
    for act in activation_candidates:
        for sol in solver_candidates:
            for alpha in alpha_candidates[:2]:  # Limit for computational efficiency
                for lr in lr_candidates[:2]:
                    params = {
                        'hidden_layer_sizes': arch,
                        'activation': act,
                        'solver': sol,
                        'alpha': alpha,
                        'learning_rate_init': lr,
                        'max_iter': 300
                    }
                    
                    score = objective_function(params)
                    optimization_history.append((params.copy(), score))
                    
                    if score > best_score:
                        best_score = score
                        best_params = params.copy()
                    
                    print(f"Score: {score:.4f} - {arch}, {act}, {sol}, α={alpha}, lr={lr}")

print(f"\nBest configuration:")
print(f"Score: {best_score:.4f}")
for param, value in best_params.items():
    print(f"{param}: {value}")
```

### Advanced Hyperparameter Analysis

```python
# Learning rate scheduling analysis
def compare_learning_rates():
    """Compare different learning rate strategies."""
    learning_rates = ['constant', 'invscaling', 'adaptive']
    lr_results = {}
    
    for lr_schedule in learning_rates:
        mlp = MLPClassifier(
            hidden_layer_sizes=(100, 50),
            activation='relu',
            solver='sgd',  # SGD supports different learning rates
            learning_rate=lr_schedule,
            learning_rate_init=0.01,
            alpha=0.001,
            max_iter=300,
            random_state=42
        )
        
        mlp.fit(X_train_scaled, y_train)
        train_score = mlp.score(X_train_scaled, y_train)
        test_score = mlp.score(X_test_scaled, y_test)
        
        lr_results[lr_schedule] = {
            'train_score': train_score,
            'test_score': test_score,
            'loss_curve': mlp.loss_curve_
        }
        
        print(f"{lr_schedule:12} - Train: {train_score:.4f}, Test: {test_score:.4f}")
    
    # Plot learning curves
    plt.figure(figsize=(12, 4))
    for i, (schedule, results) in enumerate(lr_results.items(), 1):
        plt.subplot(1, 3, i)
        plt.plot(results['loss_curve'])
        plt.title(f'Learning Rate: {schedule}')
        plt.xlabel('Iterations')
        plt.ylabel('Loss')
        plt.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()
    
    return lr_results

lr_comparison = compare_learning_rates()

# Final model with optimal parameters
final_mlp = MLPClassifier(
    **best_params,
    early_stopping=True,
    validation_fraction=0.1,
    n_iter_no_change=15,
    random_state=42
)

final_mlp.fit(X_train_scaled, y_train)
final_predictions = final_mlp.predict(X_test_scaled)
final_probabilities = final_mlp.predict_proba(X_test_scaled)

print("\nFinal Model Performance:")
print(f"Training Accuracy: {final_mlp.score(X_train_scaled, y_train):.4f}")
print(f"Test Accuracy: {final_mlp.score(X_test_scaled, y_test):.4f}")
print(f"Iterations until convergence: {final_mlp.n_iter_}")

# Detailed classification report
print("\nClassification Report:")
print(classification_report(y_test, final_predictions))

# Confusion matrix
cm = confusion_matrix(y_test, final_predictions)
plt.figure(figsize=(8, 6))
plt.imshow(cm, interpolation='nearest', cmap=plt.cm.Blues)
plt.title('Confusion Matrix - Final MLP Model')
plt.colorbar()
tick_marks = np.arange(len(np.unique(y_test)))
plt.xticks(tick_marks, np.unique(y_test))
plt.yticks(tick_marks, np.unique(y_test))
plt.ylabel('True Label')
plt.xlabel('Predicted Label')

# Add text annotations
thresh = cm.max() / 2.
for i, j in np.ndindex(cm.shape):
    plt.text(j, i, format(cm[i, j], 'd'),
             horizontalalignment="center",
             color="white" if cm[i, j] > thresh else "black")

plt.tight_layout()
plt.show()
```

**Conclusion:** Neural network classification with MLPClassifier provides powerful non-linear modeling capabilities for complex classification tasks. Proper architecture design balances model capacity with generalization, while activation function selection affects training dynamics and representational power. Regularization techniques, particularly L2 regularization and early stopping, prevent overfitting and improve generalization. Systematic hyperparameter tuning through grid search, random search, or more sophisticated optimization methods is essential for achieving optimal performance. The combination of proper preprocessing, thoughtful architecture design, and careful regularization enables neural networks to excel on diverse classification problems.

**Next steps:** Consider exploring deep learning frameworks like TensorFlow or PyTorch for more complex architectures, implementing custom activation functions and regularization techniques, investigating ensemble methods combining multiple neural networks, and exploring advanced optimization algorithms and learning rate schedules.

---

