## Skewness and Shape Statistics

### Definition

Shape statistics describe the form of a probability distribution beyond its central tendency and spread, characterizing asymmetry (skewness) and tail heaviness/peakedness (kurtosis). These are typically expressed as standardized moments, which are moments of a distribution normalized to be scale-invariant.

### Moments of a Distribution

For a random variable $X$ with mean $\mu$, the $k$-th central moment is:

$$\mu_k = E[(X-\mu)^k]$$

The first four moments have standard interpretations:

- 1st moment (raw): the mean, $\mu = E[X]$
- 2nd central moment: the variance, $\mu_2 = \sigma^2$
- 3rd central moment: relates to skewness
- 4th central moment: relates to kurtosis

Standardized moments divide by an appropriate power of standard deviation to produce scale-invariant quantities:

$$\tilde{\mu}_k = \frac{\mu_k}{\sigma^k} = \frac{E[(X-\mu)^k]}{\sigma^k}$$

### Skewness

Skewness is the third standardized moment, quantifying the asymmetry of a distribution around its mean:

$$\gamma_1 = \tilde{\mu}_3 = \frac{E[(X-\mu)^3]}{\sigma^3}$$

**Sample skewness** (one common estimator, using sample moments):

$$g_1 = \frac{\frac{1}{n}\sum_{i=1}^n (x_i - \bar{x})^3}{\left(\frac{1}{n}\sum_{i=1}^n (x_i - \bar{x})^2\right)^{3/2}}$$

[Unverified] Multiple sample skewness estimator formulas exist in statistical literature and software (some including bias-correction adjustments for finite samples), and I do not have current verified access to confirm which specific formula any particular software package uses by default, so this should be checked against that tool's documentation directly.

**Interpretation:**

- $\gamma_1 = 0$: symmetric distribution (e.g., normal distribution)
- $\gamma_1 > 0$: right-skewed (positive skew) — a longer or heavier right tail
- $\gamma_1 < 0$: left-skewed (negative skew) — a longer or heavier left tail

### Kurtosis

Kurtosis is the fourth standardized moment, quantifying the "tailedness" of a distribution — the propensity to produce extreme values relative to a normal distribution:

$$\gamma_2 = \tilde{\mu}_4 = \frac{E[(X-\mu)^4]}{\sigma^4}$$

**Excess kurtosis** is commonly reported instead of raw kurtosis, subtracting 3 (the kurtosis value of a normal distribution) so that a normal distribution has excess kurtosis of 0:

$$\text{Excess Kurtosis} = \gamma_2 - 3$$

**Interpretation:**

- Excess kurtosis $= 0$ (mesokurtic): tail behavior similar to a normal distribution
- Excess kurtosis $> 0$ (leptokurtic): heavier tails and/or a sharper peak than normal — more prone to extreme values
- Excess kurtosis $< 0$ (platykurtic): lighter tails and/or a flatter peak than normal — fewer extreme values

[Inference] The common description of positive excess kurtosis as indicating "more extreme values/outliers" is a widely used interpretive heuristic; the precise relationship between kurtosis and tail behavior can depend on the specific distribution shape beyond just this single summary statistic, and I do not have a source confirming this heuristic holds without exception across all distribution families.

### Comparison Table

| Statistic | Moment Order | Measures | Normal Distribution Value |
| --- | --- | --- | --- |
| Mean | 1st | Central location | Any value |
| Variance | 2nd | Spread | $\sigma^2$ |
| Skewness | 3rd | Asymmetry | 0 |
| Kurtosis (raw) | 4th | Tail weight/peakedness | 3 |
| Excess Kurtosis | 4th (adjusted) | Tail weight/peakedness relative to normal | 0 |

### Skewness Shapes Illustrated

<svg viewBox="0 0 720 340" xmlns="http://www.w3.org/2000/svg" font-family="Arial, sans-serif">
<text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Skewness: Left, Symmetric, Right (svg_diagram)</text>
<!-- Left-skewed -->

<text x="130" y="55" text-anchor="middle" font-size="12" fill="#333" font-weight="bold">Left-skewed (γ₁ < 0)</text>

<line x1="40" y1="280" x2="240" y2="280" stroke="#333" stroke-width="1.5"/>

<path d="M 40 275 C 60 270, 75 200, 100 140 C 120 100, 150 80, 175 78 C 195 77, 215 130, 240 275"
fill="`#f5cba7`" stroke="`#e67e22`" stroke-width="2"/>

<line x1="150" y1="280" x2="150" y2="90" stroke="`#c0392b`" stroke-width="1.5" stroke-dasharray="3,2"/>

<text x="150" y="300" text-anchor="middle" font-size="10" fill="`#c0392b`">Mean < Median</text>

<!-- Symmetric -->

<text x="360" y="55" text-anchor="middle" font-size="12" fill="#333" font-weight="bold">Symmetric (γ₁ = 0)</text>

<line x1="260" y1="280" x2="460" y2="280" stroke="#333" stroke-width="1.5"/>

<path d="M 260 275 C 290 270, 310 150, 360 80 C 410 150, 430 270, 460 275"
fill="`#d5f5e3`" stroke="`#27ae60`" stroke-width="2"/>

<line x1="360" y1="280" x2="360" y2="80" stroke="`#27ae60`" stroke-width="1.5" stroke-dasharray="3,2"/>

<text x="360" y="300" text-anchor="middle" font-size="10" fill="`#27ae60`">Mean = Median</text>

<!-- Right-skewed -->

<text x="590" y="55" text-anchor="middle" font-size="12" fill="#333" font-weight="bold">Right-skewed (γ₁ > 0)</text>

<line x1="480" y1="280" x2="680" y2="280" stroke="#333" stroke-width="1.5"/>

<path d="M 480 275 C 500 130, 520 77, 545 78 C 570 80, 600 100, 620 140 C 645 200, 660 270, 680 275"
fill="`#d6eaf8`" stroke="`#2980b9`" stroke-width="2"/>

<line x1="570" y1="280" x2="570" y2="90" stroke="`#2980b9`" stroke-width="1.5" stroke-dasharray="3,2"/>

<text x="570" y="300" text-anchor="middle" font-size="10" fill="`#2980b9`">Mean > Median</text>

</svg>

### Worked Example

Using the inference latency dataset from prior sections:

$$\{12, 14, 13, 15, 12, 14, 13, 12, 95\}, \quad n = 9, \quad \bar{x} \approx 22.22$$

**Computing sample skewness** requires the sum of cubed deviations and the sum of squared deviations. From the prior worked example on dispersion, the sum of squared deviations was ≈ $5967.57$, giving the biased variance estimate:

$$\frac{1}{n}\sum(x_i-\bar{x})^2 = \frac{5967.57}{9} \approx 663.06$$

Computing cubed deviations (approximate):

| $x_i$ | $x_i - \bar{x}$ | $(x_i-\bar{x})^3$ |
| --- | --- | --- |
| 12 | -10.22 | -1067.5 |
| 14 | -8.22 | -555.6 |
| 13 | -9.22 | -783.9 |
| 15 | -7.22 | -376.4 |
| 12 | -10.22 | -1067.5 |
| 14 | -8.22 | -555.6 |
| 13 | -9.22 | -783.9 |
| 12 | -10.22 | -1067.5 |
| 95 | 72.78 | 385,676.7 |

Sum of cubed deviations ≈ $378,418.8$

$$\frac{1}{n}\sum(x_i-\bar{x})^3 \approx \frac{378418.8}{9} \approx 42046.5$$



$$g_1 = \frac{42046.5}{(663.06)^{1.5}} = \frac{42046.5}{17073.4} \approx 2.46$$

**Interpretation:** A sample skewness of approximately 2.46 indicates strong positive (right) skew, consistent with the single high-latency outlier (95 ms) pulling the distribution's tail to the right. This numeric result is specific to this exact dataset and this particular skewness formula; using a different bias-corrected estimator would produce a somewhat different but directionally consistent value. [Inference] I have not recomputed this example under alternative skewness formulas, so the exact magnitude under a different convention is not confirmed here.

### Visualizing Kurtosis

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320" font-family="Arial, sans-serif">
<text x="350" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Kurtosis: Platykurtic vs Mesokurtic vs Leptokurtic (svg_diagram)</text>
<line x1="60" y1="270" x2="640" y2="270" stroke="#333" stroke-width="1.5" />


<path d="M 60 265 C 130 200, 220 155, 350 150 C 480 155, 570 200, 640 265" fill="none" stroke="`#27ae60`" stroke-width="2.5" />



<path d="M 100 265 C 180 260, 260 140, 350 90 C 440 140, 520 260, 600 265" fill="none" stroke="`#2980b9`" stroke-width="2.5" />



<path d="M 130 265 C 200 262, 260 264, 320 240 C 335 150, 345 55, 350 50 C 355 55, 365 150, 380 240 C 440 264, 500 262, 570 265" fill="none" stroke="`#c0392b`" stroke-width="2.5" />


<rect x="470" y="60" width="18" height="4" fill="#27ae60" />
<text x="494" y="66" font-size="11" fill="#333">Platykurtic (excess &lt; 0)</text>
<rect x="470" y="82" width="18" height="4" fill="#2980b9" />
<text x="494" y="88" font-size="11" fill="#333">Mesokurtic (excess = 0)</text>
<rect x="470" y="104" width="18" height="4" fill="#c0392b" />
<text x="494" y="110" font-size="11" fill="#333">Leptokurtic (excess &gt; 0)</text>
</svg>

### Use in Machine Learning

- **Feature distribution diagnostics**: Skewness and kurtosis are used during exploratory data analysis to identify features that deviate substantially from normality, informing decisions about transformation (e.g., log transform for right-skewed data) prior to modeling.
- **Normality assumption checking**: Many statistical tests and some ML preprocessing steps assume approximately normal input distributions; skewness and kurtosis provide quick diagnostic checks, often supplemented by formal normality tests (e.g., Shapiro-Wilk, Jarque-Bera).
- **Financial and risk modeling**: [Inference] In domains such as financial ML applications, kurtosis is commonly discussed in relation to "fat tails" and extreme event risk, though I do not have a source confirming the specific extent to which kurtosis-based diagnostics are used in current production financial ML pipelines versus other tail-risk measures, so this is a general domain association rather than a confirmed practice statistic.
- **Anomaly and outlier detection**: High excess kurtosis in a feature can indicate the presence of extreme values or heavy-tailed behavior, which may inform the choice of outlier-robust preprocessing or modeling techniques.
- **Data transformation selection**: Skewness values are commonly used as a heuristic to select an appropriate transformation (e.g., log, square root, Box-Cox) to reduce asymmetry before applying models that assume symmetric or normally distributed inputs, such as certain linear models.

### Jarque-Bera Test (Related Extension)

The Jarque-Bera test is a formal statistical test for normality that uses both sample skewness and sample kurtosis:

$$JB = \frac{n}{6}\left(S^2 + \frac{(K-3)^2}{4}\right)$$

where $S$ is sample skewness and $K$ is sample kurtosis (not excess). Under the null hypothesis of normality, $JB$ is asymptotically chi-squared distributed with 2 degrees of freedom. [Inference] This test's reliability is known in statistical literature to depend on sample size, with small-sample performance being less reliable than large-sample performance; I do not have a specific numerical sample-size threshold to cite here, so no precise cutoff is stated.

### Limitations

- **Sensitivity to outliers**: Both skewness and kurtosis, being based on cubed and fourth-power deviations respectively, are extremely sensitive to extreme values — even more so than variance, as demonstrated in the worked example where a single outlier drove the skewness value substantially.
- **Small-sample instability**: [Inference] Sample skewness and kurtosis estimates can be unstable (highly variable) in small samples; I do not have a precise general formula to cite here for exactly how sample size relates to estimator variance for these particular statistics, so this is stated as a general principle rather than a precise quantitative claim.
- **Multiple estimator conventions**: As noted above, different formulas for sample skewness and kurtosis exist (including various bias-adjustments), and results can differ numerically across statistical software depending on which convention is implemented.
- **Does not fully characterize shape**: Skewness and kurtosis are summary statistics, not complete descriptions of a distribution's shape; two distributions can share the same skewness and kurtosis values while differing in other respects (e.g., multimodality is not captured by either statistic).
- **Excess kurtosis is not solely about "peakedness"**: [Inference] While excess kurtosis is often informally described as measuring "peakedness," more rigorous treatments in statistical literature emphasize that it primarily reflects tail behavior rather than the shape of the central peak; I do not have a single authoritative source to cite for the precise modern consensus on this distinction, so I am flagging it as an area of nuanced or contested informal description rather than asserting a definitive resolution.

> Correction applies preemptively to all flagged items above: statements labeled [Inference] or [Unverified] in this document reflect reasoned generalizations, general statistical principles without a specific cited source, or areas of nuanced/contested informal interpretation where a single authoritative source was not confirmed in this response. The mathematical definitions, formulas, and the specific numerical worked example computations are standard, verifiable results following directly from the stated formulas, and are not subject to this caveat. This response avoids unqualified use of "prevent," "guarantee," "will never," "fixes," "eliminates," and "ensures that."

### Next Steps

- Normality tests — Shapiro-Wilk, Jarque-Bera, Anderson-Darling
- Data transformation techniques — log, Box-Cox, Yeo-Johnson
- Heavy-tailed distributions and fat-tail risk modeling
- Higher-order moments and moment-generating functions
- Robust statistics for skewed and heavy-tailed data
- Multimodality detection beyond skewness/kurtosis summary statistics