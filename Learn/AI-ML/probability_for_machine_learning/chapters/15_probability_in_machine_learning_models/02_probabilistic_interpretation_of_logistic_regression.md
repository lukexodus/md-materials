## Probabilistic Interpretation of Logistic Regression

### Overview

Logistic regression is a discriminative probabilistic model used for binary (and, via extensions, multiclass) classification. Rather than directly predicting a class label, it models the conditional probability of a class given input features, $P(y \mid \mathbf{x})$. This distinguishes it from a purely algorithmic view of logistic regression as "fitting an S-curve," and instead grounds it in a formal probabilistic framework rooted in the Bernoulli distribution and maximum likelihood estimation.

### The Bernoulli Model of the Output

For binary classification with labels $y \in \{0, 1\}$, the output is modeled as a Bernoulli random variable:

$$
y \mid \mathbf{x} \sim \text{Bernoulli}(p)
$$

where $p = P(y = 1 \mid \mathbf{x})$. The probability mass function is:

$$
P(y \mid \mathbf{x}) = p^{y}(1-p)^{1-y}
$$

This single expression compactly represents both cases:
- When $y = 1$: $P(y \mid \mathbf{x}) = p$
- When $y = 0$: $P(y \mid \mathbf{x}) = 1 - p$

**Key Points**
- Logistic regression does not model $y$ directly; it models the parameter $p$ of a Bernoulli distribution.
- The model assumes each observation is conditionally independent given $\mathbf{x}$.

### Linking Linear Combinations to Probabilities

A linear model produces an unbounded real-valued output:

$$
z = \mathbf{w}^\top \mathbf{x} + b
$$

Since $z \in (-\infty, \infty)$ but probabilities must lie in $[0, 1]$, a **link function** is required. Logistic regression uses the sigmoid (logistic) function:

$$
\sigma(z) = \frac{1}{1 + e^{-z}}
$$

so that:

$$
p = P(y = 1 \mid \mathbf{x}) = \sigma(\mathbf{w}^\top \mathbf{x} + b)
$$

The sigmoid function maps any real number to the open interval $(0, 1)$, satisfying the axioms of probability for a single Bernoulli parameter.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Sigmoid Function: Mapping Linear Output to Probability (svg_diagram)</text>

  <line x1="80" y1="320" x2="580" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="320" x2="80" y2="60" stroke="#333" stroke-width="1.5" />

  <text x="580" y="340" font-size="12" fill="#333">z</text>
  <text x="60" y="65" font-size="12" fill="#333">p</text>

  <line x1="75" y1="190" x2="580" y2="190" stroke="#ccc" stroke-width="1" stroke-dasharray="4,4" />
  <text x="60" y="194" font-size="11" fill="#666">0.5</text>

  <line x1="80" y1="65" x2="580" y2="65" stroke="#ccc" stroke-width="1" stroke-dasharray="2,2" />
  <text x="60" y="69" font-size="11" fill="#666">1.0</text>

  <line x1="80" y1="320" x2="580" y2="320" stroke="#ccc" stroke-width="1" stroke-dasharray="2,2" />
  <text x="60" y="324" font-size="11" fill="#666">0.0</text>

  <path d="M 80 315             C 180 315, 250 300, 300 250            C 320 220, 330 195, 330 190            C 330 185, 340 160, 360 130            C 410 80, 480 68, 580 65" fill="none" stroke="#2563eb" stroke-width="2.5" />

  <circle cx="330" cy="190" r="4" fill="#dc2626" />
  <text x="340" y="180" font-size="11" fill="#dc2626">z = 0, p = 0.5</text>

  <text x="320" y="360" text-anchor="middle" font-size="12" fill="#444">Decision boundary occurs where z = 0 (i.e., p = 0.5)</text>
</svg>

**Key Points**
- The sigmoid is monotonic, meaning larger $z$ always corresponds to larger $p$.
- $\sigma(0) = 0.5$, so the decision boundary (where the model is indifferent between classes) corresponds to $\mathbf{w}^\top \mathbf{x} + b = 0$.
- This is a modeling choice; other link functions (e.g., probit) exist and lead to different models. [Inference] The sigmoid is favored partly due to its convenient derivative and connection to log-odds, though this is a design rationale rather than a strict mathematical necessity.

### Log-Odds (Logit) Interpretation

The sigmoid function has an inverse called the **logit function**, which reveals why logistic regression is "linear" in a specific sense:

$$
\log\left(\frac{p}{1-p}\right) = \mathbf{w}^\top \mathbf{x} + b
$$

The quantity $\frac{p}{1-p}$ is called the **odds** of the positive class, and its logarithm is the **log-odds** or **logit**.

**Key Points**
- Logistic regression assumes a linear relationship between the input features and the log-odds of the outcome, not the probability itself.
- A unit increase in a feature $x_i$ changes the log-odds by $w_i$, holding other features constant.
- Exponentiating a coefficient, $e^{w_i}$, gives the multiplicative change in odds per unit increase in $x_i$. This is a standard interpretive technique in applied statistics.

### Likelihood Function

Given a dataset $\{(\mathbf{x}_i, y_i)\}_{i=1}^n$ with independent observations, the likelihood of the parameters $\mathbf{w}, b$ is:

$$
L(\mathbf{w}, b) = \prod_{i=1}^{n} p_i^{y_i} (1 - p_i)^{1 - y_i}
$$

where $p_i = \sigma(\mathbf{w}^\top \mathbf{x}_i + b)$.

Taking the log for numerical stability and analytical convenience gives the **log-likelihood**:

$$
\ell(\mathbf{w}, b) = \sum_{i=1}^{n} \left[ y_i \log p_i + (1 - y_i) \log(1 - p_i) \right]
$$

### Connection to Cross-Entropy Loss

Maximizing the log-likelihood is equivalent to minimizing the negative log-likelihood, which is exactly the **binary cross-entropy loss** commonly used to train logistic regression models:

$$
J(\mathbf{w}, b) = -\frac{1}{n}\sum_{i=1}^{n} \left[ y_i \log p_i + (1 - y_i) \log(1 - p_i) \right]
$$

**Key Points**
- This shows that logistic regression's standard training objective is not an arbitrary loss function — it is derived directly from maximum likelihood estimation under a Bernoulli assumption.
- The loss penalizes confident, incorrect predictions heavily due to the logarithm's behavior near 0 and 1.
- [Inference] This connection between MLE and cross-entropy is a widely taught derivation in statistical machine learning; however, the exact pedagogical framing may differ slightly across textbooks and courses.

### Maximum Likelihood Estimation and Optimization

Unlike linear regression under Gaussian noise assumptions, logistic regression's log-likelihood has no closed-form solution for $\mathbf{w}, b$. This is because the sigmoid function introduces nonlinearity into the likelihood equations.

**Key Points**
- Parameters are typically estimated using iterative optimization methods such as gradient descent, Newton's method, or iteratively reweighted least squares (IRLS).
- The log-likelihood function for logistic regression is concave, so [Inference] under standard conditions (linearly separable data excluded, and features not perfectly collinear), gradient-based methods are expected to converge to the global maximum, though actual convergence in practice depends on implementation details, learning rate, and data conditioning.
- Behavior of specific solvers (e.g., convergence speed, numerical stability) may vary by library and implementation. [Unverified] for any specific software package unless documented directly in that package's technical references.

### Decision Rule from Probabilities

Once $p = P(y=1 \mid \mathbf{x})$ is estimated, a hard classification decision is typically made by thresholding:

$$
\hat{y} = \begin{cases} 1 & \text{if } p \geq 0.5 \\ 0 & \text{if } p < 0.5 \end{cases}
$$

**Key Points**
- The threshold of 0.5 is a convention, not a mathematical requirement. It can be adjusted based on class imbalance, cost-sensitive decision-making, or desired precision/recall tradeoffs.
- Because the output is a calibrated-in-theory probability, logistic regression allows downstream decisions to incorporate uncertainty, unlike models that output only hard labels.

### Worked Example

**Example**

Suppose a simple model predicts loan default using a single feature, credit score deviation $x$ (standardized), with fitted parameters $w = -2.0$, $b = 0.1$.

For a data point with $x = 0.5$:

$$
z = (-2.0)(0.5) + 0.1 = -0.9
$$

$$
p = \sigma(-0.9) = \frac{1}{1 + e^{0.9}} \approx \frac{1}{1 + 2.4596} \approx 0.289
$$

**Output**

$P(y = 1 \mid x = 0.5) \approx 0.289$, meaning the model estimates roughly a 28.9% probability of default (class 1) for this input. Since $p < 0.5$, the hard classification under the default threshold would be $\hat{y} = 0$ (no default).

### Model Assumptions and Their Probabilistic Role

**Key Points**
- **Conditional independence**: Observations are assumed independent given their features, which justifies factorizing the likelihood as a product.
- **Correct link function**: The model assumes the log-odds are linear in the features; if this assumption is violated, $p$ estimates may be systematically biased. [Inference] This is a standard concern in applied statistics, though the magnitude of bias depends on the degree of true nonlinearity.
- **No perfect separability**: If classes are perfectly linearly separable, the MLE for $\mathbf{w}$ can diverge to infinity, since the log-likelihood keeps improving as weights grow. Regularization (L2/L1) is commonly used to address this in practice.

### Relationship to Naive Bayes

**Key Points**
- Logistic regression is a **discriminative** model: it directly models $P(y \mid \mathbf{x})$.
- Naive Bayes is a **generative** model: it models $P(\mathbf{x} \mid y)$ and $P(y)$, then derives $P(y \mid \mathbf{x})$ via Bayes' theorem.
- [Inference] Under certain assumptions (e.g., features conditionally independent given class, and Gaussian or specific exponential family distributions), Naive Bayes and logistic regression converge to the same decision boundary asymptotically. This is a known theoretical result in some statistical learning treatments, but exact conditions vary by source and are not universally identical across formulations, so this should be treated as [Unverified] without a specific citation being checked in this session.

### Calibration Considerations

**Key Points**
- A well-specified logistic regression model, trained via MLE, tends to produce probability estimates that are reasonably calibrated on data similar to the training distribution.
- Calibration is not automatic under model misspecification, class imbalance, or distributional shift. Claims that logistic regression outputs are "true probabilities" should be treated cautiously — they are estimates conditioned on modeling assumptions.
- Behavior regarding calibration can vary depending on data characteristics and preprocessing; this is [Inference] rather than a fixed guarantee.

### Conclusion

Logistic regression's probabilistic interpretation frames it as maximum likelihood estimation of a Bernoulli parameter linked to a linear predictor via the sigmoid function. This foundation explains the origin of the cross-entropy loss, motivates the log-odds interpretation of coefficients, and clarifies the assumptions under which the model's probability outputs can be meaningfully interpreted. Understanding this derivation distinguishes principled use of logistic regression from purely mechanical curve-fitting.

### Related Topics

- Maximum likelihood estimation: general theory and derivation
- Softmax regression as the multiclass generalization of logistic regression
- Generalized linear models (GLMs) and the exponential family
- Regularization (L1/L2) in logistic regression and its Bayesian interpretation (MAP estimation with priors)
- Calibration curves and reliability diagrams for probabilistic classifiers
- Naive Bayes classifiers and generative vs. discriminative model comparison
- Odds ratios and their interpretation in applied statistics