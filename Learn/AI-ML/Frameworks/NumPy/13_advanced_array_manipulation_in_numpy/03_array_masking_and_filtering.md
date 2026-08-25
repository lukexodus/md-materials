## Array Masking and Filtering


Array masking represents a fundamental paradigm in NumPy that enables selective data access, modification, and analysis through boolean arrays that act as filters, providing both performance benefits and code clarity for complex data operations.

Boolean masking creates logical arrays that correspond element-wise to data arrays, where True values indicate selection and False values indicate exclusion. These masks can be generated through comparison operations, logical functions, or custom boolean expressions, providing flexible filtering mechanisms.

Masked arrays (numpy.ma module) extend basic masking to handle missing or invalid data explicitly. These specialized arrays maintain separate mask arrays alongside data arrays, enabling statistical operations that automatically exclude masked elements without requiring data copying or modification.

Advanced masking techniques include mask propagation across operations, mask combination using logical operators, and mask inversion for complementary selections. These operations maintain vectorization while providing sophisticated data filtering capabilities.

Compressed arrays and mask-based indexing enable memory-efficient storage and processing of sparse or filtered data. The compressed representation eliminates masked elements entirely, reducing memory footprint and computational overhead for subsequent operations.

**Example:**

```python
# Advanced boolean masking
data = np.array([1, -2, 3, np.nan, 5, -6, 7, np.inf])
valid_mask = ~(np.isnan(data) | np.isinf(data))
positive_mask = data > 0

# Combined mask operations
combined_mask = valid_mask & positive_mask
filtered_data = data[combined_mask]

# Masked array operations
import numpy.ma as ma
masked_data = ma.masked_invalid(data)
result = ma.mean(masked_data)  # Automatically excludes invalid values

# Mask inversion and propagation
inverted_mask = ~combined_mask
complement_data = data[inverted_mask]
```

