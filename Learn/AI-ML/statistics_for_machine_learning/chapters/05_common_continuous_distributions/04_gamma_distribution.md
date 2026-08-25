## Gamma Distribution (svg_diagram)

### Definition

The gamma distribution is a continuous probability distribution defined over non-negative real numbers, commonly used to model waiting times, sums of exponential processes, and skewed positive-valued data. It generalizes several other distributions, including the exponential and chi-square distributions.

A random variable $X$ follows a gamma distribution, denoted $X \sim \text{Gamma}(k, \theta)$ or $X \sim \text{Gamma}(\alpha, \beta)$ depending on parameterization, if its density has the form below.

### Probability Density Function

Using shape-rate parameterization ($\alpha$ = shape, $\beta$ = rate):

$$f(x) = \frac{\beta^\alpha}{\Gamma(\alpha)} x^{\alpha-1} e^{-\beta x} \quad \text{for } x > 0$$

where $\Gamma(\alpha)$ is the gamma function, an extension of the factorial function to real and complex arguments.

[Unverified] Multiple parameterizations of the gamma distribution exist in statistical literature (shape-rate vs. shape-scale); I do not have access to a definitive source confirming which is more prevalent across all fields, so no claim is made about which is "standard."

### Alternate Parameterization (Shape-Scale)

Using shape-scale parameterization ($k$ = shape, $\theta$ = scale, where $\theta = 1/\beta$):

$$f(x) = \frac{1}{\Gamma(k)\theta^k} x^{k-1} e^{-x/\theta} \quad \text{for } x > 0$$

### Parameters

- $\alpha$ or $k$: shape parameter, $\alpha > 0$
- $\beta$: rate parameter, $\beta > 0$ (shape-rate form)
- $\theta$: scale parameter, $\theta > 0$, where $\theta = 1/\beta$ (shape-scale form)

### Key Points

- The gamma distribution is defined only for positive values ($x > 0$).
- Its shape depends heavily on the value of $\alpha$: for $\alpha < 1$ the density is unbounded near zero, for $\alpha = 1$ it reduces to the exponential distribution, and for $\alpha > 1$ it is unimodal with a peak away from zero. [Inference] This shape behavior follows from standard analysis of the gamma density function's form; it is not independently re-derived in this response.
- Two independent parameterizations (rate vs. scale) exist in different textbooks and software packages, which can lead to confusion if not checked carefully. [Unverified] I do not have access to information confirming which parameterization any specific software library uses by default.

### Mean and Variance

Using shape-rate parameterization:

$$E[X] = \frac{\alpha}{\beta}$$

$$\text{Var}(X) = \frac{\alpha}{\beta^2}$$

Using shape-scale parameterization:

$$E[X] = k\theta$$

$$\text{Var}(X) = k\theta^2$$

[Inference] These are standard results obtained via direct integration of the density function; the integration itself is not reproduced here, and I have not independently re-verified them against an external source in this response.

### Relationship to Exponential Distribution

When $\alpha = 1$ (or $k=1$), the gamma distribution reduces exactly to the exponential distribution with rate $\beta$:

$$\text{Gamma}(1, \beta) = \text{Exponential}(\beta)$$

More generally, the sum of $k$ independent and identically distributed exponential random variables, each with rate $\lambda$, follows a $\text{Gamma}(k, \lambda)$ distribution. [Inference] This is a standard theoretical result in probability theory regarding sums of independent exponential variables; the proof is not reproduced here.

### Example

Suppose the total time to complete 3 independent sequential tasks, each individually exponentially distributed with rate $\lambda = 2$ per hour, is modeled as $X \sim \text{Gamma}(3, 2)$ (shape-rate form).

$$E[X] = \frac{3}{2} = 1.5 \text{ hours}$$

$$\text{Var}(X) = \frac{3}{2^2} = 0.75$$

[Inference] These numeric results follow directly from the formulas above given the stated parameters; they have not been separately verified through simulation in this response.

### Diagram: PDF Shapes for Different Alpha Values

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 340" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Gamma Distribution Shapes (svg_diagram)</text>

  <line x1="60" y1="280" x2="560" y2="280" stroke="#333" stroke-width="2" />
  <line x1="60" y1="280" x2="60" y2="60" stroke="#333" stroke-width="2" />

  <text x="300" y="305" text-anchor="middle" font-size="12" fill="#333">x</text>

  <path d="M 60,90 C 90,150 130,220 200,255 C 280,278 400,280 560,280" fill="none" stroke="#d43a5a" stroke-width="2.5" />
  <text x="105" y="80" font-size="11" fill="#d43a5a">α &lt; 1</text>

  <path d="M 60,280 C 90,150 130,80 170,70 C 220,80 280,150 380,260 C 450,278 500,280 560,280" fill="none" stroke="#4a76d4" stroke-width="2.5" />
  <text x="180" y="60" font-size="11" fill="#4a76d4">α = 1 (exponential)</text>

  <path d="M 60,280 C 100,280 150,275 200,220 C 250,140 290,90 330,90 C 380,100 440,200 500,265 C 520,275 540,278 560,280" fill="none" stroke="#3a9e5f" stroke-width="2.5" />
  <text x="330" y="80" font-size="11" fill="#3a9e5f">α &gt; 1</text>

  <text x="300" y="320" text-anchor="middle" font-size="11" fill="#666">Shape varies with α; scale (β or θ) stretches/compresses horizontally</text>
</svg>

### Relationship to Other Distributions

- **Exponential distribution**: Special case when $\alpha = 1$ (shape-rate) or $k=1$ (shape-scale).
- **Chi-square distribution**: The chi-square distribution with $\nu$ degrees of freedom is a special case of the gamma distribution with $\alpha = \nu/2$ and $\beta = 1/2$ (shape-rate form). [Inference] This relationship is a standard result stated in probability theory references; it is not independently re-derived in this response.
- **Erlang distribution**: The Erlang distribution is a special case of the gamma distribution where the shape parameter $k$ is restricted to positive integers.
- **Poisson distribution**: The gamma distribution is the conjugate prior for the rate parameter $\lambda$ of a Poisson distribution in Bayesian inference. [Unverified] I do not have access to a source confirming how frequently this conjugacy relationship is applied in practice relative to other prior choices.
- **Beta distribution**: If $X \sim \text{Gamma}(\alpha, \theta)$ and $Y \sim \text{Gamma}(\beta, \theta)$ are independent, then $X/(X+Y)$ follows a Beta distribution with parameters $\alpha, \beta$. [Inference] This is a standard theoretical result in probability theory; the derivation is not reproduced here.

### Applications in Machine Learning

- **Bayesian inference (conjugate priors)**: The gamma distribution is commonly used as a conjugate prior for the precision (inverse variance) parameter in Bayesian normal models, and for rate parameters in Poisson models. [Unverified] I do not have access to information confirming how commonly this specific prior choice is used across practitioners relative to alternative priors.
- **Modeling waiting times and durations**: Gamma distributions are used to model skewed, positive-valued durations, such as time-to-event data in survival analysis, when a constant hazard rate assumption (as in the exponential case) is considered too restrictive. [Inference] This application is described in survival analysis literature; whether it fits any specific dataset requires domain-specific validation not addressed here.
- **Reliability and queuing models**: Component lifetimes and service times with non-constant failure/service rates are sometimes modeled using gamma distributions rather than the memoryless exponential distribution. [Unverified] I do not have access to information confirming how frequently this modeling choice is applied across specific industries.
- **Variance modeling in hierarchical models**: In Bayesian hierarchical models, gamma priors are sometimes placed on variance or precision parameters. [Unverified] I do not have access to a source confirming the prevalence of this practice relative to alternative approaches (e.g., half-Cauchy priors).

### Common Pitfalls

- **Parameterization confusion**: Mixing up rate ($\beta$) and scale ($\theta = 1/\beta$) parameterizations across different software libraries or textbooks can lead to significant calculation errors. [Unverified] I do not have access to a comprehensive list confirming which specific libraries use which parameterization by default; this should be checked against the documentation of the specific tool in use.
- **Misapplying to negative or zero data**: Since the gamma distribution is defined only for $x > 0$, applying it to data containing zero or negative values is mathematically inconsistent with the distribution's definition.
- **Assuming a fixed shape without justification**: Selecting $\alpha$ or $k$ arbitrarily without checking fit to data can produce a poorly specified model. [Inference] based on general statistical modeling principles regarding parameter selection and goodness of fit; this is not a claim about any specific dataset.

### Related Topics

- Exponential distribution
- Chi-square distribution
- Beta distribution
- Poisson distribution (as related conjugate prior context)
- Erlang distribution
- Bayesian conjugate priors

---

[Unverified] This entire response contains multiple claims labeled [Inference] or [Unverified] as specified. Standard mathematical identities (PDF forms, mean/variance formulas, special-case relationships) reflect commonly presented results in probability theory textbooks, but I have not independently re-derived or cross-checked them against a specific external source in this response. Claims about software library defaults, industry prevalence, or practitioner conventions are labeled [Unverified] because I do not have access to that information.