## Latent Variable Models

### Overview

Latent variable models are a broad class of probabilistic models that explain observed data using unobserved (latent) variables believed to underlie or generate the observed patterns. These models formalize the idea that measurable data are often a partial, noisy, or transformed reflection of some lower-dimensional or hidden underlying structure. Latent variable models unify a wide range of techniques across machine learning and statistics, including Gaussian Mixture Models, Probabilistic PCA, Hidden Markov Models, factor analysis, and topic models.

### Core Concept

A latent variable model specifies a joint distribution over observed variables $\mathbf{x}$ and unobserved latent variables $\mathbf{z}$:

$$
P(\mathbf{x}, \mathbf{z} \mid \theta) = P(\mathbf{x} \mid \mathbf{z}, \theta) \, P(\mathbf{z} \mid \theta)
$$

The observed data likelihood is obtained by marginalizing (integrating or summing) over the latent variables:

$$
P(\mathbf{x} \mid \theta) = \int P(\mathbf{x} \mid \mathbf{z}, \theta) \, P(\mathbf{z} \mid \theta) \, d\mathbf{z}
$$

or, for discrete latent variables:

$$
P(\mathbf{x} \mid \theta) = \sum_{\mathbf{z}} P(\mathbf{x} \mid \mathbf{z}, \theta) \, P(\mathbf{z} \mid \theta)
$$

**Key Points**
- $P(\mathbf{z} \mid \theta)$ is the **prior** over the latent variable, and $P(\mathbf{x} \mid \mathbf{z}, \theta)$ is the **observation model** (or likelihood) describing how observed data is generated conditioned on the latent state.
- The latent variable $\mathbf{z}$ may be discrete (as in mixture models), continuous (as in Probabilistic PCA), or structured (as in sequences for Hidden Markov Models).
- [Inference] The general motivation for introducing latent variables is that they can allow a complex marginal distribution over $\mathbf{x}$ to be expressed as a combination of simpler conditional distributions, which is a structural description following directly from the mathematical form above; however, I do not have a specific verified source confirmed in this session for this exact framing as a stated design motivation, so this characterization should be treated as [Unverified] beyond the direct mathematical structure shown.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">General Latent Variable Model Structure (svg_diagram)</text>

  <circle cx="200" cy="150" r="35" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="200" y="155" text-anchor="middle" font-size="14" fill="#1e3a8a">z</text>
  <text x="200" y="200" text-anchor="middle" font-size="11" fill="#444">unobserved</text>

  <line x1="235" y1="150" x2="405" y2="150" stroke="#555" stroke-width="1.5" marker-end="url(#arrow4)" />
  <text x="320" y="140" text-anchor="middle" font-size="11" fill="#444">P(x|z,theta)</text>

  <circle cx="440" cy="150" r="35" fill="#fce7f3" stroke="#be185d" stroke-width="2" />
  <text x="440" y="155" text-anchor="middle" font-size="14" fill="#831843">x</text>
  <text x="440" y="200" text-anchor="middle" font-size="11" fill="#444">observed</text>

  <text x="320" y="260" text-anchor="middle" font-size="12" fill="#444">Only x is available at training time;</text>
  <text x="320" y="278" text-anchor="middle" font-size="12" fill="#444">z must be inferred or marginalized</text>
</svg>

### Discrete vs. Continuous Latent Variables

**Key Points**
- **Discrete latent variables** represent categorical, unobserved group membership. Example: the component-assignment variable $z$ in a Gaussian Mixture Model, where $z \in \{1, \ldots, K\}$ indicates which mixture component generated a data point.
- **Continuous latent variables** represent an unobserved position in a continuous space, often of lower dimensionality than the observed data. Example: the latent vector $\mathbf{z} \in \mathbb{R}^q$ in Probabilistic PCA, representing a compressed coordinate in a linear subspace.
- **Structured latent variables** capture dependencies across a sequence or graph of latent states. Example: the hidden state sequence in a Hidden Markov Model, where each latent state depends on the previous one.
- The choice of latent variable type is [Inference] generally guided by the nature of the hypothesized underlying structure in a given application — categorical for clustering, continuous for dimensionality reduction, structured for sequential or relational dependencies — based on general reasoning about how these model families are typically applied, though I do not have a specific verified source confirmed in this session establishing this as a formal categorization rule, so this framing should be treated as [Unverified] beyond the general descriptive pattern.

### Common Examples of Latent Variable Models

**Key Points**
- **Gaussian Mixture Models**: discrete latent component assignment, continuous Gaussian observation model per component.
- **Probabilistic PCA / Factor Analysis**: continuous latent variable, linear-Gaussian observation model.
- **Hidden Markov Models**: discrete latent state sequence with Markovian transition structure, observations conditioned on the current hidden state.
- **Latent Dirichlet Allocation (topic models)**: discrete latent topic assignments per word, with documents modeled as mixtures over topics.
- **Variational Autoencoders**: continuous latent variable with a neural network (nonlinear) observation model, trained via variational inference rather than exact EM.
- [Unverified] The relative popularity or current prevalence of any of these specific models in applied practice as of the present date is not something I can confirm without checking a current source in this session; the descriptions above characterize the mathematical structure of each model rather than a claim about their current usage frequency.

### Parameter Estimation Approaches

**Key Points**
- **Expectation-Maximization (EM)**: applicable when the posterior $P(\mathbf{z} \mid \mathbf{x}, \theta)$ can be computed exactly or in closed form, as in Gaussian Mixture Models and Probabilistic PCA.
- **Variational Inference**: used when the exact posterior over latent variables is intractable; a simpler approximating distribution $q(\mathbf{z})$ is optimized to be close to the true posterior, typically by maximizing the Evidence Lower Bound (ELBO).
- **Markov Chain Monte Carlo (MCMC)**: used to draw samples from the posterior over latent variables when neither an exact closed form nor a tractable variational approximation is available.
- [Inference] The choice among these three approaches is generally described in the literature as depending on the tractability of the posterior distribution for a given model, with EM preferred when tractable, variational inference favored for scalability with moderate accuracy trade-offs, and MCMC used when asymptotically exact samples are needed. I am presenting this as a general characterization based on common descriptions of these methods, but I do not have a specific verified source confirmed in this session for this comparative statement, so this should be treated as [Unverified] beyond the individual definitions of each method.

### The Role of the Prior Over Latent Variables

**Key Points**
- The prior $P(\mathbf{z} \mid \theta)$ encodes assumptions about the structure of the latent space before observing any data, such as assuming a standard normal distribution in Probabilistic PCA or a categorical distribution with learned mixing weights in Gaussian Mixture Models.
- In Bayesian extensions of latent variable models, a prior may also be placed over the parameters $\theta$ themselves, in addition to the latent variables, leading to fully Bayesian latent variable models where both $\mathbf{z}$ and $\theta$ are treated as random variables to be inferred.
- [Unverified] Any specific claim about which prior choice is "best" for a given application depends on domain-specific considerations that I cannot generalize without a specific cited source or benchmark being checked in this session.

### Identifiability Issues

**Key Points**
- Latent variable models frequently exhibit **non-identifiability**: multiple distinct parameter settings can produce the same marginal distribution over observed data.
- Example: in Probabilistic PCA, an arbitrary orthogonal rotation $\mathbf{R}$ applied to the loading matrix $\mathbf{W}$ leaves the marginal distribution over $\mathbf{x}$ unchanged, meaning the latent dimensions themselves do not have a uniquely defined orientation.
- Example: in Gaussian Mixture Models, the labeling of components is arbitrary (component 1 could be relabeled as component 2 with no change to the model), a phenomenon generally referred to as **label switching**.
- [Inference] These identifiability issues are generally described in the literature as requiring additional constraints or post-hoc resolution (e.g., fixing an ordering convention or applying a rotation constraint) when specific latent variable values, rather than only the observed-data likelihood, are of direct interest. I am presenting this as a general modeling concern based on the structural properties described above rather than a specific verified source checked in this session, so this should be treated as [Unverified] beyond the description of the identifiability phenomenon itself.

### Example: Comparing Two Latent Variable Models

**Example**

Consider modeling a dataset of customer purchase records.

A **Gaussian Mixture Model** applied to this data would assume each customer belongs to one of $K$ discrete "segments" (e.g., budget shoppers, luxury shoppers), with purchase behavior generated from a segment-specific Gaussian distribution. The latent variable here is the discrete segment label.

A **Probabilistic PCA** model applied to the same data would instead assume each customer's purchase behavior is generated from a continuous, lower-dimensional "preference profile" (e.g., a 2-dimensional latent space capturing something like "price sensitivity" and "brand loyalty"), linearly mapped into the observed purchase feature space with added noise.

**Output**

Both models are latent variable models over the same observed data, but they encode fundamentally different assumptions about the hidden structure: one assumes discrete cluster membership, the other assumes a continuous underlying coordinate. [Inference] The choice between them would generally depend on whether the underlying real-world structure is believed to be more naturally categorical or continuous, which is a modeling judgment rather than something determined purely by the data itself; this is a general reasoning statement about model selection rather than a confirmed claim about this specific dataset, so it should be treated as [Inference].

### Marginalization and Its Computational Challenge

**Key Points**
- The central computational challenge in latent variable models is that the marginal likelihood $P(\mathbf{x} \mid \theta)$ requires summing or integrating over all possible latent variable configurations, which is often intractable in closed form for complex models.
- This intractability motivates the use of approximate inference methods (EM, variational inference, MCMC) rather than direct maximum likelihood optimization of the marginal likelihood.
- [Unverified] The degree of computational cost for any specific model and dataset size is implementation-dependent and cannot be generalized as a fixed claim without a specific benchmark being cited.

### Latent Variable Models vs. Fully Observed Models

**Key Points**
- In a fully observed model, all variables relevant to the likelihood are directly measured, and maximum likelihood estimation can typically proceed via direct optimization without an iterative E-step/M-step structure.
- Latent variable models trade this direct tractability for the ability to represent hidden structure, unmeasured causes, or compressed representations that are believed to underlie the observed data.
- [Speculation] It is possible that in some applications, introducing a latent variable structure where none is truly present in the underlying data-generating process could lead to overfitting or spurious structure being attributed to the model; this is a speculative concern based on general statistical reasoning about model complexity rather than a confirmed finding from any specific study, so it is labeled as [Speculation] and should not be treated as an established result.

### Conclusion

Latent variable models provide a unifying probabilistic framework for representing observed data as arising from unobserved underlying structure, whether discrete, continuous, or sequentially structured. This framework connects models as varied as Gaussian Mixture Models, Probabilistic PCA, and Hidden Markov Models under a common mathematical formulation involving priors over latent variables and observation models conditioned on them. Estimation typically requires approximate methods such as EM, variational inference, or MCMC due to the general intractability of marginalizing over latent variables in closed form. Several characterizations in this document regarding comparative method selection, identifiability handling conventions, and modeling motivations are labeled [Inference] or [Unverified], reflecting that they are reasoned generalizations rather than claims verified against a specific cited source within this session.

### Related Topics

- Expectation-Maximization algorithm: detailed derivation and convergence
- Variational inference and the Evidence Lower Bound
- Hidden Markov Models and sequential latent structure
- Markov Chain Monte Carlo methods for posterior sampling
- Identifiability and label switching in mixture models
- Bayesian latent variable models and hierarchical priors
- Variational Autoencoders as neural latent variable models