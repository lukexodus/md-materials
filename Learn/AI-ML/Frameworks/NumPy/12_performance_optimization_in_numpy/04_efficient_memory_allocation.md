## Efficient Memory Allocation


**Key Points**
Memory allocation strategies significantly impact performance, especially for large arrays or frequent allocation patterns. Understanding NumPy's memory management, pre-allocation techniques, and memory pooling approaches enables optimization of memory-intensive computations while reducing garbage collection overhead.

**Pre-allocation Strategies**
```python
# Compare different allocation patterns
def allocation_benchmark():
    n_iterations = 1000
    array_size = 10000
    
    # Method 1: Repeated allocation (inefficient)
    def repeated_allocation():
        results = []
        for i in range(n_iterations):
            arr = np.random.rand(array_size)
            processed = arr * 2 + 1
            results.append(np.sum(processed))
        return results
    
    # Method 2: Pre-allocate working arrays (efficient)
    def preallocated_working():
        results = []
        work_array = np.empty(array_size)
        temp_array = np.empty(array_size)
        
        for i in range(n_iterations):
            np.random.rand(array_size, out=work_array)
            np.multiply(work_array, 2, out=temp_array)
            temp_array += 1
            results.append(np.sum(temp_array))
        return results
    
    # Method 3: Pre-allocate result array
    def preallocated_results():
        results = np.empty(n_iterations)
        work_array = np.empty(array_size)
        
        for i in range(n_iterations):
            np.random.rand(array_size, out=work_array)
            work_array *= 2
            work_array += 1
            results[i] = np.sum(work_array)
        return results
    
    methods = {
        'Repeated allocation': repeated_allocation,
        'Pre-allocated working': preallocated_working,
        'Pre-allocated results': preallocated_results
    }
    
    for name, method in methods.items():
        start = time.time()
        result = method()
        elapsed = time.time() - start
        print(f"{name:20s}: {elapsed:.6f}s")

allocation_benchmark()
```

**Memory Pool Management**
```python
# Implement simple memory pooling for frequently allocated arrays
class ArrayPool:
    """Simple memory pool for NumPy arrays"""
    
    def __init__(self):
        self.pools = {}  # shape -> list of available arrays
    
    def get_array(self, shape, dtype=np.float64):
        """Get array from pool or create new one"""
        key = (shape, dtype)
        
        if key in self.pools and self.pools[key]:
            return self.pools[key].pop()
        else:
            return np.empty(shape, dtype=dtype)
    
    def return_array(self, arr):
        """Return array to pool for reuse"""
        key = (arr.shape, arr.dtype)
        
        if key not in self.pools:
            self.pools[key] = []
        
        # Clear array and return to pool
        arr.fill(0)  # Optional: clear data
        self.pools[key].append(arr)
    
    def get_pool_stats(self):
        """Get statistics about pool usage"""
        stats = {}
        for key, arrays in self.pools.items():
            stats[key] = len(arrays)
        return stats

# Demonstrate memory pooling
def test_memory_pooling():
    pool = ArrayPool()
    shape = (1000, 1000)
    n_operations = 100
    
    # Method 1: Without pooling
    def without_pooling():
        for i in range(n_operations):
            arr = np.random.rand(*shape)
            result = np.sum(arr ** 2)
    
    # Method 2: With pooling
    def with_pooling():
        for i in range(n_operations):
            arr = pool.get_array(shape)
            np.random.rand(*shape, out=arr)
            result = np.sum(arr ** 2)
            pool.return_array(arr)
    
    # Benchmark both approaches
    start = time.time()
    without_pooling()
    time_without = time.time() - start
    
    start = time.time()
    with_pooling()
    time_with = time.time() - start
    
    print(f"Without pooling: {time_without:.6f}s")
    print(f"With pooling: {time_with:.6f}s")
    print(f"Pool stats: {pool.get_pool_stats()}")

test_memory_pooling()
```

**Memory-Efficient Array Operations**
```python
# Techniques for reducing memory footprint
def memory_efficient_operations():
    # Large dataset simulation
    n_samples = 1000000
    n_features = 100
    
    # Method 1: Memory-intensive approach
    def memory_intensive_standardization(data):
        mean = np.mean(data, axis=0)
        std = np.std(data, axis=0)
        standardized = (data - mean) / std
        return standardized
    
    # Method 2: Memory-efficient approach
    def memory_efficient_standardization(data):
        # Compute statistics
        mean = np.mean(data, axis=0)
        std = np.std(data, axis=0)
        
        # In-place standardization
        data -= mean  # Broadcasting subtraction
        data /= std   # Broadcasting division
        return data
    
    # Method 3: Chunked processing for very large arrays
    def chunked_standardization(data, chunk_size=10000):
        # First pass: compute statistics
        mean = np.mean(data, axis=0)
        std = np.std(data, axis=0)
        
        # Second pass: standardize in chunks
        n_samples = data.shape[0]
        for start in range(0, n_samples, chunk_size):
            end = min(start + chunk_size, n_samples)
            chunk = data[start:end]
            chunk -= mean
            chunk /= std
        
        return data
    
    # Test with moderately sized array
    test_data = np.random.randn(100000, 50)
    
    # Copy for each test
    data1 = test_data.copy()
    data2 = test_data.copy()
    data3 = test_data.copy()
    
    methods = [
        ('Memory intensive', lambda: memory_intensive_standardization(data1)),
        ('Memory efficient', lambda: memory_efficient_standardization(data2)),
        ('Chunked processing', lambda: chunked_standardization(data3, chunk_size=5000))
    ]
    
    for name, method in methods:
        start = time.time()
        result = method()
        elapsed = time.time() - start
        print(f"{name:18s}: {elapsed:.6f}s")

memory_efficient_operations()
```

