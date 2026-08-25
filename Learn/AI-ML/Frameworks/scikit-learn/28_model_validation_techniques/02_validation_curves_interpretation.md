## Validation Curves Interpretation


Validation curves plot model performance against a single hyperparameter value, showing how changes in that parameter affect both training and validation performance. This technique is essential for hyperparameter tuning and understanding model complexity.

Validation curves reveal the optimal complexity for a model by showing the sweet spot where validation performance peaks. They clearly illustrate underfitting at low complexity values and overfitting at high complexity values.

**Key points:**

- Maps hyperparameter values to model performance
- Identifies optimal complexity levels
- Shows overfitting and underfitting regions
- Guides hyperparameter selection decisions

**Example:**

```python
from sklearn.model_selection import validation_curve
from sklearn.ensemble import RandomForestClassifier
from sklearn.svm import SVC
import matplotlib.pyplot as plt
import numpy as np

def plot_validation_curve(estimator, X, y, param_name, param_range, title, log_scale=False):
    train_scores, val_scores = validation_curve(
        estimator, X, y, param_name=param_name, param_range=param_range,
        cv=5, scoring='accuracy', n_jobs=-1
    )
    
    train_mean = np.mean(train_scores, axis=1)
    train_std = np.std(train_scores, axis=1)
    val_mean = np.mean(val_scores, axis=1)
    val_std = np.std(val_scores, axis=1)
    
    plt.figure(figsize=(10, 6))
    
    if log_scale:
        plt.semilogx(param_range, train_mean, 'o-', color='blue', label='Training score')
        plt.semilogx(param_range, val_mean, 'o-', color='red', label='Cross-validation score')
    else:
        plt.plot(param_range, train_mean, 'o-', color='blue', label='Training score')
        plt.plot(param_range, val_mean, 'o-', color='red', label='Cross-validation score')
    
    plt.fill_between(param_range, train_mean - train_std, train_mean + train_std, alpha=0.1, color='blue')
    plt.fill_between(param_range, val_mean - val_std, val_mean + val_std, alpha=0.1, color='red')
    
    plt.xlabel(param_name)
    plt.ylabel('Accuracy Score')
    plt.title(f'Validation Curve - {title}')
    plt.legend(loc='best')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()
    
    # Find optimal parameter value
    optimal_idx = np.argmax(val_mean)
    optimal_param = param_range[optimal_idx]
    optimal_score = val_mean[optimal_idx]
    
    print(f"Optimal {param_name}: {optimal_param}")
    print(f"Optimal CV score: {optimal_score:.3f} (+/- {val_std[optimal_idx]:.3f})")

# Random Forest max_depth validation curve
rf_depths = range(1, 21)
plot_validation_curve(
    RandomForestClassifier(n_estimators=100, random_state=42),
    X_scaled, y, 'max_depth', rf_depths, 'Random Forest Max Depth'
)

# SVM C parameter validation curve
svm_C_range = np.logspace(-3, 2, 10)
plot_validation_curve(
    SVC(kernel='rbf', random_state=42),
    X_scaled, y, 'C', svm_C_range, 'SVM C Parameter', log_scale=True
)
```

Validation curves can be extended to show multiple metrics simultaneously or compare different algorithms with the same hyperparameter. They're particularly useful for understanding how regularization parameters affect model performance.

