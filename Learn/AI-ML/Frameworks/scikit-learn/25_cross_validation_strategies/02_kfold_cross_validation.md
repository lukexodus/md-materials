## KFold Cross-Validation


KFold is the most fundamental cross-validation strategy, dividing the dataset into k equally-sized folds. The model trains on k-1 folds and tests on the remaining fold, repeating this process k times so each fold serves as the test set exactly once.

**Key points:**

- Default k=5 in scikit-learn, though k=10 is common in practice
- Provides good bias-variance tradeoff for most datasets
- Each sample appears in exactly one test set
- Suitable for regression and balanced classification problems

**Example:**

```python
from sklearn.model_selection import KFold, cross_val_score
from sklearn.ensemble import RandomForestClassifier
from sklearn.datasets import make_classification

# Generate sample data
X, y = make_classification(n_samples=1000, n_features=20, random_state=42)

# Initialize KFold
kf = KFold(n_splits=5, shuffle=True, random_state=42)

# Initialize model
model = RandomForestClassifier(random_state=42)

# Perform cross-validation
cv_scores = cross_val_score(model, X, y, cv=kf, scoring='accuracy')
print(f"CV Scores: {cv_scores}")
print(f"Mean CV Score: {cv_scores.mean():.3f} (+/- {cv_scores.std() * 2:.3f})")
```

The shuffle parameter randomizes the data before splitting, which is crucial when the dataset has inherent ordering. The random_state ensures reproducibility across runs.

