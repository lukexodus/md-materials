## Common NumPy Errors and Solutions


**Shape Mismatch Errors** Broadcasting incompatibility represents the most frequent NumPy error. Shape mismatches occur when arrays cannot be broadcast together for operations. The error message `ValueError: operands could not be broadcast together` indicates dimensional incompatibility. Solutions include reshaping arrays using `reshape()`, adding dimensions with `np.newaxis`, or using explicit broadcasting with `np.broadcast_arrays()`.

**Example:**

```python
import numpy as np

# Common shape mismatch error
a = np.array([[1, 2, 3], [4, 5, 6]])  # Shape: (2, 3)
b = np.array([1, 2])  # Shape: (2,)

try:
    result = a + b  # This will fail
except ValueError as e:
    print(f"Error: {e}")

# Solutions:
# Solution 1: Reshape b to be compatible
b_reshaped = b.reshape(2, 1)  # Shape: (2, 1)
result1 = a + b_reshaped

# Solution 2: Use np.newaxis
result2 = a + b[:, np.newaxis]

# Solution 3: Explicit broadcasting
a_broadcast, b_broadcast = np.broadcast_arrays(a, b.reshape(2, 1))
result3 = a_broadcast + b_broadcast

print(f"Original shapes: a={a.shape}, b={b.shape}")
print(f"Solution 1 result shape: {result1.shape}")
```

**Data Type Errors** NumPy's strict type system generates errors when incompatible data types interact. Integer overflow, precision loss during type conversion, and mixed-type operations create unexpected results. The `astype()` method provides controlled type conversion, while `np.can_cast()` checks conversion safety before execution.

**Example:**

```python
# Data type conversion issues
int_array = np.array([1000000], dtype=np.int8)  # Overflow
print(f"Overflow result: {int_array}")  # Will show incorrect value

# Safe type conversion checking
large_values = np.array([300, 400, 500])
if np.can_cast(large_values.dtype, np.int8):
    safe_conversion = large_values.astype(np.int8)
else:
    print("Cannot safely convert to int8")
    safe_conversion = large_values.astype(np.int16)

# Mixed type operations
float_array = np.array([1.5, 2.7, 3.9])
int_array = np.array([1, 2, 3], dtype=np.int32)

# Check result type
result = float_array + int_array
print(f"Result dtype: {result.dtype}")  # Will be float64
```

**Index and Slicing Errors** Array indexing errors manifest as `IndexError` when indices exceed array bounds or `TypeError` when using invalid index types. Negative indexing, boolean masking errors, and fancy indexing complications require careful bounds checking and index validation.

**Example:**

```python
arr = np.array([[1, 2, 3], [4, 5, 6], [7, 8, 9]])

# Safe indexing with bounds checking
def safe_index(array, row, col):
    try:
        if 0 <= row < array.shape[0] and 0 <= col < array.shape[1]:
            return array[row, col]
        else:
            raise IndexError(f"Index ({row}, {col}) out of bounds for shape {array.shape}")
    except IndexError as e:
        print(f"Indexing error: {e}")
        return None

# Boolean indexing validation
mask = arr > 5
try:
    filtered = arr[mask]
    print(f"Filtered values: {filtered}")
except Exception as e:
    print(f"Boolean indexing error: {e}")

# Fancy indexing with validation
def safe_fancy_index(array, indices):
    try:
        # Validate all indices are within bounds
        if np.all(indices < array.shape[0]) and np.all(indices >= 0):
            return array[indices]
        else:
            raise IndexError("Some indices are out of bounds")
    except (IndexError, TypeError) as e:
        print(f"Fancy indexing error: {e}")
        return None

indices = np.array([0, 2, 1])
result = safe_fancy_index(arr, indices)
```

**Memory Allocation Errors** `MemoryError` exceptions occur when requesting arrays larger than available memory. Large array operations can exhaust system memory, particularly with complex number operations or high-dimensional arrays. Memory-mapped arrays (`np.memmap`) and chunked processing provide solutions for large datasets.

**Example:**

```python
import psutil

def check_memory_before_allocation(shape, dtype=np.float64):
    """Check if there's enough memory before creating array"""
    required_bytes = np.prod(shape) * np.dtype(dtype).itemsize
    available_bytes = psutil.virtual_memory().available
    
    if required_bytes > available_bytes:
        raise MemoryError(f"Not enough memory: need {required_bytes/1e9:.2f}GB, "
                         f"available {available_bytes/1e9:.2f}GB")
    return True

# Safe large array creation
try:
    check_memory_before_allocation((10000, 10000))
    large_array = np.zeros((10000, 10000))
    print("Array created successfully")
except MemoryError as e:
    print(f"Memory error prevented: {e}")
    # Use memory-mapped array instead
    large_array = np.memmap('temp_array.dat', dtype=np.float64, 
                           mode='w+', shape=(10000, 10000))
    print("Using memory-mapped array instead")

# Chunked processing for large operations
def chunked_operation(array, chunk_size=1000):
    """Process large array in chunks to avoid memory issues"""
    results = []
    for i in range(0, len(array), chunk_size):
        chunk = array[i:i+chunk_size]
        # Process chunk
        processed = np.square(chunk)  # Example operation
        results.append(processed)
    return np.concatenate(results)
```

**Linear Algebra Errors** `LinAlgError` exceptions arise from mathematically invalid operations like inverting singular matrices or computing eigenvalues of non-square matrices. Condition number checking with `np.linalg.cond()` identifies numerically unstable matrices before operations.

**Example:**

```python
from numpy.linalg import LinAlgError, cond, inv, solve

# Singular matrix detection and handling
def safe_matrix_inverse(matrix, condition_threshold=1e12):
    """Safely compute matrix inverse with condition number checking"""
    try:
        # Check if matrix is square
        if matrix.shape[0] != matrix.shape[1]:
            raise LinAlgError("Matrix must be square for inversion")
        
        # Check condition number
        condition_num = cond(matrix)
        if condition_num > condition_threshold:
            raise LinAlgError(f"Matrix is ill-conditioned (condition number: {condition_num:.2e})")
        
        return inv(matrix)
    
    except LinAlgError as e:
        print(f"Linear algebra error: {e}")
        # Use pseudo-inverse for singular matrices
        return np.linalg.pinv(matrix)

# Example matrices
well_conditioned = np.array([[2, 1], [1, 1]])
ill_conditioned = np.array([[1, 1], [1, 1.0000001]])  # Nearly singular

print("Well-conditioned matrix:")
result1 = safe_matrix_inverse(well_conditioned)
print(f"Inverse computed: {result1 is not None}")

print("\nIll-conditioned matrix:")
result2 = safe_matrix_inverse(ill_conditioned)
print(f"Pseudo-inverse used: {result2 is not None}")

# Safe linear system solving
def safe_solve(A, b):
    """Safely solve linear system Ax = b"""
    try:
        return solve(A, b)
    except LinAlgError as e:
        print(f"Cannot solve system: {e}")
        # Use least squares solution
        return np.linalg.lstsq(A, b, rcond=None)[0]
```

