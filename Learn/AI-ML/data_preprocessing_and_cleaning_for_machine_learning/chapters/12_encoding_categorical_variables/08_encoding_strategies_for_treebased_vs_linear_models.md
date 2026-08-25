## Encoding Strategies for Tree-Based vs. Linear Models

### Overview

The choice of categorical encoding strategy should account for how the downstream model actually consumes numeric input. Tree-based models and linear models interpret encoded features in fundamentally different ways, which changes which encoding tradeoffs matter most. This topic consolidates the model-specific guidance touched on across individual encoding methods into a direct comparison.

### Core Mechanical Difference

- **Linear models** (linear regression, logistic regression, linear SVM) compute a weighted sum of feature values: $\hat{y} = \sum_i w_i x_i + b$. This means the encoded numeric value itself carries direct, continuous meaning — larger values contribute proportionally more (or less, if the weight is negative) to the prediction. Any false numeric relationship introduced by an encoding method (e.g., implying green > blue > red) directly distorts this weighted sum.
- **Tree-based models** (decision trees, random forests, gradient boosting) make decisions via threshold splits: `is feature_x <= v?`. The model only cares about the relative ordering of values at each split point, not the magnitude or distance between them in a continuous sense. This makes trees comparatively more tolerant of encodings that introduce arbitrary numeric structure, since a split can still partition categories into useful groups across multiple splits even without a meaningful ordinal relationship.

This distinction is a well-documented structural property of how these model families compute predictions, not an inference.

### Encoding Suitability by Model Type

| Encoding Method | Linear Models | Tree-Based Models |
| --- | --- | --- |
| One-hot encoding | Well suited (standard choice) | Usable, but can reduce split efficiency on high-cardinality features |
| Label encoding (nominal data) | Poorly suited (false ordinal relationship distorts weighted sum) | [Inference] Often tolerated, since splits can still partition arbitrary numeric groupings |
| Ordinal encoding (true ordinal data) | Well suited, if spacing assumption is reasonable | Well suited, less sensitive to spacing assumptions |
| Target/mean encoding | Usable, but leakage-driven overfitting may show up as coefficient instability | Well suited; dense single-column signal works well with splits |
| Frequency/count encoding | [Inference] Usable if frequency has a roughly linear or monotonic relationship with the target | Well suited; splits handle frequency thresholds naturally |
| Binary encoding | [Inference] May introduce subtle bit-pattern artifacts affecting coefficients | Generally compatible; splits handle bit columns individually |
| Hashing trick | Commonly used in large-scale sparse linear pipelines (e.g., text) | [Inference] Collisions may dilute split information more than for linear models |

Rows marked [Inference] reflect reasoned extensions of each model family's mechanics rather than benchmarked comparisons on a specific dataset, consistent with how these points were qualified in each method's dedicated discussion.

### Why Linear Models Are More Encoding-Sensitive

Linear models assume:

1. A consistent, additive relationship between each feature and the target.
2. That the numeric distance between values is meaningful (e.g., the "distance" between encoded value 1 and 2 should reflect something real about the underlying categories).

When these assumptions are violated — such as label-encoding nominal data — the model has no mechanism to "correct" for the false relationship on its own. The weighted sum will treat the false numeric relationship as real signal, which can misdirect the learned coefficients.

- Regularized linear models (Ridge, Lasso) do not resolve this issue on their own, since regularization controls coefficient magnitude, not the validity of the assumed numeric relationship between encoded categories.

### Why Tree-Based Models Are More Encoding-Tolerant (With Limits)

Trees do not assume a consistent additive or linear relationship between a feature's numeric value and the target. Instead, each split simply asks whether a value falls above or below a threshold, and the tree can combine multiple splits on the same feature to approximate more complex, non-monotonic relationships.

- [Inference] This is why label encoding on nominal data, which would badly distort a linear model, is often considered acceptable for tree-based models — the tree can still learn to separate "green" from "blue" and "red" via multiple splits, even though the assigned integers (0, 1, 2) don't reflect a true order. This reasoning follows from how split-based partitioning works mechanically, and is a widely repeated practical heuristic, but I cannot verify its magnitude of impact across specific datasets without direct benchmarking.
- This tolerance is not unlimited: [Inference] very high-cardinality label-encoded features may still require many splits to capture meaningful groupings, and one-hot or target encoding may still outperform label encoding in some cases even for tree-based models. I do not have a reliable general basis to state which approach is better for trees across all cardinality levels and datasets.

### Decision Framework

===MERMAID_DIAGRAM===

flowchart TD

A[Categorical feature] --> B{Downstream model type}

B -->|Linear/Distance-based/Neural network| C{Does feature have true order?}

C -->|Yes| D[Ordinal encoding with explicit order]

C -->|No| E{Cardinality level}

E -->|Low| F[One-hot encoding]

E -->|High| G["Target encoding with k-fold, or frequency/hashing"]

B -->|Tree-based| H{Cardinality level}

H -->|Low| I["One-hot or label encoding both commonly used"]

H -->|High| J["Target, frequency, or label encoding; native categorical support if available"]

### Native Categorical Support in Tree Libraries

Some gradient boosting implementations, such as LightGBM and CatBoost, support categorical features natively without requiring explicit encoding, using specialized internal split-finding algorithms designed for categorical data.

- This is documented behavior for these specific libraries. [Unverified] The exact internal algorithm details and performance characteristics differ between LightGBM's and CatBoost's native categorical handling, and I do not have a verified basis to compare their relative effectiveness without referring to each library's current documentation and any independent benchmarks.
- When native categorical support is available and used, it can reduce or eliminate the need for manual encoding steps such as one-hot, label, or target encoding for that specific model.

### Practical Example

Consider a feature `payment_method` with categories: credit_card, debit_card, paypal, bank_transfer (nominal, no true order).

- **For logistic regression:** One-hot encoding (dropping one category to avoid the dummy variable trap) is the standard, well-suited choice, since it avoids implying any false numeric relationship between payment methods.
- **For a gradient boosting model:** Label encoding, one-hot encoding, or native categorical handling (if using LightGBM/CatBoost) are all commonly used, since the tree's split mechanics do not depend on the encoded values having a real numeric relationship.

### Common Pitfalls

- Applying label encoding to nominal features for linear models, introducing a false relationship that directly distorts the weighted sum computation.
- Assuming tree-based models are completely indifferent to encoding choice — while more tolerant than linear models, encoding still affects split efficiency and the number of splits required to capture a pattern.
- Overlooking native categorical support in libraries like LightGBM or CatBoost, leading to unnecessary manual encoding steps.
- Using the same encoding strategy across all models in an ensemble (e.g., a mix of linear and tree-based models) without considering that the optimal encoding may differ between them.

### Key Points

- Linear models compute a weighted sum where the numeric value of an encoded feature carries direct, continuous meaning, making them sensitive to false ordinal relationships.
- Tree-based models split on thresholds and are comparatively more tolerant of arbitrary numeric encodings, though this tolerance is not unlimited, particularly at high cardinality.
- [Inference] The practical heuristic that "trees tolerate label encoding better than linear models" follows from documented split mechanics, but its magnitude of impact on any specific dataset has not been benchmarked here.
- Some gradient boosting libraries (LightGBM, CatBoost) offer native categorical handling that can reduce the need for manual encoding, though their internal implementations differ and are not compared here in detail.
- Encoding strategy should be chosen per model type rather than applied uniformly across an entire modeling pipeline that mixes model families.

**Related Topics**

- Native categorical feature handling in LightGBM and CatBoost
- One-hot encoding and the dummy variable trap
- Target and mean encoding leakage mitigation strategies
- Frequency and count encoding for high-cardinality features
- Choosing encoding strategy alongside feature scaling decisions