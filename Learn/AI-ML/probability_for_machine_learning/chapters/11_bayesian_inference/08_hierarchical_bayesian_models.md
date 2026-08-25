## Hierarchical Bayesian Models

### Overview

Hierarchical Bayesian models (also called multilevel models) structure parameters into multiple levels, where parameters of a prior distribution are themselves governed by hyperparameters drawn from a higher-level distribution. This structure allows information to be shared ("pooled") across related groups or units while still allowing each group its own parameters.

The defining feature is a chain of conditional dependencies:

$$
\theta_j \sim p(\theta_j \mid \phi), \quad \phi \sim p(\phi)
$$

$$
y_{ij} \sim p(y_{ij} \mid \theta_j)
$$

where $y_{ij}$ is observation $i$ in group $j$, $\theta_j$ is the group-level parameter, and $\phi$ is the hyperparameter shared across all groups.

### Motivation

**Key Points**
- Standard Bayesian models often assume either complete pooling (one shared parameter for all groups) or no pooling (independent parameters per group).
- Complete pooling ignores group-level differences; no pooling ignores shared structure and performs poorly with small per-group sample sizes.
- Hierarchical models interpolate between these extremes through **partial pooling**, where group estimates are shrunk toward a global mean, with the degree of shrinkage learned from the data.

### Structure of a Hierarchical Model

A typical three-level hierarchy:

1. **Hyperprior level**: $\phi \sim p(\phi)$ — distribution over hyperparameters.
2. **Prior level**: $\theta_j \sim p(\theta_j \mid \phi)$ — group-specific parameters conditioned on hyperparameters.
3. **Likelihood level**: $y_{ij} \sim p(y_{ij} \mid \theta_j)$ — observed data conditioned on group parameters.

The joint posterior is:

$$
p(\theta_{1:J}, \phi \mid y) \propto p(\phi) \prod_{j=1}^{J} p(\theta_j \mid \phi) \prod_{i=1}^{n_j} p(y_{ij} \mid \theta_j)
$$

This joint distribution generally has no closed form for anything beyond simple conjugate cases, so it is typically approximated via MCMC or variational inference. [Inference]

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 420">
\<style\>
  .lbl { font-family: sans-serif; font-size: 14px; fill: #222; }
  .sub { font-family: sans-serif; font-size: 12px; fill: #555; }
  .node { fill: #eef3fb; stroke: #34618f; stroke-width: 1.5; }
  .arrow { stroke: #34618f; stroke-width: 1.5; marker-end: url(#arrow); }
\</style\>
<text x="350" y="25" text-anchor="middle" class="lbl" font-weight="bold">Hierarchical Bayesian Structure (svg_diagram)</text>

<circle cx="350" cy="70" r="35" class="node" />
<text x="350" y="75" text-anchor="middle" class="lbl">φ</text>
<text x="350" y="118" text-anchor="middle" class="sub">Hyperparameter</text>

<circle cx="180" cy="200" r="35" class="node" />
<text x="180" y="205" text-anchor="middle" class="lbl">θ₁</text>
<circle cx="350" cy="200" r="35" class="node" />
<text x="350" y="205" text-anchor="middle" class="lbl">θ₂</text>
<circle cx="520" cy="200" r="35" class="node" />
<text x="520" y="205" text-anchor="middle" class="lbl">θⱼ</text>
<text x="350" y="248" text-anchor="middle" class="sub">Group-level parameters</text>

<circle cx="180" cy="340" r="30" class="node" />
<text x="180" y="345" text-anchor="middle" class="lbl">y₁ᵢ</text>
<circle cx="350" cy="340" r="30" class="node" />
<text x="350" y="345" text-anchor="middle" class="lbl">y₂ᵢ</text>
<circle cx="520" cy="340" r="30" class="node" />
<text x="520" y="345" text-anchor="middle" class="lbl">yⱼᵢ</text>
<text x="350" y="388" text-anchor="middle" class="sub">Observed data per group</text>

<line x1="330" y1="95" x2="200" y2="175" class="arrow" />
<line x1="350" y1="105" x2="350" y2="165" class="arrow" />
<line x1="370" y1="95" x2="500" y2="175" class="arrow" />

<line x1="180" y1="235" x2="180" y2="310" class="arrow" />
<line x1="350" y1="235" x2="350" y2="310" class="arrow" />
<line x1="520" y1="235" x2="520" y2="310" class="arrow" />
</svg>

### Partial Pooling and Shrinkage

In partial pooling, each group estimate $\hat\theta_j$ is pulled toward the overall mean $\hat\phi$, with the amount of shrinkage determined by the relative variance between groups and within groups.

A common illustrative case — the normal-normal hierarchical model:

$$
\theta_j \mid \phi, \tau^2 \sim \mathcal{N}(\phi, \tau^2), \quad y_{ij} \mid \theta_j \sim \mathcal{N}(\theta_j, \sigma^2)
$$

The posterior mean for group $j$ approximates a weighted average:

$$
\mathbb{E}[\theta_j \mid y] \approx \lambda_j \bar{y}_j + (1 - \lambda_j)\hat\phi
$$

where $\lambda_j = \dfrac{n_j / \sigma^2}{n_j/\sigma^2 + 1/\tau^2}$ is the shrinkage weight for group $j$. Groups with fewer observations ($n_j$ small) are shrunk more strongly toward the global mean $\hat\phi$. This is a standard derivation result for the conjugate normal-normal hierarchical case [Unverified — exact form depends on model parameterization and referenced source].

### Example

**Example**
Estimating student test scores across multiple schools:
- **No pooling**: each school's average is estimated independently — noisy for schools with few students.
- **Complete pooling**: a single average across all schools — ignores real differences between schools.
- **Hierarchical (partial pooling)**: each school gets its own estimated mean $\theta_j$, but all $\theta_j$ are drawn from a shared distribution governed by $\phi$ (the overall district mean) and $\tau^2$ (between-school variance). Schools with small sample sizes get pulled more toward the district average; schools with large sample sizes remain closer to their own observed average.

### Inference Methods

- **Markov Chain Monte Carlo (MCMC)**: Gibbs sampling and Hamiltonian Monte Carlo (e.g., via Stan or PyMC) are commonly used for hierarchical posteriors, especially with non-conjugate priors. [Inference — commonality based on typical practice, not a universal claim]
- **Variational Inference (VI)**: approximates the posterior with a simpler parametric family, offering faster but approximate inference; approximation quality varies by model and is not guaranteed to match MCMC accuracy.
- **Empirical Bayes**: estimates hyperparameters $\phi$ by maximizing the marginal likelihood rather than placing a full prior on $\phi$, which is a simplification that avoids full hyperprior specification but may understate uncertainty. [Inference]

### Non-Centered Parameterization

Hierarchical models, particularly with small between-group variance $\tau$, are known to exhibit poor sampling geometry in MCMC (the "funnel" problem), which can slow convergence or bias estimates. [Unverified — degree of impact depends on sampler, data, and model specifics]

A common mitigation is the **non-centered parameterization**:

$$
\theta_j = \phi + \tau \cdot \tilde\theta_j, \quad \tilde\theta_j \sim \mathcal{N}(0, 1)
$$

This reparameterization separates the group-level parameter from direct dependence on $\tau$, which can improve sampler behavior in some cases. It does not eliminate all sampling difficulties, and results may vary by model. [Inference]

### Hierarchical Models in Machine Learning

- **Multi-task learning**: hierarchical priors allow tasks to share statistical strength while retaining task-specific parameters.
- **Mixed-effects models**: combine fixed effects (shared across all data) with random effects (group-specific), commonly used in longitudinal or grouped data analysis.
- **Bayesian neural networks with grouped data**: hierarchical priors over weights can be used when data naturally clusters into groups (e.g., per-user or per-device models), though this increases model complexity and computational cost. [Inference]
- **Topic models** (e.g., Hierarchical Dirichlet Process): use hierarchical structure to allow the number of latent topics to be inferred from data rather than fixed in advance.

### Model Diagnostics

**Key Points**
- **Posterior predictive checks**: compare simulated data from the fitted model against observed data to assess fit.
- **Divergences** (in HMC/NUTS samplers): indicate regions of the posterior where the sampler failed to explore accurately, often linked to funnel geometry in hierarchical models.
- **$\hat{R}$ (R-hat) statistic**: used to assess MCMC chain convergence; values close to 1.0 are typically considered acceptable, though exact thresholds vary by source and are not a strict guarantee of convergence. [Unverified]
- **Effective sample size (ESS)**: estimates the number of independent samples equivalent to the correlated MCMC draws obtained.

### Advantages and Limitations

**Key Points**
- *Advantages*: better handling of unbalanced group sizes, natural uncertainty quantification at multiple levels, ability to generalize to new/unseen groups via the population-level distribution.
- *Limitations*: increased model and computational complexity, sensitivity to hyperprior choice especially with few groups, potential sampling difficulties (funnel geometry), and interpretability challenges compared to simpler pooled models.

### Conclusion

Hierarchical Bayesian models provide a principled framework for modeling grouped or nested data by sharing statistical strength across groups while preserving group-specific variation. Their effectiveness depends on the chosen structure, priors, and inference method, and outcomes such as improved estimation accuracy are context-dependent rather than guaranteed. [Inference]

### Related Topics

- Bayesian Inference — Empirical Bayes methods
- Markov Chain Monte Carlo (MCMC) — Gibbs sampling, Hamiltonian Monte Carlo, NUTS
- Variational Inference for hierarchical posteriors
- Mixed-effects and multilevel regression models
- Hierarchical Dirichlet Processes and nonparametric Bayesian models
- Bayesian Neural Networks and structured priors
- Model diagnostics: posterior predictive checks, R-hat, divergence analysis