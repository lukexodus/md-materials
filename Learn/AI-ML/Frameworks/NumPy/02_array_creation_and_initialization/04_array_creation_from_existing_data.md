## Array Creation from Existing Data


**From Lists and Tuples**

```python
# From Python list
list_arr = np.array([1, 2, 3, 4, 5])

# From nested lists (multidimensional)
nested = np.array([[1, 2, 3], [4, 5, 6]])

# From tuple
tuple_arr = np.array((1, 2, 3))
```

**From Other Arrays**

```python
# Copy arrays
original = np.array([1, 2, 3])
copied = np.array(original)  # Creates copy
referenced = np.asarray(original)  # May return reference

# Convert data types
float_arr = np.array([1, 2, 3], dtype=float)
```

**From Files and Strings**

```python
# From string (simple cases)
str_arr = np.fromstring('1 2 3 4', sep=' ')

# From file
# np.loadtxt('data.txt')  # Load from text file
# np.load('data.npy')     # Load from NumPy binary format
```

