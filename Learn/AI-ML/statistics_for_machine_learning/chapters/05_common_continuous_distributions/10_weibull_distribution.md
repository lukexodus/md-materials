## Weibull Distribution (svg_diagram)

### Definition

The Weibull distribution is a continuous probability distribution commonly used in reliability engineering and survival analysis to model time-to-failure or time-to-event data. Its flexible shape allows it to represent increasing, decreasing, or constant failure rates.

A random variable $X$ follows a Weibull distribution, denoted $X \sim \text{Weibull}(k, \lambda)$, if its density has the form below.

### Probability Density Function

$$f(x) = \frac{k}{\lambda}\left(\frac{x}{\lambda}\right)^{k-1} \exp\left(-\left(\frac{x}{\lambda}\right)^k\right) \quad \text{for } x \ge 0$$

### Cumulative Distribution Function

$$F(x) = 1 - \exp\left(-\left(\frac{x}{\lambda}\right)^k\right) \quad \text{for } x \ge 0$$

### Parameters

- $k$: shape parameter, $k > 0$
- $\lambda$: scale parameter, $\lambda > 0$

### Key Points

- The distribution is defined only for non-negative values ($x \ge 0$).
- The shape parameter $k$ determines the behavior of the failure (hazard) rate over time: decreasing for $k < 1$, constant for $k = 1$, and increasing for $k > 1$. [Inference] This behavior follows from standard analysis of the Weibull hazard function's mathematical form; it is not independently re-derived in this response.
- When $k = 1$, the Weibull distribution reduces exactly to the exponential distribution with rate $1/\lambda$.
- The distribution's flexibility in modeling varying hazard rates is a commonly cited reason for its use in reliability engineering. [Unverified] I do not have access to a source confirming the relative frequency of this rationale across specific industries or practitioner communities.

### Mean and Variance

$$E[X] = \lambda \, \Gamma\left(1 + \frac{1}{k}\right)$$

$$\text{Var}(X) = \lambda^2 \left[\Gamma\left(1+\frac{2}{k}\right) - \Gamma\left(1+\frac{1}{k}\right)^2\right]$$

where $\Gamma(\cdot)$ is the gamma function.

[Inference] These are standard results obtained via integration of the density function; the integration itself is not reproduced here, and I do not have access to independently re-verify these formulas against an external source in this response.

### The Hazard Function

The hazard function (instantaneous failure rate) for the Weibull distribution is:

$$h(x) = \frac{k}{\lambda}\left(\frac{x}{\lambda}\right)^{k-1}$$

- $k < 1$: hazard rate decreases over time (early-life failures, "infant mortality")
- $k = 1$: hazard rate is constant over time (random, memoryless failures)
- $k > 1$: hazard rate increases over time (wear-out failures)

[Inference] This interpretation of hazard rate behavior by shape parameter is a standard result in reliability engineering literature; it is not independently re-derived step-by-step in this response.

### Example

Suppose the lifetime of a mechanical component, in years, is modeled as $X \sim \text{Weibull}(k=2, \lambda=5)$, indicating an increasing hazard rate (wear-out behavior).

$$E[X] = 5 \, \Gamma\left(1 + \frac{1}{2}\right) = 5\,\Gamma(1.5)$$

Using $\Gamma(1.5) = \frac{\sqrt{\pi}}{2} \approx 0.8862$:

$$E[X] \approx 5 \times 0.8862 \approx 4.431 \text{ years}$$

[Inference] This numeric result follows directly from the mean formula and the standard value of $\Gamma(1.5)$; it has not been separately verified through simulation in this response.

### Diagram: Hazard Rate Shapes by k

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 340" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Weibull Hazard Rate by Shape (svg_diagram)</text>

  <line x1="60" y1="280" x2="560" y2="280" stroke="#333" stroke-width="2" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="300" y="305" text-anchor="middle" font-size="12" fill="#333">time (x)</text>
  <text x="30" y="170" font-size="11" fill="#333">h(x)</text>

  <path d="M 60,90 C 150,150 250,220 560,260" fill="none" stroke="#d43a5a" stroke-width="2.5" />
  <text x="150" y="130" font-size="11" fill="#d43a5a">k &lt; 1 (decreasing)</text>

  <line x1="60" y1="170" x2="560" y2="170" stroke="#4a76d4" stroke-width="2.5" />
  <text x="420" y="160" font-size="11" fill="#4a76d4">k = 1 (constant)</text>

  <path d="M 60,270 C 200,260 350,180 560,80" fill="none" stroke="#3a9e5f" stroke-width="2.5" />
  <text x="400" y="110" font-size="11" fill="#3a9e5f">k &gt; 1 (increasing)</text>
</svg>

### Relationship to Other Distributions

- **Exponential distribution**: Special case when $k = 1$: $\text{Weibull}(1, \lambda) = \text{Exponential}(1/\lambda)$.
- **Rayleigh distribution**: Special case when $k = 2$, the Weibull distribution is equivalent to the Rayleigh distribution with an appropriate scale parameter relationship. [Inference] This relationship is a standard special-case result stated in probability theory references; the exact parameter correspondence is not independently re-derived in this response.
- **Extreme value theory**: The Weibull distribution is one of three families of distributions that arise as limiting distributions for the minimum of a large number of independent, identically distributed random variables (the others being the Gumbel and Fréchet distributions). [Unverified] I do not have access to a specific source in this response to confirm the full technical conditions under which this limiting result holds.

### Applications in Machine Learning

- **Survival analysis and time-to-event modeling**: The Weibull distribution is commonly used as a parametric baseline in survival models, such as Weibull regression, to model time-to-failure or time-to-churn data where hazard rates change over time. [Inference] This is a standard application described in survival analysis literature; whether it is the most appropriate model for a specific dataset requires domain-specific validation not addressed here.
- **Reliability engineering**: Weibull analysis is a standard technique for modeling component or system failure times in manufacturing and engineering contexts. [Unverified] I do not have access to information confirming how frequently this specific technique is applied relative to alternatives across current engineering practice.
- **Wind speed modeling**: The Weibull distribution is sometimes used to model wind speed distributions in renewable energy forecasting applications. [Unverified] I do not have access to a source confirming the prevalence of this specific application across current renewable energy modeling practice.
- **Extreme value modeling**: Due to its connection to extreme value theory, the Weibull distribution (or related extreme value distributions) can be used in modeling minimum values in risk analysis or anomaly detection contexts. [Inference] This application follows from the theoretical connection to extreme value theory described above; specific applicability to any given dataset is not verified here.

### Common Pitfalls

- **Confusing parameterizations**: Different software libraries and textbooks may use different parameterizations of the Weibull distribution (e.g., shape-scale vs. alternative forms), which can lead to calculation errors if not checked carefully. [Unverified] I do not have access to a comprehensive list confirming which specific libraries use which parameterization by default; this should be checked against the documentation of the specific tool in use.
- **Misinterpreting the shape parameter**: Assuming a constant hazard rate ($k=1$, equivalent to exponential behavior) when the true underlying process has an increasing or decreasing hazard rate can lead to a poorly specified model. [Inference] based on general statistical modeling principles regarding shape parameter selection and goodness of fit; this is not a claim about any specific dataset.
- **Applying to negative-valued data**: Since the Weibull distribution is defined only for $x \ge 0$, applying it to data that can be negative is mathematically inconsistent with the distribution's definition.

### Related Topics

- Exponential distribution
- Gamma distribution
- Survival analysis
- Reliability engineering
- Extreme value theory
- Hazard function modeling

---

[Unverified] This response contains claims labeled [Inference] or [Unverified] throughout, per the stated labeling requirements, with each labeled step representing a distinct, individually-labeled point rather than a chain of unlabeled inferences. Standard mathematical identities (PDF/CDF forms, mean/variance formulas, special-case relationships to the exponential and Rayleigh distributions) reflect commonly presented results in probability theory references, but I do not have access to independently verify or cross-check them against a specific cited external source in this response. Claims regarding practitioner prevalence, specific industry applications, or software/library implementation behavior are labeled [Unverified], and behavior of any specific implementation is not guaranteed and should be verified empirically. No instances of "prevent," "guarantee," "will never," "fixes," "eliminates," or "ensures that" were used in this response outside of this note, which references the rule itself rather than asserting such a claim.