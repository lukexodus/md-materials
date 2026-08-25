## Memory Leak Detection


**Memory Usage Monitoring** NumPy applications can develop memory leaks through improper array management. The `psutil` library monitors memory consumption patterns, while `memory_profiler` provides line-by-line memory usage analysis. [Unverified] Memory leaks often result from circular references in complex array structures.

**Example:**

```python
import gc
import psutil
import os

class MemoryMonitor:
    def __init__(self):
        self.process = psutil.Process(os.getpid())
        self.initial_memory = self.get_memory_usage()
    
    def get_memory_usage(self):
        """Get current memory usage in MB"""
        return self.process.memory_info().rss / 1024 / 1024
    
    def check_memory_change(self, operation_name="operation"):
        """Check memory change since last check"""
        current_memory = self.get_memory_usage()
        change = current_memory - self.initial_memory
        print(f"Memory after {operation_name}: {current_memory:.2f} MB (change: {change:+.2f} MB)")
        self.initial_memory = current_memory
        return change

def detect_memory_leak():
    """Example function that demonstrates memory leak detection"""
    monitor = MemoryMonitor()
    arrays = []
    
    print("Starting memory leak detection test...")
    monitor.check_memory_change("initialization")
    
    # Simulate operations that might cause leaks
    for i in range(5):
        # Create large array
        large_array = np.random.random((1000, 1000))
        arrays.append(large_array)
        monitor.check_memory_change(f"iteration {i+1}")
        
        # This simulates keeping references (potential leak)
        if i > 2:  # Start cleaning up after iteration 2
            arrays.pop(0)  # Remove oldest array
            gc.collect()  # Force garbage collection
            monitor.check_memory_change(f"cleanup {i+1}")

# Run memory leak detection
detect_memory_leak()
```

**Array Reference Management** Understanding NumPy's memory model prevents leak accumulation. Views share memory with parent arrays, while copies create independent memory allocations. The `array.base` attribute identifies view relationships, and explicit deletion using `del` releases array references.

**Example:**

```python
def analyze_array_references(arr, name="array"):
    """Analyze array memory relationships"""
    print(f"\n=== Reference analysis for {name} ===")
    print(f"Array ID: {id(arr)}")
    print(f"Base array: {arr.base is not None}")
    if arr.base is not None:
        print(f"Base array ID: {id(arr.base)}")
    print(f"Owns data: {arr.flags.owndata}")
    print(f"Reference count: {arr.base.__array_interface__.get('data', [None])[0] if arr.base else 'N/A'}")

def demonstrate_views_and_copies():
    """Demonstrate difference between views and copies"""
    # Original array
    original = np.arange(12).reshape(3, 4)
    print("Original array created")
    analyze_array_references(original, "original")
    
    # Create a view (shares memory)
    view = original[1:, :]  # Slice creates a view
    analyze_array_references(view, "view")
    
    # Create a copy (independent memory)
    copy = original.copy()
    analyze_array_references(copy, "copy")
    
    # Demonstrate memory sharing
    print(f"\nMemory sharing test:")
    print(f"Original and view share memory: {np.shares_memory(original, view)}")
    print(f"Original and copy share memory: {np.shares_memory(original, copy)}")
    
    # Modify view and show effect on original
    view[0, 0] = 999
    print(f"After modifying view[0,0] = 999:")
    print(f"Original[1,0] = {original[1,0]} (should be 999)")
    
    # Clean up references
    del view, copy
    gc.collect()
    print("References cleaned up")

demonstrate_views_and_copies()
```

