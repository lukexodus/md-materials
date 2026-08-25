## Renaming, Reordering, and Restructuring Columns

### Overview

Column-level restructuring — renaming for clarity or consistency, reordering for readability or downstream tooling, and reshaping the overall column structure — is a routine but important part of preparing a DataFrame for analysis, reporting, or model input, where column names and order often carry both human-readability and programmatic significance.

### Renaming Columns

```python
import pandas as pd

df = pd.DataFrame({"Col A": [1, 2], "col_b": [3, 4], "ColumnC": [5, 6]})

df = df.rename(columns={"Col A": "col_a", "ColumnC": "column_c"})
```

`rename()` accepts a dictionary mapping old names to new ones, and by default returns a new DataFrame rather than modifying in place.

```python
df.rename(columns={"Col A": "col_a"}, inplace=True)
```

**Key Points**
- Only the columns listed in the mapping are changed; unmapped columns keep their original names.
- Passing a function instead of a dictionary applies it to every column name:

```python
df = df.rename(columns=str.lower)
```

### Bulk Renaming with String Methods

For consistent transformations across all columns (not just a specific mapping), assigning directly to `df.columns` with a vectorized string operation is often more direct:

```python
df.columns = df.columns.str.lower().str.replace(" ", "_")
```

This lowercases and replaces spaces with underscores across every column name in one operation, useful for standardizing inconsistent naming conventions (mixed case, spaces) commonly seen in data exported from spreadsheets or external systems.

### Setting Column Names at Creation

```python
df = pd.DataFrame(data, columns=["id", "name", "value"])
```

Explicitly passing `columns` at DataFrame creation avoids a separate rename step when the source data (e.g., a NumPy array or list of lists) doesn't already carry column labels.

### Reordering Columns

Pandas has no dedicated "reorder columns" method; reordering is done by selecting columns in the desired sequence:

```python
df = df[["id", "value", "name"]]
```

This creates a new DataFrame with columns in the specified order — any column names omitted from the list are dropped, so the list must include every column intended to be kept.

**Key Points**
- To reorder while keeping all columns without typing every name, common patterns include moving a specific column to the front:

```python
cols = ["id"] + [c for c in df.columns if c != "id"]
df = df[cols]
```

- Or moving a column to a specific position:

```python
cols = list(df.columns)
cols.insert(1, cols.pop(cols.index("value")))
df = df[cols]
```

### Reindexing Columns

`reindex()` provides an alternative approach that also handles the case of specifying columns that don't yet exist:

```python
df = df.reindex(columns=["id", "name", "value", "new_col"])
```

Columns in the `reindex()` list that don't already exist in the DataFrame are added with `NaN` values filled in, rather than raising an error — this differs from plain bracket selection, which requires all specified columns to already exist.

### Dropping Columns

```python
df = df.drop(columns=["temp_col"])
df.drop(columns=["temp_col"], inplace=True)
df = df.drop("temp_col", axis=1)
```

`columns=[...]` and `axis=1` with a positional/single argument are two equivalent ways of specifying that the drop applies to columns rather than rows (the default axis).

### Restructuring: Wide to Long (`melt`)

Wide-format data (one column per category/measurement) is often restructured into long format (one row per observation) for certain types of analysis or plotting:

```python
wide_df = pd.DataFrame({
    "id": [1, 2],
    "math_score": [90, 85],
    "science_score": [88, 92]
})

long_df = pd.melt(
    wide_df,
    id_vars=["id"],
    value_vars=["math_score", "science_score"],
    var_name="subject",
    value_name="score"
)
```

`id_vars` specifies columns to keep as identifiers (repeated across the reshaped rows); `value_vars` specifies which columns to "unpivot" into the new long-format rows.

### Restructuring: Long to Wide (`pivot`)

```python
wide_again = long_df.pivot(index="id", columns="subject", values="score")
```

`pivot()` reverses the melt operation, converting unique values in the `columns` argument into new column headers, with `values` populating the cells and `index` defining the row identity.

**Key Points**
- `pivot()` requires that each combination of `index` and `columns` values be unique; duplicate combinations raise an error. `pivot_table()` is the aggregating alternative when duplicates exist and need to be combined (e.g., via mean or sum):

```python
wide_agg = long_df.pivot_table(index="id", columns="subject", values="score", aggfunc="mean")
```

### Flattening MultiIndex Columns

Operations like `pivot_table()` with multiple `values` columns, or `groupby().agg()` with multiple aggregation functions, can produce a hierarchical (MultiIndex) column structure:

```python
result = df.groupby("category").agg({"value": ["mean", "sum"]})
print(result.columns)
# MultiIndex([('value', 'mean'), ('value', 'sum')])
```

Flattening this into single-level string column names is a common follow-up step for compatibility with tools or code expecting flat columns:

```python
result.columns = ["_".join(col).strip() for col in result.columns.values]
```

### Reordering to Match an External Schema

When column order must match an external system's expected schema (e.g., a database table or API contract), explicit reindexing against a predefined list is a direct approach:

```python
expected_schema = ["id", "name", "email", "created_at", "status"]
df = df.reindex(columns=expected_schema)
```

Any column in `expected_schema` not present in `df` is added as a new column filled with `NaN`, and any existing column not listed is dropped — both behaviors follow directly from how `reindex()` is documented to work.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| `KeyError` on rename | Key in the rename dictionary doesn't exactly match an existing column name (case or whitespace mismatch) |
| Unexpected column drop | Bracket-selection reordering (`df[[...]]`) omitted a column that should have been kept |
| `ValueError` on `pivot()` | Duplicate index/column combinations; requires `pivot_table()` with an aggregation function instead |
| Confusing MultiIndex column access | Forgetting that hierarchical columns require tuple-based indexing (`df[("value", "mean")]`) until flattened |

### Diagram: Wide vs. Long Format Restructuring

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Wide-to-Long and Long-to-Wide Restructuring (svg_diagram)</text>

  <text x="150" y="55" text-anchor="middle" font-size="12" font-weight="bold">Wide format</text>
  <rect x="40" y="65" width="220" height="30" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="150" y="85" text-anchor="middle" font-size="10">id | math_score | science_score</text>
  <rect x="40" y="95" width="220" height="30" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="150" y="115" text-anchor="middle" font-size="10">1  | 90         | 88</text>

  <line x1="280" y1="90" x2="340" y2="60" stroke="#333" stroke-width="1.5" marker-end="url(#arrow12)" />
  <text x="310" y="50" text-anchor="middle" font-size="9" fill="#555">melt()</text>

  <line x1="340" y1="130" x2="280" y2="100" stroke="#333" stroke-width="1.5" marker-end="url(#arrow12)" />
  <text x="310" y="145" text-anchor="middle" font-size="9" fill="#555">pivot()</text>

  <text x="580" y="55" text-anchor="middle" font-size="12" font-weight="bold">Long format</text>
  <rect x="440" y="65" width="280" height="25" fill="#f5e0e8" stroke="#a54a72" />
  <text x="580" y="82" text-anchor="middle" font-size="10">id | subject       | score</text>
  <rect x="440" y="90" width="280" height="25" fill="#f5e0e8" stroke="#a54a72" />
  <text x="580" y="107" text-anchor="middle" font-size="10">1  | math_score    | 90</text>
  <rect x="440" y="115" width="280" height="25" fill="#f5e0e8" stroke="#a54a72" />
  <text x="580" y="132" text-anchor="middle" font-size="10">1  | science_score | 88</text>

  </svg>

### Related Topics

- `stack()`/`unstack()` as an alternative reshape mechanism tied to MultiIndex structure
- `pd.wide_to_long()` for more complex wide-to-long patterns with variable suffix parsing
- Merging/joining DataFrames with mismatched or overlapping column names
- Schema validation and enforcement libraries (Pandera) for structural consistency
- Column-level metadata management in larger ETL pipelines
- MultiIndex columns and rows in depth (creation, selection, and flattening strategies)