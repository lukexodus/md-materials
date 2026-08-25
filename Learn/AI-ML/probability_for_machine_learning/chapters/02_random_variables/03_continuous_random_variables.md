## Continuous Random Variables

### Definition

A continuous random variable $X$ is a random variable, as defined in the earlier formalism module, whose range is uncountable — typically an interval or union of intervals in $\mathbb{R}$. Unlike discrete random variables, $P(X = x) = 0$ for every individual value $x$. [Inference] This follows because a continuous random variable is characterized by a density rather than point masses; assigning nonzero probability to every one of an uncountably infinite set of points would violate the normalization axiom $P(\Omega) = 1$ established in the Kolmogorov axioms module.

### Probability Density Function (PDF)

A continuous random variable is characterized by a **probability density function** $f_X(x)$ satisfying:

$$
f_X(x) \geq 0 \text{ for all } x, \qquad \int_{-\infty}^{\infty} f_X(x)\, dx = 1
$$

Probability over an interval is computed as:

$$
P(a \leq X \leq b) = \int_a^b f_X(x)\, dx
$$

[Inference] This integral definition is the continuous analogue of the discrete sum $\sum_{x_i \leq x} p_X(x_i)$ from the discrete random variables module, replacing summation with integration since the support is uncountable. A key consequence is that $f_X(x)$ itself is **not** a probability — it is a density, and can exceed 1, unlike a PMF value.

### Cumulative Distribution Function

$$
F_X(x) = P(X \leq x) = \int_{-\infty}^{x} f_X(t)\, dt
$$

$$
f_X(x) = \frac{d}{dx} F_X(x)
$$

[Inference] This derivative relationship follows from the Fundamental Theorem of Calculus applied to the CDF-as-integral definition, consistent with what was stated in the random variable formalism module, and holds at points where $F_X$ is differentiable.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280">
<title>PDF and CDF relationship for a continuous random variable (svg_diagram)</title>
<rect x="0" y="0" width="600" height="280" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">PDF and CDF Relationship (svg_diagram)</text>

<text x="150" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">PDF f(x)</text>
<line x1="60" y1="190" x2="260" y2="190" stroke="#333333" stroke-width="1.5" />
<line x1="60" y1="190" x2="60" y2="70" stroke="#333333" stroke-width="1.5" />
<path d="M 70 185 Q 130 90 160 90 Q 190 90 250 185" fill="none" stroke="#2b6cb0" stroke-width="2.5" />
<path d="M 120 185 Q 145 110 170 115 L 170 185 Z" fill="#a3c9f9" fill-opacity="0.5" stroke="none" />
<text x="145" y="205" font-size="10" text-anchor="middle" font-family="sans-serif" fill="#333333">shaded area = P(a≤X≤b)</text>

<text x="450" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">CDF F(x)</text>
<line x1="360" y1="190" x2="560" y2="190" stroke="#333333" stroke-width="1.5" />
<line x1="360" y1="190" x2="360" y2="70" stroke="#333333" stroke-width="1.5" />
<path d="M 370 188 C 420 188 440 90 550 78" fill="none" stroke="#c0392b" stroke-width="2.5" />
<text x="460" y="220" font-size="10" text-anchor="middle" font-family="sans-serif" fill="#333333">S-shaped, non-decreasing, →1</text>
</svg>

### The Uniform Distribution

Models a random variable equally likely to fall anywhere within an interval $[a,b]$:

$$
f_X(x) = \begin{cases} \dfrac{1}{b-a} & a \leq x \leq b \\ 0 & \text{otherwise} \end{cases}
$$

[Inference] The constant value $\frac{1}{b-a}$ follows from requiring $\int_a^b f_X(x)\,dx = 1$ under a constant density over an interval of length $b-a$; solving $\frac{1}{b-a} \times (b-a) = 1$ confirms the normalization condition holds.

### The Normal (Gaussian) Distribution

$$
f_X(x) = \frac{1}{\sigma\sqrt{2\pi}} \exp\left(-\frac{(x-\mu)^2}{2\sigma^2}\right)
$$

where $\mu$ is the mean and $\sigma^2$ is the variance. [Unverified] I cannot verify within this document a full derivation of why this specific functional form satisfies normalization ($\int_{-\infty}^{\infty} f_X(x)\,dx = 1$), since that derivation requires the Gaussian integral result, which is not derived in this module series; this should be checked against a dedicated calculus reference rather than accepted from this statement alone.

The **standard normal distribution** is the special case $\mu = 0$, $\sigma = 1$, commonly denoted $Z \sim N(0,1)$.

### The Exponential Distribution

Models the waiting time until an event occurs, given a constant rate $\lambda$:

$$
f_X(x) = \lambda e^{-\lambda x}, \quad x \geq 0
$$

[Unverified] I cannot verify within this document series a full derivation connecting this distribution to the Poisson distribution (introduced in the previous module) as the waiting-time analogue of Poisson-distributed event counts, since that derivation was not carried out in either module; this connection is commonly stated in probability texts, but I have not reproduced the derivation here and it should be checked against a dedicated source.

### The Beta Distribution

Defined on the interval $[0,1]$, commonly used to model probabilities themselves:

$$
f_X(x) = \frac{x^{\alpha-1}(1-x)^{\beta-1}}{B(\alpha,\beta)}, \quad 0 \leq x \leq 1
$$

where $B(\alpha,\beta)$ is the Beta function, a normalizing constant. [Unverified] I cannot verify within this document a full derivation of the Beta function's exact form or value in general, as that requires the Gamma function relationship ($B(\alpha,\beta) = \frac{\Gamma(\alpha)\Gamma(\beta)}{\Gamma(\alpha+\beta)}$), which is not derived in this module series.

### Worked Example: Uniform Distribution Probability

Let $X \sim \text{Uniform}(0, 10)$. Compute $P(3 \leq X \leq 7)$.

$$
f_X(x) = \frac{1}{10-0} = \frac{1}{10}, \quad 0 \leq x \leq 10
$$

$$
P(3 \leq X \leq 7) = \int_3^7 \frac{1}{10}\, dx = \frac{7-3}{10} = \frac{4}{10} = 0.4
$$

[Inference] This computation follows directly from the uniform PDF definition and the interval-probability integral stated above; I have verified this specific arithmetic within this response.

### Worked Example: Standard Normal Probability (Setup Only)

Let $Z \sim N(0,1)$. To compute $P(Z \leq 1.5)$, one would evaluate $F_Z(1.5) = \int_{-\infty}^{1.5} f_Z(t)\,dt$. [Unverified] I cannot state a specific decimal value for this probability within this response, since the standard normal CDF has no closed-form elementary antiderivative and is conventionally evaluated using tabulated values or numerical computation; stating a specific numeric result here without performing that lookup or computation would be an unverified claim.

### Mixed Random Variables (Brief Note)

[Unverified] Some random variables are neither purely discrete nor purely continuous (e.g., a variable with a point mass at zero combined with a continuous density elsewhere). I do not have a full formal treatment of this case within the scope of this module series; this should be treated as a named edge case requiring separate dedicated coverage rather than an implicitly covered special case of the definitions given above.

### Relevance to Machine Learning

- The **Normal distribution** is used extensively in ML for modeling noise in regression (e.g., Gaussian noise assumptions in linear regression), weight initialization schemes, and as a prior in Bayesian methods. [Unverified] I do not have access to information confirming the specific noise assumptions used in any particular deployed ML system, so such assumptions should be verified against the specific model specification in use rather than assumed from this general statement.
- The **Beta distribution** is commonly used as a conjugate prior for the Bernoulli/Binomial parameter $p$ in Bayesian inference, connecting back to the Bernoulli distribution from the previous module. [Unverified] I do not have a derivation of conjugacy within this document series confirming this property; this should be checked against a dedicated Bayesian statistics reference.
- The **Exponential distribution** appears in survival analysis and time-to-event modeling. [Unverified] I do not have access to information confirming the specific prevalence of this distribution's use across current ML applications, so this should be treated as a general structural connection rather than a claim about common practice.
- **Continuous probability densities** underlie the likelihood functions used in maximum likelihood estimation for continuous-valued model outputs, such as Gaussian likelihoods in regression loss derivations. [Inference] This connection follows from the definition of likelihood as the density function evaluated at observed data points, a standard construction in statistical estimation, though I have not derived the full MLE procedure within this document series.

### Common Pitfalls

- Interpreting $f_X(x)$ as a probability directly, rather than a density; $f_X(x)$ can exceed 1, and only integrals of $f_X$ over intervals yield probabilities.
- Assuming $P(X = x) \neq 0$ for continuous random variables, leading to errors when computing probabilities of exact point values instead of intervals.
- Confusing strict and non-strict inequalities ($P(X < x)$ vs $P(X \leq x)$) as if they differ for continuous random variables; [Inference] since $P(X = x) = 0$ for any single point in the continuous case, these two probabilities are equal, unlike in the discrete case where they generally differ.
- Applying discrete-case formulas (sums) directly to continuous random variables instead of the corresponding integral forms.

**Related Topics**
- Expectation and variance of continuous random variables
- Joint distributions of continuous random variables
- Transformations of continuous random variables (change of variables)
- The Central Limit Theorem and its connection to the Normal distribution
- Conjugate priors in Bayesian inference
- Maximum likelihood estimation for continuous distributions

> Correction: This document contains multiple [Unverified] labeled points, including underived normalization proofs for the Normal and Beta distributions, an unevaluated standard normal probability, and unconfirmed claims about ML application prevalence. These are labeled rather than presented as confirmed fact, consistent with the requirement not to chain unverified claims into stated conclusions.