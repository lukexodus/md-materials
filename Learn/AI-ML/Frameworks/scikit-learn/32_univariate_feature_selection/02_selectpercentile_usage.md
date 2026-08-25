## SelectPercentile Usage


SelectPercentile selects features based on a percentile of the highest scores, offering more flexibility than SelectKBest when the optimal number of features is unknown.

**Key points:**

- Selects features based on a percentage rather than absolute number
- Automatically adapts to datasets with different numbers of features
- Useful when you want to keep a proportion of features rather than a fixed count
- Default percentile is 10% of features

```python
from sklearn.feature_selection import SelectPercentile
from sklearn.datasets import make_classification

# Generate synthetic dataset
X, y = make_classification(n_samples=1000, n_features=100, n_informative=20, 
                          n_redundant=10, random_state=42)

# Select top 25% of features
selector = SelectPercentile(score_func=f_classif, percentile=25)
X_selected = selector.fit_transform(X, y)

print(f"Original features: {X.shape[1]}")
print(f"Selected features: {X_selected.shape[1]}")
print(f"Selected feature indices: {selector.get_support(indices=True)}")
```

**Configuration options:**

- `percentile`: Percentage of features to select (default: 10)
- `score_func`: Scoring function to use for feature evaluation
- All methods from SelectKBest are available

