## Aggregate Functions and Reductions


**Sum and Product Operations**

```python
# Sum operations
arr = np.array([[1, 2, 3], [4, 5, 6]])
total_sum = np.sum(arr)           # 21
sum_axis0 = np.sum(arr, axis=0)   # [5 7 9]
sum_axis1 = np.sum(arr, axis=1)   # [6 15]

# Cumulative sum
cumsum_flat = np.cumsum(arr)      # [1 3 6 10 15 21]
cumsum_axis0 = np.cumsum(arr, axis=0)  # [[1 2 3], [5 7 9]]

# Product operations
product_all = np.prod(arr)        # 720
product_axis0 = np.prod(arr, axis=0)   # [4 10 18]
cumprod = np.cumprod(arr.flatten())    # [1 2 6 24 120 720]
```

**Min and Max Operations**

```python
# Minimum and maximum
min_val = np.min(arr)             # 1
max_val = np.max(arr)             # 6
min_axis0 = np.min(arr, axis=0)   # [1 2 3]
max_axis1 = np.max(arr, axis=1)   # [3 6]

# Argument min and max (indices)
argmin_flat = np.argmin(arr)      # 0
argmax_axis0 = np.argmax(arr, axis=0)  # [1 1 1]

# Minimum and maximum along specific axes
data_3d = np.random.rand(3, 4, 5)
min_axes = np.min(data_3d, axis=(0, 2))  # Min along first and third axes
```

**Logical Reductions**

```python
# Boolean arrays
bool_arr = np.array([[True, False, True], [False, True, False]])

# Any and all operations
any_all = np.any(bool_arr)        # True
all_all = np.all(bool_arr)        # False
any_axis0 = np.any(bool_arr, axis=0)   # [True True True]
all_axis1 = np.all(bool_arr, axis=1)   # [False False]

# Count non-zero elements
count_nonzero = np.count_nonzero(bool_arr)  # 3
```

**Advanced Aggregate Functions**

```python
# Pairwise differences
data_seq = np.array([1, 3, 6, 10, 15])
differences = np.diff(data_seq)   # [2 3 4 5]
second_diff = np.diff(data_seq, n=2)  # [1 1 1]

# Gradient calculation
gradient = np.gradient(data_seq)  # [2. 2.5 3.5 4.5 5.]

# Unique values and counts
data_with_repeats = np.array([1, 2, 2, 3, 3, 3, 4])
unique_vals = np.unique(data_with_repeats)  # [1 2 3 4]
unique_counts = np.unique(data_with_repeats, return_counts=True)
```

**Custom Reduction Functions**

```python
# Apply custom functions along axes
def custom_range(arr):
    return np.max(arr) - np.min(arr)

# Apply along different axes
data = np.random.rand(5, 10)
range_axis0 = np.apply_along_axis(custom_range, 0, data)
range_axis1 = np.apply_along_axis(custom_range, 1, data)

# Reduce function for complex operations
def weighted_mean(arr, weights):
    return np.sum(arr * weights) / np.sum(weights)
```

**Key Points**

- Broadcasting enables efficient operations on arrays with different shapes following specific compatibility rules
- Element-wise operations preserve array structure while applying functions to individual elements
- Arithmetic operators are overloaded for intuitive mathematical computation on arrays
- Trigonometric functions support both radians and degrees with complete inverse function coverage
- Exponential and logarithmic functions include specialized variants for numerical accuracy
- Statistical functions provide comprehensive descriptive statistics with axis-specific computation
- Aggregate functions reduce array dimensionality while preserving essential information
- Custom reduction operations can be implemented using apply_along_axis and reduce functions

**Examples**

Statistical analysis of a dataset:

```python
# Sample dataset
data = np.random.normal(100, 15, size=(1000, 5))  # 1000 samples, 5 features

# Comprehensive statistical summary
means = np.mean(data, axis=0)
stds = np.std(data, axis=0, ddof=1)
medians = np.median(data, axis=0)
q25, q75 = np.percentile(data, [25, 75], axis=0)

# Correlation analysis
correlation_matrix = np.corrcoef(data.T)

# Standardization
standardized = (data - means) / stds

# Feature scaling to [0, 1]
min_vals = np.min(data, axis=0)
max_vals = np.max(data, axis=0)
normalized = (data - min_vals) / (max_vals - min_vals)
```

**Output**

Mathematical operations in NumPy provide a comprehensive framework for numerical computation, combining efficient element-wise operations with sophisticated broadcasting rules. The integration of arithmetic operators, trigonometric functions, statistical measures, and aggregate reductions creates a powerful toolkit for scientific computing. Understanding these operations and their interaction with NumPy's broadcasting system enables efficient manipulation of multidimensional data structures and forms the foundation for advanced numerical analysis and machine learning applications.

---

