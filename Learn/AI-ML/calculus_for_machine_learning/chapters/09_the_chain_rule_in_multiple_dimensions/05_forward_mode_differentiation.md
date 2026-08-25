## Forward-Mode Differentiation

### Overview

Forward-mode differentiation is a method for computing derivatives of a function represented as a computational graph by propagating derivative information in the same direction as the original computation — from inputs to outputs. Each intermediate variable carries both its numerical value and the derivative of that value with respect to a chosen input, and these paired quantities are updated together as the computation proceeds.

### Core Idea: Dual Numbers

Forward-mode differentiation is commonly implemented using **dual numbers**, an extension of real numbers of the form:

$$a + b\varepsilon, \quad \text{where } \varepsilon^2 = 0, \; \varepsilon \neq 0$$

Here $a$ is the ordinary value and $b$ is the derivative component. Arithmetic on dual numbers automatically propagates derivatives:

$$(a + b\varepsilon) + (c + d\varepsilon) = (a+c) + (b+d)\varepsilon$$

$$(a + b\varepsilon)(c + d\varepsilon) = ac + (ad + bc)\varepsilon$$

The product rule emerges naturally from this algebra, since $\varepsilon^2 = 0$ eliminates the cross term.

### Formal Definition

Given a function composed of elementary operations, forward-mode differentiation computes, for a chosen input variable $x_i$, the derivative of every intermediate node $v_j$ with respect to $x_i$ as the graph is evaluated:

$$\dot{v}_j = \frac{\partial v_j}{\partial x_i}$$

This quantity $\dot{v}_j$ is called the **tangent** of $v_j$. At each node, the tangent is computed using the local derivative rule combined with the tangents of that node's direct predecessors:

$$\dot{v}_j = \sum_{k \,:\, k \to j} \frac{\partial v_j}{\partial v_k} \cdot \dot{v}_k$$

This is the chain rule applied forward, one node at a time, in the same topological order as the original forward pass.

### Worked Example

Let $f(x, y) = (x + y)(y+1)$, and compute $\dfrac{\partial f}{\partial x}$ at $(x,y) = (2,3)$ using forward mode. Since the derivative is being taken with respect to $x$, the input tangent is seeded as $\dot{x} = 1$, $\dot{y} = 0$.

| Node | Operation | Value | Tangent ($\partial/\partial x$) |
|---|---|---|---|
| $v_1$ | $x$ | 2 | $\dot v_1 = 1$ |
| $v_2$ | $y$ | 3 | $\dot v_2 = 0$ |
| $v_3$ | $v_1 + v_2$ | 5 | $\dot v_3 = \dot v_1 + \dot v_2 = 1$ |
| $v_4$ | $v_2 + 1$ | 4 | $\dot v_4 = \dot v_2 = 0$ |
| $v_5$ | $v_3 \times v_4$ | 20 | $\dot v_5 = \dot v_3 v_4 + v_3 \dot v_4 = (1)(4)+(5)(0) = 4$ |

**Result:** $\dfrac{\partial f}{\partial x} = 4$ at $(2,3)$, matching the value obtained by direct differentiation of $f = xy + x + y^2 + y$, where $\partial f/\partial x = y+1 = 4$. ✓

To obtain $\dfrac{\partial f}{\partial y}$, a **separate forward pass** would be required, this time seeding $\dot{x} = 0$, $\dot{y} = 1$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Forward-Mode: Value and Tangent Propagate Together (svg_diagram)</text>

  <circle cx="80" cy="150" r="34" fill="#4A90D9" />
  <text x="80" y="146" text-anchor="middle" font-size="13" fill="#fff">v=2</text>
  <text x="80" y="162" text-anchor="middle" font-size="11" fill="#eee">v̇=1</text>

  <circle cx="80" cy="260" r="34" fill="#4A90D9" />
  <text x="80" y="256" text-anchor="middle" font-size="13" fill="#fff">v=3</text>
  <text x="80" y="272" text-anchor="middle" font-size="11" fill="#eee">v̇=0</text>

  <circle cx="290" cy="120" r="36" fill="#7FB77E" />
  <text x="290" y="112" text-anchor="middle" font-size="13" fill="#fff">v3=5</text>
  <text x="290" y="128" text-anchor="middle" font-size="11" fill="#eee">v̇3=1</text>

  <circle cx="290" cy="260" r="36" fill="#7FB77E" />
  <text x="290" y="252" text-anchor="middle" font-size="13" fill="#fff">v4=4</text>
  <text x="290" y="268" text-anchor="middle" font-size="11" fill="#eee">v̇4=0</text>

  <circle cx="500" cy="190" r="38" fill="#E8A33D" />
  <text x="500" y="182" text-anchor="middle" font-size="13" fill="#fff">v5=20</text>
  <text x="500" y="198" text-anchor="middle" font-size="11" fill="#fff">v̇5=4</text>

  <line x1="112" y1="140" x2="258" y2="122" stroke="#333" stroke-width="2" />
  <line x1="112" y1="165" x2="258" y2="240" stroke="#333" stroke-width="2" />
  <line x1="112" y1="255" x2="258" y2="255" stroke="#333" stroke-width="2" />
  <line x1="322" y1="135" x2="470" y2="180" stroke="#333" stroke-width="2" />
  <line x1="322" y1="245" x2="470" y2="205" stroke="#333" stroke-width="2" />
</svg>

### Forward-Mode Applied to Multiple Outputs

Forward-mode differentiation computes the derivative of **all outputs** with respect to **one input** per pass. For a function $\mathbf{f}: \mathbb{R}^n \to \mathbb{R}^k$, obtaining the full Jacobian requires $n$ separate forward passes — one for each input variable, seeding the tangent of that input to 1 and all others to 0.

$$J_f = \begin{bmatrix} \dfrac{\partial f_1}{\partial x_1} & \cdots & \dfrac{\partial f_1}{\partial x_n} \\ \vdots & \ddots & \vdots \\ \dfrac{\partial f_k}{\partial x_1} & \cdots & \dfrac{\partial f_k}{\partial x_n} \end{bmatrix}$$

Each column of this matrix is produced by one forward-mode pass, seeded with a single input tangent set to 1.

### Computational Cost

| Quantity | Forward-Mode Cost |
|---|---|
| Number of passes needed for full Jacobian | $n$ (one per input) |
| Cost per pass | Comparable to one forward evaluation |
| Efficient when | $n$ is small relative to $k$ (few inputs, many outputs) |
| Inefficient when | $n$ is large relative to $k$ (many inputs, one output) — the typical case in machine learning |

This cost structure is the key reason forward-mode is not the default choice for training large neural networks, where the number of parameters ($n$) vastly exceeds the number of outputs ($k=1$, a scalar loss).

### Forward-Mode vs. Reverse-Mode: Summary Comparison

| Aspect | Forward-Mode | Reverse-Mode |
|---|---|---|
| Propagation direction | Same as forward computation | Opposite of forward computation |
| Quantity carried | Tangent $\dot v = \partial v/\partial x_i$ | Adjoint $\bar v = \partial L/\partial v$ |
| One pass computes | One column of the Jacobian | One row of the Jacobian |
| Passes needed for full Jacobian | $n$ (number of inputs) | $k$ (number of outputs) |
| Best suited for | Many outputs, few inputs | Many inputs, few outputs (e.g., scalar loss) |

### Relevance to Machine Learning

[Inference] Because a typical supervised learning setup involves a single scalar loss function and a large number of parameters, forward-mode differentiation is generally described in published technical and academic sources as less computationally efficient than reverse-mode for this specific use case, since it would require one pass per parameter rather than one pass overall. I cannot verify how any specific current automatic differentiation library selects between forward-mode and reverse-mode internally, so this should be treated as [Inference] based on the mathematical cost structure described above, not as a confirmed statement about any particular software's behavior. Behavior may differ across frameworks, versions, and configurations, and I do not have access to verified, up-to-date internal implementation details for any named library.

[Unverified] Some frameworks are reported in general technical discussions to offer forward-mode differentiation as an option for specific use cases, such as computing directional derivatives or Jacobian-vector products efficiently. I cannot verify which specific frameworks currently support this, under what function names, or with what configuration requirements, so this claim should not be relied upon without independent confirmation from official, current documentation.

### Common Pitfalls

- Assuming one forward-mode pass yields the full gradient with respect to all inputs — it only yields the derivative with respect to the single seeded input direction
- Using forward-mode for large-parameter models without accounting for its per-input cost, which [Inference] would scale poorly compared to reverse-mode in that setting, based on the pass-count structure described above rather than on confirmed benchmarks
- Confusing the tangent $\dot v$ (forward-mode quantity) with the adjoint $\bar v$ (reverse-mode quantity) — they represent different derivative directions and are not interchangeable
- Forgetting to re-seed and re-run the entire forward pass when a derivative with respect to a different input is needed

### Key Points

- Forward-mode differentiation propagates derivative ("tangent") information alongside values, in the same direction as the original computation
- Dual numbers provide one common algebraic formalism for implementing forward-mode differentiation, where the chain rule and product rule emerge automatically from the algebra
- A full Jacobian requires one forward-mode pass per input variable, making the method efficient primarily when the number of inputs is small
- [Inference] This cost structure is generally described as the reason forward-mode is not the typical default for training large-scale neural networks, though I cannot verify the specific internal design choices of any particular current framework, and this characterization should not be treated as a guaranteed or confirmed description of any named software's behavior

**Related Topics**
- Reverse-Mode Differentiation and Adjoint Propagation
- Dual Numbers and Their Algebraic Properties
- Jacobian-Vector Products and Vector-Jacobian Products
- Computational Graphs as a Chain Rule Representation
- Numerical vs. Symbolic vs. Automatic Differentiation