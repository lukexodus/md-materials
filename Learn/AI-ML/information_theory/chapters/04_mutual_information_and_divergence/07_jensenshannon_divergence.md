## Jensen-Shannon Divergence

### Motivation

KL divergence has two practical limitations: it is asymmetric ($D_{KL}(P \parallel Q) \neq D_{KL}(Q \parallel P)$) and it can be undefined or infinite when $Q(x) = 0$ for some $x$ where $P(x) > 0$. Jensen-Shannon (JS) divergence was introduced to address both issues, producing a bounded, symmetric, and always-finite measure of distributional difference.

### Definition

Jensen-Shannon divergence between two distributions $P$ and $Q$ is defined using an intermediate "mixture" distribution $M$:

$$M = \frac{1}{2}(P + Q)$$

The JS divergence is then the average of the KL divergences of $P$ and $Q$ each measured against this mixture:

$$D_{JS}(P \parallel Q) = \frac{1}{2} D_{KL}(P \parallel M) + \frac{1}{2} D_{KL}(Q \parallel M)$$

Expanded fully in terms of the original distributions:

$$D_{JS}(P \parallel Q) = \frac{1}{2} \sum_x P(x) \log \frac{P(x)}{M(x)} + \frac{1}{2} \sum_x Q(x) \log \frac{Q(x)}{M(x)}$$

### Symmetry

Because $M$ is constructed symmetrically from $P$ and $Q$, swapping the two input distributions leaves the value unchanged:

$$D_{JS}(P \parallel Q) = D_{JS}(Q \parallel P)$$

This is a direct structural improvement over KL divergence, which has no such guarantee.

### Boundedness

When the logarithm is base 2, JS divergence is bounded:

$$0 \leq D_{JS}(P \parallel Q) \leq 1$$

When using the natural logarithm (base $e$), the upper bound becomes $\ln 2 \approx 0.693$. The lower bound of $0$ is achieved if and only if $P = Q$ almost everywhere. The upper bound is approached when $P$ and $Q$ have disjoint support (no overlapping probability mass).

**Key Points**
- JS divergence is always finite, even when $P$ and $Q$ have disjoint or partially disjoint support, because the mixture $M$ guarantees $M(x) > 0$ wherever either $P(x) > 0$ or $Q(x) > 0$.
- It is symmetric by construction, unlike raw KL divergence.
- Its square root, $\sqrt{D_{JS}(P \parallel Q)}$, satisfies the triangle inequality and is a true metric, commonly called the Jensen-Shannon distance.

### Relation to Mutual Information

JS divergence has an elegant interpretation in terms of mutual information. Consider a mixture experiment: flip a fair coin to decide whether to draw a sample from $P$ or from $Q$, and let $Z$ be a binary indicator of which distribution was chosen. Then:

$$D_{JS}(P \parallel Q) = I(X ; Z)$$

where $I(X ; Z)$ is the mutual information between the observed sample $X$ and the source-indicator variable $Z$. This means JS divergence measures how much information a sample reveals about which of the two distributions generated it — if $P$ and $Q$ are identical, observing $X$ tells you nothing about $Z$, giving $I(X;Z) = 0$.

### Derivation Sketch

Starting from the KL-based definition, substitute $M = \frac{1}{2}(P+Q)$ and expand:

$$D_{JS}(P \parallel Q) = \frac{1}{2}\sum_x P(x)\log\frac{2P(x)}{P(x)+Q(x)} + \frac{1}{2}\sum_x Q(x)\log\frac{2Q(x)}{P(x)+Q(x)}$$

This can be rewritten using entropy terms as:

$$D_{JS}(P \parallel Q) = H(M) - \frac{1}{2}H(P) - \frac{1}{2}H(Q)$$

where $H(M)$ is the Shannon entropy of the mixture distribution. This form shows JS divergence as the excess entropy of the mixture over the average entropy of its components — a direct consequence of the concavity of entropy (Jensen's inequality, from which the name derives).

**Example**
Let $P = [0.5, 0.5]$ and $Q = [0.9, 0.1]$ over a 2-outcome space.

The mixture is:
$$M = \left[\frac{0.5+0.9}{2}, \frac{0.5+0.1}{2}\right] = [0.7, 0.3]$$

Computing each component (using $\log_2$):
$$D_{KL}(P \parallel M) = 0.5 \log_2 \frac{0.5}{0.7} + 0.5 \log_2\frac{0.5}{0.3} \approx 0.5(-0.485) + 0.5(0.737) \approx 0.126$$

$$D_{KL}(Q \parallel M) = 0.9\log_2\frac{0.9}{0.7} + 0.1\log_2\frac{0.1}{0.3} \approx 0.9(0.363) + 0.1(-1.585) \approx 0.168$$

$$D_{JS}(P \parallel Q) = \frac{1}{2}(0.126) + \frac{1}{2}(0.168) \approx 0.147 \text{ bits}$$

This is well within the $[0,1]$ bound, reflecting moderate but not extreme divergence between the two distributions.

### Diagram: JS Divergence Construction

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 260">
  <text x="320" y="24" font-size="15" font-family="sans-serif" text-anchor="middle" fill="#222" font-weight="bold">Jensen-Shannon Divergence Construction (svg_diagram)</text>

  <rect x="40" y="60" width="160" height="50" fill="#a8d5ba" stroke="#333" stroke-width="1.5" />
  <text x="120" y="90" font-size="14" font-family="sans-serif" text-anchor="middle" fill="#111">P</text>

  <rect x="440" y="60" width="160" height="50" fill="#f4b183" stroke="#333" stroke-width="1.5" />
  <text x="520" y="90" font-size="14" font-family="sans-serif" text-anchor="middle" fill="#111">Q</text>

  <rect x="240" y="140" width="160" height="50" fill="#c9b8e8" stroke="#333" stroke-width="1.5" />
  <text x="320" y="170" font-size="14" font-family="sans-serif" text-anchor="middle" fill="#111">M = (P+Q)/2</text>

  <line x1="120" y1="110" x2="300" y2="140" stroke="#333" stroke-width="1.2" />
  <line x1="520" y1="110" x2="340" y2="140" stroke="#333" stroke-width="1.2" />

  <text x="215" y="130" font-size="11" font-family="sans-serif" fill="#333">D_KL(P‖M)</text>
  <text x="400" y="130" font-size="11" font-family="sans-serif" fill="#333">D_KL(Q‖M)</text>

  <rect x="180" y="220" width="280" height="30" fill="none" stroke="#333" stroke-width="1.2" stroke-dasharray="4,3" />
  <text x="320" y="240" font-size="12" font-family="sans-serif" text-anchor="middle" fill="#111">D_JS = avg of both KL terms</text>
</svg>

### Common Pitfalls

- Assuming JS divergence satisfies the triangle inequality directly — it does not; only its square root (the JS distance) is a proper metric.
- Confusing the bound value: the $[0,1]$ bound applies specifically to $\log_2$; using $\ln$ changes the upper bound to $\ln 2$.
- Treating JS divergence as interchangeable with KL divergence in optimization — because JS is bounded and smoother near disjoint supports, its gradient behavior differs, which is why it was historically favored in certain generative modeling objectives.
- [Inference] In practice, when $P$ and $Q$ are estimated from finite samples with disjoint empirical support, naive plug-in estimates of JS divergence can still be numerically unstable or biased for small sample sizes, though the population-level quantity itself remains well-defined and bounded.

### Applications

- **Generative Adversarial Networks (GANs)**: The original GAN objective was shown to correspond, at the optimal discriminator, to minimizing (a shifted, scaled version of) JS divergence between the real and generated data distributions.
- **Document and text similarity**: JS divergence between word-frequency distributions is used as a symmetric similarity measure in information retrieval and natural language processing.
- **Clustering and distribution comparison**: Used where a bounded, symmetric alternative to KL divergence is needed to compare probability distributions across different domains or datasets.

**Related Topics**
- Jensen's inequality and its role in entropy concavity
- f-divergences as the general family unifying KL, JS, and other divergence measures
- Total variation distance as an alternative bounded divergence
- Wasserstein distance and its comparison to JS divergence in generative modeling
- Mutual information estimation via divergence-based bounds
- Symmetrized KL divergence as a simpler (but unbounded) alternative to JS divergence