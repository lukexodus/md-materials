## Overfitting and Underfitting Concepts


**Overfitting** occurs when a model learns training data too specifically, including noise and irrelevant patterns. The model performs well on training data but poorly on new, unseen data. High variance characterizes overfitting - small changes in training data cause large changes in the learned model.

**Underfitting** happens when a model is too simple to capture underlying data patterns. The model performs poorly on both training and test data because it lacks sufficient complexity to represent the true relationship. High bias characterizes underfitting - the model makes strong assumptions that prevent it from learning the target function.

**Key Points:**

- Overfitting indicators: High training accuracy, low validation accuracy
- Underfitting indicators: Low training and validation accuracy
- Regularization techniques: `sklearn.linear_model.Ridge`, `sklearn.linear_model.Lasso`
- Model complexity control: `max_depth` in trees, `C` parameter in SVM
- Early stopping in iterative algorithms: `n_estimators` in ensemble methods

**Example:**

```python
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import validation_curve
import numpy as np

# Study overfitting with max_depth parameter
param_range = np.arange(1, 21)
train_scores, val_scores = validation_curve(
    RandomForestClassifier(random_state=42), X, y,
    param_name='max_depth', param_range=param_range,
    cv=5, scoring='accuracy'
)

# Low max_depth: underfitting (low train and val scores)
# High max_depth: overfitting (high train, low val scores)
```

