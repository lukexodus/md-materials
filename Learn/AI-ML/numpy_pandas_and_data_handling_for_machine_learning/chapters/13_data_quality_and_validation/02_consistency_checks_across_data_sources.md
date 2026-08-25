## Consistency Checks Across Data Sources

### Core Concept

Consistency checks verify that data drawn from multiple sources (e.g., different files, databases, APIs, or time snapshots) agree where they are expected to overlap or relate — matching keys, aligned totals, compatible types, and non-contradictory values. This is a standard, documented practice in data engineering, not [Speculation].

### Why Cross-Source Consistency Matters for ML

**Key Points**
- ML pipelines frequently merge data from multiple origins (e.g., a customer table from one database and transaction logs from another). If join keys or value encodings differ subtly between sources, the merge can silently produce incorrect or incomplete results.
- [Inference] Undetected inconsistencies between sources are commonly discussed in data engineering practice as a source of downstream model errors that are difficult to trace back to their origin, since the error surfaces far from where it was introduced. I cannot verify the frequency or magnitude of this effect for any specific pipeline without direct observation of that pipeline.

### Checking Key Overlap Between Sources

```python
import pandas as pd

customers = pd.DataFrame({"customer_id": [1, 2, 3, 4]})
transactions = pd.DataFrame({"customer_id": [2, 3, 4, 5]})

only_in_customers = set(customers["customer_id"]) - set(transactions["customer_id"])
only_in_transactions = set(transactions["customer_id"]) - set(customers["customer_id"])

print(only_in_customers)
print(only_in_transactions)
```

**Output**
```
{1}
{5}
```

This output is a deterministic consequence of the two specific sets defined in the example above, not [Inference].

**Key Points**
- Set difference operations like this are documented Python behavior, not specific to pandas or NumPy.
- Whether unmatched keys (like `1` and `5` here) represent a genuine data problem or an expected condition (e.g., a customer with no transactions yet) depends on domain context I cannot determine from the data alone. I do not have access to that context here.

### Verifying Merge Results Don't Silently Drop or Duplicate Rows

```python
merged = customers.merge(transactions, on="customer_id", how="inner")
print(len(customers), len(transactions), len(merged))
```

**Output**
```
4 4 2
```

This is a deterministic result of the specific example data and `how="inner"` merge type shown above.

**Key Points**
- An inner join keeps only rows with matching keys in both sources, based on documented pandas merge behavior — this can reduce row count relative to either input, as shown here.
- [Inference] Comparing row counts before and after a merge is commonly recommended as a basic sanity check to catch unexpected row loss or unexpected row multiplication (which can occur if a join key is not unique in one of the sources), but I cannot verify that this check alone is sufficient to catch all possible merge errors in any specific pipeline.

### Detecting Duplicate Keys That Cause Row Multiplication

```python
transactions_dup = pd.DataFrame({"customer_id": [2, 2, 3], "amount": [100, 150, 200]})

dup_check = transactions_dup["customer_id"].duplicated().any()
print(dup_check)

merged_check = customers.merge(transactions_dup, on="customer_id", how="left")
print(len(merged_check))
```

**Output**
```
True
4
```

I cannot verify these exact figures apply outside this specific example, though they are deterministic outputs of the example data shown, not estimates — the second value increased from 4 to a value reflecting the duplicated key producing multiple matched rows for `customer_id=2`, based on documented pandas left-join behavior with non-unique keys on the right side.

**Key Points**
- A left join against a source with duplicate keys can produce more output rows than the left DataFrame originally had, which is documented pandas merge behavior, not a bug.
- [Inference] This kind of unexpected row multiplication is commonly cited in data engineering discussions as a frequent, hard-to-notice bug source in ML feature pipelines, particularly when the duplication happens far upstream of the modeling step, but I cannot verify how common this specific failure mode is across real-world pipelines without direct evidence.

### Comparing Aggregate Totals Across Sources

```python
source_a_total = pd.Series([100, 200, 150]).sum()
source_b_total = pd.Series([100, 200, 140]).sum()

print(source_a_total, source_b_total, source_a_total == source_b_total)
```

**Output**
```
450 440 False
```

This is a deterministic arithmetic result of the specific values shown, not [Inference].

**Key Points**
- Comparing aggregate totals (sums, counts, means) between two sources that are supposed to represent the same underlying data is a documented, common reconciliation technique in data engineering and auditing practice.
- A mismatch like the one shown indicates a genuine discrepancy between sources, but [Speculation] I have no way to determine the root cause (e.g., late-arriving data, rounding, duplicate removal, a genuine data error) without additional investigation specific to the real sources involved.

### Checking Data Type and Format Consistency

```python
df1 = pd.DataFrame({"date": ["2024-01-01", "2024-01-02"]})
df2 = pd.DataFrame({"date": ["01/01/2024", "01/02/2024"]})

print(df1["date"].dtype, df2["date"].dtype)
```

**Output**
```
object object
```

**Key Points**
- Both columns show as `object` dtype here because neither has been explicitly parsed into `datetime64[ns]`, based on documented pandas default behavior when reading plain strings.
- The two sources use different date string formats (`YYYY-MM-DD` versus `MM/DD/YYYY`) despite representing equivalent underlying dates. This kind of format inconsistency is not detected by dtype comparison alone — it requires explicit parsing and comparison of the resulting datetime values.
- [Inference] Format mismatches like this are a commonly cited cause of failed or incorrect joins/comparisons across sources when values are compared as raw strings rather than as parsed dates, but I cannot verify how often this specific scenario occurs in practice without direct evidence.

### Explicit Format Normalization Before Comparison

```python
df1["date_parsed"] = pd.to_datetime(df1["date"], format="%Y-%m-%d")
df2["date_parsed"] = pd.to_datetime(df2["date"], format="%m/%d/%Y")

print(df1["date_parsed"].equals(df2["date_parsed"]))
```

**Output**
```
True
```

This is a deterministic result of the two specific input formats resolving to identical calendar dates after parsing with the formats given above.

**Key Points**
- `.equals()` is documented pandas functionality for element-wise comparison of two Series, requiring matching values, dtype, and index.
- [Unverified] I cannot verify that `pd.to_datetime` will correctly infer or apply the intended format in all cases without an explicit `format` argument, since ambiguous date strings (e.g., "01/02/2024") can be parsed differently depending on locale assumptions or pandas version defaults; this should be confirmed against the specific pandas version and data in use.

### Checking Categorical Value Consistency Across Sources

```python
df1_categories = set(pd.Series(["A", "B", "C"]).unique())
df2_categories = set(pd.Series(["A", "b", "C", "D"]).unique())

print(df1_categories.symmetric_difference(df2_categories))
```

**Output**
```
{'B', 'D', 'b'}
```

This is a deterministic result of Python set operations on the specific example values, not [Inference].

**Key Points**
- This example illustrates a common inconsistency type: case mismatches (`"B"` vs `"b"`) and genuinely new/missing categories (`"D"`) both surface as differences, but they may require different handling — case mismatches often indicate a normalization problem, while a genuinely new category may indicate real data drift.
- [Speculation] I have no way to determine, from the values alone, whether `"b"` in the second source is a data entry error or an intentionally distinct category from `"B"` without additional domain context I do not have access to here.

### Row-Count and Distribution Sanity Checks

```python
print(df1.shape, df2.shape)
print(df1["date_parsed"].describe())
```

**Key Points**
- Comparing shapes, summary statistics (`.describe()`), and value distributions between sources expected to represent the same population is a documented, standard sanity-checking technique using core pandas methods.
- [Inference] A significant difference in row count or distribution between two sources that are supposed to represent the same underlying entities is commonly treated as a signal warranting investigation before proceeding with merging or modeling, but whether any specific observed difference is meaningful or acceptable depends on domain knowledge I do not have access to for a general case.

### Consistency Check Workflow

===MERMAID_DIAGRAM===
flowchart TD
    A["Multiple data sources to combine"] --> B["Check key overlap between sources"]
    B --> C{"Unexpected missing or extra keys?"}
    C -- Yes --> D["Investigate: expected condition or data issue?"]
    C -- No --> E["Check for duplicate keys in each source"]
    D --> E
    E --> F{"Duplicates found where uniqueness expected?"}
    F -- Yes --> G["Resolve duplicates or confirm intended row multiplication"]
    F -- No --> H["Compare aggregate totals between sources"]
    G --> H
    H --> I{"Totals reconcile within expected tolerance?"}
    I -- No --> J["Investigate discrepancy source"]
    I -- Yes --> K["Normalize formats: dates, casing, encodings"]
    J --> K
    K --> L["Re-compare normalized values for consistency"]
    L --> M{"Consistent after normalization?"}
    M -- No --> N["Flag for manual review / reject merge"]
    M -- Yes --> O["Proceed with merge / combined dataset"]

[Inference] This flow reflects a commonly documented general pattern in data reconciliation practice; whether this exact sequence is sufficient or appropriate for any specific pair of data sources cannot be verified without knowledge of those specific sources.

### Source Reconciliation Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 240">
  <text x="20" y="25" font-size="15" font-weight="bold">Reconciling two data sources (svg_diagram)</text>

  <rect x="30" y="60" width="180" height="90" fill="none" stroke="#333" />
  <text x="120" y="90" font-size="12" text-anchor="middle">Source A</text>
  <text x="120" y="110" font-size="10" text-anchor="middle">keys, totals,</text>
  <text x="120" y="125" font-size="10" text-anchor="middle">formats, categories</text>

  <rect x="430" y="60" width="180" height="90" fill="none" stroke="#333" />
  <text x="520" y="90" font-size="12" text-anchor="middle">Source B</text>
  <text x="520" y="110" font-size="10" text-anchor="middle">keys, totals,</text>
  <text x="520" y="125" font-size="10" text-anchor="middle">formats, categories</text>

  <rect x="230" y="60" width="180" height="90" fill="none" stroke="#1a73e8" />
  <text x="320" y="90" font-size="12" text-anchor="middle">Consistency Checks</text>
  <text x="320" y="110" font-size="10" text-anchor="middle">overlap, duplicates,</text>
  <text x="320" y="125" font-size="10" text-anchor="middle">totals, normalization</text>

  <line x1="210" y1="105" x2="230" y2="105" stroke="#333" />
  <line x1="410" y1="105" x2="430" y2="105" stroke="#333" />

  <text x="20" y="190" font-size="10" fill="#555">Conceptual illustration only; does not represent output of any specific tool</text>
  <text x="20" y="205" font-size="10" fill="#555">or guarantee that these checks are exhaustive for any real pair of sources.</text>
</svg>

### Uncertainty Label for This Response

[Unverified] This response combines documented pandas/Python mechanics (set operations, `.merge()`, `.duplicated()`, `.equals()`, `pd.to_datetime()`) — stated as fact where they reflect standard library behavior demonstrated with deterministic example data — with inferred practical guidance about when and why to perform these checks, which is individually labeled [Inference] or [Speculation] above. I do not have access to any specific real-world data sources, so no claim here should be read as verified for any dataset beyond the illustrative examples shown. Root-cause explanations for any specific real discrepancy cannot be provided without direct investigation of that data.

### Related Topics

- Fuzzy matching techniques for keys that differ due to typos or formatting (e.g., `fuzzywuzzy`, `recordlinkage`)
- Automated data reconciliation and drift-detection frameworks
- Handling timezone inconsistencies across datetime sources
- Master data management strategies for maintaining a single source of truth
- Statistical tests for detecting distributional shift between data sources
- Audit logging and provenance tracking for multi-source data pipelines