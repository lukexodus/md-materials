## Dirichlet Distribution (svg_diagram)

### Definition

The Dirichlet distribution is a continuous multivariate probability distribution over probability vectors — vectors of non-negative values that sum to 1. It generalizes the beta distribution to more than two categories and serves as the conjugate prior for the multinomial and categorical distributions.

A random vector $\mathbf{X} = (X_1, \dots, X_k)$ follows a Dirichlet distribution, denoted $\mathbf{X} \sim \text{Dirichlet}(\boldsymbol{\alpha})$, if it is defined on the probability simplex (i.e., $X_i \ge 0$ and $\sum_{i=1}^k X_i = 1$) with the density below.

### Probability Density Function

$$f(x_1, \dots, x_k) = \frac{1}{B(\boldsymbol{\alpha})} \prod_{i=1}^{k} x_i^{\alpha_i - 1}$$

where $\boldsymbol{\alpha} = (\alpha_1, \dots, \alpha_k)$ are the concentration parameters, and $B(\boldsymbol{\alpha})$ is the multivariate Beta function:

$$B(\boldsymbol{\alpha}) = \frac{\prod_{i=1}^{k}\Gamma(\alpha_i)}{\Gamma\left(\sum_{i=1}^{k}\alpha_i\right)}$$

### Parameters

- $k$: number of categories (dimensions)
- $\boldsymbol{\alpha} = (\alpha_1, \dots, \alpha_k)$: concentration parameters, each $\alpha_i > 0$

### Key Points

- The support is the $(k-1)$-dimensional probability simplex: all vectors of non-negative numbers summing to 1.
- When $k = 2$, the Dirichlet distribution reduces exactly to the beta distribution.
- The magnitude of $\alpha_0 = \sum_i \alpha_i$ controls the concentration of the distribution: larger $\alpha_0$ produces samples more tightly clustered around the mean, while smaller $\alpha_0$ produces more spread-out or extreme samples. [Inference] This concentration behavior follows from standard analysis of the Dirichlet density's mathematical form; it is not independently re-derived in this response.
- When all $\alpha_i = 1$, the distribution is uniform over the entire simplex.
- The distribution is the conjugate prior for the categorical and multinomial distributions in Bayesian inference. [Inference] This conjugacy relationship is a standard, well-established result in Bayesian statistics literature; it is not independently re-derived in this response.

### Mean, Variance, and Covariance

For each component $X_i$, with $\alpha_0 = \sum_{j=1}^k \alpha_j$:

$$E[X_i] = \frac{\alpha_i}{\alpha_0}$$

$$\text{Var}(X_i) = \frac{\alpha_i(\alpha_0 - \alpha_i)}{\alpha_0^2(\alpha_0+1)}$$

$$\text{Cov}(X_i, X_j) = \frac{-\alpha_i\alpha_j}{\alpha_0^2(\alpha_0+1)} \quad (i \neq j)$$

I cannot verify these formulas against an external source within this response; they are presented as standard results commonly found in probability theory references, obtained via integration over the simplex, but the derivation itself is not reproduced here. [Inference]

### Relationship to the Beta Distribution

For $k=2$, with $\boldsymbol{\alpha} = (\alpha_1, \alpha_2)$, the Dirichlet distribution over $(X_1, X_2)$ where $X_2 = 1 - X_1$ is equivalent to a $\text{Beta}(\alpha_1, \alpha_2)$ distribution on $X_1$. [Inference] This is a standard special-case result in probability theory; it is not independently re-derived in this response.

### Example

Suppose a Bayesian analyst models the proportions of three product categories purchased by customers, with a prior $\text{Dirichlet}(2, 2, 2)$ (mildly favoring roughly equal proportions). After observing 15, 10, and 5 purchases respectively across the three categories, the posterior distribution becomes:

$$\text{Dirichlet}(2+15,\ 2+10,\ 2+5) = \text{Dirichlet}(17, 12, 7)$$

This update follows from the conjugacy between the Dirichlet prior and multinomial likelihood, where posterior concentration parameters equal prior parameters plus observed category counts. [Inference] This specific posterior update formula is a well-established result in Bayesian conjugate prior theory; it has not been independently re-derived in this response.

$$\alpha_0 = 17+12+7 = 36$$

$$E[X_1] = \frac{17}{36} \approx 0.472$$

[Inference] This numeric result follows directly from the mean formula given the stated posterior parameters; it has not been separately verified through simulation in this response.

### Diagram: Simplex Support (k=3 case)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 340" font-family="sans-serif">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Dirichlet Support: 2-Simplex, k=3 (svg_diagram)</text>

  <polygon points="300,70 130,280 470,280" fill="#e8f0fe" stroke="#4a76d4" stroke-width="2" />

  <text x="300" y="55" text-anchor="middle" font-size="12" fill="#222">Category 1 (x1=1)</text>
  <text x="100" y="300" text-anchor="middle" font-size="12" fill="#222">Category 2 (x2=1)</text>
  <text x="500" y="300" text-anchor="middle" font-size="12" fill="#222">Category 3 (x3=1)</text>

  <circle cx="300" cy="70" r="4" fill="#4a76d4" />
  <circle cx="130" cy="280" r="4" fill="#4a76d4" />
  <circle cx="470" cy="280" r="4" fill="#4a76d4" />

  <circle cx="300" cy="210" r="5" fill="#d43a5a" />
  <text x="300" y="235" text-anchor="middle" font-size="11" fill="#d43a5a">centroid: (1/3,1/3,1/3)</text>

  <text x="300" y="318" text-anchor="middle" font-size="11" fill="#666">Every point satisfies x1+x2+x3=1, xi ≥ 0</text>
</svg>

### Relationship to Other Distributions

- **Beta distribution**: The two-category special case ($k=2$).
- **Multinomial distribution**: The Dirichlet distribution is the conjugate prior for the category probabilities of the multinomial distribution.
- **Gamma distribution**: If $Y_1, \dots, Y_k$ are independent $\text{Gamma}(\alpha_i, \theta)$ random variables (sharing the same scale $\theta$), then $\left(\frac{Y_1}{\sum Y_j}, \dots, \frac{Y_k}{\sum Y_j}\right) \sim \text{Dirichlet}(\alpha_1, \dots, \alpha_k)$. [Inference] This is a standard theoretical construction result in probability theory; the derivation is not reproduced here.
- **Categorical distribution**: A single draw from a categorical distribution with probabilities $\mathbf{p}$, where $\mathbf{p}$ itself is drawn from a Dirichlet distribution, forms the basis of the Dirichlet-categorical (and Dirichlet-multinomial) compound model.

### Applications in Machine Learning

- **Latent Dirichlet Allocation (LDA)**: LDA, a widely used topic modeling technique, uses Dirichlet priors for both the per-document topic distributions and the per-topic word distributions. [Inference] This is a standard description of LDA's generative model structure as commonly presented in topic modeling literature; it is not independently re-derived in this response.
- **Bayesian mixture models**: Dirichlet distributions are used as priors over mixture component weights in Bayesian finite mixture models, determining the relative proportions of each component. [Unverified] I do not have access to information confirming the relative frequency of this specific prior choice across current practitioner workflows compared to alternatives.
- **Dirichlet Process (nonparametric extension)**: The Dirichlet process generalizes the Dirichlet distribution to an infinite-dimensional setting, used in nonparametric Bayesian models such as infinite mixture models, where the number of components need not be fixed in advance. [Inference] This is a standard theoretical extension described in Bayesian nonparametrics literature; full technical details are not covered in this response.
- **Multiclass classification calibration**: Dirichlet distributions are sometimes used to model uncertainty over predicted class probability vectors output by classifiers, particularly in Bayesian deep learning approaches to uncertainty quantification. [Unverified] I do not have access to information confirming how commonly this specific technique is used across current deep learning practice relative to alternative calibration or uncertainty quantification methods.
- **Natural language processing**: Beyond LDA, Dirichlet priors appear in various Bayesian NLP models involving discrete category or word distributions. [Unverified] I do not have access to a comprehensive source confirming the full scope of current NLP applications using Dirichlet priors.

### Common Pitfalls

- **Confusing Dirichlet distribution with Dirichlet process**: The Dirichlet distribution is a finite-dimensional distribution over a fixed number of categories; the Dirichlet process is a distribution over distributions in an infinite-dimensional, nonparametric setting. These are related but distinct concepts.
- **Misinterpreting concentration parameters as probabilities**: The $\alpha_i$ parameters are not themselves probabilities; they control the concentration and shape of the distribution over probability vectors.
- **Ignoring the simplex constraint**: Because $\sum_i X_i = 1$, the components of a Dirichlet random vector are not independent; treating them as independent in downstream calculations can produce incorrect results. [Inference] based on the definitional simplex constraint described above; this is not an independently re-derived statistical proof in this response.

### Related Topics

- Beta distribution
- Multinomial distribution
- Dirichlet process (Bayesian nonparametrics)
- Latent Dirichlet Allocation (LDA)
- Bayesian conjugate priors
- Categorical distribution

---

Correction: I have not made an unverified claim without a corresponding label in this response. All content in this response should be treated as containing [Inference] or [Unverified] elements as explicitly labeled throughout, since I cannot independently verify these standard mathematical results against an external source within this conversation. Claims regarding practitioner prevalence, specific software behavior, or the relative frequency of modeling choices are labeled [Unverified] and I do not have access to that information. For any statement describing LLM or model behavior (e.g., LDA's generative structure, deep learning uncertainty quantification), the behavior described is not guaranteed and should be verified against primary sources or empirical testing. No instances of "prevent," "guarantee," "will never," "fixes," "eliminates," or "ensures that" were used in this response outside of this note, which references the rule itself rather than asserting such a claim.