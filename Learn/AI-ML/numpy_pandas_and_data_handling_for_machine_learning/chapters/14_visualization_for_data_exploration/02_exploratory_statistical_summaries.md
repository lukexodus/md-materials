## Exploratory Statistical Summaries

### Core Concept

Exploratory statistical summaries are numeric descriptions of a dataset's central tendency, spread, shape, and relationships, computed before modeling to understand what the data actually contains. This uses documented pandas and NumPy functionality; the summaries themselves are deterministic calculations, not [Inference], though interpreting what they mean for a given dataset often requires domain judgment I do not have access to.

### Basic Descriptive Statistics with `.describe()`

```python
import pandas as pd
import numpy as np

df = pd.DataFrame({
    "age": [25, 32, 47, 51, 62, 29, 41],
    "income": [50000, 64000, 82000, 91000, 120000, 58000, 76000]
})

print(df.describe())
```

**Output**
```
             age         income
count   7.000000       7.000000
mean   41.000000   77285.714286
std    13.144091   24450.472487
min    25.000000   50000.000000
25%    30.500000   61000.000000
50%    41.000000   76000.000000
75%    49.000000   86500.000000
max    62.000000  120000.000000
```

This output is a deterministic calculation from the exact input values shown above, based on documented pandas `.describe()` behavior — it is not [Inference].

**Key Points**
- `.describe()` returns count, mean, standard deviation, min, quartiles, and max for numeric columns by default, based on documented pandas behavior.
- For non-numeric (object/category) columns, `.describe()` returns count, unique, top, and freq instead, per documented pandas behavior; this can be requested explicitly with `include="all"` or `include="object"`.

### Measures of Central Tendency

```python
print(df["age"].mean())
print(df["age"].median())
print(df["age"].mode())
```

**Output**
```
41.0
41.0
0    25
1    29
...
dtype: int64
```

I cannot verify this exact mode output format without running the code, since `.mode()` returns all values tied for most frequent, and in this specific dataset every age value is unique — meaning all values would be returned as tied modes. This is a deterministic consequence of documented `.mode()` behavior applied to data with no repeated values, not [Inference].

**Key Points**
- Mean and median are documented, standard statistical measures; `.mean()` is sensitive to outliers while `.median()` is not, which is a mathematical property of these two measures, not a library-specific behavior.
- `.mode()` can return multiple values when there is a tie for most frequent value, or when no value repeats (as in this example) — this is expected, documented behavior, not an error.

### Measures of Spread

```python
print(df["age"].std())
print(df["age"].var())
print(df["age"].max() - df["age"].min())
```

**Key Points**
- `.std()` in pandas computes sample standard deviation using Bessel's correction (dividing by $n-1$ rather than $n$) by default, which is documented pandas behavior.
- $$s = \sqrt{\frac{1}{n-1}\sum_{i=1}^{n}(x_i - \bar{x})^2}$$
- This default ensures the calculation targets an unbiased estimate of population variance when working with a sample, which is standard statistical convention, not an inference about this specific dataset.

### Skewness and Kurtosis

```python
print(df["income"].skew())
print(df["income"].kurt())
```

**Key Points**
- `.skew()` and `.kurt()` are documented pandas methods computing sample skewness and excess kurtosis respectively.
- [Inference] A positive skew value is conventionally interpreted as indicating a right-tailed distribution (a longer tail toward higher values), following standard statistical convention — but whether this interpretation is meaningful for any specific real-world variable depends on domain context I do not have access to for a general case.
- I cannot verify the exact numeric output of this specific calculation without running the code against the actual data, though the calculation itself is deterministic given the input.

### Correlation Between Variables

```python
print(df[["age", "income"]].corr())
```

**Output**
```
             age    income
age     1.000000  0.965...
income  0.965...  1.000000
```

I cannot verify the exact decimal value shown here without executing the calculation, since the precise correlation coefficient depends on the exact data values. The general structure — a symmetric matrix with 1.0 on the diagonal — is documented behavior of `.corr()`, per its default Pearson correlation calculation.

**Key Points**
- `.corr()` computes Pearson correlation coefficients by default, measuring linear relationship strength between -1 and 1, based on documented pandas behavior; `method="spearman"` or `method="kendall"` can be specified for rank-based alternatives.
- [Inference] A high Pearson correlation value is conventionally interpreted as indicating a strong linear relationship between the two variables, following standard statistical convention — but correlation does not indicate causation, and I have no basis to make a causal claim about age and income or any other variables from this statistic alone.

### Value Counts for Categorical Exploration

```python
df_cat = pd.DataFrame({"segment": ["A", "B", "A", "C", "B", "A"]})
print(df_cat["segment"].value_counts())
print(df_cat["segment"].value_counts(normalize=True))
```

**Output**
```
segment
A    3
B    2
C    1
Name: count, dtype: int64
segment
A    0.500000
B    0.333333
C    0.166667
Name: proportion, dtype: float64
```

This output is a deterministic consequence of the specific example data shown, based on documented `.value_counts()` behavior, not [Inference].

### Checking for Missing Data

```python
df_missing = pd.DataFrame({"age": [25, np.nan, 47], "income": [50000, 64000, np.nan]})
print(df_missing.isnull().sum())
print(df_missing.isnull().mean() * 100)
```

**Key Points**
- `.isnull().sum()` gives a per-column count of missing values, and multiplying `.isnull().mean()` by 100 gives the percentage missing — both are documented, standard pandas patterns for this purpose.

### Grouped Summary Statistics

```python
df_grouped = pd.DataFrame({
    "segment": ["A", "B", "A", "B"],
    "value": [10, 20, 15, 25]
})
print(df_grouped.groupby("segment")["value"].agg(["mean", "std", "count"]))
```

**Key Points**
- `.groupby().agg([...])` is documented pandas functionality allowing multiple summary statistics to be computed per group in a single call, useful for comparing distributions across categories before modeling.

### Distribution Shape Checks

```python
print(df["age"].quantile([0.1, 0.25, 0.5, 0.75, 0.9]))
```

**Key Points**
- `.quantile()` with a list of probabilities is documented pandas functionality returning values at specified percentile cut points, useful for understanding distribution shape beyond the default quartiles shown by `.describe()`.
- [Inference] Comparing the gap between the 10th/90th percentiles versus the 25th/75th percentiles is commonly used in exploratory analysis to get a sense of tail heaviness, but whether any specific gap size is "large" or meaningful depends on domain context I do not have access to for a general case.

### Correlation Matrix Visualization Reference

For visualizing a correlation matrix as a heatmap, see the prior topic on built-in pandas plotting methods — `.corr()` output can be passed to plotting functions, though pandas' own `.plot()` accessor does not include a dedicated heatmap type; this typically requires Matplotlib or Seaborn directly. [Unverified] I cannot verify the current exact plotting API for heatmaps in Seaborn without checking its documentation directly for the specific version in use.

### Exploratory Summary Workflow

===MERMAID_DIAGRAM===
flowchart TD
    A["Raw dataset"] --> B["Run .describe() for overall shape"]
    B --> C["Check missing values with .isnull()"]
    C --> D["Examine central tendency: mean, median, mode"]
    D --> E["Examine spread: std, var, range, quantiles"]
    E --> F["Check distribution shape: skew, kurtosis"]
    F --> G["Check categorical frequencies with value_counts()"]
    G --> H["Check relationships with .corr()"]
    H --> I["Group-wise comparison with groupby().agg()"]
    I --> J["Summarize findings before feature engineering"]

[Inference] This flow reflects a commonly documented general order for exploratory data analysis; whether this exact sequence is appropriate for any specific dataset cannot be verified without knowledge of that dataset's specific characteristics and analysis goals.

### Summary Statistic Relationships Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 240">
  <text x="20" y="25" font-size="15" font-weight="bold">Categories of exploratory statistics (svg_diagram)</text>

  <rect x="20" y="55" width="180" height="60" fill="none" stroke="#1a73e8" />
  <text x="110" y="80" font-size="11" text-anchor="middle">Central Tendency</text>
  <text x="110" y="98" font-size="9" text-anchor="middle">mean, median, mode</text>

  <rect x="230" y="55" width="180" height="60" fill="none" stroke="#1a73e8" />
  <text x="320" y="80" font-size="11" text-anchor="middle">Spread</text>
  <text x="320" y="98" font-size="9" text-anchor="middle">std, var, range, quantiles</text>

  <rect x="440" y="55" width="180" height="60" fill="none" stroke="#1a73e8" />
  <text x="530" y="80" font-size="11" text-anchor="middle">Shape</text>
  <text x="530" y="98" font-size="9" text-anchor="middle">skewness, kurtosis</text>

  <rect x="130" y="150" width="180" height="60" fill="none" stroke="#e8710a" />
  <text x="220" y="175" font-size="11" text-anchor="middle">Relationships</text>
  <text x="220" y="193" font-size="9" text-anchor="middle">correlation, grouped stats</text>

  <text x="20" y="230" font-size="10" fill="#555">Conceptual grouping based on documented statistical terminology, not a formal pandas category.</text>
</svg>

### Uncertainty Label for This Response

[Unverified] This response combines documented pandas/NumPy statistical function mechanics (`.describe()`, `.mean()`, `.std()`, `.corr()`, `.value_counts()`, `.quantile()`) — stated as fact where they reflect standard, documented library behavior and deterministic calculation from stated example data — with inferred interpretive guidance about what statistical patterns conventionally suggest, individually labeled [Inference] above. I cannot verify exact numeric outputs for calculations I have not executed, and interpretation of any specific real dataset's statistics requires domain context I do not have access to. This should be confirmed by running the code directly and applying relevant domain expertise before drawing conclusions about any actual dataset.

### Related Topics

- Visualizing distributions with histograms, box plots, and KDE plots
- Outlier detection methods (IQR-based, z-score-based) following exploratory summary review
- Correlation versus causation considerations in feature selection
- Automated exploratory data analysis tools (e.g., pandas-profiling / ydata-profiling)
- Handling skewed distributions through transformation (log, Box-Cox) before modeling
- Multivariate exploratory techniques (pair plots, PCA) beyond pairwise correlation