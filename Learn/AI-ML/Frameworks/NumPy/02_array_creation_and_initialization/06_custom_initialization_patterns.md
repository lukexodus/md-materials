## Custom Initialization Patterns


**Meshgrid for Coordinate Arrays**

`numpy.meshgrid()` creates coordinate matrices from coordinate vectors, essential for function evaluation over grids.

```python
# Create coordinate grids
x = np.linspace(-2, 2, 5)
y = np.linspace(-1, 1, 3)
X, Y = np.meshgrid(x, y)

# Evaluate function over grid
Z = X**2 + Y**2  # Evaluate z = x² + y²
```

**Structured Initialization**

```python
# Checkerboard pattern
def checkerboard(shape):
    return np.indices(shape).sum(axis=0) % 2

checker = checkerboard((8, 8))

# Custom pattern functions
def spiral_pattern(n):
    # [Inference] This creates a spiral pattern but specific implementation varies
    arr = np.zeros((n, n))
    # Implementation would require specific algorithm
    return arr
```

**Broadcasting-based Initialization**

```python
# Using broadcasting for patterns
rows, cols = 5, 5
row_indices = np.arange(rows).reshape(-1, 1)
col_indices = np.arange(cols)

# Distance from center
center_r, center_c = rows // 2, cols // 2
distances = np.sqrt((row_indices - center_r)**2 + (col_indices - center_c)**2)

# Gradient patterns
gradient_x = np.linspace(0, 1, cols)
gradient_2d = np.broadcast_to(gradient_x, (rows, cols))
```

