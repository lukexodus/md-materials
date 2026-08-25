## ANOVA F-test Methods


ANOVA F-test evaluates whether the means of different groups (classes) are significantly different, making it effective for both classification and regression tasks.

**Key points:**

- `f_classif`: For classification tasks, compares feature means across different classes
- `f_regression`: For regression tasks, measures linear dependency between features and target
- Based on F-statistic which follows F-distribution under null hypothesis
- Assumes normal distribution and homoscedasticity
- More robust to feature scaling than chi-square test

```python
from sklearn.feature_selection import f_classif, f_regression
from sklearn.datasets import load_wine, load_boston
import pandas as pd

# Classification example with f_classif
X_wine, y_wine = load_wine(return_X_y=True)
f_scores_classif, p_values_classif = f_classif(X_wine, y_wine)

# Select top features for classification
selector_classif = SelectKBest(score_func=f_classif, k=8)
X_wine_selected = selector_classif.fit_transform(X_wine, y_wine)

print("Classification F-test results:")
wine_features = load_wine().feature_names
for i, (score, p_val) in enumerate(zip(f_scores_classif, p_values_classif)):
    print(f"{wine_features[i]}: F-score={score:.4f}, p-value={p_val:.6f}")

# Regression example with f_regression
try:
    X_boston, y_boston = load_boston(return_X_y=True)
    f_scores_reg, p_values_reg = f_regression(X_boston, y_boston)
    
    selector_reg = SelectKBest(score_func=f_regression, k=6)
    X_boston_selected = selector_reg.fit_transform(X_boston, y_boston)
    
    print(f"\nRegression selected {X_boston_selected.shape[1]} features from {X_boston.shape[1]}")
except ImportError:
    # Alternative regression dataset
    from sklearn.datasets import make_regression
    X_reg, y_reg = make_regression(n_samples=500, n_features=20, n_informative=5, random_state=42)
    f_scores_reg, p_values_reg = f_regression(X_reg, y_reg)
    print("Using synthetic regression dataset for f_regression example")
```

**Statistical interpretation:**

- F-statistic = (Between-group variance) / (Within-group variance)
- Higher F-scores indicate greater discrimination between groups
- P-values indicate statistical significance of the relationship

