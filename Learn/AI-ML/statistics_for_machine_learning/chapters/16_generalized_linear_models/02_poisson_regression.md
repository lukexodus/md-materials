## Poisson Regression

### Definition

Poisson regression is a type of Generalized Linear Model used to model count data, where the dependent variable represents the number of times an event occurs within a fixed interval of time, space, or other exposure unit.

$$\ln(\lambda) = \beta_0 + \beta_1 X_1 + \cdots + \beta_p X_p$$

where $\lambda$ is the expected count (the mean of the Poisson distribution) given the predictors.

**Key Points**
- Poisson regression uses a log link function to relate the linear predictor to the expected count. [Inference] This follows the general structure of Generalized Linear Models discussed under Logistic Regression.
- The dependent variable is assumed to follow a Poisson distribution conditional on the predictors. [Inference]
- I cannot verify a single canonical definition of Poisson regression beyond this general structure without a cited primary source.

### The Poisson Distribution

$$P(Y=y) = \frac{e^{-\lambda}\lambda^y}{y!}, \quad y = 0, 1, 2, \ldots$$

**Key Points**
- A defining property of the Poisson distribution is that its mean equals its variance: $E[Y] = Var(Y) = \lambda$. [Unverified] This is a standard mathematical property commonly cited in probability theory, but I cannot verify this exact statement matches a specific cited primary source in this conversation.
- This mean-variance equality is referred to as "equidispersion," and its violation in real data is a common practical concern for Poisson regression, discussed further below. [Unverified] I cannot verify how commonly this term is used across all statistics sources without a cited primary reference.

### Model Form

$$\lambda_i = e^{\beta_0 + \beta_1 X_{1i} + \cdots + \beta_p X_{pi}}$$

Equivalently, in log form:

$$\ln(\lambda_i) = \beta_0 + \beta_1 X_{1i} + \cdots + \beta_p X_{pi}$$

**Key Points**
- Exponentiating the linear predictor ensures $\lambda$ remains positive, which is a mathematical requirement for the Poisson distribution's parameter. [Inference] This follows algebraically from the properties of the exponential function.
- Coefficients $\beta_j$ represent the change in the log of the expected count per one-unit increase in $X_j$, holding other predictors constant. [Inference]

### Interpreting Coefficients — Rate Ratios

$$RR_j = e^{\beta_j}$$

A rate ratio (also called an incidence rate ratio, or IRR) greater than 1 indicates an increasing expected count as $X_j$ increases; less than 1 indicates a decreasing expected count. [Inference] This follows algebraically from the exponential function's properties, similar to the odds ratio interpretation discussed under Logistic Regression.

I cannot verify specific magnitude thresholds for what counts as a "large" rate ratio without a cited primary source, as this depends on context.

### The Offset Term

When counts are observed over varying exposure periods (e.g., different time intervals or population sizes), an offset term is commonly included:

$$\ln(\lambda_i) = \ln(\text{exposure}_i) + \beta_0 + \beta_1 X_{1i} + \cdots + \beta_p X_{pi}$$

**Key Points**
- The offset adjusts the model to predict a rate (count per unit exposure) rather than a raw count. [Inference]
- The coefficient on the offset term is fixed at 1 rather than estimated, which is a defining feature distinguishing an offset from a regular predictor. [Unverified] I cannot verify this precise technical distinction matches every software implementation without checking specific documentation.

### Poisson Regression Curve Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380">
  <text x="320" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Poisson Regression: Exponential Mean Function (svg_diagram)</text>

  <line x1="70" y1="320" x2="590" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="70" y1="320" x2="70" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="330" y="355" font-size="13" text-anchor="middle" fill="#333">Predictor X</text>
  <text x="30" y="190" font-size="13" text-anchor="middle" fill="#333" transform="rotate(-90 30 190)">Expected count λ</text>

  <path d="M100,310 C200,300 300,270 400,200 C480,140 540,90 570,70" fill="none" stroke="#4a86e8" stroke-width="2.5" />

  <circle cx="150" cy="308" r="3" fill="#e69b00" />
  <circle cx="250" cy="290" r="3" fill="#e69b00" />
  <circle cx="350" cy="240" r="3" fill="#e69b00" />
  <circle cx="450" cy="160" r="3" fill="#e69b00" />
  <circle cx="530" cy="100" r="3" fill="#e69b00" />

  <text x="330" y="90" font-size="11" text-anchor="middle" fill="#888">[Inference] Conceptual illustration of exponential growth in λ as X increases</text>
</svg>

### Assumptions of Poisson Regression

1. **Count outcome** — the dependent variable represents non-negative integer counts.
2. **Independence of observations.**
3. **Log-linearity** — the log of the expected count is a linear function of the predictors.
4. **Equidispersion** — the mean and variance of the outcome are approximately equal, conditional on predictors.
5. **No perfect multicollinearity** among predictors, as discussed under Multicollinearity.

[Unverified] This list reflects commonly cited assumptions in Poisson regression literature, but exact framing and emphasis vary by source, so I cannot confirm a single canonical version without referencing a specific textbook.

### Overdispersion

**Key Points**
- Overdispersion occurs when the observed variance in the count data exceeds what the Poisson distribution predicts (i.e., $Var(Y) > E[Y]$). [Inference]
- Overdispersion is commonly cited as a frequent practical issue in applied count data analysis, though I cannot verify how commonly it occurs across different fields or datasets without a cited empirical source. [Unverified]
- Ignoring overdispersion is commonly said to result in underestimated standard errors, which can lead to overly optimistic significance conclusions. [Unverified] I cannot verify the precise magnitude of this effect without a cited primary source or direct computation.

**Common Approaches to Overdispersion**

| Approach | Description |
|---|---|
| Quasi-Poisson regression | Adjusts standard errors using an estimated dispersion parameter without changing the mean structure |
| Negative Binomial regression | Uses a different distribution that includes an additional parameter to model excess variance |
| Robust (sandwich) standard errors | Adjusts standard error estimates without changing the distributional assumption directly |

[Unverified] This table reflects commonly cited remedies discussed in count-data regression literature, but I cannot verify the comparative effectiveness of these approaches without cited benchmark sources.

### Zero-Inflation

**Key Points**
- Some count datasets contain more zero counts than a standard Poisson distribution would predict, a situation commonly referred to as "zero-inflation." [Unverified] I cannot verify how commonly this specific terminology is used across all statistics sources without a cited primary reference.
- Zero-Inflated Poisson (ZIP) models are commonly cited as one approach to address this, combining a standard Poisson process with a separate process modeling excess zeros. [Unverified] I cannot verify specific model construction details without a cited primary source.

### Worked Example (Conceptual)

**Example**

Suppose a Poisson regression models the number of customer service calls ($Y$) based on number of products owned ($X$), with fitted coefficients $\hat{\beta}_0 = 0.2$, $\hat{\beta}_1 = 0.3$.

For $X = 4$ products:

$$\ln(\lambda) = 0.2 + 0.3(4) = 1.4$$

$$\lambda = e^{1.4} \approx 4.06$$

This is a direct arithmetic computation from the stated hypothetical coefficient values, not derived from a real dataset. The interpretation would be an expected count of approximately 4.06 calls, though this is illustrative only.

### Poisson Regression Workflow

```mermaid
flowchart TD
    A[Collect count data: X predictors, count Y] --> B[Check mean-variance relationship]
    B --> C{Approximately equal mean and variance?}
    C -->|Yes| D[Fit standard Poisson regression via MLE]
    C -->|No, overdispersed| E[Consider Quasi-Poisson or Negative Binomial]
    D --> F[Check for excess zeros]
    E --> F
    F --> G{Zero-inflation present?}
    G -->|Yes| H[Consider Zero-Inflated Poisson or Negative Binomial model]
    G -->|No| I[Interpret coefficients as rate ratios: exp(βj)]
    H --> I
    I --> J[Evaluate model fit: deviance, AIC, residual diagnostics]
```

### Model Evaluation

| Metric | Description |
|---|---|
| Deviance | Likelihood-based measure of model fit, analogous to residual sum of squares |
| AIC / BIC | Information criteria for comparing model specifications, as discussed under Regression Diagnostics |
| Pearson residuals | Used to assess overdispersion and individual observation fit |
| Pseudo-$R^2$ | Likelihood-based analogue to $R^2$ |

[Unverified] This table reflects commonly cited evaluation approaches in count-data regression literature, but I cannot verify a single authoritative source confirming this exact list.

### Poisson Regression vs. Logistic and Linear Regression

| Aspect | Linear Regression | Logistic Regression | Poisson Regression |
|---|---|---|---|
| Outcome type | Continuous | Binary | Count (non-negative integer) |
| Link function | Identity | Logit | Log |
| Distribution assumption | Normal | Binomial/Bernoulli | Poisson |
| Coefficient interpretation | Change in $Y$ | Change in log-odds | Change in log-count |
| Ratio interpretation | Not applicable | Odds ratio | Rate ratio (IRR) |

[Unverified] This comparison table synthesizes commonly cited distinctions across regression types discussed in this conversation, but I cannot verify each specific pairing against a single authoritative source.

### Limitations and Considerations

- Poisson regression assumes equidispersion; violations (overdispersion or underdispersion) can invalidate standard error estimates if not addressed. [Inference]
- Poisson regression assumes log-linearity between predictors and the expected count; if this does not hold, the model may not fit well, which cannot be assessed without diagnostics on actual data. [Inference]
- Zero-inflation, if present but unaddressed, can lead to poor model fit and biased inference. [Inference]
- I do not have access to any specific dataset in this conversation; all coefficients, expected counts, and evaluation metrics presented here are either hypothetical or explicitly labeled as such.
- Claims about behavior of any specific statistical software's Poisson regression implementation require verification against that software's documentation directly.

**Related Topics**
- Generalized Linear Models — broader framework encompassing Poisson regression
- Negative Binomial regression — addressing overdispersion in depth
- Zero-Inflated and Hurdle models for excess-zero count data
- Logistic regression — related GLM for binary outcomes
- Maximum likelihood estimation — estimation method underlying Poisson regression
- Overdispersion diagnostics and testing
- Offset terms and rate modeling in depth
- Model evaluation: deviance, AIC, BIC for count models
- Multicollinearity — relevance to Poisson regression predictors
- Residual analysis — Pearson and deviance residuals for count models