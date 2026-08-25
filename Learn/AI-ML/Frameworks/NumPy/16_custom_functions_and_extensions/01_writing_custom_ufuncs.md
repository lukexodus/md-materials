## Writing Custom Ufuncs


Universal functions (ufuncs) are the building blocks of NumPy's vectorized operations, supporting element-wise operations with automatic broadcasting, type promotion, and output array management. Custom ufuncs extend NumPy's functionality while maintaining these performance and usability benefits.

**Key points:**

- Custom ufuncs support automatic broadcasting across input arrays
- Type promotion and casting rules are handled automatically
- Memory layout optimization and cache efficiency are preserved
- Integration with NumPy's error handling and floating-point control systems
- Support for multiple input and output arrays with flexible signatures

**Example:**

```python
import numpy as np

# Method 1: Using np.frompyfunc for simple Python functions
def custom_sigmoid(x):
    return 1 / (1 + np.exp(-np.clip(x, -500, 500)))  # Clipping prevents overflow

# Create ufunc from Python function
sigmoid_ufunc = np.frompyfunc(custom_sigmoid, 1, 1)

# Apply to arrays with automatic broadcasting
x = np.linspace(-10, 10, 1000)
result = sigmoid_ufunc(x).astype(float)  # Convert from object array

# Method 2: Using numpy.vectorize for more control
@np.vectorize
def custom_relu(x, alpha=0.01):
    return np.maximum(alpha * x, x)  # Leaky ReLU implementation

# Usage with broadcasting
data = np.random.randn(100, 50)
activated = custom_relu(data, alpha=0.02)

# Method 3: Creating ufuncs with multiple outputs
def polar_to_cartesian(r, theta):
    x = r * np.cos(theta)
    y = r * np.sin(theta)
    return x, y

polar_ufunc = np.frompyfunc(polar_to_cartesian, 2, 2)

# Usage with complex broadcasting scenarios
r_values = np.linspace(1, 10, 100).reshape(-1, 1)
theta_values = np.linspace(0, 2*np.pi, 50).reshape(1, -1)
x_coords, y_coords = polar_ufunc(r_values, theta_values)

# Advanced ufunc with accumulation and reduction
def weighted_mean_func(values, weights):
    return np.sum(values * weights) / np.sum(weights)

# Custom reduction operation
def sliding_weighted_mean(data, weights, window_size):
    results = np.zeros(len(data) - window_size + 1)
    for i in range(len(results)):
        window_data = data[i:i+window_size]
        results[i] = weighted_mean_func(window_data, weights)
    return results
```

Custom ufuncs inherit NumPy's memory management and can be combined with other ufuncs in complex expressions. The automatic type promotion ensures consistent behavior across different input types, while the broadcasting system handles dimensional compatibility automatically.

