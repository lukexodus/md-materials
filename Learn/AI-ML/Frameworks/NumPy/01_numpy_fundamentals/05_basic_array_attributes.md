## Basic Array Attributes


NumPy arrays contain essential metadata accessible through attributes:

**Shape and Dimensions:**

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])
arr.shape     # (2, 3) - dimensions of array
arr.ndim      # 2 - number of dimensions
arr.size      # 6 - total number of elements
```

**Data Type Information:**

```python
arr.dtype     # Data type of elements
arr.itemsize  # Size in bytes of each element
arr.nbytes    # Total bytes consumed by elements
```

**Memory and Structure:**

```python
arr.data      # Buffer containing actual array data
arr.strides   # Tuple of bytes to step in each dimension
arr.flags     # Information about memory layout
```

**Common Data Types:**

- `int8, int16, int32, int64` - Signed integers
- `uint8, uint16, uint32, uint64` - Unsigned integers
- `float16, float32, float64` - Floating point numbers
- `complex64, complex128` - Complex numbers
- `bool` - Boolean values

