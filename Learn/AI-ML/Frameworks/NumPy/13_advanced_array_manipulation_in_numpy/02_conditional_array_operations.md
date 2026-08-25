## Conditional Array Operations


Conditional operations in NumPy transcend simple boolean indexing to encompass sophisticated logical operations, multi-condition filtering, and element-wise conditional transformations that enable complex data processing workflows.

The numpy.where function serves as the cornerstone of conditional operations, providing vectorized if-else logic that operates element-wise across entire arrays. This function accepts condition arrays and corresponding value arrays, enabling complex decision trees without explicit loops.

Multiple condition handling utilizes logical operators (&, |, ~) combined with proper parenthesization to create compound boolean expressions. These operations maintain vectorization while enabling sophisticated filtering criteria that can combine numerical comparisons, pattern matching, and custom logical functions.

The numpy.select function extends conditional operations to multiple conditions with corresponding choice arrays, functioning as a vectorized switch-case statement. This approach proves particularly valuable when dealing with categorical data or implementing complex business logic across large datasets.

Conditional assignment operations modify arrays in-place based on boolean conditions, providing memory-efficient alternatives to creating new arrays. These operations can utilize fancy indexing combined with conditional expressions to achieve targeted modifications.

**Example:**

```python
# Multi-condition filtering
data = np.random.randn(1000)
condition1 = data > 0
condition2 = np.abs(data) < 1.5
filtered = data[(condition1 & condition2)]

# Complex conditional assignment
result = np.where((data > 0) & (data < 1), data * 2, 
                  np.where(data < -1, 0, data))

# Multiple choice selection
conditions = [data < -1, (data >= -1) & (data < 1), data >= 1]
choices = [0, data * 0.5, data * 2]
processed = np.select(conditions, choices, default=data)
```

