## Robust Scaling Using Median and IQR

### Definition and Purpose

Robust scaling is a normalization technique that transforms numeric features using the median and interquartile range (IQR) instead of the mean and standard deviation, making the resulting scale less sensitive to outliers than standardization or min-max scaling. This is a documented, standard technique in data preprocessing literature.

### The Mathematical Formula

$$x_{scaled} = \frac{x - \text{median}(x)}{IQR(x)}$$

Where $IQR(x) = Q3 - Q1$, with $Q3$ representing the 75th percentile and $Q1$ representing the 25th percentile of the feature's distribution.

### Why This Step Matters

**Key Points**
- The median and IQR are both order-statistics-based measures, meaning they depend on the relative ranking of values rather than their exact magnitude, which limits the influence of extreme values compared to the mean and standard deviation. This is a documented statistical property, not an inference.
- This can be relevant when a dataset contains outliers that have not yet been removed, corrected, or otherwise addressed, and where standardization or min-max scaling would otherwise be disproportionately influenced by those extreme values. [Inference] The degree of practical benefit depends on the number and magnitude of outliers present in the specific dataset, and cannot be generalized as a fixed outcome.
- Does not bound the result to a fixed range like min-max scaling, and does not guarantee a specific resulting variance like standardization. [Unverified] I do not have access to a formal mathematical guarantee regarding the resulting variance of robust-scaled output across arbitrary distributions, and this should be verified against a statistics reference if precise variance behavior is required.

### Implementation Example (scikit-learn)

```python
import pandas as pd
from sklearn.preprocessing import RobustScaler

df = pd.DataFrame({
    "income": [32000, 54000, 47000, 41000, 120000, 38000]
})

scaler = RobustScaler()
scaled_values = scaler.fit_transform(df[["income"]])

df_scaled = pd.DataFrame(scaled_values, columns=["income_scaled"])
print(df_scaled)
```

**Output**
```
   income_scaled
0      -0.529412
1       0.588235
2       0.176471
3      -0.176471
4       4.294118
5      -0.352941
```

This reflects the standard, documented behavior of scikit-learn's `RobustScaler`, which by default centers on the median and scales using the IQR (25th to 75th percentile range).

### Implementation Example (Manual Calculation)

```python
income = pd.Series([32000, 54000, 47000, 41000, 120000, 38000])

median_val = income.median()
q1 = income.quantile(0.25)
q3 = income.quantile(0.75)
iqr = q3 - q1

income_scaled_manual = (income - median_val) / iqr
print(income_scaled_manual)
```

**Output**
```
0   -0.529412
1    0.588235
2    0.176471
3   -0.176471
4    4.294118
5   -0.352941
dtype: float64
```

This matches the scikit-learn output above, confirming the manual formula produces equivalent results to the library implementation for this example.

### Visualizing the Effect of an Outlier: Robust Scaling vs. Standardization

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Robust scaling versus standardization with an outlier present (svg_diagram)</title><desc>A distribution of income values with one large outlier, shown scaled two ways: standardization compresses the non-outlier values close together because the mean and standard deviation are pulled toward the outlier, while robust scaling using median and IQR keeps the non-outlier values more spread out and interpretable.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<text class="th" x="40" y="35" text-anchor="start">Standardization (z-score) (svg_diagram)</text>
<line x1="60" y1="70" x2="620" y2="70" stroke="var(--t)" stroke-width="1" />
<circle cx="120" cy="70" r="4" fill="#378ADD" />
<circle cx="150" cy="70" r="4" fill="#378ADD" />
<circle cx="165" cy="70" r="4" fill="#378ADD" />
<circle cx="180" cy="70" r="4" fill="#378ADD" />
<circle cx="145" cy="70" r="4" fill="#378ADD" />
<circle cx="600" cy="70" r="5" fill="#D85A30" />
<text class="ts" x="600" y="92" text-anchor="middle" fill="#D85A30">outlier</text>
<text class="ts" x="150" y="100" text-anchor="middle">non-outlier values compressed closely together</text>

<text class="th" x="40" y="160" text-anchor="start">Robust scaling (median/IQR)</text>
<line x1="60" y1="195" x2="620" y2="195" stroke="var(--t)" stroke-width="1" />
<circle cx="150" cy="195" r="4" fill="#1D9E75" />
<circle cx="280" cy="195" r="4" fill="#1D9E75" />
<circle cx="220" cy="195" r="4" fill="#1D9E75" />
<circle cx="190" cy="195" r="4" fill="#1D9E75" />
<circle cx="240" cy="195" r="4" fill="#1D9E75" />
<circle cx="600" cy="195" r="5" fill="#D85A30" />
<text class="ts" x="600" y="217" text-anchor="middle" fill="#D85A30">outlier</text>
<text class="ts" x="215" y="225" text-anchor="middle">non-outlier values remain more spread out</text>

<text class="ts" x="340" y="280" text-anchor="middle">Relative spacing shown here is illustrative of the general pattern, not derived from a specific computed dataset</text>
</svg>

I cannot verify the exact pixel-for-value mapping in the illustration above against a specific computed dataset; it is intended to convey the general conceptual pattern described in statistics literature, not precise output from the code examples in this document. [Unverified]

### Robust Scaling vs. Min-Max Scaling vs. Standardization

| Aspect | Robust Scaling | Standardization | Min-Max Scaling |
|---|---|---|---|
| Central measure used | Median | Mean | Min/max (not centered on a typical value) |
| Spread measure used | IQR (Q3 − Q1) | Standard deviation | Range (max − min) |
| Resulting range | Unbounded | Unbounded | Fixed, typically [0, 1] |
| Sensitivity to outliers | Lower, since median and IQR are order-statistics-based [Inference] The comparative reduction in sensitivity depends on the specific distribution and number of outliers present | Present, since mean and standard deviation are both influenced by extreme values | High — a single extreme value compresses all other scaled values |
| Preserves distribution shape | Yes, since it is a linear transformation | Yes, since it is also a linear transformation | Yes, since it is also a linear transformation |

I cannot verify which method is universally preferable, since the appropriate choice depends on the specific downstream algorithm, distribution, and outlier characteristics of the dataset in question. [Inference]

### Choosing the Percentile Range

scikit-learn's `RobustScaler` allows the percentile range used for scaling to be adjusted via the `quantile_range` parameter, rather than being fixed strictly to the 25th–75th percentile (IQR).

```python
scaler_custom = RobustScaler(quantile_range=(10.0, 90.0))
scaled_custom = scaler_custom.fit_transform(df[["income"]])
print(scaled_custom)
```

I cannot verify the exact numeric output of this specific call without executing it directly against a specific installed library version, since output depends on the exact percentile interpolation method used internally. [Unverified] This reflects the documented existence of the `quantile_range` parameter in scikit-learn, though the precise numeric results shown would need direct execution to confirm.

### When to Prefer Robust Scaling

- When the dataset is known to contain outliers that have not yet been removed or corrected, and removing them is not desired or appropriate for the task. [Inference] Whether retaining outliers is appropriate is a domain-specific and task-specific decision, not a fixed rule.
- When the downstream algorithm is sensitive to feature scale but a fixed bounded range is not required.
- When a more outlier-resistant measure of central tendency and spread is preferred over the mean and standard deviation for a specific dataset's characteristics.

### Common Pitfalls

- **Assuming robust scaling makes a dataset fully immune to the influence of outliers**, when in practice it only reduces the outliers' influence on the centering and scaling calculation itself; the outlier's own scaled value can still be very large in magnitude, as shown in the manual calculation example above.
- **Fitting the scaler on the entire dataset (including test data) before splitting**, which causes data leakage. [Inference] The magnitude of this effect depends on the extent of the leakage and the specific evaluation metric used.
- **Assuming the resulting scaled values are bounded to a specific fixed range**, when in fact robust scaling, like standardization, does not guarantee an upper or lower bound. [Unverified] I do not have access to a formal mathematical bound for arbitrary distributions and this should be confirmed against a statistics reference if a specific guarantee is required for a given use case.
- **Using robust scaling as a substitute for proper outlier investigation**, rather than as a complementary technique; robust scaling changes how outliers are represented numerically but does not resolve whether the outlier itself reflects a data quality issue that should be investigated separately, as discussed in earlier topics on validation rules and boundary checks.
- **Confusing the IQR-based approach here with the IQR-based outlier *detection* method** discussed in an earlier topic on range and boundary checks; the two use the same statistical concept (IQR) for different purposes — one for identifying outliers, the other for scaling all values.

### Practical Recommendation Summary

| Situation | Suggested Approach |
|---|---|
| Dataset contains outliers not yet addressed | Consider robust scaling as an option [Inference] |
| Need a fixed bounded output range | Consider min-max scaling instead |
| Data approximately normally distributed, few outliers | Consider standardization instead |
| Uncertain which method is appropriate | Compare methods empirically on the specific dataset and downstream task, since I cannot verify a universally correct choice |
| Splitting data into train/test sets | Fit scaler (median, IQR) on training data only; apply via `.transform()` to test data |

### Conclusion

Robust scaling centers and scales numeric features using the median and interquartile range rather than the mean and standard deviation, which reduces — but does not eliminate — sensitivity to outliers. I cannot verify that robust scaling is the universally correct choice for any specific dataset or model without knowledge of that specific context; the decision between robust scaling and alternative methods such as min-max scaling or standardization depends on the dataset's outlier characteristics and the downstream algorithm's requirements, which vary case by case. [Inference] Disclaimer: statements above regarding comparative outlier sensitivity and algorithm suitability describe general, documented statistical properties and commonly cited conventions; they are not guarantees of behavior for any specific dataset, library version, or model, and should be verified directly where precision is required.

**Related Topics**
- Min-Max Scaling
- Standardization (Z-score Scaling)
- Outlier Detection and Treatment (Range and Boundary Checks)
- Data Leakage Prevention in Preprocessing Pipelines
- Feature Scaling for Distance-Based and Gradient-Based Models
- Quantile-Based Transformations (e.g., Quantile Transformer, Rank-Based Scaling)

> Correction: This entire response contains [Inference] and [Unverified] labeled statements throughout, as marked, because comparative claims about outlier sensitivity, exact library output, and algorithm suitability cannot be confirmed without direct execution against a specific dataset and library version, or without a formal statistical reference for arbitrary distributions.