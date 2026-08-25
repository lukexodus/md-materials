## Maximum Likelihood Estimation

### Definition

Maximum likelihood estimation (MLE) is a method for estimating unknown population parameters by selecting the parameter values that maximize the likelihood function — a function expressing how probable the observed data is, given a set of parameter values.

$$\hat{\theta}_{MLE} = \arg\max_{\theta} \, L(\theta \mid x_1, x_2, \ldots, x_n)$$

where $L(\theta \mid x_1, \ldots, x_n)$ is the likelihood function evaluated at the observed data, treated as a function of the unknown parameter $\theta$.

### The Likelihood Function

**Key Points**

- For independent and identically distributed (i.i.d.) observations, the likelihood function is the product of the individual probability density (or mass) functions evaluated at each observation:

$$L(\theta \mid x_1, \ldots, x_n) = \prod_{i=1}^{n} f(x_i \mid \theta)$$

- The likelihood function is a function of the parameter $\theta$, with the data held fixed — this is the reverse framing of a probability density function, which is a function of the data with the parameter held fixed [Inference]
- I cannot verify that this distinction between likelihood and probability is articulated identically across all statistical sources, though the mathematical formula itself is a standard construction [Inference]

### Log-Likelihood

**Definition**

Because products of many small probabilities can become numerically difficult to work with, the log-likelihood — the natural logarithm of the likelihood function — is commonly used instead, converting the product into a sum.

$$\ell(\theta) = \log L(\theta \mid x_1, \ldots, x_n) = \sum_{i=1}^{n} \log f(x_i \mid \theta)$$

**Key Points**

- Since the logarithm is a monotonically increasing function, the value of $\theta$ that maximizes $\ell(\theta)$ is the same value that maximizes $L(\theta)$ [Inference]
- Working with sums rather than products is generally more numerically stable and more tractable for calculus-based optimization (taking derivatives) [Inference]

### General Procedure

1. Specify a probability distribution assumed to have generated the observed data, with one or more unknown parameters
2. Write the likelihood function $L(\theta)$ as the product of the density/mass function across all observations
3. Take the natural logarithm to obtain the log-likelihood $\ell(\theta)$
4. Differentiate $\ell(\theta)$ with respect to each parameter and set the derivative(s) equal to zero
5. Solve the resulting equation(s) for the parameter(s), yielding the maximum likelihood estimate(s)
6. Verify (e.g., via second derivative) that the solution corresponds to a maximum rather than a minimum or saddle point [Inference]

**Key Points**

- I cannot verify that a closed-form analytical solution exists for every distribution; some likelihood functions require numerical optimization methods rather than direct differentiation [Unverified]

### Worked Example: Normal Distribution

**Example**

For data assumed to be i.i.d. from a normal distribution with unknown mean $\mu$ and known variance $\sigma^2$, the log-likelihood is:

$$\ell(\mu) = -\frac{n}{2}\log(2\pi\sigma^2) - \frac{1}{2\sigma^2}\sum_{i=1}^{n}(x_i - \mu)^2$$

Differentiating with respect to $\mu$ and setting the result to zero yields:

$$\hat{\mu}_{MLE} = \frac{1}{n}\sum_{i=1}^{n} x_i = \bar{X}$$

[Inference] This result is commonly presented in statistical literature, showing that the MLE of the mean under a normal distribution assumption coincides with the sample mean. I cannot independently verify every textbook presents this identical derivation.

**Key Points**

- For the same normal distribution setup, the MLE of variance (with $\mu$ also unknown and estimated) is commonly derived as:

$$\hat{\sigma}^2_{MLE} = \frac{1}{n}\sum_{i=1}^{n}(x_i - \bar{X})^2$$

- This MLE variance estimator uses $n$ in the denominator, making it a biased estimator of the population variance at finite sample sizes — the same biased form encountered in the discussion of bias of an estimator [Inference]

### Illustration

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Maximum likelihood estimation as finding the peak of the likelihood function (svg_diagram)</title><desc>Chart showing the log-likelihood function plotted against candidate parameter values, with the maximum likelihood estimate identified at the peak of the curve.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<line x1="60" y1="250" x2="620" y2="250" stroke="var(--t)" stroke-width="0.5" />
<text class="ts" x="620" y="270" text-anchor="end">Candidate parameter value (theta)</text>
<line x1="60" y1="250" x2="60" y2="50" stroke="var(--t)" stroke-width="0.5" />
<text class="ts" x="45" y="50" text-anchor="end">Log-likelihood</text>

<path fill="none" stroke="#378ADD" stroke-width="1.5" d="M100 230 Q340 60 580 230" />

<line x1="340" y1="250" x2="340" y2="80" stroke="var(--t)" stroke-width="0.5" stroke-dasharray="3 3" />
<circle cx="340" cy="80" r="4" fill="#D85A30" />
<text class="th" x="340" y="35" text-anchor="middle" fill="#993C1D">MLE: theta-hat (svg_diagram)</text>
</svg>

[Inference] This diagram illustrates the general conceptual shape of a log-likelihood function reaching a maximum at the MLE. It does not represent a specific empirical dataset.

### Properties of Maximum Likelihood Estimators

**Key Points**

- MLEs are commonly described in statistical literature as consistent under standard regularity conditions, meaning they converge to the true parameter value as $n \to \infty$ [Unverified: I cannot confirm the precise regularity conditions required without a specific cited source]
- MLEs are commonly described as asymptotically efficient, meaning that as $n \to \infty$, their variance approaches the theoretical minimum described by the Cramér–Rao lower bound [Unverified: I cannot confirm the precise regularity conditions required without a specific cited source]
- MLEs are commonly described as asymptotically normally distributed, which underlies the use of normal-based confidence intervals for MLE parameter estimates in large samples [Unverified: I cannot confirm the precise formal statement without a specific cited source]
- MLEs are not guaranteed to be unbiased at finite sample sizes, as shown in the variance example above [Inference]
- MLEs possess the **invariance property**: if $\hat{\theta}_{MLE}$ is the MLE of $\theta$, then $g(\hat{\theta}_{MLE})$ is the MLE of $g(\theta)$ for any function $g$ [Unverified: I cannot confirm the precise formal statement or conditions on $g$ without a specific cited source]

I cannot verify that all of these properties hold identically across every distribution and model specification; regularity conditions vary and I do not have access to a comprehensive cited source confirming universal applicability. [Unverified]

### Maximum Likelihood Estimation vs. Method of Moments

| Aspect | Maximum Likelihood Estimation | Method of Moments |
|---|---|---|
| Basis of estimation | Maximizing the likelihood of observed data | Equating sample and population moments |
| Computational complexity | Can require iterative numerical optimization for complex models [Inference] | Often simpler, closed-form solutions in many cases [Inference] |
| Asymptotic efficiency | Commonly described as asymptotically efficient under regularity conditions [Unverified] | Not generally guaranteed to be efficient [Unverified] |
| Use of full distributional assumption | Requires specifying the full probability distribution | Requires only the specific moments used, not the full distribution [Inference] |

I cannot verify that this comparison table reflects a universally agreed-upon characterization across all statistical literature; specific properties can vary by distribution and estimation context. [Unverified]

### Numerical Optimization for MLE

**Key Points**

- When a closed-form analytical solution is not available, MLE parameters are commonly found using iterative numerical optimization algorithms, such as gradient-based methods or the Newton-Raphson method [Unverified: I cannot confirm which specific algorithms are considered standard across all applications without a cited source]
- The **Expectation-Maximization (EM) algorithm** is commonly cited as a specialized iterative technique for finding MLEs in models involving latent or unobserved variables, such as mixture models [Unverified: I cannot confirm the precise formal description or convergence properties without a specific cited source]
- I cannot verify that numerical optimization methods always converge to the global maximum of the likelihood function rather than a local maximum, as this depends on the shape of the likelihood surface and the specific optimization algorithm used [Unverified]

### Relevance to Machine Learning

**Key Points**

- Many common loss functions used in training machine learning models can be derived from a maximum likelihood framework under specific distributional assumptions about the errors or outcomes [Unverified: the specific theoretical connection depends on model assumptions I cannot verify apply universally]
- Minimizing squared error loss in linear regression is commonly connected to maximum likelihood estimation under the assumption that errors are normally distributed [Unverified: I cannot confirm the precise conditions or derivation without a specific cited source]
- Minimizing cross-entropy loss in classification models is commonly connected to maximum likelihood estimation under a categorical or Bernoulli distribution assumption for the outcome variable [Unverified: I cannot confirm the precise conditions or derivation without a specific cited source]
- Logistic regression coefficients are commonly estimated via maximum likelihood estimation rather than a closed-form formula, typically requiring iterative numerical optimization [Unverified: I cannot confirm this is universally the estimation method used across all software implementations without a specific cited source]

**Disclaimer regarding LLM/model behavior claims:** Any statements above relating to machine learning model training, loss functions, or optimization behavior are labeled [Inference] or [Unverified] and are not guaranteed; actual behavior may vary depending on model architecture, implementation, data characteristics, and other context-specific factors.

### Limitations and Considerations

**Key Points**

- MLE requires specifying a full probability distribution for the data-generating process; if this distributional assumption is incorrect, the resulting estimates may be inaccurate or misleading [Inference]
- MLE can be sensitive to outliers, depending on the assumed distribution, since extreme observations can substantially affect the likelihood function [Unverified: the degree of sensitivity depends on the specific distribution assumed and is not something I can generalize without a cited source]
- For some models, the likelihood function may have multiple local maxima, making it possible for numerical optimization to converge to a suboptimal solution rather than the true global maximum [Unverified: I cannot confirm how frequently this occurs across different model types without a cited source]
- I cannot verify that MLE is universally considered the preferred estimation method over all alternatives (such as method of moments or Bayesian estimation) in every applied context; the appropriate choice depends on the specific goals, computational constraints, and assumptions of the analysis [Unverified]

I cannot verify that this list of limitations is exhaustive across all statistical and machine learning literature.

### Related Topics

- Estimators and estimands
- Method of moments
- Bias of an estimator
- Consistency of estimators
- Efficiency of estimators
- Loss functions in machine learning
- Logistic regression
- Expectation-Maximization algorithm

> Correction disclaimer (per stated preferences): This response contains multiple [Inference] and [Unverified]-labeled claims throughout, as many statements regarding regularity conditions, formal theorems, and machine learning applications could not be independently confirmed against a specific cited source within this conversation. All claims regarding LLM or model behavior are not guaranteed and may vary depending on implementation, data, and context. No part of this response should be read as a confirmed fact unless explicitly stated as a standard mathematical definition or formula.