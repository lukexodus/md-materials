## Reshaping Arrays


Array reshaping changes the dimensional structure while preserving the total number of elements and data order.

**reshape() Method:** The primary method for changing array dimensions:

```python
import numpy as np

# Basic reshaping
arr = np.arange(12)  # [0, 1, 2, ..., 11]
reshaped = arr.reshape(3, 4)  # 3x4 matrix
reshaped_3d = arr.reshape(2, 2, 3)  # 2x2x3 array

# Using -1 for automatic dimension calculation
auto_reshape = arr.reshape(4, -1)  # 4x3 (NumPy calculates second dimension)
auto_reshape_2 = arr.reshape(-1, 2)  # 6x2 (NumPy calculates first dimension)
```

**Reshape Constraints:**

- Total elements must remain constant
- New shape must be compatible with original size
- reshape() returns a view when possible, copy when necessary

**resize() Method:** Unlike reshape(), resize() can change the total number of elements:

```python
arr = np.arange(6)
arr.resize(2, 4)  # Pads with zeros: [[0,1,2,3], [4,5,0,0]]

# resize() modifies array in-place
# np.resize() creates new array with different behavior
new_arr = np.resize(arr, (3, 3))  # Repeats elements to fill shape
```

**Memory Considerations:** reshape() creates views when memory layout allows, while resize() always creates copies or modifies in-place.

