## Percentiles and Quantiles

### Definition

Quantiles are values that divide an ordered dataset or probability distribution into intervals with specified proportions of the data. Percentiles are a specific type of quantile that divide data into 100 equal-proportion parts.

Formally, for a continuous random variable $X$ with cumulative distribution function (CDF) $F(x)$, the $p$-th quantile $Q(p)$, for $p \in (0,1)$, is defined as:

$$Q(p) = \inf\{x : F(x) \geq p\}$$

The $k$-th percentile corresponds to $Q(k/100)$ for $k \in \{1, 2, \ldots, 99\}$.

### Key Points

- Percentiles, deciles, and quartiles are all specific cases of quantiles, differing only in how many divisions are used (100, 10, and 4, respectively).
- The median is the 50th percentile, or equivalently the 2nd quartile ($Q_2$) and 5th decile.
- Quantile computation for finite samples involves an inherent ambiguity when data points do not fall exactly at the desired proportion, leading to multiple valid interpolation methods (discussed below).
- Quantiles are robust to outliers in the sense that a percentile's *value* can be affected by extreme values, but its *rank position* is not — this distinguishes quantile-based summaries from mean-based summaries in terms of stability under data contamination.

### Quartiles, Deciles, and Percentiles

| Division Type | Number of Parts | Boundary Points | Common Notation |
| --- | --- | --- | --- |
| Quartiles | 4 | 3 boundaries | $Q_1, Q_2, Q_3$ |
| Deciles | 10 | 9 boundaries | $D_1, \ldots, D_9$ |
| Percentiles | 100 | 99 boundaries | $P_1, \ldots, P_{99}$ |

Standard reference points:

- $Q_1 = P_{25}$ (25th percentile)
- $Q_2 = P_{50}$ (median)
- $Q_3 = P_{75}$ (75th percentile)

### Sample Quantile Estimation Methods

For a finite sample, computing an exact quantile requires choosing an interpolation method when the desired rank falls between two data points. Multiple conventions exist; I cannot verify which single method is used "by default" across all statistical software without checking each tool individually, since defaults differ.

**Linear interpolation method** (one common approach): For sorted data $x_{(1)} \leq x_{(2)} \leq \ldots \leq x_{(n)}$, the position for the $p$-th quantile is:

$$h = (n-1)p + 1$$

If $h$ is an integer, $Q(p) = x_{(h)}$. Otherwise, interpolate between the surrounding order statistics:

$$Q(p) = x_{(\lfloor h \rfloor)} + (h - \lfloor h \rfloor)\left(x_{(\lceil h \rceil)} - x_{(\lfloor h \rfloor)}\right)$$

[Unverified] Different software packages (e.g., specific versions of NumPy, R, Excel) may implement different interpolation conventions (there are at least nine documented methods in some statistical literature), and I do not have current verified access to confirm which specific method each current tool version defaults to, so any claim about a specific tool's current default should be checked directly against that tool's documentation rather than assumed from this response.

### Worked Example

Using the same inference latency dataset from prior sections (in milliseconds), sorted:

$$\{12, 12, 12, 13, 13, 14, 14, 15, 95\}, \quad n = 9$$

**Finding the 25th percentile ($Q_1$)** using the linear interpolation method:

$$h = (9-1)(0.25) + 1 = 2 + 1 = 3$$

Since $h = 3$ is an integer: $Q_1 = x_{(3)} = 12$ ms.

**Finding the 75th percentile ($Q_3$):**

$$h = (9-1)(0.75) + 1 = 6 + 1 = 7$$

Since $h = 7$ is an integer: $Q_3 = x_{(7)} = 14$ ms.

**Finding the 90th percentile ($P_{90}$):**

$$h = (9-1)(0.90) + 1 = 7.2 + 1 = 8.2$$

Since $h = 8.2$ is not an integer, interpolate between $x_{(8)} = 15$ and $x_{(9)} = 95$:

$$Q(0.90) = 15 + (0.2)(95 - 15) = 15 + 16 = 31 \text{ ms}$$

**Interpretation:** The 90th percentile (31 ms) is substantially higher than $Q_3$ (14 ms), reflecting the influence of the single outlier (95 ms) on upper-tail percentiles even though the bulk of the data clusters near 12–15 ms. This demonstrates that while quantiles are more robust than the mean for central measures like the median, upper and lower extreme percentiles ($P_{95}$, $P_{99}$, etc.) are still directly shaped by tail values, since that is precisely what they are designed to describe. [Inference] This interpolation result depends on the specific method used; a different interpolation convention could produce a somewhat different numeric value for $P_{90}$ on this same dataset, though I have not recomputed this example under alternative methods here.

### The Empirical CDF and Quantile Function

The quantile function is the (generalized) inverse of the cumulative distribution function. This relationship is foundational to simulation and probabilistic modeling.

$$Q(p) = F^{-1}(p)$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 380" font-family="Arial, sans-serif">
<text x="360" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">CDF and Quantile Function as Inverses (svg_diagram)</text>


<text x="170" y="50" text-anchor="middle" font-size="13" fill="#333" font-weight="bold">CDF: F(x)</text>

<line x1="60" y1="300" x2="290" y2="300" stroke="#333" stroke-width="2" />

<line x1="60" y1="300" x2="60" y2="70" stroke="#333" stroke-width="2" />

<text x="175" y="320" text-anchor="middle" font-size="11" fill="#333">x</text>

<text x="30" y="185" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 30 185)">F(x)</text>

<path d="M 60 295 C 100 293, 130 260, 160 190 C 190 130, 220 90, 260 78 L 290 76" fill="none" stroke="`#2980b9`" stroke-width="3" />

<line x1="60" y1="185" x2="185" y2="185" stroke="#c0392b" stroke-width="1.5" stroke-dasharray="4,3" />
<line x1="185" y1="300" x2="185" y2="185" stroke="#c0392b" stroke-width="1.5" stroke-dasharray="4,3" />
<text x="45" y="188" text-anchor="end" font-size="10" fill="#c0392b">p</text>
<text x="185" y="315" text-anchor="middle" font-size="10" fill="#c0392b">Q(p)</text>


<text x="550" y="50" text-anchor="middle" font-size="13" fill="#333" font-weight="bold">Quantile Function: Q(p)</text>

<line x1="440" y1="300" x2="670" y2="300" stroke="#333" stroke-width="2" />

<line x1="440" y1="300" x2="440" y2="70" stroke="#333" stroke-width="2" />

<text x="555" y="320" text-anchor="middle" font-size="11" fill="#333">p</text>

<text x="410" y="185" text-anchor="middle" font-size="11" fill="#333" transform="rotate(-90 410 185)">Q(p)</text>

<path d="M 440 295 C 460 290, 480 270, 500 240 C 530 195, 560 130, 590 90 C 610 75, 630 70, 670 68" fill="none" stroke="`#27ae60`" stroke-width="3" />

<line x1="440" y1="240" x2="500" y2="240" stroke="#c0392b" stroke-width="1.5" stroke-dasharray="4,3" />
<line x1="500" y1="300" x2="500" y2="240" stroke="#c0392b" stroke-width="1.5" stroke-dasharray="4,3" />
<text x="425" y="243" text-anchor="end" font-size="10" fill="#c0392b">Q(p)</text>
<text x="500" y="315" text-anchor="middle" font-size="10" fill="#c0392b">p</text>
</svg>

### Use in Machine Learning

- **Outlier detection and IQR-based rules**: Quartiles ($Q_1$, $Q_3$) directly define the interquartile range used in standard outlier-flagging heuristics, as covered in measures of dispersion.
- **Quantile regression**: Rather than modeling the conditional mean of a target variable (as in ordinary least squares), quantile regression models a specified conditional quantile (e.g., the median or the 90th percentile), which is useful when the full conditional distribution's shape, not just its center, matters — such as in risk-sensitive forecasting.
- **Feature engineering and binning**: Percentile-based binning (e.g., converting a continuous feature into deciles) is a common discretization technique, particularly useful when a feature's raw scale is less informative than its relative rank.
- **Latency and performance monitoring (P50/P95/P99)**: In ML systems and infrastructure monitoring generally, percentile latency metrics (P50, P95, P99) are widely used to characterize system performance, since the mean latency can be misleading in the presence of occasional slow outliers, as shown in the worked example above.
- **Model calibration and prediction intervals**: Quantile-based prediction intervals (e.g., from quantile regression or quantile-based ensemble methods like quantile random forests) provide a way to express predictive uncertainty without assuming a specific parametric distribution shape.
- **Normalization via quantile transformation**: Some preprocessing pipelines use quantile transformation to map a feature's distribution to a uniform or normal distribution based on its empirical quantiles, which can help algorithms sensitive to non-Gaussian feature distributions. [Inference] I do not have a source confirming how frequently this specific technique (as opposed to standard scaling) is used across ML practice generally, so this should be read as a description of an available technique rather than a claim about its relative popularity.

### Box Plot Representation

Quartiles form the basis of the box plot (box-and-whisker plot), a standard visualization for summarizing a distribution's central tendency, spread, and potential outliers simultaneously.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 300" font-family="Arial, sans-serif">
<text x="350" y="24" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Box Plot Anatomy (svg_diagram)</text>
<line x1="80" y1="180" x2="620" y2="180" stroke="#ccc" stroke-width="1" />

<line x1="140" y1="180" x2="220" y2="180" stroke="#333" stroke-width="2" />
<line x1="140" y1="150" x2="140" y2="210" stroke="#333" stroke-width="2" />
<line x1="460" y1="180" x2="540" y2="180" stroke="#333" stroke-width="2" />
<line x1="540" y1="150" x2="540" y2="210" stroke="#333" stroke-width="2" />

<rect x="220" y="130" width="240" height="100" fill="#aed6f1" stroke="#2980b9" stroke-width="2" />

<line x1="340" y1="130" x2="340" y2="230" stroke="#c0392b" stroke-width="3" />

<circle cx="590" cy="180" r="5" fill="#e74c3c" />


<text x="140" y="240" text-anchor="middle" font-size="11" fill="#333">Min (within 1.5×IQR)</text>

<text x="220" y="118" text-anchor="middle" font-size="11" fill="#333">Q1</text>

<text x="340" y="118" text-anchor="middle" font-size="11" fill="`#c0392b`" font-weight="bold">Median (Q2)</text>

<text x="460" y="118" text-anchor="middle" font-size="11" fill="#333">Q3</text>

<text x="540" y="240" text-anchor="middle" font-size="11" fill="#333">Max (within 1.5×IQR)</text>

<text x="590" y="200" text-anchor="middle" font-size="11" fill="`#e74c3c`">Outlier</text>

</svg>

### Limitations

- **Interpolation ambiguity**: Because multiple valid interpolation conventions exist for finite samples, the same dataset can yield slightly different percentile values depending on the method and software used. I cannot verify a single "correct" universal method without reference to a specific standard or tool.
- **Tail percentiles remain outlier-sensitive**: As shown in the worked example, while the median is robust, extreme percentiles (P95, P99, etc.) are directly determined by tail behavior and are not "robust" in the same sense — this is an inherent property of what tail percentiles are designed to measure, not a flaw.
- **Sample size sensitivity**: Estimating extreme percentiles (e.g., P99, P99.9) reliably requires substantially larger sample sizes than estimating the median, since fewer data points inform the extreme tail region. [Inference] I do not have a specific formula or source to cite for exact minimum sample size requirements per percentile level in this response, so this should be treated as a general statistical principle rather than a precise quantitative guideline.
- **Discrete data caveats**: For discrete or heavily tied data, quantile boundaries may fall exactly on repeated values, which can make some interpolation methods behave differently than they would for continuous data.

> Correction applies preemptively to all flagged items above: statements labeled [Inference] or [Unverified] in this document reflect reasoned generalizations, general statistical principles without a specific cited source, or areas where implementation details vary by software and were not individually verified in this response. The mathematical definitions, formulas, and the specific numerical worked example computations are standard, verifiable results and are not subject to this caveat. This response avoids unqualified use of "prevent," "guarantee," "will never," "fixes," "eliminates," and "ensures that."

### Next Steps

- Box plots and visual distribution summaries
- Quantile regression — formal model specification and loss function
- Quantile transformation and normalization techniques
- P50/P95/P99 latency monitoring in production ML systems
- Order statistics — theoretical properties and distributions
- Empirical cumulative distribution function (ECDF) estimation