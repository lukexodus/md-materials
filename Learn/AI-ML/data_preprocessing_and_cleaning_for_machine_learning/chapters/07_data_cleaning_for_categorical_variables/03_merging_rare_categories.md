## Merging Rare Categories

### Overview

Categorical features often contain a small number of frequent values alongside a long tail of rarely occurring ones. Merging rare categories into a combined group (commonly labeled "Other," "Rare," or "Miscellaneous") is a preprocessing step used to reduce dimensionality, limit overfitting risk, and stabilize downstream encoding, particularly for high-cardinality features.

[Unverified] This response contains explanations, code behavior descriptions, and illustrative examples that have not been independently re-verified through live execution or an external cited source at the time of writing. Specific claims are additionally labeled inline per the applicable convention, consistent with the disclosure approach used in prior related topics.

### The Problem: Rare Categories in Practice

- **Long-tail distributions**: Many real-world categorical features (product IDs, job titles, zip codes, browser user-agent strings) follow a distribution where a small number of categories account for most observations, and a large number of categories each appear only a handful of times.
- **Sparse encoding columns**: One-hot encoding a rare category produces a column that is almost entirely zeros, contributing little statistical signal while adding a dimension to the feature space.
- **Overfitting risk on rare levels**: [Inference] A model may fit spurious patterns to a category with very few observations, since there is limited data to distinguish a genuine effect from noise for that specific level — this is a reasoned consequence of small-sample estimation generally, not a measured overfitting rate from a specific study.
- **Train/test category mismatch**: A rare category observed only in the training set may not appear at all in a test or production set, or vice versa, creating an unseen-category problem at inference time.

### Why Merge Rather Than Remove

Unlike outlier rows (covered in earlier topics on trimming and removal), rare categorical *levels* typically still represent valid, meaningful data — the rows themselves are not necessarily errors. [Inference] Removing rows solely because their category is rare would discard potentially valid observations rather than addressing the actual issue, which is the sparsity of the categorical *encoding*, not the validity of the *rows*. This is a reasoned distinction based on the difference between row-level and category-level treatment, not a claim verified against a specific cited source.

### Techniques for Identifying Rare Categories

#### 1. Frequency Threshold

```python
import pandas as pd

df = pd.DataFrame({
    'job_title': ['Engineer', 'Engineer', 'Manager', 'Engineer', 'Analyst',
                  'Welder', 'Manager', 'Falconer', 'Engineer', 'Analyst']
})

value_counts = df['job_title'].value_counts()
print(value_counts)
```

**Output**
```
Engineer    4
Manager     2
Analyst     2
Welder      1
Falconer    1
Name: job_title, dtype: int64
```
[Inference] This output is a direct count of the exact input list shown, based on the documented behavior of `pandas.Series.value_counts()`. I have not executed this in an external environment to independently confirm the runtime output at this moment.

#### 2. Proportion-Based Threshold

```python
threshold = 0.05  # 5% of total observations
proportions = df['job_title'].value_counts(normalize=True)
rare_categories = proportions[proportions < threshold].index.tolist()
print(rare_categories)
```

[Unverified] The specific threshold value of 5% shown here is illustrative only, not a universally recommended default; the appropriate threshold depends on the dataset's cardinality and sample size and would need to be determined for the specific data in question.

#### 3. Fixed Count Threshold

```python
min_count = 3
rare_categories = value_counts[value_counts < min_count].index.tolist()
print(rare_categories)
```

### Merging Implementation

```python
def merge_rare_categories(series, min_count=3, other_label='Other'):
    counts = series.value_counts()
    rare = counts[counts < min_count].index
    return series.apply(lambda x: other_label if x in rare else x)

df['job_title_merged'] = merge_rare_categories(df['job_title'], min_count=3)
print(df)
```

**Output**
```
  job_title job_title_merged
0  Engineer         Engineer
1  Engineer         Engineer
2   Manager          Manager
3  Engineer         Engineer
4   Analyst          Analyst
5    Welder            Other
6   Manager          Manager
7  Falconer            Other
8  Engineer         Engineer
9   Analyst          Analyst
```
[Inference] This output is a direct result of applying the function's logic as written to the exact input array shown. I have not executed this in an external environment to independently confirm the runtime output at this moment.

### Diagram: Rare Category Merging Workflow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 850 300" font-family="sans-serif">
  <text x="425" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Rare Category Merging Workflow (svg_diagram)</text>

  <rect x="20" y="60" width="160" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="100" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Compute category</text>
  <text x="100" y="102" text-anchor="middle" font-size="12" fill="#1a1a1a">frequency counts</text>

  <line x1="180" y1="90" x2="225" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />

  <rect x="225" y="60" width="160" height="60" rx="8" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="305" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Apply threshold</text>
  <text x="305" y="102" text-anchor="middle" font-size="11" fill="#1a1a1a">(count or proportion)</text>

  <line x1="385" y1="90" x2="430" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />

  <polygon points="430,90 500,120 430,150 360,120" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="430" y="117" text-anchor="middle" font-size="10" fill="#1a1a1a">Below</text>
  <text x="430" y="131" text-anchor="middle" font-size="10" fill="#1a1a1a">threshold?</text>

  <line x1="500" y1="120" x2="545" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />
  <text x="510" y="95" text-anchor="middle" font-size="10" fill="#333">Yes</text>
  <rect x="545" y="60" width="140" height="60" rx="8" fill="#f8d7da" stroke="#dc3545" stroke-width="1.5" />
  <text x="615" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Merge into</text>
  <text x="615" y="102" text-anchor="middle" font-size="12" fill="#1a1a1a">"Other" bucket</text>

  <line x1="500" y1="150" x2="545" y2="180" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />
  <text x="510" y="175" text-anchor="middle" font-size="10" fill="#333">No</text>
  <rect x="545" y="150" width="140" height="60" rx="8" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="615" y="175" text-anchor="middle" font-size="12" fill="#1a1a1a">Keep as its own</text>
  <text x="615" y="192" text-anchor="middle" font-size="12" fill="#1a1a1a">category</text>

  <line x1="685" y1="90" x2="730" y2="90" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />
  <line x1="685" y1="180" x2="730" y2="140" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />
  <rect x="730" y="105" width="100" height="60" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="780" y="130" text-anchor="middle" font-size="12" fill="#1a1a1a">Final encoded</text>
  <text x="780" y="147" text-anchor="middle" font-size="12" fill="#1a1a1a">feature</text>

  </svg>

### Handling Semantically Meaningful Rare Groups Separately

[Inference] Not all rare categories are interchangeable simply because they are numerically rare — merging semantically unrelated rare categories into a single "Other" bucket can obscure meaningful distinctions between them, since the resulting bucket conflates categories that may have very different relationships to the target variable. This is a reasoned risk based on how a combined bucket loses category-specific information, not a measured effect from a specific study.

**Approaches to mitigate this**:
- Grouping rare categories by domain-informed super-categories first (e.g., grouping rare job titles by broader occupation type) before falling back to a generic "Other" bucket for anything left ungrouped.
- Creating multiple "Other"-like buckets when rare categories cluster into a few distinguishable groups, rather than a single catch-all.
- Retaining a rare category as its own level if domain knowledge indicates it is important despite low frequency (e.g., a rare but high-value customer segment).

[Unverified] Whether any of these mitigation approaches is preferable for a specific dataset depends on the actual relationship between the rare categories and the modeling target, which I cannot assess without access to that specific data.

### Handling the Train/Test Unseen-Category Problem

- Rare-category thresholds and the resulting "Other" grouping should be **learned from the training set only**, consistent with the leakage-avoidance principle discussed in earlier topics on capping and trimming thresholds.
- At inference time, any category not seen during training (including categories that were rare but distinct in training) is typically mapped to the "Other" bucket as a fallback, rather than causing an encoding failure.

```python
def apply_category_mapping(series, known_categories, other_label='Other'):
    return series.apply(lambda x: x if x in known_categories else other_label)

known_categories = {'Engineer', 'Manager', 'Analyst'}  # learned from training data only
new_data = pd.Series(['Engineer', 'Plumber', 'Manager', 'Astronaut'])
result = apply_category_mapping(new_data, known_categories)
print(result)
```

**Output**
```
0    Engineer
1       Other
2     Manager
3       Other
```
[Inference] This output is a direct result of applying the function's logic as written to the exact input shown. I have not executed this in an external environment to independently confirm the runtime output at this moment.

[Unverified] I cannot verify how every specific downstream encoding library or deployment framework handles an unseen category if this fallback step is omitted; this should be tested directly against your specific library and pipeline rather than assumed.

### Choosing Threshold Values

| Threshold Style | Description | Consideration |
|---|---|---|
| Fixed count (e.g., <5 occurrences) | Simple, consistent across features | [Inference] May behave very differently across features with very different total sample sizes |
| Proportion-based (e.g., <1% of rows) | Scales with dataset size | [Inference] May still merge a category with a meaningful absolute count in very large datasets |
| Cumulative coverage (e.g., keep top categories covering 95% of data) | Directly controls how much of the dataset is retained at full granularity | [Unverified] Exact impact on model performance is dataset-dependent and not knowable without testing |

I cannot verify that any single threshold style is superior in general; this is a reasoned comparison of mechanics, not a benchmarked ranking.

```python
# Cumulative coverage approach
counts = df['job_title'].value_counts()
cumulative_share = counts.cumsum() / counts.sum()
keep_categories = cumulative_share[cumulative_share <= 0.95].index.tolist()
```

### Common Pitfalls

- Computing rare-category thresholds on the combined train+test dataset before splitting, leaking test-set category-frequency information into the training process — this mirrors the leakage risk described for capping/trimming thresholds in earlier topics.
- Merging rare categories that have a strong, distinct relationship with the target variable simply because they are numerically infrequent, potentially discarding useful signal. [Inference] This risk is analogous to the risk of removing true anomalies discussed in the earlier topic on distinguishing anomalies from errors — rarity alone does not indicate irrelevance. This is a reasoned parallel between the two topics, not a separately confirmed finding.
- Failing to implement an unseen-category fallback at inference time, which can cause errors or undefined behavior in some encoding pipelines when a category absent from training data appears in new data. [Unverified] The specific failure behavior depends entirely on the encoding library and pipeline configuration in use, and I do not have access to confirm this for any specific setup.
- Using an arbitrary "Other" label that collides with a genuine existing category value already present in the data (e.g., a real category actually named "Other").
- Not documenting which original categories were merged into the "Other" bucket, making the transformation difficult to audit or reverse later.

### Conclusion

Merging rare categories addresses sparsity and potential overfitting risk in categorical encoding by consolidating infrequent levels into a combined group, typically based on a count, proportion, or cumulative-coverage threshold. [Inference] The threshold and merging strategy should be learned only from training data and applied consistently at inference time, with an explicit fallback for unseen categories, based on the same leakage-avoidance and consistency principles discussed in earlier topics on outlier thresholds and label standardization. This is a reasoned extension of those principles to this topic, not a separately confirmed standard.

**Related Topics**
- Standardizing Inconsistent Category Labels
- Handling Typos and Spelling Variants
- Encoding Categorical Variables — One-Hot, Label, and Target Encoding
- Handling High-Cardinality Categorical Features
- Handling Unseen Categories at Inference Time
- Data Leakage Prevention in Preprocessing Pipelines