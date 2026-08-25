## Kullback-Leibler Divergence

### Definition

The Kullback-Leibler (KL) divergence is a measure of how one probability distribution $Q$ diverges from a reference probability distribution $P$. It is not a true distance metric, since it is asymmetric and does not satisfy the triangle inequality.

For discrete probability distributions $P$ and $Q$ defined over the same probability space:

$$D_{KL}(P \parallel Q) = \sum_{x} P(x) \log \frac{P(x)}{Q(x)}$$

For continuous distributions with probability density functions $p(x)$ and $q(x)$:

$$D_{KL}(P \parallel Q) = \int_{-\infty}^{\infty} p(x) \log \frac{p(x)}{q(x)} \, dx$$

$P$ is typically treated as the "true" or reference distribution, and $Q$ as the approximating distribution.

### Intuition

KL divergence quantifies the expected number of extra bits (if using $\log_2$) or nats (if using $\log_e$) required to encode samples from $P$ when using a code optimized for $Q$ instead of the true distribution $P$. This framing comes from information theory and coding theory.

- $D_{KL}(P \parallel Q) = 0$ if and only if $P = Q$ almost everywhere.
- $D_{KL}(P \parallel Q) \geq 0$ always (non-negativity), a result known as Gibbs' inequality.
- Larger values indicate greater divergence between the two distributions.

### Key Properties

**Key Points**
- **Non-negativity**: $D_{KL}(P \parallel Q) \geq 0$, with equality only when $P = Q$.
- **Asymmetry**: $D_{KL}(P \parallel Q) \neq D_{KL}(Q \parallel P)$ in general. This means KL divergence is not a metric in the mathematical sense.
- **Not symmetric, no triangle inequality**: These two facts together mean KL divergence should be understood as a directed "divergence," not a distance.
- **Undefined/infinite cases**: If there exists an $x$ such that $Q(x) = 0$ but $P(x) > 0$, then $D_{KL}(P \parallel Q)$ is undefined or diverges to infinity. This is because the reference distribution $P$ assigns probability mass to an event the approximating distribution $Q$ considers impossible.
- **Invariance**: KL divergence is invariant under parameter transformations that are invertible, [Inference] though this property is more relevant in theoretical derivations than typical applied ML workflows.

### Derivation from Cross-Entropy

KL divergence can be decomposed in terms of entropy and cross-entropy:

$$D_{KL}(P \parallel Q) = H(P, Q) - H(P)$$

where $H(P)$ is the Shannon entropy of $P$:

$$H(P) = -\sum_{x} P(x) \log P(x)$$

and $H(P, Q)$ is the cross-entropy between $P$ and $Q$:

$$H(P, Q) = -\sum_{x} P(x) \log Q(x)$$

This decomposition explains why minimizing cross-entropy loss during model training is equivalent to minimizing KL divergence between the true data distribution and the model's predicted distribution, since $H(P)$ is constant with respect to the model's parameters.

### Forward vs. Reverse KL

The direction of the KL divergence matters significantly in practice, particularly in variational inference and generative modeling.

**Forward KL**: $D_{KL}(P \parallel Q)$
- Averages over $P$, so $Q$ is penalized heavily wherever $P(x) > 0$ but $Q(x) \approx 0$.
- Encourages $Q$ to cover all regions where $P$ has mass ("mass-covering" or "zero-avoiding" behavior).
- Used in maximum likelihood estimation.

**Reverse KL**: $D_{KL}(Q \parallel P)$
- Averages over $Q$, so $Q$ is penalized less for ignoring regions where $P$ has mass but $Q$ does not.
- Encourages $Q$ to concentrate on a single mode of $P$ ("mode-seeking" or "zero-forcing" behavior).
- Used in variational inference (e.g., Variational Autoencoders, Evidence Lower Bound optimization).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380" font-family="sans-serif">
  <text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold">Forward vs Reverse KL Behavior (svg_diagram)</text>

  <text x="170" y="55" text-anchor="middle" font-size="13" font-weight="bold">Forward KL: D(P||Q) — Mass Covering</text>
  <polygon points="30,180 60,60 90,180" fill="#a3c9f7" opacity="0.7" />
  <polygon points="150,180 180,90 210,180" fill="#a3c9f7" opacity="0.7" />
  <text x="60" y="195" text-anchor="middle" font-size="11">P mode 1</text>
  <text x="180" y="195" text-anchor="middle" font-size="11">P mode 2</text>
  <path d="M 30 180 Q 120 40 210 180" fill="none" stroke="#e07b39" stroke-width="3" />
  <text x="120" y="230" text-anchor="middle" font-size="11" fill="#e07b39">Q spreads to cover both modes</text>

  <text x="530" y="55" text-anchor="middle" font-size="13" font-weight="bold">Reverse KL: D(Q||P) — Mode Seeking</text>
  <polygon points="390,180 420,60 450,180" fill="#a3c9f7" opacity="0.7" />
  <polygon points="510,180 540,90 570,180" fill="#a3c9f7" opacity="0.7" />
  <text x="420" y="195" text-anchor="middle" font-size="11">P mode 1</text>
  <text x="540" y="195" text-anchor="middle" font-size="11">P mode 2</text>
  <path d="M 390 180 Q 420 30 450 180" fill="none" stroke="#e07b39" stroke-width="3" />
  <text x="420" y="230" text-anchor="middle" font-size="11" fill="#e07b39">Q locks onto one mode</text>

  <line x1="20" y1="180" x2="220" y2="180" stroke="black" stroke-width="1" />
  <line x1="380" y1="180" x2="580" y2="180" stroke="black" stroke-width="1" />

  <text x="350" y="280" text-anchor="middle" font-size="12" fill="#333">P = true/target distribution (blue), Q = approximating distribution (orange curve)</text>
  <text x="350" y="305" text-anchor="middle" font-size="11" fill="#555">Forward KL penalizes Q=0 where P&gt;0. Reverse KL tolerates Q=0 where P&gt;0.</text>
  <text x="350" y="330" text-anchor="middle" font-size="10" fill="#777">[Inference] Diagram illustrates a well-known conceptual pattern; exact curve shapes are illustrative, not derived from specific data.</text>
</svg>

### Relationship to Maximum Likelihood Estimation

Minimizing forward KL divergence $D_{KL}(P_{\text{data}} \parallel Q_{\theta})$ with respect to model parameters $\theta$ is mathematically equivalent to maximum likelihood estimation (MLE) over the empirical data distribution. This is a well-established result in statistical learning theory.

$$\theta^* = \arg\min_\theta D_{KL}(P_{\text{data}} \parallel Q_\theta) = \arg\max_\theta \mathbb{E}_{x \sim P_{\text{data}}}[\log Q_\theta(x)]$$

### Applications in Machine Learning

- **Variational Autoencoders (VAEs)**: KL divergence regularizes the learned latent distribution toward a prior (commonly a standard normal distribution) as part of the Evidence Lower Bound (ELBO) objective.
- **Variational Inference**: Reverse KL is minimized to approximate an intractable posterior distribution with a tractable one.
- **t-SNE**: Uses KL divergence to compare pairwise similarity distributions in high-dimensional and low-dimensional embedding spaces.
- **Reinforcement Learning**: KL divergence constraints appear in algorithms such as Trust Region Policy Optimization (TRPO) and Proximal Policy Optimization (PPO) to limit how much a policy can change between updates.
- **Knowledge Distillation**: KL divergence between a teacher model's and student model's output distributions is commonly used as a training loss.
- **Model Comparison**: Used to compare how well different candidate distributions approximate observed data.

[Unverified] Specific hyperparameter choices, implementation behavior, and empirical effectiveness of KL divergence in any given library or framework can vary by codebase and version; consult the relevant documentation for implementation-specific details.

### Worked Example

Consider two discrete distributions over three outcomes $\{A, B, C\}$:

| Outcome | $P(x)$ | $Q(x)$ |
|---------|--------|--------|
| A | 0.50 | 0.40 |
| B | 0.30 | 0.30 |
| C | 0.20 | 0.30 |

$$D_{KL}(P \parallel Q) = 0.50 \log\frac{0.50}{0.40} + 0.30 \log\frac{0.30}{0.30} + 0.20 \log\frac{0.20}{0.30}$$

Using natural log:

$$= 0.50 (0.2231) + 0.30(0) + 0.20(-0.4055)$$

$$= 0.1116 + 0 - 0.0811 = 0.0304 \text{ nats}$$

**Example**
This result (approximately 0.0304 nats) indicates that $Q$ is a reasonably close approximation of $P$, but not identical, since the divergence is small but nonzero.

### Relationship to Jensen-Shannon Divergence

Because KL divergence is asymmetric and can be undefined for non-overlapping supports, a symmetrized and bounded variant called Jensen-Shannon (JS) divergence is often used instead:

$$D_{JS}(P \parallel Q) = \frac{1}{2} D_{KL}(P \parallel M) + \frac{1}{2} D_{KL}(Q \parallel M), \quad M = \frac{1}{2}(P + Q)$$

JS divergence is symmetric and always finite, which makes it useful in contexts such as Generative Adversarial Network (GAN) theory.

### Common Pitfalls

- Assuming KL divergence is a true distance metric — it is not, due to asymmetry.
- Applying $D_{KL}(P \parallel Q)$ when $Q$ can be zero where $P$ is nonzero, leading to undefined or infinite values.
- Confusing forward and reverse KL in variational inference derivations, which changes the qualitative behavior of the fitted approximation.
- Assuming a small KL divergence always implies distributions are "close" in every practical sense — the interpretation depends on the application and the scale of the underlying probabilities. [Inference]

### Related Topics
- Cross-Entropy Loss and Its Relationship to KL Divergence
- Jensen-Shannon Divergence
- Mutual Information
- Evidence Lower Bound (ELBO) and Variational Inference
- Entropy and Differential Entropy
- f-Divergences (generalized family including KL divergence)
- Wasserstein Distance as an Alternative to KL-based Metrics