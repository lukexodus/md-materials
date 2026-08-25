## ExtraTreesClassifier Implementation


ExtraTreesClassifier (Extremely Randomized Trees) extends the Random Forest concept by introducing additional randomness in the splitting process. Instead of finding the best split, it randomly selects splits for each feature, leading to faster training and often better generalization.

**Key points:**

- Uses entire dataset for training each tree (no bootstrap sampling)
- Randomly selects split points for each feature
- Faster training compared to Random Forest
- Higher variance reduction through increased randomness
- Often performs better on noisy datasets

```python
from sklearn.ensemble import ExtraTreesClassifier

# Extra Trees implementation
et_classifier = ExtraTreesClassifier(
    n_estimators=100,
    max_depth=10,
    min_samples_split=2,
    min_samples_leaf=1,
    max_features='sqrt',       # feature sampling strategy
    bootstrap=False,           # use entire dataset
    n_jobs=-1,
    random_state=42
)

et_classifier.fit(X_train, y_train)
et_pred = et_classifier.predict(X_test)

# Compare feature importance with Random Forest
et_importance = et_classifier.feature_importances_
rf_importance = rf_classifier.feature_importances_
```

The key difference lies in the splitting strategy. While Random Forest finds optimal splits among randomly selected features, Extra Trees randomly selects both features and split points, leading to higher variance individual trees but potentially better ensemble performance through increased diversity.

**Example** of comparison analysis:

```python
from sklearn.metrics import accuracy_score, classification_report
import matplotlib.pyplot as plt

# Performance comparison
models = {
    'Decision Tree': dt_classifier,
    'Random Forest': rf_classifier,
    'Extra Trees': et_classifier
}

results = {}
for name, model in models.items():
    pred = model.predict(X_test)
    accuracy = accuracy_score(y_test, pred)
    results[name] = accuracy
    print(f"{name} Accuracy: {accuracy:.4f}")

# Feature importance visualization
feature_names = [f'Feature_{i}' for i in range(X.shape[1])]
plt.figure(figsize=(12, 4))
plt.bar(feature_names, rf_importance, alpha=0.7, label='Random Forest')
plt.bar(feature_names, et_importance, alpha=0.7, label='Extra Trees')
plt.legend()
plt.title('Feature Importance Comparison')
plt.xticks(rotation=45)
plt.show()
```

