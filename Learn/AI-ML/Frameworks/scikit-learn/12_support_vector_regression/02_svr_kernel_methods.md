## SVR Kernel Methods


Kernel functions enable SVR to capture non-linear relationships by implicitly mapping input features into higher-dimensional spaces where linear separation becomes possible. The kernel trick avoids explicit computation of high-dimensional feature mappings, making non-linear SVR computationally tractable.

### Linear Kernel

The linear kernel represents the simplest case where no transformation is applied to the input space. It's defined as the dot product between two vectors: K(x_i, x_j) = x_i^T x_j. Linear kernels are appropriate when the relationship between features and target is approximately linear, offering computational efficiency and interpretability.

**Advantages**: Computationally efficient, interpretable coefficients, less prone to overfitting with high-dimensional data, suitable for sparse datasets.

**Disadvantages**: Limited expressiveness for non-linear relationships, may underfit complex patterns, requires feature engineering for non-linear relationships.

### Radial Basis Function (RBF) Kernel

The RBF kernel, also known as Gaussian kernel, is defined as K(x_i, x_j) = exp(-γ||x_i - x_j||²). This kernel creates infinite-dimensional feature spaces and can approximate any continuous function, making it highly flexible for complex non-linear patterns.

**Gamma Parameter**: Controls the influence radius of individual training examples. High gamma values create tight, localized decision boundaries, while low gamma values produce smoother, more generalized boundaries. The gamma parameter directly affects model complexity and generalization capability.

**Universal Approximation**: RBF kernels can theoretically approximate any continuous function given sufficient data, making them suitable for complex regression tasks where the underlying relationship is unknown.

### Polynomial Kernel

The polynomial kernel is defined as K(x_i, x_j) = (γx_i^T x_j + r)^d, where d is the degree, γ is the scaling factor, and r is the independent term. This kernel captures polynomial relationships between features and can model interactions up to degree d.

**Degree Selection**: The polynomial degree determines the complexity of feature interactions. Higher degrees can capture more complex relationships but increase computational cost and overfitting risk.

**Computational Considerations**: Polynomial kernels can become computationally expensive for high degrees and may suffer from numerical instability with extreme parameter values.

### Sigmoid Kernel

The sigmoid kernel, defined as K(x_i, x_j) = tanh(γx_i^T x_j + r), resembles neural network activation functions. While theoretically interesting, sigmoid kernels can be challenging to optimize and may not satisfy Mercer's conditions under all parameter settings.

**Parameter Sensitivity**: Sigmoid kernels are highly sensitive to parameter choices and may produce inconsistent results. They're less commonly used in practice compared to RBF and polynomial kernels.

### Custom Kernels

Scikit-learn supports custom kernel functions for domain-specific applications. Custom kernels must satisfy Mercer's conditions (positive semi-definite) to ensure convergence and optimal solutions.

**Key points**:

- Kernel choice significantly impacts model performance and computational complexity
- RBF kernels provide good default choice for most non-linear regression problems
- Linear kernels excel in high-dimensional spaces and when interpretability is important
- Polynomial kernels capture specific interaction patterns but require careful degree selection
- Custom kernels enable domain-specific feature representations

**Example**:

```python
from sklearn.svm import SVR
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, GridSearchCV
from sklearn.metrics import mean_squared_error, r2_score
import numpy as np
import matplotlib.pyplot as plt

# Generate synthetic non-linear data
np.random.seed(42)
X = np.linspace(-3, 3, 300).reshape(-1, 1)
y = 0.5 * X.ravel()**3 - 2 * X.ravel()**2 + X.ravel() + np.random.normal(0, 0.5, X.shape[0])

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Feature scaling for consistent kernel performance
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Compare different kernel types
kernels = {
    'Linear': SVR(kernel='linear', C=1.0, epsilon=0.1),
    'RBF': SVR(kernel='rbf', C=1.0, gamma='scale', epsilon=0.1),
    'Polynomial (degree=2)': SVR(kernel='poly', degree=2, C=1.0, epsilon=0.1),
    'Polynomial (degree=3)': SVR(kernel='poly', degree=3, C=1.0, epsilon=0.1),
    'Sigmoid': SVR(kernel='sigmoid', C=1.0, epsilon=0.1)
}

results = {}
for kernel_name, model in kernels.items():
    model.fit(X_train_scaled, y_train)
    y_pred = model.predict(X_test_scaled)
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    results[kernel_name] = {'MSE': mse, 'R²': r2, 'Support Vectors': model.n_support_[0]}

# Display results
for kernel, metrics in results.items():
    print(f"{kernel}: MSE={metrics['MSE']:.4f}, R²={metrics['R²']:.4f}, SVs={metrics['Support Vectors']}")

# Custom kernel example
def custom_polynomial_kernel(X, Y):
    """Custom polynomial kernel with specific transformations"""
    gamma = 1.0 / X.shape[1]
    return (gamma * np.dot(X, Y.T) + 1) ** 2

# Using precomputed kernel with custom function
from sklearn.metrics.pairwise import pairwise_kernels
K_train = pairwise_kernels(X_train_scaled, metric=custom_polynomial_kernel)
K_test = pairwise_kernels(X_test_scaled, X_train_scaled, metric=custom_polynomial_kernel)

custom_svr = SVR(kernel='precomputed')
custom_svr.fit(K_train, y_train)
y_pred_custom = custom_svr.predict(K_test)

print(f"Custom Kernel: MSE={mean_squared_error(y_test, y_pred_custom):.4f}, "
      f"R²={r2_score(y_test, y_pred_custom):.4f}")
```

