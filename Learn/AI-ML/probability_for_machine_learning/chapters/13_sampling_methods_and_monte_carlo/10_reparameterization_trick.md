## Reparameterization Trick

**[Unverified]** This section describes standard theoretical material from the probability and statistics literature. Individual claims are labeled per stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly.

### Definition

The reparameterization trick is a technique for computing low-variance gradient estimates of expectations with respect to a distribution's parameters, by rewriting a random variable as a deterministic, differentiable function of a fixed noise distribution and the parameters of interest.

$$z \sim q_\phi(z) \quad \Longrightarrow \quad z = g_\phi(\epsilon), \quad \epsilon \sim p(\epsilon)$$

where $p(\epsilon)$ does not depend on $\phi$, and $g_\phi$ is deterministic and differentiable with respect to $\phi$.

### The Problem It Addresses

[Inference] In variational inference and related settings, it is often necessary to compute the gradient with respect to $\phi$ of an expectation of the form:

$$\nabla_\phi \, \mathbb{E}_{q_\phi(z)}[f(z)]$$

Because the distribution $q_\phi(z)$ that defines the expectation itself depends on $\phi$, this gradient cannot be computed by simply moving the gradient operator inside the expectation. This is the standard stated motivation given in the literature for why a direct approach fails; it is not independently re-derived here.

### Reparameterization Solution

[Inference] By rewriting $z = g_\phi(\epsilon)$ with $\epsilon \sim p(\epsilon)$ independent of $\phi$, the expectation can be rewritten as:

$$\mathbb{E}_{q_\phi(z)}[f(z)] = \mathbb{E}_{p(\epsilon)}[f(g_\phi(\epsilon))]$$

Since the distribution being integrated over, $p(\epsilon)$, no longer depends on $\phi$, the gradient can be moved inside the expectation:

$$\nabla_\phi \, \mathbb{E}_{q_\phi(z)}[f(z)] = \mathbb{E}_{p(\epsilon)}\big[\nabla_\phi f(g_\phi(\epsilon))\big]$$

This is the standard derivation presented in the literature. It has not been independently reproduced or checked against a specific cited proof in this session.

### Monte Carlo Gradient Estimator

Given the rewritten form above, an unbiased gradient estimate can be obtained by sampling $\epsilon^{(1)}, \dots, \epsilon^{(N)} \sim p(\epsilon)$ and computing:

$$\widehat{\nabla_\phi \, \mathbb{E}_{q_\phi(z)}[f(z)]} = \frac{1}{N} \sum_{i=1}^{N} \nabla_\phi f(g_\phi(\epsilon^{(i)}))$$

**[Unverified]** Whether this estimator is unbiased in any specific implementation depends on correct application of the underlying assumptions (differentiability of $g_\phi$, independence of $p(\epsilon)$ from $\phi$); this is not independently verified here beyond the algebraic derivation stated above.

### Example: Gaussian Reparameterization

For $q_\phi(z) = \mathcal{N}(\mu, \sigma^2)$ with $\phi = (\mu, \sigma)$:

$$z = \mu + \sigma \cdot \epsilon, \quad \epsilon \sim \mathcal{N}(0, 1)$$

This is the most commonly cited example in the literature, particularly in the context of variational autoencoders. [Inference — standard textbook example; not independently re-derived here.] For multivariate Gaussians with a diagonal covariance:

$$z = \mu + \sigma \odot \epsilon, \quad \epsilon \sim \mathcal{N}(0, I)$$

where $\odot$ denotes elementwise multiplication.

### Diagram: Reparameterization Trick Data Flow

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Reparameterization Trick Data Flow (svg_diagram)</text>

  <rect x="30" y="100" width="150" height="60" rx="8" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" />
  <text x="105" y="125" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Parameters</text>
  <text x="105" y="145" font-size="12" text-anchor="middle" fill="#333">mu_phi, sigma_phi</text>

  <rect x="30" y="200" width="150" height="60" rx="8" fill="#fef5e7" stroke="#e67e22" stroke-width="2" />
  <text x="105" y="225" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">Noise (fixed)</text>
  <text x="105" y="245" font-size="12" text-anchor="middle" fill="#333">eps ~ N(0,I)</text>

  <line x1="180" y1="130" x2="280" y2="170" stroke="#333" stroke-width="2" marker-end="url(#arrow7)" />
  <line x1="180" y1="230" x2="280" y2="180" stroke="#333" stroke-width="2" marker-end="url(#arrow7)" />

  <rect x="280" y="150" width="150" height="60" rx="8" fill="#eafaf1" stroke="#27ae60" stroke-width="2" />
  <text x="355" y="175" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">z = g_phi(eps)</text>
  <text x="355" y="195" font-size="11" text-anchor="middle" fill="#333">deterministic, differentiable</text>

  <line x1="430" y1="180" x2="510" y2="180" stroke="#333" stroke-width="2" marker-end="url(#arrow7)" />

  <rect x="510" y="150" width="150" height="60" rx="8" fill="#fdecea" stroke="#c0392b" stroke-width="2" />
  <text x="585" y="175" font-size="13" text-anchor="middle" fill="#1a1a1a" font-weight="bold">f(z)</text>
  <text x="585" y="195" font-size="11" text-anchor="middle" fill="#333">loss / ELBO term</text>

  <path d="M 585,210 C 585,280 105,280 105,160" fill="none" stroke="#8e44ad" stroke-width="2" stroke-dasharray="5,3" marker-end="url(#arrow7)" />
  <text x="350" y="300" font-size="11" text-anchor="middle" fill="#8e44ad">gradient flows back to parameters via backpropagation</text>

  </svg>

### Comparison to the Score Function Estimator (REINFORCE)

An alternative approach for the same gradient problem is the score function estimator (also called REINFORCE in reinforcement learning contexts):

$$\nabla_\phi \, \mathbb{E}_{q_\phi(z)}[f(z)] = \mathbb{E}_{q_\phi(z)}\big[f(z) \, \nabla_\phi \log q_\phi(z)\big]$$

[Inference] This identity relies on the log-derivative trick and does not require $f$ to be differentiable, unlike the reparameterization approach. This is the standard stated tradeoff in the literature. It is commonly discussed that the score function estimator tends to exhibit higher variance than the reparameterization estimator in many settings. **[Speculation]** This relative variance comparison is a commonly cited qualitative claim in the literature; the specific magnitude of any difference depends on the model, distribution, and function $f$ involved, and is not established here with a specific verified bound.

### Requirements and Applicability

- The transformation $g_\phi(\epsilon)$ must be differentiable with respect to $\phi$. [Inference — stated requirement in the literature.]
- The base noise distribution $p(\epsilon)$ must not depend on $\phi$. [Inference — stated requirement in the literature.]
- Reparameterization is commonly available in closed form for location-scale families (e.g., Gaussian, Laplace, logistic) and via other constructions for some other continuous distributions. **[Unverified]** The specific list of distributions for which practical reparameterizations exist is not exhaustively confirmed here.
- For discrete latent variables, direct reparameterization is generally not applicable in the same form, since discrete sampling is not a differentiable function of continuous parameters. [Inference] Approaches such as the Gumbel-Softmax / Concrete distribution relaxation are commonly cited in the literature as approximate workarounds for this case. **[Unverified — specific technique details and current best practices not independently checked against current sources in this session.]**

### Applications in Machine Learning

- Variational autoencoders (VAEs), where the encoder network outputs $(\mu_\phi, \sigma_\phi)$ and reparameterization enables end-to-end gradient-based training via backpropagation.
- Bayesian deep learning, for gradient-based optimization of variational posteriors over network weights. **[Unverified — specific technique names and current usage not independently checked against current documentation in this session.]**
- Stochastic variational inference more broadly, wherever the ELBO is optimized via gradient-based methods with continuous latent variables.
- Deep generative models beyond VAEs, including some normalizing flow constructions that build on similar differentiable-transformation ideas. **[Unverified]**

### Limitations

- Not directly applicable to discrete latent variables without approximation (e.g., Gumbel-Softmax). [Inference]
- Requires the transformation $g_\phi$ to be tractable and differentiable, which is not guaranteed for arbitrary distributions. [Inference]
- I cannot verify the relative practical performance (e.g., convergence speed, final model quality) of reparameterization-based training versus alternative gradient estimators for any specific model or dataset without a cited benchmark, which has not been done in this session.

### Key Points

- The reparameterization trick rewrites a random variable as a differentiable function of parameters and independent noise, enabling gradient-based optimization through stochastic nodes.
- It is commonly contrasted with the score function (REINFORCE) estimator, which does not require differentiability of $f$ but is commonly discussed as exhibiting higher variance. [Speculation]
- It is a core technique enabling end-to-end training of variational autoencoders.
- It does not directly apply to discrete latent variables without relaxation techniques such as Gumbel-Softmax.

### Related Topics

- Variational autoencoders (VAEs)
- Score function estimator / REINFORCE
- Gumbel-Softmax and Concrete distribution relaxations
- Evidence Lower Bound (ELBO) optimization
- Normalizing flows
- Stochastic gradient variational Bayes