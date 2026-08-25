## Isotonic Regression


Isotonic regression fits monotonic functions to data, ensuring predictions follow monotonically increasing or decreasing relationships.

### Mathematical Constraint

The algorithm enforces monotonicity constraints: if x₁ ≤ x₂, then f(x₁) ≤ f(x₂) for increasing functions. This constraint is useful when domain knowledge indicates monotonic relationships between features and targets.

### Implementation Details

The `IsotonicRegression` class uses the Pool Adjacent Violators Algorithm (PAVA) for optimization. The `increasing` parameter controls monotonicity direction (True for increasing, False for decreasing, 'auto' for automatic detection).

**Example:**

```python
from sklearn.isotonic import IsotonicRegression
import numpy as np

# Generate monotonic data with noise
X = np.linspace(0, 10, 100)
y = X**2 + np.random.normal(0, 10, 100)  # Quadratic with noise

iso_reg = IsotonicRegression(increasing=True, out_of_bounds='clip')
iso_reg.fit(X, y)
y_pred = iso_reg.predict(X)
```

### Boundary Handling

The `out_of_bounds` parameter controls extrapolation behavior: 'nan' returns NaN, 'clip' uses boundary values, and 'raise' throws exceptions. The `y_min` and `y_max` parameters set explicit bounds for predictions.

### Applications

Isotonic regression excels in calibration tasks, dose-response modeling, and scenarios requiring monotonic constraints. It's particularly useful for probability calibration and ranking applications.

