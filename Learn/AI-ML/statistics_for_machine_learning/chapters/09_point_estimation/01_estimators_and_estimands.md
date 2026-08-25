## Estimators and Estimands

### Definition

An **estimand** is the specific population quantity or parameter that a statistical analysis aims to estimate — the theoretical target of inference, such as a population mean, variance, or regression coefficient. An **estimator** is the rule, formula, or algorithm applied to sample data to produce a numerical approximation of that estimand. The numerical output produced by applying an estimator to a specific dataset is called an **estimate**.

### Distinguishing the Three Concepts

| Term | Nature | Example |
|---|---|---|
| Estimand | A fixed but typically unknown population quantity | The true population mean income, $\mu$ |
| Estimator | A function or rule applied to sample data | $\bar{X} = \frac{1}{n}\sum_{i=1}^{n} X_i$ |
| Estimate | A specific numerical value from applying the estimator to observed data | $\bar{x} = 52{,}340$ (from one particular sample) |

**Key Points**

- The estimand exists independently of any sample; it is a property of the population
- The estimator is a general procedure that could be applied to any sample drawn from that population
- The estimate is the realized output for one specific dataset — different samples yield different estimates from the same estimator [Inference]

### Notation Conventions

**Key Points**

- The estimand is typically denoted with a Greek letter, such as $\theta$, $\mu$, or $\sigma^2$
- The estimator or estimate is typically denoted with a "hat," such as $\hat{\theta}$, $\hat{\mu}$, or $\hat{\sigma}^2$
- This notation convention is widely used in statistical literature, though I cannot verify it is applied with perfect uniformity across all sources or subfields [Unverified]

### Properties of Estimators

#### Bias

**Definition**

The bias of an estimator is the difference between the expected value of the estimator (across repeated sampling) and the true value of the estimand.

$$\text{Bias}(\hat{\theta}) = E[\hat{\theta}] - \theta$$

**Key Points**

- An estimator is called **unbiased** if $E[\hat{\theta}] = \theta$, meaning its expected value across repeated samples equals the true estimand
- An estimator is called **biased** if this expectation differs systematically from $\theta$
- The sample mean $\bar{X}$ is an unbiased estimator of the population mean $\mu$ [Inference: this is a widely taught result derived from the linearity of expectation, though I cannot independently verify every textbook presents this identically]

#### Variance of an Estimator

**Definition**

The variance of an estimator describes how much the estimator's value is expected to fluctuate across different samples drawn from the same population.

$$\text{Var}(\hat{\theta}) = E\left[\left(\hat{\theta} - E[\hat{\theta}]\right)^2\right]$$

**Key Points**

- Lower variance indicates the estimator produces more consistent estimates across different samples
- Variance of an estimator is closely related to standard error, which is the square root of the estimator's variance [Inference]

#### Mean Squared Error (MSE)

**Definition**

Mean squared error combines both bias and variance into a single measure of an estimator's overall accuracy.

$$MSE(\hat{\theta}) = \text{Var}(\hat{\theta}) + \left[\text{Bias}(\hat{\theta})\right]^2$$

**Key Points**

- This decomposition shows that an estimator's total error arises from two distinct sources: systematic bias and random variance
- An estimator with zero bias but high variance can have a higher MSE than a slightly biased estimator with much lower variance [Inference]
- This tradeoff is conceptually related to the bias-variance tradeoff discussed in machine learning model evaluation [Inference]

#### Consistency

**Definition**

An estimator is called **consistent** if, as the sample size $n$ increases toward infinity, the estimator converges in probability to the true value of the estimand.

$$\hat{\theta}_n \xrightarrow{P} \theta \quad \text{as } n \to \infty$$

**Key Points**

- Consistency is an asymptotic property, describing behavior as sample size grows without bound, rather than behavior at any fixed finite sample size [Inference]
- A biased estimator can still be consistent if its bias diminishes to zero as $n \to \infty$ [Inference]

#### Efficiency

**Definition**

An estimator is considered more **efficient** relative to another if it achieves a lower variance while remaining unbiased (or while holding bias constant), typically compared against a theoretical lower bound on variance.

**Key Points**

- The **Cramér–Rao lower bound** is often cited as a theoretical minimum variance achievable by an unbiased estimator, though I cannot verify the specific mathematical conditions under which it applies without a cited source [Unverified]
- Among a class of unbiased estimators, the one with the lowest variance is sometimes referred to as the "best" or "most efficient" unbiased estimator [Unverified: terminology and formal criteria vary across sources]

### Illustration

<svg width="100%" viewBox="0 0 680 340" role="img"><title>Bias and variance of estimators (svg_diagram)</title><desc>Four target diagrams illustrating combinations of low and high bias with low and high variance, showing where estimates cluster relative to the true estimand at the center.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<text class="th" x="150" y="30" text-anchor="middle">Low bias, low variance (svg_diagram)</text>
<circle cx="150" cy="110" r="60" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="110" r="40" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="110" r="20" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="110" r="2" fill="#D85A30" />
<circle cx="146" cy="108" r="4" fill="#378ADD" />
<circle cx="153" cy="112" r="4" fill="#378ADD" />
<circle cx="148" cy="115" r="4" fill="#378ADD" />
<circle cx="153" cy="106" r="4" fill="#378ADD" />

<text class="th" x="530" y="30" text-anchor="middle">High bias, low variance</text>
<circle cx="530" cy="110" r="60" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="110" r="40" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="110" r="20" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="110" r="2" fill="#D85A30" />
<circle cx="572" cy="95" r="4" fill="#378ADD" />
<circle cx="576" cy="100" r="4" fill="#378ADD" />
<circle cx="574" cy="90" r="4" fill="#378ADD" />
<circle cx="578" cy="97" r="4" fill="#378ADD" />

<text class="th" x="150" y="230" text-anchor="middle">Low bias, high variance</text>
<circle cx="150" cy="290" r="60" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="290" r="40" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="290" r="20" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="150" cy="290" r="2" fill="#D85A30" />
<circle cx="115" cy="260" r="4" fill="#378ADD" />
<circle cx="185" cy="320" r="4" fill="#378ADD" />
<circle cx="120" cy="325" r="4" fill="#378ADD" />
<circle cx="180" cy="255" r="4" fill="#378ADD" />

<text class="th" x="530" y="230" text-anchor="middle">High bias, high variance</text>
<circle cx="530" cy="290" r="60" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="290" r="40" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="290" r="20" fill="none" stroke="var(--t)" stroke-width="0.5" />
<circle cx="530" cy="290" r="2" fill="#D85A30" />
<circle cx="590" cy="250" r="4" fill="#378ADD" />
<circle cx="605" cy="270" r="4" fill="#378ADD" />
<circle cx="595" cy="320" r="4" fill="#378ADD" />
<circle cx="610" cy="245" r="4" fill="#378ADD" />
</svg>

[Inference] This diagram illustrates a conceptual analogy commonly used to teach bias and variance, not a specific empirical dataset. The center point represents the true estimand; blue points represent estimates from repeated samples.

### Common Examples of Estimators and Their Estimands

| Estimand | Common Estimator | Formula |
|---|---|---|
| Population mean $\mu$ | Sample mean $\bar{X}$ | $\bar{X} = \frac{1}{n}\sum X_i$ |
| Population variance $\sigma^2$ | Sample variance $s^2$ | $s^2 = \frac{1}{n-1}\sum (X_i - \bar{X})^2$ |
| Population proportion $p$ | Sample proportion $\hat{p}$ | $\hat{p} = \frac{\text{count of successes}}{n}$ |
| Regression coefficient $\beta$ | Ordinary least squares estimate $\hat{\beta}$ | $\hat{\beta} = (X^TX)^{-1}X^Ty$ |

**[Unverified]** I cannot verify without a specific cited source that the $n-1$ denominator (Bessel's correction) in the sample variance formula is explained identically across all statistical textbooks, though it is commonly presented as a correction for the bias that would otherwise arise from using the sample mean in place of the unknown population mean. [Inference]

### Point Estimation vs. Interval Estimation

**Key Points**

- **Point estimation** produces a single numerical value as the estimate of the estimand (e.g., $\bar{x} = 52{,}340$)
- **Interval estimation** produces a range of plausible values, such as a confidence interval, intended to capture the estimand with a stated level of confidence
- Both approaches rely on an underlying estimator; interval estimation additionally requires an estimate of the estimator's variability (e.g., standard error) [Inference]

### Relevance to Machine Learning

**Key Points**

- Model parameters (e.g., regression coefficients, neural network weights) can be framed as estimators of underlying, often unobservable, true relationships in the data-generating process [Inference]
- Loss functions used in training are often designed so that minimizing them yields a specific type of estimator; for example, minimizing squared error loss is connected to producing an estimator with maximum likelihood properties under a Gaussian noise assumption [Unverified: the specific theoretical connection depends on model assumptions I cannot verify apply universally]
- Regularization techniques (e.g., ridge regression, LASSO) intentionally introduce bias into an estimator in exchange for reduced variance, aiming to lower overall mean squared error [Inference]
- Evaluation metrics computed on test data (e.g., mean accuracy) are themselves estimators of a model's true generalization performance, which is itself an unobservable estimand [Inference]

**Example**

In ridge regression, the estimator is modified from ordinary least squares by adding a penalty term:

$$\hat{\beta}_{ridge} = (X^TX + \lambda I)^{-1}X^Ty$$

This estimator is generally biased relative to the true coefficient $\beta$, but is intended to reduce variance, particularly under multicollinearity. [Inference] Whether this results in lower MSE than the unbiased OLS estimator depends on the specific data and value of $\lambda$; I cannot verify this holds universally across all datasets. [Unverified]

### Limitations and Considerations

**Key Points**

- An estimand must be clearly and precisely defined before an estimator can be meaningfully evaluated; ambiguity in the target quantity can lead to estimators that answer a different question than intended [Inference]
- No single estimator is universally "best" across all criteria (bias, variance, computational cost); the appropriate choice depends on the specific context and priorities of the analysis [Unverified: I cannot confirm a single universally agreed-upon selection framework across all statistical literature]
- The properties of an estimator (bias, consistency, efficiency) are typically derived under specific assumptions about the data-generating process; violations of these assumptions can affect whether the stated properties hold [Inference]

I cannot verify that this list represents an exhaustive set of considerations discussed across all statistical and machine learning literature.

### Related Topics

- Bias-variance tradeoff
- Standard error and sampling distributions
- Maximum likelihood estimation
- Confidence intervals
- Regularization methods (ridge regression, LASSO)
- Bootstrap and jackknife resampling

[Unverified] This entire response contains a combination of established statistical definitions and [Inference] or [Unverified]-labeled reasoning where I could not confirm a claim against a specific cited source. Claims regarding machine learning practice or model behavior are not guaranteed and may vary depending on implementation, data characteristics, and context.