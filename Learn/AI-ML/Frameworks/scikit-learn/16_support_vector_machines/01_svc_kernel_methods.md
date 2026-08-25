## SVC Kernel Methods


The Support Vector Classifier (SVC) uses the kernel trick to transform data into higher-dimensional spaces where linear separation becomes possible. Scikit-learn's `SVC` class supports multiple kernel functions that define how similarity between data points is calculated.

**Key Points:**

- Linear kernel: `K(x, y) = x^T y` - fastest computation, works well for high-dimensional data
- Polynomial kernel: `K(x, y) = (γx^T y + r)^d` - captures polynomial relationships with degree parameter
- RBF (Radial Basis Function): `K(x, y) = exp(-γ||x-y||²)` - most popular, handles non-linear patterns effectively
- Sigmoid kernel: `K(x, y) = tanh(γx^T y + r)` - neural network-inspired, less commonly used
- Custom kernels: User-defined functions or precomputed kernel matrices

The gamma parameter controls kernel coefficient influence - higher values create more complex decision boundaries but risk overfitting. The `kernel` parameter accepts string identifiers or callable functions for custom implementations.

**Example:**

```python
from sklearn.svm import SVC
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split

X, y = make_classification(n_samples=1000, n_features=20, n_classes=2, random_state=42)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# RBF kernel with automatic gamma scaling
svc_rbf = SVC(kernel='rbf', gamma='scale', C=1.0)
svc_rbf.fit(X_train, y_train)

# Polynomial kernel with degree 3
svc_poly = SVC(kernel='poly', degree=3, gamma='scale', coef0=1)
svc_poly.fit(X_train, y_train)

# Custom kernel function
def custom_kernel(X, Y):
    return np.dot(X, Y.T) ** 2

svc_custom = SVC(kernel=custom_kernel)
```

Kernel selection depends on data characteristics - linear kernels for high-dimensional sparse data, RBF for general non-linear patterns, and polynomial for specific degree relationships. Cross-validation helps determine optimal kernel parameters.

