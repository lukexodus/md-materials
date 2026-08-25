## Learning Curves Analysis


Learning curves plot model performance against training set size, revealing how additional training data affects both training and validation performance. They provide crucial insights into whether a model suffers from high bias, high variance, or is performing optimally.

Learning curves help diagnose several key issues: underfitting (high bias) appears as both training and validation scores plateauing at low values with a small gap between them; overfitting (high variance) shows a large gap between training and validation scores; optimal performance displays converging scores at high values as training size increases.

**Key points:**

- Reveals impact of training data size on model performance
- Diagnoses bias-variance tradeoffs effectively
- Guides decisions about data collection needs
- Shows convergence behavior and stability

**Example:**

```python
from sklearn.model_selection import learning_curve
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import load_digits
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
import numpy as np

# Load and prepare data
digits = load_digits()
X, y = digits.data, digits.target
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Generate learning curves
def plot_learning_curves(estimator, X, y, title):
    train_sizes, train_scores, val_scores = learning_curve(
        estimator, X, y, 
        train_sizes=np.linspace(0.1, 1.0, 10),
        cv=5, scoring='accuracy', 
        n_jobs=-1, random_state=42
    )
    
    # Calculate means and standard deviations
    train_mean = np.mean(train_scores, axis=1)
    train_std = np.std(train_scores, axis=1)
    val_mean = np.mean(val_scores, axis=1)
    val_std = np.std(val_scores, axis=1)
    
    # Plot learning curves
    plt.figure(figsize=(10, 6))
    plt.plot(train_sizes, train_mean, 'o-', color='blue', label='Training score')
    plt.fill_between(train_sizes, train_mean - train_std, train_mean + train_std, alpha=0.1, color='blue')
    
    plt.plot(train_sizes, val_mean, 'o-', color='red', label='Cross-validation score')
    plt.fill_between(train_sizes, val_mean - val_std, val_mean + val_std, alpha=0.1, color='red')
    
    plt.xlabel('Training Set Size')
    plt.ylabel('Accuracy Score')
    plt.title(f'Learning Curves - {title}')
    plt.legend(loc='best')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()
    
    return train_sizes, train_scores, val_scores

# Compare different models
models = [
    (RandomForestClassifier(n_estimators=10, random_state=42), "Underfitted RF"),
    (RandomForestClassifier(n_estimators=100, random_state=42), "Well-fitted RF"),
    (RandomForestClassifier(n_estimators=100, max_depth=20, min_samples_split=2, random_state=42), "Overfitted RF")
]

for model, title in models:
    plot_learning_curves(model, X_scaled, y, title)
```

Advanced learning curve analysis can include multiple metrics simultaneously, showing precision, recall, and F1-score curves together to understand different aspects of model performance. You can also generate learning curves for different hyperparameter settings to see how they affect the bias-variance tradeoff.

