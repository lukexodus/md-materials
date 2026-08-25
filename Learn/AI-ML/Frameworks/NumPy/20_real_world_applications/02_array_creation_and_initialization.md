## Array Creation and Initialization


**Basic Array Creation Methods**

```python
import numpy as np

# From lists and tuples
arr1 = np.array([1, 2, 3, 4, 5])
arr2 = np.array([[1, 2], [3, 4]])

# Using built-in functions
zeros = np.zeros((3, 4))
ones = np.ones((2, 3), dtype=np.float32)
empty = np.empty((2, 2))
identity = np.eye(4)

# Range-based creation
arange = np.arange(0, 10, 2)
linspace = np.linspace(0, 1, 50)
logspace = np.logspace(0, 2, 10)

# Random arrays
random_uniform = np.random.random((3, 3))
random_normal = np.random.normal(0, 1, (100,))
random_integers = np.random.randint(0, 10, (5, 5))
```

**Advanced Creation Techniques**

```python
# From functions
def custom_func(x, y):
    return x + y

fromfunction_arr = np.fromfunction(custom_func, (3, 3))

# Memory-mapped arrays for large datasets
memmap_arr = np.memmap('large_file.dat', dtype='float32', mode='w+', shape=(1000000,))

# Structured arrays
dtype = [('name', 'U10'), ('age', 'i4'), ('weight', 'f4')]
structured = np.array([('Alice', 25, 55.0), ('Bob', 30, 70.5)], dtype=dtype)
```

