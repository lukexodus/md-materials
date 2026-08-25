## Detecting and Handling Missing Data

### Overview

Pandas represents missing data primarily using `NaN` (from NumPy, for numeric and object columns), `None` (in object-dtype columns), `NaT` (for missing datetime values), and, for nullable extension dtypes introduced later in Pandas' development, a dedicated `pd.NA` value. Detecting and handling these consistently is a prerequisite for most downstream analysis and machine learning preprocessing.

### Why Missing Data Needs Special Handling

NumPy's `NaN` is a floating-point value defined by the IEEE 754 standard, and it has a specific, well-known property: `NaN != NaN` evaluates to `True`, and standard equality checks cannot be used to detect it.

```python
import numpy as np

print(np.nan == np.nan)  # False
```

This is why Pandas provides dedicated detection methods rather than relying on equality comparisons.

### Detecting Missing Values

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    "a": [1, 2, np.nan, 4],
    "b": ["x", None, "z", "w"]
})

df.isna()
df.isnull()
```

`isna()` and `isnull()` are exact aliases of each other — both exist for compatibility with different naming conventions (Pandas' own vs. R-influenced naming), and they behave identically.

```python
df.notna()
df.notnull()
```

These return the inverse boolean mask.

### Counting Missing Values

```python
df.isna().sum()          # missing count per column
df.isna().sum().sum()    # total missing values in the DataFrame
df.isna().mean()         # proportion missing per column
```

**Key Points**
- `isna().sum()` works because `True`/`False` are treated as `1`/`0` in numeric aggregation — a well-established property of Python's `bool` being a subclass of `int`, not specific to Pandas.
- `isna().mean()` gives the fraction of missing values directly, useful for a quick data-quality overview.

### Visualizing Missingness

```python
df.isna().sum().plot(kind="bar")
```

For a more structural view of *where* missingness co-occurs across columns, a heatmap of the boolean mask is a common approach:

```python
import matplotlib.pyplot as plt

plt.imshow(df.isna(), aspect="auto", cmap="viridis")
plt.xlabel("Columns")
plt.ylabel("Rows")
plt.show()
```

[Inference] Visual inspection of missingness patterns is commonly recommended before choosing an imputation strategy, since different missingness patterns (random vs. structured) often call for different handling approaches — this reflects standard data-preprocessing guidance found across statistics and ML literature generally, not a claim about any specific dataset.

### Dropping Missing Data

```python
df.dropna()                     # drop rows with any missing value
df.dropna(axis=1)               # drop columns with any missing value
df.dropna(how="all")            # drop only rows where ALL values are missing
df.dropna(thresh=2)             # keep rows with at least 2 non-missing values
df.dropna(subset=["a"])         # drop rows where column "a" is missing
```

**Key Points**
- `how="any"` is the default: a row (or column, with `axis=1`) is dropped if it contains at least one missing value.
- `thresh` specifies a minimum number of non-missing values required to keep the row/column, offering finer control than `how`.

Dropping rows discards information and reduces sample size; [Speculation] whether this is preferable to imputation for a specific dataset depends on how much data would be lost and why the values are missing in the first place — I don't have enough context about any particular dataset to state a general recommendation here.

### Filling Missing Data

```python
df.fillna(0)                              # fill with a constant
df.fillna({"a": 0, "b": "unknown"})       # different fill value per column
df.fillna(method="ffill")                 # forward fill
df.fillna(method="bfill")                 # backward fill
df["a"].fillna(df["a"].mean())            # fill with column mean
```

[Unverified] The exact current API for `method="ffill"`/`"bfill"` (whether passed via `fillna(method=...)` or the separate `ffill()`/`bfill()` methods) has changed across Pandas versions, and I do not have a confirmed, version-specific answer for which form is current or deprecated without checking documentation for a specific version.

Using the dedicated methods directly, which avoids this ambiguity:

```python
df.ffill()
df.bfill()
```

### Interpolation

For numeric data with a meaningful order (e.g., time series), interpolation estimates missing values based on surrounding data rather than a single fixed fill value:

```python
df["value"].interpolate(method="linear")
```

Other `method` options include `"polynomial"`, `"spline"`, and time-aware interpolation for datetime-indexed data (`method="time"`).

[Inference] Interpolation is commonly considered more appropriate than simple mean/mode filling for ordered data like time series, since it accounts for local trend rather than treating all missing values identically — this reflects a general statistical rationale for the technique, not a claim benchmarked on specific data here.

### Missing Data and Dtypes

A well-known Pandas/NumPy interaction: NumPy's classic integer dtypes cannot represent `NaN` (since `NaN` is inherently a float concept in IEEE 754), so a column that mixes integers and missing values is upcast to `float64`.

```python
s = pd.Series([1, 2, None])
print(s.dtype)  # float64
```

Pandas' nullable integer extension type (`Int64`, capital I) avoids this upcasting, using `pd.NA` instead of `NaN`:

```python
s = pd.Series([1, 2, None], dtype="Int64")
print(s.dtype)  # Int64
print(s)
```

**Key Points**
- `pd.NA` is designed to propagate consistently through boolean logic (`pd.NA | True` is `True`, `pd.NA | False` is `pd.NA`), differing from `NaN`'s behavior in some contexts.
- [Unverified] The complete list of operations and edge cases where `pd.NA` and `NaN` behave differently is not something I can state exhaustively here without checking documentation for a specific Pandas version.

### Missing Data in Machine Learning Preprocessing

Most scikit-learn estimators do not accept `NaN` values directly (with specific documented exceptions such as certain tree-based and histogram-gradient-boosting models). This makes explicit missing-data handling a required preprocessing step in the broader pipeline, not merely a data-cleaning convenience.

```python
from sklearn.impute import SimpleImputer

imputer = SimpleImputer(strategy="mean")
X_filled = imputer.fit_transform(df[["a"]])
```

[Unverified] The exact current list of scikit-learn estimators that natively support missing values depends on the installed scikit-learn version, and I do not have a confirmed, version-specific list to cite here.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| `df["col"] == np.nan` always returns `False` | Equality comparison cannot detect `NaN`; use `isna()` instead |
| Unexpected `float64` dtype on an integer column | Presence of missing values with classic (non-nullable) integer dtype |
| Silent data loss | `dropna()` called without checking how many rows/columns are actually removed |
| Imputing before train/test split | Can leak information from the test set into imputed training values, a widely documented data leakage concern in ML preprocessing |

### Diagram: Missing Data Handling Decision Path

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 300">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Missing Data Handling Options (svg_diagram)</text>

  <rect x="300" y="50" width="160" height="50" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="380" y="80" text-anchor="middle" font-size="12">Missing values detected</text>

  <line x1="380" y1="100" x2="150" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow6)" />
  <line x1="380" y1="100" x2="380" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow6)" />
  <line x1="380" y1="100" x2="610" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow6)" />

  <rect x="60" y="155" width="180" height="50" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="150" y="178" text-anchor="middle" font-size="11">Drop</text>
  <text x="150" y="195" text-anchor="middle" font-size="10">(dropna)</text>

  <rect x="290" y="155" width="180" height="50" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="380" y="178" text-anchor="middle" font-size="11">Fill / Impute</text>
  <text x="380" y="195" text-anchor="middle" font-size="10">(fillna, SimpleImputer)</text>

  <rect x="520" y="155" width="180" height="50" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="610" y="178" text-anchor="middle" font-size="11">Interpolate</text>
  <text x="610" y="195" text-anchor="middle" font-size="10">(ordered/time data)</text>

  <text x="150" y="230" text-anchor="middle" font-size="10" fill="#555">low missing %,</text>
  <text x="150" y="245" text-anchor="middle" font-size="10" fill="#555">random pattern</text>

  <text x="380" y="230" text-anchor="middle" font-size="10" fill="#555">need to preserve</text>
  <text x="380" y="245" text-anchor="middle" font-size="10" fill="#555">row count</text>

  <text x="610" y="230" text-anchor="middle" font-size="10" fill="#555">sequential/</text>
  <text x="610" y="245" text-anchor="middle" font-size="10" fill="#555">time-ordered data</text>

  </svg>

### Related Topics

- Missing Completely at Random (MCAR) vs. Missing at Random (MAR) vs. Missing Not at Random (MNAR) frameworks
- Multiple imputation techniques (`IterativeImputer` in scikit-learn)
- Handling missing data correctly within cross-validation pipelines
- Missing data in categorical columns and encoding strategies
- Time series-specific missing data handling (gaps, irregular sampling)
- Sentinel value pitfalls (e.g., `-999` or `"N/A"` strings not recognized as missing by default)