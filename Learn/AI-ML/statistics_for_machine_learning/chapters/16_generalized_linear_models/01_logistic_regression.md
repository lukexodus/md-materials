## Logistic Regression

### Definition

Logistic regression is a statistical method used to model the relationship between one or more independent variables and a binary (or categorical) dependent variable, by estimating the probability that an observation belongs to a particular class.

$$P(Y=1 \mid X) = \frac{1}{1 + e^{-(\beta_0 + \beta_1 X_1 + \cdots + \beta_p X_p)}}$$

**Key Points**
- Unlike linear regression, logistic regression models a probability bounded between 0 and 1, rather than an unbounded continuous outcome. [Inference]
- Logistic regression is a type of Generalized Linear Model (GLM) using the logit link function. [Unverified] I cannot verify this exact categorization matches every statistics textbook's terminology without a cited primary source.

### The Logit Function

The logit (log-odds) transformation is central to logistic regression:

$$\text{logit}(p) = \ln\left(\frac{p}{1-p}\right) = \beta_0 + \beta_1 X_1 + \cdots + \beta_p X_p$$

**Key Points**
- The logit function maps probabilities in $(0,1)$ to the entire real number line $(-\infty, \infty)$. [Inference] This follows algebraically from the properties of the natural logarithm applied to the odds ratio $p/(1-p)$.
- The right-hand side of the logit equation is linear in the parameters, which is why logistic regression is considered a linear model despite modeling a nonlinear probability curve. [Inference]

### Odds and Odds Ratios

$$\text{Odds} = \frac{p}{1-p}$$

For a one-unit increase in $X_j$, the odds ratio is:

$$OR_j = e^{\beta_j}$$

**Key Points**
- An odds ratio greater than 1 indicates increasing odds of $Y=1$ as $X_j$ increases; an odds ratio less than 1 indicates decreasing odds. [Inference] This follows algebraically from the exponential function's properties.
- Odds ratios are commonly used for interpretation because raw logistic regression coefficients ($\beta_j$) are on the log-odds scale, which is less intuitive to communicate. [Inference]
- I cannot verify specific magnitude thresholds (e.g., what counts as a "large" odds ratio) without a cited primary source, as this depends on context.

### The Sigmoid (Logistic) Curve

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380">
  <text x="320" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Logistic (Sigmoid) Function (svg_diagram)</text>

  <line x1="70" y1="320" x2="590" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="330" y1="320" x2="330" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="330" y="345" font-size="13" text-anchor="middle" fill="#333">β0 + β1X</text>
  <text x="30" y="190" font-size="13" text-anchor="middle" fill="#333" transform="rotate(-90 30 190)">P(Y=1)</text>

  <text x="595" y="80" font-size="11" fill="#555">1.0</text>
  <line x1="330" y1="80" x2="590" y2="80" stroke="#ccc" stroke-width="1" stroke-dasharray="3,2" />
  <text x="595" y="323" font-size="11" fill="#555">0.0</text>

  <path d="M100,300 C200,300 280,290 330,190 C380,90 460,80 560,80" fill="none" stroke="#4a86e8" stroke-width="2.5" />

  <circle cx="330" cy="190" r="4" fill="#e69b00" />
  <text x="345" y="185" font-size="11" fill="#e69b00">P = 0.5 at logit = 0</text>

  <line x1="330" y1="80" x2="330" y2="320" stroke="#ccc" stroke-width="1" stroke-dasharray="2,2" />

  <text x="330" y="360" font-size="11" text-anchor="middle" fill="#888">[Inference] Conceptual illustration of the sigmoid function shape</text>
</svg>

### Parameter Estimation — Maximum Likelihood

Unlike linear regression's OLS, logistic regression coefficients are typically estimated via Maximum Likelihood Estimation (MLE), since no closed-form solution generally exists. [Unverified] I cannot verify this claim about closed-form solution non-existence in all cases without a cited primary source.

$$L(\boldsymbol{\beta}) = \prod_{i=1}^n p_i^{y_i} (1-p_i)^{1-y_i}$$

The log-likelihood is typically maximized numerically using iterative optimization methods. [Inference]

**Common Estimation Methods**
- Iteratively Reweighted Least Squares (IRLS) — commonly cited as a standard approach for logistic regression MLE. [Unverified] I cannot verify this is the most widely used method across all software implementations without checking specific documentation.
- Gradient descent / Newton-Raphson — commonly used in machine learning implementations, particularly for large datasets. [Inference]

I cannot verify specific convergence properties or computational efficiency comparisons between these methods without a cited primary source.

### Assumptions of Logistic Regression

1. **Binary or categorical outcome** — the dependent variable is binary (or extended to multinomial/ordinal for more categories).
2. **Independence of observations.**
3. **Linearity in the logit** — the log-odds are assumed to be a linear function of the predictors, not the probability itself.
4. **Little or no multicollinearity** among predictors, as discussed under Multicollinearity.
5. **Large sample size** — commonly cited as important for stable MLE estimates, though I cannot verify specific minimum sample size thresholds without a cited primary source. [Unverified]

[Unverified] This list reflects commonly cited assumptions in logistic regression literature, but exact framing and emphasis vary by source, so I cannot confirm a single canonical version without referencing a specific textbook.

Note: logistic regression does **not** require homoscedasticity or normally distributed errors in the same sense as linear regression, since it models a binomial (or Bernoulli) outcome rather than a continuous one with additive Gaussian error. [Unverified] I cannot verify this precise distinction is presented identically across all statistics sources without a cited primary reference.

### Model Evaluation Metrics

| Metric | Description |
|---|---|
| Accuracy | Proportion of correctly classified observations |
| Confusion matrix | Cross-tabulation of predicted vs. actual classes |
| Precision / Recall | Class-specific correctness and coverage measures |
| ROC curve / AUC | Tradeoff between true positive rate and false positive rate across thresholds |
| Log-loss (deviance) | Penalizes confident incorrect predictions more heavily |
| Pseudo-$R^2$ (e.g., McFadden's) | Analogue to $R^2$ for likelihood-based models |

[Unverified] This table reflects commonly cited evaluation metrics in classification and logistic regression literature, but I cannot verify a single authoritative source confirming this exact list or set of definitions.

### Worked Example (Conceptual)

**Example**

Suppose a logistic regression model predicts whether a student passes an exam ($Y=1$) based on hours studied ($X$), with fitted coefficients $\hat{\beta}_0 = -4$, $\hat{\beta}_1 = 1.5$.

For $X = 3$ hours studied:

$$\text{logit} = -4 + 1.5(3) = 0.5$$

$$P(Y=1) = \frac{1}{1+e^{-0.5}} \approx \frac{1}{1+0.6065} \approx 0.622$$

This is a direct arithmetic computation from the stated hypothetical coefficient values, not derived from a real dataset.

### Logistic Regression Workflow

```mermaid
flowchart TD
    A[Collect data: X predictors, binary Y] --> B[Check linearity in the logit]
    B --> C[Fit model via Maximum Likelihood Estimation]
    C --> D[Obtain coefficients on log-odds scale]
    D --> E[Convert to odds ratios: exp(βj)]
    D --> F[Compute predicted probabilities via sigmoid function]
    F --> G[Choose classification threshold, e.g. 0.5]
    G --> H[Generate confusion matrix]
    H --> I[Evaluate: accuracy, precision, recall, ROC/AUC]
    I --> J{Model performance adequate?}
    J -->|No| K[Consider additional predictors, interactions, or regularization]
    J -->|Yes| L[Proceed with interpretation and deployment]
```

### Logistic Regression vs. Linear Regression

| Aspect | Linear Regression | Logistic Regression |
|---|---|---|
| Outcome type | Continuous | Binary / categorical |
| Link function | Identity | Logit |
| Estimation method | OLS (closed-form) | MLE (iterative) |
| Error distribution assumption | Normal | Binomial / Bernoulli |
| Interpretation of coefficients | Change in $Y$ per unit $X$ | Change in log-odds per unit $X$ |
| Fit measure | $R^2$ | Pseudo-$R^2$, log-loss, AUC |

[Unverified] This comparison table synthesizes commonly cited distinctions in statistics and machine learning literature, but I cannot verify each specific pairing against a single authoritative source.

### Regularized Logistic Regression

Similar to linear regression, logistic regression can be regularized to address overfitting or multicollinearity:

$$\min_{\boldsymbol{\beta}} \left[ -\log L(\boldsymbol{\beta}) + \lambda \sum_{j=1}^p |\beta_j|^k \right]$$

where $k=1$ corresponds to L1 (Lasso-type) regularization and $k=2$ corresponds to L2 (Ridge-type) regularization. [Unverified] I cannot verify this exact generalized formula representation matches every textbook's presentation without a cited primary source.

### Limitations and Considerations

- Logistic regression assumes linearity in the logit; if this does not hold, the model may not fit the data well, and this cannot be assessed without diagnostic checks on actual data. [Inference]
- Separation (where a predictor perfectly predicts the outcome) can cause coefficient estimates to fail to converge or become unstable during MLE. [Unverified] I cannot verify specific software behavior under separation without checking that software's documentation directly.
- Class imbalance in the outcome variable can affect model performance and the interpretability of standard metrics like accuracy. [Inference]
- Odds ratios are often misinterpreted as risk ratios; these are not the same quantity except under specific conditions (e.g., rare outcomes). [Unverified] I cannot verify the precise mathematical conditions under which odds ratios approximate risk ratios without a cited primary source.
- I do not have access to any specific dataset in this conversation; all coefficients, probabilities, and evaluation metrics presented here are either hypothetical or explicitly labeled as such.
- Claims about behavior of any specific statistical software's logistic regression implementation require verification against that software's documentation directly.

**Related Topics**
- Generalized Linear Models — broader framework encompassing logistic regression
- Maximum likelihood estimation — full derivation and properties
- ROC curves and AUC — evaluation metrics in depth
- Multinomial and ordinal logistic regression — extensions beyond binary outcomes
- Regularized regression: Ridge, Lasso, Elastic Net
- Multicollinearity — relevance to logistic regression predictors
- Confusion matrix, precision, recall, and F1 score in depth
- Class imbalance handling techniques
- Odds ratios vs. risk ratios — distinction in depth
- Assumptions of linear regression — contrast with logistic regression assumptions