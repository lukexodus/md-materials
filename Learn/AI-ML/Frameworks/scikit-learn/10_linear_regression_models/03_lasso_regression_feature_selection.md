## Lasso Regression Feature Selection


Lasso regression uses L1 regularization to perform automatic feature selection by driving irrelevant coefficients to exactly zero.

**Key points:**

- Minimizes: Σ(yi - ŷi)² + α Σ|βj| (L1 penalty)
- Produces sparse solutions by setting some coefficients to zero
- Automatic feature selection capability
- No analytical solution; requires iterative optimization
- Tends to select one feature from groups of correlated features

```python
from sklearn.linear_model import Lasso, LassoCV
import pandas as pd

# Create data with irrelevant features
np.random.seed(42)
X_sparse = np.random.randn(100, 10)
# Only first 3 features are relevant
y_sparse = X_sparse[:, 0] + 2*X_sparse[:, 1] - X_sparse[:, 2] + np.random.randn(100) * 0.1

X_train, X_test, y_train, y_test = train_test_split(X_sparse, y_sparse, test_size=0.3, random_state=42)

# Lasso with different alpha values
alphas = [0.01, 0.1, 1.0, 10.0]
feature_names = [f'Feature_{i}' for i in range(10)]

for alpha in alphas:
    lasso = Pipeline([
        ('scaler', StandardScaler()),
        ('lasso', Lasso(alpha=alpha, max_iter=2000))
    ])
    lasso.fit(X_train, y_train)
    
    coefficients = lasso.named_steps['lasso'].coef_
    selected_features = np.where(coefficients != 0)[0]
    
    print(f"\nAlpha {alpha}:")
    print(f"Test R²: {lasso.score(X_test, y_test):.3f}")
    print(f"Selected features: {len(selected_features)}")
    print(f"Non-zero coefficients: {coefficients[coefficients != 0]}")

# Automatic alpha selection with LassoCV
lasso_cv = Pipeline([
    ('scaler', StandardScaler()),
    ('lasso', LassoCV(cv=5, max_iter=2000, random_state=42))
])
lasso_cv.fit(X_train, y_train)

print(f"\nOptimal alpha: {lasso_cv.named_steps['lasso'].alpha_:.3f}")
print(f"Selected features: {np.sum(lasso_cv.named_steps['lasso'].coef_ != 0)}")

# Feature importance visualization
coefficients_df = pd.DataFrame({
    'Feature': feature_names,
    'Coefficient': lasso_cv.named_steps['lasso'].coef_
})
print("\nFeature coefficients:")
print(coefficients_df[coefficients_df['Coefficient'] != 0].sort_values('Coefficient', key=abs, ascending=False))
```

**Applications:**

- High-dimensional datasets with many irrelevant features
- Gene expression analysis and biomarker discovery
- Text mining and natural language processing
- When model interpretability is crucial
- Exploratory data analysis for feature discovery

