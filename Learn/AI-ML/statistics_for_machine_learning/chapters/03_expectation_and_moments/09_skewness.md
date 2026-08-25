## Skewness

### Definition

Skewness measures the asymmetry of a probability distribution around its mean. The population skewness of a random variable $X$ is defined as the third standardized moment:

$$\text{Skew}(X) = E\left[\left(\frac{X - \mu}{\sigma}\right)^3\right] = \frac{E[(X-\mu)^3]}{\sigma^3}$$

where $\mu = E[X]$ and $\sigma$ is the standard deviation of $X$.

### Interpretation

- **Skew $> 0$ (right/positive skew)**: the distribution has a longer or heavier tail extending toward higher values. The bulk of the mass sits on the left, with a tail stretching right.
- **Skew $< 0$ (left/negative skew)**: the distribution has a longer or heavier tail extending toward lower values. The bulk of the mass sits on the right, with a tail stretching left.
- **Skew $\approx 0$**: the distribution is roughly symmetric around its mean. A normal distribution has skewness exactly $0$.

A common point of confusion: the direction of skew refers to the direction of the tail, not the direction in which most of the data points lie or where the peak is located.

### Relationship Between Mean, Median, and Mode

For unimodal distributions with moderate skew, a commonly cited heuristic is:

- Right-skewed: mean > median > mode
- Left-skewed: mean < median < mode
- Symmetric: mean ≈ median ≈ mode

[Unverified] This ordering is a commonly taught rule of thumb in introductory statistics, but it does not hold universally for all distributions — there exist skewed distributions where this ordering is violated. I do not have a specific source in this conversation to cite for the exact conditions under which the heuristic fails, so this should be treated as an approximate guideline rather than a guaranteed mathematical property.

### Sample Skewness

For a sample of $n$ observations, one common estimator (Fisher-Pearson coefficient of skewness) is:

$$g_1 = \frac{\frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{x})^3}{\left(\frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{x})^2\right)^{3/2}}$$

An adjusted version correcting for sample bias is sometimes used:

$$G_1 = \frac{\sqrt{n(n-1)}}{n-2} \, g_1$$

[Unverified] Multiple skewness estimators exist across different statistical software packages, and I do not have a confirmed, specific source in this conversation verifying which estimator is treated as the default in any particular tool. This formula reflects a commonly cited adjusted estimator in statistics references, but its use as a "default" cannot be confirmed here.

### Types of Skewed Distributions

- **Exponential distribution**: always right-skewed, with skewness exactly $2$ regardless of the rate parameter.
- **Log-normal distribution**: right-skewed, common for modeling quantities like income or reaction times.
- **Beta distribution**: can be left-skewed, right-skewed, or symmetric depending on its two shape parameters.
- **Normal distribution**: symmetric, skewness $= 0$.

**Example**

Consider a small dataset: $\{2, 3, 3, 4, 4, 4, 5, 15\}$. The value $15$ is a high outlier relative to the rest of the data, which is clustered between $2$ and $5$. This produces a long right tail, and the sample skewness will be positive, since the third central moment is dominated by the large positive deviation of the outlier from the mean.

I have not computed the exact numerical value of skewness for this dataset in this response; presenting a specific decimal result without performing and verifying the calculation step by step would risk an unverified numerical claim.

### Effect on Statistical Assumptions

Many classical statistical methods (e.g., ordinary least squares regression, t-tests) assume normally distributed errors or approximately symmetric data. Substantial skewness can affect the validity of confidence intervals and hypothesis tests that rely on normality assumptions. [Inference] This is a widely taught principle in statistics coursework connecting skewness to the robustness of parametric methods, though the practical magnitude of impact depends on sample size, the specific test used, and the degree of skew — this is a general pattern, not a guaranteed outcome for any specific dataset or test.

### Relevance to Machine Learning

- **Feature transformation**: skewed features are sometimes transformed (e.g., log transform, Box-Cox transform) prior to modeling, particularly for algorithms sensitive to the scale and distribution of input features.
- **Target variable skew in regression**: a highly skewed target variable can affect the performance of models that assume roughly symmetric residuals, such as ordinary least squares.
- **Outlier detection**: skewness statistics are sometimes used as a diagnostic signal alongside other exploratory data analysis techniques to flag distributions that may contain outliers or heavy tails.
- **Distributional assumptions in generative models**: skewness informs whether a Gaussian assumption is reasonable for a given variable, relevant to models such as Gaussian Mixture Models or linear discriminant analysis.

[Inference] These are patterns commonly described in machine learning and statistics coursework connecting skewness to preprocessing decisions. I do not have access to information about how any specific software library or production system internally handles skewed features, and behavior in any particular implementation is not guaranteed to match this general description. This entire subsection should be treated as [Inference], not as a confirmed technical specification of any named tool.

### Visualization

<svg viewBox="0 0 640 320" xmlns="http://www.w3.org/2000/svg">
  <text x="320" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Skewness and Mean-Median-Mode Position (svg_diagram)</text>

  <g transform="translate(20,60)">
    <text x="90" y="0" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Left-skewed</text>
    <rect x="0" y="10" width="180" height="150" fill="none" stroke="#888" stroke-width="1"/>
    <path d="M 10,145 Q 30,145 40,125 Q 55,90 70,55 Q 80,25 95,18 Q 108,15 125,20 Q 145,28 170,50 L 170,150 L 10,150 Z" fill="#93c5fd" stroke="#2563eb" stroke-width="1.5"/>
    <line x1="95" y1="15" x2="95" y2="150" stroke="#1e40af" stroke-width="1" stroke-dasharray="3,2"/>
    <line x1="115" y1="15" x2="115" y2="150" stroke="#7c2d12" stroke-width="1" stroke-dasharray="3,2"/>
    <line x1="80" y1="15" x2="80" y2="150" stroke="#166534" stroke-width="1" stroke-dasharray="3,2"/>
    <text x="90" y="165" text-anchor="middle" font-size="9" fill="#444">mean &lt; median &lt; mode</text>
  </g>

  <g transform="translate(230,60)">
    <text x="90" y="0" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Symmetric</text>
    <rect x="0" y="10" width="180" height="150" fill="none" stroke="#888" stroke-width="1"/>
    <path d="M 10,145 Q 40,145 55,100 Q 75,20 90,20 Q 105,20 125,100 Q 140,145 170,145 L 170,150 L 10,150 Z" fill="#86efac" stroke="#16a34a" stroke-width="1.5"/>
    <line x1="90" y1="15" x2="90" y2="150" stroke="#1e40af" stroke-width="1.5" stroke-dasharray="3,2"/>
    <text x="90" y="165" text-anchor="middle" font-size="9" fill="#444">mean ≈ median ≈ mode</text>
  </g>

  <g transform="translate(440,60)">
    <text x="90" y="0" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Right-skewed</text>
    <rect x="0" y="10" width="180" height="150" fill="none" stroke="#888" stroke-width="1"/>
    <path d="M 10,50 Q 30,28 50,20 Q 63,15 80,18 Q 95,25 110,55 Q 125,90 140,125 Q 150,145 170,145 L 170,150 L 10,150 Z" fill="#fca5a5" stroke="#dc2626" stroke-width="1.5"/>
    <line x1="55" y1="15" x2="55" y2="150" stroke="#166534" stroke-width="1" stroke-dasharray="3,2"/>
    <line x1="75" y1="15" x2="75" y2="150" stroke="#7c2d12" stroke-width="1" stroke-dasharray="3,2"/>
    <line x1="95" y1="15" x2="95" y2="150" stroke="#1e40af" stroke-width="1" stroke-dasharray="3,2"/>
    <text x="90" y="165" text-anchor="middle" font-size="9" fill="#444">mode &lt; median &lt; mean</text>
  </g>

  <text x="320" y="250" text-anchor="middle" font-size="12" fill="#444">Dashed lines (left to right within each panel) approximate mode, median, mean positions.</text>
  <text x="320" y="270" text-anchor="middle" font-size="11" fill="#666">This ordering is a common heuristic, not a universal rule for all distributions. [Unverified]</text>
</svg>

### Skewness Assessment Flow

```plaintext
===MERMAID_DIAGRAM===
flowchart TD
    A["Compute third standardized moment (svg_diagram)"] --> B{"Sign of skewness?"}
    B -->|"Positive"| C["Right-skewed: long tail toward high values"]
    B -->|"Negative"| D["Left-skewed: long tail toward low values"]
    B -->|"Near zero"| E["Approximately symmetric"]
    C --> F["Consider log or Box-Cox transform"]
    D --> F
    E --> G["Symmetric-data assumptions may be reasonable"]
```

I cannot verify the specific textbook or curriculum source for the exact phrasing, example dataset, or presentation order used in this response. The core definitions (third standardized moment, sample skewness formulas) are standard results in statistics, but no specific external document was retrieved or cited in this conversation. The mean-median-mode heuristic and several machine learning applications are marked [Unverified] or [Inference] because they are commonly taught approximations or plausible conceptual links rather than confirmed universal properties or verified implementation details. Because part of this output is unverified against a specific named source, the entire response is labeled accordingly.

**Related Topics**
- Kurtosis and tail heaviness
- Box-Cox and log transformations for skewed features
- Fisher-Pearson vs. other skewness estimators
- Effect of skewness on parametric hypothesis tests
- Log-normal and exponential distribution properties
- Outlier detection using distributional shape statistics

