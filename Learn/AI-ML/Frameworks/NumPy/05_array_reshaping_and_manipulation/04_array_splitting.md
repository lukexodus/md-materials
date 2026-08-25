## Array Splitting


Splitting operations divide arrays into smaller sub-arrays along specified axes.

**split() Function:** Divides array into equal-sized sub-arrays:

```python
arr = np.arange(12)
# Split into 3 equal parts
parts = np.split(arr, 3)  # [array([0,1,2,3]), array([4,5,6,7]), array([8,9,10,11])]

# 2D splitting
arr_2d = np.arange(12).reshape(4, 3)
row_split = np.split(arr_2d, 2, axis=0)  # Split along rows
col_split = np.split(arr_2d, 3, axis=1)  # Split along columns
```

**array_split() Function:** Handles uneven divisions:

```python
arr = np.arange(10)
uneven_split = np.array_split(arr, 3)  # Creates arrays of lengths [4, 3, 3]
```

**Specialized Splitting Functions:**

```python
arr_2d = np.arange(12).reshape(4, 3)

# Horizontal split (along axis 1)
h_split = np.hsplit(arr_2d, 3)  # Split into 3 columns

# Vertical split (along axis 0)  
v_split = np.vsplit(arr_2d, 2)  # Split into 2 rows

# Depth split for 3D arrays
arr_3d = np.arange(24).reshape(2, 3, 4)
d_split = np.dsplit(arr_3d, 2)  # Split along depth axis
```

**Advanced Splitting with Indices:**

```python
arr = np.arange(10)
# Split at specific indices
custom_split = np.split(arr, [3, 7])  # Creates 3 arrays: [0:3], [3:7], [7:]
```

