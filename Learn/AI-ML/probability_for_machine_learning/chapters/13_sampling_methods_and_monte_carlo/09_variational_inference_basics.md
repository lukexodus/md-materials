## Variational Inference Basics

**[Unverified]** This section describes standard theoretical material from the probability and statistics literature. Individual claims are labeled per stated preferences; where a claim is not independently confirmed against a specific cited source in this session, it is marked accordingly. Behavior claims about any specific system or implementation are not guaranteed.

### Definition

Variational inference (VI) is a method for approximating intractable posterior distributions $p(z \mid x)$ in probabilistic models by reformulating inference as an optimization problem, rather than a sampling problem as in MCMC. A tractable family of distributions $q(z; \phi)$, parameterized by variational parameters $\phi$, is optimized to be as close as possible to the true posterior $p(z \mid x)$.

$$q^*(z) = \arg\min_{q \in \mathcal{Q}} \, \text{KL}\big(q(z) \, \| \, p(z \mid x)\big)$$

where $\mathcal{Q}$ is the chosen family of tractable distributions (the "variational family").

### Why Direct KL Minimization Is Not Used Directly

[Inference] The KL divergence $\text{KL}(q(z) \| p(z \mid x))$ requires evaluating $p(z \mid x) = p(x,z)/p(x)$, which involves the intractable marginal likelihood (evidence) $p(x) = \int p(x,z)\, dz$ — the same intractable quantity that motivates using an approximation in the first place. This is the standard stated motivation in the literature for reformulating the objective; it is not independently re-derived here.

### The Evidence Lower Bound (ELBO)

[Inference] Because direct minimization is not tractable, the literature commonly derives an equivalent optimization objective, the Evidence Lower Bound (ELBO), which avoids requiring $p(x)$ directly. Starting from the log marginal likelihood:

$$\log p(x) = \text{ELBO}(q) + \text{KL}\big(q(z) \, \| \, p(z \mid x)\big)$$

where:

$$\text{ELBO}(q) = \mathbb{E}_{q(z)}\big[\log p(x, z) - \log q(z)\big]$$

Since $\text{KL}(\cdot) \geq 0$ always, $\text{ELBO}(q) \leq \log p(x)$, and the ELBO is a lower bound on the log evidence — hence the name. Because $\log p(x)$ is fixed with respect to $q$, maximizing the ELBO with respect to $q$'s parameters is equivalent to minimizing the KL divergence to the true posterior. **[Unverified]** This equivalence is presented as commonly stated theory in the literature; the derivation has not been independently reproduced or checked against a specific cited proof in this session.

### Rewriting the ELBO

The ELBO is commonly decomposed as:

$$\text{ELBO}(q) = \mathbb{E}_{q(z)}[\log p(x \mid z)] - \text{KL}\big(q(z) \, \| \, p(z)\big)$$

This decomposition is commonly interpreted in the literature as:

- **Reconstruction term**: $\mathbb{E}_{q(z)}[\log p(x \mid z)]$ — how well the approximate posterior explains the observed data.
- **Regularization term**: $-\text{KL}(q(z) \| p(z))$ — a penalty pulling $q(z)$ toward the prior $p(z)$.

**[Unverified]** This particular interpretive framing (reconstruction vs. regularization) is a common pedagogical description found in secondary sources on variational autoencoders and related models; it is not an independently verified formal property beyond the algebraic decomposition itself.

### Mean-Field Variational Inference

A common simplifying assumption, called the mean-field assumption, factorizes $q(z)$ across the latent variables:

$$q(z) = \prod_{i=1}^{D} q_i(z_i)$$

Under this assumption, a standard derivation in the literature is coordinate ascent variational inference (CAVI), which iteratively updates each factor $q_i(z_i)$ to maximize the ELBO holding all other factors fixed. [Inference — this is the standard textbook derivation; not independently re-derived here.] The optimal form of each factor, under this assumption, has a known closed form:

$$q_i^*(z_i) \propto \exp\big(\mathbb{E}_{q_{-i}}[\log p(x, z)]\big)$$

**[Unverified]** Whether this closed form is tractable to compute in any specific model depends on the model's structure and is not established in general here.

### Diagram: Variational Inference as Optimization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" font-size="18" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Variational Inference as Optimization (svg_diagram)</text>

  <ellipse cx="450" cy="220" rx="180" ry="130" fill="#fdecea" stroke="#c0392b" stroke-width="2" />
  <text x="450" y="100" font-size="12" fill="#c0392b" font-weight="bold">true posterior p(z|x)</text>
  <circle cx="450" cy="220" r="6" fill="#c0392b" />

  <ellipse cx="250" cy="220" rx="100" ry="70" fill="#eaf2f8" stroke="#2980b9" stroke-width="2" opacity="0.7" />
  <text x="250" y="145" font-size="12" fill="#2980b9" font-weight="bold">variational family Q</text>

  <circle cx="300" cy="220" r="6" fill="#2980b9" />
  <text x="300" y="240" font-size="10" text-anchor="middle" fill="#2980b9">q*(z), closest in Q</text>

  <line x1="300" y1="220" x2="450" y2="220" stroke="#e67e22" stroke-width="2" stroke-dasharray="5,3" marker-end="url(#arrow6)" />
  <text x="375" y="210" font-size="10" fill="#e67e22" text-anchor="middle">KL divergence</text>

  <text x="350" y="360" font-size="11" text-anchor="middle" fill="#555">q* is the member of Q minimizing KL(q || p(z|x)), equivalently maximizing the ELBO</text>

  </svg>

### Comparison to MCMC

- **MCMC**: Samples from $p(z \mid x)$ asymptotically; given enough iterations, is commonly described in the literature as producing samples that approximate the true posterior arbitrarily closely. **[Unverified]** This asymptotic property does not translate to a specific guarantee for any finite chain, and no such guarantee is claimed here.
- **Variational inference**: Optimizes a bound and returns an approximate posterior from a restricted family $\mathcal{Q}$; even at the optimum, $q^*(z)$ does not generally equal $p(z \mid x)$ unless $p(z \mid x) \in \mathcal{Q}$. [Inference — this follows from the definition of the optimization being restricted to $\mathcal{Q}$.]
- **Speed vs. accuracy tradeoff**: VI is commonly described in the literature as typically faster than MCMC for large-scale problems, at the cost of a systematic approximation bias from the restricted variational family. **[Speculation]** This is a commonly discussed qualitative tradeoff, not a confirmed quantitative result verified in this session; actual relative performance depends on the specific model, data scale, and implementation.

### Reparameterization Trick

For continuous latent variables, computing gradients of the ELBO with respect to variational parameters $\phi$ is complicated by the fact that the expectation is taken over a distribution that itself depends on $\phi$. A common solution, the reparameterization trick, rewrites $z \sim q_\phi(z)$ as a deterministic, differentiable transformation of a noise variable:

$$z = g_\phi(\epsilon, x), \quad \epsilon \sim p(\epsilon)$$

For example, for $q_\phi(z) = \mathcal{N}(\mu_\phi, \sigma_\phi^2)$:

$$z = \mu_\phi + \sigma_\phi \odot \epsilon, \quad \epsilon \sim \mathcal{N}(0, I)$$

[Inference] This reformulation allows gradients to be computed via standard backpropagation, which is the standard stated motivation for the technique in the literature (notably in the context of variational autoencoders). This is not independently re-derived here.

### Applications in Machine Learning

- Variational autoencoders (VAEs), where an encoder network parameterizes $q_\phi(z \mid x)$ and is trained jointly with a decoder network via the ELBO.
- Bayesian deep learning, approximating posteriors over neural network weights (e.g., variational dropout, Bayes by Backprop). **[Unverified — specific technique names and current usage not independently checked against current documentation in this session.]**
- Topic models (e.g., variational inference for Latent Dirichlet Allocation, as an alternative to collapsed Gibbs sampling).
- Large-scale Bayesian inference where MCMC is computationally impractical. **[Speculation]** — commonly cited motivation, not independently benchmarked here.

### Limitations

- The variational family $\mathcal{Q}$ introduces approximation bias; mean-field assumptions in particular are commonly described in the literature as underestimating posterior variance and failing to capture correlations between latent variables when the true posterior is highly correlated. **[Speculation]** This is a commonly discussed qualitative concern, not a confirmed quantitative result verified in this session.
- The ELBO can have multiple local optima, and optimization is commonly described as not guaranteed to be found the global optimum in non-convex settings such as those involving neural network parameterizations. [Inference — general property of non-convex optimization; not independently verified for this specific setting here.]
- Model-specific derivations (e.g., closed-form CAVI updates) may not generalize easily to arbitrary model structures. [Inference]

### Key Points

- Variational inference reframes posterior approximation as optimization over a tractable family $\mathcal{Q}$.
- The ELBO is a tractable lower bound on the log evidence; maximizing it is equivalent to minimizing KL divergence to the true posterior.
- Mean-field assumptions enable closed-form coordinate ascent updates (CAVI) in some conjugate model classes.
- The reparameterization trick enables gradient-based optimization of the ELBO for continuous latent variables.
- VI is commonly discussed as trading approximation accuracy for computational speed relative to MCMC; this tradeoff is described qualitatively and not established here with specific quantitative bounds. [Speculation]

### Related Topics

- Evidence Lower Bound (ELBO) derivation in detail
- Variational autoencoders (VAEs)
- Reparameterization trick and gradient estimators
- Mean-field theory and coordinate ascent variational inference (CAVI)
- Comparison of MCMC and variational methods
- Bayesian deep learning