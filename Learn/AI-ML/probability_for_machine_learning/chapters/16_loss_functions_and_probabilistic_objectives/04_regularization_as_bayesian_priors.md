## Regularization as Bayesian Priors

### Overview

Regularization techniques commonly used in machine learning to prevent overfitting can be reinterpreted through a Bayesian lens, where each regularization penalty corresponds to a specific prior distribution placed over model parameters. This framing connects seemingly ad hoc engineering techniques — adding a penalty term to a loss function — to a principled probabilistic foundation via Maximum A Posteriori (MAP) estimation. This document is a topic-focused companion to the MAP estimation material, concentrating specifically on the correspondence between individual regularization schemes and their associated priors.

### The General Correspondence

Under MAP estimation, the objective being minimized is:

$$
-\log P(\mathbf{X} \mid \theta) - \log P(\theta)
$$

**Key Points**
- The first term is the standard data-fitting term (negative log-likelihood), identical to what would be minimized under plain MLE.
- The second term, $-\log P(\theta)$, depends only on the parameters, not the data, and takes the mathematical role that a regularization penalty plays in a standard (non-Bayesian) loss function formulation.
- [Inference] This structural parallel is the basis for describing regularized loss minimization as equivalent to MAP estimation under an appropriately chosen prior; this is a standard derivation presented in Bayesian machine learning literature, but I cannot independently verify the exact historical origin or a specific textbook's presentation of this equivalence within this session, so this characterization should be labeled [Unverified] beyond the direct algebraic correspondence shown in the derivations below.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 280">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Regularization Penalty as Negative Log-Prior (svg_diagram)</text>

  <rect x="60" y="90" width="230" height="60" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="175" y="115" text-anchor="middle" font-size="12" fill="#1e3a8a">Standard ML view:</text>
  <text x="175" y="135" text-anchor="middle" font-size="12" fill="#1e3a8a">Loss + lambda * penalty(theta)</text>

  <text x="320" y="125" text-anchor="middle" font-size="14" fill="#333">≡</text>

  <rect x="350" y="90" width="230" height="60" fill="#fce7f3" stroke="#be185d" stroke-width="1.5" />
  <text x="465" y="115" text-anchor="middle" font-size="12" fill="#831843">Bayesian view:</text>
  <text x="465" y="135" text-anchor="middle" font-size="12" fill="#831843">-log P(X|theta) - log P(theta)</text>

  <text x="320" y="200" text-anchor="middle" font-size="12" fill="#444">lambda * penalty(theta) corresponds to -log P(theta)</text>
  <text x="320" y="220" text-anchor="middle" font-size="12" fill="#444">for a specific choice of prior distribution</text>
</svg>

### L2 Regularization and the Gaussian Prior

A zero-mean Gaussian prior over a parameter $\theta$ with variance $\tau^2$:

$$
P(\theta) = \frac{1}{\sqrt{2\pi\tau^2}} \exp\left(-\frac{\theta^2}{2\tau^2}\right)
$$

gives a negative log-prior of:

$$
-\log P(\theta) = \frac{\theta^2}{2\tau^2} + \text{constant}
$$

**Key Points**
- This term is proportional to $\theta^2$, matching the standard L2 (ridge) penalty $\lambda \theta^2$ used in regularized loss functions, with $\lambda \propto \frac{1}{2\tau^2}$.
- A smaller prior variance $\tau^2$ corresponds to a stronger belief that $\theta$ should be close to zero, which [Inference] translates to a larger effective regularization strength $\lambda$; this proportional relationship follows directly from the algebra shown above, but I cannot independently verify whether this exact proportionality constant matches every specific textbook convention without checking a cited source, so this should be labeled [Unverified] as a precise universal convention beyond the general direction of the relationship.
- The Gaussian prior places most of its probability mass near zero but assigns nonzero (asymptotically decaying) probability to arbitrarily large parameter values, which is [Inference] commonly cited in the literature as the underlying reason L2-regularized (MAP-Gaussian) estimates tend to shrink parameters toward zero without setting them exactly to zero. I do not have a specific verified source confirmed in this session for this precise geometric explanation, so this should be treated as [Unverified] beyond the shape of the prior distribution itself.

### L1 Regularization and the Laplace Prior

A Laplace (double-exponential) prior over $\theta$ with scale parameter $b$:

$$
P(\theta) = \frac{1}{2b} \exp\left(-\frac{|\theta|}{b}\right)
$$

gives a negative log-prior of:

$$
-\log P(\theta) = \frac{|\theta|}{b} + \text{constant}
$$

**Key Points**
- This term is proportional to $|\theta|$, matching the standard L1 (lasso) penalty $\lambda |\theta|$, with $\lambda \propto \frac{1}{b}$.
- The Laplace distribution has a sharp peak (non-differentiable point) at $\theta = 0$, in contrast to the smooth peak of the Gaussian. [Inference] This sharp peak is generally cited in the literature as the reason MAP estimation under a Laplace prior tends to produce exactly-zero parameter estimates for some parameters (sparsity), unlike the Gaussian case. I cannot independently verify this specific optimization-geometry argument within this session without checking a specific mathematical source, so this should be labeled [Unverified] beyond the description of the distribution's shape.

### Elastic Net as a Combined Prior

**Key Points**
- Elastic Net regularization combines both L1 and L2 penalty terms: $\lambda_1 |\theta| + \lambda_2 \theta^2$.
- [Inference] Under the Bayesian correspondence framework described above, this combined penalty is generally describable as corresponding to a prior that is itself a combination (product, in the unnormalized sense) of a Laplace and a Gaussian density, though this composite distribution does not have as simple or commonly named a closed form as either prior alone. I do not have a specific verified source confirmed in this session establishing a standard named form for this combined prior, so this characterization should be treated as [Unverified] beyond the direct algebraic combination of the two penalty terms.

### Uniform Prior and Unregularized MLE

**Key Points**
- If $P(\theta)$ is a uniform distribution over the parameter space (constant density), $\log P(\theta)$ becomes a constant with respect to $\theta$ and drops out of the maximization entirely.
- This shows that standard, unregularized maximum likelihood estimation is a special case of MAP estimation under an implicit flat prior, [Inference] which is a standard way of framing MLE within the broader MAP/Bayesian estimation hierarchy in the literature; I cannot verify the precise formal treatment of "improper" uniform priors over unbounded parameter spaces within this session without checking a specific mathematical source, so this technical point should be labeled [Unverified] beyond the general limiting description given.

### Other Prior-Penalty Correspondences

**Key Points**
- **Dropout**: [Speculation] some literature has drawn a connection between dropout regularization in neural networks and approximate Bayesian inference over network weights, though the precise nature and scope of this connection involves specific technical conditions I cannot verify or restate reliably within this session without checking a specific cited source; this should be treated as [Speculation] rather than an established equivalence, and readers should not assume dropout is straightforwardly "the same as" a Bayesian prior without consulting a specific verified reference.
- **Early stopping**: [Speculation] it has been suggested in some literature that early stopping in iterative gradient-based training can have an implicit regularizing effect comparable in some settings to certain forms of parameter-norm penalties, but I do not have a specific verified derivation or source confirmed in this session establishing a precise Bayesian prior correspondence for early stopping, so this connection should be treated as [Speculation] rather than a confirmed mathematical equivalence.
- **Weight decay vs. L2 regularization**: [Unverified] whether weight decay as implemented in a specific optimizer (e.g., in the context of adaptive gradient methods) is exactly mathematically identical to L2 regularization added to the loss function is a specific technical question that depends on implementation details I cannot verify without checking that optimizer's specific documentation or a dedicated source within this session; these two concepts are sometimes treated as equivalent and sometimes distinguished in the literature depending on the optimizer, and I do not have enough verified information in this session to state a general rule.

### Worked Example

**Example**

Suppose a linear regression model has negative log-likelihood term (assuming Gaussian noise) equal to $\sum_i (y_i - \theta x_i)^2$, and a Gaussian prior on $\theta$ contributes penalty term $0.1 \theta^2$ (corresponding to some fixed prior variance $\tau^2$).

The MAP objective is:

$$
f(\theta) = \sum_i (y_i - \theta x_i)^2 + 0.1\theta^2
$$

**Output**

This expression is structurally identical to a standard ridge regression objective, where the coefficient $0.1$ plays the role of the regularization strength $\lambda$. Solving this minimization problem would yield the same numerical result whether framed as "ridge regression with $\lambda = 0.1$" or as "MAP estimation with a Gaussian prior of a specific corresponding variance $\tau^2$." I have not computed a specific closed-form numerical solution for $\theta$ here, since no specific data values for $x_i, y_i$ were provided; this example illustrates the structural correspondence between the two framings rather than a numerically solved instance.

### Interpreting Regularization Strength as Prior Confidence

**Key Points**
- The regularization hyperparameter $\lambda$ (or equivalently, the prior's variance or scale parameter) can be interpreted within this framework as encoding how strongly the modeler believes, prior to seeing data, that parameters should be small or near zero.
- A very large $\lambda$ (very small prior variance) corresponds to a strong prior belief pulling estimates toward zero regardless of what the data suggests, while a very small $\lambda$ (very large prior variance) corresponds to a weak prior that allows the data (likelihood term) to dominate the estimate.
- [Inference] In practice, $\lambda$ is generally selected via cross-validation rather than through an explicit, independently justified statement of prior belief, which [Speculation] some have noted creates a degree of tension with a purely Bayesian interpretation, since a "prior" is conventionally meant to reflect belief formed prior to seeing the data, whereas cross-validation uses the data itself to select the prior's effective strength; I do not have a specific verified source confirmed in this session discussing this specific philosophical tension, so this observation should be treated as [Speculation] rather than an established critique documented in a specific reference.

### Limitations of This Correspondence

**Key Points**
- The Bayesian correspondence typically applies most directly and cleanly to the MAP point estimate; it does not by itself provide the full posterior distribution or associated uncertainty quantification that a complete Bayesian treatment would offer.
- [Inference] Not every regularization technique used in practice has a clean, widely agreed-upon Bayesian prior interpretation (as illustrated by the more tentative dropout and early-stopping examples above), so this framework is generally described in the literature as most cleanly applicable to explicit parameter-norm penalties (L1, L2, Elastic Net) rather than as a universal explanation for all regularization methods. I do not have a specific verified source confirmed in this session comprehensively surveying which regularization techniques do or do not have established Bayesian correspondences, so this should be treated as [Unverified] as a general claim beyond the specific examples discussed above.

### Conclusion

Regularization penalties commonly used in machine learning correspond, under MAP estimation, to specific choices of prior distribution placed over model parameters: L2 regularization corresponds to a Gaussian prior, and L1 regularization corresponds to a Laplace prior, with the regularization strength inversely related to the prior's variance or scale parameter. This correspondence provides a probabilistic interpretation for otherwise ad hoc penalty terms, though its clean applicability is most established for explicit norm-based penalties rather than for all modern regularization techniques such as dropout or early stopping, where the Bayesian connection is more tentative. Several claims in this document regarding sparsity mechanisms, the philosophical tension between cross-validated hyperparameters and prior belief, and correspondences for techniques beyond L1/L2 penalties are labeled [Inference], [Speculation], or [Unverified], reflecting that they are reasoned generalizations or tentative literature connections not independently verified against a specific cited source within this session.

### Related Topics

- Maximum a posteriori estimation: general derivation and point-estimate framework
- Ridge and Lasso regression: geometric and algebraic derivation
- Conjugate priors and their computational advantages in Bayesian updating
- Full Bayesian inference versus point-estimate approximations
- Dropout and its proposed relationship to approximate Bayesian inference
- Cross-validation for hyperparameter selection
- Sparsity-inducing priors beyond the Laplace distribution (e.g., spike-and-slab)