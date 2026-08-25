## Partial Correlation

### Overview

Partial correlation measures the linear relationship between two variables while statistically controlling for the effect of one or more additional variables. It addresses a key limitation of simple (bivariate) correlation: an observed association between two variables can sometimes be fully or partly explained by their mutual relationship with a third variable. Partial correlation isolates the direct association by removing the influence of these confounding or mediating variables.

### Motivation: The Confounding Problem

**Key Points**
- A simple Pearson correlation between $X$ and $Y$ can be inflated, deflated, or even reversed in sign if both variables are related to a third variable $Z$.
- This phenomenon is related to **spurious correlation**, where an apparent association between two variables arises indirectly through their shared relationship with a confounding variable, rather than reflecting a direct relationship. [Inference]
- Partial correlation addresses this by mathematically removing the linear influence of the controlling variable(s) before assessing the remaining association.

### Definition (Single Control Variable)

The partial correlation between $X$ and $Y$, controlling for a third variable $Z$, denoted $r_{XY \cdot Z}$, is computed from the pairwise Pearson correlations:

$$r_{XY \cdot Z} = \frac{r_{XY} - r_{XZ}\,r_{YZ}}{\sqrt{(1 - r_{XZ}^2)(1 - r_{YZ}^2)}}$$

where $r_{XY}$, $r_{XZ}$, and $r_{YZ}$ are the ordinary Pearson correlations between each pair of variables.

**Key Points**
- Like ordinary Pearson correlation, $r_{XY \cdot Z}$ ranges from $-1$ to $1$.
- The formula effectively removes from both $X$ and $Y$ the portion of their variation that is linearly predictable from $Z$, then correlates the remaining residuals.
- If $Z$ has no linear relationship with either $X$ or $Y$ (i.e., $r_{XZ} = r_{YZ} = 0$), the partial correlation reduces exactly to the ordinary correlation $r_{XY}$.

### Diagram: Removing the Effect of a Confounding Variable

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 300" font-family="Arial, sans-serif">
  <text x="350" y="26" font-size="18" font-weight="bold" text-anchor="middle" fill="#222">Partial Correlation Concept (svg_diagram)</text>

  <circle cx="170" cy="150" r="45" fill="#e8f0fe" stroke="#4a76d4" stroke-width="2" />
  <text x="170" y="155" font-size="14" text-anchor="middle" fill="#222">X</text>

  <circle cx="530" cy="150" r="45" fill="#e8f0fe" stroke="#4a76d4" stroke-width="2" />
  <text x="530" y="155" font-size="14" text-anchor="middle" fill="#222">Y</text>

  <circle cx="350" cy="70" r="45" fill="#fef3e0" stroke="#d4914a" stroke-width="2" />
  <text x="350" y="75" font-size="14" text-anchor="middle" fill="#222">Z</text>

  <line x1="210" y1="140" x2="490" y2="140" stroke="#d4494a" stroke-width="2" stroke-dasharray="6,3" />
  <text x="350" y="130" font-size="12" text-anchor="middle" fill="#d4494a">Raw correlation r_XY</text>

  <line x1="200" y1="120" x2="310" y2="90" stroke="#d4914a" stroke-width="2" />
  <line x1="390" y1="90" x2="500" y2="120" stroke="#d4914a" stroke-width="2" />

  <line x1="180" y1="195" x2="520" y2="195" stroke="#3a8a4a" stroke-width="2.5" />
  <text x="350" y="215" font-size="12" text-anchor="middle" fill="#3a8a4a">Partial correlation r_XY.Z (Z's influence removed)</text>
</svg>

### Regression-Based Interpretation

Partial correlation can equivalently be understood through residuals from linear regression:

1. Regress $X$ on $Z$, obtaining residuals $e_X = X - \hat{X}(Z)$.
2. Regress $Y$ on $Z$, obtaining residuals $e_Y = Y - \hat{Y}(Z)$.
3. Compute the ordinary Pearson correlation between $e_X$ and $e_Y$: this equals $r_{XY \cdot Z}$.

**Key Points**
- This regression-residual interpretation clarifies exactly what partial correlation measures: the correlation between the parts of $X$ and $Y$ that remain **after** removing whatever can be linearly explained by $Z$.
- This approach naturally generalizes to controlling for multiple variables simultaneously, by regressing $X$ and $Y$ on the full set of control variables before correlating the residuals.

### Worked Example

Suppose the pairwise Pearson correlations among three variables are:

$$r_{XY} = 0.6, \qquad r_{XZ} = 0.7, \qquad r_{YZ} = 0.65$$

**Applying the formula:**

$$r_{XY \cdot Z} = \frac{0.6 - (0.7)(0.65)}{\sqrt{(1 - 0.7^2)(1 - 0.65^2)}} = \frac{0.6 - 0.455}{\sqrt{(0.51)(0.5775)}}$$

$$= \frac{0.145}{\sqrt{0.2945}} = \frac{0.145}{0.5427} \approx 0.267$$

**Interpretation:** The raw correlation between $X$ and $Y$ (0.6) drops substantially to approximately 0.27 once the shared association with $Z$ is accounted for. This suggests a meaningful portion of the original $X$-$Y$ association may be attributable to their mutual relationship with $Z$, rather than a direct relationship between $X$ and $Y$ themselves. [Inference]

### Partial Correlation with Multiple Control Variables

When controlling for several variables simultaneously, partial correlation is more generally computed using the **precision matrix** (inverse of the correlation or covariance matrix). For variables with correlation matrix $R$ and precision matrix $P = R^{-1}$:

$$r_{ij \cdot \text{rest}} = \frac{-P_{ij}}{\sqrt{P_{ii}P_{jj}}}$$

**Key Points**
- This formula gives the partial correlation between variables $i$ and $j$, controlling for **all other variables** in the dataset simultaneously.
- This connects directly to Gaussian graphical models, where a zero entry in the precision matrix corresponds to a zero partial correlation, implying conditional independence between the two variables given all others (under a multivariate normal assumption). [Inference]
- Computing partial correlations this way requires the covariance or correlation matrix to be invertible, which relates directly to the positive definiteness requirements discussed for covariance matrices generally.

### Semi-Partial (Part) Correlation

A related but distinct concept, the **semi-partial correlation** (or part correlation), removes the influence of $Z$ from only one of the two variables (commonly the predictor), rather than from both:

$$r_{Y(X \cdot Z)} = \frac{r_{XY} - r_{XZ}\,r_{YZ}}{\sqrt{1 - r_{XZ}^2}}$$

**Key Points**
- Semi-partial correlation is often used in regression contexts to assess the unique contribution of a specific predictor to the variance in $Y$, after accounting for shared variance with other predictors.
- It differs from partial correlation in that only the denominator's adjustment is applied to one variable, making semi-partial correlations generally smaller in magnitude than the corresponding partial correlation. [Inference]
- This distinction matters for interpreting squared semi-partial correlations as unique variance explained (as used in some hierarchical regression analyses). [Inference]

### Key Properties and Assumptions

**Key Points**
- **Assumes linearity:** Like Pearson correlation, partial correlation captures only linear relationships among the variables, including the relationships used to remove the confounding variable's effect.
- **Sensitive to omitted variables:** Partial correlation only controls for the variables explicitly included in the calculation; unmeasured confounders can still bias the resulting estimate. [Inference]
- **Not evidence of direct causation:** A nonzero partial correlation after controlling for relevant variables indicates a direct linear association, but this does not by itself establish a causal relationship between $X$ and $Y$. [Inference]
- **Assumes correctly specified control variables:** Controlling for a variable that is actually a consequence of both $X$ and $Y$ (a "collider") rather than a common cause can introduce, rather than remove, spurious association. [Inference]

### Relevance to Machine Learning

**Key Points**
- **Feature relationship analysis:** Partial correlation helps distinguish direct associations between features (or between a feature and a target) from associations that are mediated or confounded by other features.
- **Graphical models:** Partial correlations directly parameterize Gaussian graphical models, where the pattern of nonzero partial correlations defines the structure of conditional dependencies among variables.
- **Feature selection and redundancy:** Understanding partial correlations can help identify which features provide unique predictive information versus which are largely redundant given other included features. [Inference]
- **Causal inference groundwork:** While not sufficient on its own to establish causation, partial correlation analysis is often an early step in exploring potential causal structures, complementing more formal causal inference methods. [Inference]
- **Network and graphical lasso methods:** Sparse estimation of the precision matrix (e.g., via graphical lasso) is used to infer parsimonious partial correlation networks in high-dimensional settings, such as gene expression or financial data analysis. [Inference]

### Conceptual Flow

```mermaid
flowchart TD
    A[Variables X, Y, and control variable(s) Z] --> B[Regress X on Z, obtain residuals]
    A --> C[Regress Y on Z, obtain residuals]
    B --> D[Correlate residuals of X and Y]
    C --> D
    D --> E[Partial correlation r_XY.Z]
    E --> F{Compare to raw correlation r_XY}
    F -- Substantially reduced --> G[Suggests confounding by Z]
    F -- Similar magnitude --> H[Suggests direct association, less confounded by Z]
```

### Advantages and Limitations

**Key Points**
- **Advantages:**
  - Helps disentangle direct associations from those explained by shared relationships with other variables.
  - Extends naturally to controlling for multiple variables simultaneously via the precision matrix.
  - Provides a foundation for graphical models representing conditional independence structure among many variables.
- **Limitations:**
  - Only removes **linear** influence of the control variable(s); nonlinear confounding relationships may not be fully addressed. [Inference]
  - Requires correctly identifying and including relevant control variables; omitted confounders remain a source of bias. [Inference]
  - Computing partial correlations with many control variables requires an invertible covariance or correlation matrix, which can be problematic in high-dimensional or small-sample settings. [Inference]
  - Interpretation can be misleading if a control variable is actually a mediator (on the causal pathway between $X$ and $Y$) rather than a common cause, since controlling for a mediator can remove genuine indirect effects. [Inference]

### Practical Considerations

- Before interpreting a partial correlation, it is useful to consider the plausible causal role of the control variable — whether it is a likely confounder, mediator, or collider — since this affects whether "controlling for it" is appropriate or informative. [Inference]
- In high-dimensional settings with many potential control variables, regularized precision matrix estimation (e.g., graphical lasso) is often preferred over direct matrix inversion for numerical stability and interpretability. [Inference]
- Partial correlation analysis is often a useful exploratory step before applying more formal causal inference frameworks, such as those based on directed acyclic graphs (DAGs). [Inference]

**Next Steps**
- Pearson Correlation
- Covariance Matrices and Precision Matrices
- Gaussian Graphical Models
- Graphical Lasso for Sparse Precision Matrix Estimation
- Multicollinearity and Variance Inflation Factor
- Causal Inference and Directed Acyclic Graphs
- Semi-Partial Correlation in Regression Analysis