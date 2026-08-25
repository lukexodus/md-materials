## Structuring Features and Labels from Raw Data

### Conceptual Overview

Structuring raw data into features (inputs, conventionally $X$) and labels (targets, conventionally $y$) is the step that converts a dataset from its collected or stored form into the shape required by a machine learning algorithm's training interface. This involves selecting which columns represent predictive signal versus which represent the outcome to be predicted, transforming raw fields into a numeric/tabular form models can consume, and ensuring the resulting arrays are aligned row-for-row between $X$ and $y$.

### Basic Feature/Label Split

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    'age': [25, 32, 47, 51, 62],
    'income': [40000, 52000, 61000, 58000, 72000],
    'purchased': [0, 0, 1, 1, 1]
})

X = df.drop(columns=['purchased'])
y = df['purchased']
print(X)
print(y)
```

**Output**

```
   age  income
0   25   40000
1   32   52000
2   47   61000
3   51   58000
4   62   72000

0    0
1    0
2    1
3    1
4    1
Name: purchased, dtype: int64
```

`X` retains all columns except the designated label column; `y` is extracted as a separate one-dimensional structure (a Pandas `Series`). Row alignment between `X` and `y` is preserved automatically here because both are derived from the same original `DataFrame` without any intervening row-order changes.

### Converting to NumPy Arrays

Many ML libraries (particularly lower-level ones, or certain estimator internals) expect NumPy arrays rather than Pandas objects.

```python
X_array = X.to_numpy()
y_array = y.to_numpy()
print(X_array)
print(y_array)
print(type(X_array), X_array.dtype)
```

**Output**

```
[[   25 40000]
 [   32 52000]
 [   47 61000]
 [   51 58000]
 [   62 72000]]
[0 0 1 1 1]
<class 'numpy.ndarray'> int64
```

`.to_numpy()` produces a plain array stripped of column names and index labels. [Inference] Whether downstream code requires the Pandas wrapper (for column-name-based operations) or the plain array (for raw numeric operations) depends on the specific library and pipeline stage being used, which is not something fixed by Pandas/NumPy themselves.

### Selecting Features by Type or Name

```python
df2 = pd.DataFrame({
    'age': [25, 32, 47],
    'income': [40000, 52000, 61000],
    'city': ['Manila', 'Cebu', 'Davao'],
    'purchased': [0, 1, 1]
})

numeric_features = df2.select_dtypes(include=[np.number]).drop(columns=['purchased'])
categorical_features = df2.select_dtypes(include=['object'])
print(numeric_features)
print(categorical_features)
```

**Output**

```
   age  income
0   25   40000
1   32   52000
2   47   61000

     city
0  Manila
1    Cebu
2   Davao
```

`select_dtypes()` allows programmatic separation of columns by data type, which is useful when a pipeline must apply different preprocessing (e.g., scaling for numeric columns, encoding for categorical columns) before recombining them into a final feature matrix.

### Encoding Categorical Labels

Labels are not always already numeric. Classification targets stored as strings must generally be encoded before most algorithms can consume them.

```python
df3 = pd.DataFrame({
    'age': [25, 32, 47, 51],
    'outcome': ['no', 'no', 'yes', 'yes']
})

df3['outcome_encoded'] = df3['outcome'].map({'no': 0, 'yes': 1})
print(df3)
```

**Output**

```
   age outcome  outcome_encoded
0   25      no                0
1   32      no                0
2   47     yes                1
3   51     yes                1
```

`.map()` with an explicit dictionary gives direct control over the encoding scheme. For labels with more than two categories, `pandas.factorize()` or `sklearn.preprocessing.LabelEncoder` are common alternatives; I cannot verify which is preferable for any specific downstream library without knowing the exact pipeline being used, since this depends on the library's expected input format. [Unverified]

### One-Hot Encoding Categorical Features

```python
df4 = pd.DataFrame({
    'age': [25, 32, 47],
    'city': ['Manila', 'Cebu', 'Manila']
})

X_encoded = pd.get_dummies(df4, columns=['city'])
print(X_encoded)
```

**Output**

```
   age  city_Cebu  city_Manila
0   25      False        True
1   32       True       False
2   47      False        True
```

`pd.get_dummies()` expands a categorical column into multiple binary indicator columns. [Inference] The resulting boolean dtype display (`True`/`False` rather than `0`/`1`) reflects a Pandas version-dependent default; I cannot verify the exact dtype behavior across all Pandas versions without checking the specific version in use, since `get_dummies` output dtype conventions have changed across releases.

### Row Alignment Risks When Building X and y Separately

A common structural error arises when $X$ and $y$ are constructed through different filtering, sorting, or indexing operations, causing their row order to diverge silently.

```python
df5 = pd.DataFrame({
    'id': [1, 2, 3, 4],
    'feature': [10, 20, 30, 40],
    'label': [0, 1, 0, 1]
})

X5 = df5[['feature']].sort_values('feature', ascending=False)
y5 = df5['label']  # NOT re-sorted to match X5

print(X5)
print(y5)
```

**Output**

```
   feature
3       40
2       30
1       20
0       10

0    0
1    1
2    0
3    1
Name: label, dtype: int64
```

Here `X5` has been reordered by sorting, but `y5` retains the original row order — the index values (`3, 2, 1, 0` versus `0, 1, 2, 3`) no longer correspond to the same underlying records if the two are later converted to plain NumPy arrays and combined positionally. This is a structural bug: it does not raise an error but silently mismatches features to the wrong labels.

**Key Points**

- Always derive $X$ and $y$ from operations that preserve the same row index, or explicitly reindex one to match the other before converting to NumPy arrays.
- If using Pandas objects (not NumPy arrays) throughout a pipeline, index-based alignment can catch some — but not all — mismatches, since operations like `.to_numpy()` strip the index entirely and rely purely on positional order afterward.
- [Inference] This category of error is a known general risk pattern in tabular ML pipelines based on how positional versus index-based alignment works in Pandas; I cannot verify how any specific downstream library or user pipeline would behave when given misaligned arrays, since that depends on code not shown here.

### Correct Alignment Pattern

```python
df5_sorted = df5.sort_values('feature', ascending=False)
X5_correct = df5_sorted[['feature']]
y5_correct = df5_sorted['label']

print(X5_correct)
print(y5_correct)
```

**Output**

```
   feature
3       40
2       30
1       20
0       10

3    1
2    0
1    1
0    0
Name: label, dtype: int64
```

Sorting the full `DataFrame` first, then splitting into $X$ and $y$ from the already-sorted result, guarantees that row correspondence is preserved regardless of subsequent row-order changes.

### Structuring Labels for Time-Aware Splits

For time series or otherwise ordered data, labels are frequently derived from a future value in the same series (see lead features), which means the feature/label split must also account for the resulting boundary `NaN`s.

```python
ts = pd.DataFrame({
    'day': pd.date_range('2024-01-01', periods=5),
    'value': [10, 12, 15, 14, 18]
})
ts['target'] = ts['value'].shift(-1)

ts_clean = ts.dropna(subset=['target'])
X_ts = ts_clean[['value']]
y_ts = ts_clean['target']
print(X_ts)
print(y_ts)
```

**Output**

```
   value
0     10
1     12
2     15
3     14

0    12.0
1    15.0
2    14.0
3    18.0
Name: target, dtype: float64
```

Dropping rows with a missing target (via `dropna(subset=['target'])`) after constructing the lead-based label column ensures $X$ and $y$ remain the same length and correspond row-for-row, at the cost of losing the final observation, which has no known future value to serve as its label.

### Diagram: Raw Data to Feature/Label Structure

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 300" font-family="sans-serif">
  <text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Raw Data to Aligned Feature/Label Structure (svg_diagram)</text>

  <rect x="40" y="60" width="180" height="100" fill="#EDEDED" stroke="#888" stroke-width="1.5" rx="4" />
  <text x="130" y="55" text-anchor="middle" font-size="12" fill="#333">Raw DataFrame</text>
  <text x="60" y="85" font-size="11" fill="#333">id, feature_a,</text>
  <text x="60" y="100" font-size="11" fill="#333">feature_b, target</text>
  <text x="60" y="120" font-size="11" fill="#333">(unaligned risk if</text>
  <text x="60" y="135" font-size="11" fill="#333">split separately)</text>

  <line x1="220" y1="110" x2="300" y2="110" stroke="#888" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="300" y="60" width="180" height="45" fill="#4C72B0" opacity="0.15" stroke="#4C72B0" stroke-width="1.5" rx="4" />
  <text x="390" y="80" text-anchor="middle" font-size="12" fill="#4C72B0" font-weight="bold">X (features)</text>
  <text x="390" y="96" text-anchor="middle" font-size="11" fill="#333">same row index preserved</text>

  <rect x="300" y="115" width="180" height="45" fill="#C44E52" opacity="0.15" stroke="#C44E52" stroke-width="1.5" rx="4" />
  <text x="390" y="135" text-anchor="middle" font-size="12" fill="#C44E52" font-weight="bold">y (labels)</text>
  <text x="390" y="151" text-anchor="middle" font-size="11" fill="#333">same row index preserved</text>

  <line x1="480" y1="110" x2="560" y2="110" stroke="#888" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="560" y="80" width="130" height="60" fill="#55A868" opacity="0.15" stroke="#55A868" stroke-width="1.5" rx="4" />
  <text x="625" y="105" text-anchor="middle" font-size="12" fill="#55A868" font-weight="bold">Model-ready</text>
  <text x="625" y="122" text-anchor="middle" font-size="11" fill="#333">arrays (aligned</text>
  <text x="625" y="137" text-anchor="middle" font-size="11" fill="#333">row-for-row)</text>

  <text x="40" y="210" font-size="12" fill="#333">Warning: splitting/sorting X and y independently after this point</text>
  <text x="40" y="228" font-size="12" fill="#333">risks silent row misalignment (see correct alignment pattern above).</text>
</svg>

### Practical Pitfalls Summary

- Splitting $X$ and $y$ from the raw `DataFrame` using different filtering, sorting, or dropping operations applied separately, rather than deriving both from the same already-processed `DataFrame`.
- Converting to NumPy arrays before verifying alignment, since `.to_numpy()` discards the index that could otherwise reveal a mismatch.
- Forgetting to drop or impute rows with missing labels (e.g., from lead-shifted targets) before fitting a model, since most estimators require $y$ to contain no missing values.
- Encoding categorical labels or features inconsistently between training and future/inference data (e.g., a category present in inference data but absent from the training-time mapping), which can produce `NaN`s or unmapped values downstream. [Inference] This is a general risk based on how dictionary-based `.map()` and similar encoding approaches behave when encountering unseen keys; I cannot verify how any specific downstream model or library would handle this without knowing the exact code involved.

**Note on this response:** All descriptions of NumPy/Pandas API behavior above (e.g., `.drop()`, `.to_numpy()`, `.map()`, `get_dummies()`, `.sort_values()`, `.dropna()`) reflect standard, documented library behavior and are not flagged as uncertain. Statements regarding version-specific dtype defaults, and any claims about behavior of code, libraries, or pipelines not shown in this conversation, are labeled [Inference] or [Unverified] per your stated preferences, since I do not have access to verify those specifics.