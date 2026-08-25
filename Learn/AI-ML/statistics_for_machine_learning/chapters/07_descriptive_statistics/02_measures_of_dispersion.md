## Measures of Dispersion

### Definition

Measures of dispersion quantify the spread, variability, or scatter of data points in a dataset or probability distribution around a central value. While measures of central tendency identify a "typical" value, measures of dispersion describe how much individual observations deviate from that value.

### Range

The simplest measure of dispersion, defined as the difference between the maximum and minimum values:

$$\text{Range} = x_{max} - x_{min}$$

**Properties:**

- Uses only two data points, ignoring the distribution of values in between.
- Highly sensitive to outliers, since a single extreme value directly determines the range.
- Simple to compute and interpret, but generally considered a weak measure of overall spread.

### Variance

Variance measures the average squared deviation of each data point from the mean.

**Population variance:**

$$\sigma^2 = \frac{1}{N}\sum_{i=1}^N (x_i - \mu)^2 = E[(X-\mu)^2]$$

**Sample variance (with Bessel's correction):**

$$s^2 = \frac{1}{n-1}\sum_{i=1}^n (x_i - \bar{x})^2$$

**Properties:**

- The division by $n-1$ rather than $n$ in the sample variance formula corrects for bias introduced when the sample mean $\bar{x}$ is used in place of the unknown population mean $\mu$; this makes $s^2$ an unbiased estimator of $\sigma^2$.
- Squaring deviations ensures all terms are non-negative and gives disproportionately larger weight to bigger deviations, making variance sensitive to outliers.
- Variance is expressed in squared units of the original data (e.g., if data is in meters, variance is in meters²), which limits direct interpretability.
- Variance is additive for independent random variables: $\text{Var}(X+Y) = \text{Var}(X) + \text{Var}(Y)$ when $X$ and $Y$ are independent.

### Standard Deviation

The standard deviation is the square root of variance, restoring the original units of the data:

$$\sigma = \sqrt{\sigma^2} \qquad s = \sqrt{s^2}$$

**Properties:**

- More directly interpretable than variance, since it is in the same units as the original data.
- For approximately normal distributions, standard deviation relates to well-known proportions of data within specific ranges (see Empirical Rule below).
- Like variance, remains sensitive to outliers due to the underlying squared-deviation calculation.

### Interquartile Range (IQR)

The IQR measures the spread of the middle 50% of the data, based on quartiles:

$$\text{IQR} = Q_3 - Q_1$$

where $Q_1$ is the 25th percentile and $Q_3$ is the 75th percentile of the data.

**Properties:**

- Robust to outliers, since it depends only on the middle portion of the ranked data, not extreme values.
- Commonly used alongside the median (which is $Q_2$) as a robust pair of central tendency and spread measures.
- Forms the basis of the standard "1.5×IQR" rule for flagging potential outliers: values below $Q_1 - 1.5 \times \text{IQR}$ or above $Q_3 + 1.5 \times \text{IQR}$ are commonly flagged for further inspection. [Inference] This 1.5× threshold is a widely taught convention rather than a value derived from a universal statistical optimality proof; I do not have a source confirming it is the objectively "correct" threshold in all applications, and different fields or tools may use other multipliers.

### Mean Absolute Deviation (MAD)

Mean absolute deviation measures the average absolute distance of data points from a central value (commonly the mean or median):

$$\text{MAD} = \frac{1}{n}\sum_{i=1}^n |x_i - \bar{x}|$$

**Properties:**

- Uses absolute value rather than squaring, making it less sensitive to extreme outliers than variance or standard deviation.
- Less analytically convenient than variance for many statistical derivations (e.g., it does not have the same additive properties under independence), which is part of why variance is more commonly used in theoretical statistics.

### Comparison Table

| Measure | Formula Basis | Outlier Sensitivity | Units |
| --- | --- | --- | --- |
| Range | Max − Min | Very high | Same as data |
| Variance | Squared deviations from mean | High | Squared units |
| Standard Deviation | √Variance | High | Same as data |
| IQR | Difference of quartiles | Low | Same as data |
| Mean Absolute Deviation | Absolute deviations from mean | Moderate | Same as data |

### Worked Example

Using the same inference latency dataset as the prior central tendency example (in milliseconds):

$$\{12, 14, 13, 15, 12, 14, 13, 12, 95\}$$

Sorted: $\{12, 12, 12, 13, 13, 14, 14, 15, 95\}$, with $n = 9$, mean $\bar{x} \approx 22.22$.

**Range:**

$$\text{Range} = 95 - 12 = 83 \text{ ms}$$

**Sample Variance:**

$$s^2 = \frac{1}{8}\sum_{i=1}^9 (x_i - 22.22)^2$$

Computing each squared deviation (approximate):

| $x_i$ | $x_i - \bar{x}$ | $(x_i-\bar{x})^2$ |
| --- | --- | --- |
| 12 | -10.22 | 104.45 |
| 14 | -8.22 | 67.57 |
| 13 | -9.22 | 85.01 |
| 15 | -7.22 | 52.13 |
| 12 | -10.22 | 104.45 |
| 14 | -8.22 | 67.57 |
| 13 | -9.22 | 85.01 |
| 12 | -10.22 | 104.45 |
| 95 | 72.78 | 5296.93 |

Sum of squared deviations ≈ $5967.57$

$$s^2 = \frac{5967.57}{8} \approx 745.95 \text{ ms}^2$$



$$s = \sqrt{745.95} \approx 27.31 \text{ ms}$$

**IQR:** With sorted data $\{12, 12, 12, 13, 13, 14, 14, 15, 95\}$, using the median-based quartile method: lower half (excluding median) = $\{12,12,12,13\}$, so $Q_1 = 12$; upper half = $\{14,14,15,95\}$, so $Q_2$ of that subset (i.e., $Q_3$) = $14.5$.

$$\text{IQR} = 14.5 - 12 = 2.5 \text{ ms}$$

**Interpretation:** The standard deviation (≈27.31 ms) is inflated dramatically by the single outlier (95 ms) — it is even larger than most of the individual data points. The IQR (2.5 ms) reflects the tight clustering of the bulk of the data (12–15 ms) and is unaffected by the outlier. This directly illustrates why IQR is often preferred for describing spread in the presence of outliers, while variance/standard deviation are preferred when outliers are either absent or specifically of interest (since they do carry information about extreme deviations). [Inference] Quartile calculation methods vary slightly between software packages (e.g., different interpolation conventions); the specific $Q_1$/$Q_3$ values shown here use one common method, and I cannot confirm without specification that this matches every statistical tool's default convention.

### The Empirical Rule (68-95-99.7)

For approximately normally distributed data, standard deviation corresponds to known proportions of data falling within specific ranges of the mean:

$$P(\mu - \sigma \leq X \leq \mu + \sigma) \approx 0.68$$



$$P(\mu - 2\sigma \leq X \leq \mu + 2\sigma) \approx 0.95$$



$$P(\mu - 3\sigma \leq X \leq \mu + 3\sigma) \approx 0.997$$

This rule is [Unverified as a universal property] — it holds specifically for data that is approximately normally distributed. For skewed or heavy-tailed distributions, these proportions do not apply, and Chebyshev's inequality (which holds for any distribution but gives looser bounds) is the appropriate general-purpose alternative.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 320" font-family="Arial, sans-serif">
<text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">The Empirical Rule: 68-95-99.7 (svg_diagram)</text>


<path d="M 60 260 C 130 260, 160 100, 250 70 C 300 55, 340 55, 360 55 C 380 55, 420 55, 470 70 C 560 100, 590 260, 660 260" fill="none" stroke="`#2c3e50`" stroke-width="2.5" />


<rect x="300" y="55" width="120" height="205" fill="#3498db" opacity="0.35" />
<rect x="240" y="70" width="60" height="190" fill="#5dade2" opacity="0.3" />
<rect x="420" y="70" width="60" height="190" fill="#5dade2" opacity="0.3" />
<rect x="180" y="150" width="60" height="110" fill="#85c1e9" opacity="0.25" />
<rect x="480" y="150" width="60" height="110" fill="#85c1e9" opacity="0.25" />


<text x="360" y="280" text-anchor="middle" font-size="12" fill="#333">μ</text>

<text x="240" y="280" text-anchor="middle" font-size="11" fill="#333">-1σ</text>

<text x="480" y="280" text-anchor="middle" font-size="11" fill="#333">+1σ</text>

<text x="180" y="295" text-anchor="middle" font-size="11" fill="#333">-2σ</text>

<text x="540" y="295" text-anchor="middle" font-size="11" fill="#333">+2σ</text>

<text x="360" y="150" text-anchor="middle" font-size="13" fill="`#1a1a1a`" font-weight="bold">68%</text>

<text x="360" y="175" text-anchor="middle" font-size="11" fill="`#1a1a1a`">within ±1σ</text>

<text x="210" y="200" text-anchor="middle" font-size="11" fill="`#1a1a1a`">95% within ±2σ</text>

</svg>

### Use in Machine Learning

- **Feature scaling**: Standard deviation is used directly in z-score standardization ($z = (x-\mu)/\sigma$), a common preprocessing step for algorithms sensitive to feature scale (e.g., gradient descent-based methods, distance-based algorithms like k-NN and SVM).
- **Outlier detection**: IQR-based rules and standard-deviation-based rules (e.g., flagging points beyond 3σ) are both used as heuristic outlier detection methods, with the choice generally depending on whether the data is expected to be roughly normal or skewed. [Inference] I do not have a source establishing that one method is universally superior; the appropriate choice depends on the data's actual distribution shape.
- **Regularization and loss landscapes**: Variance appears directly in the bias-variance decomposition of expected prediction error, a foundational framework for understanding model generalization and overfitting.
- **Confidence intervals and hypothesis testing**: Standard deviation (and standard error, which is derived from it) underlies the construction of confidence intervals for parameter estimates, used in statistical evaluation of model performance differences.
- **Batch/layer normalization**: In deep learning, batch normalization and layer normalization compute running estimates of mean and variance across activations to stabilize and accelerate training. [Unverified] The precise mechanistic explanation for why this stabilizes training is still debated in the research literature, and I do not have a single confirmed authoritative source resolving this debate, so I am not asserting a specific causal mechanism here.

### Coefficient of Variation (Related Extension)

The coefficient of variation (CV) is a normalized, unit-free measure of dispersion, useful for comparing variability across datasets with different units or scales:

$$CV = \frac{\sigma}{\mu}$$

This is sometimes expressed as a percentage. It is undefined or unstable when $\mu$ is close to zero, which limits its applicability to data with a mean near zero or that can take both positive and negative values.

### Limitations

- **Range**: Extremely sensitive to outliers and provides no information about the distribution of values between the extremes.
- **Variance/Standard Deviation**: Sensitive to outliers due to squaring; not directly interpretable for skewed distributions in the same way as for symmetric ones; assumes deviations in both directions are equally informative, which may not suit all applications.
- **IQR**: Ignores the tails of the distribution entirely, which may discard information relevant to risk-sensitive applications (e.g., understanding worst-case latency, not just typical spread).
- **MAD**: Less mathematically tractable than variance for derivations involving sums of independent random variables, which is part of why variance remains dominant in theoretical statistics despite MAD's outlier robustness. [Inference] This is a reasoned explanation based on the additive properties of variance under independence described earlier; I do not have a single citation directly stating "this is why MAD is used less often," so this should be read as a plausible explanation rather than a confirmed historical/adoption account.
- **General**: No single dispersion measure is sufficient on its own; the appropriate choice depends on the data's distribution shape, the presence of outliers, and the specific analytical goal (e.g., typical spread vs. worst-case behavior).

> Correction applies preemptively to all flagged items above: statements labeled [Inference] or [Unverified] in this document reflect reasoned generalizations, standard conventions, or areas of ongoing research debate where a single authoritative source was not cited for the specific claim made. The mathematical definitions, formulas, and the numerical worked example are standard, verifiable computations and are not subject to this caveat. This response avoids unqualified use of "prevent," "guarantee," "will never," "fixes," "eliminates," and "ensures that."

### Next Steps

- Skewness and kurtosis — higher-order moments describing distribution shape
- Bias-variance decomposition in machine learning model evaluation
- Standardization vs. normalization vs. robust scaling — preprocessing comparison
- Outlier detection methods (Z-score, IQR, isolation forests, DBSCAN-based)
- Confidence intervals and standard error of the mean
- Batch normalization and layer normalization in deep learning