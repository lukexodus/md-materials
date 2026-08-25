## Model Comparison and Selection


**Example** comprehensive comparison framework:

```python
from sklearn.model_selection import cross_val_score
from sklearn.metrics import make_scorer, mean_absolute_error
import time

# Create comprehensive dataset
np.random.seed(42)
X_comp = np.random.randn(500, 10)
X_comp[:, 1] = X_comp[:, 0] + 0.1 * np.random.randn(500)  # Multicollinearity
y_comp = (2*X_comp[:, 0] - X_comp[:, 2] + 0.5*X_comp[:, 5]**2 + 
          np.random.randn(500) * 0.2)

X_train, X_test, y_train, y_test = train_test_split(X_comp, y_comp, test_size=0.3, random_state=42)

# Define models
models = {
    'Linear Regression': Pipeline([
        ('scaler', StandardScaler()),
        ('model', LinearRegression())
    ]),
    'Ridge': Pipeline([
        ('scaler', StandardScaler()),
        ('model', RidgeCV(alphas=np.logspace(-3, 3, 50)))
    ]),
    'Lasso': Pipeline([
        ('scaler', StandardScaler()),
        ('model', LassoCV(max_iter=2000))
    ]),
    'ElasticNet': Pipeline([
        ('scaler', StandardScaler()),
        ('model', ElasticNetCV(l1_ratio=[0.1, 0.5, 0.9], max_iter=2000))
    ]),
    'Polynomial Ridge (degree=2)': Pipeline([
        ('poly', PolynomialFeatures(degree=2)),
        ('scaler', StandardScaler()),
        ('model', RidgeCV(alphas=np.logspace(-3, 3, 50)))
    ])
}

# Evaluate models
results_comparison = {}
for name, model in models.items():
    start_time = time.time()
    
    # Cross-validation
    cv_scores = cross_val_score(model, X_train, y_train, cv=5, scoring='r2')
    
    # Fit and test
    model.fit(X_train, y_train)
    test_score = model.score(X_test, y_test)
    
    # Additional metrics
    y_pred = model.predict(X_test)
    test_mae = mean_absolute_error(y_test, y_pred)
    
    fit_time = time.time() - start_time
    
    results_comparison[name] = {
        'cv_mean': cv_scores.mean(),
        'cv_std': cv_scores.std(),
        'test_r2': test_score,
        'test_mae': test_mae,
        'fit_time': fit_time
    }
    
    print(f"{name}:")
    print(f"  CV R²: {cv_scores.mean():.3f} ± {cv_scores.std():.3f}")
    print(f"  Test R²: {test_score:.3f}")
    print(f"  Test MAE: {test_mae:.3f}")
    print(f"  Fit time: {fit_time:.3f}s")
    
    # Model-specific information
    if hasattr(model.named_steps['model'], 'coef_'):
        n_features = np.sum(model.named_steps['model'].coef_ != 0)
        print(f"  Active features: {n_features}")
    
    print()
```

