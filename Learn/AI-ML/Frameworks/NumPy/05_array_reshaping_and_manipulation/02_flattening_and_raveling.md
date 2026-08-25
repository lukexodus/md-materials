## Flattening and Raveling


Flattening operations convert multi-dimensional arrays to one-dimensional arrays.

**flatten() Method:** Always returns a copy of the array:

```python
arr_2d = np.array([[1, 2, 3], [4, 5, 6]])
flattened = arr_2d.flatten()  # [1, 2, 3, 4, 5, 6]
flattened_f = arr_2d.flatten(order='F')  # [1, 4, 2, 5, 3, 6] (column-major)
```

**ravel() Method:** Returns a view when possible, copy when necessary:

```python
raveled = arr_2d.ravel()  # Usually returns view
raveled_copy = np.ravel(arr_2d)  # Function form

# Order parameters
c_order = arr_2d.ravel(order='C')  # Row-major (default)
f_order = arr_2d.ravel(order='F')  # Column-major
```

**Performance Differences:** ravel() is generally faster than flatten() because it avoids unnecessary copying when array memory layout permits view creation.

