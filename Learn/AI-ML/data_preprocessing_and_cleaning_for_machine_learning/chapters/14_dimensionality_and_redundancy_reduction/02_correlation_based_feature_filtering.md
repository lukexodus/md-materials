## Correlation-Based Feature Filtering

### Overview

Correlation-based feature filtering removes or flags features that are highly correlated with one another, on the reasoning that two strongly correlated features carry substantially redundant information. Retaining both typically adds little predictive value while increasing dimensionality, and for some model types, can actively degrade model stability or interpretability.

### Measuring Correlation Between Features

The most common measure for numeric features is the Pearson correlation coefficient, which quantifies the strength and direction of a linear relationship between two variables:

$$r_{xy} = \frac{\sum_{i}(x_i - \bar{x})(y_i - \bar{y})}{\sqrt{\sum_i (x_i - \bar{x})^2}\sqrt{\sum_i (y_i - \bar{y})^2}}$$

producing a value between -1 (perfect negative linear relationship) and +1 (perfect positive linear relationship), with 0 indicating no linear relationship.

```python
corr_matrix = df.corr()
```

pandas' `.corr()` method computes pairwise Pearson correlation by default across all numeric columns in a DataFrame, and is documented to support alternative methods such as Spearman and Kendall correlation via a `method` parameter.

### Visualizing the Correlation Matrix

A correlation heatmap is commonly used to visually identify pairs of highly correlated features across a dataset.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 420">
<text x="240" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#333">Correlation Matrix Heatmap (svg_diagram)</text>
<g font-size="12" fill="#333">
<text x="150" y="55" text-anchor="middle">A</text>
<text x="220" y="55" text-anchor="middle">B</text>
<text x="290" y="55" text-anchor="middle">C</text>
<text x="360" y="55" text-anchor="middle">D</text>
<text x="110" y="100" text-anchor="end">A</text>
<text x="110" y="170" text-anchor="end">B</text>
<text x="110" y="240" text-anchor="end">C</text>
<text x="110" y="310" text-anchor="end">D</text>
</g>
<rect x="115" y="65" width="70" height="70" fill="#B40426" />
<rect x="185" y="65" width="70" height="70" fill="#3B4CC0" />
<rect x="255" y="65" width="70" height="70" fill="#F7B79B" />
<rect x="325" y="65" width="70" height="70" fill="#7B9FF9" />
<rect x="115" y="135" width="70" height="70" fill="#3B4CC0" />
<rect x="185" y="135" width="70" height="70" fill="#B40426" />
<rect x="255" y="135" width="70" height="70" fill="#DEDCDB" />
<rect x="325" y="135" width="70" height="70" fill="#E7A186" />
<rect x="115" y="205" width="70" height="70" fill="#F7B79B" />
<rect x="185" y="205" width="70" height="70" fill="#DEDCDB" />
<rect x="255" y="205" width="70" height="70" fill="#B40426" />
<rect x="325" y="205" width="70" height="70" fill="#3B4CC0" />
<rect x="115" y="275" width="70" height="70" fill="#7B9FF9" />
<rect x="185" y="275" width="70" height="70" fill="#E7A186" />
<rect x="255" y="275" width="70" height="70" fill="#3B4CC0" />
<rect x="325" y="275" width="70" height="70" fill="#B40426" />
<text x="380" y="80" font-size="11" fill="#333">+1.0</text>
<rect x="410" y="68" width="20" height="14" fill="#B40426" />
<text x="380" y="330" font-size="11" fill="#333">-1.0</text>
<rect x="410" y="318" width="20" height="14" fill="#3B4CC0" />
</svg>

Dark red cells (near +1.0) indicate strongly positively correlated feature pairs, such as features A and C in this illustrative example, which would be flagged as candidates for redundancy removal.

### Correlation Thresholds for Filtering

A common approach identifies feature pairs whose absolute correlation exceeds a chosen threshold, then removes one feature from each such pair.

```python
import numpy as np

corr_matrix = df.corr().abs()
upper = corr_matrix.where(np.triu(np.ones(corr_matrix.shape), k=1).astype(bool))
to_drop = [column for column in upper.columns if any(upper[column] > 0.9)]
df_reduced = df.drop(columns=to_drop)
```

Using `np.triu` to extract only the upper triangle of the correlation matrix avoids redundantly evaluating each pair twice (since the matrix is symmetric) and avoids flagging a feature's correlation with itself along the diagonal.

- There is no single universally standardized correlation threshold at which two features are considered "too correlated" to keep both. [Inference] A commonly cited informal convention treats absolute correlations above roughly 0.8–0.9 as indicating strong redundancy warranting removal of one feature, but I do not have a single authoritative source confirming this specific range as a formally standardized rule, and the appropriate threshold depends on the specific modeling context and dataset.

### Which Feature to Drop From a Correlated Pair

When two features are found to be highly correlated, a decision must be made about which one to remove. Common considerations include:

- **Domain relevance:** Retaining the feature that is more interpretable or more directly tied to the business or scientific question, when this can be determined.
- **Missing data:** Retaining the feature with fewer missing values, if the two otherwise carry similar information.
- **Relationship with the target:** [Inference] Retaining the feature that has a stronger individual relationship with the target variable (e.g., via a target-aware statistic such as mutual information or a simple univariate correlation with the target itself) is a commonly recommended heuristic, since dropping the less target-relevant feature of the pair better preserves predictive signal. This is a reasoned recommendation based on the shared goal of retaining predictive power while reducing redundancy, not a benchmarked finding for a specific dataset.

### Correlation-Based Filtering Is Univariate-Pair, Not Multivariate

A key limitation of pairwise correlation filtering is that it only examines relationships between two features at a time, and does not account for more complex, multivariate redundancy involving three or more features jointly.

- **Example of a blind spot:** Three features, A, B, and C, might each have only moderate pairwise correlation with one another individually (e.g., all below a 0.8 threshold), yet one feature (e.g., C) might still be nearly perfectly predictable as a linear combination of the other two (e.g., $C \approx A + B$). Pairwise correlation filtering alone would not detect this multivariate redundancy, since no single pairwise correlation value captures a three-feature linear relationship.
- **Multicollinearity diagnostics beyond pairwise correlation:** Variance Inflation Factor (VIF) is commonly used specifically to detect this kind of multivariate redundancy, particularly relevant for linear regression models, since it measures how well each feature can be predicted from all other features jointly, not just from one other feature at a time.

$$\text{VIF}_i = \frac{1}{1 - R_i^2}$$

where $R_i^2$ is the coefficient of determination obtained by regressing feature $i$ against all other features.

- [Inference] A commonly cited informal convention treats VIF values above roughly 5–10 as indicating problematic multicollinearity warranting further investigation or feature removal, though I do not have a single authoritative source establishing this exact range as a formally universal standard, and appropriate thresholds vary across statistical literature and application domains.

### Nonlinear Relationships and Correlation's Blind Spot

Pearson correlation specifically measures the strength of a *linear* relationship between two features. Two features can have a strong nonlinear relationship (e.g., a quadratic or exponential relationship) while showing a Pearson correlation close to zero.

- [Inference] This means correlation-based filtering using Pearson correlation alone may fail to detect redundancy between features that are related in a nonlinear way, potentially retaining two features that are, in a broader informational sense, substantially redundant. This is a reasoned mathematical limitation of the Pearson correlation formula's linear assumption, not a benchmarked finding on a specific dataset.
- **Mitigation:** Spearman rank correlation (which captures monotonic, not necessarily linear, relationships) or mutual information (which can capture more general statistical dependence, including nonlinear and non-monotonic relationships) are sometimes used as complements or alternatives to Pearson correlation specifically to address this blind spot.

### Model Compatibility Considerations

- **Linear models:** [Inference] Highly correlated features are particularly relevant to address for linear regression specifically, since strong correlation between predictors (multicollinearity) can cause unstable, difficult-to-interpret coefficient estimates, even if the model's overall predictive accuracy is not necessarily strongly affected. This is a well-documented statistical property of ordinary least squares estimation under multicollinearity, not merely an inference, though the degree of instability in coefficients for any specific dataset depends on the exact correlation structure present.
- **Tree-based models:** [Inference] Tree-based models are generally considered more robust to correlated features in terms of overall predictive performance, since a tree can simply choose to split on whichever of two correlated features happens to provide a marginally better split at a given node. However, this can make feature importance scores derived from tree-based models less reliable or less interpretable specifically when features are correlated, since importance may be arbitrarily distributed between the correlated features rather than concentrated on one. This is a commonly cited practical concern in feature importance interpretation literature, not a benchmarked measurement for a specific dataset.
- **Neural networks:** [Unverified] The practical impact of correlated input features on neural network training and generalization varies considerably depending on architecture, regularization, and training procedure, and I do not have a general, verifiable rule to state regarding the specific magnitude of this impact.

### Decision Path

===MERMAID_DIAGRAM===

flowchart TD

A[Compute pairwise correlation matrix] --> B{Pair exceeds threshold?}

B -->|No| C[Retain both features]

B -->|Yes| D{Which feature more relevant to target or domain?}

D --> E[Drop the less relevant/redundant feature]

A --> F[Also consider VIF for multivariate redundancy]

F --> G{VIF exceeds threshold?}

G -->|Yes| H[Investigate further; consider dropping or combining features]

G -->|No| C

### Common Pitfalls

- Relying solely on Pearson correlation, which only captures linear relationships, potentially missing meaningful nonlinear redundancy between features.
- Applying a single fixed correlation threshold without considering the specific modeling context or the relative importance of the features involved.
- Ignoring multivariate redundancy (multiple features jointly predictive of one another) by only examining pairwise correlations, which VIF or similar diagnostics are better suited to detect.
- Computing correlation on the full dataset, including validation or test data, before splitting, which is a data leakage concern consistent with other preprocessing steps discussed previously.
- Dropping a feature from a correlated pair without checking which of the two has a stronger relationship with the target variable, potentially discarding more useful predictive information than necessary.

### Key Points

- Correlation-based filtering removes one feature from pairs exceeding a chosen absolute correlation threshold, most commonly using Pearson correlation for numeric features.
- [Inference] There is no single universally standardized correlation threshold; commonly cited informal conventions suggest roughly 0.8–0.9, though this is not confirmed as a formally standardized rule from a single authoritative source.
- Pairwise correlation filtering only detects two-feature redundancy; multivariate redundancy involving three or more features requires complementary diagnostics such as Variance Inflation Factor (VIF).
- [Inference] Pearson correlation's focus on linear relationships means it can miss meaningful nonlinear redundancy between features; Spearman correlation or mutual information are sometimes used to address this specific limitation.
- Linear models are particularly sensitive to multicollinearity in terms of coefficient stability, while tree-based models are generally more robust in terms of predictive performance but can show less reliable feature importance rankings when correlated features are present.

I cannot verify a single universally correct correlation or VIF threshold applicable across all datasets and modeling contexts; appropriate thresholds should be validated based on the specific dataset, model type, and domain context.

**Related Topics**

- Variance Inflation Factor (VIF) and multicollinearity diagnostics in depth
- Mutual information as a nonlinear-aware feature relevance measure
- Low-variance feature filtering as a complementary preprocessing step
- Principal Component Analysis (PCA) as an alternative to explicit redundant feature removal
- Recursive feature elimination and model-based feature importance ranking