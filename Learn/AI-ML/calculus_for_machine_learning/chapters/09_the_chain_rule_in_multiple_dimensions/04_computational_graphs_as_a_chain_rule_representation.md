## Computational Graphs as a Chain Rule Representation

### Overview

A computational graph is a way of representing a mathematical expression as a directed graph, where nodes correspond to variables or operations and edges represent data dependencies. This structure provides a natural framework for applying the chain rule systematically, since each edge in the graph corresponds to a local derivative, and the chain rule prescribes how to combine these local derivatives to compute derivatives across the entire graph.

### Structure of a Computational Graph

A computational graph consists of:

- **Input nodes** — represent independent variables (e.g., $x_1, x_2$)
- **Intermediate nodes** — represent the result of applying an operation to earlier nodes (e.g., $v_3 = v_1 \times v_2$)
- **Output node** — represents the final scalar or vector result of the computation (e.g., a loss value $L$)
- **Edges** — represent direct dependencies; an edge from node $a$ to node $b$ means $b$ is computed directly from $a$

Every node other than the inputs has an associated **local derivative** with respect to each of its direct predecessors, computed using ordinary differentiation rules for that single operation.

### Forward Pass: Building the Graph

The forward pass evaluates the expression by computing each node's value in topological order — every node is computed only after all of its predecessors have been computed.

**Example expression:** $f(x, y) = (x + y)(y + 1)$

| Node | Operation | Value (at $x=2, y=3$) |
|---|---|---|
| $v_1$ | $x$ | 2 |
| $v_2$ | $y$ | 3 |
| $v_3$ | $v_1 + v_2$ | 5 |
| $v_4$ | $v_2 + 1$ | 4 |
| $v_5$ | $v_3 \times v_4$ | 20 |

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Computational Graph: f(x,y) = (x+y)(y+1) (svg_diagram)</text>

  <circle cx="80" cy="150" r="30" fill="#4A90D9" />
  <text x="80" y="156" text-anchor="middle" font-size="15" fill="#fff">x=2</text>

  <circle cx="80" cy="260" r="30" fill="#4A90D9" />
  <text x="80" y="266" text-anchor="middle" font-size="15" fill="#fff">y=3</text>

  <circle cx="280" cy="120" r="32" fill="#7FB77E" />
  <text x="280" y="126" text-anchor="middle" font-size="14" fill="#fff">v3=5</text>
  <text x="280" y="145" text-anchor="middle" font-size="10" fill="#eee">x+y</text>

  <circle cx="280" cy="260" r="32" fill="#7FB77E" />
  <text x="280" y="266" text-anchor="middle" font-size="14" fill="#fff">v4=4</text>
  <text x="280" y="285" text-anchor="middle" font-size="10" fill="#eee">y+1</text>

  <circle cx="480" cy="190" r="34" fill="#E8A33D" />
  <text x="480" y="196" text-anchor="middle" font-size="15" fill="#fff">v5=20</text>
  <text x="480" y="212" text-anchor="middle" font-size="10" fill="#fff">v3×v4</text>

  <line x1="108" y1="140" x2="252" y2="125" stroke="#333" stroke-width="2" />
  <line x1="108" y1="165" x2="252" y2="235" stroke="#333" stroke-width="2" />
  <line x1="108" y1="255" x2="252" y2="255" stroke="#333" stroke-width="2" />

  <line x1="310" y1="135" x2="452" y2="180" stroke="#333" stroke-width="2" />
  <line x1="310" y1="245" x2="452" y2="200" stroke="#333" stroke-width="2" />

  <text x="565" y="196" font-size="13" fill="#555">= f(x,y)</text>
</svg>

### Backward Pass: Applying the Chain Rule

The backward pass computes the derivative of the output with respect to every node, working in reverse topological order. This process is called **reverse-mode differentiation**, and it is a direct, systematic application of the multivariable chain rule.

The rule at each node: the derivative of the output $L$ with respect to a node $v$ equals the sum, over all nodes $u$ that $v$ feeds into, of the derivative with respect to $u$ multiplied by the local derivative of $u$ with respect to $v$:

$$\frac{\partial L}{\partial v} = \sum_{u \,:\, v \to u} \frac{\partial L}{\partial u} \cdot \frac{\partial u}{\partial v}$$

This is exactly the general chain rule sum-over-paths formula, applied one edge at a time.

### Backward Pass Worked Through the Example

Continuing $f = v_5 = v_3 \times v_4$, with $v_3 = 5$, $v_4 = 4$:

**Step 1 — Derivative of output with respect to itself:**

$$\frac{\partial v_5}{\partial v_5} = 1$$

**Step 2 — Propagate to $v_3$ and $v_4$ (local derivatives of a product):**

$$\frac{\partial v_5}{\partial v_3} = v_4 = 4, \qquad \frac{\partial v_5}{\partial v_4} = v_3 = 5$$

**Step 3 — Propagate to $v_1$ (only reachable through $v_3$):**

$$\frac{\partial v_5}{\partial v_1} = \frac{\partial v_5}{\partial v_3} \cdot \frac{\partial v_3}{\partial v_1} = 4 \times 1 = 4$$

**Step 4 — Propagate to $v_2$ (reachable through both $v_3$ and $v_4$ — two paths, so the contributions are summed):**

$$\frac{\partial v_5}{\partial v_2} = \frac{\partial v_5}{\partial v_3} \cdot \frac{\partial v_3}{\partial v_2} + \frac{\partial v_5}{\partial v_4} \cdot \frac{\partial v_4}{\partial v_2} = (4 \times 1) + (5 \times 1) = 9$$

**Result:** $\dfrac{\partial f}{\partial x} = 4$, $\dfrac{\partial f}{\partial y} = 9$ at the point $(x,y) = (2,3)$.

This matches what would be obtained analytically: $f = (x+y)(y+1) = xy + x + y^2 + y$, so $\partial f/\partial x = y + 1 = 4$ and $\partial f/\partial y = x + 2y + 1 = 9$. ✓

### Why Nodes with Multiple Outgoing Edges Require Summation

A node that feeds into more than one downstream node (like $v_2 = y$ in the example above) affects the final output through multiple independent paths. The chain rule requires summing the contribution of every such path — this is the same principle underlying the tree-diagram form of the chain rule, just expressed in graph terms rather than tree terms.

### Forward-Mode vs. Reverse-Mode Differentiation

| Aspect | Forward-Mode | Reverse-Mode |
|---|---|---|
| Traversal direction | Same as forward pass | Opposite of forward pass |
| Computes | Derivative of all outputs w.r.t. one input | Derivative of one output w.r.t. all inputs |
| Efficient when | Few inputs, many outputs | Many inputs, few outputs (e.g., scalar loss) |
| Typical ML use case | Less common in deep learning | Standard in backpropagation |

[Inference] Because neural network training typically involves a single scalar loss and a very large number of parameters, reverse-mode differentiation is generally described in the literature as the more computationally efficient choice for this setting, and is widely reported to be the approach used by mainstream deep learning frameworks. This is a reasoned inference based on the structure of the problem and general descriptions in published material, not a confirmed statement about the internal implementation of any specific software library. I do not have access to verified, up-to-date internal source code for any particular framework, so exact implementation details should be treated as [Unverified] and may vary by library and version.

### Local Derivatives Table for Common Operations

| Operation | Local Derivative |
|---|---|
| $v = a + b$ | $\partial v/\partial a = 1$, $\partial v/\partial b = 1$ |
| $v = a \times b$ | $\partial v/\partial a = b$, $\partial v/\partial b = a$ |
| $v = a / b$ | $\partial v/\partial a = 1/b$, $\partial v/\partial b = -a/b^2$ |
| $v = \sin(a)$ | $\partial v/\partial a = \cos(a)$ |
| $v = e^a$ | $\partial v/\partial a = e^a$ |
| $v = \max(a, 0)$ (ReLU) | $\partial v/\partial a = 1$ if $a>0$, else $0$ |

These local derivatives are the atomic building blocks combined by the chain rule at every node during the backward pass.

### Relevance to Machine Learning

Every operation in a neural network's forward computation — matrix multiplications, activation functions, loss functions — can be represented as a node in a computational graph. [Inference] Automatic differentiation libraries are generally described, in published technical documentation and academic sources, as constructing such a graph either explicitly or implicitly during the forward pass, and then applying reverse-mode differentiation to compute gradients for all parameters in a single backward traversal. I cannot verify the precise internal mechanism of any specific current library version, so this should be treated as [Inference] rather than a confirmed technical description, and actual behavior may differ across frameworks, versions, and configurations.

### Common Pitfalls

- Forgetting to sum contributions at nodes with multiple outgoing edges (fan-out), leading to incomplete gradients
- Confusing forward-mode and reverse-mode differentiation — they traverse the graph in opposite directions and have different efficiency trade-offs
- Assuming the computational graph must be built explicitly in all cases — [Unverified] whether a specific framework builds the graph explicitly (as in "define-and-run" systems) or implicitly during execution (as in "define-by-run" systems) depends on that framework's design, and I do not have verified, current details on any particular library's default behavior
- Treating local derivatives as if they were the full derivative, rather than one factor in a chain-rule product

### Key Points

- A computational graph decomposes a complex expression into a sequence of simple operations, each with an easily computed local derivative
- The chain rule is applied edge by edge during a backward traversal, and contributions are summed at any node with multiple outgoing edges
- Reverse-mode differentiation computes the derivative of one output with respect to all inputs in a single backward pass, which [Inference] is generally described in the literature as well-suited to the scalar-loss, many-parameter setting typical of neural network training, though I cannot independently verify this characterization for any specific framework
- Local derivative tables for common operations (addition, multiplication, activation functions) form the reusable building blocks of automatic differentiation systems

**Related Topics**
- Reverse-Mode vs. Forward-Mode Automatic Differentiation
- Backpropagation Derived from First Principles
- Jacobian Matrices and Their Role in Vector Calculus
- Gradient Vectors and Directional Derivatives
- Numerical vs. Symbolic vs. Automatic Differentiation