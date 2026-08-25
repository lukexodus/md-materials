## SelectKBest Implementation


SelectKBest selects the k highest-scoring features based on univariate statistical tests. It's one of the most commonly used feature selection methods due to its simplicity and effectiveness.

**Key points:**

- Selects a fixed number of features (k) with the highest scores
- Works with any scoring function that takes two arrays X and y and returns scores and p-values
- Maintains feature order from the original dataset
- Supports both classification and regression tasks

```python
from sklearn.feature_selection import SelectKBest, chi2, f_classif
from sklearn.datasets import load_breast_cancer
from sklearn.model_selection import train_test_split
import numpy as np

# Load dataset
X, y = load_breast_cancer(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Select top 10 features using chi-square test
selector = SelectKBest(score_func=chi2, k=10)
X_train_selected = selector.fit_transform(X_train, y_train)
X_test_selected = selector.transform(X_test)

# Get selected feature indices and scores
selected_features = selector.get_support(indices=True)
feature_scores = selector.scores_
```

**Key methods and attributes:**

- `fit_transform(X, y)`: Fits the selector and transforms the data
- `get_support(indices=True)`: Returns indices of selected features
- `scores_`: Array of scores for each feature
- `pvalues_`: Array of p-values for each feature (if available)

