## Array Creation Methods


NumPy provides numerous methods for creating arrays with different initialization patterns:

**From Sequences:**

```python
# From lists/tuples
arr1 = np.array([1, 2, 3, 4])
arr2 = np.array([[1, 2], [3, 4]])
arr3 = np.array((1, 2, 3, 4))
```

**Intrinsic NumPy Creation:**

```python
# Zeros and ones
zeros = np.zeros((3, 4))
ones = np.ones((2, 3, 4))
identity = np.eye(5)  # Identity matrix

# Range functions
arange = np.arange(0, 10, 2)  # [0, 2, 4, 6, 8]
linspace = np.linspace(0, 1, 5)  # [0, 0.25, 0.5, 0.75, 1]
logspace = np.logspace(0, 2, 5)  # Logarithmic spacing

# Uninitialized arrays
empty = np.empty((2, 3))  # Uninitialized values
```

**Advanced Creation:**

```python
# From functions
fromfunction = np.fromfunction(lambda i, j: i * j, (3, 3))

# Random arrays
random = np.random.random((3, 4))
normal = np.random.normal(0, 1, (3, 4))

# From files
array_from_file = np.loadtxt('data.txt')
```

