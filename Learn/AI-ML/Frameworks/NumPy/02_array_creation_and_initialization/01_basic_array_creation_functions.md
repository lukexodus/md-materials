## Basic Array Creation Functions


**zeros, ones, empty**

The fundamental creation functions generate arrays filled with specific values. `numpy.zeros()` creates arrays filled with zeros, accepting shape as a tuple and optional dtype parameter. The function allocates memory and initializes all elements to zero, making it ideal for creating placeholder arrays or accumulator arrays in iterative processes.

```python
import numpy as np

# Create 1D array of zeros
arr_1d = np.zeros(5)  # [0. 0. 0. 0. 0.]

# Create 2D array with specific shape
arr_2d = np.zeros((3, 4))  # 3x4 array of zeros

# Specify data type
arr_int = np.zeros(5, dtype=int)  # [0 0 0 0 0]
```

`numpy.ones()` operates identically to zeros but fills arrays with ones. This function proves useful for creating weight matrices, normalization arrays, or initialization patterns requiring unity values.

```python
# Create array of ones
ones_arr = np.ones((2, 3))  # 2x3 array of ones

# Different data types
ones_complex = np.ones(3, dtype=complex)  # [1.+0.j 1.+0.j 1.+0.j]
```

`numpy.empty()` allocates memory without initializing values, containing arbitrary data from memory. This function provides the fastest array creation method when immediate initialization with specific values will follow.

```python
# Create empty array (contains random values)
empty_arr = np.empty((2, 2))  # Contains whatever was in memory
```

**full and full_like**

`numpy.full()` creates arrays filled with specified values, offering more flexibility than zeros or ones. This function accepts the desired fill value as a parameter.

```python
# Create array filled with specific value
filled_arr = np.full((3, 3), 7)  # 3x3 array filled with 7
filled_float = np.full(5, 3.14)  # [3.14 3.14 3.14 3.14 3.14]
```

