## Bias-Variance Tradeoff


**Bias** represents systematic error from overly simplistic assumptions in the learning algorithm. High-bias models consistently miss relevant relations between features and target outputs, leading to underfitting. Bias measures how far predicted values are from true values on average.

**Variance** represents sensitivity to small fluctuations in training data. High-variance models change significantly with different training sets, leading to overfitting. Variance measures how much predictions vary for different training sets.

The **bias-variance tradeoff** describes the fundamental tension in machine learning: reducing bias typically increases variance and vice versa. The total error consists of bias², variance, and irreducible noise. Optimal models balance these components to minimize total error.

**Key Points:**

- Low bias, low variance: ideal but often unattainable
- High bias, low variance: underfitting (simple models)
- Low bias, high variance: overfitting (complex models)
- High bias, high variance: worst case scenario
- Ensemble methods can reduce both: `sklearn.ensemble.BaggingClassifier` reduces variance, `sklearn.ensemble.AdaBoostClassifier` reduces bias

**Example:**

```python
from sklearn.ensemble import BaggingClassifier
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import cross_val_score

# High variance: single decision tree
single_tree = DecisionTreeClassifier(random_state=42)
single_scores = cross_val_score(single_tree, X, y, cv=10)

# Reduced variance: bagged trees
bagged_trees = BaggingClassifier(
    DecisionTreeClassifier(), n_estimators=100, random_state=42
)
bagged_scores = cross_val_score(bagged_trees, X, y, cv=10)

print(f"Single tree variance: {np.var(single_scores):.4f}")
print(f"Bagged trees variance: {np.var(bagged_scores):.4f}")
```

**Conclusion:** These fundamental concepts form the theoretical foundation for effective machine learning with scikit-learn. Understanding the supervised/unsupervised distinction guides algorithm selection, while classification versus regression determines appropriate metrics and evaluation strategies. Proper data splitting ensures reliable performance estimates, and recognizing overfitting/underfitting patterns enables better model tuning. The bias-variance tradeoff provides a framework for understanding model behavior and guides decisions about model complexity and ensemble methods.

---

