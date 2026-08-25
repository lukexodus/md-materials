## Gaussian Process Regression


Gaussian Process Regression (GPR) provides probabilistic, non-parametric regression with uncertainty quantification through Bayesian inference principles.

### Mathematical Foundation

GPR assumes target values follow a multivariate Gaussian distribution defined by mean and covariance functions (kernels). The kernel function encodes assumptions about data smoothness and patterns. Predictions include both mean estimates and confidence intervals.

### Kernel Selection

Scikit-learn provides various kernels: RBF (radial basis function), Matérn, White (noise), Linear, and composite kernels. The `kernel` parameter accepts single kernels or combinations using operators (+, *, **).

Common kernels include:

- RBF: Smooth, infinitely differentiable functions
- Matérn: Controlled smoothness with ν parameter
- Linear: Linear relationships
- WhiteKernel: Noise modeling

**Example:**

```python
from sklearn.gaussian_process import GaussianProcessRegressor
from sklearn.gaussian_process.kernels import RBF, WhiteKernel, ConstantKernel

# Composite kernel
kernel = ConstantKernel(1.0) * RBF(length_scale=1.0) + WhiteKernel(noise_level=1.0)

gpr = GaussianProcessRegressor(
    kernel=kernel,
    alpha=1e-6,
    normalize_y=True,
    n_restarts_optimizer=10
)

gpr.fit(X_train, y_train)
mean_prediction, std_prediction = gpr.predict(X_test, return_std=True)
```

### Hyperparameter Optimization

GPR optimizes kernel hyperparameters through maximum likelihood estimation. The `n_restarts_optimizer` parameter controls optimization attempts from different starting points. The `alpha` parameter adds diagonal regularization for numerical stability.

### Computational Complexity

GPR has O(n³) training complexity and O(n²) prediction complexity due to matrix inversion operations. This limits scalability to datasets with thousands of samples. Sparse Gaussian processes and inducing points can address scalability issues.

