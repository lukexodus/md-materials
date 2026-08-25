## Performance Optimization Techniques


**Vectorization Strategies**

```python
# Inefficient loop-based approach
def slow_operation(arr):
    result = np.zeros_like(arr)
    for i in range(len(arr)):
        result[i] = arr[i] ** 2 + 2 * arr[i] + 1
    return result

# Vectorized approach
def fast_operation(arr):
    return arr ** 2 + 2 * arr + 1

# Using numexpr for complex expressions (if available)
# import numexpr as ne
# result = ne.evaluate("arr**2 + 2*arr + 1")
```

**Memory-Efficient Operations**

```python
# In-place operations to save memory
large_array = np.random.random((10000, 10000))
large_array += 1  # In-place addition
np.sqrt(large_array, out=large_array)  # In-place square root

# Memory views vs copies
view = large_array[::2, ::2]  # Creates a view
copy = large_array[::2, ::2].copy()  # Creates a copy

# Using appropriate data types
int_array = np.array([1, 2, 3], dtype=np.int8)  # Uses less memory than default int64
```

