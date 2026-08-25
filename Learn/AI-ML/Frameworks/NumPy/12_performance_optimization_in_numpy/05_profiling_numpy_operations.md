## Profiling NumPy Operations


**Key Points**
Profiling identifies performance bottlenecks and quantifies optimization impacts. NumPy-specific profiling techniques include timing individual operations, analyzing memory usage patterns, and identifying computational hotspots. Understanding profiling tools and interpreting results enables data-driven optimization decisions.

**Basic Timing and Benchmarking**
```python
import numpy as np
import time
from contextlib import contextmanager

@contextmanager
def timer(operation_name):
    """Context manager for timing operations"""
    start = time.perf_counter()
    yield
    elapsed = time.perf_counter() - start
    print(f"{operation_name}: {elapsed:.6f}s")

# Function-level timing
def profile_numpy_operations():
    size = (1000, 1000)
    
    # Create test data
    with timer("Array creation"):
        a = np.random.rand(*size)
        b = np.random.rand(*size)
    
    # Test various operations
    operations = {
        "Element-wise addition": lambda: a + b,
        "Element-wise multiplication": lambda: a * b,
        "Matrix multiplication": lambda: a @ b,
        "Sum reduction": lambda: np.sum(a),
        "Mean along axis": lambda: np.mean(a, axis=0),
        "Sorting": lambda: np.sort(a, axis=1),
        "FFT": lambda: np.fft.fft2(a)
    }
    
    for name, operation in operations.items():
        with timer(name):
            result = operation()

profile_numpy_operations()
```

**Detailed Performance Analysis**
```python
# More sophisticated profiling with multiple runs
def detailed_benchmark(func, *args, n_runs=10, warmup=2):
    """Detailed benchmarking with statistical analysis"""
    
    # Warmup runs
    for _ in range(warmup):
        func(*args)
    
    # Timed runs
    times = []
    for _ in range(n_runs):
        start = time.perf_counter()
        result = func(*args)
        times.append(time.perf_counter() - start)
    
    times = np.array(times)
    stats = {
        'mean': np.mean(times),
        'std': np.std(times),
        'min': np.min(times),
        'max': np.max(times),
        'median': np.median(times)
    }
    
    return stats, result

# Example: Compare different matrix multiplication approaches
def compare_matmul_methods():
    size = 500
    a = np.random.rand(size, size)
    b = np.random.rand(size, size)
    
    methods = {
        'np.dot': lambda x, y: np.dot(x, y),
        'np.matmul': lambda x, y: np.matmul(x, y),
        '@ operator': lambda x, y: x @ y,
        'einsum': lambda x, y: np.einsum('ij,jk->ik', x, y)
    }
    
    results = {}
    for name, method in methods.items():
        stats, result = detailed_benchmark(method, a, b, n_runs=10)
        results[name] = stats
        print(f"{name:12s}: {stats['mean']:.6f}s ± {stats['std']:.6f}s")
    
    # Verify all methods produce same result
    base_result = methods['np.dot'](a, b)
    for name, method in methods.items():
        test_result = method(a, b)
        assert np.allclose(base_result, test_result), f"{name} produces different result"

compare_matmul_methods()
```

**Memory Usage Profiling**
```python
# Memory profiling utilities
def memory_usage_profiler():
    """Profile memory usage of NumPy operations"""
    import psutil
    import os
    
    def get_memory_mb():
        process = psutil.Process(os.getpid())
        return process.memory_info().rss / 1024 / 1024
    
    def profile_memory_operation(operation_name, operation_func):
        mem_before = get_memory_mb()
        result = operation_func()
        mem_after = get_memory_mb()
        mem_diff = mem_after - mem_before
        print(f"{operation_name:25s}: {mem_diff:+7.1f} MB")
        return result
    
    # Test memory usage of various operations
    size = 2000
    
    # Array creation
    arr1 = profile_memory_operation(
        "Create large array",
        lambda: np.random.rand(size, size)
    )
    
    # Copy operations
    arr2 = profile_memory_operation(
        "Array copy",
        lambda: arr1.copy()
    )
    
    # View operations (should use minimal memory)
    view = profile_memory_operation(
        "Array view (transpose)",
        lambda: arr1.T
    )
    
    # Mathematical operations
    result = profile_memory_operation(
        "Matrix multiplication",
        lambda: arr1 @ arr2
    )
    
    # In-place vs out-of-place operations
    profile_memory_operation(
        "In-place operation",
        lambda: arr1.__iadd__(1)  # arr1 += 1
    )
    
    temp_arr = arr2.copy()
    profile_memory_operation(
        "Out-of-place operation",
        lambda: temp_arr + 1
    )

memory_usage_profiler()
```

**Algorithmic Complexity Analysis**
```python
# Analyze scaling behavior of operations
def scaling_analysis():
    """Analyze how operations scale with input size"""
    
    def test_operation_scaling(operation_func, sizes, operation_name):
        times = []
        for size in sizes:
            # Create test data of specified size
            if operation_name in ["Sort", "FFT"]:
                data = np.random.rand(size)
            else:
                data = np.random.rand(size, size)
            
            # Time the operation
            start = time.perf_counter()
            if operation_name == "MatMul":
                result = operation_func(data, data)
            else:
                result = operation_func(data)
            elapsed = time.perf_counter() - start
            times.append(elapsed)
        
        return times
    
    # Test sizes
    sizes = [100, 200, 400, 800, 1600]
    
    # Operations to test
    operations = {
        "Sum": np.sum,
        "Sort": np.sort,
        "FFT": np.fft.fft,
        "MatMul": np.matmul
    }
    
    print("Scaling Analysis:")
    print("Size      ", "    ".join(f"{op:>8s}" for op in operations.keys()))
    print("-" * 50)
    
    all_results = {}
    for op_name, op_func in operations.items():
        times = test_operation_scaling(op_func, sizes, op_name)
        all_results[op_name] = times
    
    # Print results in tabular format
    for i, size in enumerate(sizes):
        print(f"{size:4d}      ", end="")
        for op_name in operations.keys():
            time_val = all_results[op_name][i]
            print(f"{time_val:8.4f}", end="    ")
        print()
    
    # Analyze scaling ratios
    print("\nScaling Ratios (time[i+1]/time[i]):")
    print("Size      ", "    ".join(f"{op:>8s}" for op in operations.keys()))
    print("-" * 50)
    
    for i in range(1, len(sizes)):
        print(f"{sizes[i]:4d}      ", end="")
        for op_name in operations.keys():
            if all_results[op_name][i-1] > 0:
                ratio = all_results[op_name][i] / all_results[op_name][i-1]
                print(f"{ratio:8.2f}", end="    ")
            else:
                print(f"{'N/A':>8s}", end="    ")
        print()

scaling_analysis()
```

