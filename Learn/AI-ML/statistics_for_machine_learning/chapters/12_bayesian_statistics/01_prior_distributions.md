## Prior Distributions

### Overview

A prior distribution represents the probability distribution assigned to a parameter before observing data, encoding existing beliefs, assumptions, or knowledge about that parameter's plausible values. Priors are a foundational component of Bayesian inference, where they are combined with the likelihood of observed data to produce a posterior distribution. In machine learning, priors appear in Bayesian models, regularization interpretations of standard ML algorithms, and probabilistic graphical models.

### Role in Bayesian Inference

Bayesian inference combines a prior distribution with observed data through Bayes' theorem to produce an updated (posterior) belief about a parameter.

$$P(\theta \mid D) = \frac{P(D \mid \theta) \, P(\theta)}{P(D)}$$

where:

- $P(\theta)$ is the prior distribution over parameter $\theta$
- $P(D \mid \theta)$ is the likelihood of the observed data given $\theta$
- $P(\theta \mid D)$ is the posterior distribution
- $P(D)$ is the marginal likelihood (evidence), acting as a normalizing constant

The prior directly influences the posterior, with its relative influence depending on the amount and informativeness of the observed data. As the amount of data grows large, the posterior generally becomes increasingly dominated by the likelihood, reducing the relative influence of the prior. [Inference — this is a widely stated asymptotic property of Bayesian updating in statistical literature, not verified against a specific source in this conversation]

### Types of Priors

- **Informative prior**: encodes substantial existing knowledge or strong belief about the parameter, expressed as a concentrated distribution
- **Weakly informative prior**: provides some regularization or plausible bounds without strongly dictating the outcome
- **Uninformative (diffuse) prior**: intended to have minimal influence on the posterior, letting the data dominate the inference
- **Non-informative prior**: closely related to uninformative priors; can include improper priors that do not integrate to 1 but sometimes still yield valid (proper) posteriors
- **Conjugate prior**: a prior chosen such that the resulting posterior belongs to the same distributional family as the prior, simplifying computation
- **Subjective prior**: explicitly derived from expert judgment or domain knowledge rather than a general default rule [Inference — this is a commonly used descriptive category in Bayesian statistics discussions; not confirmed against a specific source in this conversation]

### Conjugate Priors

A conjugate prior, when combined with a specific likelihood function, produces a posterior distribution from the same family as the prior. This property allows closed-form updating without numerical integration.

**Common conjugate pairs:**

| Likelihood | Conjugate Prior | Posterior |
| --- | --- | --- |
| Bernoulli / Binomial | Beta | Beta |
| Poisson | Gamma | Gamma |
| Normal (known variance) | Normal | Normal |
| Normal (unknown variance) | Normal-Inverse-Gamma | Normal-Inverse-Gamma |
| Multinomial | Dirichlet | Dirichlet |
| Exponential | Gamma | Gamma |

### Worked Example — Beta-Binomial Conjugacy

For a binary outcome (e.g., click/no-click) modeled as a Bernoulli process with unknown success probability $\theta$, a Beta prior is conjugate:

$$\theta \sim \text{Beta}(\alpha, \beta)$$

Given $x$ successes out of $n$ trials, the posterior is:

$$\theta \mid x \sim \text{Beta}(\alpha + x, \beta + n - x)$$

**Numeric example:** Suppose a prior belief is expressed as $\text{Beta}(2, 2)$ (a weakly informative prior centered at 0.5), and 8 successes are observed out of 20 trials.

$$\text{Posterior} = \text{Beta}(2+8,\ 2+20-8) = \text{Beta}(10, 14)$$

The posterior mean is:

$$E[\theta \mid x] = \frac{\alpha_{post}}{\alpha_{post}+\beta_{post}} = \frac{10}{24} \approx 0.417$$

This value follows directly from the standard formula for the mean of a Beta distribution applied to the stated posterior parameters, not from an estimate.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 340">
<text x="310" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Beta prior updating to posterior (svg_diagram)</text>
<line x1="60" y1="280" x2="580" y2="280" stroke="#333" stroke-width="1.5" />
<line x1="60" y1="280" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
<text x="320" y="310" text-anchor="middle" font-size="12" fill="#333">theta (probability of success)</text>
<path d="M 60 250 Q 200 60 320 60 Q 440 60 580 250" fill="none" stroke="#2563eb" stroke-width="2.5" />
<text x="150" y="90" font-size="12" fill="#2563eb" font-weight="bold">Prior: Beta(2,2)</text>
<path d="M 60 280 Q 240 270 300 90 Q 360 270 580 280" fill="none" stroke="#dc2626" stroke-width="2.5" />
<text x="380" y="120" font-size="12" fill="#dc2626" font-weight="bold">Posterior: Beta(10,14)</text>
<line x1="320" y1="280" x2="320" y2="290" stroke="#333" stroke-width="1" />
<text x="320" y="303" text-anchor="middle" font-size="10" fill="#333">0.5</text>
</svg>

### Uninformative and Reference Priors

**Uniform prior**: assigns equal probability density across the plausible range of the parameter, intended to express no strong preference among values.

**Jeffreys prior**: a specific type of non-informative prior constructed to be invariant under reparameterization of the parameter, derived from the Fisher information of the model. [Inference — this is the standard definition given in Bayesian statistics literature; not verified against a specific source in this conversation]

**Improper priors**: priors that do not integrate to a finite value (e.g., a uniform distribution over all real numbers) but can still, in some cases, yield a proper (valid, integrable) posterior once combined with the likelihood. Improper priors require care, since not all combinations of improper prior and likelihood yield a valid posterior. [Inference]

### Priors as Regularization in Machine Learning

Several standard machine learning regularization techniques have a direct interpretation as imposing specific priors within a Bayesian framework, when the corresponding estimation procedure is framed as Maximum a Posteriori (MAP) estimation rather than pure maximum likelihood estimation.

| ML Regularization | Equivalent Prior (Bayesian view) |
| --- | --- |
| L2 regularization (Ridge) | Gaussian (Normal) prior on weights |
| L1 regularization (Lasso) | Laplace prior on weights |
| Elastic Net | Combination of Gaussian and Laplace priors |

This equivalence holds under the specific framing of regularized loss minimization as MAP estimation; it does not imply that all regularization techniques used in practice are explicitly derived from or interpreted through this Bayesian lens in every implementation. [Inference — this is a widely cited theoretical connection in statistical learning theory, not verified against a specific source in this conversation]

### Sensitivity to Prior Choice

The influence of the prior on the posterior depends on:

- **Prior informativeness**: highly concentrated priors exert more influence than diffuse ones
- **Sample size**: larger datasets generally reduce the relative influence of the prior [Inference]
- **Alignment between prior and data**: priors that conflict strongly with the observed data can pull the posterior toward implausible regions if the prior is highly informative and the data is limited [Inference]

Sensitivity analysis — examining how posterior conclusions change under different reasonable prior choices — is commonly recommended as part of Bayesian modeling practice. [Inference — this is standard methodological guidance found in Bayesian statistics literature; not verified against a specific source in this conversation]

### Python Implementation Example

```python
import numpy as np
from scipy import stats

# Beta-Binomial conjugate updating
alpha_prior, beta_prior = 2, 2
successes, trials = 8, 20

alpha_post = alpha_prior + successes
beta_post = beta_prior + (trials - successes)

posterior_mean = alpha_post / (alpha_post + beta_post)
posterior_dist = stats.beta(alpha_post, beta_post)

print(f"Posterior mean: {posterior_mean:.4f}")
print(f"95% credible interval: {posterior_dist.interval(0.95)}")
```

I have not executed this code, so I cannot verify its exact printed output. [Unverified] Behavior may also vary depending on the installed version of `scipy`. [Inference]

### Priors in Machine Learning Model Contexts

- **Bayesian linear/logistic regression**: priors placed on coefficients act as regularizers and allow uncertainty quantification over parameter estimates
- **Bayesian neural networks**: priors are placed over network weights, though exact posterior inference is generally computationally intractable for large networks and typically requires approximation methods (e.g., variational inference, Markov Chain Monte Carlo) [Inference]
- **Naive Bayes classifiers**: priors represent the marginal class probabilities, estimated from training data frequencies or set based on domain knowledge
- **Hierarchical Bayesian models**: priors themselves can have their own distributions (hyperpriors), allowing information sharing across related groups or parameters [Inference — general description of hierarchical Bayesian model structure; not tied to a specific source in this conversation]
- **Gaussian processes**: the prior is placed directly over functions, defined by a mean function and covariance (kernel) function [Inference]

### Prior vs. Posterior vs. Likelihood — Conceptual Distinction

| Term | Represents |
| --- | --- |
| Prior | Belief about parameter before observing data |
| Likelihood | Probability of observed data given a specific parameter value |
| Posterior | Updated belief about parameter after observing data |
| Evidence (marginal likelihood) | Overall probability of the data, integrated over all parameter values |

### Criticisms and Debate

The choice and use of priors is a subject of ongoing methodological discussion. Frequentist critiques of Bayesian methods sometimes center on the perceived subjectivity of prior selection and its potential to influence conclusions independently of the observed data. Bayesian responses often emphasize that prior choice can be made transparent, justified by domain knowledge, and tested for sensitivity, and that all statistical modeling involves assumptions of some kind. [Inference — this reflects a commonly described tension in the general statistics literature between frequentist and Bayesian philosophies; not verified against a specific source in this conversation] This dispute is presented here for informational balance and does not represent an endorsement of either position.

### **Key Points**

- A prior distribution encodes belief about a parameter before observing data and combines with the likelihood via Bayes' theorem to form the posterior
- Conjugate priors simplify computation by keeping the posterior in the same distributional family as the prior
- Common ML regularization techniques (L1, L2) correspond to specific priors under a MAP estimation framing [Inference]
- Prior influence on the posterior generally diminishes as sample size increases [Inference]
- Prior selection remains a debated methodological topic, particularly regarding subjectivity and sensitivity of conclusions [Inference]

### **Related Topics**

- Bayes' theorem and posterior distributions
- Maximum a Posteriori (MAP) estimation vs. Maximum Likelihood Estimation (MLE)
- Conjugate prior families (Beta-Binomial, Gamma-Poisson, Normal-Normal)
- Markov Chain Monte Carlo (MCMC) methods
- Variational inference
- Bayesian neural networks
- Credible intervals vs. confidence intervals
- Hierarchical Bayesian models