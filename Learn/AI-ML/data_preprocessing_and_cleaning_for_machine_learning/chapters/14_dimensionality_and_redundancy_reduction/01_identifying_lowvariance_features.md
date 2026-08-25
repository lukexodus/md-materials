## Identifying Low-Variance Features

### Overview

Low-variance feature identification is a filter-based feature selection technique that flags or removes features with little to no variability across observations. A feature that takes nearly the same value for almost every row carries little information that a model can use to distinguish between outcomes, regardless of the modeling approach used downstream.

### Core Rationale

If a feature's value barely changes across the dataset, it cannot meaningfully help a model separate one observation from another, since there is little to no variation for the model to associate with differences in the target variable.

**Extreme case:** A constant feature — one that has exactly the same value in every single row — has zero variance and provides no discriminative information whatsoever. This is a direct mathematical consequence of variance being zero, not an inference.

**Near-constant case:** A feature where 99.9% of rows share the same value, with only a tiny fraction differing, provides very little practical signal for most models, even though its variance is technically nonzero.

### Measuring Variance

For a numeric feature $x$ with $n$ observations and mean $\bar{x}$, variance is computed as:

$$\text{Var}(x) = \frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{x})^2$$

```python
df.var()
```

pandas' `.var()` method is documented to compute the variance of each numeric column in a DataFrame by default.

### VarianceThreshold in scikit-learn

scikit-learn provides a dedicated transformer for this exact purpose:

```python
from sklearn.feature_selection import VarianceThreshold

selector = VarianceThreshold(threshold=0.01)
X_reduced = selector.fit_transform(X)
```

`VarianceThreshold` is documented to remove all features whose variance does not meet a specified threshold. By default, with `threshold=0`, it removes only features with zero variance (i.e., constant features); a nonzero threshold removes features with variance below that specified value as well.

### The Scale Dependency Problem

Variance is measured in the squared units of the original feature, which means variance values are not directly comparable across features with different scales.

**Example:** A feature measured in kilometers (e.g., distance, ranging 0–5) will have a numerically much smaller variance than a feature measured in meters covering a similar relative spread (e.g., 0–5,000), purely due to the unit of measurement, not because one feature is actually "more constant" than the other in a meaningful sense.

- [Inference] This means applying a single fixed variance threshold across features with very different scales or units can produce misleading results, since a threshold appropriate for one feature's scale may be far too strict or too lenient for another feature measured in different units. This follows directly from how variance scales mathematically with the underlying units, not from a benchmarked comparison on a specific dataset.
- **Common mitigation:** Applying feature scaling (e.g., StandardScaler, as covered in the feature scaling topic) before computing variance, or computing the coefficient of variation ($\text{CV} = \sigma / \mu$) as a scale-independent alternative, allows more meaningful comparison of relative variability across features with different original units.

### Low-Variance Detection for Categorical Features

For categorical (non-numeric) features, "variance" in the statistical sense above does not directly apply, since these features are not raw numeric quantities. Instead, features are typically checked for how frequently the single most common category occurs relative to the total number of observations.

```python
df['category_col'].value_counts(normalize=True).iloc[0]
```

If the most frequent category represents a very high proportion of all observations (e.g., 99.5%), the feature is effectively near-constant in the same conceptual sense as a low-variance numeric feature, even though variance itself is not the exact statistic being computed.

- [Inference] A commonly used informal heuristic is to flag categorical features where a single category accounts for more than roughly 95–99% of observations as candidates for removal, though I do not have a single authoritative source establishing this specific percentage range as a formally standardized threshold, and the appropriate cutoff depends on dataset size and the specific modeling context.

### Why Low-Variance Features Can Still Matter in Specific Contexts

Removing low-variance features is not universally appropriate in every situation:

- [Inference] A near-constant feature might still carry meaningful signal if its rare, non-dominant values correspond strongly to a specific outcome (e.g., a rare sensor reading that almost always indicates equipment failure), even though the feature has very low overall variance. In such cases, removing the feature purely based on a variance threshold could discard genuinely useful predictive information. This is a reasoned exception based on how variance-based filtering ignores the relationship between the feature and the target, not a benchmarked finding for a specific dataset.
- Variance-based filtering, including `VarianceThreshold`, evaluates each feature independently and does not consider the feature's relationship with the target variable at all. This is a documented characteristic of the technique's design, not an inference — it is explicitly a univariate, target-agnostic filter method.

### Decision Path

===MERMAID_DIAGRAM===

flowchart TD

A[Feature under evaluation] --> B{Numeric or categorical?}

B -->|Numeric| C[Compute variance, ideally after scaling for comparability]

B -->|Categorical| D[Compute proportion of most frequent category]

C --> E{Variance below threshold?}

D --> F{Dominant category proportion very high?}

E -->|Yes| G{Rare values strongly tied to target?}

F -->|Yes| G

G -->|Yes| H["[Inference] Consider retaining despite low variance"]

G -->|No or unknown| I[Candidate for removal]

E -->|No| J[Retain feature]

F -->|No| J

### Relationship to Other Feature Selection Methods

Low-variance filtering is typically applied as an early, computationally inexpensive preprocessing step, prior to more sophisticated feature selection techniques that do consider the relationship between features and the target (such as univariate statistical tests, recursive feature elimination, or model-based feature importance).

- [Inference] Because low-variance filtering is target-agnostic and computationally simple, it is commonly used as a first-pass filter to remove obviously uninformative features before applying more computationally expensive, target-aware selection methods to the remaining feature set. This is a commonly described practical workflow in feature selection literature, though I do not have a single authoritative source confirming this exact ordering as a formally mandated standard practice.

### Common Pitfalls

- Applying a single fixed variance threshold across features with substantially different scales or units without first standardizing them or using a scale-independent measure like coefficient of variation.
- Removing a low-variance feature without checking whether its rare values are strongly associated with the target variable, potentially discarding useful predictive signal.
- Computing variance (or dominant category proportion) on the full dataset, including validation or test data, before splitting — the same train/test leakage concern that applies broadly to preprocessing steps, including this one.
- Assuming `VarianceThreshold`'s default `threshold=0` setting removes anything beyond exactly constant features; nonzero thresholds must be explicitly set to remove near-constant features.

### Key Points

- Low-variance features provide little discriminative information for a model, with a constant feature (zero variance) providing none at all — a direct mathematical consequence, not an inference.
- Variance is scale-dependent, so applying a single threshold across differently-scaled features requires either prior standardization or a scale-independent measure such as coefficient of variation.
- Categorical features are typically assessed for near-constancy via the proportion of the most frequent category, rather than variance directly, since variance is not defined the same way for non-numeric data.
- [Inference] Removing low-variance features can discard useful signal in cases where rare values are strongly associated with the target, since variance-based filtering does not consider the target variable at all — this is a documented, target-agnostic characteristic of the method's design.
- Low-variance filtering is commonly used as an inexpensive first-pass step before more sophisticated, target-aware feature selection methods, though I do not have a single authoritative source confirming this ordering as a universally mandated workflow.

I cannot verify a single universally standardized variance or frequency threshold applicable across all datasets and modeling contexts; appropriate thresholds are dataset- and problem-specific and should be validated empirically.

**Related Topics**

- Feature scaling as a prerequisite for meaningful variance comparison across features
- Univariate statistical feature selection (e.g., chi-squared, ANOVA F-test)
- Correlation-based redundant feature removal
- Recursive feature elimination and model-based feature importance
- Coefficient of variation as a scale-independent variability measure