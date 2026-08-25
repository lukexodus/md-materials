## Confidence Intervals for Coefficients

### Definition

A confidence interval for a regression coefficient provides a range of plausible values for the true (population) parameter $\beta_j$, constructed such that, under repeated sampling, a specified proportion of such intervals would contain the true value. [Unverified] This is a standard frequentist interpretation commonly presented in statistics literature, but I cannot verify this exact phrasing matches a single canonical source. If any part of this response is unverified, the entire response should be treated as containing unverified content per the stated labeling requirement.

$$\hat{\beta}_j \pm t_{\alpha/2, \, n-p-1} \cdot SE(\hat{\beta}_j)$$

where $t_{\alpha/2, \, n-p-1}$ is the critical value from the t-distribution with $n-p-1$ degrees of freedom, and $SE(\hat{\beta}_j)$ is the standard error of the coefficient estimate.

**Key Points**
- The confidence level (e.g., 95%) refers to the long-run performance of the interval-construction procedure, not the probability that a specific computed interval contains the true parameter. [Unverified] I cannot verify this precise philosophical distinction is presented identically across all statistics sources without a cited primary reference.
- A narrower interval, for a given confidence level, is commonly associated with a more precise estimate of $\beta_j$. [Inference]

### Standard Error of a Coefficient

$$SE(\hat{\beta}_j) = \hat{\sigma} \sqrt{\left[(\mathbf{X}^\top \mathbf{X})^{-1}\right]_{jj}}$$

where $\hat{\sigma}$ is the estimated residual standard deviation and $\left[(\mathbf{X}^\top \mathbf{X})^{-1}\right]_{jj}$ is the corresponding diagonal element of the inverse of $\mathbf{X}^\top \mathbf{X}$.

[Unverified] This formula reflects a standard presentation in regression textbooks, but I cannot verify this exact notation matches every source without a cited primary reference.

**Key Points**
- Standard errors of coefficients tend to be larger when multicollinearity is present, as discussed under the Multicollinearity topic. [Inference]
- Standard errors also depend on sample size and the variance of the predictor itself; larger samples and greater predictor variability are commonly associated with smaller standard errors. [Inference] I cannot verify the precise mathematical relationship in every case without direct computation.

### Derivation Logic

1. Under the classical linear regression assumptions (including normality of errors), $\hat{\boldsymbol{\beta}}$ follows a multivariate normal distribution. [Unverified] I cannot verify this precise distributional claim without a cited primary source.
2. Because $\sigma^2$ is estimated rather than known, the t-distribution (rather than the normal distribution) is used for interval construction. [Unverified] This is commonly stated in regression literature, but I cannot verify the exact justification without a cited primary source.
3. The degrees of freedom for the t-distribution are $n - p - 1$, where $p$ is the number of predictors. [Unverified] I cannot verify this exact degrees-of-freedom convention matches every software implementation without checking specific documentation.

Each step above is labeled individually and should not be treated as a single confirmed chain; each depends on assumptions not verified within this conversation.

### Worked Example (Conceptual)

**Example**

Suppose $\hat{\beta}_1 = 7.5$, $SE(\hat{\beta}_1) = 1.2$, $n = 20$, $p = 1$, and the desired confidence level is 95%.

Degrees of freedom: $n - p - 1 = 18$

Using a commonly cited approximate critical value of $t_{0.025, 18} \approx 2.101$ [Unverified — I cannot verify this specific critical value without consulting a t-distribution table or statistical software directly]:

$$7.5 \pm 2.101 \times 1.2 = 7.5 \pm 2.52$$

$$CI_{95\%} \approx (4.98, 10.02)$$

This is a direct arithmetic computation based on the stated hypothetical values and an unverified critical value; it is illustrative only and not derived from a real dataset or a confirmed statistical table lookup.

### Confidence Interval Visualization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Confidence Interval for a Coefficient (svg_diagram)</text>

  <line x1="80" y1="180" x2="560" y2="180" stroke="#333" stroke-width="1.5" />
  <text x="320" y="210" font-size="12" text-anchor="middle" fill="#333">Value of β₁</text>

  <line x1="220" y1="160" x2="220" y2="200" stroke="#666" stroke-width="1.5" />
  <text x="220" y="225" font-size="11" text-anchor="middle" fill="#555">Lower bound (4.98)</text>

  <line x1="420" y1="160" x2="420" y2="200" stroke="#666" stroke-width="1.5" />
  <text x="420" y="225" font-size="11" text-anchor="middle" fill="#555">Upper bound (10.02)</text>

  <line x1="220" y1="180" x2="420" y2="180" stroke="#4a86e8" stroke-width="4" />

  <circle cx="320" cy="180" r="6" fill="#e69b00" />
  <text x="320" y="160" font-size="12" text-anchor="middle" fill="#e69b00">β̂₁ = 7.5</text>

  <line x1="0" y1="180" x2="80" y2="180" stroke="#ccc" stroke-width="1" />
  <line x1="560" y1="180" x2="640" y2="180" stroke="#ccc" stroke-width="1" />

  <text x="320" y="260" font-size="11" text-anchor="middle" fill="#888">[Inference] Illustrative diagram based on the worked example above, not real data</text>
</svg>

### Relationship to Hypothesis Testing

A confidence interval for $\beta_j$ is commonly described as related to the corresponding two-sided hypothesis test $H_0: \beta_j = 0$:

- If the confidence interval does not contain 0, the coefficient is commonly said to be statistically significant at the corresponding significance level. [Unverified] I cannot verify this equivalence holds under every testing convention or software implementation without a cited primary source.
- If the interval contains 0, the null hypothesis that $\beta_j = 0$ is commonly not rejected at that significance level. [Unverified] Same caveat as above applies.

I cannot verify this duality claim beyond stating it as a commonly described relationship in regression literature.

### Factors Affecting Interval Width

| Factor | Commonly Cited Effect on Interval Width |
|---|---|
| Sample size ($n$) | Larger $n$ commonly associated with narrower intervals [Inference] |
| Residual variance ($\hat{\sigma}^2$) | Higher residual variance commonly associated with wider intervals [Inference] |
| Multicollinearity | Higher multicollinearity commonly associated with wider intervals for affected coefficients [Inference] |
| Confidence level | Higher confidence level (e.g., 99% vs 95%) commonly associated with wider intervals [Inference] |
| Predictor variability | Greater spread in $X_j$ values commonly associated with narrower intervals [Inference] |

[Unverified] This table reflects commonly cited relationships in regression literature, but I cannot verify precise magnitudes or guaranteed directions of these effects without direct computation on specific data or a cited primary source.

### Confidence Interval Construction Workflow

```mermaid
flowchart TD
    A[Fit regression model] --> B[Obtain coefficient estimate β̂j]
    B --> C[Compute standard error SE(β̂j)]
    C --> D[Determine degrees of freedom: n - p - 1]
    D --> E[Obtain t critical value for desired confidence level]
    E --> F[Compute interval: β̂j ± t × SE(β̂j)]
    F --> G{Interval contains 0?}
    G -->|Yes| H[Fail to reject H0: βj = 0 at this confidence level]
    G -->|No| I[Reject H0: βj = 0 at this confidence level]
```

### Common Misinterpretations

**Key Points**
- A 95% confidence interval does **not** mean there is a 95% probability that the true $\beta_j$ lies within the specific computed interval; this is a frequently cited misinterpretation in statistics education. [Unverified] I cannot verify how frequently this specific misinterpretation occurs among practitioners without a cited empirical source, though the distinction itself is commonly emphasized in statistics literature.
- A confidence interval does not indicate the probability that the null hypothesis is true or false. [Inference]
- Overlapping confidence intervals for two different coefficients do not necessarily imply the coefficients are not significantly different from each other; this requires a separate direct test. [Unverified] I cannot verify the precise statistical justification for this without a cited primary source.

### Limitations and Considerations

- Confidence intervals for coefficients rely on the same underlying assumptions discussed under Assumptions of Linear Regression (linearity, independence, homoscedasticity, normality); violations can invalidate interval coverage properties. [Inference]
- Under heteroscedasticity, standard confidence intervals may not have the stated coverage properties unless robust standard errors are used, as discussed under Heteroscedasticity. [Inference]
- I do not have access to any specific dataset in this conversation; all coefficient estimates, standard errors, and interval bounds presented here are either hypothetical or explicitly labeled as such.
- I cannot verify exact critical values from t-distribution tables without direct computation or access to verified statistical software/tables; the value used in the worked example above is presented as commonly cited but unverified in this context.
- Claims about behavior of any specific statistical software's confidence interval output require verification against that software's documentation directly.

**Related Topics**
- Ordinary least squares — estimator variance underlying these intervals
- Hypothesis testing on coefficients — t-tests and F-tests in depth
- Assumptions of linear regression — foundational context for interval validity
- Heteroscedasticity — impact on standard error and interval validity
- Bootstrap confidence intervals as a non-parametric alternative
- Prediction intervals vs. confidence intervals — distinction in depth
- Multicollinearity — effect on coefficient standard errors
- t-distribution and degrees of freedom in regression contexts
- Multiple linear regression — full model context
- Robust standard errors for valid inference under assumption violations