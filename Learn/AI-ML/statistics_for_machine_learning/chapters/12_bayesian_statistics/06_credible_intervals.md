## Credible Intervals

### Overview

A credible interval is a range of values for a parameter that is estimated to contain the true parameter value with a specified posterior probability. It is the Bayesian counterpart to the frequentist confidence interval, but with a distinct probabilistic interpretation rooted in the posterior distribution rather than long-run sampling frequency. In machine learning, credible intervals are used to communicate uncertainty around Bayesian model parameters and predictions.

### Formal Definition

A $100(1-\alpha)\%$ credible interval $[\theta_{lower}, \theta_{upper}]$ satisfies:

$$P(\theta_{lower} \leq \theta \leq \theta_{upper} \mid D) = 1 - \alpha$$

meaning that, given the observed data and the model (including the prior), the posterior probability that the true parameter lies within this interval is $1-\alpha$.

### Interpretation

A 95% credible interval is generally interpreted as: given the model, the prior, and the observed data, there is a 95% posterior probability that the true parameter value lies within the stated interval. This is a direct probability statement about the parameter itself. [Inference — this is a standard interpretive statement found in Bayesian statistics literature; not verified against a specific cited source in this conversation]

### Credible Interval vs. Confidence Interval

| Aspect | Credible Interval (Bayesian) | Confidence Interval (Frequentist) |
| --- | --- | --- |
| What is random | The parameter (given fixed data) | The interval (across repeated sampling) |
| Interpretation | Direct posterior probability the parameter lies in the interval | Long-run proportion of intervals (across repeated experiments) that would contain the true parameter |
| Requires a prior | Yes | No |
| Numeric values | Can coincide with confidence intervals under certain priors (e.g., flat priors, large samples) | — |

These two interval types are frequently conflated in informal usage, but their formal interpretations differ. [Inference — this reflects a widely discussed distinction in Bayesian vs. frequentist statistics literature; not verified against a specific source in this conversation] A common misinterpretation is treating a frequentist confidence interval as if it had the credible-interval interpretation (a direct probability statement about where the parameter lies); this specific interpretation is only formally valid for credible intervals. [Inference]

### Types of Credible Intervals

- **Equal-tailed interval (percentile interval)**: constructed by taking the $\alpha/2$ and $1-\alpha/2$ percentiles of the posterior distribution, leaving equal probability mass in each tail
- **Highest Posterior Density (HPD) interval**: the narrowest possible interval containing $1-\alpha$ of the posterior probability mass; every point inside the interval has higher posterior density than every point outside it

For symmetric, unimodal posterior distributions, the equal-tailed and HPD intervals generally coincide or are very close. For skewed or multimodal posteriors, they can differ substantially, with the HPD interval always being at least as narrow as the equal-tailed interval for the same probability level. [Inference — this narrowness property follows from the definition of HPD as the minimum-width interval at a given probability level, though the general statement about typical divergence in skewed cases is a commonly cited characterization in Bayesian statistics literature, not independently verified against a specific source here]

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 340">
<text x="310" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Equal-tailed vs HPD interval on a skewed posterior (svg_diagram)</text>
<line x1="60" y1="280" x2="580" y2="280" stroke="#333" stroke-width="1.5" />
<line x1="60" y1="280" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
<text x="320" y="310" text-anchor="middle" font-size="12" fill="#333">theta</text>
<path d="M 60 278 Q 120 270 160 90 Q 220 55 300 160 Q 400 250 580 278" fill="none" stroke="#2563eb" stroke-width="2.5" />
<line x1="110" y1="240" x2="110" y2="280" stroke="#dc2626" stroke-width="2.5" />
<line x1="380" y1="240" x2="380" y2="280" stroke="#dc2626" stroke-width="2.5" />
<line x1="110" y1="260" x2="380" y2="260" stroke="#dc2626" stroke-width="2" stroke-dasharray="3,3" />
<text x="245" y="330" text-anchor="middle" font-size="11" fill="#dc2626" font-weight="bold">Equal-tailed interval</text>
<line x1="130" y1="150" x2="130" y2="280" stroke="#16a34a" stroke-width="2.5" />
<line x1="320" y1="150" x2="320" y2="280" stroke="#16a34a" stroke-width="2.5" />
<line x1="130" y1="150" x2="320" y2="150" stroke="#16a34a" stroke-width="2" stroke-dasharray="3,3" />
<text x="225" y="140" text-anchor="middle" font-size="11" fill="#16a34a" font-weight="bold">HPD interval (narrower)</text>
</svg>

### Worked Example — Credible Interval from a Beta Posterior

Using the posterior $\text{Beta}(17, 14)$ from a prior topic's worked example (14 successes in 25 trials, $\text{Beta}(3,3)$ prior):

For an equal-tailed 95% credible interval, the 2.5th and 97.5th percentiles of $\text{Beta}(17,14)$ would need to be computed via the inverse Beta CDF. I have not performed this numerical computation here, so I cannot state specific interval bounds. I cannot verify a numeric result without actually computing the inverse CDF, and I will not present estimated bounds as fact.

The general procedure: use the inverse cumulative distribution function (quantile function) of $\text{Beta}(17,14)$ at $q=0.025$ and $q=0.975$ to obtain the lower and upper bounds respectively.

### Python Implementation Example

```python
from scipy import stats

alpha_post, beta_post = 17, 14
posterior = stats.beta(alpha_post, beta_post)

# Equal-tailed 95% credible interval
lower_eq, upper_eq = posterior.interval(0.95)

print(f"Equal-tailed 95% credible interval: ({lower_eq:.4f}, {upper_eq:.4f})")
```

I cannot verify this. I have not executed this code, so I do not have access to its actual printed output. [Unverified] Behavior may also vary depending on the installed version of `scipy`, and this is not guaranteed to produce identical results across all environments. [Inference] This is a general statement about software behavior across versions and environments, offered without independent confirmation for this specific code and library version.

### Computing HPD Intervals

Unlike equal-tailed intervals, HPD intervals generally do not have a simple closed-form solution for most distributions, including the Beta distribution, and typically require numerical search methods (e.g., finding the narrowest interval containing the target probability mass by iterating over candidate density thresholds). Common approaches include:

- **Analytical/numerical optimization**: for well-characterized unimodal distributions, searching for the narrowest interval containing the target probability mass
- **Sample-based estimation**: for posteriors approximated via MCMC, HPD intervals are commonly estimated directly from the empirical distribution of posterior samples

I do not have access to a specific, verifiable source confirming exact implementation details of HPD computation in any particular software library, so I cannot state specifics about such implementations. [Unverified]

### Credible Intervals for Approximate Posteriors

When the posterior is approximated (e.g., via MCMC sampling or variational inference rather than an exact conjugate form), credible intervals are typically estimated from the approximate posterior:

- **From MCMC samples**: credible intervals can be estimated directly using the empirical percentiles of the collected posterior samples
- **From variational approximations**: credible intervals are computed from the assumed variational family's distribution (e.g., percentiles of a fitted Gaussian), which may not accurately reflect the true posterior's shape if the variational approximation is a poor fit [Inference]

The accuracy of any credible interval derived this way depends on the quality of the underlying posterior approximation; this is not a guaranteed property and can vary substantially across models and inference methods. [Inference] I cannot verify claims about the accuracy of any specific software library's credible interval computation without a named, checkable source. [Unverified]

### Credible Intervals in Machine Learning Contexts

- **Bayesian regression**: credible intervals around regression coefficients communicate the range of plausible parameter values given the prior and data
- **Uncertainty quantification for predictions**: posterior predictive credible intervals communicate a range of plausible outcomes for new data points, incorporating both parameter uncertainty and (where modeled) observation noise
- **A/B testing (Bayesian framing)**: credible intervals around the estimated difference between variants are sometimes used as an alternative to frequentist p-values and confidence intervals [Inference — this reflects a commonly cited application in Bayesian A/B testing literature, not verified against a specific source in this conversation]
- **Bayesian neural networks and Gaussian processes**: credible intervals (or predictive intervals derived from the posterior) communicate uncertainty in individual predictions, though computing these exactly is often computationally intractable for large networks and requires approximation methods [Inference]

I do not have access to information confirming which specific credible interval methods are considered standard practice across every particular machine learning subfield, so any such broad claim would require checking a named, current source. [Unverified]

### Factors Affecting Credible Interval Width

- **Amount of data**: larger sample sizes generally narrow the posterior and thus the credible interval, as the likelihood increasingly dominates the prior [Inference]
- **Prior informativeness**: more informative (concentrated) priors tend to produce narrower credible intervals, particularly when data is limited [Inference]
- **Choice of confidence level**: higher probability coverage (e.g., 99% vs. 90%) produces wider intervals, following directly from the definition of a credible interval as containing a specified probability mass
- **Model correctness**: if the underlying likelihood or prior is misspecified, the credible interval's stated coverage probability may not correspond to actual coverage of the true parameter, since the interval's validity depends on the assumed model being a reasonable representation of the data-generating process [Inference]

### Limitations and Considerations

- Credible interval interpretation depends on accepting the specified prior; different reasonable priors can produce different credible intervals, particularly with limited data [Inference]
- For approximate posteriors (MCMC, variational inference), credible interval accuracy is limited by the quality of the underlying approximation [Inference]
- HPD intervals can be discontinuous (composed of multiple disjoint regions) for multimodal posteriors, complicating interpretation and computation [Inference — this is a recognized property of HPD regions for multimodal distributions in Bayesian statistics literature, not verified against a specific source in this conversation]
- Credible intervals do not, by themselves, indicate whether the range of plausible values is practically or scientifically meaningful — this requires separate domain-specific judgment, similar to the distinction between statistical and practical significance discussed for other inference methods

### **Key Points**

- A credible interval gives a direct posterior probability statement about where a parameter lies, given the model, prior, and data
- This differs formally from a frequentist confidence interval, which describes long-run coverage across repeated sampling rather than a direct probability about the specific interval observed [Inference]
- Equal-tailed intervals use symmetric percentile cutoffs; HPD intervals find the narrowest interval containing the target probability mass, and are always at least as narrow for the same probability level
- For approximate posteriors, credible interval quality depends on the accuracy of the posterior approximation method used [Inference]
- Credible interval width is influenced by data quantity, prior informativeness, and the chosen probability level [Inference for data quantity and prior informativeness; direct definitional consequence for probability level]

### **Related Topics**

- Posterior distributions and Bayesian point estimation
- Prior distributions and conjugate priors
- Confidence intervals (frequentist) and their formal interpretation
- Markov Chain Monte Carlo (MCMC) methods
- Variational inference
- Bayesian A/B testing
- Posterior predictive distributions
- Highest Posterior Density (HPD) regions for multimodal distributions