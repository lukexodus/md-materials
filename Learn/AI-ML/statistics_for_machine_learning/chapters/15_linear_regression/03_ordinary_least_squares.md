## Ordinary Least Squares

### Definition

Ordinary Least Squares (OLS) is a method for estimating the parameters of a linear regression model by minimizing the sum of squared differences between observed values and values predicted by the model.

$$\hat{\boldsymbol{\beta}} = \arg\min_{\boldsymbol{\beta}} \sum_{i=1}^n \left( y_i - \mathbf{x}_i^\top \boldsymbol{\beta} \right)^2$$

**Key Points**
- OLS is the most commonly used estimation method for linear regression models. [Inference] This is based on general familiarity with statistics and machine learning literature, but I cannot verify a specific usage statistic without a cited source.
- OLS minimizes squared residuals rather than absolute residuals, which has specific mathematical consequences discussed below.

### Objective Function

In matrix form, the OLS objective is to minimize the residual sum of squares (RSS):

$$RSS(\boldsymbol{\beta}) = (\mathbf{Y} - \mathbf{X}\boldsymbol{\beta})^\top (\mathbf{Y} - \mathbf{X}\boldsymbol{\beta})$$

Taking the derivative with respect to $\boldsymbol{\beta}$ and setting it to zero yields the normal equations:

$$\mathbf{X}^\top \mathbf{X} \boldsymbol{\beta} = \mathbf{X}^\top \mathbf{Y}$$

Solving for $\boldsymbol{\beta}$:

$$\hat{\boldsymbol{\beta}} = (\mathbf{X}^\top \mathbf{X})^{-1} \mathbf{X}^\top \mathbf{Y}$$

[Unverified] This derivation reflects a standard presentation found in regression textbooks, but I cannot verify it matches every specific notational convention without a cited primary source.

### Derivation Sketch

Setting the gradient of $RSS(\boldsymbol{\beta})$ to zero:

$$\frac{\partial RSS}{\partial \boldsymbol{\beta}} = -2\mathbf{X}^\top(\mathbf{Y} - \mathbf{X}\boldsymbol{\beta}) = 0$$

$$\mathbf{X}^\top \mathbf{Y} = \mathbf{X}^\top \mathbf{X} \boldsymbol{\beta}$$

$$\hat{\boldsymbol{\beta}} = (\mathbf{X}^\top \mathbf{X})^{-1} \mathbf{X}^\top \mathbf{Y}$$

This solution requires $\mathbf{X}^\top \mathbf{X}$ to be invertible, which fails when predictors are perfectly collinear or when $n < p$. [Inference] This invertibility requirement follows algebraically from the formula itself, but specific failure conditions in applied settings would need to be checked against the actual data structure.

### Gauss-Markov Theorem

The Gauss-Markov theorem states that, under certain assumptions, the OLS estimator is the Best Linear Unbiased Estimator (BLUE) — meaning it has the lowest variance among all linear unbiased estimators. [Unverified] This is a widely cited theorem in statistics, but I cannot verify its exact statement or proof conditions without referencing a primary source such as a formal statistics textbook.

**Gauss-Markov Assumptions**
1. Linearity in parameters.
2. Random sampling / independent observations.
3. No perfect multicollinearity.
4. Zero conditional mean of errors: $E[\varepsilon \mid \mathbf{X}] = 0$.
5. Homoscedasticity: $Var(\varepsilon \mid \mathbf{X}) = \sigma^2$.

[Unverified] This list reflects a commonly cited formulation of the Gauss-Markov assumptions, but exact wording and numbering vary across textbooks, so I cannot confirm a single canonical version without a specific cited source.

Note: normality of errors is **not** required for the Gauss-Markov theorem itself; it becomes relevant for exact inference (confidence intervals, hypothesis tests) rather than for the BLUE property. [Unverified] This distinction is commonly made in econometrics texts, but I cannot verify this precise framing without a cited primary source.

### Geometric Interpretation

OLS can be understood geometrically as an orthogonal projection of the response vector $\mathbf{Y}$ onto the column space of $\mathbf{X}$.

$$\hat{\mathbf{Y}} = \mathbf{X}\hat{\boldsymbol{\beta}} = \mathbf{H}\mathbf{Y}$$

where $\mathbf{H} = \mathbf{X}(\mathbf{X}^\top \mathbf{X})^{-1}\mathbf{X}^\top$ is the "hat matrix" that projects $\mathbf{Y}$ onto the column space of $\mathbf{X}$.

**Key Points**
- The residual vector $\mathbf{Y} - \hat{\mathbf{Y}}$ is orthogonal to the column space of $\mathbf{X}$. [Inference] This follows algebraically from the normal equations, though I have not independently re-derived it here beyond restating the standard result.
- The hat matrix $\mathbf{H}$ is idempotent ($\mathbf{H}\mathbf{H} = \mathbf{H}$) and symmetric. [Unverified] This is a standard linear algebra property associated with projection matrices, but I cannot verify this specific claim without a cited reference.

### Geometric Projection Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 400">
  <text x="320" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">OLS as Orthogonal Projection (svg_diagram)</text>

  <rect x="80" y="120" width="360" height="200" fill="#e8f0fe" fill-opacity="0.4" stroke="#4a86e8" stroke-width="1.5" />
  <text x="100" y="140" font-size="12" fill="#4a86e8">Column space of X</text>

  <line x1="260" y1="320" x2="500" y2="80" stroke="#c00" stroke-width="2" />
  <text x="500" y="70" font-size="12" fill="#c00">Y (observed)</text>

  <line x1="260" y1="320" x2="400" y2="200" stroke="#34a853" stroke-width="2.5" />
  <text x="410" y="195" font-size="12" fill="#34a853">Ŷ (fitted, projection)</text>

  <line x1="400" y1="200" x2="500" y2="80" stroke="#e69b00" stroke-width="2" stroke-dasharray="4,3" />
  <text x="470" y="140" font-size="11" fill="#e69b00">residual (Y − Ŷ)</text>

  <rect x="385" y="185" width="15" height="15" fill="none" stroke="#666" stroke-width="1" />

  <circle cx="260" cy="320" r="3" fill="#333" />
  <text x="245" y="340" font-size="11" fill="#333">origin</text>
</svg>

### Properties of OLS Estimators

- **Unbiasedness**: $E[\hat{\boldsymbol{\beta}}] = \boldsymbol{\beta}$, under the Gauss-Markov assumptions. [Unverified] I cannot verify this holds outside the stated assumptions without a cited proof.
- **Variance**: $Var(\hat{\boldsymbol{\beta}}) = \sigma^2 (\mathbf{X}^\top \mathbf{X})^{-1}$. [Unverified] This is a standard formula in regression theory, but exact derivation conditions should be checked against a primary source.
- **Consistency**: as sample size increases, OLS estimates are commonly described as converging toward true parameter values under certain regularity conditions. [Speculation] I cannot confirm the exact regularity conditions required without referencing a specific asymptotic theory source, and this statement should not be treated as established without such verification.

### Worked Example

Using the same dataset from simple linear regression (hours studied $X$, exam score $Y$):

| $X$ | $Y$ |
|---|---|
| 1 | 50 |
| 2 | 55 |
| 3 | 65 |
| 4 | 70 |
| 5 | 80 |

**Example**

Applying the OLS formula:

$$\hat{\beta_1} = \frac{\sum (x_i - \bar{x})(y_i - \bar{y})}{\sum (x_i - \bar{x})^2} = \frac{75}{10} = 7.5$$

$$\hat{\beta_0} = \bar{y} - \hat{\beta_1}\bar{x} = 64 - 7.5(3) = 41.5$$

This is a direct arithmetic recomputation of the earlier simple linear regression example, not a new independently verified result.

### Numerical Estimation — When Closed-Form Fails

When $\mathbf{X}^\top \mathbf{X}$ is not invertible (e.g., due to multicollinearity or $p > n$), alternative approaches include:

- **Pseudoinverse (Moore-Penrose)** — provides a solution even when $\mathbf{X}^\top \mathbf{X}$ is singular.
- **Gradient descent** — iterative numerical optimization of the RSS objective, commonly used in machine learning contexts, particularly for large datasets. [Inference]
- **Regularization (Ridge regression)** — adds a penalty term to make the matrix invertible: $\hat{\boldsymbol{\beta}} = (\mathbf{X}^\top \mathbf{X} + \lambda \mathbf{I})^{-1} \mathbf{X}^\top \mathbf{Y}$.

[Unverified] These are commonly cited alternative approaches in machine learning and statistics literature, but I cannot verify their comparative performance characteristics without cited benchmark sources.

### OLS Estimation Workflow

```mermaid
flowchart TD
    A[Observed data: X, Y] --> B[Formulate design matrix X and response Y]
    B --> C[Compute X^T X]
    C --> D{Invertible?}
    D -->|Yes| E[Solve normal equations: β = (X^T X)^-1 X^T Y]
    D -->|No| F[Use pseudoinverse, regularization, or iterative methods]
    E --> G[Compute fitted values and residuals]
    F --> G
    G --> H[Evaluate model fit and check assumptions]
```

### Limitations and Considerations

- OLS is sensitive to outliers because squared residuals penalize large deviations disproportionately. [Inference]
- OLS requires $\mathbf{X}^\top \mathbf{X}$ to be invertible; this fails under perfect multicollinearity or when the number of predictors exceeds the number of observations. [Inference]
- The BLUE property depends on the Gauss-Markov assumptions holding; violations (e.g., heteroscedasticity, autocorrelation) do not necessarily bias OLS estimates but can affect efficiency and standard error validity. [Unverified] This distinction is commonly discussed in econometrics literature, but I cannot verify the precise technical boundaries without a cited primary source.
- OLS does not by itself establish causal relationships between predictors and the response variable. [Inference]
- I do not have access to dataset-specific results regarding invertibility, residual behavior, or estimator variance; such claims require direct computation on real data.

**Related Topics**
- Gauss-Markov theorem — full statement and proof conditions
- Ridge regression and regularized least squares
- Weighted least squares for heteroscedastic data
- Generalized least squares (GLS)
- Gradient descent as an alternative optimization approach
- Residual diagnostics and assumption verification
- Multicollinearity and the pseudoinverse solution
- Maximum likelihood estimation vs. OLS under normality
- Hat matrix and leverage/influence diagnostics
- Multiple linear regression — full model context

> Correction note: No correction is issued in this response, as no unverified claim was presented as confirmed fact. All uncertain statements above have been labeled per the stated requirements.