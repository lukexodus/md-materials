## Adaptive Learning Rate Methods

### Motivation

Momentum-based methods use a single global learning rate $\eta$ applied uniformly across all parameters. Adaptive learning rate methods instead adjust the effective step size *per parameter*, based on the history of gradients observed for that parameter. This is useful when:

- Different parameters have gradients of very different typical magnitudes (common in deep networks with varying layer scales)
- Sparse features receive infrequent but potentially large gradient updates
- The loss surface has different curvature along different parameter directions

These are established motivations documented in the original papers for each method cited below; the degree of practical benefit on any specific task is problem-dependent [Inference].

### AdaGrad

**Update Rule**

$$G_t = G_{t-1} + \nabla J(\theta_t)^2$$

$$\theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{G_t + \epsilon}} \odot \nabla J(\theta_t)$$

Where:
- $G_t$ is a per-parameter accumulator of squared gradients (element-wise), initialized as $G_0 = 0$
- $\epsilon$ is a small constant (e.g., $10^{-8}$) added for numerical stability, preventing division by zero
- $\odot$ denotes element-wise multiplication
- The division $\frac{\eta}{\sqrt{G_t + \epsilon}}$ is also element-wise

**Behavior**

Parameters with large historical gradients accumulate a large $G_t$, which shrinks their effective learning rate. Parameters with small or infrequent gradients keep a larger effective learning rate. This origin and behavior are described in Duchi, Hazan, and Singer's original AdaGrad paper (2011) [Unverified — I have not fetched or re-verified the primary source text in this conversation].

**Key Points**

- Well suited to sparse gradient settings (e.g., certain NLP or recommendation tasks with sparse features), per the original motivating use case
- Because $G_t$ accumulates monotonically (it only grows, never shrinks), the effective learning rate decreases continuously over training and can become extremely small — this is a known limitation, not a guaranteed failure mode, since its practical impact depends on training duration and gradient magnitudes [Inference]
- Not typically the default choice for training deep neural networks over long horizons, according to commonly cited practitioner discussion [Unverified]

### RMSProp

**Motivation**

RMSProp modifies AdaGrad's ever-growing accumulator into an exponentially decaying moving average, so that older squared gradients are gradually "forgotten" rather than permanently accumulated. RMSProp was introduced informally by Geoffrey Hinton in an online course (not a formal peer-reviewed publication) [Unverified — this attribution is widely repeated but I cannot independently confirm the original source here].

**Update Rule**

$$E[g^2]_t = \gamma E[g^2]_{t-1} + (1-\gamma) \nabla J(\theta_t)^2$$

$$\theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{E[g^2]_t + \epsilon}} \odot \nabla J(\theta_t)$$

Where:
- $E[g^2]_t$ is the exponential moving average of squared gradients
- $\gamma$ is the decay rate, commonly cited around $0.9$ [Unverified — exact conventional defaults vary by framework and should be checked against current documentation]

**Key Points**

- Addresses AdaGrad's diminishing learning rate problem by using a moving average instead of a cumulative sum
- Effective learning rate can both increase and decrease over time as gradient magnitudes change, unlike AdaGrad's strictly non-increasing rate
- Commonly used in recurrent neural network training in past literature, though current framework defaults and popularity may have shifted since [Unverified]

### Adam (Adaptive Moment Estimation)

**Motivation**

Adam combines momentum (first moment of gradients) with RMSProp-style adaptive scaling (second moment of gradients). It was introduced by Kingma and Ba (2014) in the paper "Adam: A Method for Stochastic Optimization" [Unverified — I have not fetched the primary source in this conversation to verify exact publication details].

**Update Rule**

$$m_t = \beta_1 m_{t-1} + (1-\beta_1)\nabla J(\theta_t)$$

$$v_t = \beta_2 v_{t-1} + (1-\beta_2)\nabla J(\theta_t)^2$$

Bias-corrected estimates:

$$\hat{m}_t = \frac{m_t}{1-\beta_1^t}, \qquad \hat{v}_t = \frac{v_t}{1-\beta_2^t}$$

Parameter update:

$$\theta_{t+1} = \theta_t - \frac{\eta}{\sqrt{\hat{v}_t} + \epsilon}\hat{m}_t$$

Where:
- $m_t$ is the first-moment estimate (mean of gradients, i.e., momentum)
- $v_t$ is the second-moment estimate (uncentered variance of gradients)
- $\beta_1, \beta_2$ are decay rates for the first and second moments; commonly cited defaults are $\beta_1 = 0.9$, $\beta_2 = 0.999$ [Unverified — exact defaults are framework-dependent and should be checked against current documentation]
- The bias correction terms $1-\beta_1^t$ and $1-\beta_2^t$ counteract the fact that $m_0 = v_0 = 0$, which biases early estimates toward zero

**Why Bias Correction Is Needed**

At early time steps, $m_t$ and $v_t$ are biased toward zero because they are initialized at zero and only partially updated. Dividing by $(1-\beta_1^t)$ and $(1-\beta_2^t)$ rescales these estimates so that, under the assumption gradients are drawn from a stationary distribution, $E[\hat{m}_t]$ approximates the true gradient mean. This derivation is presented in the original Adam paper [Unverified — not independently re-verified in this conversation]; whether the stationarity assumption holds in real non-convex training is a separate question not addressed by the derivation itself [Inference].

**Key Points**

- Combines benefits of momentum (smoothing/acceleration) and adaptive scaling (per-parameter step sizes)
- Widely adopted as a default optimizer across many deep learning tasks, per common practitioner usage patterns [Unverified — I cannot confirm current relative popularity statistics without searching]
- Some published analyses have raised convergence concerns for Adam on certain convex problems, notably Reddi, Kale, and Duchi's "On the Convergence of Adam and Beyond" (2018), which proposed AMSGrad as a corrective variant [Unverified — I have not re-verified this paper's specific claims in this conversation]
- Whether Adam "generalizes worse" than SGD with momentum on specific tasks has been debated in the literature; this is an empirical, task-dependent question rather than a settled universal claim [Inference]

### Comparison Table

| Method | Adapts Per-Parameter Rate | Uses Momentum | Learning Rate Behavior Over Time |
|---|---|---|---|
| SGD | No | No | Constant (unless externally scheduled) |
| SGD + Momentum | No | Yes | Constant base rate, velocity accumulates |
| AdaGrad | Yes | No | Monotonically decreasing |
| RMSProp | Yes | No | Fluctuates with recent gradient magnitude |
| Adam | Yes | Yes | Fluctuates with recent gradient magnitude, bias-corrected early on |

This table reflects the standard algorithmic descriptions in the respective papers; I have not re-fetched each paper in this conversation to re-verify every detail [Unverified].

### Geometric Intuition

(svg_diagram) Effective learning rate scaling per parameter dimension

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320" font-family="sans-serif">
  <text x="320" y="24" text-anchor="middle" font-size="16" font-weight="bold">Adaptive Step Scaling by Gradient History (svg_diagram)</text>

  
  <line x1="80" y1="260" x2="580" y2="260" stroke="#333333" stroke-width="1.5" />
  <line x1="80" y1="260" x2="80" y2="60" stroke="#333333" stroke-width="1.5" />
  <text x="580" y="278" font-size="11" text-anchor="end">parameter dimension →</text>
  <text x="60" y="60" font-size="11" text-anchor="end">step size</text>

  
  <rect x="130" y="80" width="60" height="180" fill="#d1495b" opacity="0.75" />
  <text x="160" y="272" font-size="11" text-anchor="middle">large grad history</text>
  <text x="160" y="70" font-size="11" text-anchor="middle">small step</text>

  
  <rect x="260" y="200" width="60" height="60" fill="#2e86ab" opacity="0.75" />
  <text x="290" y="272" font-size="11" text-anchor="middle">small grad history</text>
  <text x="290" y="190" font-size="11" text-anchor="middle">large step</text>

  
  <rect x="390" y="140" width="60" height="120" fill="#7a9e5b" opacity="0.75" />
  <text x="420" y="272" font-size="11" text-anchor="middle">medium grad history</text>
  <text x="420" y="130" font-size="11" text-anchor="middle">medium step</text>
</svg>

### Worked Numerical Example (Adam, First Two Steps)

Let $J(\theta) = \theta^2$, $\nabla J(\theta) = 2\theta$, $\theta_0 = 10$, $\eta = 0.1$, $\beta_1 = 0.9$, $\beta_2 = 0.999$, $\epsilon = 10^{-8}$. This is a direct algebraic computation from the stated update rule, not an inference.

**Step 1**

Gradient: $g_1 = 2(10) = 20$

$$m_1 = 0.9(0) + 0.1(20) = 2$$
$$v_1 = 0.999(0) + 0.001(20^2) = 0.001(400) = 0.4$$

Bias correction:
$$\hat{m}_1 = \frac{2}{1-0.9^1} = \frac{2}{0.1} = 20$$
$$\hat{v}_1 = \frac{0.4}{1-0.999^1} = \frac{0.4}{0.001} = 400$$

Update:
$$\theta_1 = 10 - 0.1 \cdot \frac{20}{\sqrt{400}+10^{-8}} \approx 10 - 0.1(1.0) = 9.9$$

**Step 2**

Gradient: $g_2 = 2(9.9) = 19.8$

$$m_2 = 0.9(2) + 0.1(19.8) = 1.8 + 1.98 = 3.78$$
$$v_2 = 0.999(0.4) + 0.001(19.8^2) = 0.3996 + 0.39204 = 0.79164$$

Bias correction:
$$\hat{m}_2 = \frac{3.78}{1-0.9^2} = \frac{3.78}{0.19} \approx 19.895$$
$$\hat{v}_2 = \frac{0.79164}{1-0.999^2} = \frac{0.79164}{0.001999} \approx 396.02$$

Update:
$$\theta_2 = 9.9 - 0.1 \cdot \frac{19.895}{\sqrt{396.02}} \approx 9.9 - 0.1(0.9999) \approx 9.8$$

Note that Adam's early steps here take roughly constant-sized steps ($\approx 0.1$) regardless of the raw gradient magnitude of 20 or 19.8 — this normalization behavior is a direct algebraic consequence of the update rule on this specific example, not a general guarantee about all inputs or later training stages [Inference].

### Common Pitfalls

- **Assuming Adam works well "out of the box" for every problem**: performance is task- and architecture-dependent; I cannot verify universal superiority claims [Unverified]
- **Treating $\epsilon$ as irrelevant**: on some problems, the choice of $\epsilon$ has been reported to affect training stability, though the magnitude of this effect is architecture-dependent [Inference]
- **Ignoring weight decay interaction**: naively combining Adam with standard L2 regularization does not behave identically to decoupled weight decay (AdamW); this distinction is described in Loshchilov and Hutter's "Decoupled Weight Decay Regularization" [Unverified — not re-verified in this conversation]
- **Assuming adaptive methods always generalize as well as SGD + momentum**: this is disputed in the literature and depends on task, architecture, and hyperparameter tuning quality [Inference]

### Pseudocode (Adam)

```
initialize θ, m = 0, v = 0, t = 0
for t in range(1, num_steps + 1):
    g = compute_gradient(J, θ)
    m = beta1 * m + (1 - beta1) * g
    v = beta2 * v + (1 - beta2) * g^2
    m_hat = m / (1 - beta1^t)
    v_hat = v / (1 - beta2^t)
    θ = θ - eta * m_hat / (sqrt(v_hat) + epsilon)
return θ
```

### Disclaimer on Behavioral Claims

Statements above about which optimizer performs better in practice, common default hyperparameters, or typical framework behavior are [Unverified] or [Inference] unless tied to a directly shown algebraic derivation. Actual behavior of any specific implementation may vary by framework, framework version, and problem setting, and is not guaranteed by this content.

### Related Topics

- Learning rate scheduling and warmup strategies
- AdamW and decoupled weight decay
- Second-order optimization methods (Newton's method, quasi-Newton methods, natural gradient)
- Convergence analysis for non-convex optimization
- Batch normalization and its interaction with optimizer choice
- Gradient clipping and numerical stability in training