## Polynomial Regression Extensions


Polynomial regression extends linear models to capture non-linear relationships by creating polynomial features from existing features.

**Key points:**

- Transforms features: [x1, x2] → [1, x1, x2, x1², x1x2, x2²] for degree 2
- Still linear in coefficients despite non-linear feature relationships
- Higher degrees can capture complex patterns but risk overfitting
- Combines with regularization to control model complexity
- Feature scaling becomes critical with polynomial terms

```python
from sklearn.preprocessing import PolynomialFeatures
from sklearn.linear_model import LinearRegression, Ridge
from sklearn.metrics import mean_squared_error

# Generate non-linear data
np.random.seed(42)
X_nonlinear = np.linspace(-2, 2, 100).reshape(-1, 1)
y_nonlinear = 0.5 * X_nonlinear.ravel()**3 - 2 * X_nonlinear.ravel()**2 + X_nonlinear.ravel() + np.random.randn(100) * 0.5

X_train, X_test, y_train, y_test = train_test_split(X_nonlinear, y_nonlinear, test_size=0.3, random_state=42)

# Compare different polynomial degrees
degrees = [1, 2, 3, 5, 8]
poly_results = {}

for degree in degrees:
    # Linear regression with polynomial features
    poly_pipe = Pipeline([
        ('poly', PolynomialFeatures(degree=degree)),
        ('scaler', StandardScaler()),
        ('regression', LinearRegression())
    ])
    
    poly_pipe.fit(X_train, y_train)
    
    train_pred = poly_pipe.predict(X_train)
    test_pred = poly_pipe.predict(X_test)
    
    train_mse = mean_squared_error(y_train, train_pred)
    test_mse = mean_squared_error(y_test, test_pred)
    
    poly_results[degree] = {
        'train_mse': train_mse,
        'test_mse': test_mse,
        'n_features': poly_pipe.named_steps['poly'].n_output_features_
    }
    
    print(f"Degree {degree}: Train MSE = {train_mse:.3f}, Test MSE = {test_mse:.3f}, Features = {poly_results[degree]['n_features']}")

# Regularized polynomial regression
print("\nPolynomial Ridge Regression:")
for degree in [3, 5, 8]:
    poly_ridge = Pipeline([
        ('poly', PolynomialFeatures(degree=degree)),
        ('scaler', StandardScaler()),
        ('ridge', RidgeCV(alphas=np.logspace(-3, 3, 50)))
    ])
    
    poly_ridge.fit(X_train, y_train)
    test_score = poly_ridge.score(X_test, y_test)
    optimal_alpha = poly_ridge.named_steps['ridge'].alpha_
    
    print(f"Degree {degree}: Test R² = {test_score:.3f}, Alpha = {optimal_alpha:.3f}")

# Multiple features polynomial regression
X_multi_nonlinear = np.random.randn(200, 2)
y_multi_nonlinear = (X_multi_nonlinear[:, 0]**2 + 
                    X_multi_nonlinear[:, 1]**2 + 
                    X_multi_nonlinear[:, 0] * X_multi_nonlinear[:, 1] + 
                    np.random.randn(200) * 0.1)

X_train_multi, X_test_multi, y_train_multi, y_test_multi = train_test_split(
    X_multi_nonlinear, y_multi_nonlinear, test_size=0.3, random_state=42)

poly_multi = Pipeline([
    ('poly', PolynomialFeatures(degree=2, interaction_only=False)),
    ('scaler', StandardScaler()),
    ('ridge', RidgeCV(alphas=np.logspace(-3, 3, 50)))
])

poly_multi.fit(X_train_multi, y_train_multi)
print(f"\nMultiple features polynomial: Test R² = {poly_multi.score(X_test_multi, y_test_multi):.3f}")

# Feature names for interpretation
poly_features = PolynomialFeatures(degree=2)
poly_features.fit(X_train_multi)
feature_names = poly_features.get_feature_names_out(['x1', 'x2'])
print(f"Generated features: {list(feature_names)}")
```

**Applications:**

- Non-linear relationships with known polynomial structure
- Engineering applications with physics-based polynomial models
- Time series with polynomial trends
- Curve fitting and interpolation problems
- Computer graphics and animation curves

