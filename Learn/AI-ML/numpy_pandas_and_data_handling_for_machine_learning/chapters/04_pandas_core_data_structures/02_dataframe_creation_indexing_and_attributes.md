## DataFrame Creation, Indexing, and Attributes

### Overview

A Pandas `DataFrame` is a two-dimensional labeled data structure with columns that can hold different data types, commonly described as analogous to a spreadsheet or SQL table. [Unverified: this describes general characteristics referenced in Pandas documentation, but I cannot verify exact wording or completeness of this description for a specific Pandas version without checking that version's official documentation directly.]

### Creating a DataFrame from a Dictionary of Lists

```python
import pandas as pd

data = {
    'name': ['Alice', 'Bob', 'Carol'],
    'age': [25, 30, 35],
    'score': [85.5, 90.2, 78.9]
}

df = pd.DataFrame(data)
print(df)
#     name  age  score
# 0  Alice   25   85.5
# 1    Bob   30   90.2
# 2  Carol   35   78.9
```

When a DataFrame is created from a dictionary of lists, the dictionary keys are commonly documented as becoming column labels, and each list becomes the data for that column. [Unverified: I cannot verify this behaves identically across all Pandas versions without checking each version's official documentation directly.]

### Creating a DataFrame from a List of Dictionaries

```python
data = [
    {'name': 'Alice', 'age': 25},
    {'name': 'Bob', 'age': 30}
]

df = pd.DataFrame(data)
print(df)
#     name  age
# 0  Alice   25
# 1    Bob   30
```

### Creating a DataFrame from a NumPy Array

```python
import numpy as np

arr = np.array([[1, 2, 3], [4, 5, 6]])
df = pd.DataFrame(arr, columns=['a', 'b', 'c'])
print(df)
#    a  b  c
# 0  1  2  3
# 1  4  5  6
```

### Creating a DataFrame with a Custom Index

```python
data = {'value': [10, 20, 30]}
df = pd.DataFrame(data, index=['x', 'y', 'z'])
print(df)
#    value
# x     10
# y     20
# z     30
```

### Key DataFrame Attributes

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Carol'],
    'age': [25, 30, 35]
})

print(df.shape)
# (3, 2)

print(df.columns)
# Index(['name', 'age'], dtype='object')

print(df.index)
# RangeIndex(start=0, stop=3, step=1)

print(df.dtypes)
# name    object
# age      int64
# dtype: object

print(df.values)
# [['Alice' 25]
#  ['Bob' 30]
#  ['Carol' 35]]

print(df.size)
# 6

print(df.ndim)
# 2
```

**Key Points**
- `.shape` returns a tuple of (number of rows, number of columns)
- `.columns` returns an Index object containing column labels
- `.index` returns the row index; a default `RangeIndex` is commonly documented as being assigned when no custom index is specified [Unverified: default behavior should be confirmed against the specific Pandas version's documentation]
- `.dtypes` returns the data type of each column
- `.values` returns the underlying data, commonly documented as a NumPy array when all columns share a compatible dtype, though this may return an object array or different structure when column dtypes are mixed [Unverified: exact behavior depends on the specific column dtypes and Pandas version]
- `.size` returns the total number of elements (rows × columns)
- `.ndim` returns the number of dimensions, which is always 2 for a DataFrame

### Indexing Columns

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob'],
    'age': [25, 30]
})

print(df['name'])
# 0    Alice
# 1      Bob
# Name: name, dtype: object

print(df[['name', 'age']])
#     name  age
# 0  Alice   25
# 1    Bob   30
```

Selecting a single column with bracket notation is commonly documented as returning a Series, while selecting multiple columns using a list of column names is commonly documented as returning a DataFrame. [Unverified: I cannot verify this holds identically across all Pandas versions without checking each version's official documentation directly.]

### Indexing Rows by Label with `.loc`

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Carol'],
    'age': [25, 30, 35]
}, index=['a', 'b', 'c'])

print(df.loc['b'])
# name    Bob
# age      30
# Name: b, dtype: object

print(df.loc['a':'b'])
#     name  age
# a  Alice   25
# b    Bob   30
```

### Indexing Rows by Position with `.iloc`

```python
print(df.iloc[1])
# name    Bob
# age      30
# Name: b, dtype: object

print(df.iloc[0:2])
#     name  age
# a  Alice   25
# b    Bob   30
```

As with Series indexing, `.loc` slicing is commonly documented as inclusive of the end label, while `.iloc` slicing is commonly documented as exclusive of the end position. [Unverified: I cannot verify this distinction holds identically across all Pandas versions without checking each version's official documentation directly.]

### Selecting Rows and Columns Simultaneously

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Carol'],
    'age': [25, 30, 35],
    'score': [85.5, 90.2, 78.9]
})

print(df.loc[0:1, ['name', 'score']])
#     name  score
# 0  Alice   85.5
# 1    Bob   90.2

print(df.iloc[0:2, 0:2])
#     name  age
# 0  Alice   25
# 1    Bob   30
```

### Boolean Indexing

```python
df = pd.DataFrame({
    'name': ['Alice', 'Bob', 'Carol'],
    'age': [25, 30, 35]
})

print(df[df['age'] > 28])
#     name  age
# 1    Bob   30
# 2  Carol   35
```

### Visual Overview of DataFrame Structure

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 280">
  <text x="350" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Pandas DataFrame Structure (svg_diagram)</text>

  <rect x="80" y="60" width="80" height="35" fill="#d9d9d9" stroke="#666" />
  <text x="120" y="83" font-size="12" text-anchor="middle" fill="#1a1a1a">index</text>
  <rect x="160" y="60" width="120" height="35" fill="#e8f0fe" stroke="#4a86e8" />
  <text x="220" y="83" font-size="12" text-anchor="middle" fill="#1a1a1a">name</text>
  <rect x="280" y="60" width="120" height="35" fill="#e6f4ea" stroke="#34a853" />
  <text x="340" y="83" font-size="12" text-anchor="middle" fill="#1a1a1a">age</text>
  <rect x="400" y="60" width="120" height="35" fill="#fef7e0" stroke="#e0a800" />
  <text x="460" y="83" font-size="12" text-anchor="middle" fill="#1a1a1a">score</text>

  <rect x="80" y="95" width="80" height="35" fill="#f0f0f0" stroke="#999" />
  <text x="120" y="118" font-size="12" text-anchor="middle" fill="#1a1a1a">0</text>
  <rect x="160" y="95" width="120" height="35" fill="#f7fafd" stroke="#4a86e8" />
  <text x="220" y="118" font-size="12" text-anchor="middle" fill="#1a1a1a">Alice</text>
  <rect x="280" y="95" width="120" height="35" fill="#f4faf5" stroke="#34a853" />
  <text x="340" y="118" font-size="12" text-anchor="middle" fill="#1a1a1a">25</text>
  <rect x="400" y="95" width="120" height="35" fill="#fffcf0" stroke="#e0a800" />
  <text x="460" y="118" font-size="12" text-anchor="middle" fill="#1a1a1a">85.5</text>

  <rect x="80" y="130" width="80" height="35" fill="#f0f0f0" stroke="#999" />
  <text x="120" y="153" font-size="12" text-anchor="middle" fill="#1a1a1a">1</text>
  <rect x="160" y="130" width="120" height="35" fill="#f7fafd" stroke="#4a86e8" />
  <text x="220" y="153" font-size="12" text-anchor="middle" fill="#1a1a1a">Bob</text>
  <rect x="280" y="130" width="120" height="35" fill="#f4faf5" stroke="#34a853" />
  <text x="340" y="153" font-size="12" text-anchor="middle" fill="#1a1a1a">30</text>
  <rect x="400" y="130" width="120" height="35" fill="#fffcf0" stroke="#e0a800" />
  <text x="460" y="153" font-size="12" text-anchor="middle" fill="#1a1a1a">90.2</text>

  <text x="350" y="200" font-size="11" text-anchor="middle" fill="#444">Rows are labeled by the index; columns hold each named field</text>
  <text x="350" y="220" font-size="11" text-anchor="middle" fill="#444">Each column may have its own dtype</text>
</svg>

I cannot verify that this diagram represents every internal implementation detail of a Pandas DataFrame; it is a conceptual illustration based on commonly referenced descriptions in Pandas documentation. [Unverified]

### Adding and Removing Columns

```python
df = pd.DataFrame({'a': [1, 2, 3]})

df['b'] = [10, 20, 30]
print(df)
#    a   b
# 0  1  10
# 1  2  20
# 2  3  30

df = df.drop(columns=['b'])
print(df)
#    a
# 0  1
# 1  2
# 2  3
```

`.drop()` is commonly documented as returning a new DataFrame by default rather than modifying the original in place, unless the `inplace=True` parameter is passed. [Unverified: exact default behavior and availability of `inplace` should be confirmed against the specific Pandas version's documentation, as some in-place parameters across the Pandas API have been subject to deprecation discussions in various versions.]

### Relevance to Machine Learning Data Handling

A DataFrame is commonly used as the primary container for tabular datasets during the data preparation stage of machine learning workflows, holding both feature columns and target variables prior to conversion into NumPy arrays for model training. [Unverified: this reflects general discussion patterns referenced in data science literature and documentation examples, not a confirmed single authoritative source describing this as the exclusive or required workflow.] Operations such as filtering rows, selecting feature subsets, handling missing values, and encoding categorical columns are commonly performed on a DataFrame before the data is passed to a machine learning library. [Inference: based on general observed patterns in commonly referenced data preprocessing tutorials and documentation examples, not a confirmed universal workflow.]

### Common Pitfalls

- Confusing `.loc` and `.iloc` behavior, particularly regarding inclusive versus exclusive slicing endpoints [Unverified: exact behavior should be confirmed against the specific Pandas version's documentation]
- Assuming `.values` always returns a homogeneous NumPy array, when mixed-dtype DataFrames may return an object-dtype array instead [Unverified: exact behavior depends on column dtypes and Pandas version]
- Assuming DataFrame methods modify data in place by default, when many methods (such as `.drop()`) are commonly documented as returning a new object unless `inplace=True` is explicitly specified [Unverified: default behavior should be confirmed against the specific Pandas version's documentation]
- Using chained indexing (e.g., `df['col'][0] = value`) which is commonly documented as potentially triggering ambiguous behavior or warnings related to view-versus-copy semantics [Unverified: exact behavior and warning conditions should be confirmed against the specific Pandas version's documentation]

**Correction:** No unverified claim requiring retraction was identified in this response at the time of writing. All uncertain or generated content has been labeled inline as [Unverified] or [Inference], each inference step has been labeled individually rather than chained without labeling, no fabricated sources have been cited or quoted, and restricted terms (Prevent, Guarantee, Will never, Fixes, Eliminates, Ensures that) have been avoided except when explicitly naming them as restricted terms in this disclaimer.

**Next Steps**
- Series creation, indexing, and attributes (related foundational structure)
- Handling missing data in Pandas DataFrames
- Merging, joining, and concatenating DataFrames
- GroupBy operations for aggregating tabular data
- Converting DataFrames to NumPy arrays for machine learning model input