## Frequency and Count Encoding

### Overview

Frequency encoding (also called count encoding) replaces each category with either the number of times it appears in the dataset (count encoding) or the proportion of total observations it represents (frequency encoding). It is a simple, leakage-free technique commonly used for high-cardinality categorical features as an alternative to target encoding or one-hot encoding.

### Mechanics

For count encoding, each category $c$ is replaced with the number of rows in the dataset where that category occurs:

$$\text{encoded}(c) = n_c$$

For frequency encoding, the count is normalized by the total number of observations $N$:

$$\text{encoded}(c) = \frac{n_c}{N}$$

**Example:**

| city | count | frequency |
| --- | --- | --- |
| Lagos | 3 | 0.30 |
| Tokyo | 5 | 0.50 |
| Paris | 2 | 0.20 |

(assuming 10 total rows)

```python
freq_map = df['city'].value_counts(normalize=True)
df['city_freq'] = df['city'].map(freq_map)
```

`value_counts(normalize=True)` is documented pandas behavior that returns the relative frequency of each unique value.

### Why Frequency Encoding Is Useful

- **Dimensionality:** Like target encoding, frequency encoding produces a single numeric column regardless of how many unique categories exist, making it well-suited for high-cardinality features such as `zip_code`, `user_id`, or `product_id`.
- **No target leakage:** Since frequency encoding is derived purely from the distribution of the categorical feature itself, and not from the target variable, it does not carry the target leakage risk associated with target/mean encoding.
- **Simplicity:** The computation is straightforward and computationally inexpensive compared to more complex encoding schemes like k-fold target encoding.

### Key Limitation: Loss of Category Identity

Frequency encoding introduces a specific structural limitation: **categories with the same frequency become indistinguishable to the model**, even if they represent entirely different real-world categories.

**Example:** If both "Lagos" and "Berlin" each appear exactly 3 times in the dataset, they will both be encoded as the same value (3, or 0.30 in frequency terms). Any model using this encoded feature cannot differentiate between Lagos and Berlin based on this column alone, even though they may have very different relationships with the target variable.

This is a direct mathematical consequence of the encoding method — it maps categories to values based only on their occurrence rate, not on their identity or relationship to any outcome.

- [Inference] The practical impact of this limitation depends on how many categories share similar frequencies in a given dataset, and how much predictive signal is actually tied to category identity versus category frequency itself. I cannot verify the extent of this impact without testing on a specific dataset.

### When Frequency Encoding Is Appropriate

Frequency encoding tends to work well when:

- The frequency (or rarity) of a category itself carries predictive signal. For example, in fraud detection, a rarely used `merchant_id` might itself be informative regardless of the merchant's specific identity.
- High cardinality makes one-hot encoding impractical, and target encoding's leakage risk or implementation complexity is undesirable.
- The feature is being used with tree-based models, which can effectively split on frequency-derived values as thresholds.

### When Frequency Encoding Is Inappropriate

- When distinct categories with similar frequencies have meaningfully different relationships with the target variable, frequency encoding will fail to capture that distinction, since it collapses them to the same encoded value.
- [Inference] For nominal categories where identity matters more than occurrence rate (e.g., `color` in a product recommendation context, where a specific color might be strongly preferred regardless of how often it appears in the dataset), frequency encoding may discard meaningful information that one-hot or target encoding would otherwise preserve. This is a reasoned limitation based on the mechanics of the encoding, not a benchmarked result for any specific use case.

### Model Compatibility

===MERMAID_DIAGRAM===

flowchart TD

A[High-cardinality categorical feature] --> B{Is frequency itself predictive?}

B -->|Yes| C[Frequency or count encoding suitable]

B -->|No, category identity matters more| D["Consider target encoding, hashing, or embeddings"]

C --> E{Model type}

E -->|Tree-based| F[Well suited: splits on frequency thresholds effectively]

E -->|Linear/Distance-based| G["[Inference] May work, but assumes frequency has a linear or distance-meaningful relationship with target"]

- **Tree-based models:** Frequency encoding is commonly used with tree-based models, since these models can split on the frequency-derived value as an effective threshold, without assuming any particular linear relationship between the encoded value and the target.
- **Linear models:** [Inference] Using frequency encoding with linear models assumes that the relationship between a category's frequency and the target is roughly linear or monotonic, which may not hold for all datasets. I cannot verify whether this assumption holds without testing on specific data.
- **Distance-based models (k-NN, k-Means):** Frequency-encoded values will directly affect distance calculations, treating categories with similar frequencies as "close" to one another, regardless of their actual real-world relationship.

### Count Encoding vs. Frequency Encoding

The two variants (raw count vs. normalized frequency) are mathematically related by a constant scaling factor ($N$, the total number of observations):

$$\text{frequency}(c) = \frac{\text{count}(c)}{N}$$

- For models sensitive to feature scale (e.g., linear models, neural networks, distance-based models), the choice between raw counts and normalized frequency may matter for numerical stability, since raw counts can vary widely in magnitude across datasets of different sizes.
- For tree-based models, since splits are threshold-based and the transformation between count and frequency is purely a constant scaling factor, [Inference] the practical outcome of using one versus the other is likely to be very similar for a given dataset, though this is a reasoned mathematical observation rather than a benchmarked comparison across specific implementations.

### Handling Unseen Categories at Inference Time

A category not seen during training will not have an associated count or frequency value computed from the training data. Common approaches include:

- Assigning a value of 0 (or a small constant) to represent an unseen, and therefore assumed rare, category.
- Assigning the minimum observed frequency from the training set as a fallback estimate.

[Unverified] There is no single universally standardized default approach for handling unseen categories in frequency encoding across libraries, since, unlike scikit-learn's built-in encoders, frequency encoding is often implemented manually using pandas rather than through a dedicated library class with documented defaults. This should be explicitly designed and validated for a given pipeline rather than assumed.

### Common Pitfalls

- Computing frequency or count encoding using the combined training and test datasets, which introduces data leakage similar to fitting any other encoder on the full dataset before splitting.
- Not accounting for unseen categories at inference time, which can result in missing or undefined encoded values in production.
- Assuming frequency encoding preserves the same information as target encoding — it does not, since it reflects only occurrence rate, not any relationship with the target variable.
- Using frequency encoding when multiple distinct categories share similar frequencies and the model needs to distinguish between them based on identity, not just occurrence rate.

### Key Points

- Frequency and count encoding replace categories with their occurrence rate or raw count, producing a single numeric column without target leakage risk.
- A core limitation is that categories with identical frequencies become indistinguishable to the model, regardless of their actual real-world differences.
- [Inference] This method tends to work best when frequency itself is predictive (e.g., rarity as a fraud signal) and works less well when category identity independently matters beyond its occurrence rate.
- Tree-based models are commonly paired with frequency encoding due to compatible threshold-based splitting mechanics.
- [Unverified] Standardized handling of unseen categories varies across implementations, since frequency encoding is often manually implemented rather than provided as a documented library default.

**Related Topics**

- Target and mean encoding as an alternative for high-cardinality features
- The hashing trick for fixed-dimensionality categorical encoding
- Weight of Evidence (WOE) encoding for binary classification
- Combining frequency encoding with other encoding schemes in a pipeline
- Handling rare categories via grouping ("other" bucket strategies)