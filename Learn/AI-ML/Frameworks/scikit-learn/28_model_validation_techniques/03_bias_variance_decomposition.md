## Bias-Variance Decomposition


Bias-variance decomposition breaks down prediction error into three components: bias (error from oversimplifying assumptions), variance (error from sensitivity to small fluctuations), and irreducible error (noise inherent in the problem). This analysis provides deep insights into model behavior and guides improvement strategies.

Understanding bias-variance decomposition helps choose between different modeling approaches. High-bias models consistently make the same wrong assumptions, while high-variance models are inconsistent across different training sets.

**Key points:**

- Decomposes total error into interpretable components
- Guides model selection and complexity decisions
- Reveals fundamental limitations and improvement opportunities
- Connects theoretical understanding to practical performance

**Example:**

```python
import numpy as np
from sklearn.ensemble import RandomForestClassifier, BaggingClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import train_test_split
from sklearn.datasets import make_classification
import matplotlib.pyplot as plt

def bias_variance_decomposition(estimator, X, y, n_trials=100, test_size=0.3, random_state=42):
    """
    Perform bias-variance decomposition for a given estimator.
    """
    np.random.seed(random_state)
    n_samples, n_features = X.shape
    
    # Storage for predictions
    predictions = []
    
    for trial in range(n_trials):
        # Bootstrap sample
        bootstrap_idx = np.random.choice(n_samples, size=n_samples, replace=True)
        X_bootstrap = X[bootstrap_idx]
        y_bootstrap = y[bootstrap_idx]
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X_bootstrap, y_bootstrap, test_size=test_size, random_state=trial
        )
        
        # Fit model and predict
        estimator.fit(X_train, y_train)
        y_pred = estimator.predict(X_test)
        predictions.append(y_pred)
    
    # Convert to numpy array for easier manipulation
    predictions = np.array(predictions)
    
    # Calculate main prediction (ensemble average)
    main_predictions = np.mean(predictions, axis=0)
    
    # Calculate bias-variance components
    # For simplicity, we'll use the last test set from the loop
    bias_squared = np.mean((main_predictions - y_test) ** 2)
    variance = np.mean(np.var(predictions, axis=0))
    
    return bias_squared, variance, predictions

# Generate complex dataset
X, y = make_classification(
    n_samples=1000, n_features=20, n_informative=15, 
    n_redundant=5, n_clusters_per_class=1, random_state=42
)

# Compare different models
models = {
    'High Bias (Shallow Tree)': DecisionTreeClassifier(max_depth=2, random_state=42),
    'High Variance (Deep Tree)': DecisionTreeClassifier(max_depth=None, min_samples_split=2, random_state=42),
    'Balanced (Random Forest)': RandomForestClassifier(n_estimators=100, random_state=42),
    'Low Variance (Bagged Trees)': BaggingClassifier(DecisionTreeClassifier(), n_estimators=100, random_state=42)
}

results = {}
for name, model in models.items():
    bias_sq, variance, _ = bias_variance_decomposition(model, X, y)
    results[name] = {'bias_squared': bias_sq, 'variance': variance}
    print(f"{name}:")
    print(f"  Bias²: {bias_sq:.4f}")
    print(f"  Variance: {variance:.4f}")
    print(f"  Bias² + Variance: {bias_sq + variance:.4f}")
    print()

# Visualize bias-variance tradeoff
model_names = list(results.keys())
bias_values = [results[name]['bias_squared'] for name in model_names]
variance_values = [results[name]['variance'] for name in model_names]

plt.figure(figsize=(10, 6))
x_pos = np.arange(len(model_names))

plt.bar(x_pos, bias_values, alpha=0.7, label='Bias²', color='red')
plt.bar(x_pos, variance_values, bottom=bias_values, alpha=0.7, label='Variance', color='blue')

plt.xlabel('Model')
plt.ylabel('Error Component')
plt.title('Bias-Variance Decomposition Comparison')
plt.xticks(x_pos, model_names, rotation=45, ha='right')
plt.legend()
plt.tight_layout()
plt.show()
```

Bias-variance decomposition can be extended to regression problems with different error metrics and can include analysis of how ensemble methods specifically target variance reduction.

