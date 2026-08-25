## Training, Validation, and Test Sets


**Training set** contains data used to fit model parameters. The algorithm learns patterns and relationships from this subset. In scikit-learn, training data is passed to the `fit()` method of estimators.

**Validation set** evaluates model performance during development and hyperparameter tuning. This subset helps select optimal model configurations without touching test data. Scikit-learn provides `sklearn.model_selection.train_test_split` and cross-validation tools for creating validation splits.

**Test set** provides final, unbiased performance evaluation on completely unseen data. This subset should only be used once after model selection is complete. The test set simulates real-world deployment conditions.

**Key Points:**

- Common split ratios: 60% training, 20% validation, 20% test
- `sklearn.model_selection.train_test_split` handles random splitting
- `sklearn.model_selection.cross_val_score` performs k-fold cross-validation
- Stratified splitting maintains class distribution: `stratify` parameter

**Example:**

```python
from sklearn.model_selection import train_test_split
from sklearn.datasets import load_digits

X, y = load_digits(return_X_y=True)

# Split into train/temp, then temp into validation/test
X_train, X_temp, y_train, y_temp = train_test_split(
    X, y, test_size=0.4, random_state=42, stratify=y
)
X_val, X_test, y_val, y_test = train_test_split(
    X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
)
```

