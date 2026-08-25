## Removing Duplicates and Inconsistent Records

### Overview

Duplicate and inconsistent records are a common data quality issue that can distort statistical summaries, bias model training, and cause errors in joins or aggregations. Pandas provides dedicated tools for detecting exact duplicates, near-duplicates arising from formatting inconsistencies, and structural inconsistencies across related columns.

### Detecting Exact Duplicates

```python
import pandas as pd

df = pd.DataFrame({
    "id": [1, 2, 2, 3, 4],
    "name": ["Alice", "Bob", "Bob", "Carol", "Dave"]
})

df.duplicated()
```

`duplicated()` returns a boolean Series marking each row as `True` if it is a duplicate of an earlier row (by default), considering all columns.

**Key Points**
- `keep="first"` (default): marks all but the first occurrence as duplicate.
- `keep="last"`: marks all but the last occurrence as duplicate.
- `keep=False`: marks *all* occurrences of a duplicated row as `True`, useful for inspecting every copy rather than just the extras.

```python
df.duplicated(keep=False)
```

### Removing Exact Duplicates

```python
df.drop_duplicates()
df.drop_duplicates(keep="last")
df.drop_duplicates(subset=["name"])
```

`subset` restricts the duplicate check to specific columns rather than requiring all columns to match — useful when, for example, an `id` column is unique per row but a `name` field has genuine repeats that should be considered duplicates.

```python
df.drop_duplicates(subset=["name"], keep="first", inplace=True)
```

**Key Points**
- `inplace=True` modifies the DataFrame directly rather than returning a new one; [Inference] this is generally used to avoid holding two copies of a large DataFrame in memory simultaneously, though the actual memory impact depends on DataFrame size and how the result is otherwise used.

### Counting Duplicates Before Removing

```python
duplicate_count = df.duplicated().sum()
print(f"Found {duplicate_count} duplicate rows")
```

Checking the count before dropping is a common practice for understanding the scale of the issue before deciding on a removal strategy.

### Near-Duplicates from Formatting Inconsistencies

Exact duplicate detection misses records that differ only in formatting — case, whitespace, or punctuation — but represent the same real-world entity.

```python
df["email"] = df["email"].str.lower().str.strip()
df["name"] = df["name"].str.strip().str.title()
```

Normalizing text fields (lowercasing, trimming whitespace, consistent capitalization) before duplicate detection catches cases that exact matching would miss:

```python
df_normalized = df.copy()
df_normalized["email"] = df_normalized["email"].str.lower().str.strip()

duplicates_after_normalization = df_normalized.duplicated(subset=["email"])
```

[Inference] Normalizing text before duplicate detection is standard practice in data cleaning workflows generally, based on this being a widely documented technique for catching case/whitespace-based near-duplicates, though the specific normalization steps needed depend on the actual inconsistencies present in a given dataset.

### Fuzzy Matching for Near-Duplicate Detection

For near-duplicates that differ by more than simple formatting (e.g., typos, abbreviations — "Jon Smith" vs. "John Smith"), exact or normalized-string matching is insufficient. Libraries such as `rapidfuzz` or `fuzzywuzzy` compute string similarity scores:

```python
from rapidfuzz import fuzz

similarity = fuzz.ratio("Jon Smith", "John Smith")
print(similarity)
```

Applying a similarity threshold to flag candidate near-duplicate pairs for review:

```python
from itertools import combinations

names = df["name"].tolist()
candidates = [
    (a, b, fuzz.ratio(a, b))
    for a, b in combinations(names, 2)
    if fuzz.ratio(a, b) > 90
]
```

[Unverified] The specific similarity threshold that correctly balances false positives and false negatives depends entirely on the dataset and the nature of the naming inconsistencies present — I do not have a general threshold value to recommend that would hold across different datasets.

**Key Points**
- Fuzzy matching does not scale well to very large datasets using naive pairwise comparison (`combinations` is $O(n^2)$); blocking or indexing strategies are typically used to reduce the comparison space first for large datasets.

### Detecting Inconsistent Records Across Related Columns

Beyond row-level duplication, inconsistency can occur when related columns should agree but don't — for example, the same `customer_id` associated with two different `customer_name` values across rows.

```python
inconsistent = df.groupby("customer_id")["customer_name"].nunique()
problem_ids = inconsistent[inconsistent > 1].index

df[df["customer_id"].isin(problem_ids)]
```

This identifies `customer_id` values associated with more than one distinct `customer_name`, surfacing rows where the two fields disagree across the dataset.

### Handling Inconsistent Categorical Labels

Free-text or loosely controlled categorical fields often accumulate inconsistent labels representing the same category:

```python
df["status"].unique()
# array(['Active', 'active', 'ACTIVE', 'Inactive', 'inactive'], dtype=object)

mapping = {
    "active": "Active",
    "ACTIVE": "Active",
    "inactive": "Inactive"
}
df["status"] = df["status"].replace(mapping)
```

Inspecting `unique()` output on categorical/text columns is a straightforward way to surface this kind of inconsistency before deciding on a normalization mapping.

### Validating Cross-Field Consistency Rules

Some inconsistencies are logical rather than textual — for example, an `end_date` earlier than a `start_date`:

```python
invalid_rows = df[df["end_date"] < df["start_date"]]
```

**Key Points**
- These logical validation checks are dataset- and domain-specific; there is no general-purpose Pandas function that detects "business rule" violations automatically. Each rule generally needs to be expressed explicitly as a boolean condition, as shown above.

### Common Pitfalls

| Pitfall | Cause |
|---|---|
| Duplicates missed | Case/whitespace differences not normalized before `duplicated()`/`drop_duplicates()` |
| Unintended data loss | `drop_duplicates()` called without `subset`, dropping rows that only coincidentally matched on non-identifying columns |
| False positive near-duplicates | Fuzzy matching threshold set too low, flagging genuinely distinct records as duplicates |
| Silent index issues after dropping | Row index not reset after `drop_duplicates()`, leaving gaps that can cause confusion in later position-based operations |

Resetting the index after dropping rows is a common follow-up step:

```python
df = df.drop_duplicates().reset_index(drop=True)
```

### Diagram: Duplicate Detection Workflow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 260">
  <text x="380" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Duplicate and Inconsistency Detection Workflow (svg_diagram)</text>

  <rect x="30" y="60" width="150" height="45" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="105" y="87" text-anchor="middle" font-size="11">Raw data</text>

  <line x1="180" y1="82" x2="230" y2="82" stroke="#333" stroke-width="2" marker-end="url(#arrow8)" />

  <rect x="240" y="60" width="150" height="45" rx="6" fill="#fdf3d7" stroke="#b8952f" />
  <text x="315" y="80" text-anchor="middle" font-size="11">Normalize text</text>
  <text x="315" y="95" text-anchor="middle" font-size="10">(case, whitespace)</text>

  <line x1="390" y1="82" x2="440" y2="82" stroke="#333" stroke-width="2" marker-end="url(#arrow8)" />

  <rect x="450" y="60" width="150" height="45" rx="6" fill="#f5e0e8" stroke="#a54a72" />
  <text x="525" y="80" text-anchor="middle" font-size="11">Exact duplicate</text>
  <text x="525" y="95" text-anchor="middle" font-size="10">check (duplicated)</text>

  <line x1="660" y1="82" x2="700" y2="82" stroke="#333" stroke-width="2" marker-end="url(#arrow8)" />
  <rect x="600" y="60" width="0" height="0" />

  <line x1="315" y1="105" x2="315" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow8)" />
  <rect x="230" y="155" width="170" height="45" rx="6" fill="#e5f5e0" stroke="#4a9159" />
  <text x="315" y="175" text-anchor="middle" font-size="11">Fuzzy matching</text>
  <text x="315" y="190" text-anchor="middle" font-size="10">(near-duplicates)</text>

  <line x1="525" y1="105" x2="525" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow8)" />
  <rect x="440" y="155" width="170" height="45" rx="6" fill="#eef2fb" stroke="#4a6fa5" />
  <text x="525" y="175" text-anchor="middle" font-size="11">Cross-field</text>
  <text x="525" y="190" text-anchor="middle" font-size="10">consistency checks</text>

  </svg>

### Related Topics

- Record linkage and entity resolution across multiple data sources
- Blocking/indexing strategies to scale fuzzy matching beyond small datasets
- Data validation frameworks (e.g., Great Expectations, Pandera) for automated rule enforcement
- Handling inconsistent units and formats within numeric columns (e.g., mixed currencies)
- Merge/join strategies when duplicate keys exist across DataFrames
- Auditing and logging data-cleaning transformations for reproducibility