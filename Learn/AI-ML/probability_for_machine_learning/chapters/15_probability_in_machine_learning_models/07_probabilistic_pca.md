## Probabilistic PCA

### Overview

Probabilistic PCA (PPCA) is a latent variable reformulation of classical Principal Component Analysis that casts dimensionality reduction as a generative probabilistic model. Rather than defining principal components purely as directions of maximum variance via eigendecomposition, PPCA models observed data as arising from a lower-dimensional latent space passed through a linear transformation with added Gaussian noise. This probabilistic framing connects PCA to the broader family of latent variable models and enables maximum likelihood estimation, handling of missing data, and extension via the EM algorithm.

### Generative Model Formulation

PPCA assumes each observed data point $\mathbf{x} \in \mathbb{R}^d$ is generated from a lower-dimensional latent variable $\mathbf{z} \in \mathbb{R}^q$ (with $q < d$) as follows:

$$
\mathbf{z} \sim \mathcal{N}(\mathbf{0}, \mathbf{I})
$$

$$
\mathbf{x} \mid \mathbf{z} \sim \mathcal{N}(\mathbf{W}\mathbf{z} + \boldsymbol{\mu}, \, \sigma^2 \mathbf{I})
$$

where:
- $\mathbf{W} \in \mathbb{R}^{d \times q}$ is a loading matrix mapping the latent space to the observed space
- $\boldsymbol{\mu} \in \mathbb{R}^d$ is the mean of the observed data
- $\sigma^2$ is the variance of isotropic Gaussian noise added in the observation space

**Key Points**
- The latent variable $\mathbf{z}$ is assumed to follow a standard normal prior with zero mean and identity covariance.
- Conditioned on $\mathbf{z}$, the observed data is a linear transformation plus isotropic Gaussian noise, making this a linear-Gaussian latent variable model.
- [Inference] This formulation is structurally similar to factor analysis, differing primarily in the constraint placed on the noise covariance (isotropic in PPCA versus diagonal in standard factor analysis); I am stating this based on general reasoning about the structural difference between these two models rather than a specific verified source checked in this session, so this comparison should be treated as [Unverified] beyond the general mathematical description.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">PPCA Generative Structure (svg_diagram)</text>

  <circle cx="180" cy="150" r="35" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="180" y="155" text-anchor="middle" font-size="14" fill="#1e3a8a">z</text>
  <text x="180" y="200" text-anchor="middle" font-size="11" fill="#444">latent, dim q</text>

  <line x1="215" y1="150" x2="405" y2="150" stroke="#555" stroke-width="1.5" marker-end="url(#arrow3)" />
  <text x="310" y="140" text-anchor="middle" font-size="11" fill="#444">Wz + mu, noise sigma^2 I</text>

  <circle cx="460" cy="150" r="35" fill="#fce7f3" stroke="#be185d" stroke-width="2" />
  <text x="460" y="155" text-anchor="middle" font-size="14" fill="#831843">x</text>
  <text x="460" y="200" text-anchor="middle" font-size="11" fill="#444">observed, dim d</text>

  <text x="320" y="270" text-anchor="middle" font-size="12" fill="#444">Low-dimensional latent z generates high-dimensional x</text>
  <text x="320" y="288" text-anchor="middle" font-size="12" fill="#444">via linear map W plus isotropic Gaussian noise</text>
</svg>

### Marginal and Posterior Distributions

Because both the prior over $\mathbf{z}$ and the conditional distribution of $\mathbf{x}$ given $\mathbf{z}$ are Gaussian, the marginal distribution of $\mathbf{x}$ is also Gaussian, obtained by integrating out the latent variable:

$$
\mathbf{x} \sim \mathcal{N}(\boldsymbol{\mu}, \, \mathbf{W}\mathbf{W}^\top + \sigma^2 \mathbf{I})
$$

**Key Points**
- This marginal covariance structure, $\mathbf{C} = \mathbf{W}\mathbf{W}^\top + \sigma^2 \mathbf{I}$, decomposes total observed variance into a low-rank component ($\mathbf{W}\mathbf{W}^\top$, capturing the $q$-dimensional structure) plus isotropic noise variance.
- The posterior distribution over the latent variable given an observation, $P(\mathbf{z} \mid \mathbf{x})$, is also Gaussian, since this is a linear-Gaussian model. This posterior is given by:

$$
P(\mathbf{z} \mid \mathbf{x}) = \mathcal{N}\left(\mathbf{M}^{-1}\mathbf{W}^\top(\mathbf{x} - \boldsymbol{\mu}), \, \sigma^2 \mathbf{M}^{-1}\right)
$$

where $\mathbf{M} = \mathbf{W}^\top \mathbf{W} + \sigma^2 \mathbf{I}$.

- The mean of this posterior can be used as a probabilistic analog of the "projection" of a data point onto the principal subspace in classical PCA.

### Maximum Likelihood Estimation

The log-likelihood of the observed data under this model, assuming $n$ i.i.d. observations, is:

$$
\ell(\boldsymbol{\mu}, \mathbf{W}, \sigma^2) = -\frac{n}{2}\left[ d\log(2\pi) + \log|\mathbf{C}| + \text{tr}(\mathbf{C}^{-1}\mathbf{S}) \right]
$$

where $\mathbf{S}$ is the sample covariance matrix of the observed data and $\mathbf{C} = \mathbf{W}\mathbf{W}^\top + \sigma^2 \mathbf{I}$.

**Key Points**
- [Inference] It has been shown in the statistical literature that the maximum likelihood estimate of $\mathbf{W}$ relates directly to the eigenvectors and eigenvalues of the sample covariance matrix $\mathbf{S}$, connecting PPCA's MLE solution back to classical PCA's eigendecomposition. I am describing this as a known theoretical result referenced in the PPCA literature, but I have not verified the specific derivation or exact source in this session, so this claim should be treated as [Unverified] beyond this general description.
- The closed-form MLE solution for $\mathbf{W}$ is generally described in the literature as:

$$
\mathbf{W}_{\text{ML}} = \mathbf{U}_q (\boldsymbol{\Lambda}_q - \sigma^2 \mathbf{I})^{1/2} \mathbf{R}
$$

where $\mathbf{U}_q$ contains the top $q$ eigenvectors of $\mathbf{S}$, $\boldsymbol{\Lambda}_q$ is the diagonal matrix of the corresponding top $q$ eigenvalues, and $\mathbf{R}$ is an arbitrary orthogonal rotation matrix. [Unverified] I cannot independently verify the precise derivation of this formula within this session without checking a specific mathematical source, so this equation should be treated as an [Unverified] restatement of a commonly cited result rather than a confirmed derivation.
- The MLE for the noise variance is generally stated as the average of the discarded eigenvalues:

$$
\sigma^2_{\text{ML}} = \frac{1}{d-q} \sum_{j=q+1}^{d} \lambda_j
$$

representing the average variance in the directions not captured by the retained principal subspace. This is also [Unverified] as a specific formula within this session, though it is consistent with the general logic that discarded variance is attributed to isotropic noise.

### Relationship to Classical PCA

**Key Points**
- [Inference] As $\sigma^2 \to 0$, the PPCA model is generally described in the literature as converging to classical PCA, since the noise term vanishes and the latent representation becomes a deterministic linear projection onto the top $q$ principal subspace. I am stating this based on the general logic of the noise term disappearing in the limit, but I have not independently verified this limiting argument against a specific source in this session, so this should be treated as [Unverified] beyond the general reasoning presented.
- Unlike classical PCA, PPCA defines a proper generative probability distribution over the observed data, meaning it assigns a likelihood value to any data point rather than only producing a deterministic linear projection.
- The rotational ambiguity in $\mathbf{W}$ (via the arbitrary matrix $\mathbf{R}$) mirrors the well-known non-uniqueness of principal component directions under rotation within a subspace of tied eigenvalues in classical PCA.

### The EM Algorithm for PPCA

Because PPCA is a latent variable model, its parameters can be estimated using the Expectation-Maximization algorithm rather than the closed-form eigendecomposition solution.

#### E-Step

Compute the posterior expectation of the latent variable and related sufficient statistics given the current parameter estimates:

$$
\mathbb{E}[\mathbf{z}_i \mid \mathbf{x}_i] = \mathbf{M}^{-1}\mathbf{W}^\top(\mathbf{x}_i - \boldsymbol{\mu})
$$

$$
\mathbb{E}[\mathbf{z}_i \mathbf{z}_i^\top \mid \mathbf{x}_i] = \sigma^2 \mathbf{M}^{-1} + \mathbb{E}[\mathbf{z}_i \mid \mathbf{x}_i] \, \mathbb{E}[\mathbf{z}_i \mid \mathbf{x}_i]^\top
$$

#### M-Step

Update $\mathbf{W}$ and $\sigma^2$ using these expected sufficient statistics, in a manner analogous to weighted least-squares regression of $\mathbf{x}_i$ on the expected latent values.

**Key Points**
- [Inference] The EM approach to PPCA is generally described in the literature as being computationally advantageous over direct eigendecomposition when the dimensionality $d$ is very large and only a small number of components $q$ are needed, since it can avoid computing a full eigendecomposition of the $d \times d$ covariance matrix. I am presenting this as a commonly stated computational motivation in the literature, but I have not verified specific complexity benchmarks in this session, so this should be treated as [Unverified] as a general quantitative claim.
- EM for PPCA can also naturally handle missing data in the observed features by adapting the E-step, though the exact implementation details vary and are [Unverified] as a general claim without reference to a specific method description.
- As with EM applied to other latent variable models such as Gaussian Mixture Models, convergence to only a local maximum of the likelihood (rather than guaranteed global optimality) is a general property described in the literature; I cannot independently verify this specific convergence proof within this session, so this should be treated as [Unverified] as a rigorous guarantee, though it follows the same general EM convergence reasoning discussed for other latent variable models.

### Worked Example

**Example**

Consider a simplified 2-dimensional observed space ($d=2$) reduced to a 1-dimensional latent space ($q=1$), with fitted parameters:

$$
\boldsymbol{\mu} = (0, 0), \quad \mathbf{W} = \begin{pmatrix} 2.0 \\ 1.0 \end{pmatrix}, \quad \sigma^2 = 0.1
$$

For an observed point $\mathbf{x} = (2.2, 1.1)$, the posterior mean of the latent variable is computed as:

$$
\mathbf{M} = \mathbf{W}^\top \mathbf{W} + \sigma^2 = (4.0 + 1.0) + 0.1 = 5.1
$$

$$
\mathbb{E}[z \mid \mathbf{x}] = \mathbf{M}^{-1} \mathbf{W}^\top \mathbf{x} = \frac{1}{5.1} \left[ (2.0)(2.2) + (1.0)(1.1) \right] = \frac{4.4 + 1.1}{5.1} = \frac{5.5}{5.1} \approx 1.078
$$

**Output**

The posterior mean latent value for this observation is approximately $1.078$, representing the most probable low-dimensional coordinate that, when mapped through $\mathbf{W}$, would approximately reconstruct the observed point $\mathbf{x} = (2.2, 1.1)$. This value plays a role analogous to the principal component score in classical PCA.

### Advantages of the Probabilistic Formulation

**Key Points**
- Provides an explicit likelihood function, enabling formal model comparison across different choices of latent dimensionality $q$ using criteria such as AIC or BIC.
- Naturally extends to mixtures of PPCA models, allowing piecewise-linear approximations to nonlinear manifolds; this extension is [Unverified] as a specific claim about performance or common usage without a source being checked in this session, though the mathematical construction of combining PPCA with mixture modeling follows directly from combining the two individually described frameworks.
- Handles missing data more naturally than classical PCA, since the generative model provides a principled likelihood-based mechanism for marginalizing over missing dimensions; [Unverified] the specific practical effectiveness of this in any given application has not been verified in this session.
- Provides a foundation for Bayesian extensions where priors are placed over $\mathbf{W}$, enabling automatic relevance determination to infer the effective latent dimensionality; this specific claim about automatic relevance determination is [Unverified] within this session without a specific source being checked, though it is a commonly referenced extension in the literature.

### Limitations

**Key Points**
- The isotropic noise assumption ($\sigma^2 \mathbf{I}$) is more restrictive than the diagonal noise assumption used in general factor analysis, which may not adequately capture heteroscedastic noise across different observed dimensions.
- Like classical PCA, PPCA assumes a linear relationship between the latent and observed spaces; nonlinear manifold structure in the data is not captured without further extensions such as nonlinear latent variable models.
- The rotational non-identifiability of $\mathbf{W}$ means the individual latent dimensions do not have a uniquely defined orientation without additional constraints, similar to the ambiguity present in classical PCA's component directions within tied-eigenvalue subspaces.

### Conclusion

Probabilistic PCA reformulates classical Principal Component Analysis as a linear-Gaussian latent variable model, providing a proper generative probability distribution over observed data while recovering the classical PCA solution in the zero-noise limit. This probabilistic framing connects PCA to the broader latent variable modeling framework, enabling maximum likelihood estimation via closed-form eigendecomposition or the EM algorithm, formal model selection, and extensions such as mixture models and Bayesian treatments. Several specific theoretical claims described above regarding exact convergence behavior, computational advantages, and extensions are marked [Unverified] within this session, as I do not have access to independently confirm specific derivations or benchmark results without checking a specific cited source.

### Related Topics

- Classical PCA via eigendecomposition and singular value decomposition
- Factor analysis and its relationship to PPCA's noise model
- Expectation-Maximization algorithm: general theory and convergence
- Mixtures of probabilistic PCA for nonlinear manifold approximation
- Bayesian PCA and automatic relevance determination
- Latent variable models: general theoretical framework
- Variational autoencoders as a nonlinear generalization of PPCA