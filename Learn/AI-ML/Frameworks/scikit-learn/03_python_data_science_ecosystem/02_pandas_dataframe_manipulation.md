## Pandas DataFrame manipulation


**DataFrame** represents two-dimensional labeled data structures with heterogeneous column types, built on top of NumPy arrays. The DataFrame provides database-like operations including joins, grouping, and pivoting, while maintaining integration with the broader scientific Python ecosystem.

**Data loading and inspection** supports multiple file formats including CSV, Excel, JSON, and SQL databases. The `read_csv()` function offers extensive customization for parsing options, data types, and missing value handling. Initial data exploration uses methods like `head()`, `info()`, `describe()`, and `value_counts()`.

**Key Points:**

- Labeled axes enable intuitive data access and alignment
- Heterogeneous columns support mixed data types
- Built-in missing data handling with NaN representation
- SQL-like operations for filtering, joining, and aggregating
- Time series functionality with DatetimeIndex

**Example:**

```python
import pandas as pd
import numpy as np

# Data creation and loading
df = pd.DataFrame({
    'A': np.random.randn(100),
    'B': np.random.choice(['X', 'Y', 'Z'], 100),
    'C': pd.date_range('2024-01-01', periods=100),
    'D': np.random.randint(1, 10, 100)
})

# Alternative loading
# df = pd.read_csv('data.csv', parse_dates=['date_column'])

# Basic inspection
print(df.head())
print(df.info())
print(df.describe())
print(df['B'].value_counts())
```

**Data cleaning and transformation** addresses common issues including missing values, duplicate records, and data type conversions. The `fillna()`, `dropna()`, and `interpolate()` methods handle missing data, while `astype()` and `pd.to_datetime()` manage type conversions. String operations through the `.str` accessor enable text processing within DataFrames.

**Filtering and selection** uses boolean indexing, label-based selection with `.loc[]`, and position-based selection with `.iloc[]`. Query operations support complex filtering conditions, while the `isin()` method enables membership testing. Multi-level indexing provides hierarchical data organization.

**Example:**

```python
# Data cleaning
df_clean = df.dropna()  # Remove missing values
df['A_filled'] = df['A'].fillna(df['A'].mean())  # Fill with mean
df['B_upper'] = df['B'].str.upper()  # String operations

# Filtering and selection
recent_data = df[df['C'] > '2024-06-01']
high_values = df.loc[df['A'] > 1, ['B', 'D']]
subset = df.iloc[:10, 1:3]  # Position-based selection

# Query operations
filtered = df.query('A > 0 and B == "X"')
category_subset = df[df['B'].isin(['X', 'Y'])]
```

**Grouping and aggregation** operations mirror SQL GROUP BY functionality, enabling split-apply-combine operations on categorical data. The `.groupby()` method creates GroupBy objects that support multiple aggregation functions simultaneously. Pivot tables provide cross-tabulation functionality for multidimensional data analysis.

**Example:**

```python
# GroupBy operations
grouped = df.groupby('B')
group_stats = grouped.agg({
    'A': ['mean', 'std', 'count'],
    'D': ['sum', 'max']
})

# Pivot tables
pivot = df.pivot_table(
    values='A', 
    index='B', 
    columns=df['C'].dt.month, 
    aggfunc=['mean', 'count']
)

# Time series resampling
df_ts = df.set_index('C')
monthly_avg = df_ts.resample('M')['A'].mean()
```

