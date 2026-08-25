## Cardinality Analysis for Categorical Features

### Purpose

Cardinality analysis measures the number of unique values in a categorical column. This determines which encoding strategy is feasible, whether a column is likely miscategorized as categorical, and whether dimensionality problems will arise downstream in a machine learning pipeline.

### Why This Matters for Cleaning

**Key Points**
- Low-cardinality columns are generally straightforward to one-hot encode without creating excessive dimensionality
- High-cardinality columns can cause one-hot encoding to produce an impractically large number of sparse feature columns
- Extremely high cardinality (near or equal to row count) often signals that a column is actually an identifier, not a genuine categorical feature
- Cardinality directly informs the choice between one-hot encoding, target encoding, frequency encoding, hashing, or embedding-based approaches

### Measuring Cardinality

```python
import pandas as pd

df = pd.read_csv("customers.csv")

df["country"].nunique()
df["customer_id"].nunique()

cardinality = df.select_dtypes(include="object").nunique().sort_values(ascending=False)
print(cardinality)
```

`nunique()` is a documented, standard pandas method that counts the number of distinct non-null values in a column by default.

### Cardinality as a Proportion of Row Count

Raw unique-value counts are more informative when compared against total row count, since a column with 500 unique values means something different in a dataset of 600 rows versus one of 600,000 rows.

```python
total_rows = len(df)

cardinality_ratio = df.select_dtypes(include="object").nunique() / total_rows
print(cardinality_ratio.sort_values(ascending=False))
```

**Example**

If `customer_id` has a cardinality ratio close to $1.0$ (i.e., nearly every value is unique), this suggests the column functions as an identifier rather than a meaningful categorical feature for modeling, and it is commonly excluded from the feature set used to train a model, since a column where nearly every value is unique per row provides no generalizable pattern to learn from. [Inference] This is a reasoned conclusion based on how identifier-like columns behave in typical modeling contexts; whether a specific column should actually be excluded still depends on the particular use case, since in some tasks an ID-like column encodes real information (e.g., a ZIP code, which is technically a numeric identifier but often carries meaningful geographic signal).

### Classifying Columns by Cardinality Level

| Cardinality range (approximate) | Common classification | Typical encoding approach |
|---|---|---|
| 2 unique values | Binary | Map to 0/1 |
| 3–15 unique values | Low cardinality | One-hot encoding |
| 16–100 unique values | Moderate cardinality | Target encoding, frequency encoding, or grouped one-hot |
| 100+ unique values | High cardinality | Target encoding, hashing, embeddings, or grouping rare categories |
| Near-equal to row count | Likely an identifier | Typically excluded from features |

[Speculation] The specific numeric thresholds shown above (e.g., 15, 100) are illustrative reference points commonly discussed in practitioner guidance, not a fixed or universally agreed standard. I do not have access to information confirming a single authoritative cutoff, and the appropriate threshold for any specific dataset depends on the modeling algorithm, available compute, and dataset size.

### Visualizing Cardinality Across Columns

```python
import matplotlib.pyplot as plt

cardinality.plot(kind="barh", figsize=(8, 6))
plt.xlabel("Number of Unique Values")
plt.title("Cardinality by Categorical Column")
plt.gca().invert_yaxis()
plt.show()
```

<svg viewBox="0 0 640 280" xmlns="http://www.w3.org/2000/svg">
  <text x="320" y="24" font-size="15" font-weight="bold" text-anchor="middle" fill="#1f2937">Cardinality by Column (svg_diagram)</text>

  <line x1="180" y1="50" x2="180" y2="250" stroke="#374151" stroke-width="1.5"/>

  <text x="170" y="70" font-size="11" text-anchor="end" fill="#1f2937">customer_id</text>
  <rect x="185" y="58" width="400" height="20" fill="#ef4444"/>
  <text x="595" y="73" font-size="10" fill="#1f2937">10,000</text>

  <text x="170" y="105" font-size="11" text-anchor="end" fill="#1f2937">email</text>
  <rect x="185" y="93" width="395" height="20" fill="#ef4444"/>
  <text x="590" y="108" font-size="10" fill="#1f2937">9,950</text>

  <text x="170" y="140" font-size="11" text-anchor="end" fill="#1f2937">city</text>
  <rect x="185" y="128" width="90" height="20" fill="#f59e0b"/>
  <text x="280" y="143" font-size="10" fill="#1f2937">240</text>

  <text x="170" y="175" font-size="11" text-anchor="end" fill="#1f2937">product_category</text>
  <rect x="185" y="163" width="35" height="20" fill="#059669"/>
  <text x="225" y="178" font-size="10" fill="#1f2937">18</text>

  <text x="170" y="210" font-size="11" text-anchor="end" fill="#1f2937">country</text>
  <rect x="185" y="198" width="20" height="20" fill="#059669"/>
  <text x="210" y="213" font-size="10" fill="#1f2937">12</text>

  <text x="170" y="245" font-size="11" text-anchor="end" fill="#1f2937">is_active</text>
  <rect x="185" y="233" width="5" height="20" fill="#2563eb"/>
  <text x="195" y="248" font-size="10" fill="#1f2937">2</text>
</svg>

### Cardinality's Effect on One-Hot Encoding Dimensionality

One-hot encoding creates one new binary column per unique category. This means the number of resulting columns scales directly with cardinality.

$$\text{new columns} = k - 1 \text{ (with drop-first)} \quad \text{or} \quad k \text{ (without drop-first)}$$

where $k$ is the number of unique categories. This is a direct, deterministic consequence of how one-hot encoding is defined, not an estimate.

**Example**

A `product_category` column with 18 unique values produces 17 or 18 new binary columns after one-hot encoding, depending on whether a reference category is dropped. A `customer_id`-like column with 10,000 unique values would produce roughly 10,000 new columns, which is generally impractical for most modeling workflows in terms of both memory usage and the sparsity of the resulting feature matrix. [Inference] The claim that this is "generally impractical" is a reasoned inference based on how sparse, high-dimensional feature matrices are commonly discussed in machine learning practice as increasing memory usage and the risk of overfitting; the actual practical impact depends on the specific model, library, and available compute resources, which I cannot verify without testing that specific setup.

### Decision Flow for Handling Cardinality

```plaintext
===MERMAID_DIAGRAM===
flowchart TD
    A["Categorical column"] --> B["Compute nunique() and cardinality ratio"]
    B --> C{"Ratio near 1.0?"}
    C -- Yes --> D["Likely an identifier — consider excluding from features"]
    C -- No --> E{"Cardinality level?"}
    E -- Low --> F["One-hot encoding"]
    E -- Moderate --> G["Target or frequency encoding, or grouped one-hot"]
    E -- High --> H["Group rare categories, hashing, or target encoding"]
```

### Detecting High Cardinality Combined with Rare Categories

A high-cardinality column often also has a long tail of rare categories, which frequency counts can quantify directly.

```python
value_counts = df["city"].value_counts()
top_n_coverage = value_counts.head(20).sum() / len(df) * 100

print(f"Unique cities: {df['city'].nunique()}")
print(f"Top 20 cities cover {top_n_coverage:.2f}% of rows")
```

If a small number of top categories cover a large majority of rows, grouping the remaining long tail into an `"other"` category is a common strategy to reduce effective cardinality while retaining most of the signal. [Inference] This is a reasoned, commonly used approach; whether it preserves enough predictive signal for a specific task depends on whether the rare categories carry meaningful information for that task, which cannot be determined without domain knowledge of the specific dataset.

### Common Pitfalls

- Treating a numeric-looking identifier column (e.g., zip code, phone number) as a plain number rather than recognizing it as categorical
- One-hot encoding a high-cardinality column without checking cardinality first, leading to memory issues or excessively sparse matrices
- Ignoring that cardinality can change between training and production data — new unseen categories at inference time require an explicit handling strategy (e.g., an "unknown" bucket)
- Assuming cardinality alone determines feature importance — a low-cardinality column is not automatically more or less predictive than a high-cardinality one

### Related Topics

- Encoding strategies for categorical variables (one-hot, target, frequency, hashing, embeddings)
- Handling unseen categories at inference time
- Grouping rare categories into an "other" bucket
- Feature selection and dimensionality reduction after encoding
- Identifying identifier-like columns that should be excluded from modeling
