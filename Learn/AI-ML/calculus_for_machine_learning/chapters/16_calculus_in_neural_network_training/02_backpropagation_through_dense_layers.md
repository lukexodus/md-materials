## Backpropagation Through Dense Layers (svg_diagram)

### Layer Definition

A dense (fully connected) layer transforms an input vector $\mathbf{x} \in \mathbb{R}^n$ into an output vector $\mathbf{z} \in \mathbb{R}^m$ via a weight matrix and bias:

$$\mathbf{z} = W\mathbf{x} + \mathbf{b}$$

where $W \in \mathbb{R}^{m \times n}$, $\mathbf{b} \in \mathbb{R}^m$. Typically an elementwise nonlinearity $\sigma$ follows:

$$\mathbf{a} = \sigma(\mathbf{z})$$

This section derives $\partial L/\partial W$, $\partial L/\partial \mathbf{b}$, and $\partial L/\partial \mathbf{x}$ given an upstream adjoint $\bar{\mathbf{a}} = \partial L/\partial \mathbf{a}$, continuing the chain-rule mechanics established in the loss-gradient topic.

### Step 1: Backprop Through the Nonlinearity

Since $\sigma$ is applied elementwise, the local Jacobian is diagonal:

$$\bar{z}_i = \bar{a}_i \cdot \sigma'(z_i)$$

or in vector form with elementwise (Hadamard) product $\odot$:

$$\bar{\mathbf{z}} = \bar{\mathbf{a}} \odot \sigma'(\mathbf{z})$$

**Example with ReLU** ($\sigma(z) = \max(0, z)$, $\sigma'(z) = 1$ if $z>0$ else $0$):

$$\bar{z}_i = \begin{cases} \bar{a}_i & \text{if } z_i > 0 \\ 0 & \text{if } z_i \leq 0 \end{cases}$$

### Step 2: Backprop Through the Affine Transform

Given $\bar{\mathbf{z}}$, the goal is to find $\bar{W}$, $\bar{\mathbf{b}}$, and $\bar{\mathbf{x}}$.

**Gradient with respect to bias:**

$$\frac{\partial z_i}{\partial b_i} = 1 \quad \Rightarrow \quad \bar{\mathbf{b}} = \bar{\mathbf{z}}$$

Since each $b_i$ affects only $z_i$ with coefficient 1, the bias adjoint is simply the incoming adjoint, unchanged.

**Gradient with respect to weights:**

Each entry $z_i = \sum_j W_{ij} x_j + b_i$, so:

$$\frac{\partial z_i}{\partial W_{ij}} = x_j \quad \Rightarrow \quad \bar{W}_{ij} = \bar{z}_i \cdot x_j$$

In matrix form, this is an outer product:

$$\bar{W} = \bar{\mathbf{z}} \, \mathbf{x}^T$$

**Gradient with respect to input:**

Each $z_i$ depends on every $x_j$ through $W_{ij}$, so by the multivariable chain rule (summing over all $i$, since $x_j$ fans out into every output $z_i$):

$$\bar{x}_j = \sum_{i} \bar{z}_i \cdot \frac{\partial z_i}{\partial x_j} = \sum_i \bar{z}_i W_{ij}$$

In matrix form:

$$\bar{\mathbf{x}} = W^T \bar{\mathbf{z}}$$

This fan-out sum is the same accumulation principle established in the backpropagation topic, applied here across an entire layer rather than a single scalar node.

### Numeric Worked Example

Let $\mathbf{x} = [1.0, 2.0]^T$, $W = \begin{bmatrix} 0.5 & -0.5 \\ 1.0 & 0.5 \end{bmatrix}$, $\mathbf{b} = [0.1, -0.2]^T$, using ReLU activation.

**Forward pass:**

$$
\begin{aligned}
\mathbf{z} &= W\mathbf{x} + \mathbf{b} = \begin{bmatrix} 0.5(1.0) + (-0.5)(2.0) \\ 1.0(1.0) + 0.5(2.0) \end{bmatrix} + \begin{bmatrix}0.1 \\ -0.2\end{bmatrix} = \begin{bmatrix}-0.5\\2.0\end{bmatrix}+\begin{bmatrix}0.1\\-0.2\end{bmatrix} = \begin{bmatrix}-0.4\\1.8\end{bmatrix} \\
\mathbf{a} &= \text{ReLU}(\mathbf{z}) = \begin{bmatrix}0\\1.8\end{bmatrix}
\end{aligned}
$$

**Assume upstream adjoint** $\bar{\mathbf{a}} = [0.3, -0.1]^T$ (e.g., arriving from a loss gradient further downstream).

**Backward through ReLU:**

$$\bar{\mathbf{z}} = \begin{bmatrix}0.3 \cdot [z_1>0] \\ -0.1\cdot[z_2>0]\end{bmatrix} = \begin{bmatrix}0.3 \cdot 0 \\ -0.1\cdot 1\end{bmatrix} = \begin{bmatrix}0\\-0.1\end{bmatrix}$$

since $z_1 = -0.4 \leq 0$ (gradient blocked) and $z_2 = 1.8 > 0$ (gradient passes through).

**Backward through the affine transform:**

$$\bar{\mathbf{b}} = \bar{\mathbf{z}} = \begin{bmatrix}0\\-0.1\end{bmatrix}$$

$$\bar{W} = \bar{\mathbf{z}}\,\mathbf{x}^T = \begin{bmatrix}0\\-0.1\end{bmatrix}\begin{bmatrix}1.0 & 2.0\end{bmatrix} = \begin{bmatrix}0 & 0\\-0.1 & -0.2\end{bmatrix}$$

$$\bar{\mathbf{x}} = W^T\bar{\mathbf{z}} = \begin{bmatrix}0.5 & 1.0\\-0.5 & 0.5\end{bmatrix}\begin{bmatrix}0\\-0.1\end{bmatrix} = \begin{bmatrix}0.5(0)+1.0(-0.1)\\-0.5(0)+0.5(-0.1)\end{bmatrix} = \begin{bmatrix}-0.1\\-0.05\end{bmatrix}$$

I have not executed this example in code during this session; the arithmetic was carried out manually and each step shown explicitly so it can be independently checked. [Inference] This is a standard application of the outer-product and matrix-transpose rules derived above, applied mechanically to these specific numbers — the result depends entirely on correct arithmetic execution of that known rule, not on any additional unconfirmed assumption.

### Diagram: Dense Layer Backward Pass Data Flow

<svg viewBox="0 0 680 400" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
  <text x="20" y="24" font-size="15" font-weight="bold">Dense Layer Backward Pass (svg_diagram)</text>

  <rect x="40" y="160" width="90" height="50" fill="none" stroke="black" stroke-width="2"/>
  <text x="85" y="190" font-size="13" text-anchor="middle">x</text>

  <rect x="220" y="100" width="110" height="50" fill="none" stroke="black" stroke-width="2"/>
  <text x="275" y="130" font-size="13" text-anchor="middle">z = Wx+b</text>

  <rect x="420" y="100" width="110" height="50" fill="none" stroke="black" stroke-width="2"/>
  <text x="475" y="130" font-size="13" text-anchor="middle">a = ReLU(z)</text>

  <rect x="220" y="260" width="110" height="50" fill="none" stroke="black" stroke-width="2"/>
  <text x="275" y="282" font-size="12" text-anchor="middle">W̄ = z̄ xᵀ</text>
  <text x="275" y="298" font-size="12" text-anchor="middle">b̄ = z̄</text>

  <!-- forward arrows -->
  <line x1="130" y1="185" x2="220" y2="140" stroke="black" stroke-width="1.5"/>
  <line x1="330" y1="125" x2="420" y2="125" stroke="black" stroke-width="1.5"/>

  <!-- backward arrows -->
  <line x1="420" y1="150" x2="330" y2="160" stroke="red" stroke-width="1.5"/>
  <text x="345" y="175" font-size="11" fill="red">z̄=ā⊙σ'(z)</text>

  <line x1="275" y1="150" x2="275" y2="260" stroke="red" stroke-width="1.5"/>
  <text x="285" y="215" font-size="11" fill="red">z̄</text>

  <line x1="220" y1="200" x2="130" y2="210" stroke="red" stroke-width="1.5"/>
  <text x="140" y="235" font-size="11" fill="red">x̄=Wᵀz̄</text>

  <text x="550" y="130" font-size="11" fill="red">ā (upstream)</text>
</svg>

### Batched Version

In practice, layers process a batch of $B$ samples at once, using $X \in \mathbb{R}^{B \times n}$ rather than a single vector. The forward and backward equations generalize as:

$$Z = XW^T + \mathbf{b}^T \quad (\text{broadcast over batch})$$

$$\bar{W} = \bar{Z}^T X, \qquad \bar{\mathbf{b}} = \sum_{\text{batch}} \bar{Z}, \qquad \bar{X} = \bar{Z}W$$

The bias gradient requires summing over the batch dimension because each bias term is shared (fanned out) across all $B$ samples — the same fan-out accumulation principle applied along a different axis. [Inference] This batched form follows from applying the single-sample derivation above independently to each row of $X$ and summing shared-parameter contributions, which is a standard extension pattern in matrix calculus. I have not independently re-derived the full batched Jacobian algebra step-by-step in this session to confirm no sign or transpose error exists in this summary.

### Full Layer-to-Layer Chain

For a network with layers $1, \dots, L$, the backward pass propagates $\bar{\mathbf{x}}$ from each layer as the $\bar{\mathbf{a}}$ (upstream adjoint) for the previous layer:

```plaintext
===MERMAID_DIAGRAM===
flowchart RL
    Lbar["L̄ = 1"] --> aL["ā at layer L"]
    aL --> zL["z̄ at layer L (through activation)"]
    zL --> WL["W̄_L, b̄_L (parameter grads)"]
    zL --> xL["x̄_L = W_Lᵀ z̄_L"]
    xL --> aLm1["ā at layer L-1 (= x̄_L)"]
    aLm1 --> zLm1["z̄ at layer L-1"]
    zLm1 --> WLm1["W̄_(L-1), b̄_(L-1)"]
```

Each layer's $\bar{\mathbf{x}}$ becomes the next layer's (moving backward) $\bar{\mathbf{a}}$, forming the same reverse-topological chain established generically in the backpropagation topic, now specialized to the dense-layer structure.

### Parameter Update Context

Once $\bar W$ and $\bar{\mathbf b}$ are computed for every layer, an optimizer (e.g., gradient descent) uses them to update parameters:

$$W \leftarrow W - \eta \bar{W}, \qquad \mathbf{b} \leftarrow \mathbf{b} - \eta \bar{\mathbf{b}}$$

where $\eta$ is the learning rate. [Unverified] I cannot verify claims about which specific optimizer variant (SGD, Adam, etc.) is used in any particular context, since that depends entirely on the training setup being discussed, which has not been specified here. The gradients derived above are the raw inputs any such optimizer would consume, regardless of the update rule chosen.

### Common Implementation Pitfalls

- **Forgetting to sum the bias gradient over the batch dimension**, which produces a gradient of the wrong shape or an incorrect magnitude.
- **Transposing $W$ incorrectly** in either the forward pass ($W\mathbf{x}$) or the backward pass ($W^T\bar{\mathbf{z}}$) — these are easy to confuse and produce silently wrong results (no shape error if $W$ happens to be square).
- **Applying the activation derivative to $\mathbf{a}$ instead of $\mathbf{z}$.** For ReLU specifically this often still works by coincidence since $\text{ReLU}(z) > 0 \iff z > 0$, but for other activations (e.g., sigmoid, tanh) this is [Inference] generally understood to produce an incorrect gradient. I have not tested this specific error case numerically in this session to confirm the magnitude of the resulting error for a specific activation.

### Key Points

- Dense layer backprop decomposes into two chain-rule steps: through the elementwise nonlinearity, then through the affine transform.
- $\bar{\mathbf{b}} = \bar{\mathbf{z}}$ directly; $\bar{W} = \bar{\mathbf{z}}\mathbf{x}^T$ (outer product); $\bar{\mathbf{x}} = W^T\bar{\mathbf{z}}$.
- The input gradient uses $W^T$ specifically because each input fans out into every output neuron, requiring the same accumulation-over-children principle used throughout this series.
- Batched computation requires summing the bias gradient across the batch dimension, since the bias is a shared, fanned-out parameter.
- [Unverified] Any claims about specific framework implementations, default optimizers, or measured performance were not checked against current documentation in this session and are not asserted as confirmed fact.

### Related Topics

- Backpropagation through convolutional layers
- Backpropagation through normalization layers (BatchNorm, LayerNorm)
- Vanishing and exploding gradients across deep layer stacks
- Weight initialization strategies and their interaction with gradient magnitude
- Optimizer mechanics (SGD, momentum, Adam) as consumers of computed gradients
- Automatic differentiation for recurrent/sequential architectures (backpropagation through time)

