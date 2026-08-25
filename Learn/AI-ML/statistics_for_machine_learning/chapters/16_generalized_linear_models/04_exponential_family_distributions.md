## Exponential Family Distributions

### Definition and Motivation

A probability distribution belongs to the exponential family if its probability density function (PDF) or probability mass function (PMF) can be written in a canonical form. This family unifies many common distributions — Normal, Bernoulli, Binomial, Poisson, Gamma, Exponential, and others — under a single mathematical framework, which is the theoretical foundation for Generalized Linear Models (GLMs).

The general form for a single-parameter exponential family distribution is:

$$p(y; \eta) = b(y) \exp\left(\eta T(y) - a(\eta)\right)$$

Where each term has a specific role:

- $\eta$ — the **natural parameter** (also called the canonical parameter)
- $T(y)$ — the **sufficient statistic** (often $T(y) = y$)
- $a(\eta)$ — the **log-partition function** (also called the cumulant function), which ensures the distribution integrates/sums to 1
- $b(y)$ — the **base measure**, a function of $y$ alone, independent of $\eta$

### Why This Form Matters for Machine Learning

This structure is not merely a mathematical curiosity. [Inference] The unification allows a single algorithmic framework (GLMs) to handle regression, classification, and count prediction by simply changing which exponential-family distribution is assumed for the response variable. This is a reasoned conclusion based on the standard derivation of GLMs and is widely presented this way in statistical learning texts, not an empirical claim about any specific implementation.

Key properties that follow from the exponential family form:

- **Sufficiency**: $T(y)$ contains all the information in the data needed to estimate $\eta$
- **Conjugacy**: Exponential family distributions often have conjugate priors, simplifying Bayesian updates
- **Moment generation**: Derivatives of $a(\eta)$ directly yield the mean and variance of the distribution

### Deriving Mean and Variance from $a(\eta)$

One of the most useful analytical properties of the exponential family is that the mean and variance can be obtained directly from the log-partition function without integrating the full distribution.

$$E[T(y)] = \frac{d}{d\eta} a(\eta) = a'(\eta)$$

$$\text{Var}(T(y)) = \frac{d^2}{d\eta^2} a(\eta) = a''(\eta)$$

This is a standard result derivable from the fact that the exponential family PDF must integrate to 1, and differentiating that normalization condition with respect to $\eta$ yields these moment relationships. This derivation is a well-established part of exponential family theory, not an inference specific to any dataset or model.

### Canonical Examples Rewritten in Exponential Family Form

#### Bernoulli Distribution

For $y \in \{0, 1\}$ with success probability $\phi$:

$$p(y; \phi) = \phi^y (1-\phi)^{1-y}$$

Rewriting in exponential family form:

$$p(y; \phi) = \exp\left(y \log\phi + (1-y)\log(1-\phi)\right) = \exp\left(\log\left(\frac{\phi}{1-\phi}\right) y + \log(1-\phi)\right)$$

Matching terms to the canonical form:

- $\eta = \log\left(\frac{\phi}{1-\phi}\right)$ — this is the **log-odds** or **logit**
- $T(y) = y$
- $a(\eta) = -\log(1-\phi) = \log(1 + e^{\eta})$
- $b(y) = 1$

Solving for $\phi$ in terms of $\eta$ gives $\phi = \frac{1}{1 + e^{-\eta}}$, which is the **sigmoid function**. This is the standard mathematical origin of why logistic regression uses the sigmoid as its link function.

#### Gaussian (Normal) Distribution

Assuming known variance $\sigma^2 = 1$ for simplicity:

$$p(y; \mu) = \frac{1}{\sqrt{2\pi}} \exp\left(-\frac{(y-\mu)^2}{2}\right)$$

Expanding and matching to canonical form:

- $\eta = \mu$
- $T(y) = y$
- $a(\eta) = \frac{\eta^2}{2}$
- $b(y) = \frac{1}{\sqrt{2\pi}} \exp\left(-\frac{y^2}{2}\right)$

#### Poisson Distribution

For count data with rate parameter $\lambda$:

$$p(y; \lambda) = \frac{e^{-\lambda}\lambda^y}{y!}$$

Matching to canonical form:

- $\eta = \log(\lambda)$
- $T(y) = y$
- $a(\eta) = \lambda = e^{\eta}$
- $b(y) = \frac{1}{y!}$

### Summary Table of Common Members

| Distribution | Natural Parameter $\eta$ | $a(\eta)$ | Typical Use Case |
|---|---|---|---|
| Bernoulli | $\log(\phi/(1-\phi))$ | $\log(1+e^{\eta})$ | Binary classification |
| Gaussian | $\mu$ | $\eta^2/2$ | Continuous regression |
| Poisson | $\log(\lambda)$ | $e^{\eta}$ | Count data |
| Gamma | $-1/\theta$ | $-\log(-\eta)$ | Positive-skewed continuous data |
| Multinomial | vector of log-odds | log-sum-exp form | Multi-class classification |

[Unverified] The exact parameterization conventions (e.g., sign of $\eta$, dispersion term placement) can differ slightly between textbooks and software implementations. I cannot verify which specific convention any given library uses without checking its documentation directly.

### Structural Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 820 460">
  <text x="410" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Exponential Family Structure (svg_diagram)</text>

  <rect x="260" y="55" width="300" height="55" rx="8" fill="#eef2ff" stroke="#4338ca" stroke-width="1.5" />
  <text x="410" y="78" text-anchor="middle" font-size="13" fill="#1a1a1a" font-family="monospace">p(y; η) = b(y) exp(η·T(y) − a(η))</text>
  <text x="410" y="97" text-anchor="middle" font-size="11" fill="#555">Canonical Exponential Family Form</text>

  <line x1="410" y1="110" x2="140" y2="160" stroke="#888" stroke-width="1.5" />
  <line x1="410" y1="110" x2="410" y2="160" stroke="#888" stroke-width="1.5" />
  <line x1="410" y1="110" x2="680" y2="160" stroke="#888" stroke-width="1.5" />

  <rect x="40" y="160" width="200" height="60" rx="8" fill="#fef3c7" stroke="#b45309" stroke-width="1.5" />
  <text x="140" y="185" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">η (natural parameter)</text>
  <text x="140" y="202" text-anchor="middle" font-size="10" fill="#555">canonical link target</text>

  <rect x="310" y="160" width="200" height="60" rx="8" fill="#dcfce7" stroke="#15803d" stroke-width="1.5" />
  <text x="410" y="185" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">T(y) (sufficient stat)</text>
  <text x="410" y="202" text-anchor="middle" font-size="10" fill="#555">often T(y) = y</text>

  <rect x="580" y="160" width="200" height="60" rx="8" fill="#fee2e2" stroke="#b91c1c" stroke-width="1.5" />
  <text x="680" y="185" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">a(η) (log-partition)</text>
  <text x="680" y="202" text-anchor="middle" font-size="10" fill="#555">normalizes distribution</text>

  <line x1="680" y1="220" x2="680" y2="260" stroke="#888" stroke-width="1.5" />
  <rect x="560" y="260" width="240" height="70" rx="8" fill="#f3f4f6" stroke="#374151" stroke-width="1.5" />
  <text x="680" y="283" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">Derivatives of a(η)</text>
  <text x="680" y="300" text-anchor="middle" font-size="10" fill="#555" font-family="monospace">E[T(y)] = a'(η)</text>
  <text x="680" y="316" text-anchor="middle" font-size="10" fill="#555" font-family="monospace">Var(T(y)) = a''(η)</text>

  <line x1="140" y1="220" x2="140" y2="380" stroke="#888" stroke-width="1.5" />
  <rect x="40" y="380" width="200" height="60" rx="8" fill="#e0e7ff" stroke="#4338ca" stroke-width="1.5" />
  <text x="140" y="405" text-anchor="middle" font-size="12" font-weight="bold" fill="#1a1a1a">GLM Link Function</text>
  <text x="140" y="422" text-anchor="middle" font-size="10" fill="#555">connects η to μ = E[y]</text>
</svg>

### Relationship to Generalized Linear Models

The exponential family provides the theoretical scaffold for GLMs through three assumptions:

1. Given input $x$, the response $y$ follows some exponential family distribution with parameter $\eta$
2. The goal is to predict $E[T(y)|x]$, typically $E[y|x]$
3. The natural parameter relates linearly to the inputs: $\eta = \theta^T x$

The function mapping $\eta$ back to the mean $\mu = E[y]$ is the **canonical response function**, and its inverse is the **canonical link function**. This linkage is what determines, for example, why logistic regression uses the sigmoid and Poisson regression uses the exponential (log-link inverse) function — both are direct consequences of the algebra shown in the derivations above, not arbitrary design choices.

```mermaid
flowchart LR
    A["Input features x"] --> B["Linear predictor eta = theta^T x"]
    B --> C["Canonical link function g"]
    C --> D["Mean mu = E[y|x]"]
    D --> E["Exponential family distribution p(y; eta)"]
    E --> F["Predicted response y"]
```

### Worked Example: From Distribution Choice to Model Form

**Example**

Given a dataset where the response variable $y$ is a non-negative integer count (e.g., number of website visits per hour):

1. Select the Poisson distribution as appropriate, since it models count data
2. From the derivation above, $\eta = \log(\lambda)$, so $\lambda = e^{\eta}$
3. Set $\eta = \theta^T x$ (the linear predictor)
4. This yields the model: $\lambda(x) = e^{\theta^T x}$

This is precisely the model form used in **Poisson regression**, and it is derived directly from exponential family algebra rather than chosen heuristically.

[Inference] Whether Poisson regression is the *best* choice for a specific real-world count dataset depends on whether the data satisfies the Poisson assumption of equal mean and variance (equidispersion); overdispersed count data may be better modeled with a Negative Binomial distribution instead. This is a reasoned modeling recommendation, not a universal rule, and actual model fit should be checked empirically on the data in question.

### Common Pitfalls

- Assuming a distribution belongs to the exponential family without verifying its PDF can be algebraically rearranged into canonical form — some distributions (e.g., Uniform with unknown bounds, Cauchy) do not belong to this family
- Confusing the **natural parameter** $\eta$ with the **mean parameter** $\mu$ — they are related but distinct, connected via the link function
- Overlooking the **dispersion parameter** $\phi$ in the two-parameter exponential family form, relevant for distributions like Gaussian and Gamma where variance is not fully determined by the mean alone

### **Related Topics**

- Canonical link functions and their derivation for each exponential family member
- Generalized Linear Models — model fitting via Iteratively Reweighted Least Squares (IRLS)
- Maximum Likelihood Estimation for exponential family parameters
- Deviance and goodness-of-fit measures for GLMs
- Overdispersion and the Negative Binomial distribution as an extension beyond Poisson
- Bayesian conjugate priors arising from exponential family structure
- Link function selection: canonical vs. non-canonical links