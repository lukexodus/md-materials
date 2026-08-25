## Wasserstein Distance

### Definition

Wasserstein distance, also known as Earth Mover's Distance (EMD), measures the minimum "cost" required to transform one probability distribution into another, where cost is defined as the amount of probability mass moved multiplied by the distance it is moved. It originates from the mathematical theory of optimal transport.

The general $p$-Wasserstein distance between distributions $P$ and $Q$ over a metric space is defined as:

$$W_p(P, Q) = \left( \inf_{\gamma \in \Gamma(P,Q)} \int \|x - y\|^p \, d\gamma(x,y) \right)^{1/p}$$

where $\Gamma(P, Q)$ denotes the set of all joint distributions (couplings) $\gamma(x, y)$ whose marginals are $P$ and $Q$ respectively.

The most commonly used variant in machine learning is the 1-Wasserstein distance ($p=1$), also called the Kantorovich-Rubinstein distance:

$$W_1(P, Q) = \inf_{\gamma \in \Gamma(P,Q)} \int \|x - y\| \, d\gamma(x,y)$$

### Intuition

A common informal explanation, sometimes called the "earth mover's" analogy, treats each distribution as a pile of dirt: $P$ describes one configuration of dirt piles, and $Q$ describes a target configuration. The Wasserstein distance corresponds to the minimum total effort (mass × distance) needed to reshape one pile configuration into the other. [Inference] This analogy is a widely used pedagogical device for building intuition about optimal transport, though it is a simplification and does not capture the full mathematical formalism of the infimum over couplings.

### Kantorovich-Rubinstein Duality

The 1-Wasserstein distance has an equivalent dual formulation that is more tractable for computation, particularly in machine learning contexts:

$$W_1(P, Q) = \sup_{\|f\|_L \leq 1} \left( \mathbb{E}_{x \sim P}[f(x)] - \mathbb{E}_{y \sim Q}[f(y)] \right)$$

where the supremum is taken over all 1-Lipschitz functions $f$ (functions whose rate of change is bounded by 1). This duality result is a standard, mathematically established theorem in optimal transport theory. It underlies the practical approach used in Wasserstein GANs, where a neural network is trained to approximate the 1-Lipschitz function $f$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340" font-family="sans-serif">
  <text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold">Wasserstein Distance as Optimal Transport (svg_diagram)</text>

  <line x1="50" y1="280" x2="650" y2="280" stroke="black" stroke-width="1.5" />
  <text x="640" y="300" font-size="11">x</text>

  <circle cx="130" cy="260" r="14" fill="#3b6fd4" opacity="0.8" />
  <circle cx="190" cy="260" r="10" fill="#3b6fd4" opacity="0.8" />
  <circle cx="250" cy="260" r="8" fill="#3b6fd4" opacity="0.8" />
  <text x="180" y="230" font-size="12" fill="#3b6fd4" font-weight="bold">P (source mass)</text>

  <circle cx="450" cy="260" r="8" fill="#d47b3b" opacity="0.8" />
  <circle cx="510" cy="260" r="10" fill="#d47b3b" opacity="0.8" />
  <circle cx="570" cy="260" r="14" fill="#d47b3b" opacity="0.8" />
  <text x="510" y="230" font-size="12" fill="#d47b3b" font-weight="bold">Q (target mass)</text>

  <path d="M 130 250 Q 300 150 450 250" fill="none" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)" />
  <path d="M 190 252 Q 320 170 510 252" fill="none" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)" />
  <path d="M 250 254 Q 380 190 570 254" fill="none" stroke="#888" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)" />

  <text x="350" y="310" text-anchor="middle" font-size="11" fill="#555">Dashed paths = mass transported from P to Q; distance moved factors into total cost</text>
</svg>

[Inference] This diagram is a simplified illustration of the transport-plan concept underlying Wasserstein distance. It does not represent an optimal transport plan computed from actual numerical data.

### Key Properties

**Key Points**
- **True metric**: The Wasserstein distance satisfies non-negativity, symmetry, identity of indiscernibles, and the triangle inequality, making it a valid metric on the space of probability distributions (for finite $p$-th moments). This is a mathematically established property.
- **Symmetry**: $W_p(P, Q) = W_p(Q, P)$.
- **Handles disjoint supports meaningfully**: Unlike KL divergence or standard JS divergence, Wasserstein distance provides a smooth, non-zero, and informative measure of distance even when $P$ and $Q$ have non-overlapping supports. This is frequently cited as a key theoretical motivation for its use in generative modeling. [Inference] The practical significance of this property for any specific training procedure depends on implementation details, and I do not have access to benchmark data to confirm the magnitude of this benefit in a given setting.
- **Sensitive to underlying geometry**: Unlike KL, JS, or TV distance, Wasserstein distance explicitly incorporates the distance metric of the underlying space ($\|x-y\|$), meaning it accounts for how "far apart" differing regions of probability mass are, not just how much mass differs.

### Comparison with Other Divergence Measures

| Property | KL Divergence | JS Divergence | Total Variation | Wasserstein ($W_1$) |
|----------|----------------|-----------------|--------------------|------------------------|
| Symmetric | No | Yes | Yes | Yes |
| True metric | No | No (sqrt is) | Yes | Yes |
| Meaningful under disjoint supports | No (undefined/infinite) | Yes (but can saturate) | Yes (but can saturate at 1) | Yes (varies smoothly) |
| Uses underlying space geometry | No | No | No | Yes |
| Common ML use case | MLE, cross-entropy loss | GAN theory | Robustness, privacy | WGAN, domain adaptation |

### Worked Example (1D Discrete Case)

For distributions on a 1-dimensional line, the 1-Wasserstein distance has a simplified closed-form computation using cumulative distribution functions (CDFs):

$$W_1(P, Q) = \int_{-\infty}^{\infty} |F_P(x) - F_Q(x)| \, dx$$

where $F_P$ and $F_Q$ are the cumulative distribution functions of $P$ and $Q$.

Consider two simple discrete distributions on integer support $\{1, 2, 3\}$:

| $x$ | $P(x)$ | $Q(x)$ | $F_P(x)$ | $F_Q(x)$ | $\lvert F_P - F_Q\rvert$ |
|-----|--------|--------|----------|----------|----------------------------|
| 1 | 0.5 | 0.0 | 0.5 | 0.0 | 0.5 |
| 2 | 0.3 | 0.2 | 0.8 | 0.2 | 0.6 |
| 3 | 0.2 | 0.8 | 1.0 | 1.0 | 0.0 |

For discrete, evenly spaced 1D support, the sum of absolute CDF differences (multiplied by the spacing between points, here equal to 1) approximates the integral:

$$W_1(P, Q) \approx |F_P(1) - F_Q(1)| + |F_P(2) - F_Q(2)| = 0.5 + 0.6 = 1.1$$

**Example**
This value reflects that $Q$ has shifted a substantial portion of its probability mass toward higher values of $x$ (mass concentrated at $x=3$) relative to $P$ (mass concentrated at $x=1$), and the distance metric captures both the amount of mass moved and the distance it traveled, unlike KL, JS, or TV distance, which would only reflect the pointwise probability differences.

### Applications in Machine Learning

- **Wasserstein GAN (WGAN)**: Uses the Kantorovich-Rubinstein dual formulation as a training objective, replacing the original GAN's JS-divergence-based discriminator with a "critic" network constrained to approximate 1-Lipschitz functions. This is a documented approach originating from published research on WGANs. [Unverified] I do not have the specific paper loaded in this context to quote from directly, and I am not able to verify exact implementation details of any particular WGAN codebase without inspecting it.
- **Domain Adaptation**: Wasserstein distance is used in some methods to measure and minimize the discrepancy between source and target domain feature distributions. [Unverified] I cannot verify performance claims for specific domain adaptation frameworks without a cited source.
- **Optimal Transport in Computer Vision**: Used for tasks such as image retrieval and shape matching, where the geometric sensitivity of Wasserstein distance is often relevant to comparing spatial distributions. [Inference] This application follows logically from the metric's geometric-awareness property described above, though I cannot verify comparative effectiveness against alternative methods without a specific citation.
- **Reinforcement Learning**: Some distributional reinforcement learning approaches use Wasserstein distance to compare return distributions. [Unverified] I do not have a specific source available to confirm current implementation details or empirical results for this application.

### Computational Considerations

Computing exact Wasserstein distance in high dimensions is generally more computationally expensive than computing KL, JS, or TV distance, since it requires solving an optimal transport problem (e.g., via linear programming or the Sinkhorn algorithm for entropy-regularized approximations). [Inference] This added computational cost is frequently cited as a practical trade-off against the metric's favorable theoretical properties, though exact runtime comparisons depend on problem dimensionality, implementation, and hardware, and I cannot verify specific benchmark figures without a cited source.

### Common Pitfalls

- Assuming Wasserstein distance is always straightforward to compute — in high-dimensional continuous settings, exact computation is generally intractable and requires approximation methods.
- Confusing $W_1$ with higher-order variants ($W_2$, etc.) — these are defined differently (different exponent $p$) and are not numerically interchangeable.
- Assuming the 1-Lipschitz constraint in the dual formulation is trivially enforced in neural network training — enforcing this constraint (e.g., via weight clipping or gradient penalty methods) is a nontrivial implementation detail. [Unverified] I cannot verify which specific enforcement method is most effective without a cited comparative source.

### Related Topics
- Kullback-Leibler Divergence (prerequisite concept)
- Jensen-Shannon Divergence
- Total Variation Distance
- Optimal Transport Theory
- Wasserstein GAN (WGAN) Architecture
- Sinkhorn Algorithm and Entropy-Regularized Optimal Transport
- Distributional Reinforcement Learning

> Correction note (per formatting preference): No unverified claims were presented as fact in this response; all uncertain statements above are labeled [Inference] or [Unverified] at the point they occur, per your standing instructions.