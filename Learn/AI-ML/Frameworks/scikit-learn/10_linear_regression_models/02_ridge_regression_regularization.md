## Ridge Regression Regularization


Ridge regression adds L2 regularization to prevent overfitting by penalizing large coefficients. The alpha parameter controls the strength of regularization.

**Key points:**

- Minimizes: Σ(yi - ŷi)² + α Σβj² (L2 penalty)
- Shrinks coefficients toward zero but doesn't eliminate them
- Handles multicollinearity by distributing coefficient values
- Analytical solution: β = (X^T X + αI)^(-1) X^T y
- Cross-validation typically used to select optimal alpha

```python
from sklearn.linear_model import Ridge, RidgeCV
from sklearn.preprocessing import StandardScaler
from sklearn.pipeline import Pipeline

# Create data with multicollinearity
np.random.seed(42)
X_multi = np.random.randn(100, 5)
X_multi[:, 1] = X_multi[:, 0] + 0.1 * np.random.randn(100)  # Correlated features
y_multi = X_multi[:, 0] + X_multi[:, 2] + np.random.randn(100) * 0.1

X_train, X_test, y_train, y_test = train_test_split(X_multi, y_multi, test_size=0.3, random_state=42)

# Ridge with different alpha values
alphas = [0.1, 1.0, 10.0, 100.0]
ridge_scores = {}

for alpha in alphas:
    ridge = Pipeline([
        ('scaler', StandardScaler()),
        ('ridge', Ridge(alpha=alpha))
    ])
    ridge.fit(X_train, y_train)
    train_score = ridge.score(X_train, y_train)
    test_score = ridge.score(X_test, y_test)
    ridge_scores[alpha] = {'train': train_score, 'test': test_score}
    
    print(f"Alpha {alpha}: Train R² = {train_score:.3f}, Test R² = {test_score:.3f}")

# Automatic alpha selection with RidgeCV
ridge_cv = Pipeline([
    ('scaler', StandardScaler()),
    ('ridge', RidgeCV(alphas=np.logspace(-3, 3, 50), cv=5))
])
ridge_cv.fit(X_train, y_train)

print(f"\nOptimal alpha: {ridge_cv.named_steps['ridge'].alpha_:.3f}")
print(f"CV R²: {ridge_cv.score(X_test, y_test):.3f}")
```

**Applications:**

- High-dimensional data with more features than samples
- Multicollinear datasets where features are correlated
- Preventing overfitting in complex models
- When you want to retain all features but reduce their impact
- Genomics, text analysis, and image processing

