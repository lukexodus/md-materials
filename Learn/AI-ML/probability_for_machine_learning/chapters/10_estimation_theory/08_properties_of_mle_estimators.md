## Properties of MLE Estimators

### Overview

Maximum Likelihood Estimation (MLE) produces estimators whose behavior can be characterized through several theoretical properties. These properties describe how MLE estimators behave, particularly as sample size grows. Most of these properties are asymptotic, meaning they describe behavior as $n \to \infty$, and may not hold exactly for finite samples.

### Consistency

**Definition**

An estimator $\hat{\theta}_n$ is consistent if it converges in probability to the true parameter value $\theta_0$ as the sample size increases:

$$\hat{\theta}_n \xrightarrow{p} \theta_0 \quad \text{as } n \to \infty$$

**Key Points**
- Under standard regularity conditions, MLE is consistent. [Inference] This is a well-established theoretical result in classical statistics, though the specific regularity conditions required (identifiability, continuity, compactness of parameter space, among others) must hold for the guarantee to apply.
- Consistency does not describe finite-sample accuracy — a consistent estimator can still perform poorly with small $n$.
- Consistency relies on the model being correctly specified. If the assumed model family does not contain the true data-generating process, MLE may converge to a different value (the "pseudo-true" parameter). [Inference]

### Asymptotic Normality

**Definition**

As sample size grows, the sampling distribution of the MLE approaches a normal distribution centered at the true parameter:

$$\sqrt{n}(\hat{\theta}_n - \theta_0) \xrightarrow{d} \mathcal{N}(0, I(\theta_0)^{-1})$$

where $I(\theta_0)$ is the Fisher Information at the true parameter value.

**Key Points**
- This result allows construction of approximate confidence intervals and hypothesis tests for large $n$.
- The quality of the normal approximation for small or moderate $n$ varies by model and is not fixed by this theorem. [Inference]
- Asymptotic normality depends on the same regularity conditions required for consistency, plus differentiability of the log-likelihood.

### Efficiency and the Cramér–Rao Lower Bound

**Definition**

The Cramér–Rao Lower Bound (CRLB) establishes a lower bound on the variance of any unbiased estimator:

$$\text{Var}(\hat{\theta}) \geq \frac{1}{I(\theta)}$$

where $I(\theta)$ is the Fisher Information.

**Key Points**
- MLE is asymptotically efficient, meaning that as $n \to \infty$, its variance approaches the CRLB. [Inference] This is an asymptotic property; for finite samples, other estimators may have lower variance in specific cases.
- "Asymptotically efficient" does not mean MLE has minimum variance for every finite sample size.
- Efficiency comparisons assume the same regularity conditions as consistency and asymptotic normality.

### Invariance Property

**Definition**

If $\hat{\theta}$ is the MLE of $\theta$, then for any function $g(\theta)$, the MLE of $g(\theta)$ is $g(\hat{\theta})$:

$$\widehat{g(\theta)} = g(\hat{\theta})$$

**Example**

If $\hat{\lambda}$ is the MLE of the rate parameter $\lambda$ in an exponential distribution, then the MLE of the mean $\frac{1}{\lambda}$ is simply $\frac{1}{\hat{\lambda}}$ — no separate optimization is required.

**Key Points**
- This property holds exactly for finite samples, unlike consistency, asymptotic normality, and efficiency, which are asymptotic.
- It applies to any transformation $g$, including non-linear and non-invertible functions, though the interpretation for non-invertible functions requires care. [Inference]

### Bias of MLE Estimators

**Key Points**
- MLE estimators are not guaranteed to be unbiased. A commonly cited example is the MLE of variance in a Gaussian distribution, which uses $n$ rather than $n-1$ in the denominator, producing a biased estimate for finite samples. [Unverified — I have not verified the exact derivation here; this is a widely cited textbook example but should be checked against a primary source such as Casella & Berger, *Statistical Inference*.]
- MLE is asymptotically unbiased under standard regularity conditions, meaning bias tends toward zero as $n \to \infty$. [Inference]
- Bias and consistency are distinct properties — an estimator can be biased for finite $n$ while still being consistent.

### Regularity Conditions

MLE properties above (consistency, asymptotic normality, efficiency) generally require conditions such as:

- The true parameter lies in the interior of the parameter space
- The likelihood function is differentiable with respect to $\theta$
- The support of the distribution does not depend on $\theta$
- The Fisher Information is positive and finite

**Key Points**
- If these conditions are violated (e.g., uniform distribution with parameter-dependent support), MLE may lose some or all of the properties described above. [Inference]
- Verifying regularity conditions for a specific model is a case-by-case task and is not automatic.

### Relationship Between Properties

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 420">
  <text x="400" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">MLE Estimator Properties (svg_diagram)</text>

  <rect x="300" y="55" width="200" height="50" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5" />
  <text x="400" y="85" font-size="14" text-anchor="middle" fill="#1a1a1a">Regularity Conditions</text>

  <line x1="400" y1="105" x2="400" y2="135" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="120" y="140" width="160" height="50" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="200" y="170" font-size="13" text-anchor="middle" fill="#1a1a1a">Consistency</text>

  <rect x="320" y="140" width="160" height="50" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="400" y="165" font-size="13" text-anchor="middle" fill="#1a1a1a">Asymptotic</text>
  <text x="400" y="180" font-size="13" text-anchor="middle" fill="#1a1a1a">Normality</text>

  <rect x="520" y="140" width="160" height="50" rx="6" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5" />
  <text x="600" y="165" font-size="13" text-anchor="middle" fill="#1a1a1a">Asymptotic</text>
  <text x="600" y="180" font-size="13" text-anchor="middle" fill="#1a1a1a">Efficiency</text>

  <line x1="400" y1="105" x2="200" y2="140" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="400" y1="105" x2="600" y2="140" stroke="#666" stroke-width="1.5" marker-end="url(#arrow)" />

  <rect x="300" y="230" width="200" height="50" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5" />
  <text x="400" y="260" font-size="14" text-anchor="middle" fill="#1a1a1a">Invariance Property</text>
  <text x="400" y="300" font-size="11.5" text-anchor="middle" fill="#555">(holds for finite samples;</text>
  <text x="400" y="315" font-size="11.5" text-anchor="middle" fill="#555">independent of asymptotics)</text>

  <rect x="80" y="350" width="640" height="55" rx="6" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5" />
  <text x="400" y="373" font-size="12.5" text-anchor="middle" fill="#1a1a1a">Bias: not guaranteed to be zero for finite n</text>
  <text x="400" y="392" font-size="12.5" text-anchor="middle" fill="#1a1a1a">[Inference] asymptotically unbiased under regularity conditions</text>

  </svg>

### Common Pitfalls

- Assuming asymptotic properties apply at small sample sizes without checking convergence behavior for the specific model. [Inference]
- Treating MLE as unbiased by default — bias must be checked per model.
- Ignoring regularity condition violations (e.g., parameter-dependent support), which can invalidate consistency and asymptotic normality claims for that model. [Inference]
- Confusing consistency (large-sample convergence) with unbiasedness (finite-sample expectation equal to true value) — these are independent properties.

### Practical Implications for Machine Learning

- Many ML estimators (e.g., logistic regression coefficients under MLE) rely on asymptotic normality for constructing confidence intervals and standard errors. [Inference] Applicability depends on sample size and whether regularity conditions hold for the specific model architecture.
- With large datasets, MLE-based estimators are often treated as approximately unbiased and normally distributed in practice, though this is a practical approximation rather than a finite-sample guarantee. [Inference]
- For small datasets or high-dimensional parameter spaces, asymptotic properties may not hold well, and regularized or Bayesian alternatives are sometimes preferred. [Unverified — the comparative performance depends heavily on the specific problem and is not universally established.]

**Related Topics**
- Fisher Information and its role in variance bounds
- Bias-Variance tradeoff in estimation
- Bayesian estimation vs. Maximum Likelihood Estimation
- Asymptotic theory in statistics (delta method, M-estimators)
- Regularized Maximum Likelihood (MAP estimation)
- Confidence intervals derived from MLE
- Model misspecification and its effect on MLE consistency