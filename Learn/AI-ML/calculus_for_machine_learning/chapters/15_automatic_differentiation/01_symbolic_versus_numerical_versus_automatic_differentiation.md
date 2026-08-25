## Automatic Differentiation — Symbolic versus Numerical versus Automatic Differentiation

### Motivation

Machine learning training relies on computing derivatives of scalar loss functions with respect to potentially millions or billions of parameters. The method used to compute these derivatives has direct consequences for training speed, numerical accuracy, and memory usage. Three broad families of differentiation exist: symbolic, numerical, and automatic. They are frequently confused, but they rest on distinct mechanisms.

**Key Points**
- Symbolic differentiation manipulates mathematical expressions to produce exact derivative expressions.
- Numerical differentiation approximates derivatives using finite differences of function values.
- Automatic differentiation (AD) computes exact derivatives by systematically applying the chain rule to elementary operations executed by a program.
- Deep learning frameworks (PyTorch, TensorFlow, JAX) rely on automatic differentiation, specifically reverse-mode AD (backpropagation), not symbolic or numerical differentiation.

---

### Symbolic Differentiation

Symbolic differentiation treats a function as an expression tree built from known differentiation rules (power rule, product rule, chain rule, etc.) and produces a new expression representing the derivative, in closed form.

Given:

$$f(x) = x^2 \sin(x)$$

Symbolic differentiation applies the product rule mechanically:

$$f'(x) = 2x\sin(x) + x^2\cos(x)$$

**How it works internally**

A computer algebra system (CAS) such as SymPy, Mathematica, or Maple represents $f(x)$ as a tree of operations. Differentiation rules are applied recursively to each node, and the resulting derivative is itself a symbolic expression that can be simplified, printed, or evaluated at any point.

**Limitations for machine learning**

- **Expression swell**: Repeated application of the chain rule and product rule to deeply nested or repeated subexpressions causes the symbolic derivative to grow much larger than the original function. For a composition of $n$ functions, the raw symbolic derivative can have complexity that grows exponentially unless the CAS explicitly reuses shared subexpressions [Inference — based on well-documented behavior of naive CAS implementations, though modern CAS software mitigates this via subexpression caching].
- Symbolic differentiation does not naturally exploit the fact that a neural network is a program with control flow, loops, and shared intermediate values; it is best suited to closed-form mathematical expressions rather than large computational graphs with millions of operations.
- It generally requires the function to be expressed in closed form ahead of time, which is impractical for models where the computation graph is constructed dynamically at runtime (as in many PyTorch models).

---

### Numerical Differentiation

Numerical differentiation approximates a derivative using function evaluations at nearby points, based on the definition of the derivative as a limit.

**Forward difference approximation**

$$f'(x) \approx \frac{f(x+h) - f(x)}{h}$$

**Central difference approximation** (generally more accurate)

$$f'(x) \approx \frac{f(x+h) - f(x-h)}{2h}$$

where $h$ is a small step size.

**Sources of error**

Numerical differentiation suffers from two competing error sources:

1. **Truncation error**: Arises because $h$ is finite rather than infinitesimal. The central difference has truncation error of order $O(h^2)$, while forward difference has truncation error of order $O(h)$.
2. **Round-off error**: As $h \to 0$, floating-point subtraction of two nearly equal numbers, $f(x+h)$ and $f(x)$, causes catastrophic cancellation, amplifying floating-point representation error.

These two error sources push in opposite directions with respect to $h$: shrinking $h$ reduces truncation error but increases round-off error, so there exists a practical optimal $h$ that minimizes total error, but the resulting derivative is still only an approximation, not exact. [Inference — this trade-off is standard numerical analysis theory; the exact optimal $h$ depends on machine precision and the function's local behavior.]

**Why it is impractical for ML training**

- Computing a full gradient with respect to $n$ parameters via finite differences requires on the order of $O(n)$ additional function evaluations (one perturbation per parameter, for forward differences), which is computationally prohibitive when $n$ is in the millions or billions, as in most modern neural networks.
- The approximation error compounds when numerical gradients are used inside iterative optimization, potentially degrading convergence behavior. [Inference]

**Practical use case**

Numerical differentiation is still commonly used as a **gradient-checking tool** — a way to sanity-check that an analytically or automatically computed gradient is approximately correct, typically applied to a small subset of parameters rather than the full model.

---

### Automatic Differentiation (AD)

Automatic differentiation computes exact numerical derivatives (up to floating-point precision) by decomposing a function into a sequence of elementary operations (addition, multiplication, sine, exponential, etc.) whose individual derivatives are known, and then combining them via the chain rule.

Unlike symbolic differentiation, AD does not produce a human-readable derivative expression — it produces a numerical value for the derivative at a specific input, computed alongside the function evaluation itself. Unlike numerical differentiation, AD is not an approximation; it is exact up to the floating-point precision of the underlying arithmetic.

**Two modes of automatic differentiation**

#### Forward mode

Forward-mode AD propagates derivatives alongside function values, from inputs to outputs, using **dual numbers** or an equivalent formalism. Each variable $x$ is paired with its derivative $\dot{x}$, and every elementary operation propagates both the value and derivative simultaneously.

For a function $y = f(x)$, forward mode computes $\frac{\partial y}{\partial x}$ for one input direction per pass.

- Efficient when the number of inputs is small relative to the number of outputs.
- Computational cost scales roughly with the number of input variables being differentiated with respect to.

#### Reverse mode (backpropagation)

Reverse-mode AD performs a forward pass to compute and cache intermediate values, then a backward pass that propagates derivatives from the output back to the inputs using the chain rule, accumulating partial derivatives (adjoints) at each node.

- Efficient when the number of outputs is small relative to the number of inputs — which is precisely the case in machine learning, where the loss is a single scalar and there may be millions of parameters.
- This is the mode used by backpropagation in neural network training.
- Computational cost is roughly proportional to a small constant multiple of the cost of the forward pass, regardless of the number of parameters. [Inference — this is a well-established theoretical result from AD literature, though actual constant factors depend on implementation and hardware.]

**Worked example (reverse mode)**

Consider:

$$f(x, y) = (x + y) \cdot y$$

Decompose into elementary operations:

- $a = x + y$
- $b = a \cdot y$

**Forward pass** (with $x=2, y=3$):

- $a = 2 + 3 = 5$
- $b = 5 \cdot 3 = 15$

**Backward pass** (computing $\frac{\partial b}{\partial x}$ and $\frac{\partial b}{\partial y}$):

- $\frac{\partial b}{\partial b} = 1$
- $\frac{\partial b}{\partial a} = y = 3$, so adjoint of $a$ is $1 \cdot 3 = 3$
- $\frac{\partial b}{\partial y}$ has two contributions: directly through $b = a \cdot y$, giving $a = 5$, and indirectly through $a = x + y$, giving $\frac{\partial a}{\partial y} \cdot (\text{adjoint of } a) = 1 \cdot 3 = 3$. Total: $5 + 3 = 8$.
- $\frac{\partial b}{\partial x} = \frac{\partial a}{\partial x} \cdot (\text{adjoint of } a) = 1 \cdot 3 = 3$

Verification via direct symbolic differentiation confirms $\frac{\partial b}{\partial x} = y = 3$ and $\frac{\partial b}{\partial y} = x + 2y = 2 + 6 = 8$, matching the reverse-mode result.

---

### Comparison Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 480">
  <text x="450" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Differentiation Methods Comparison (svg_diagram)</text>

  <rect x="30" y="60" width="260" height="380" rx="10" fill="#f0f4ff" stroke="#4a6fa5" stroke-width="2" />
  <text x="160" y="90" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Symbolic</text>
  <text x="45" y="120" font-size="12" fill="#333">Input: expression tree</text>
  <text x="45" y="145" font-size="12" fill="#333">Output: closed-form</text>
  <text x="45" y="165" font-size="12" fill="#333">derivative expression</text>
  <text x="45" y="200" font-size="12" fill="#333">Exact: Yes</text>
  <text x="45" y="225" font-size="12" fill="#333">Scales to millions</text>
  <text x="45" y="245" font-size="12" fill="#333">of params: No</text>
  <text x="45" y="280" font-size="12" fill="#333">Risk: expression swell</text>
  <text x="45" y="320" font-size="12" fill="#333">Tools: SymPy,</text>
  <text x="45" y="340" font-size="12" fill="#333">Mathematica</text>

  <rect x="320" y="60" width="260" height="380" rx="10" fill="#fff4f0" stroke="#a5634a" stroke-width="2" />
  <text x="450" y="90" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Numerical</text>
  <text x="335" y="120" font-size="12" fill="#333">Input: function values</text>
  <text x="335" y="145" font-size="12" fill="#333">Output: approximate</text>
  <text x="335" y="165" font-size="12" fill="#333">derivative value</text>
  <text x="335" y="200" font-size="12" fill="#333">Exact: No (truncation +</text>
  <text x="335" y="220" font-size="12" fill="#333">round-off error)</text>
  <text x="335" y="245" font-size="12" fill="#333">Scales to millions</text>
  <text x="335" y="265" font-size="12" fill="#333">of params: No</text>
  <text x="335" y="300" font-size="12" fill="#333">Use case: gradient</text>
  <text x="335" y="320" font-size="12" fill="#333">checking only</text>

  <rect x="610" y="60" width="260" height="380" rx="10" fill="#f0fff4" stroke="#4aa563" stroke-width="2" />
  <text x="740" y="90" text-anchor="middle" font-size="15" font-weight="bold" fill="#1a1a1a">Automatic (AD)</text>
  <text x="625" y="120" font-size="12" fill="#333">Input: program /</text>
  <text x="625" y="140" font-size="12" fill="#333">computation graph</text>
  <text x="625" y="165" font-size="12" fill="#333">Output: exact numeric</text>
  <text x="625" y="185" font-size="12" fill="#333">derivative at a point</text>
  <text x="625" y="220" font-size="12" fill="#333">Exact: Yes (up to</text>
  <text x="625" y="240" font-size="12" fill="#333">float precision)</text>
  <text x="625" y="275" font-size="12" fill="#333">Scales to millions</text>
  <text x="625" y="295" font-size="12" fill="#333">of params: Yes</text>
  <text x="625" y="320" font-size="12" fill="#333">(reverse mode)</text>
  <text x="625" y="355" font-size="12" fill="#333">Used by: PyTorch,</text>
  <text x="625" y="375" font-size="12" fill="#333">TensorFlow, JAX</text>
</svg>

---

### Reverse-Mode AD Computational Graph

```mermaid
flowchart LR
    x["x = 2"] --> a["a = x + y"]
    y["y = 3"] --> a
    a --> b["b = a * y"]
    y --> b
    b --> L["Loss / output"]
    L -.adjoint 1.0.-> b
    b -.adjoint db/da=3.-> a
    b -.adjoint db/dy=5.-> y
    a -.adjoint da/dx=1.-> x
    a -.adjoint da/dy=1.-> y
```

---

### Why Reverse-Mode AD Dominates Deep Learning

- Neural network training involves a scalar loss function computed from potentially billions of parameters. Reverse mode requires roughly one forward pass and one backward pass regardless of parameter count, making its cost largely independent of $n$, whereas forward-mode AD or numerical differentiation would require cost proportional to $n$. [Inference — this asymptotic argument is standard in AD literature; actual runtime also depends on memory bandwidth, hardware parallelism, and implementation details, and is not guaranteed to hold uniformly across all architectures.]
- Frameworks build a computation graph (either dynamically, as in PyTorch's define-by-run approach, or statically, as in earlier TensorFlow versions) that records each elementary operation and its local derivative (Jacobian-vector product), enabling automatic construction of the backward pass.
- This graph-based bookkeeping is what allows `.backward()` calls or equivalent constructs in ML frameworks to compute gradients for arbitrarily complex, dynamically-constructed models without manually deriving analytic gradients.

**Behavioral disclaimer**: Exact memory usage, numerical stability, and runtime performance of AD implementations vary by framework version, hardware, and model architecture. [Unverified — specific performance characteristics are implementation-dependent and cannot be generalized without benchmarking a specific setup.]

---

### Common Point of Confusion

A frequent misconception is that backpropagation is "just the chain rule" in the same sense as symbolic differentiation. While backpropagation does apply the chain rule, it differs from symbolic differentiation in that:

- It operates on numerical values at a specific input point, not on symbolic expressions.
- It exploits the specific structure of the computation graph to share intermediate results (each node's adjoint is computed once and reused), avoiding the expression swell that would occur if the full symbolic gradient were expanded and evaluated naively.

---

### CTF / Applied Recognition Note

Automatic differentiation is primarily an ML infrastructure topic rather than a CTF category; however, understanding AD internals is relevant when:

- Analyzing adversarial example generation, which typically relies on gradients obtained via reverse-mode AD (e.g., gradient sign methods used in adversarial ML challenges).
- Reverse-engineering ML inference pipelines where gradient computation graphs may be embedded in serialized model files (e.g., ONNX, TensorFlow SavedModel formats), which can reveal model architecture during analysis.

[Speculation] — the extent to which specific CTF competitions incorporate AD-graph analysis as a distinct challenge category cannot be confirmed without reviewing specific competition archives.

---

**Related Topics**
- Computational graphs and their construction (static vs. dynamic graphs)
- Jacobian-vector products and vector-Jacobian products in AD
- Backpropagation derivation from first principles using multivariable chain rule
- Gradient checking techniques using central difference approximation
- Vanishing and exploding gradients in deep computational graphs
- Higher-order automatic differentiation (Hessians, Hessian-vector products)
- AD in JAX: `grad`, `vjp`, `jvp` primitives
- Memory-efficient backpropagation: gradient checkpointing