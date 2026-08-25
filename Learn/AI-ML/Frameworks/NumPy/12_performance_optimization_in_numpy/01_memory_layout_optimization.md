## Memory Layout Optimization


**Key Points**
NumPy arrays store data in contiguous memory blocks with specific ordering patterns. Understanding and optimizing memory layout directly impacts cache performance, vectorization efficiency, and overall computational speed. The choice between row-major (C-style) and column-major (Fortran-style) ordering significantly affects performance for different operation types.

**Array Order and Contiguity**
```python
import numpy as np
import time

# Create arrays with different memory layouts
size = 1000
a_c = np.random.rand(size, size)  # C-contiguous (row-major)
a_f = np.asfortranarray(a_c)      # Fortran-contiguous (column-major)

print("C-contiguous flags:", a_c.flags)
print("F-contiguous flags:", a_f.flags)
print("Memory layout - C:", a_c.flags['C_CONTIGUOUS'])
print("Memory layout - F:", a_f.flags['F_CONTIGUOUS'])

# Demonstrate performance difference for row vs column operations
def time_operation(arr, operation_type):
    if operation_type == 'row':
        start = time.time()
        result = np.sum(arr, axis=1)  # Sum along rows
        return time.time() - start
    else:
        start = time.time()
        result = np.sum(arr, axis=0)  # Sum along columns
        return time.time() - start

# Row operations
c_row_time = time_operation(a_c, 'row')
f_row_time = time_operation(a_f, 'row')

# Column operations
c_col_time = time_operation(a_c, 'col')
f_col_time = time_operation(a_f, 'col')

print(f"Row operations - C: {c_row_time:.6f}s, F: {f_row_time:.6f}s")
print(f"Column operations - C: {c_col_time:.6f}s, F: {f_col_time:.6f}s")
```

**Stride Patterns and Access Efficiency**
```python
# Understanding array strides
arr_2d = np.random.rand(1000, 1000)
print("Array shape:", arr_2d.shape)
print("Array strides:", arr_2d.strides)
print("Element size:", arr_2d.itemsize)

# Create arrays with different stride patterns
arr_strided = arr_2d[::2, ::2]  # Every second element
print("Strided array strides:", arr_strided.strides)
print("Is contiguous:", arr_strided.flags['C_CONTIGUOUS'])

# Performance comparison: contiguous vs strided access
def benchmark_access_pattern(arr, name):
    start = time.time()
    result = np.sum(arr ** 2)
    elapsed = time.time() - start
    print(f"{name} access time: {elapsed:.6f}s")
    return elapsed

# Compare contiguous and strided access
contiguous_time = benchmark_access_pattern(arr_2d, "Contiguous")
strided_time = benchmark_access_pattern(arr_strided, "Strided")
print(f"Strided access is {strided_time/contiguous_time:.2f}x slower")
```

**Memory Layout Conversion Strategies**
```python
# Converting between memory layouts
def convert_and_benchmark():
    # Original array
    original = np.random.rand(500, 500, 100)
    print("Original layout - C:", original.flags['C_CONTIGUOUS'])
    
    # Convert to Fortran order
    fortran_copy = np.asfortranarray(original)
    print("Fortran copy - F:", fortran_copy.flags['F_CONTIGUOUS'])
    
    # In-place transpose (changes stride pattern)
    transposed = original.transpose(2, 1, 0)
    print("Transposed contiguity:", transposed.flags['C_CONTIGUOUS'])
    
    # Force contiguous copy
    contiguous_copy = np.ascontiguousarray(transposed)
    print("Forced contiguous - C:", contiguous_copy.flags['C_CONTIGUOUS'])
    
    return original, fortran_copy, transposed, contiguous_copy

arrays = convert_and_benchmark()
```

**Optimal Array Creation Patterns**
```python
# Pre-allocate with correct memory layout
def create_optimized_arrays(shape, dtype=np.float64):
    # Method 1: Direct creation with order specification
    arr_c = np.zeros(shape, dtype=dtype, order='C')
    arr_f = np.zeros(shape, dtype=dtype, order='F')
    
    # Method 2: Empty array initialization (faster for temporary arrays)
    arr_empty = np.empty(shape, dtype=dtype, order='C')
    
    # Method 3: Using specific constructors
    arr_ones = np.ones(shape, dtype=dtype, order='C')
    arr_full = np.full(shape, 3.14, dtype=dtype, order='C')
    
    return arr_c, arr_f, arr_empty, arr_ones, arr_full

# Benchmark array creation methods
def benchmark_creation(shape):
    methods = {
        'zeros': lambda: np.zeros(shape),
        'empty': lambda: np.empty(shape),
        'ones': lambda: np.ones(shape),
        'full': lambda: np.full(shape, 1.0)
    }
    
    for name, method in methods.items():
        start = time.time()
        for _ in range(100):
            arr = method()
        elapsed = time.time() - start
        print(f"{name:8s}: {elapsed:.6f}s for 100 creations")

benchmark_creation((1000, 1000))
```

