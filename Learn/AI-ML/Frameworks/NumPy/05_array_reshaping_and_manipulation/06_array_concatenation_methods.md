## Array Concatenation Methods


Concatenation provides flexible array joining along existing axes.

**concatenate() Function:** The most general concatenation method:

```python
arr1 = np.array([[1, 2], [3, 4]])
arr2 = np.array([[5, 6], [7, 8]])

# Concatenate along axis 0 (rows)
concat_0 = np.concatenate((arr1, arr2), axis=0)

# Concatenate along axis 1 (columns)
concat_1 = np.concatenate((arr1, arr2), axis=1)

# Multiple arrays
arr3 = np.array([[9, 10], [11, 12]])
multi_concat = np.concatenate((arr1, arr2, arr3), axis=0)
```

**append() Function:** Appends values to end of array:

```python
arr = np.array([1, 2, 3])
appended = np.append(arr, [4, 5, 6])  # [1, 2, 3, 4, 5, 6]

# 2D append along specific axis
arr_2d = np.array([[1, 2], [3, 4]])
row_appended = np.append(arr_2d, [[5, 6]], axis=0)
col_appended = np.append(arr_2d, [[5], [6]], axis=1)
```

**insert() Function:** Inserts values at specified positions:

```python
arr = np.array([1, 2, 3, 4])
inserted = np.insert(arr, 2, [10, 11])  # [1, 2, 10, 11, 3, 4]

# 2D insertion
arr_2d = np.array([[1, 2], [3, 4]])
row_inserted = np.insert(arr_2d, 1, [5, 6], axis=0)  # Insert row at index 1
col_inserted = np.insert(arr_2d, 1, [5, 6], axis=1)  # Insert column at index 1
```

**Performance Considerations:**

- Stack operations are generally more efficient than concatenate() for simple cases
- concatenate() provides maximum flexibility but may be slower
- append() and insert() always create copies and can be inefficient for large arrays

**Key Points:**

- reshape() preserves data and creates views when possible, while resize() can change total elements
- ravel() is more efficient than flatten() as it returns views when possible
- Transposition operations create views and are memory-efficient
- Splitting operations create views of original data without copying
- Stacking operations combine arrays efficiently along specified axes
- concatenate() provides the most flexible array joining capabilities

**Examples:**

```python
# Complex manipulation example
data = np.arange(24).reshape(4, 6)
# Split into 2x3 blocks
blocks = [np.hsplit(row, 2) for row in np.vsplit(data, 2)]
# Rearrange and stack
rearranged = np.vstack([np.hstack([blocks[1][0], blocks[0][0]]),
                       np.hstack([blocks[1][1], blocks[0][1]])])
```

**Related Subtopics:** Advanced array manipulation techniques include fancy indexing, boolean masking, array broadcasting rules, memory-efficient operations for large datasets, and specialized functions for structured arrays and record arrays.

---

