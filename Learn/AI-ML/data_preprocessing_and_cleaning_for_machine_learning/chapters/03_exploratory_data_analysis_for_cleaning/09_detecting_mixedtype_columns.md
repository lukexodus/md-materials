## Detecting Mixed-Type Columns

### Definition

A mixed-type column is a single column (Series) in a dataset that contains values of more than one data type — for example, a column meant to hold numeric ages that also contains strings like `"unknown"`, `"N/A"`, or `"25 years"`. Mixed types commonly arise from manual data entry, merged datasets, exports from spreadsheets with inconsistent formatting, or placeholder values used to represent missing data.

### Why This Matters

**Key Points**

- Many machine learning algorithms and preprocessing functions (scalers, encoders, imputers) expect a single consistent dtype per column and will raise errors or silently misbehave otherwise.
- Pandas often stores mixed-type columns as `object` dtype, which masks the underlying inconsistency until an operation fails downstream.
- Undetected mixed types can cause silent data corruption — for instance, numeric values stored as strings will not be included in statistical summaries like `.mean()` unless explicitly converted.
- Mixed types frequently indicate a deeper data quality issue (inconsistent source systems, encoding errors, or improper joins) worth investigating beyond the column itself.

### Common Causes

- **Missing value placeholders**: mixing `NaN` with strings such as `"missing"`, `"N/A"`, `"-"`, or `"unknown"`.
- **Unit or formatting inconsistencies**: `"25"` vs `"25 kg"` vs `25`.
- **Boolean-like ambiguity**: `True`/`False` mixed with `"yes"`/`"no"` or `1`/`0`.
- **Date inconsistencies**: date strings mixed with Unix timestamps or `datetime` objects.
- **Encoding or copy-paste errors**: stray whitespace, currency symbols (`"$100"`), or thousands separators (`"1,000"`) mixed into otherwise numeric columns.
- **Merged/concatenated datasets**: combining files from different sources where the same logical column was typed differently.

### Detection Methods

#### 1. Inspecting dtype at the column level

The `.dtypes` attribute shows the dtype pandas assigned to each column, but this only reveals the surface-level storage type. A column of `object` dtype could be pure strings, pure mixed types, or anything in between — `.dtypes` alone cannot distinguish these cases.

```python
import pandas as pd

df = pd.read_csv("data.csv")
print(df.dtypes)
```

This is a necessary first step but is not sufficient on its own, since `object` is a catch-all dtype in pandas.

#### 2. Checking per-value Python types

To actually detect mixed types within an `object` column, apply Python's built-in `type()` function to every value and inspect the set of distinct types present.

```python
def detect_mixed_types(series):
    types_found = series.map(type).value_counts()
    return types_found

print(detect_mixed_types(df["age"]))
```

If this returns more than one type (e.g., `<class 'int'>` and `<class 'str'>`), the column is confirmed mixed-type.

#### 3. Using `pandas.api.types.infer_dtype`

Pandas provides a utility function specifically designed to infer the effective type of values within a Series, including detecting the `"mixed"` case explicitly.

```python
from pandas.api.types import infer_dtype

result = infer_dtype(df["age"], skipna=True)
print(result)
```

Possible outputs include `"integer"`, `"floating"`, `"string"`, `"mixed-integer"`, `"mixed-integer-float"`, or `"mixed"`. A result of `"mixed"` or `"mixed-integer"` is a direct signal of inconsistent typing within the column.

#### 4. Attempting coercion and catching failures

A practical detection technique is to attempt to convert the column to the expected type and capture which values fail.

```python
def find_non_numeric(series):
    coerced = pd.to_numeric(series, errors="coerce")
    failed_mask = coerced.isna() & series.notna()
    return series[failed_mask]

problem_values = find_non_numeric(df["age"])
print(problem_values.unique())
```

This isolates the exact offending values (e.g., `"unknown"`, `"25 years"`) rather than just flagging that a problem exists, which is more actionable during cleaning.

#### 5. Scanning all columns programmatically

For a full dataset audit, iterate over every column and report any that contain more than one Python type.

```python
def scan_dataframe_for_mixed_types(df):
    mixed_cols = {}
    for col in df.columns:
        unique_types = df[col].map(type).nunique()
        if unique_types > 1:
            mixed_cols[col] = df[col].map(type).value_counts().to_dict()
    return mixed_cols

report = scan_dataframe_for_mixed_types(df)
print(report)
```

**Output**

```
{'age': {<class 'int'>: 950, <class 'str'>: 50},
 'signup_date': {<class 'str'>: 800, <class 'float'>: 200}}
```

This gives a column-by-column breakdown of exactly which types are competing within each field and their relative frequency, which helps prioritize cleaning effort toward the most contaminated columns.

### Visualizing the Detection Workflow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 400">
<text x="410" y="28" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Mixed-Type Column Detection Workflow (svg_diagram)</text>
<rect x="30" y="60" width="180" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
<text x="120" y="85" font-size="12.5" text-anchor="middle" fill="#1a1a1a">Load DataFrame</text>
<text x="120" y="102" font-size="12.5" text-anchor="middle" fill="#1a1a1a">df.dtypes</text>
<rect x="30" y="160" width="180" height="60" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
<text x="120" y="185" font-size="12.5" text-anchor="middle" fill="#1a1a1a">Column is</text>
<text x="120" y="202" font-size="12.5" text-anchor="middle" fill="#1a1a1a">'object' dtype?</text>
<rect x="30" y="260" width="180" height="60" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
<text x="120" y="285" font-size="12.5" text-anchor="middle" fill="#1a1a1a">Non-object dtype:</text>
<text x="120" y="302" font-size="12.5" text-anchor="middle" fill="#1a1a1a">likely consistent</text>
<rect x="290" y="160" width="200" height="60" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
<text x="390" y="182" font-size="12.5" text-anchor="middle" fill="#1a1a1a">series.map(type)</text>
<text x="390" y="199" font-size="12.5" text-anchor="middle" fill="#1a1a1a">.value_counts()</text>
<rect x="290" y="260" width="200" height="60" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
<text x="390" y="282" font-size="12.5" text-anchor="middle" fill="#1a1a1a">infer_dtype()</text>
<text x="390" y="299" font-size="12.5" text-anchor="middle" fill="#1a1a1a">check for "mixed*"</text>
<rect x="580" y="210" width="210" height="60" rx="8" fill="#f3e8fd" stroke="#a142f4" stroke-width="1.5" />
<text x="685" y="232" font-size="12.5" text-anchor="middle" fill="#1a1a1a">pd.to_numeric(errors=</text>
<text x="685" y="249" font-size="12.5" text-anchor="middle" fill="#1a1a1a">'coerce') to isolate values</text>
<line x1="120" y1="120" x2="120" y2="158" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="120" y1="220" x2="120" y2="258" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
<text x="128" y="245" font-size="11" fill="#5f6368">No</text>
<line x1="210" y1="190" x2="288" y2="190" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
<text x="220" y="182" font-size="11" fill="#5f6368">Yes</text>
<line x1="390" y1="220" x2="390" y2="258" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="490" y1="220" x2="580" y2="235" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="490" y1="280" x2="580" y2="255" stroke="#5f6368" stroke-width="1.5" marker-end="url(#arrow)" />
</svg>

### Edge Cases to Watch For

- **NaN masking**: `NaN` is a `float` in pandas, so a column with numbers and missing values will show both `int`/`float` and may be flagged as mixed even though this is often benign; distinguish this from genuine string contamination.
- **Boolean ambiguity**: columns with `True`/`False` mixed with `1`/`0` may or may not be problematic depending on downstream processing — pandas treats booleans as a subtype of integers in some numeric contexts.
- **Whitespace-only differences**: `"25 "` (with trailing space) and `"25"` may both coerce successfully but indicate inconsistent upstream formatting worth flagging separately.
- **Large datasets**: applying `.map(type)` row-by-row is $O(n)$ per column and can be slow on very large datasets; for large-scale scans, sampling a subset of rows first can help prioritize which columns warrant a full scan. [Inference] — this performance characteristic follows from the row-wise nature of `.map()`, though actual runtime depends on hardware, dataset size, and pandas version, and may vary.

### Next Steps

- **Handling Missing Values** — strategies for imputing or removing `NaN`/placeholder values once mixed-type columns are cleaned.
- **Type Coercion and Casting Strategies** — systematic approaches to converting cleaned mixed-type columns into a single consistent dtype.
- **Standardizing Categorical String Values** — resolving inconsistent casing, whitespace, and synonyms (e.g., `"Yes"` vs `"yes"` vs `"Y"`).
- **Detecting and Handling Outliers** — a related EDA step often performed after type consistency is established.
- **Schema Validation with Pandera or Great Expectations** — enforcing type contracts programmatically to catch mixed types before they enter a pipeline.