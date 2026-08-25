## Cache-Friendly Operations


**Key Points**
Cache-friendly operations maximize data reuse and minimize memory access latency by organizing computations to work with data that fits in processor caches. Understanding cache hierarchies, temporal and spatial locality, and blocking strategies enables significant performance improvements for numerical computations.

**Spatial Locality Optimization**
```python
# Demonstrate cache-friendly vs cache-unfriendly access patterns
def cache_friendly_sum(matrix):
    """Sum matrix elements in row-major order (cache-friendly)"""
    total = 0.0
    rows, cols = matrix.shape
    for i in range(rows):
        for j in range(cols):
            total += matrix[i, j]
    return total

def cache_unfriendly_sum(matrix):
    """Sum matrix elements in column-major order (cache-unfriendly for C arrays)"""
    total = 0.0
    rows, cols = matrix.shape
    for j in range(cols):
        for i in range(rows):
            total += matrix[i, j]
    return total

# Benchmark different access patterns
large_matrix = np.random.rand(2000, 2000)

# NumPy vectorized operations (most cache-friendly)
start = time.time()
numpy_sum = np.sum(large_matrix)
numpy_time = time.time() - start

# Row-major access (cache-friendly)
start = time.time()
friendly_sum = cache_friendly_sum(large_matrix)
friendly_time = time.time() - start

print(f"NumPy vectorized: {numpy_time:.6f}s")
print(f"Cache-friendly: {friendly_time:.6f}s")
print(f"NumPy is {friendly_time/numpy_time:.1f}x faster than manual loop")
```

**Blocking and Tiling Strategies**
```python
# Matrix multiplication with cache blocking
def blocked_matrix_multiply(A, B, block_size=64):
    """Cache-blocked matrix multiplication"""
    n, m = A.shape
    m2, p = B.shape
    assert m == m2, "Matrix dimensions must match"
    
    C = np.zeros((n, p))
    
    # Block the computation
    for i in range(0, n, block_size):
        for j in range(0, p, block_size):
            for k in range(0, m, block_size):
                # Define block boundaries
                i_end = min(i + block_size, n)
                j_end = min(j + block_size, p)
                k_end = min(k + block_size, m)
                
                # Multiply blocks
                C[i:i_end, j:j_end] += A[i:i_end, k:k_end] @ B[k:k_end, j:j_end]
    
    return C

# Compare blocked vs direct multiplication for medium-sized matrices
size = 512
A = np.random.rand(size, size)
B = np.random.rand(size, size)

# NumPy's optimized implementation
start = time.time()
C_numpy = A @ B
numpy_matmul_time = time.time() - start

# Blocked implementation
start = time.time()
C_blocked = blocked_matrix_multiply(A, B, block_size=64)
blocked_time = time.time() - start

print(f"NumPy matmul: {numpy_matmul_time:.6f}s")
print(f"Blocked matmul: {blocked_time:.6f}s")
print(f"Results match: {np.allclose(C_numpy, C_blocked)}")
```

**Temporal Locality Exploitation**
```python
# Example: Element-wise operations with data reuse
def fused_operations(arr):
    """Fuse multiple operations to improve temporal locality"""
    # Single pass through data with multiple operations
    return (arr ** 2 + np.sin(arr)) * np.exp(-arr)

def separate_operations(arr):
    """Separate operations requiring multiple passes"""
    temp1 = arr ** 2
    temp2 = np.sin(arr)
    temp3 = np.exp(-arr)
    return (temp1 + temp2) * temp3

# Benchmark temporal locality
test_array = np.random.rand(1000000)

start = time.time()
result_fused = fused_operations(test_array)
fused_time = time.time() - start

start = time.time()
result_separate = separate_operations(test_array)
separate_time = time.time() - start

print(f"Fused operations: {fused_time:.6f}s")
print(f"Separate operations: {separate_time:.6f}s")
print(f"Results match: {np.allclose(result_fused, result_separate)}")
print(f"Speedup: {separate_time/fused_time:.2f}x")
```

**Memory Access Pattern Optimization**
```python
# Optimize for sequential memory access
def sequential_vs_random_access():
    size = 1000000
    data = np.arange(size, dtype=np.float64)
    
    # Sequential access pattern
    indices_sequential = np.arange(0, size, 100)
    
    # Random access pattern
    np.random.seed(42)
    indices_random = np.random.choice(size, len(indices_sequential), replace=False)
    
    # Benchmark access patterns
    start = time.time()
    sequential_sum = np.sum(data[indices_sequential])
    sequential_time = time.time() - start
    
    start = time.time()
    random_sum = np.sum(data[indices_random])
    random_time = time.time() - start
    
    print(f"Sequential access: {sequential_time:.6f}s")
    print(f"Random access: {random_time:.6f}s")
    print(f"Sequential is {random_time/sequential_time:.2f}x faster")

sequential_vs_random_access()
```

