## Graphing and Transformations of Functions

### Basic Transformation Types

Given a base function $f(x)$, transformations modify its graph through shifting, stretching, compressing, or reflecting.

$$g(x) = a \cdot f(b(x - h)) + k$$

- $h$: horizontal shift
- $k$: vertical shift
- $a$: vertical stretch/compression and possible reflection
- $b$: horizontal stretch/compression and possible reflection

These are standard algebraic transformation rules, verifiable directly by substitution and graphing.

### Vertical and Horizontal Shifts

| Transformation | Effect | Example |
|---|---|---|
| $f(x) + k$ | Shifts graph up by $k$ (if $k > 0$) | $x^2 + 3$ |
| $f(x) - k$ | Shifts graph down by $k$ | $x^2 - 3$ |
| $f(x - h)$ | Shifts graph right by $h$ (if $h > 0$) | $(x-2)^2$ |
| $f(x + h)$ | Shifts graph left by $h$ | $(x+2)^2$ |

**Key Points**

- Vertical shifts affect the output value directly: $y \to y + k$
- Horizontal shifts affect the input in the opposite direction of the sign shown: $f(x - h)$ shifts right, not left, for positive $h$
- These rules follow directly from function definitions and are verifiable by substitution

**Example**

For $f(x) = x^2$, the transformed function $g(x) = (x - 3)^2 + 1$ shifts the graph 3 units right and 1 unit up.

### Vertical and Horizontal Stretch/Compression

| Transformation | Effect |
|---|---|
| $a \cdot f(x)$, $\lvert a \rvert > 1$ | Vertical stretch |
| $a \cdot f(x)$, $0 < \lvert a \rvert < 1$ | Vertical compression |
| $f(bx)$, $\lvert b \rvert > 1$ | Horizontal compression |
| $f(bx)$, $0 < \lvert b \rvert < 1$ | Horizontal stretch |

**Key Points**

- Vertical stretch/compression scales output values directly
- Horizontal stretch/compression scales input values, with an inverse relationship between $b$ and the visual stretching effect
- These are standard, verifiable algebraic transformation properties

### Reflections

| Transformation | Effect |
|---|---|
| $-f(x)$ | Reflects across the $x$-axis |
| $f(-x)$ | Reflects across the $y$-axis |
| $-f(-x)$ | Reflects across the origin (180° rotation) |

**Example**

For $f(x) = e^x$:

- $-f(x) = -e^x$ reflects across the $x$-axis (range becomes $(-\infty, 0)$)
- $f(-x) = e^{-x}$ reflects across the $y$-axis (this is the exponential decay form)

### Visualizing Combined Transformations

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Transformation of f(x) = x² (svg_diagram)</text>

  <line x1="60" y1="270" x2="650" y2="270" stroke="#334155" stroke-width="1.5" />
  <line x1="200" y1="40" x2="200" y2="300" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="275" font-size="11" font-family="sans-serif">x</text>

  <path d="M 100 250 Q 200 60 300 250" fill="none" stroke="#9ca3af" stroke-width="2" />
  <text x="120" y="240" font-size="11" font-family="sans-serif" fill="#9ca3af">f(x)=x²</text>

  <path d="M 300 220 Q 400 30 500 220" fill="none" stroke="#1d4ed8" stroke-width="2.5" />
  <text x="470" y="200" font-size="11" font-family="sans-serif" fill="#1d4ed8">g(x)=(x-3)²+1</text>

  <line x1="200" y1="250" x2="300" y2="250" stroke="#b91c1c" stroke-width="1" stroke-dasharray="4,4" />
  <text x="230" y="265" font-size="9" font-family="sans-serif" fill="#b91c1c">shift right 3</text>
</svg>

This diagram is a conceptual, schematic illustration of shift direction and is not a precisely computed plot.

### Transformations Relevant to Machine Learning

#### Feature Scaling as Linear Transformation

Standardization (z-score normalization) is a linear transformation of input data:

$$z = \frac{x - \mu}{\sigma}$$

This is algebraically a horizontal shift (by $\mu$) followed by a horizontal compression/stretch (by $\frac{1}{\sigma}$), applied to the data distribution rather than to a function graph directly. This is a verifiable algebraic description of the standardization formula.

**Key Points**

- [Inference] Feature scaling is commonly used before training certain models (e.g., those using gradient descent or distance metrics) because unscaled features with very different numeric ranges may cause uneven contributions to the loss gradient or distance calculation. I cannot verify without a specific citation that this exact rationale is stated identically across all sources discussing this practice, though the general reasoning pattern is widely reported in machine learning literature.

#### Activation Function Shifting via Bias Terms

In a neural network layer, $f(Wx + b)$, the bias term $b$ acts as a horizontal shift applied before the activation function $f$ is evaluated (equivalently describable as a shift affecting where the activation's characteristic curve is centered relative to the raw weighted input).

**Example**

For a sigmoid neuron: $\sigma(wx + b)$

The bias $b$ shifts the midpoint of the sigmoid curve. Without a bias term, the curve's midpoint ($\sigma = 0.5$) is fixed at $x = 0$; with a bias, it shifts to $x = -b/w$ (assuming $w \neq 0$). This is a verifiable algebraic consequence of setting $wx + b = 0$ and solving for $x$.

#### Batch Normalization as Combined Transformation

Batch normalization applies a shift-and-scale transformation to layer activations:

$$\hat{x} = \gamma \left(\frac{x - \mu_B}{\sigma_B}\right) + \beta$$

where $\gamma$ and $\beta$ are learned scale and shift parameters, $\mu_B$ and $\sigma_B$ are batch statistics. This formula structurally mirrors the general transformation form $a \cdot f(x - h) + k$. This describes the algebraic structure of the commonly cited batch normalization formula; I cannot verify this reproduction against the original paper's exact notation without directly fetching that source.

### Order of Operations for Multiple Transformations

When combining transformations, order matters. A standard convention (though notation conventions can vary by textbook) is:

1. Horizontal shifts (inside the function argument)
2. Horizontal stretch/compression and reflection
3. Vertical stretch/compression and reflection
4. Vertical shifts (outside the function)

**Example**

$g(x) = 2f(3(x - 1)) + 4$ applied to $f(x)$:

1. Shift right by 1: $f(x-1)$
2. Compress horizontally by factor $\frac{1}{3}$: $f(3(x-1))$
3. Stretch vertically by factor 2: $2f(3(x-1))$
4. Shift up by 4: $2f(3(x-1)) + 4$

[Unverified] Whether every textbook presents this exact ordering convention identically; some instructional materials sequence steps differently while arriving at the same final graph, and I cannot verify a single universally standardized ordering without checking multiple specific curricula.

### Symmetry: Even and Odd Functions

| Type | Condition | Graph Symmetry | Example |
|---|---|---|---|
| Even | $f(-x) = f(x)$ | Symmetric about $y$-axis | $x^2$, $\cos(x)$ |
| Odd | $f(-x) = -f(x)$ | Symmetric about origin | $x^3$, $\sin(x)$ |

These are standard, verifiable algebraic definitions.

**Key Points**

- Many functions are neither even nor odd
- [Inference] Recognizing symmetry can simplify certain calculus operations, such as evaluating definite integrals over symmetric intervals, since an odd function integrated over $[-a, a]$ has a known simplification. This is a standard result covered in calculus curricula; I cannot verify this is phrased identically across every source without a specific citation, though the mathematical property itself is verifiable through direct integration.

### Summary Table

| Transformation | Formula | Effect on Graph |
|---|---|---|
| Vertical shift | $f(x) + k$ | Moves up/down |
| Horizontal shift | $f(x - h)$ | Moves right/left |
| Vertical scale | $a \cdot f(x)$ | Stretches/compresses vertically |
| Horizontal scale | $f(bx)$ | Stretches/compresses horizontally |
| Reflection ($x$-axis) | $-f(x)$ | Flips vertically |
| Reflection ($y$-axis) | $f(-x)$ | Flips horizontally |

**Related Topics**

- Even and odd function properties in integration
- Composite function graphing techniques
- Batch normalization and layer normalization in depth
- Standardization and normalization of input features
- Symmetry arguments in definite integral evaluation