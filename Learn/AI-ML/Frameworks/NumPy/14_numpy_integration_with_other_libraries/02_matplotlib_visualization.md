## Matplotlib Visualization


Matplotlib natively accepts NumPy arrays as input for all plotting functions, making visualization of numerical data straightforward. The library's architecture is designed around NumPy's array structure and broadcasting rules.

**Key points:**

- All plotting functions accept NumPy arrays directly without conversion
- NumPy's broadcasting rules apply to matplotlib operations
- Masked arrays from NumPy are handled automatically in plots
- Color mapping and data transformation leverage NumPy's vectorized operations

**Example:**

```python
import numpy as np
import matplotlib.pyplot as plt

# Generate data using NumPy
x = np.linspace(0, 10, 1000)
y1 = np.sin(x)
y2 = np.cos(x)
noise = np.random.normal(0, 0.1, 1000)

# Direct plotting with NumPy arrays
fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(10, 8))

# Line plots
ax1.plot(x, y1, label='sin(x)')
ax1.plot(x, y2, label='cos(x)')
ax1.legend()

# Scatter plot with NumPy-generated colors
colors = np.random.rand(1000)
ax2.scatter(y1, y2, c=colors, alpha=0.6, cmap='viridis')

# Using NumPy for advanced plotting
# Contour plots with meshgrids
X, Y = np.meshgrid(np.linspace(-3, 3, 100), np.linspace(-3, 3, 100))
Z = np.exp(-(X**2 + Y**2))
plt.contour(X, Y, Z, levels=20)
```

The integration includes support for complex numbers, where matplotlib automatically handles the real and imaginary components, and efficient handling of large datasets through NumPy's memory layout optimization.

