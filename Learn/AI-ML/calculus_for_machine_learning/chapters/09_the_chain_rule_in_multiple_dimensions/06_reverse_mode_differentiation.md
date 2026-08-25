## Reverse-Mode Differentiation

### Overview

Reverse-mode differentiation computes derivatives of a function represented as a computational graph by propagating derivative information backward — from outputs to inputs — opposite to the direction of the original forward computation. It computes the derivative of a single output with respect to all inputs in one backward traversal, which makes it especially efficient for functions with many inputs and few outputs, such as neural network loss functions.

### Core Idea: Adjoints

Reverse-mode differentiation tracks a quantity called the **adjoint** at each node, defined as the derivative of the final output $L$ with respect to that node's value:

$$\bar{v}_j = \frac{\partial L}{\partial v_j}$$

The adjoint of the output node is initialized to $1$ (since $\partial L/\partial L = 1$), and adjoints propagate backward through the graph, accumulating contributions from every downstream node that depends on the current node.

### Formal Definition

For a node $v_j$ with downstream successors $v_k$ (nodes that use $v_j$ as an input), the adjoint is computed as:

$$\bar{v}_j = \sum_{k \,:\, j \to k} \bar{v}_k \cdot \frac{\partial v_k}{\partial v_j}$$

This is the chain rule applied in reverse, one node at a time, summing over every path by which $v_j$ influences the output $L$.

### Two-Phase Algorithm

Reverse-mode differentiation proceeds in two distinct phases:

1. **Forward pass** — evaluate the computational graph in topological order, computing and storing the value of every node
2. **Backward pass** — traverse the graph in reverse topological order, computing the adjoint of every node using the adjoints of its successors and the local derivatives already available from the forward pass

Both the graph structure and all intermediate values from the forward pass must be retained in memory for the backward pass to proceed.

### Worked Example

Let $f(x, y) = (x + y)(y + 1)$, evaluated at $(x, y) = (2, 3)$.

**Forward pass (values):**

| Node | Operation | Value |
|---|---|---|
| $v_1$ | $x$ | 2 |
| $v_2$ | $y$ | 3 |
| $v_3$ | $v_1 + v_2$ | 5 |
| $v_4$ | $v_2 + 1$ | 4 |
| $v_5$ | $v_3 \times v_4$ | 20 |

**Backward pass (adjoints):**

| Node | Adjoint Computation | Value |
|---|---|---|
| $\bar v_5$ | seed | $1$ |
| $\bar v_4$ | $\bar v_5 \cdot v_3$ | $1 \times 5 = 5$ |
| $\bar v_3$ | $\bar v_5 \cdot v_4$ | $1 \times 4 = 4$ |
| $\bar v_2$ | $\bar v_3 \cdot \dfrac{\partial v_3}{\partial v_2} + \bar v_4 \cdot \dfrac{\partial v_4}{\partial v_2}$ | $(4)(1) + (5)(1) = 9$ |
| $\bar v_1$ | $\bar v_3 \cdot \dfrac{\partial v_3}{\partial v_1}$ | $(4)(1) = 4$ |

**Result:** $\dfrac{\partial f}{\partial x} = \bar v_1 = 4$, $\dfrac{\partial f}{\partial y} = \bar v_2 = 9$. This matches the analytical derivatives of $f = xy + x + y^2 + y$: $\partial f/\partial x = y+1 = 4$, $\partial f/\partial y = x + 2y + 1 = 9$. ✓

Both partial derivatives were obtained in a **single backward pass**, unlike forward-mode, which would require two separate passes.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Reverse-Mode: Adjoints Propagate Backward (svg_diagram)</text>

  <circle cx="90" cy="150" r="34" fill="#4A90D9" />
  <text x="90" y="146" text-anchor="middle" font-size="12" fill="#fff">v1=2</text>
  <text x="90" y="162" text-anchor="middle" font-size="11" fill="#eee">v̄1=4</text>

  <circle cx="90" cy="260" r="34" fill="#4A90D9" />
  <text x="90" y="256" text-anchor="middle" font-size="12" fill="#fff">v2=3</text>
  <text x="90" y="272" text-anchor="middle" font-size="11" fill="#eee">v̄2=9</text>

  <circle cx="300" cy="120" r="36" fill="#7FB77E" />
  <text x="300" y="112" text-anchor="middle" font-size="12" fill="#fff">v3=5</text>
  <text x="300" y="128" text-anchor="middle" font-size="11" fill="#eee">v̄3=4</text>

  <circle cx="300" cy="260" r="36" fill="#7FB77E" />
  <text x="300" y="252" text-anchor="middle" font-size="12" fill="#fff">v4=4</text>
  <text x="300" y="268" text-anchor="middle" font-size="11" fill="#eee">v̄4=5</text>

  <circle cx="510" cy="190" r="38" fill="#E8A33D" />
  <text x="510" y="182" text-anchor="middle" font-size="12" fill="#fff">v5=20</text>
  <text x="510" y="198" text-anchor="middle" font-size="11" fill="#fff">v̄5=1</text>

  <line x1="470" y1="190" x2="336" y2="140" stroke="#E8622C" stroke-width="2" marker-end="url(#arrowRev)" />
  <line x1="470" y1="190" x2="336" y2="250" stroke="#E8622C" stroke-width="2" marker-end="url(#arrowRev)" />
  <line x1="264" y1="130" x2="124" y2="155" stroke="#E8622C" stroke-width="2" marker-end="url(#arrowRev)" />
  <line x1="264" y1="140" x2="124" y2="255" stroke="#E8622C" stroke-width="2" marker-end="url(#arrowRev)" />
  <line x1="264" y1="255" x2="124" y2="262" stroke="#E8622C" stroke-width="2" marker-end="url(#arrowRev)" />

  <text x="320" y="310" text-anchor="middle" font-size="12" fill="#E8622C">Adjoints flow opposite to the original forward computation</text>
</svg>

### Fan-Out Requires Summation

When a node feeds into multiple downstream nodes (as $v_2$ does above, feeding into both $v_3$ and $v_4$), its adjoint accumulates contributions from every path. This is the same principle governing the general multivariable chain rule sum-over-paths formula, now applied specifically during backward traversal.

### Computational Cost

| Quantity | Reverse-Mode Cost |
|---|---|
| Number of passes for full gradient | 1 forward pass + 1 backward pass |
| Cost relative to forward evaluation | Roughly a small constant multiple, according to standard descriptions of the algorithm's asymptotic behavior |
| Memory requirement | Must store all intermediate values from the forward pass |
| Efficient when | Many inputs, few outputs (e.g., scalar loss) — the typical machine learning setting |

I cannot verify precise, universal constant-factor cost figures for reverse-mode differentiation across all implementations, since actual performance depends on the specific graph structure, hardware, and software implementation. [Unverified]

### Forward-Mode vs. Reverse-Mode: Summary Comparison

| Aspect | Forward-Mode | Reverse-Mode |
|---|---|---|
| Propagation direction | Same as forward computation | Opposite of forward computation |
| Quantity carried | Tangent $\dot v = \partial v/\partial x_i$ | Adjoint $\bar v = \partial L/\partial v$ |
| One pass computes | One column of the Jacobian | One row of the Jacobian |
| Passes needed for full Jacobian | $n$ (number of inputs) | $k$ (number of outputs) |
| Best suited for | Many outputs, few inputs | Many inputs, few outputs |

### Relevance to Machine Learning: Backpropagation

Backpropagation, as used in neural network training, is a specific instance of reverse-mode differentiation applied to the computational graph defined by a network's layers, with the scalar loss as the output node. [Inference] Because a typical neural network has a very large number of parameters and produces a single scalar loss, reverse-mode differentiation is described in academic and technical literature as well-matched to this setting, since it computes the gradient with respect to all parameters in one backward pass rather than requiring one pass per parameter. This is a reasoned inference based on the pass-count structure described above and general descriptions found in published sources, not a confirmed statement about the internal design or behavior of any specific current software library. Behavior may differ across frameworks, versions, and configurations, and I do not have access to verified, up-to-date internal implementation details for any named library. [Unverified] as it pertains to any specific software product.

I cannot verify which specific automatic differentiation frameworks are currently in use, their current version behavior, or their exact internal architecture, so any statement connecting this mathematical description to a named product should be treated as [Unverified].

### Common Pitfalls

- Forgetting to sum adjoint contributions at nodes with multiple downstream uses (fan-out), producing an incomplete gradient
- Failing to retain forward-pass intermediate values, which are required inputs to the backward pass computations
- Confusing the adjoint $\bar v = \partial L/\partial v$ with the tangent $\dot v = \partial v/\partial x_i$ used in forward-mode — these represent derivatives in opposite directions and are computed differently
- Assuming reverse-mode is always more efficient than forward-mode; this depends on the ratio of inputs to outputs, and the comparison reverses when there are many outputs and few inputs [Inference], based on the pass-count structure described above rather than on confirmed benchmarks for any specific system

### Key Points

- Reverse-mode differentiation propagates adjoints ($\partial L/\partial v$) backward through a computational graph, computing the gradient with respect to all inputs in a single backward pass
- The method requires a forward pass first to compute and store all intermediate values, followed by a backward pass to compute adjoints
- Nodes with multiple downstream uses require summing adjoint contributions from every path, consistent with the general chain rule
- [Inference] Reverse-mode is widely described in published technical and academic sources as the standard mathematical basis for backpropagation in neural network training, given the many-inputs/one-output structure typical of that setting; however, I cannot verify implementation-specific claims about any named software library, and such claims should be treated as [Unverified] without independent confirmation from current official documentation

**Related Topics**
- Forward-Mode Differentiation and Dual Numbers
- Backpropagation Derived from First Principles
- Jacobian-Vector Products and Vector-Jacobian Products
- Computational Graphs as a Chain Rule Representation
- Memory-Efficient Backpropagation Techniques (Checkpointing)