## AdaBoostClassifier Boosting


AdaBoost (Adaptive Boosting) sequentially trains weak classifiers, focusing on previously misclassified examples by adjusting sample weights.

**Key points:**

- Sequential training where each classifier learns from previous mistakes
- Exponentially reweights misclassified examples
- Combines weak learners into a strong classifier
- Particularly effective with decision stumps (shallow decision trees)

```python
from sklearn.ensemble import AdaBoostClassifier
from sklearn.tree import DecisionTreeClassifier

# Basic AdaBoost with default decision stumps
ada_basic = AdaBoostClassifier(
    n_estimators=100,
    learning_rate=1.0,
    random_state=42
)

# AdaBoost with custom weak learner
ada_custom = AdaBoostClassifier(
    base_estimator=DecisionTreeClassifier(max_depth=3),
    n_estimators=200,
    learning_rate=0.5,
    algorithm='SAMME.R',  # Real AdaBoost (uses probabilities)
    random_state=42
)

ada_custom.fit(X_train, y_train)

# Analyze boosting progression
train_errors = []
test_errors = []

for i, pred in enumerate(ada_custom.staged_predict(X_train)):
    train_errors.append(1 - np.mean(pred == y_train))
    
for i, pred in enumerate(ada_custom.staged_predict(X_test)):
    test_errors.append(1 - np.mean(pred == y_test))

# Plot learning curves
plt.figure(figsize=(10, 6))
plt.plot(range(1, len(train_errors) + 1), train_errors, label='Training Error')
plt.plot(range(1, len(test_errors) + 1), test_errors, label='Test Error')
plt.xlabel('Boosting Iterations')
plt.ylabel('Classification Error')
plt.legend()
plt.title('AdaBoost Learning Progression')
```

**Advanced AdaBoost analysis:**

```python
# Examine estimator weights and errors
estimator_weights = ada_custom.estimator_weights_
estimator_errors = ada_custom.estimator_errors_

# Feature importance from AdaBoost
feature_importance = ada_custom.feature_importances_

# Sample weights evolution (for binary classification)
def track_sample_weights(X, y, n_estimators=10):
    ada_tracker = AdaBoostClassifier(n_estimators=1, random_state=42)
    sample_weights_history = []
    
    current_weights = np.ones(len(X)) / len(X)
    
    for i in range(n_estimators):
        ada_tracker.fit(X, y, sample_weight=current_weights)
        
        # Predict and calculate error
        predictions = ada_tracker.predict(X)
        errors = (predictions != y).astype(int)
        
        # Calculate weighted error
        weighted_error = np.sum(current_weights * errors) / np.sum(current_weights)
        
        # Calculate classifier weight
        alpha = 0.5 * np.log((1 - weighted_error) / max(weighted_error, 1e-10))
        
        # Update sample weights
        current_weights *= np.exp(alpha * errors)
        current_weights /= np.sum(current_weights)
        
        sample_weights_history.append(current_weights.copy())
    
    return sample_weights_history
```

**Multi-class AdaBoost strategies:**

```python
# SAMME vs SAMME.R algorithms
ada_samme = AdaBoostClassifier(algorithm='SAMME', n_estimators=100)
ada_samme_r = AdaBoostClassifier(algorithm='SAMME.R', n_estimators=100)

# For multi-class problems, SAMME.R often converges faster
# SAMME uses class predictions, SAMME.R uses class probabilities
```

