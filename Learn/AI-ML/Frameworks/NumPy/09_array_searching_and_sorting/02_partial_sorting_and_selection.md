## Partial Sorting and Selection


Partial sorting operations provide efficient solutions when only portions of sorted data are needed.

**partition() Function:** Partitions array around k-th element:

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])
k = 3
partitioned = np.partition(arr, k)
# Elements 0 to k-1 are smaller than element k
# Elements k+1 to end are larger than element k
# Element k is in its final sorted position
```

**argpartition() Function:** Returns indices that would partition the array:

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])
k = 3
partition_indices = np.argpartition(arr, k)
# arr[partition_indices] gives partitioned array
```

**Multi-dimensional Partitioning:**

```python
arr_2d = np.random.randint(0, 100, (5, 4))
# Partition along axis 1, k=2
partitioned_2d = np.partition(arr_2d, 2, axis=1)
```

**Finding k-th Smallest/Largest Elements:**

```python
arr = np.array([3, 1, 4, 1, 5, 9, 2, 6])

# 3rd smallest element (0-indexed)
kth_smallest = np.partition(arr, 2)[2]

# 3rd largest element
kth_largest = np.partition(arr, -3)[-3]

# Multiple k values
multiple_k = np.partition(arr, [1, 3, 5])
```

