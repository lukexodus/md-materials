## Element-wise Operations and Broadcasting


**Broadcasting Fundamentals**

Broadcasting allows NumPy to perform operations on arrays with different shapes without explicitly reshaping them. NumPy automatically expands smaller arrays to match larger ones during operations, following specific rules that determine compatibility.

```python
import numpy as np

# Scalar with array
arr = np.array([1, 2, 3, 4])
result = arr + 10  # [11 12 13 14]

# Different shaped arrays
arr_2d = np.array([[1, 2, 3], [4, 5, 6]])
arr_1d = np.array([10, 20, 30])
broadcasted = arr_2d + arr_1d
# [[11 22 33]
#  [14 25 36]]
```

**Broadcasting Rules**

Broadcasting follows three fundamental rules: arrays are aligned from the rightmost dimension, dimensions of size 1 are stretched to match corresponding dimensions, and missing dimensions are treated as having size 1.

```python
# Compatible shapes for broadcasting
a = np.ones((3, 4, 5))     # Shape: (3, 4, 5)
b = np.ones((4, 5))        # Shape: (4, 5) -> broadcasts to (3, 4, 5)
c = np.ones((3, 1, 5))     # Shape: (3, 1, 5) -> broadcasts to (3, 4, 5)
d = np.ones((1, 4, 1))     # Shape: (1, 4, 1) -> broadcasts to (3, 4, 5)

# All can be added together
result = a + b + c + d
```

**Element-wise Function Application**

Element-wise operations apply functions to each element independently, preserving array structure while transforming values.

```python
# Element-wise operations
arr = np.array([1, 4, 9, 16])
sqrt_arr = np.sqrt(arr)        # [1. 2. 3. 4.]
squared = np.square(arr)       # [1 16 81 256]
power = np.power(arr, 0.5)     # [1. 2. 3. 4.]

# Complex element-wise operations
complex_arr = np.array([1+2j, 3+4j, 5+6j])
abs_complex = np.abs(complex_arr)      # [2.236 5. 7.81]
angle_complex = np.angle(complex_arr)   # [1.107 0.927 0.876]
```

