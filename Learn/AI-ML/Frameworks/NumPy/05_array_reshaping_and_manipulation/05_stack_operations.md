## Stack Operations


Stacking operations combine multiple arrays along existing or new dimensions.

**hstack() - Horizontal Stacking:** Concatenates arrays along axis 1 (columns):

```python
arr1 = np.array([[1, 2], [3, 4]])
arr2 = np.array([[5, 6], [7, 8]])
h_stacked = np.hstack((arr1, arr2))  # [[1,2,5,6], [3,4,7,8]]
```

**vstack() - Vertical Stacking:** Concatenates arrays along axis 0 (rows):

```python
v_stacked = np.vstack((arr1, arr2))  # [[1,2], [3,4], [5,6], [7,8]]
```

**dstack() - Depth Stacking:** Concatenates arrays along axis 2 (depth):

```python
d_stacked = np.dstack((arr1, arr2))  # Shape: (2, 2, 2)
```

**stack() Function:** Creates new axis for stacking:

```python
arr1 = np.array([1, 2, 3])
arr2 = np.array([4, 5, 6])

# Stack along new axis 0
stacked_0 = np.stack((arr1, arr2), axis=0)  # [[1,2,3], [4,5,6]]

# Stack along new axis 1
stacked_1 = np.stack((arr1, arr2), axis=1)  # [[1,4], [2,5], [3,6]]
```

**column_stack() and row_stack():** Specialized stacking for 1D arrays:

```python
arr1 = np.array([1, 2, 3])
arr2 = np.array([4, 5, 6])

col_stacked = np.column_stack((arr1, arr2))  # [[1,4], [2,5], [3,6]]
row_stacked = np.row_stack((arr1, arr2))     # [[1,2,3], [4,5,6]]
```

