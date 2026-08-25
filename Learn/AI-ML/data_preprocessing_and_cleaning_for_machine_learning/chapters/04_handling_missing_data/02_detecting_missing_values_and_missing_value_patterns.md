## Detecting Missing Values and Missing Value Patterns

### Overview

Before missing data can be handled through deletion, imputation, or modeling, it must first be systematically detected — both at the individual value level and at the level of patterns across rows and columns. Detection involves identifying explicit missing markers (like `NaN` or `NULL`), implicit missing markers (like placeholder strings), and structural patterns in how missingness co-occurs across variables.

### Why Pattern Detection Matters

**Key Points**

- Detecting *that* values are missing is only the first step; detecting *patterns* in missingness helps distinguish between MCAR, MAR, and MNAR mechanisms, which in turn determines appropriate handling strategies.
- Missing values are not always represented as `NaN` — datasets frequently encode missingness using placeholder strings (`"N/A"`, `"unknown"`, `"-"`, `"999"`), which standard missingness checks will not catch unless explicitly searched for.
- Visualizing missingness patterns often reveals structural issues (e.g., entire blocks of rows missing the same set of columns) that summary statistics alone can obscure.

### Step 1: Detecting Explicit Missing Values

Pandas natively recognizes `NaN`, `None`, and `NaT` (for datetime) as missing.

```python
import pandas as pd

df = pd.read_csv("data.csv")

# Total missing values per column
print(df.isna().sum())

# Percentage missing per column
print((df.isna().mean() * 100).round(2))

# Total missing values in the entire dataset
print(df.isna().sum().sum())
```

**Output**

```
age            50
income         120
signup_date    0
region         15
dtype: int64
```

### Step 2: Detecting Implicit (Disguised) Missing Values

Placeholder values do not register as missing under `.isna()` and must be searched for explicitly, typically by inspecting unique values per column.

```python
# Inspect unique values to spot disguised missingness
for col in df.select_dtypes(include="object").columns:
    print(col, df[col].unique()[:20])
```

Common disguised missing markers include `"N/A"`, `"NA"`, `"null"`, `"none"`, `"-"`, `"?"`, `"unknown"`, empty strings `""`, and sentinel numeric codes such as `-1`, `0`, `9999`, or `999`. Once identified, these can be explicitly converted to `NaN`:

```python
placeholder_values = ["N/A", "NA", "null", "none", "-", "?", "unknown", ""]
df.replace(placeholder_values, pd.NA, inplace=True)
```

I cannot verify which placeholder conventions apply to any specific dataset without inspecting it directly — the list above reflects commonly encountered conventions, not a guaranteed or exhaustive set for every source.

### Step 3: Visualizing Missingness Patterns

#### Missingness Matrix (Row-Level View)

A matrix view shows, for every row and column, whether a value is present or missing, which helps reveal whether missingness is scattered randomly or clustered in blocks.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 380">
<text x="380" y="26" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Missingness Matrix Concept (svg_diagram)</text>

<text x="40" y="55" font-size="12" fill="`#5f6368`">Rows</text>

<text x="700" y="55" font-size="12" fill="`#5f6368`" text-anchor="end">Columns: A, B, C, D, E</text>

<g font-size="11" fill="#1a1a1a">
<text x="10" y="80">1</text>
<text x="10" y="100">2</text>
<text x="10" y="120">3</text>
<text x="10" y="140">4</text>
<text x="10" y="160">5</text>
<text x="10" y="180">6</text>
<text x="10" y="200">7</text>
<text x="10" y="220">8</text>
</g>
<g>

<text x="120" y="65" font-size="11" text-anchor="middle">A</text>
<text x="220" y="65" font-size="11" text-anchor="middle">B</text>
<text x="320" y="65" font-size="11" text-anchor="middle">C</text>
<text x="420" y="65" font-size="11" text-anchor="middle">D</text>
<text x="520" y="65" font-size="11" text-anchor="middle">E</text>
</g>


<rect x="95" y="70" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="70" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="70" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="70" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="70" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="90" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="90" width="50" height="18" fill="#fca5a5" />
<rect x="295" y="90" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="90" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="90" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="110" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="110" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="110" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="110" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="110" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="130" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="130" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="130" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="130" width="50" height="18" fill="#fca5a5" />
<rect x="495" y="130" width="50" height="18" fill="#fca5a5" />

<rect x="95" y="150" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="150" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="150" width="50" height="18" fill="#fca5a5" />
<rect x="395" y="150" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="150" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="170" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="170" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="170" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="170" width="50" height="18" fill="#fca5a5" />
<rect x="495" y="170" width="50" height="18" fill="#fca5a5" />

<rect x="95" y="190" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="190" width="50" height="18" fill="#fca5a5" />
<rect x="295" y="190" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="190" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="190" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="210" width="50" height="18" fill="#c6dafc" />
<rect x="195" y="210" width="50" height="18" fill="#c6dafc" />
<rect x="295" y="210" width="50" height="18" fill="#c6dafc" />
<rect x="395" y="210" width="50" height="18" fill="#c6dafc" />
<rect x="495" y="210" width="50" height="18" fill="#c6dafc" />

<rect x="95" y="260" width="20" height="16" fill="#c6dafc" />
<text x="120" y="273" font-size="12" fill="#1a1a1a">Present</text>
<rect x="220" y="260" width="20" height="16" fill="#fca5a5" />
<text x="245" y="273" font-size="12" fill="#1a1a1a">Missing</text>

<text x="40" y="310" font-size="12" fill="`#5f6368`">Note: rows 4 and 6 show D and E missing together —</text>

<text x="40" y="328" font-size="12" fill="`#5f6368`">a co-occurrence pattern worth investigating, not proof of any specific mechanism.</text>

</svg>

I cannot verify what pattern would appear in any actual dataset without inspecting it — the matrix above illustrates the concept of a co-occurring missingness block, not a real dataset.

Common tools for generating this type of matrix include the `missingno` library:

```python
import missingno as msno
import matplotlib.pyplot as plt

msno.matrix(df)
plt.show()
```

I cannot verify the current API or exact behavior of `missingno` in any specific version without checking its live documentation, since library APIs can change between releases.

#### Missingness Correlation (Column-Level View)

A correlation-style heatmap of missingness indicators shows whether missingness in one column tends to co-occur with missingness in another.

```python
# Build a boolean missingness indicator DataFrame
missing_indicators = df.isna().astype(int)

# Correlation between missingness patterns across columns
missing_corr = missing_indicators.corr()
print(missing_corr)
```

**Output** (illustrative structure only)

```
              age    income   region
age          1.00     0.05     0.02
income       0.05     1.00     0.61
region       0.02     0.61     1.00
```

A high correlation (e.g., 0.61 between `income` and `region`) suggests these two columns tend to be missing together, which is a pattern worth investigating rather than a conclusion in itself — [Inference] this pattern is consistent with either a shared upstream data collection issue or a structural relationship between the two fields, but I cannot verify which explanation applies without domain-specific investigation.

### Step 4: Quantifying Missingness by Row

In addition to per-column missingness, checking how many missing values exist per row can reveal whether certain records are more incomplete than others.

```python
df["missing_count_per_row"] = df.isna().sum(axis=1)
print(df["missing_count_per_row"].value_counts().sort_index())

# Flag rows exceeding a missingness threshold
high_missing_rows = df[df["missing_count_per_row"] > 3]
print(f"Rows with more than 3 missing fields: {len(high_missing_rows)}")
```

### Step 5: Tabulating Missingness Patterns as Combinations

Rather than looking at columns pairwise, it can help to enumerate the distinct combinations of which columns are missing together, since real datasets often have a small number of recurring "missingness signatures."

```python
missing_pattern = df.isna()
pattern_counts = missing_pattern.value_counts()
print(pattern_counts.head(10))
```

This produces a ranked list of the most common combinations of missing/non-missing columns, which can reveal, for example, that a specific subset of rows is always missing the same three fields together — often a sign of a specific upstream process (e.g., a particular data source or form version) rather than random chance. [Inference] — this interpretation is a reasonable explanation for such a pattern based on common data pipeline structures, but I do not have access to information about any specific dataset's actual source, so this remains an inference rather than a confirmed cause.

### Summary Checklist

| Detection Task | Method | Reveals |
| --- | --- | --- |
| Explicit missing values | `.isna().sum()` | Count/percentage missing per column |
| Disguised missing values | `.unique()` inspection | Placeholder strings acting as missing |
| Row-level missingness | `.isna().sum(axis=1)` | Which rows are most incomplete |
| Column co-occurrence | `.isna().corr()` | Whether columns go missing together |
| Missingness signatures | `.isna().value_counts()` | Recurring combinations of missing fields |
| Visual structure | `missingno.matrix()` | Block patterns, clustering, ordering effects |

### Related Topics

- **Types of Missingness: MCAR, MAR, MNAR** — using detected patterns to reason about the underlying mechanism.
- **Handling Missing Values: Deletion Strategies** — listwise and pairwise deletion mechanics.
- **Multiple Imputation Techniques** — model-based approaches for MAR data.
- **Missing Indicator Features** — encoding the fact of missingness as a predictive feature.
- **Data Quality Auditing Pipelines** — automating missingness detection as part of a broader data validation workflow.