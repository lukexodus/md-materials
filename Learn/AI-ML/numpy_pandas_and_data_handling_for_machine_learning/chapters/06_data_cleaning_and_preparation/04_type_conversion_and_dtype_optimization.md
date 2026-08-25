## Type Conversion and Dtype Optimization

### Overview

Every column in a Pandas DataFrame has a dtype (data type) that determines how values are stored in memory and which operations are valid on them. Choosing appropriate dtypes — both for correctness and for memory efficiency — is a foundational step in preparing data for machine learning pipelines, where dataset size and numerical precision both matter.

### Inspecting Current Dtypes

```python
import pandas as pd

df.dtypes
df.info()
df.info(memory_usage="deep")
```

`dtypes` lists the dtype per column. `info()` adds row/column counts and non-null counts; `memory_usage="deep"` additionally introspects object-dtype columns (like strings) for their actual memory footprint, which the default shallow calculation does not capture accurately.

### NumPy's Numeric Dtype Hierarchy

Pandas' numeric dtypes are built directly on NumPy's dtype system:

| Dtype | Size | Range (approximate) |
|---|---|---|
| `int8` | 1 byte | -128 to 127 |
| `int16` | 2 bytes | -32,768 to 32,767 |
| `int32` | 4 bytes | ~-2.1B to 2.1B |
| `int64` | 8 bytes | ~-9.2 quintillion to 9.2 quintillion |
| `float32` | 4 bytes | ~7 decimal digits of precision |
| `float64` | 8 bytes | ~15-17 decimal digits of precision |

Smaller dtypes use less memory per value, but can only represent a narrower range or lower precision. Choosing a dtype too small for the actual data range causes silent overflow or precision loss rather than raising an error in most NumPy operations.

```python
import numpy as np
arr = np.array([200], dtype=np.int8)
print(arr)  # -56, due to overflow — int8 cannot represent 200
```

### Basic Type Conversion with `astype()`

```python
df["id"] = df["id"].astype("int32")
df["price"] = df["price"].astype("float32")
df["category"] = df["category"].astype("category")
df["is_active"] = df["is_active"].astype("bool")
```

**Key Points**
- `astype()` returns a new Series/DataFrame by default; it does not modify in place unless reassigned.
- Converting a column to a dtype that cannot represent all its actual values raises an error in some cases (e.g., converting a column containing `NaN` to a non-nullable integer type) or silently truncates/overflows in others (e.g., float-to-int truncation) — behavior differs by the specific conversion, so checking the result after conversion is a reasonable precaution.

```python
df["count"] = df["count"].astype("float").astype("int")  # truncates decimals
```

### Downcasting Numeric Types

Pandas provides `pd.to_numeric()` with a `downcast` argument to automatically select the smallest compatible numeric dtype:

```python
df["value"] = pd.to_numeric(df["value"], downcast="integer")
df["measurement"] = pd.to_numeric(df["measurement"], downcast="float")
```

This inspects the actual value range present in the column and selects the smallest dtype (e.g., `int8`, `int16`, `int32`) that can hold all observed values, rather than requiring the dtype to be specified manually.

[Inference] Using `downcast` is generally more convenient than manually inspecting min/max values and choosing a dtype by hand, since it automates that inspection — this follows directly from what the parameter is documented to do, though the actual memory savings depend on the data's value distribution.

### Converting to Nullable/Extension Dtypes

Classic NumPy-backed dtypes can't represent missing values for integers and booleans. Pandas' nullable extension types address this:

```python
df["count"] = df["count"].astype("Int64")     # nullable integer (capital I)
df["flag"] = df["flag"].astype("boolean")     # nullable boolean
```

**Key Points**
- The capitalization distinction matters: `int64` (lowercase, NumPy-backed, no `NaN` support) versus `Int64` (capitalized, Pandas extension type, supports `pd.NA`).
- [Unverified] Full operational parity between nullable extension types and their classic NumPy counterparts — for example, in third-party library compatibility or specific numerical operations — is not something I can confirm comprehensively without checking documentation for the specific Pandas and library versions in use.

### Categorical Dtype for Memory and Semantics

```python
df["status"] = df["status"].astype("category")
```

Converting a column with a limited number of repeated string values to `category` stores each unique value once, along with integer codes referencing them, rather than repeating the full string for every row.

```python
df["status"].cat.categories
df["status"].cat.codes
```

**Key Points**
- Memory reduction from `category` conversion depends heavily on cardinality (number of unique values) relative to row count — a column with mostly unique values gains little or nothing, while a column with few repeated values can see substantial reduction. [Inference] This relationship follows directly from how the encoding works internally (fixed storage per unique value plus small integer codes per row), but the exact numeric reduction for any given column depends on its specific cardinality and string lengths, which I have not measured here.
- `category` dtype also enables ordered categorical semantics for ordinal data:

```python
df["size"] = pd.Categorical(
    df["size"],
    categories=["Small", "Medium", "Large"],
    ordered=True
)
df["size"] < "Large"  # valid ordinal comparison
```

### Datetime Conversion

```python
df["date"] = pd.to_datetime(df["date"])
df["date"] = pd.to_datetime(df["date"], format="%Y-%m-%d")
```

Specifying `format` explicitly avoids Pandas' automatic format inference, which can be ambiguous or slow on large columns with inconsistent date string formats.

```python
df["date"] = pd.to_datetime(df["date"], errors="coerce")
```

`errors="coerce"` converts unparseable values to `NaT` instead of raising an exception, which is useful for handling messy real-world date columns, at the cost of silently losing information about which values failed to parse unless checked separately.

### String/Object to Numeric Conversion

```python
df["price"] = pd.to_numeric(df["price"], errors="coerce")
```

This handles columns that are stored as `object` dtype (often because they contain non-numeric strings mixed with numeric-looking values) by attempting numeric conversion and marking failures as `NaN`.

**Key Points**
- Checking for newly introduced `NaN` values after this kind of coercion is a reasonable precaution, since it reveals which original values could not be parsed:

```python
failed_mask = df["price"].isna() & original_price.notna()
```

### Measuring Memory Impact

```python
before = df.memory_usage(deep=True).sum()

df["category_col"] = df["category_col"].astype("category")
df["id"] = pd.to_numeric(df["id"], downcast="integer")

after = df.memory_usage(deep=True).sum()
print(f"Reduced from {before} to {after} bytes")
```

Measuring before and after directly, as shown here, is more reliable than assuming a specific percentage reduction, since actual savings depend entirely on the specific dataset's cardinality, value ranges, and column composition.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| Silent overflow | Downcasting to a dtype too narrow for the actual value range without checking bounds first |
| `ValueError` on `astype("int")` | Column contains `NaN`, which classic integer dtypes cannot represent |
| Precision loss | Converting `float64` to `float32` for values requiring more than ~7 significant digits of precision |
| Unexpected `object` dtype persisting | Mixed types remaining in a column after a coercion step that used `errors="coerce"`, leaving some values as `NaN` rather than fully converting |

### Diagram: Dtype Optimization Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Dtype Optimization Decision Flow (svg_diagram)</text>

  <rect x="300" y="45" width="160" height="45" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="380" y="72" text-anchor="middle" font-size="11">Inspect df.dtypes</text>

  <line x1="330" y1="90" x2="150" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow9)" />
  <line x1="380" y1="90" x2="380" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow9)" />
  <line x1="430" y1="90" x2="610" y2="130" stroke="#333" stroke-width="1.5" marker-end="url(#arrow9)" />

  <rect x="60" y="135" width="180" height="45" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="150" y="155" text-anchor="middle" font-size="11">Numeric column,</text>
  <text x="150" y="170" text-anchor="middle" font-size="10">narrow range → downcast</text>

  <rect x="290" y="135" width="180" height="45" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="380" y="155" text-anchor="middle" font-size="11">Repeated strings →</text>
  <text x="380" y="170" text-anchor="middle" font-size="10">category dtype</text>

  <rect x="520" y="135" width="180" height="45" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="610" y="155" text-anchor="middle" font-size="11">Date strings →</text>
  <text x="610" y="170" text-anchor="middle" font-size="10">pd.to_datetime</text>

  <line x1="150" y1="180" x2="150" y2="210" stroke="#333" stroke-width="1" marker-end="url(#arrow9)" />
  <line x1="380" y1="180" x2="380" y2="210" stroke="#333" stroke-width="1" marker-end="url(#arrow9)" />
  <line x1="610" y1="180" x2="610" y2="210" stroke="#333" stroke-width="1" marker-end="url(#arrow9)" />
  <text x="380" y="225" text-anchor="middle" font-size="10" fill="#555">Measure memory_usage(deep=True) before/after</text>

  </svg>

### Related Topics

- PyArrow-backed dtypes in Pandas 2.x as an alternative to NumPy-backed storage
- Sparse dtypes for columns with many repeated/zero values
- Dtype considerations when feeding data into scikit-learn vs. deep learning frameworks (e.g., float32 preference for GPU training)
- Schema enforcement strategies to maintain consistent dtypes across pipeline runs
- Memory profiling tools beyond `memory_usage()` for full pipeline analysis
- Dtype implications for Parquet/Feather round-trip fidelity