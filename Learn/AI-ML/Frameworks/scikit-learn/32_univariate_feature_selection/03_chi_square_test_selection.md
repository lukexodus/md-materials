## Chi-square Test Selection


The chi-square test measures the independence between each feature and the target variable, making it particularly suitable for categorical features and classification tasks.

**Key points:**

- Requires non-negative feature values (often used after preprocessing)
- Measures dependence between categorical variables
- Higher chi-square scores indicate stronger association with target
- Only applicable to classification problems
- Assumes features and target are categorical or can be treated as such

```python
from sklearn.feature_selection import chi2
from sklearn.preprocessing import MinMaxScaler
from sklearn.datasets import load_digits

# Load digits dataset
X, y = load_digits(return_X_y=True)

# Chi-square requires non-negative values
scaler = MinMaxScaler()
X_scaled = scaler.fit_transform(X)

# Apply chi-square test
chi2_scores, p_values = chi2(X_scaled, y)

# Select features with SelectKBest using chi-square
selector = SelectKBest(score_func=chi2, k=20)
X_selected = selector.fit_transform(X_scaled, y)

# Analyze results
feature_rankings = np.argsort(chi2_scores)[::-1]
print(f"Top 10 features by chi-square score:")
for i in range(10):
    idx = feature_rankings[i]
    print(f"Feature {idx}: Score={chi2_scores[idx]:.4f}, p-value={p_values[idx]:.6f}")
```

**Mathematical foundation:**

- Chi-square statistic: χ² = Σ((Observed - Expected)² / Expected)
- Degrees of freedom: (rows - 1) × (columns - 1)
- Higher scores indicate stronger association between feature and target

