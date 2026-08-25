## Performance Debugging


**Timing Analysis** Performance bottlenecks require systematic measurement. The `timeit` module provides accurate timing for small code sections, while `time.perf_counter()` measures larger operations. NumPy's `np.show_config()` displays optimized library information affecting performance.

**Example:**

```python
import timeit
import time
from functools import wraps

def time_function(func):
    """Decorator to time function execution"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.perf_counter()
        result = func(*args, **kwargs)
        end = time.perf_counter()
        print(f"{func.__name__} took {end - start:.6f} seconds")
        return result
    return wrapper

class PerformanceProfiler:
    def __init__(self):
        self.timings = {}
    
    def time_operation(self, name, operation, *args, **kwargs):
        """Time a specific operation"""
        setup_code = "import numpy as np"
        
        if callable(operation):
            # Time function call
            start = time.perf_counter()
            result = operation(*args, **kwargs)
            elapsed = time.perf_counter() - start
        else:
            # Time code string
            elapsed = timeit.timeit(operation, setup=setup_code, number=1)
            result = None
        
        self.timings[name] = elapsed
        print(f"{name}: {elapsed:.6f} seconds")
        return result
    
    def compare_operations(self, operations_dict, iterations=1000):
        """Compare multiple operations"""
        print(f"\nComparing operations ({iterations} iterations):")
        results = {}
        
        for name, operation in operations_dict.items():
            if callable(operation):
                elapsed = timeit.timeit(operation, number=iterations)
            else:
                elapsed = timeit.timeit(operation, setup="import numpy as np", 
                                     number=iterations)
            results[name] = elapsed
            print(f"{name}: {elapsed:.6f} seconds ({elapsed/iterations*1e6:.2f} µs per operation)")
        
        # Find fastest
        fastest = min(results, key=results.get)
        print(f"\nFastest: {fastest}")
        
        # Show relative performance
        baseline = results[fastest]
        for name, time_taken in results.items():
            ratio = time_taken / baseline
            print(f"{name}: {ratio:.2f}x slower than fastest")
        
        return results

# Example usage
profiler = PerformanceProfiler()

# Compare different ways to create arrays
size = (1000, 1000)
operations = {
    'zeros': lambda: np.zeros(size),
    'ones': lambda: np.ones(size),
    'empty': lambda: np.empty(size),
    'random': lambda: np.random.random(size)
}

profiler.compare_operations(operations, iterations=10)

# Time specific computation patterns
@time_function
def vectorized_computation(arr):
    """Vectorized computation"""
    return np.sum(arr**2 + np.sqrt(np.abs(arr)))

@time_function  
def loop_computation(arr):
    """Non-vectorized loop computation"""
    result = 0
    flat_arr = arr.flatten()
    for x in flat_arr:
        result += x**2 + (abs(x)**0.5)
    return result

# Compare vectorized vs loop approaches
test_array = np.random.random((100, 100))
vec_result = vectorized_computation(test_array)
loop_result = loop_computation(test_array)
print(f"Results match: {np.isclose(vec_result, loop_result)}")
```

**Broadcasting Efficiency** Understanding broadcasting mechanics prevents unnecessary memory allocation. Explicit shape manipulation often performs better than relying on automatic broadcasting for complex operations. [Inference] Pre-allocating result arrays can reduce memory fragmentation in iterative operations.

**Example:**

```python
def analyze_broadcasting_performance():
    """Analyze performance of different broadcasting approaches"""
    
    # Test data
    a = np.random.random((1000, 1))      # Column vector
    b = np.random.random((1, 1000))      # Row vector
    c = np.random.random((1000, 1000))   # Full matrix
    
    profiler = PerformanceProfiler()
    
    # Method 1: Let NumPy handle broadcasting automatically
    def auto_broadcast():
        return a + b
    
    # Method 2: Explicit broadcasting
    def explicit_broadcast():
        a_broadcast = np.broadcast_to(a, (1000, 1000))
        b_broadcast = np.broadcast_to(b, (1000, 1000))
        return a_broadcast + b_broadcast
    
    # Method 3: Pre-allocated result array
    def preallocated_result():
        result = np.empty((1000, 1000))
        result[:] = a + b
        return result
    
    # Method 4: Using out parameter
    def out_parameter():
        result = np.empty((1000, 1000))
        np.add(a, b, out=result)
        return result
    
    operations = {
        'auto_broadcast': auto_broadcast,
        'explicit_broadcast': explicit_broadcast,
        'preallocated_result': preallocated_result,
        'out_parameter': out_parameter
    }
    
    results = profiler.compare_operations(operations, iterations=100)
    
    # Verify all methods give same result
    ref_result = auto_broadcast()
    for name, operation in operations.items():
        if name != 'auto_broadcast':
            test_result = operation()
            matches = np.allclose(ref_result, test_result)
            print(f"{name} matches reference: {matches}")

analyze_broadcasting_performance()

def memory_efficient_operations():
    """Demonstrate memory-efficient operation patterns"""
    
    print("\n=== Memory-efficient operation patterns ===")
    
    # Large arrays that might cause memory pressure
    size = (2000, 2000)
    a = np.random.random(size)
    b = np.random.random(size)
    
    monitor = MemoryMonitor()
    monitor.check_memory_change("initial")
    
    # Memory-inefficient: creates multiple temporary arrays
    def inefficient_operations():
        temp1 = a + b
        temp2 = temp1 * 2
        temp3 = np.sqrt(temp2)
        return np.sum(temp3)
    
    result1 = inefficient_operations()
    monitor.check_memory_change("inefficient method")
    
    # Memory-efficient: reuse arrays and use in-place operations
    def efficient_operations():
        # Use one of the input arrays as workspace (if safe to modify)
        workspace = a.copy()  # or use a if it's safe to modify
        workspace += b        # In-place addition
        workspace *= 2        # In-place multiplication
        np.sqrt(workspace, out=workspace)  # In-place sqrt
        return np.sum(workspace)
    
    result2 = efficient_operations()
    monitor.check_memory_change("efficient method")
    
    print(f"Results match: {np.isclose(result1, result2)}")
    
    # Clean up
    del a, b
    gc.collect()
    monitor.check_memory_change("after cleanup")

memory_efficient_operations()
```

