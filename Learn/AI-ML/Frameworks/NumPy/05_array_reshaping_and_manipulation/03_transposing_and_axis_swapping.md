## Transposing and Axis Swapping


Transposition operations reorder array dimensions and are essential for linear algebra and data alignment.

**Basic Transposition:**

```python
arr = np.array([[1, 2, 3], [4, 5, 6]])
transposed = arr.T  # Property access
transposed_method = arr.transpose()  # Method call
transposed_func = np.transpose(arr)  # Function call
```

**Advanced Transpose with Axis Specification:**

```python
arr_3d = np.arange(24).reshape(2, 3, 4)
# Original shape: (2, 3, 4)

# Specify axis order
reordered = arr_3d.transpose(2, 0, 1)  # Shape becomes (4, 2, 3)
reordered_2 = arr_3d.transpose((1, 2, 0))  # Shape becomes (3, 4, 2)
```

**swapaxes() Method:** Swaps two specific axes:

```python
arr_3d = np.arange(24).reshape(2, 3, 4)
swapped = arr_3d.swapaxes(0, 2)  # Swap first and third axes
# Original: (2, 3, 4) → Result: (4, 3, 2)
```

**moveaxis() Function:** Moves axes from source to destination positions:

```python
moved = np.moveaxis(arr_3d, 0, -1)  # Move first axis to last position
moved_multiple = np.moveaxis(arr_3d, [0, 1], [2, 0])  # Move multiple axes
```

