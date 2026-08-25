## Data Types and Memory Management


NumPy supports various data types optimized for different use cases:

```python
# Integer types
int8_arr = np.array([1, 2, 3], dtype=np.int8)
uint64_arr = np.array([1, 2, 3], dtype=np.uint64)

# Floating-point types
float16_arr = np.array([1.1, 2.2], dtype=np.float16)  # Half precision
float128_arr = np.array([1.1, 2.2], dtype=np.float128)  # Extended precision

# Complex types
complex_arr = np.array([1+2j, 3+4j], dtype=np.complex128)

# Boolean and string types
bool_arr = np.array([True, False, True], dtype=np.bool_)
string_arr = np.array(['hello', 'world'], dtype='U10')
```

**Memory Layout and Performance Considerations**

```python
# C-order (row-major) vs Fortran-order (column-major)
c_order = np.array([[1, 2, 3], [4, 5, 6]], order='C')
f_order = np.array([[1, 2, 3], [4, 5, 6]], order='F')

# Memory usage analysis
arr = np.random.random((1000, 1000))
print(f"Size: {arr.size}, Bytes: {arr.nbytes}, Itemsize: {arr.itemsize}")
print(f"Strides: {arr.strides}, Shape: {arr.shape}")
```

