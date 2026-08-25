## Array Debugging Techniques


**Array Inspection Methods** Systematic array examination reveals structural and content issues. Essential inspection functions include `array.shape`, `array.dtype`, `array.ndim`, and `array.size` for structural analysis. Content inspection uses `np.isnan()`, `np.isinf()`, `np.isfinite()` for numerical validity checking.

**Example:**

```python
def debug_array(arr, name="array"):
    """Comprehensive array debugging information"""
    print(f"\n=== Debug info for {name} ===")
    print(f"Shape: {arr.shape}")
    print(f"Data type: {arr.dtype}")
    print(f"Dimensions: {arr.ndim}")
    print(f"Size: {arr.size}")
    print(f"Memory usage: {arr.nbytes} bytes")
    print(f"Is C-contiguous: {arr.flags.c_contiguous}")
    print(f"Is Fortran-contiguous: {arr.flags.f_contiguous}")
    
    # Statistical information
    if arr.size > 0:
        print(f"Min: {np.min(arr)}")
        print(f"Max: {np.max(arr)}")
        print(f"Mean: {np.mean(arr)}")
        print(f"Std: {np.std(arr)}")
    
    # Check for problematic values
    nan_count = np.sum(np.isnan(arr))
    inf_count = np.sum(np.isinf(arr))
    finite_count = np.sum(np.isfinite(arr))
    
    print(f"NaN values: {nan_count}")
    print(f"Infinite values: {inf_count}")
    print(f"Finite values: {finite_count}")
    
    if nan_count > 0:
        nan_locations = np.where(np.isnan(arr))
        print(f"NaN locations: {list(zip(*nan_locations))[:5]}...")  # Show first 5
    
    return {
        'shape': arr.shape,
        'dtype': arr.dtype,
        'has_nan': nan_count > 0,
        'has_inf': inf_count > 0
    }

# Example usage
problematic_array = np.array([1.0, 2.0, np.nan, np.inf, -np.inf, 3.0])
debug_info = debug_array(problematic_array, "problematic_data")
```

**Intermediate Result Examination** Complex computations benefit from step-by-step verification. Storing intermediate arrays enables result validation at each computation stage. The `np.set_printoptions()` function controls array display formatting for detailed examination.

**Example:**

```python
# Set up detailed printing options
np.set_printoptions(precision=4, suppress=True, threshold=50)

def debug_computation(x, debug=True):
    """Example computation with debugging checkpoints"""
    if debug:
        print("Input:")
        debug_array(x, "input")
    
    # Step 1: Normalization
    mean_x = np.mean(x)
    std_x = np.std(x)
    normalized = (x - mean_x) / std_x
    
    if debug:
        print(f"\nStep 1 - Normalization (mean={mean_x:.4f}, std={std_x:.4f}):")
        debug_array(normalized, "normalized")
    
    # Step 2: Apply transformation
    transformed = np.exp(normalized)
    
    if debug:
        print("\nStep 2 - Exponential transformation:")
        debug_array(transformed, "transformed")
        
        # Check for overflow
        if np.any(np.isinf(transformed)):
            print("WARNING: Overflow detected in exponential!")
    
    # Step 3: Final scaling
    result = transformed / np.sum(transformed)
    
    if debug:
        print("\nStep 3 - Final scaling:")
        debug_array(result, "result")
        print(f"Sum check: {np.sum(result):.10f} (should be 1.0)")
    
    return result

# Test with different inputs
test_data = np.array([1, 2, 3, 100, 1000])  # This will cause overflow
result = debug_computation(test_data)
```

**Conditional Debugging** Boolean indexing identifies problematic array elements. Expressions like `array[array < 0]` isolate negative values, while `np.where()` locates elements meeting specific conditions. The `np.argmax()` and `np.argmin()` functions identify extreme value locations.

**Example:**

```python
def conditional_debug(arr, conditions=None):
    """Debug array based on various conditions"""
    if conditions is None:
        conditions = {
            'negative': lambda x: x < 0,
            'zero': lambda x: x == 0,
            'large': lambda x: np.abs(x) > 100,
            'nan': lambda x: np.isnan(x),
            'inf': lambda x: np.isinf(x)
        }
    
    print(f"Array shape: {arr.shape}")
    print(f"Array: {arr}")
    
    for name, condition in conditions.items():
        mask = condition(arr)
        matching_values = arr[mask]
        locations = np.where(mask)
        
        if len(matching_values) > 0:
            print(f"\n{name.upper()} VALUES:")
            print(f"  Count: {len(matching_values)}")
            print(f"  Values: {matching_values}")
            print(f"  Locations: {list(zip(*locations))}")
    
    # Find extreme values
    if arr.size > 0 and np.all(np.isfinite(arr)):
        min_idx = np.unravel_index(np.argmin(arr), arr.shape)
        max_idx = np.unravel_index(np.argmax(arr), arr.shape)
        
        print(f"\nEXTREME VALUES:")
        print(f"  Minimum: {arr[min_idx]} at {min_idx}")
        print(f"  Maximum: {arr[max_idx]} at {max_idx}")

# Example usage
test_array = np.array([[1, -5, 0], [np.nan, 150, -200], [0, np.inf, 42]])
conditional_debug(test_array)
```

