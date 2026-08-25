## Regularization Techniques


Regularization prevents overfitting in neural networks by constraining model complexity. MLPClassifier implements L2 regularization through the alpha parameter, while other techniques like early stopping and dropout-like effects can be achieved through careful configuration.

**Key points:**

- L2 regularization (weight decay) penalizes large weights
- Early stopping prevents overfitting by monitoring validation performance
- Batch size and learning rate affect implicit regularization
- Proper initialization and normalization act as regularization
- Cross-validation helps select optimal regularization strength

### L2 Regularization Analysis

```python
from sklearn.model_selection import validation_curve

# Test different regularization strengths
alpha_range = np.logspace(-5, 1, 10)  # 10^-5 to 10^1

train_scores, val_scores = validation_curve(
    MLPClassifier(
        hidden_layer_sizes=(200, 100),
        activation='relu',
        solver='adam',
        max_iter=300,
        early_stopping=True,
        validation_fraction=0.15,
        random_state=42
    ),
    X_train_scaled, y_train,
    param_name='alpha',
    param_range=alpha_range,
    cv=3,
    scoring='accuracy',
    n_jobs=-1
)

# Plot regularization curve
plt.figure(figsize=(10, 6))
train_mean = np.mean(train_scores, axis=1)
train_std = np.std(train_scores, axis=1)
val_mean = np.mean(val_scores, axis=1)
val_std = np.std(val_scores, axis=1)

plt.semilogx(alpha_range, train_mean, 'o-', color='blue', label='Training Score')
plt.fill_between(alpha_range, train_mean - train_std, train_mean + train_std, alpha=0.1, color='blue')
plt.semilogx(alpha_range, val_mean, 'o-', color='red', label='Validation Score')
plt.fill_between(alpha_range, val_mean - val_std, val_mean + val_std, alpha=0.1, color='red')

plt.xlabel('Alpha (Regularization Strength)')
plt.ylabel('Accuracy Score')
plt.title('L2 Regularization Effect on Neural Network Performance')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()

# Find optimal alpha
optimal_idx = np.argmax(val_mean)
optimal_alpha = alpha_range[optimal_idx]
print(f"Optimal alpha: {optimal_alpha:.6f}")
print(f"Best validation score: {val_mean[optimal_idx]:.4f} ± {val_std[optimal_idx]:.4f}")
```

### Early Stopping Implementation

```python
# Comprehensive early stopping analysis
def train_with_early_stopping_analysis(X_train, y_train, X_val, y_val):
    """Train MLP with detailed early stopping monitoring."""
    mlp = MLPClassifier(
        hidden_layer_sizes=(150, 100, 50),
        activation='relu',
        solver='adam',
        alpha=0.001,
        batch_size=32,
        learning_rate_init=0.01,
        max_iter=1000,
        early_stopping=True,
        validation_fraction=0.0,  # We'll use external validation
        n_iter_no_change=15,
        tol=1e-6,
        random_state=42
    )
    
    # Manual early stopping with external validation
    best_score = 0
    patience_counter = 0
    patience = 15
    
    train_scores = []
    val_scores = []
    
    # Initial fit with small iterations
    mlp.max_iter = 50
    mlp.warm_start = True
    
    for iteration in range(1, 21):  # Up to 1000 iterations (50 * 20)
        mlp.fit(X_train, y_train)
        
        train_score = mlp.score(X_train, y_train)
        val_score = mlp.score(X_val, y_val)
        
        train_scores.append(train_score)
        val_scores.append(val_score)
        
        if val_score > best_score:
            best_score = val_score
            patience_counter = 0
        else:
            patience_counter += 1
        
        print(f"Iteration {iteration*50:4d}: Train={train_score:.4f}, Val={val_score:.4f}, "
              f"Patience={patience_counter}")
        
        if patience_counter >= patience:
            print(f"Early stopping at iteration {iteration*50}")
            break
        
        mlp.max_iter += 50
    
    return train_scores, val_scores, mlp

# Split training data for validation
from sklearn.model_selection import train_test_split
X_tr, X_val, y_tr, y_val = train_test_split(
    X_train_scaled, y_train, test_size=0.2, random_state=42, stratify=y_train
)

train_scores, val_scores, final_mlp = train_with_early_stopping_analysis(X_tr, y_tr, X_val, y_val)

# Plot training progress
plt.figure(figsize=(12, 5))
iterations = np.arange(1, len(train_scores) + 1) * 50

plt.subplot(1, 2, 1)
plt.plot(iterations, train_scores, 'b-', label='Training Score', linewidth=2)
plt.plot(iterations, val_scores, 'r-', label='Validation Score', linewidth=2)
plt.xlabel('Iterations')
plt.ylabel('Accuracy')
plt.title('Training Progress with Early Stopping')
plt.legend()
plt.grid(True, alpha=0.3)

plt.subplot(1, 2, 2)
if hasattr(final_mlp, 'loss_curve_'):
    plt.plot(final_mlp.loss_curve_, 'g-', linewidth=2)
    plt.xlabel('Iterations')
    plt.ylabel('Loss')
    plt.title('Training Loss Curve')
    plt.grid(True, alpha=0.3)

plt.tight_layout()
plt.show()
```

**Example** of batch size regularization effect:

```python
# Analyze batch size impact on regularization
batch_sizes = [8, 16, 32, 64, 128, 'auto']
batch_results = {}

for batch_size in batch_sizes:
    mlp = MLPClassifier(
        hidden_layer_sizes=(100, 50),
        activation='relu',
        solver='adam',
        alpha=0.001,
        batch_size=batch_size,
        max_iter=200,
        early_stopping=True,
        validation_fraction=0.15,
        random_state=42
    )
    
    mlp.fit(X_train_scaled, y_train)
    train_score = mlp.score(X_train_scaled, y_train)
    test_score = mlp.score(X_test_scaled, y_test)
    
    batch_results[batch_size] = {
        'train_score': train_score,
        'test_score': test_score,
        'overfitting': train_score - test_score
    }
    
    print(f"Batch size {str(batch_size):4} - Train: {train_score:.4f}, "
          f"Test: {test_score:.4f}, Gap: {train_score-test_score:.4f}")
```

