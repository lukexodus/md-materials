## Cramer-Rao Lower Bound

### Definition

The Cramer-Rao Lower Bound (CRLB) establishes a theoretical lower limit on the variance of any unbiased estimator of a parameter. For a parameter $\theta$ estimated from data with likelihood function $L(\theta; x)$, the variance of any unbiased estimator $\hat{\theta}$ satisfies:

$$\text{Var}(\hat{\theta}) \geq \frac{1}{I(\theta)}$$

where $I(\theta)$ is the Fisher Information.

This is standard statistical theory, established and taught consistently across mathematical statistics literature.

### Fisher Information

Fisher Information quantifies how much information an observable random variable carries about an unknown parameter $\theta$. It is defined as:

$$I(\theta) = E\left[\left(\frac{\partial \log f(X;\theta)}{\partial \theta}\right)^2\right]$$

Equivalently, under regularity conditions:

$$I(\theta) = -E\left[\frac{\partial^2 \log f(X;\theta)}{\partial \theta^2}\right]$$

Both forms are standard and equivalent when the likelihood function is twice differentiable and regularity conditions (interchangeability of integration and differentiation) hold.

For $n$ independent, identically distributed observations, Fisher Information scales linearly:

$$I_n(\theta) = n \cdot I_1(\theta)$$

### Regularity Conditions

The CRLB holds only when certain regularity conditions are satisfied:

- The support of the distribution does not depend on $\theta$
- The density $f(x;\theta)$ is differentiable with respect to $\theta$
- Differentiation and integration can be interchanged (i.e., $\frac{d}{d\theta}\int f(x;\theta)\,dx = \int \frac{\partial f(x;\theta)}{\partial \theta}\,dx$)
- The Fisher Information is finite and positive

If these conditions are not met (e.g., distributions like Uniform$(0, \theta)$ where support depends on $\theta$), the CRLB does not apply in its standard form. [Inference] Whether a specific non-regular case has an analogous bound depends on the distribution and typically requires separate derivation; this is not something I can generalize without checking the specific case.

### Derivation Outline

The derivation relies on the Cauchy-Schwarz inequality applied to the score function $\frac{\partial \log f(X;\theta)}{\partial \theta}$ and the estimator $\hat{\theta}$. The key steps:

1. Start from the unbiasedness condition $E[\hat{\theta}] = \theta$
2. Differentiate both sides with respect to $\theta$
3. Express the result as a covariance between $\hat{\theta}$ and the score function
4. Apply Cauchy-Schwarz to bound this covariance
5. Rearrange to isolate $\text{Var}(\hat{\theta})$

This is a well-established derivation found consistently in mathematical statistics textbooks (e.g., Casella & Berger, *Statistical Inference*). I am not quoting directly from any specific text here — this is a paraphrased summary of the standard proof structure.

### Efficient Estimators

An estimator that achieves the CRLB with equality is called an **efficient estimator**. Not all unbiased estimators achieve this bound — the CRLB is a lower bound, not a target every estimator reaches.

The ratio:

$$e(\hat{\theta}) = \frac{1/I(\theta)}{\text{Var}(\hat{\theta})}$$

is called the **efficiency** of an estimator, with values between 0 and 1 for unbiased estimators satisfying the regularity conditions.

### Relevance to Machine Learning

In machine learning, the CRLB relates to:

- **Maximum Likelihood Estimators (MLE):** Under regularity conditions, MLEs are asymptotically efficient, meaning their asymptotic variance approaches the CRLB as sample size increases. [Inference] This is an asymptotic property — for finite samples, an MLE is not guaranteed to achieve or approach the bound closely, and the rate of convergence depends on the specific model and sample size.
- **Model comparison:** The CRLB can serve as a benchmark to evaluate how close a given estimator's variance is to the theoretical best case.
- **Parameter uncertainty quantification:** Fisher Information matrices (the multivariate generalization) are used in computing standard errors for model parameters, relevant in confidence interval construction for ML model coefficients.

[Speculation] Some practitioners use Fisher Information-based bounds informally to assess whether additional data collection is likely to meaningfully reduce parameter uncertainty, though this is a heuristic application rather than a formal guarantee, and I do not have a specific verified source describing this as standard practice.

### Multivariate Extension — Fisher Information Matrix

For a vector of parameters $\boldsymbol{\theta} = (\theta_1, \theta_2, \ldots, \theta_k)$, the Fisher Information generalizes to a matrix:

$$[I(\boldsymbol{\theta})]_{ij} = E\left[\frac{\partial \log f(X;\boldsymbol{\theta})}{\partial \theta_i}\cdot\frac{\partial \log f(X;\boldsymbol{\theta})}{\partial \theta_j}\right]$$

The CRLB then takes the matrix form:

$$\text{Cov}(\hat{\boldsymbol{\theta}}) \succeq I(\boldsymbol{\theta})^{-1}$$

where $\succeq$ denotes that the difference $\text{Cov}(\hat{\boldsymbol{\theta}}) - I(\boldsymbol{\theta})^{-1}$ is positive semi-definite. This is standard for multi-parameter estimation problems, including many ML settings such as multivariate Gaussian parameter estimation.

### Worked Example — Normal Distribution Mean

Consider $X_1, \ldots, X_n \sim N(\mu, \sigma^2)$ with $\sigma^2$ known, estimating $\mu$.

The log-likelihood for a single observation:

$$\log f(x;\mu) = -\frac{1}{2}\log(2\pi\sigma^2) - \frac{(x-\mu)^2}{2\sigma^2}$$

First derivative with respect to $\mu$:

$$\frac{\partial \log f}{\partial \mu} = \frac{x-\mu}{\sigma^2}$$

Second derivative:

$$\frac{\partial^2 \log f}{\partial \mu^2} = -\frac{1}{\sigma^2}$$

So Fisher Information for one observation is $I_1(\mu) = \frac{1}{\sigma^2}$, and for $n$ observations:

$$I_n(\mu) = \frac{n}{\sigma^2}$$

Therefore:

$$\text{Var}(\hat{\mu}) \geq \frac{\sigma^2}{n}$$

The sample mean $\bar{X}$ has variance exactly $\frac{\sigma^2}{n}$, so it achieves the CRLB — it is an efficient estimator for this case. This is a standard, verifiable result derivable directly from the definitions above.

### CRLB Concept Flow (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 380">
<text x="380" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">CRLB Concept Flow (svg_diagram)</text>
<rect x="40" y="60" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="140" y="85" text-anchor="middle" font-size="13" fill="#1a1a1a">Likelihood Function</text>
<text x="140" y="103" text-anchor="middle" font-size="12" fill="#333">L(θ; x)</text>
<rect x="290" y="60" width="200" height="60" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="390" y="85" text-anchor="middle" font-size="13" fill="#1a1a1a">Score Function</text>
<text x="390" y="103" text-anchor="middle" font-size="12" fill="#333">∂ log f / ∂θ</text>
<rect x="540" y="60" width="180" height="60" rx="8" fill="#e8f0fe" stroke="#4a6fa5" stroke-width="1.5" />
<text x="630" y="85" text-anchor="middle" font-size="13" fill="#1a1a1a">Fisher Information</text>
<text x="630" y="103" text-anchor="middle" font-size="12" fill="#333">I(θ)</text>
<line x1="240" y1="90" x2="285" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="490" y1="90" x2="535" y2="90" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="290" y="180" width="200" height="60" rx="8" fill="#fef3e0" stroke="#c9891a" stroke-width="1.5" />
<text x="390" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">CRLB</text>
<text x="390" y="223" text-anchor="middle" font-size="12" fill="#333">Var(θ̂) ≥ 1 / I(θ)</text>
<line x1="630" y1="120" x2="630" y2="210" stroke="#666" stroke-width="1.5" />
<line x1="630" y1="210" x2="495" y2="210" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
<rect x="80" y="290" width="200" height="60" rx="8" fill="#e8f5e9" stroke="#3a8a4a" stroke-width="1.5" />
<text x="180" y="315" text-anchor="middle" font-size="13" fill="#1a1a1a">Efficient Estimator</text>
<text x="180" y="333" text-anchor="middle" font-size="12" fill="#333">Var(θ̂) = 1 / I(θ)</text>
<rect x="500" y="290" width="220" height="60" rx="8" fill="#fde8e8" stroke="#a53a3a" stroke-width="1.5" />
<text x="610" y="315" text-anchor="middle" font-size="13" fill="#1a1a1a">Sub-optimal Estimator</text>
<text x="610" y="333" text-anchor="middle" font-size="12" fill="#333">Var(θ̂) &gt; 1 / I(θ)</text>
<line x1="340" y1="240" x2="200" y2="285" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="440" y1="240" x2="580" y2="285" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
</svg>

### Common Pitfalls

- **Applying CRLB to biased estimators without adjustment:** The bound stated above applies strictly to unbiased estimators. A biased-estimator version exists but requires a correction term involving the derivative of the bias function.
- **Ignoring regularity conditions:** Applying the standard CRLB formula to distributions with parameter-dependent support (e.g., Uniform$(0,\theta)$) produces incorrect conclusions, since the regularity conditions fail.
- **Assuming CRLB is always attainable:** [Inference] Not all estimation problems have an estimator that reaches the CRLB — this depends on whether an efficient estimator exists for that specific model, which is not guaranteed in general.
- **Confusing asymptotic efficiency with finite-sample efficiency:** MLE's approach to the CRLB is an asymptotic result; behavior at small sample sizes can differ meaningfully from the bound. [Inference] The extent of this deviation is model-specific, and I do not have a general formula covering all cases.

### Relationship to Other Bounds

The CRLB is one of several lower bounds on estimator variance. Other bounds — such as the Bhattacharyya bound and the Chapman-Robbins bound — exist and can be tighter under certain conditions.

[Unverified] I do not have a comprehensive, verified comparison of when each alternative bound is tighter than CRLB across general classes of distributions; this would require case-by-case derivation rather than a general rule I can state reliably.

### Next Steps

- **Fisher Information Matrix** — deeper treatment of the multivariate case and its role in computing standard errors for ML model parameters
- **Maximum Likelihood Estimation (MLE)** — properties, asymptotic normality, and connection to Fisher Information
- **Sufficient Statistics and the Rao-Blackwell Theorem** — improving estimators using sufficiency
- **Bias-Variance Tradeoff in Estimation** — connecting CRLB concepts to broader estimator evaluation in ML
- **Asymptotic Efficiency of MLE** — formal treatment of convergence to the CRLB as $n \to \infty$
- **Bhattacharyya and Chapman-Robbins Bounds** — alternative, sometimes tighter, variance bounds
- **Confidence Intervals via Fisher Information** — practical application in model parameter uncertainty estimation