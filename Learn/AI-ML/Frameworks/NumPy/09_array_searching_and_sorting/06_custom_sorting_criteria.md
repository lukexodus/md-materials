## Custom Sorting Criteria


Custom sorting enables sorting by user-defined criteria and complex data structures.

**Structured Array Sorting:**

```python
# Create structured array
dtype = [('name', 'U10'), ('age', 'i4'), ('score', 'f4')]
data = np.array([('Alice', 25, 95.5), 
                 ('Bob', 30, 87.2), 
                 ('Charlie', 22, 92.1)], dtype=dtype)

# Sort by single field
sorted_by_age = np.sort(data, order='age')

# Sort by multiple fields
sorted_multi = np.sort(data, order=['score', 'age'])
```

**Custom Comparison Functions:** [Inference] NumPy's sorting functions don't directly support custom comparison functions like Python's sorted(), but custom sorting can be achieved through indirect methods:

```python
# Custom sorting using argsort with key function simulation
arr = np.array(['apple', 'Banana', 'cherry', 'Date'])

# Sort by string length
lengths = np.array([len(s) for s in arr])
length_indices = np.argsort(lengths)
sorted_by_length = arr[length_indices]

# Sort case-insensitive
lower_arr = np.array([s.lower() for s in arr])
case_indices = np.argsort(lower_arr)
case_insensitive = arr[case_indices]
```

**Complex Sorting Scenarios:**

```python
# Sorting 2D array by specific column
data = np.array([[3, 2, 1], 
                 [1, 4, 2], 
                 [2, 1, 3]])

# Sort rows by second column
col_indices = np.argsort(data[:, 1])
sorted_by_col = data[col_indices]

# Sort by custom criteria (e.g., sum of elements)
row_sums = np.sum(data, axis=1)
sum_indices = np.argsort(row_sums)
sorted_by_sum = data[sum_indices]
```

**Performance Optimization:**

```python
# For large arrays, consider algorithm choice
large_arr = np.random.randint(0, 1000000, 100000)

# Quicksort: fastest average case
quick_indices = np.argsort(large_arr, kind='quicksort')

# Mergesort: stable, guaranteed O(n log n)
merge_indices = np.argsort(large_arr, kind='mergesort')

# For partially sorted data, Timsort is often optimal
tim_indices = np.argsort(large_arr, kind='stable')
```

**Key Points:**

- sort() modifies arrays in-place while np.sort() returns copies
- Algorithm selection affects performance: quicksort for speed, mergesort for stability
- partition() provides O(n) performance for finding k-th elements
- searchsorted() enables efficient binary search in sorted arrays
- Set operations handle duplicate removal and mathematical set algebra
- argsort() enables indirect sorting and complex sorting criteria
- Custom sorting requires creative use of argsort() with computed keys

**Examples:**

```python
# Complex real-world example: sorting students by GPA, then by name
students = np.array([('Alice', 3.8), ('Bob', 3.5), ('Charlie', 3.8), ('David', 3.9)],
                   dtype=[('name', 'U10'), ('gpa', 'f4')])

# Multi-criteria sort: GPA descending, then name ascending
gpa_desc = -students['gpa']  # Negative for descending
indices = np.lexsort((students['name'], gpa_desc))
sorted_students = students[indices]
```

**Output:** Efficient searching and sorting operations enable rapid data analysis, preprocessing, and algorithm implementation with optimized performance characteristics suitable for large-scale scientific computing applications.

**Related Subtopics:** Advanced topics include parallel sorting algorithms, external sorting for datasets larger than memory, specialized sorting for different data types, performance profiling of sorting operations, and integration with pandas for labeled data sorting.

---

