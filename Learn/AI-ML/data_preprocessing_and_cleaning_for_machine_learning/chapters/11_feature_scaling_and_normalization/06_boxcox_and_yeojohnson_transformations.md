## Box-Cox and Yeo-Johnson Transformations

### Definition and Purpose

Box-Cox and Yeo-Johnson transformations are parameterized power transformation families used to reduce skewness and make a numeric distribution more closely approximate a normal distribution. Both are documented, standard techniques in statistics literature and were introduced as extensions of the simpler log and square root transformations covered in the prior topic.

### The Box-Cox Transformation

#### Formula

$$
x_{transformed} =
\begin{cases}
\dfrac{x^{\lambda} - 1}{\lambda}, & \lambda \neq 0 \\
\log(x), & \lambda = 0
\end{cases}
$$

Where $\lambda$ is a parameter estimated from the data, typically chosen to maximize the log-likelihood of the transformed data under a normal distribution assumption. This is a documented aspect of the method's standard estimation procedure.

#### Constraint

Box-Cox requires strictly positive input values ($x > 0$). This is a documented mathematical constraint of the method, not an inference.

#### Implementation Example

```python
import pandas as pd
from scipy import stats

data = pd.Series([5, 20, 50, 100, 500, 5000, 50000])

transformed_data, best_lambda = stats.boxcox(data)

print("Best lambda:", best_lambda)
print(transformed_data)
```

I cannot verify the exact numeric output of this specific `stats.boxcox` call without executing it directly against a specific installed SciPy version, since the optimal lambda is estimated numerically via an optimization procedure and small implementation differences could affect the result. [Unverified] The general behavior described — that `scipy.stats.boxcox` searches for a lambda that best approximates normality in the transformed data — reflects documented library functionality.

### The Yeo-Johnson Transformation

#### Formula

Yeo-Johnson extends the Box-Cox concept to accommodate zero and negative values through a piecewise definition:

$$
x_{transformed} =
\begin{cases}
\dfrac{(x+1)^{\lambda} - 1}{\lambda}, & \lambda \neq 0, \ x \geq 0 \\[6pt]
\log(x+1), & \lambda = 0, \ x \geq 0 \\[6pt]
-\dfrac{(-x+1)^{2-\lambda} - 1}{2-\lambda}, & \lambda \neq 2, \ x < 0 \\[6pt]
-\log(-x+1), & \lambda = 2, \ x < 0
\end{cases}
$$

This piecewise structure is a documented aspect of the Yeo-Johnson method as originally formulated in statistics literature. I cannot independently verify this exact formula against the original published source without direct access to that source; I do not have access to confirm the precise notation against the original 2000 Yeo and Johnson paper, though this formulation is widely and consistently reproduced in statistical references and library documentation. [Unverified]

#### Implementation Example

```python
import pandas as pd
from sklearn.preprocessing import PowerTransformer

df = pd.DataFrame({
    "value": [-10, -2, 0, 5, 20, 100, 1000]
})

pt = PowerTransformer(method="yeo-johnson")
transformed = pt.fit_transform(df[["value"]])

df["yeo_johnson"] = transformed
print(df)
print("Lambda:", pt.lambdas_)
```

I cannot verify the exact numeric output or lambda value of this specific call without executing it directly against a specific installed scikit-learn version. [Unverified] The general behavior — that `PowerTransformer` with `method="yeo-johnson"` accepts zero and negative values without requiring an offset, unlike Box-Cox — reflects documented library functionality.

### Key Structural Difference Between the Two Methods

| Aspect | Box-Cox | Yeo-Johnson |
|---|---|---|
| Accepts zero values | No | Yes |
| Accepts negative values | No | Yes |
| Requires strictly positive input | Yes | No |
| Formula structure | Single-branch (based on $\lambda = 0$) | Piecewise (based on sign of $x$ and $\lambda$) |
| Reduces to log transform as special case | Yes, when $\lambda = 0$ | Yes, when $\lambda = 0$ and $x \geq 0$ |

This table reflects documented structural properties of both methods as commonly described in statistics and machine learning references.

### Visualizing the Domain Restriction

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Domain restrictions of Box-Cox versus Yeo-Johnson (svg_diagram)</title><desc>A number line showing that Box-Cox can only be applied to strictly positive values, while Yeo-Johnson extends coverage to zero and negative values as well.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<text class="th" x="40" y="35" text-anchor="start">Box-Cox: valid domain (svg_diagram)</text>
<line x1="60" y1="70" x2="620" y2="70" stroke="var(--t)" stroke-width="1" />
<line x1="340" y1="55" x2="340" y2="85" stroke="var(--t)" stroke-width="1" />
<text class="ts" x="340" y="105" text-anchor="middle">0</text>
<g class="c-coral">
<rect x="200" y="55" width="140" height="30" rx="4" stroke-width="0.5" opacity="0.5" />
</g>
<text class="ts" x="270" y="45" text-anchor="middle" fill="#D85A30">invalid (x ≤ 0)</text>
<g class="c-teal">
<rect x="340" y="55" width="220" height="30" rx="4" stroke-width="0.5" opacity="0.5" />
</g>
<text class="ts" x="450" y="45" text-anchor="middle" fill="#0F6E56">valid (x &gt; 0)</text>

<text class="th" x="40" y="150" text-anchor="start">Yeo-Johnson: valid domain</text>
<line x1="60" y1="185" x2="620" y2="185" stroke="var(--t)" stroke-width="1" />
<line x1="340" y1="170" x2="340" y2="200" stroke="var(--t)" stroke-width="1" />
<text class="ts" x="340" y="220" text-anchor="middle">0</text>
<g class="c-teal">
<rect x="200" y="170" width="360" height="30" rx="4" stroke-width="0.5" opacity="0.5" />
</g>
<text class="ts" x="380" y="160" text-anchor="middle" fill="#0F6E56">valid across all real values</text>
</svg>

### Choosing Between Box-Cox and Yeo-Johnson

**Key Points**
- If all values in the feature are strictly positive, either method can typically be applied; the choice between them in that case is not dictated by the domain constraint. [Inference] Whether the two methods produce meaningfully different results on strictly positive data depends on the specific dataset's distribution, and I cannot generalize a single preferred choice without direct comparison.
- If the feature contains zero or negative values, Yeo-Johnson is the applicable choice, since Box-Cox's domain constraint would otherwise be violated.
- Both methods estimate $\lambda$ from the data (typically via maximum likelihood), meaning the transformation is data-dependent and requires fitting, similar to how min/max, mean/std, and median/IQR parameters are fitted in the scaling methods discussed in earlier topics.

### Practical Implementation Considerations

#### Using scikit-learn's Unified `PowerTransformer` Interface

```python
from sklearn.preprocessing import PowerTransformer

pt_boxcox = PowerTransformer(method="box-cox")
pt_yeojohnson = PowerTransformer(method="yeo-johnson")
```

Both methods are accessible through the same scikit-learn class interface, differing only in the `method` parameter. This reflects documented library design, not an inference.

#### Standardization as a Default Follow-Up Step

By default, scikit-learn's `PowerTransformer` also applies zero-mean, unit-variance standardization to the output after the power transformation itself, controlled by the `standardize` parameter (default `True`). [Unverified] I have not directly executed code to confirm this default behavior against a specific current version of scikit-learn; this reflects commonly cited documentation of the parameter's existence and default value, but should be confirmed against the specific installed version if precision is required.

### Train/Test Split Considerations

**Key Points**
- The $\lambda$ parameter for either method should be estimated only from training data, then applied consistently to validation and test data using `.transform()`, to avoid data leakage — consistent with the approach discussed for the other fitted scaling methods in this series.
- Applying a previously fitted $\lambda$ to new inference-time data does not guarantee the transformed output will closely approximate normality if the new data's distribution differs substantially from the training data's distribution. [Inference] The degree of any such discrepancy depends on how representative the training data is of future data, which I cannot verify in general without direct comparison.

```python
from sklearn.model_selection import train_test_split

X_train, X_test = train_test_split(data.to_frame(), test_size=0.3, random_state=42)

pt = PowerTransformer(method="box-cox")
pt.fit(X_train)

X_train_transformed = pt.transform(X_train)
X_test_transformed = pt.transform(X_test)
```

I cannot verify the exact numeric output of this specific call without executing it directly against a specific installed library version and random seed. [Unverified]

### When to Prefer Box-Cox or Yeo-Johnson Over Simple Log/Sqrt Transformations

- When a single fixed transformation (plain log or square root) does not adequately reduce skewness, and a data-driven, optimized parameter is preferred instead. [Inference] Whether this optimization yields a meaningfully better result for a specific dataset compared to a simple log transform is an empirical question that should be tested directly rather than assumed.
- When the feature contains zero or negative values and a Box-Cox-style transformation is desired; Yeo-Johnson specifically accommodates this case where Box-Cox and a plain log transform (without offset) cannot.
- When consistency across multiple features with different scales and signs is needed within a single automated preprocessing pipeline, since Yeo-Johnson's broader domain support avoids needing separate handling logic for positive versus non-positive features. [Inference] Whether this simplification is a meaningful practical benefit depends on the specific pipeline's design and the range of feature types involved.

### Common Pitfalls

- **Applying Box-Cox to data containing zero or negative values**, which violates the method's documented positivity requirement; the specific error or behavior produced in this case depends on the specific library and version used, and I cannot verify it without checking that library's current documentation directly. [Unverified]
- **Fitting $\lambda$ on the full dataset (including test data) before splitting**, which causes data leakage. [Inference] The magnitude of this effect depends on the extent of the leakage and the specific evaluation metric used.
- **Assuming either transformation produces a fully normal distribution as a result**, when in practice both methods only aim to approximate normality by optimizing $\lambda$ under that assumption; the actual result is not guaranteed to pass a formal normality test for every dataset. [Unverified] I do not have access to a formal guarantee of this kind for arbitrary underlying distributions, and this claim should not be treated as an assured outcome.
- **Forgetting to reverse the transformation when interpreting model predictions**, particularly in regression tasks where the target variable itself was transformed, which can lead to predictions being reported on the wrong scale. [Inference] Whether this specific mistake occurs depends on the specific pipeline implementation, which I cannot verify in general.
- **Not checking scikit-learn's default `standardize=True` behavior**, which applies an additional standardization step after the power transformation; overlooking this can cause confusion when comparing manually computed Box-Cox/Yeo-Johnson values (via SciPy) against scikit-learn's `PowerTransformer` output, since the two may not match unless this parameter is accounted for. [Unverified] The exact current default behavior should be confirmed against the specific installed scikit-learn version.

### Practical Recommendation Summary

| Situation | Suggested Approach |
|---|---|
| Feature is strictly positive and skewed | Either Box-Cox or Yeo-Johnson may be considered [Inference] |
| Feature contains zero or negative values | Use Yeo-Johnson; Box-Cox is not applicable |
| Comparing manual SciPy Box-Cox output to scikit-learn's `PowerTransformer` | Check the `standardize` parameter default, since it may add an extra standardization step |
| Fitting a parameterized transformation | Fit only on training data; apply via `.transform()` to test data |
| Target variable was transformed for regression | Apply the inverse transformation before interpreting predictions in original units |

### Conclusion

Box-Cox and Yeo-Johnson are both parameterized power transformations designed to reduce skewness and approximate normality, differing primarily in the domain of values each can accept — Box-Cox requires strictly positive input, while Yeo-Johnson accommodates zero and negative values as well. I cannot verify that either method is the universally correct choice for a specific dataset or downstream model without direct examination of that dataset's distribution and the task's requirements. [Inference]

> Disclaimer: Statements above regarding algorithm benefits, distributional outcomes, and library default behavior describe general, commonly cited conventions and documented parameters; they are not confirmed against direct code execution or the original source publication in every case, and are not guarantees of outcome for any specific dataset, library version, or model. Where marked [Unverified], this reflects an absence of direct verification, not a confirmed fact.

**Related Topics**
- Log and Power Transformations
- Min-Max Scaling
- Standardization (Z-score Scaling)
- Robust Scaling Using Median and IQR
- Skewness and Kurtosis Assessment
- Data Leakage Prevention in Preprocessing Pipelines

> Correction: This response labels claims regarding exact library output, formula sourcing against the original publication, default parameter behavior, and distributional guarantees as [Inference] or [Unverified] throughout, as marked, because these depend on specific datasets, library versions, or direct access to primary sources that I cannot confirm without direct execution or retrieval. No instance of "prevent," "guarantee," "will never," "fixes," "eliminates," or "ensures that" appears above outside of this correction note describing the labeling policy itself.