## Memory Views and Copies


NumPy's memory model distinguishes between views (shared data) and copies (independent data), fundamentally affecting performance and memory usage patterns.

**Memory Views** Views share underlying data with the original array while potentially having different shapes, strides, or data types. Slicing operations, reshaping, and transpose typically create views. Modifying view data affects the original array and all other views sharing the same memory buffer.

**Array Copies** Copies create independent arrays with separate memory allocation. Operations like `copy()`, `astype()` with different types, and certain fancy indexing operations produce copies. Copies consume additional memory but provide data isolation.

**View Detection** The `base` attribute identifies the original array for views (non-None) or indicates independent arrays (None). The `flags` attribute provides detailed memory layout information including writeable status, C/Fortran contiguity, and ownership.

**Memory Layout and Strides** Strides define how many bytes to skip in memory when moving along each array dimension. C-order (row-major) and Fortran-order (column-major) represent different memory layouts affecting cache performance and operation efficiency.

**Key Points**

- Views enable memory-efficient array manipulation
- Understanding view vs copy behavior prevents unexpected data modifications
- Memory layout affects performance in element-wise and linear algebra operations
- Stride information enables advanced memory access patterns

**Examples**

```python
# View creation and shared memory
original = np.array([[1, 2, 3], [4, 5, 6]])
view = original[0, :]  # Creates view
view[0] = 99  # Modifies original array

# Copy creation
copy = original.copy()
copy[0, 0] = 42  # Does not affect original

# Memory layout inspection
original.strides  # (12, 4) for int32 array
original.flags.c_contiguous  # True for C-order
```

