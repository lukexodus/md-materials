## GradientBoostingClassifier Optimization


GradientBoostingClassifier implements gradient boosting, a sequential ensemble method that builds trees iteratively, with each new tree correcting errors made by the previous ensemble. This approach often achieves superior predictive performance but requires careful tuning to prevent overfitting.

**Key points:**

- Sequential ensemble building (boosting vs bagging)
- Each tree corrects residual errors of the ensemble
- Supports various loss functions for different objectives
- Highly customizable with learning rate and regularization
- More prone to overfitting than Random Forest methods

```python
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.model_selection import validation_curve

# Gradient Boosting implementation
gb_classifier = GradientBoostingClassifier(
    n_estimators=100,          # number of boosting stages
    learning_rate=0.1,         # shrinks contribution of each tree
    max_depth=3,               # depth of individual trees
    min_samples_split=20,      # minimum samples to split
    min_samples_leaf=10,       # minimum samples in leaf
    subsample=0.8,            # fraction of samples for each tree
    max_features='sqrt',       # feature sampling
    random_state=42
)

gb_classifier.fit(X_train, y_train)
gb_pred = gb_classifier.predict(X_test)

# Access training deviance
training_deviance = gb_classifier.train_score_
```

The learning rate controls the contribution of each tree, with smaller values requiring more estimators but often leading to better generalization. The subsample parameter introduces stochastic gradient boosting, using only a fraction of training samples for each tree.

**Example** of learning curve analysis:

```python
# Validation curve for n_estimators
param_range = np.arange(50, 251, 50)
train_scores, val_scores = validation_curve(
    GradientBoostingClassifier(learning_rate=0.1, random_state=42),
    X_train, y_train,
    param_name='n_estimators',
    param_range=param_range,
    cv=5,
    scoring='accuracy'
)

# Plot learning curves
plt.figure(figsize=(10, 6))
train_mean = np.mean(train_scores, axis=1)
train_std = np.std(train_scores, axis=1)
val_mean = np.mean(val_scores, axis=1)
val_std = np.std(val_scores, axis=1)

plt.plot(param_range, train_mean, 'o-', color='blue', label='Training score')
plt.fill_between(param_range, train_mean - train_std, train_mean + train_std, alpha=0.1, color='blue')
plt.plot(param_range, val_mean, 'o-', color='red', label='Validation score')
plt.fill_between(param_range, val_mean - val_std, val_mean + val_std, alpha=0.1, color='red')
plt.xlabel('Number of Estimators')
plt.ylabel('Accuracy Score')
plt.legend()
plt.title('Gradient Boosting: Validation Curve')
plt.show()
```

Advanced gradient boosting configuration includes early stopping to prevent overfitting:

```python
# Early stopping implementation
gb_early_stop = GradientBoostingClassifier(
    n_estimators=1000,         # large number for early stopping
    learning_rate=0.05,        # smaller learning rate
    max_depth=4,
    subsample=0.8,
    validation_fraction=0.2,   # fraction for early stopping
    n_iter_no_change=10,       # patience parameter
    random_state=42
)

gb_early_stop.fit(X_train, y_train)
print(f"Optimal number of estimators: {gb_early_stop.n_estimators_}")
```

