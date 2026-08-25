## SGDClassifier Optimization


Stochastic Gradient Descent (SGD) classifier is particularly effective for large-scale learning problems, updating model parameters incrementally with each training sample.

**Key points:**

- Extremely efficient for large datasets that don't fit in memory
- Supports various loss functions (hinge, log, modified_huber, squared_hinge)
- Built-in learning rate scheduling and regularization options
- Can implement SVM, logistic regression, and other linear models depending on loss function

```python
from sklearn.linear_model import SGDClassifier
from sklearn.preprocessing import StandardScaler

# SGD requires feature scaling for optimal performance
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Different loss functions for different algorithms
sgd_svm = SGDClassifier(loss='hinge', alpha=0.01, learning_rate='optimal')
sgd_logistic = SGDClassifier(loss='log_loss', alpha=0.01, learning_rate='adaptive')
sgd_modified_huber = SGDClassifier(loss='modified_huber', alpha=0.01)

# Fit with early stopping
sgd_svm.fit(X_train_scaled, y_train)
```

**Advanced features:**

- **Partial fitting**: `partial_fit()` for online learning scenarios
- **Learning rate schedules**: 'constant', 'optimal', 'invscaling', 'adaptive'
- **Early stopping**: Prevents overfitting with validation-based stopping
- **Class balancing**: `class_weight` parameter for imbalanced datasets

```python
# Online learning example
for epoch in range(10):
    for batch_start in range(0, len(X_train_scaled), 100):
        batch_end = min(batch_start + 100, len(X_train_scaled))
        X_batch = X_train_scaled[batch_start:batch_end]
        y_batch = y_train[batch_start:batch_end]
        sgd_svm.partial_fit(X_batch, y_batch)
```

