## Binary Encoding

### Overview

Binary encoding converts categorical values into binary digit representations, splitting each binary digit across separate columns. It is designed as a compromise between one-hot encoding (which produces many columns) and label encoding (which produces a false ordinal relationship), aiming to reduce dimensionality while avoiding some of the drawbacks of both extremes.

### Mechanics

The process typically involves three steps:

1. Assign each unique category an integer identifier (similar to label encoding).
2. Convert that integer into its binary representation.
3. Split the binary digits into separate columns, one per bit position.

**Example:**

| Category | Integer ID | Binary |
| --- | --- | --- |
| red | 1 | 001 |
| blue | 2 | 010 |
| green | 3 | 011 |
| yellow | 4 | 100 |

Becomes:

| bit_0 | bit_1 | bit_2 |
| --- | --- | --- |
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 0 |

For $k$ unique categories, binary encoding requires only $\lceil \log_2(k+1) \rceil$ columns, compared to $k$ (or $k-1$) columns for one-hot encoding.

```python
import category_encoders as ce

encoder = ce.BinaryEncoder(cols=['color'])
encoded = encoder.fit_transform(df)
```

`category_encoders.BinaryEncoder` is a documented implementation of this technique in the widely used `category_encoders` library.

### Why Binary Encoding Is Useful

- **Dimensionality reduction:** For a feature with 100 unique categories, one-hot encoding produces 99–100 columns, whereas binary encoding produces only $\lceil \log_2(101) \rceil = 7$ columns. This is a direct mathematical consequence of binary representation, not an inference.
- **No target leakage:** Since binary encoding is derived only from the category's assigned integer identifier, not from the target variable, it carries no target leakage risk, unlike target/mean encoding.
- **More information density than label encoding:** Rather than a single column implying a full ordinal relationship across all categories, binary encoding spreads category identity across multiple columns, reducing (though not eliminating) the risk of implying a strict linear order.

### Key Limitation: Partial Ordinal Artifacts

Although binary encoding avoids the extreme dimensionality of one-hot encoding, it does not fully eliminate ordinal-like artifacts. Since categories are first assigned sequential integers before binary conversion, the resulting bit patterns can still encode partial similarity relationships that do not correspond to any real-world relationship between categories.

- [Inference] Categories with adjacent integer IDs may share more bit patterns in common (e.g., IDs 2 and 3 differ only in the last bit, while IDs 3 and 4 differ in multiple bits), which can implicitly suggest a form of "closeness" between certain categories that has no grounding in the actual data. This is a reasoned mathematical observation about binary representations, not a benchmarked measurement of impact on any specific model or dataset.
- This effect is generally considered less severe than the false ordinal relationship introduced by plain label encoding, since the relationship is distributed and non-monotonic across multiple columns rather than a single, direct numeric ordering. [Unverified] I do not have a reliable source to quantify precisely how much less severe this effect is in practice, as this would depend on the specific model, dataset, and number of categories involved.

### When Binary Encoding Is Appropriate

Binary encoding is often considered for:

- High-cardinality nominal categorical features where one-hot encoding would create too many columns, but target encoding's leakage risk or implementation overhead is undesirable.
- Situations where a compact, dense representation is preferred over target-derived encodings, particularly when target leakage prevention is a priority.

### When Binary Encoding May Be Less Suitable

- [Inference] For models highly sensitive to any implied numeric structure between features (e.g., certain linear models), the residual bit-pattern artifacts described above may introduce subtle, hard-to-diagnose distortions compared to methods like one-hot encoding that avoid implying any relationship between distinct categories. I cannot verify the practical magnitude of this effect without testing on specific data.
- When interpretability of individual features is important, binary-encoded columns (e.g., `bit_0`, `bit_1`, `bit_2`) are much harder to interpret individually than one-hot encoded columns, since no single bit column corresponds directly to one specific category.

### Model Compatibility

===MERMAID_DIAGRAM===

flowchart TD

A[High-cardinality nominal feature] --> B{Priority: dimensionality reduction vs interpretability?}

B -->|Dimensionality reduction priority| C[Binary encoding suitable]

B -->|Interpretability priority| D[One-hot encoding preferred despite higher dimensionality]

C --> E{Model type}

E -->|Tree-based| F["Generally compatible; splits handle bit columns individually"]

E -->|Linear models| G["[Inference] May introduce subtle bit-pattern artifacts affecting coefficient interpretation"]

- **Tree-based models:** Binary-encoded columns can be split on individually like any other binary feature, and tree-based models are commonly paired with this encoding for high-cardinality features.
- **Linear models:** As noted above, [Inference] potential bit-pattern artifacts may introduce subtle distortions, though this has not been benchmarked here against a specific dataset.
- **Neural networks:** Binary encoding can serve as a compact input representation, though embeddings are also commonly used as an alternative, particularly when the network can learn richer relationships between categories directly from data.

### Binary Encoding vs. Other High-Cardinality Methods

| Method | Output Columns (k categories) | Leakage Risk | Ordinal Artifacts |
| --- | --- | --- | --- |
| One-hot encoding | $k$ or $k-1$ | None | None |
| Label encoding | 1 | None | Full false ordinal relationship |
| Target/mean encoding | 1 | Yes | None (value reflects target relationship) |
| Frequency encoding | 1 | None | None (but loses category identity for equal-frequency categories) |
| Binary encoding | $\lceil \log_2(k+1) \rceil$ | None | Partial, reduced compared to label encoding |

### Handling Unseen Categories at Inference Time

Since binary encoding relies on integer identifiers assigned during training, a category unseen during training will not have a corresponding integer ID or bit pattern.

- `category_encoders.BinaryEncoder` and similar implementations typically require explicit configuration for handling unseen categories, often via a `handle_unknown` parameter, though [Unverified] the exact default behavior and parameter naming should be verified against the specific library version in use, since I do not have access to confirm this without checking current documentation directly.

### Common Pitfalls

- Assuming binary encoding fully removes ordinal implications between categories, when in fact partial bit-pattern artifacts can still exist depending on the assigned integer order.
- Using binary encoding when feature interpretability is a priority, since individual bit columns do not map cleanly to specific categories.
- Not planning for unseen categories at inference time, which can cause inconsistent or undefined bit patterns in production.
- Applying binary encoding to low-cardinality features where one-hot encoding would be simpler and equally effective, since the dimensionality savings are minimal for small category counts.

### Key Points

- Binary encoding represents categories using binary digits split across multiple columns, requiring only $\lceil \log_2(k+1) \rceil$ columns for $k$ categories.
- It carries no target leakage risk, since it depends only on category identity, not the target variable.
- [Inference] Partial ordinal-like artifacts can still arise from the underlying integer-to-binary conversion process, though this is generally considered less severe than full label encoding; the precise practical impact is [Unverified] without testing on specific data.
- Binary encoding trades away interpretability compared to one-hot encoding, since individual bit columns do not correspond directly to single categories.
- Handling of unseen categories at inference time depends on library-specific implementation details that should be verified against current documentation for the version in use.

**Related Topics**

- One-hot encoding and the dummy variable trap
- Frequency and count encoding as leakage-free alternatives
- Hashing trick for fixed-dimensionality categorical encoding
- The `category_encoders` library and its range of encoding implementations
- Embedding layers as a learned alternative to manual categorical encoding schemes