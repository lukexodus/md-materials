## ndarray Object Introduction


The ndarray (N-dimensional array) is NumPy's core data structure, providing a powerful container for homogeneous data.

**Core Characteristics:**

- Homogeneous elements of the same data type
- Fixed size at creation (reshaping creates new arrays)
- Elements accessible via integer indexing
- Support for broadcasting and vectorized operations

**Object Structure:**

```python
import numpy as np
arr = np.array([1, 2, 3, 4, 5])
type(arr)  # <class 'numpy.ndarray'>
```

**Memory Model:** ndarray consists of:

- Data buffer containing raw elements
- Metadata describing data interpretation (dtype, shape, strides)
- View mechanism allowing multiple array objects to share data

