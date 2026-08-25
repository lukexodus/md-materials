## LeaveOneOut Validation


LeaveOneOut (LOO) cross-validation uses each single sample as a test set while training on all remaining samples. This represents the extreme case where k equals the number of samples, providing maximum training data but potentially high variance.

**Key points:**

- Maximum utilization of training data
- Computationally expensive for large datasets
- High variance, low bias estimator
- Deterministic (no randomness involved)
- Best suited for small datasets

**Example:**

```python
from sklearn.model_selection import LeaveOneOut
from sklearn.neighbors import KNeighborsClassifier
from sklearn.datasets import load_iris

# Load small dataset
iris = load_iris()
X, y = iris.data, iris.target

# Initialize LeaveOneOut
loo = LeaveOneOut()

model = KNeighborsClassifier(n_neighbors=3)

# Perform LOO cross-validation
scores = cross_val_score(model, X, y, cv=loo)

print(f"LOO CV Scores: {len(scores)} scores")
print(f"Mean accuracy: {scores.mean():.3f}")
print(f"Standard deviation: {scores.std():.3f}")
print(f"Number of correct predictions: {scores.sum()}")
```

LeaveOneOut is particularly useful for small datasets where you cannot afford to hold out substantial portions for testing, though the high variance makes it less reliable for model selection.

