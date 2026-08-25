## LinearRegression Implementation


LinearRegression implements ordinary least squares (OLS) regression, finding coefficients that minimize the sum of squared residuals. It provides the baseline for all linear models without regularization.

**Key points:**

- Minimizes: Σ(yi - ŷi)² where ŷi = β0 + β1x1i + β2x2i + ... + βpxpi
- No regularization penalty
- Analytical solution using normal equation: β = (X^T X)^(-1) X^T y
- Assumes linear relationship, independence, homoscedasticity, and normality of residuals
- Sensitive to multicollinearity and outliers

```python
from sklearn.linear_model import LinearRegression
from sklearn.datasets import make_regression
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np
import matplotlib.pyplot as plt

# Generate sample data
X, y = make_regression(n_samples=100, n_features=1, noise=10, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)

# Initialize and fit model
lr = LinearRegression()
lr.fit(X_train, y_train)

# Make predictions
y_pred_train = lr.predict(X_train)
y_pred_test = lr.predict(X_test)

print(f"Coefficient: {lr.coef_[0]:.3f}")
print(f"Intercept: {lr.intercept_:.3f}")
print(f"Training R²: {r2_score(y_train, y_pred_train):.3f}")
print(f"Test R²: {r2_score(y_test, y_pred_test):.3f}")
print(f"Test MSE: {mean_squared_error(y_test, y_pred_test):.3f}")

# Model equation
print(f"Model: y = {lr.coef_[0]:.3f}x + {lr.intercept_:.3f}")
```

**Applications:**

- Simple prediction problems with clear linear relationships
- Baseline model for comparison with more complex approaches
- Interpretable models where coefficient meanings are important
- Small datasets without multicollinearity issues
- Understanding fundamental relationships between variables

