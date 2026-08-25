## Avoiding Unnecessary Copies


**Key Points**
Unnecessary array copies consume memory bandwidth and increase computation time. Understanding when NumPy creates copies versus views, and how to minimize copying through proper use of in-place operations, broadcasting, and memory-efficient algorithms is essential for performance optimization.

**View vs Copy Detection**
```python
# Understanding when NumPy creates copies
def analyze_copy_behavior():
    original = np.arange(1000000).reshape(1000, 1000)
    print(f"Original array id: {id(original.data)}")
    
    # Operations that create views
    transpose_view = original.T
    slice_view = original[::2, ::2]
    reshape_view = original.reshape(-1)  # Only if compatible
    
    print(f"Transpose shares data: {np.shares_memory(original, transpose_view)}")
    print(f"Slice shares data: {np.shares_memory(original, slice_view)}")
    print(f"Reshape shares data: {np.shares_memory(original, reshape_view)}")
    
    # Operations that create copies
    fancy_index_copy = original[[0, 2, 4]]
    boolean_mask_copy = original[original > 500000]
    arithmetic_copy = original + 1
    
    print(f"Fancy indexing shares data: {np.shares_memory(original, fancy_index_copy)}")
    print(f"Boolean mask shares data: {np.shares_memory(original, boolean_mask_copy)}")
    print(f"Arithmetic shares data: {np.shares_memory(original, arithmetic_copy)}")

analyze_copy_behavior()
```

**In-Place Operations Optimization**
```python
# Maximize use of in-place operations
def demonstrate_inplace_operations():
    size = 1000000
    
    # Method 1: Multiple temporary arrays (memory intensive)
    def memory_intensive_approach():
        arr = np.random.rand(size)
        temp1 = arr * 2
        temp2 = temp1 + 5
        temp3 = np.sqrt(temp2)
        result = temp3 - 1
        return result
    
    # Method 2: In-place operations (memory efficient)
    def memory_efficient_approach():
        arr = np.random.rand(size)
        arr *= 2           # In-place multiplication
        arr += 5           # In-place addition
        np.sqrt(arr, out=arr)  # In-place square root
        arr -= 1           # In-place subtraction
        return arr
    
    # Method 3: Pre-allocated output array
    def preallocated_approach():
        arr = np.random.rand(size)
        output = np.empty_like(arr)
        
        np.multiply(arr, 2, out=output)
        output += 5
        np.sqrt(output, out=output)
        output -= 1
        return output
    
    # Benchmark memory efficiency
    import psutil
    import os
    
    def get_memory_usage():
        process = psutil.Process(os.getpid())
        return process.memory_info().rss / 1024 / 1024  # MB
    
    methods = {
        'Memory Intensive': memory_intensive_approach,
        'Memory Efficient': memory_efficient_approach,
        'Pre-allocated': preallocated_approach
    }
    
    for name, method in methods.items():
        mem_before = get_memory_usage()
        start = time.time()
        result = method()
        elapsed = time.time() - start
        mem_after = get_memory_usage()
        
        print(f"{name:16s}: {elapsed:.6f}s, Memory: {mem_after-mem_before:+.1f}MB")

demonstrate_inplace_operations()
```

**Efficient Array Concatenation and Stacking**
```python
# Avoid repeated concatenations
def inefficient_concatenation(arrays):
    """Inefficient: repeated concatenation creates many copies"""
    result = arrays[0]
    for arr in arrays[1:]:
        result = np.concatenate([result, arr])
    return result

def efficient_concatenation(arrays):
    """Efficient: single concatenation operation"""
    return np.concatenate(arrays)

def preallocated_concatenation(arrays):
    """Most efficient: pre-allocate result array"""
    total_size = sum(arr.size for arr in arrays)
    result = np.empty(total_size, dtype=arrays[0].dtype)
    
    offset = 0
    for arr in arrays:
        result[offset:offset + arr.size] = arr.flat
        offset += arr.size
    
    return result

# Benchmark concatenation methods
num_arrays = 100
array_size = 10000
test_arrays = [np.random.rand(array_size) for _ in range(num_arrays)]

methods = {
    'Inefficient': inefficient_concatenation,
    'Efficient': efficient_concatenation,
    'Pre-allocated': preallocated_concatenation
}

for name, method in methods.items():
    start = time.time()
    result = method(test_arrays)
    elapsed = time.time() - start
    print(f"{name:13s}: {elapsed:.6f}s, Result size: {result.size}")
```

**Broadcasting to Avoid Copies**
```python
# Use broadcasting instead of explicit array expansion
def demonstrate_broadcasting_efficiency():
    # Large arrays for demonstration
    matrix = np.random.rand(1000, 1000)
    vector = np.random.rand(1000)
    
    # Method 1: Explicit expansion (creates copy)
    def explicit_expansion():
        expanded_vector = np.tile(vector, (1000, 1))
        return matrix + expanded_vector
    
    # Method 2: Broadcasting (no copy)
    def broadcasting_approach():
        return matrix + vector  # Broadcasting handles expansion
    
    # Method 3: Using newaxis for clarity
    def newaxis_approach():
        return matrix + vector[np.newaxis, :]
    
    methods = {
        'Explicit expansion': explicit_expansion,
        'Broadcasting': broadcasting_approach,
        'Newaxis': newaxis_approach
    }
    
    for name, method in methods.items():
        start = time.time()
        result = method()
        elapsed = time.time() - start
        print(f"{name:18s}: {elapsed:.6f}s")
    
    # Verify results are identical
    results = [method() for method in methods.values()]
    print("All results identical:", all(np.array_equal(results[0], r) for r in results[1:]))

demonstrate_broadcasting_efficiency()
```

