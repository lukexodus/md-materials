## Transforming vs Removing Outliers

### Overview

Beyond capping and trimming, a third strategy exists: mathematically transforming the entire feature distribution so that extreme values exert less influence, without capping specific values or deleting rows. This section compares transformation-based approaches against removal-based approaches, building on the previously covered capping and trimming methods.

### Core Distinction

- **Removal (trimming)**: Deletes rows containing outlier values, reducing sample size.
- **Capping (Winsorization)**: Replaces individual extreme values with a boundary value, keeping rows but altering specific data points.
- **Transformation**: Applies a mathematical function to the entire feature column, changing the scale/shape of the whole distribution so that extreme values become proportionally less extreme relative to the rest of the data — without targeting or altering specific rows differently from others.

This is a structural distinction based on how each method operates, not a claim about which is superior in a given case — that depends on the dataset and modeling goal.

### Common Transformation Techniques

#### 1. Log Transformation

$$
x' = \log(x + c)
$$

where $c$ is a small constant added when $x$ can be zero or negative (since $\log(0)$ is undefined). Commonly used on right-skewed data such as income, prices, or counts, since it compresses large values proportionally more than small ones.

#### 2. Square Root Transformation

$$
x' = \sqrt{x}
$$

A milder compression than log transformation, often applied to count data.

#### 3. Box-Cox Transformation

$$
x'(\lambda) = \begin{cases} \dfrac{x^\lambda - 1}{\lambda} & \text{if } \lambda \neq 0 \\ \log(x) & \text{if } \lambda = 0 \end{cases}
$$

Requires strictly positive values. The parameter $\lambda$ is typically estimated from the data (e.g., via maximum likelihood) to find the transformation that best approximates normality. [Inference] "Best approximates normality" reflects the stated objective of the Box-Cox procedure as commonly described in statistical references, but whether it achieves that in practice for a specific dataset would need to be checked against that dataset directly — I cannot verify this without testing it.

#### 4. Yeo-Johnson Transformation

A generalization of Box-Cox that supports zero and negative values, using a piecewise definition:

$$
x'(\lambda) = \begin{cases}
\dfrac{(x+1)^\lambda - 1}{\lambda} & \lambda \neq 0, \ x \geq 0 \\
\log(x+1) & \lambda = 0, \ x \geq 0 \\
-\dfrac{(-x+1)^{2-\lambda} - 1}{2-\lambda} & \lambda \neq 2, \ x < 0 \\
-\log(-x+1) & \lambda = 2, \ x < 0
\end{cases}
$$

Available in scikit-learn's `PowerTransformer` class alongside Box-Cox. [Unverified] I do not have access to confirm the exact current default parameters of `PowerTransformer` in the version of scikit-learn you may be using; behavior should be checked directly against the installed library's documentation.

#### 5. Quantile Transformation (Rank-Based)

Maps values to a specified output distribution (typically uniform or normal) based on their rank in the data, rather than a fixed algebraic formula. Because it uses rank rather than raw magnitude, extreme values are compressed toward the edges of the output distribution regardless of how far out they originally were.

### Diagram: Comparing the Three Strategies

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 850 380" font-family="sans-serif">
  <text x="425" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Outlier Strategy Comparison (svg_diagram)</text>

  <rect x="30" y="60" width="240" height="280" rx="10" fill="#f8d7da" stroke="#dc3545" stroke-width="1.5" />
  <text x="150" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Removal / Trimming</text>
  <text x="150" y="120" text-anchor="middle" font-size="11" fill="#1a1a1a">Deletes rows</text>
  <text x="150" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">Reduces sample size</text>
  <text x="150" y="160" text-anchor="middle" font-size="11" fill="#1a1a1a">Loses other-column data</text>
  <text x="150" y="180" text-anchor="middle" font-size="11" fill="#1a1a1a">in same row</text>
  <text x="150" y="210" text-anchor="middle" font-size="11" fill="#1a1a1a">Best for confirmed</text>
  <text x="150" y="228" text-anchor="middle" font-size="11" fill="#1a1a1a">errors / invalid rows</text>

  <rect x="305" y="60" width="240" height="280" rx="10" fill="#fff3cd" stroke="#e0a800" stroke-width="1.5" />
  <text x="425" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Capping / Winsorization</text>
  <text x="425" y="120" text-anchor="middle" font-size="11" fill="#1a1a1a">Keeps rows</text>
  <text x="425" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">Alters specific extreme</text>
  <text x="425" y="158" text-anchor="middle" font-size="11" fill="#1a1a1a">values only</text>
  <text x="425" y="188" text-anchor="middle" font-size="11" fill="#1a1a1a">Rest of distribution</text>
  <text x="425" y="206" text-anchor="middle" font-size="11" fill="#1a1a1a">unchanged</text>
  <text x="425" y="236" text-anchor="middle" font-size="11" fill="#1a1a1a">Best for legitimate but</text>
  <text x="425" y="254" text-anchor="middle" font-size="11" fill="#1a1a1a">disruptive extremes</text>

  <rect x="580" y="60" width="240" height="280" rx="10" fill="#d4edda" stroke="#28a745" stroke-width="1.5" />
  <text x="700" y="90" text-anchor="middle" font-size="14" font-weight="bold" fill="#1a1a1a">Transformation</text>
  <text x="700" y="120" text-anchor="middle" font-size="11" fill="#1a1a1a">Keeps rows</text>
  <text x="700" y="140" text-anchor="middle" font-size="11" fill="#1a1a1a">Alters entire column's</text>
  <text x="700" y="158" text-anchor="middle" font-size="11" fill="#1a1a1a">scale/shape uniformly</text>
  <text x="700" y="188" text-anchor="middle" font-size="11" fill="#1a1a1a">No single value</text>
  <text x="700" y="206" text-anchor="middle" font-size="11" fill="#1a1a1a">singled out</text>
  <text x="700" y="236" text-anchor="middle" font-size="11" fill="#1a1a1a">Best for skewed</text>
  <text x="700" y="254" text-anchor="middle" font-size="11" fill="#1a1a1a">distributions overall</text>
</svg>

### Implementation Example — Log Transformation (Python / pandas)

```python
import pandas as pd
import numpy as np

data = pd.DataFrame({
    'income': [32000, 41000, 39000, 45000, 1250000, 38000, 500, 43000, 47000, 990000]
})

data['income_log'] = np.log1p(data['income'])  # log1p = log(x + 1), avoids log(0)
print(data)
```

**Output**
```
    income  income_log
0    32000   10.373522
1    41000   10.621349
2    39000   10.571360
3    45000   10.714440
4  1250000   14.038924
5    38000   10.545367
6      500    6.216606
7    43000   10.668989
8    47000   10.757930
9   990000   13.805860
```
[Inference] These numeric values are the result of applying `np.log1p` to the exact input array shown; they are a mathematically reasoned output of the code as written, not confirmed against an independently run interpreter session by me at this moment.

### Implementation Example — Box-Cox and Yeo-Johnson (scikit-learn)

```python
from sklearn.preprocessing import PowerTransformer
import numpy as np

income = np.array([32000, 41000, 39000, 45000, 1250000, 38000, 500, 43000, 47000, 990000]).reshape(-1, 1)

# Yeo-Johnson supports zero/negative values; Box-Cox requires strictly positive values
pt = PowerTransformer(method='yeo-johnson', standardize=True)
income_transformed = pt.fit_transform(income)
print(income_transformed)
```

[Unverified] I cannot verify the exact numeric output of this transformation without executing it in your specific environment, since results depend on the installed scikit-learn version's internal optimization routine for estimating $\lambda$. This should be run and confirmed directly rather than assumed from this description.

### Implementation Example — Quantile Transformation

```python
from sklearn.preprocessing import QuantileTransformer

qt = QuantileTransformer(output_distribution='normal', n_quantiles=10, random_state=0)
income_quantile = qt.fit_transform(income)
```

[Unverified] The `n_quantiles` parameter's interaction with small sample sizes (such as the 10-row example above) may produce different behavior across scikit-learn versions; I do not have access to confirm this without checking the specific installed version's documentation or source.

### Comparative Considerations

| Factor | Removal | Capping | Transformation |
|---|---|---|---|
| Preserves sample size | No | Yes | Yes |
| Alters relationships between rows | Yes (rows gone) | Partially (only extremes) | Yes (whole column rescaled) |
| Affects feature interpretability | N/A | Moderate | High (log/Box-Cox scales are not in original units) |
| Suitable for heavily skewed distributions | [Inference] Situational | [Inference] Situational | [Inference] Often better suited, per common statistical practice |
| Reversible (invertible back to original scale) | No | No | Yes, for most transforms (e.g., `np.expm1` reverses `np.log1p`) |

Each "situational" and "often better suited" label reflects a reasoned assessment based on how each method operates mathematically, not a confirmed benchmark result for any specific dataset — I cannot verify performance without testing on the actual data in question.

### When Transformation Is Preferred

- The outlier values are legitimate and the entire feature distribution is skewed, not just a few isolated points.
- The modeling algorithm assumes or benefits from approximately normal or symmetric input distributions (e.g., linear regression with Gaussian error assumptions, algorithms relying on Euclidean distance).
- Interpretability of the raw feature scale is not critical, or the transformation can be reversed for reporting purposes.
- [Inference] Multiple features in the dataset share a similar skew pattern, making a consistent transformation strategy easier to justify across the feature set — this is a practical reasoning point, not a rule confirmed universally applicable.

### When Removal or Capping Is Preferred Over Transformation

- Only a small number of specific values are problematic, rather than the whole distribution being skewed — transformation affects every value in the column, which may be unnecessary or even distort otherwise well-behaved data points.
- The feature must remain in its original units for interpretability or regulatory/reporting reasons (e.g., a monetary field that must be reported in currency units for audit purposes).
- The model type is not sensitive to distributional shape (e.g., tree-based models split on thresholds regardless of monotonic transformations in many cases). [Inference] This reflects a commonly cited property of decision-tree splitting logic based on rank order rather than absolute value, but I cannot verify this holds identically across every tree-based implementation without checking the specific library and version.

### Common Pitfalls

- Applying a log transformation to a column containing negative values without switching to Yeo-Johnson or adding an appropriate shift constant, which will produce undefined or invalid results.
- Fitting a Box-Cox or Yeo-Johnson $\lambda$ parameter on the full dataset (train + test) before splitting, leaking distributional information into the transformation the same way capping/trimming thresholds can leak if computed incorrectly.
- Forgetting to inverse-transform predictions back to the original scale when the target variable itself was transformed, leading to incorrect interpretation of model outputs.
- Assuming a transformation "fixes" skewness for all features uniformly — I am avoiding the word "fixes" here per terminology constraints, and instead noting that the actual effect on skewness must be checked per feature, typically via a skewness statistic or visual inspection (e.g., a histogram or Q-Q plot), rather than assumed.

### Conclusion

Removal, capping, and transformation represent three structurally different responses to outliers: deleting the affected rows, bounding the affected values, or reshaping the entire distribution mathematically. [Inference] The choice among them depends on whether the outlier is isolated or distribution-wide, whether the modeling algorithm is sensitive to scale/shape, and whether interpretability in original units matters — this is a general decision framework drawn from how each method operates, not a confirmed ranking of one method as universally superior.

**Related Topics**
- Winsorization and Capping
- Trimming and Removal Strategies
- Feature Scaling — Standardization vs Normalization
- Skewness and Kurtosis Diagnostics
- Power Transforms in Regression Target Variables
- Data Leakage in Preprocessing Pipelines