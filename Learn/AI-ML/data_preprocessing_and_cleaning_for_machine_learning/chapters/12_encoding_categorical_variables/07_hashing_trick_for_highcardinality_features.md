## Hashing Trick for High-Cardinality Features

### Overview

The hashing trick maps categorical values to a fixed number of columns using a hash function, rather than allocating one column per unique category. It is commonly used for very high-cardinality features where even compact encodings like binary encoding produce too many columns, or where the set of possible categories is unknown or unbounded in advance (e.g., streaming data with new categories appearing continuously).

### Mechanics

A hash function maps each category (typically a string) to an integer, which is then reduced to a fixed range via a modulo operation:

$$\text{index}(c) = \text{hash}(c) \bmod D$$

where $D$ is the predetermined number of output dimensions (buckets), chosen in advance regardless of how many unique categories actually exist in the data.

**Example with $D = 4$ buckets:**

| Category | hash(category) | index (hash mod 4) |
| --- | --- | --- |
| Lagos | 8215 | 3 |
| Tokyo | 4102 | 2 |
| Paris | 9981 | 1 |
| Berlin | 3344 | 0 |

Each category is then represented as a one-hot-style vector of length $D$, with a 1 placed at its computed index.

```python
from sklearn.feature_extraction import FeatureHasher

hasher = FeatureHasher(n_features=8, input_type='string')
hashed = hasher.transform(df['city'])
```

`FeatureHasher` is a documented scikit-learn implementation of the hashing trick, commonly used for high-cardinality categorical and text features.

### Why the Hashing Trick Is Useful

- **Fixed dimensionality regardless of cardinality:** The number of output columns $D$ is set in advance and does not grow with the number of unique categories, unlike one-hot encoding.
- **Handles unseen categories natively:** Since encoding does not require a predefined vocabulary or mapping learned from training data, a category never seen during training can still be hashed into a valid bucket at inference time without raising an error. This is a structural property of the technique, not something requiring special configuration, unlike one-hot or label encoding.
- **Memory efficiency for streaming or online learning:** Because no lookup table needs to be stored (the hash function is computed on the fly), the hashing trick is well suited to contexts where the full category vocabulary is not known in advance or would be too large to store in memory.

### Key Limitation: Hash Collisions

Because $D$ is fixed and typically much smaller than the number of unique categories, multiple distinct categories can map to the same bucket index. This is known as a **hash collision**.

$$\text{index}(c_1) = \text{index}(c_2) \quad \text{for } c_1 \neq c_2$$

When a collision occurs, the model cannot distinguish between the colliding categories based on that feature representation alone, since they occupy the identical position in the encoded vector.

- [Inference] The probability of collisions increases as the number of unique categories approaches or exceeds $D$, and decreases as $D$ is set larger relative to the number of unique categories. This follows from basic probability reasoning about hash functions distributing values across a fixed number of buckets (similar to the birthday paradox), rather than from a specific empirical measurement on a given dataset.
- [Unverified] The exact practical impact of collisions on model performance for any specific dataset cannot be stated as a general fact, since it depends on the chosen value of $D$, the true cardinality of the feature, and how much predictive signal is tied to the specific colliding categories.

### Choosing the Number of Buckets ($D$)

Selecting $D$ involves a tradeoff:

- **Smaller $D$:** More memory-efficient and produces a more compact feature representation, but increases the likelihood of collisions.
- **Larger $D$:** Reduces collision likelihood, approaching the behavior of one-hot encoding as $D$ approaches or exceeds the true number of unique categories, but sacrifices some of the dimensionality reduction benefit that motivates using the hashing trick in the first place.

[Inference] A common practical heuristic is to set $D$ to a power of 2 that is comfortably larger than the expected number of unique categories, though the specific multiplier or margin used varies across practitioners and is not a strictly standardized rule documented as a formal specification.

### Signed Hashing to Reduce Collision Bias

Some implementations, including scikit-learn's `FeatureHasher`, use a secondary hash function to determine a sign (+1 or -1) applied to the value placed at the computed index, rather than always using +1.

- **Purpose:** [Inference] When two categories collide at the same index, assigning them opposite signs causes their contributions to partially offset rather than simply accumulate, which can reduce (though not fully eliminate) the systematic bias introduced by collisions. This is a documented design choice in the underlying algorithm's construction, though the degree to which it mitigates collision impact in practice depends on the specific data and cannot be generalized as a fixed quantitative benefit without testing.

### Model Compatibility

===MERMAID_DIAGRAM===

flowchart TD

A[Very high-cardinality or open-ended categorical feature] --> B{Is memory or unseen-category handling the primary concern?}

B -->|Yes| C[Hashing trick suitable]

B -->|No, interpretability matters more| D["Consider one-hot, target, or frequency encoding instead"]

C --> E{Choose D relative to expected cardinality}

E --> F["Larger D: fewer collisions, less dimensionality reduction"]

E --> G["Smaller D: more collisions, more dimensionality reduction"]

- **Linear models and SVMs:** The hashing trick is commonly used in large-scale text classification pipelines (e.g., bag-of-words with hashed features) paired with linear models, since these models can operate efficiently on the resulting sparse, fixed-dimensional representation.
- **Tree-based models:** [Inference] Hash-collided features may be harder for tree-based models to split on meaningfully, since a single hashed bucket may represent multiple unrelated categories with different relationships to the target, diluting the information available at each split point. I cannot verify the magnitude of this effect without testing on specific data.
- **Neural networks:** The hashing trick is sometimes used as a preprocessing step before embedding layers, particularly in large-scale recommendation systems, to bound the size of an embedding lookup table when the true vocabulary size is very large or unbounded. [Unverified] Specific architectural choices and their relative effectiveness vary widely across systems and cannot be generalized as a single standard approach without reference to a specific implementation.

### Hashing Trick vs. Other High-Cardinality Methods

| Method | Fixed Output Size | Handles Unseen Categories Natively | Collision Risk |
| --- | --- | --- | --- |
| One-hot encoding | No (grows with cardinality) | No | None |
| Target/mean encoding | Yes (1 column) | No (requires fallback) | None |
| Frequency encoding | Yes (1 column) | No (requires fallback) | None (but loses identity for equal frequencies) |
| Binary encoding | Yes (log-scaled) | No (requires fallback) | None |
| Hashing trick | Yes (fixed $D$) | Yes, natively | Yes |

### Common Pitfalls

- Setting $D$ too small relative to the actual number of unique categories, leading to a high collision rate that meaningfully degrades the feature's usefulness.
- Assuming hashed features are interpretable in the same way as one-hot encoded features — individual bucket indices do not correspond to specific, identifiable categories, since multiple categories may share a bucket.
- Using the hashing trick when the full category vocabulary is small and known in advance, where simpler methods like one-hot encoding would avoid collision risk entirely with little additional cost.
- Not accounting for collision-related noise when interpreting model coefficients or feature importance scores tied to hashed columns.

### Key Points

- The hashing trick maps categories to a fixed number of buckets using a hash function, avoiding the need for a predefined category vocabulary.
- It natively supports unseen categories at inference time, unlike most other categorical encoding methods, since no training-derived lookup table is required.
- Hash collisions are an inherent, documented tradeoff of the technique, and their practical impact depends on the ratio between the true cardinality and the chosen number of buckets $D$.
- [Inference] Signed hashing can partially offset collision-related bias, based on the documented design of the underlying algorithm, though the practical magnitude of this mitigation is [Unverified] without testing on specific data.
- The hashing trick is commonly used in large-scale text and recommendation system pipelines where memory efficiency and unseen-category handling are priorities over interpretability.

I do not have access to confirm exact default parameter behaviors (e.g., hash function choice, sign hashing defaults) for library versions not specified here; such details should be checked against current official documentation.

**Related Topics**

- Binary encoding as a lower-collision-risk alternative for moderate cardinality
- Embedding layers and their relationship to hashed feature inputs
- Sparse matrix representations and their computational tradeoffs
- Online/streaming learning pipelines and encoding strategies suited to them
- Feature hashing in text classification (bag-of-words and n-gram hashing)