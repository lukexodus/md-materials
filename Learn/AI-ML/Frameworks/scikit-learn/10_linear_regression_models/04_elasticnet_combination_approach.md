## ElasticNet Combination Approach


ElasticNet combines L1 and L2 regularization to leverage benefits of both Ridge and Lasso regression, using the l1_ratio parameter to balance between them.

**Key points:**

- Minimizes: Σ(yi - ŷi)² + α(ρ Σ|βj| + (1-ρ)/2 Σβj²) where ρ is l1_ratio
- l1_ratio=0: Pure Ridge, l1_ratio=1: Pure Lasso
- Handles groups of correlated features better than Lasso
- Provides sparse solutions with grouped feature selection
- Two hyperparameters to tune: alpha and l1_ratio

```python
from sklearn.linear_model import ElasticNet, ElasticNetCV
from sklearn.model_selection import GridSearchCV

# Create data with grouped correlated features
np.random.seed(42)
X_groups = np.random.randn(200, 15)

# Create feature groups
for i in range(3):  # 3 groups of 5 features each
    base_feature = X_groups[:, i*5]
    for j in range(1, 5):
        X_groups[:, i*5 + j] = base_feature + 0.1 * np.random.randn(200)

# Target depends on group means
y_groups = (X_groups[:, :5].mean(axis=1) + 
           2 * X_groups[:, 5:10].mean(axis=1) - 
           X_groups[:, 10:15].mean(axis=1) + 
           np.random.randn(200) * 0.1)

X_train, X_test, y_train, y_test = train_test_split(X_groups, y_groups, test_size=0.3, random_state=42)

# Compare different l1_ratio values
l1_ratios = [0.1, 0.5, 0.7, 0.9]
results = {}

for l1_ratio in l1_ratios:
    elastic_cv = Pipeline([
        ('scaler', StandardScaler()),
        ('elastic', ElasticNetCV(l1_ratio=l1_ratio, cv=5, max_iter=2000, random_state=42))
    ])
    elastic_cv.fit(X_train, y_train)
    
    test_score = elastic_cv.score(X_test, y_test)
    n_features = np.sum(elastic_cv.named_steps['elastic'].coef_ != 0)
    results[l1_ratio] = {'score': test_score, 'n_features': n_features}
    
    print(f"l1_ratio {l1_ratio}: Test R² = {test_score:.3f}, Features = {n_features}")

# Grid search for optimal parameters
param_grid = {
    'elastic__alpha': np.logspace(-3, 1, 20),
    'elastic__l1_ratio': [0.1, 0.3, 0.5, 0.7, 0.9]
}

elastic_grid = Pipeline([
    ('scaler', StandardScaler()),
    ('elastic', ElasticNet(max_iter=2000, random_state=42))
])

grid_search = GridSearchCV(elastic_grid, param_grid, cv=5, scoring='r2', n_jobs=-1)
grid_search.fit(X_train, y_train)

print(f"\nBest parameters: {grid_search.best_params_}")
print(f"Best CV score: {grid_search.best_score_:.3f}")
print(f"Test score: {grid_search.score(X_test, y_test):.3f}")
```

**Applications:**

- Datasets with groups of correlated features
- When both feature selection and regularization are needed
- Genetic data with linkage disequilibrium
- Market research with related survey questions
- Multi-modal data with feature redundancy

