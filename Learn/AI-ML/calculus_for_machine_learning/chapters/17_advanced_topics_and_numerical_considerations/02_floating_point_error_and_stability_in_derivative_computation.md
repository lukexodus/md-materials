## Floating-Point Error and Stability in Derivative Computation

### Overview

Derivative computations in machine learning — whether performed analytically, numerically, or through automatic differentiation — are ultimately executed using finite-precision floating-point arithmetic. This introduces sources of error distinct from mathematical approximation error. Understanding these effects is essential for diagnosing training instabilities, vanishing/exploding gradients, and unreliable gradient checks.

### Floating-Point Representation Basics

Computers represent real numbers using the IEEE 754 standard, typically as 32-bit (single precision) or 64-bit (double precision) floats. A floating-point number is stored as:

$$x = \pm (1.f) \times 2^{e}$$

where $f$ is the fraction (mantissa) and $e$ is the exponent.

**Key Points**
- Only a finite subset of real numbers can be represented exactly; most values are rounded to the nearest representable float.
- **Machine epsilon** ($\epsilon_{machine}$) is the smallest number such that $1 + \epsilon_{machine} \neq 1$ in floating-point arithmetic. For double precision, $\epsilon_{machine} \approx 2.22 \times 10^{-16}$; for single precision, $\epsilon_{machine} \approx 1.19 \times 10^{-7}$.
- The relative precision of floating-point numbers is roughly constant across magnitudes, but absolute precision varies — large numbers have larger gaps between representable values than small numbers.

### Round-off Error

Round-off error arises because each arithmetic operation (addition, subtraction, multiplication, division) may introduce a small rounding error, since the true result often cannot be represented exactly.

$$\text{fl}(x \, \text{op} \, y) = (x \, \text{op} \, y)(1 + \delta), \quad |\delta| \le \epsilon_{machine}$$

**Key Points**
- Each individual operation's error is bounded by machine epsilon, but errors can accumulate over long computational sequences.
- Deep neural networks with many layers perform long chains of floating-point operations during both forward and backward passes, so accumulated round-off error is a real concern, particularly in very deep or recurrent architectures.
- [Inference] The accumulation is not strictly linear in the number of operations — it depends on the conditioning of each operation and can grow more slowly or more quickly depending on the computation structure.

### Catastrophic Cancellation

This is one of the most important failure modes in derivative computation. It occurs when subtracting two nearly equal floating-point numbers, causing significant loss of relative precision.

$$f(x+h) - f(x)$$

When $h$ is small, $f(x+h)$ and $f(x)$ are close in value. Their leading digits cancel, leaving only the less-significant (and more error-prone) digits to determine the result.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 300">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Catastrophic Cancellation (svg_diagram)</text>

  <text x="60" y="90" font-size="16" font-family="monospace" fill="#1a1a1a">f(x+h) = 1.234567890123</text>
  <text x="60" y="130" font-size="16" font-family="monospace" fill="#1a1a1a">f(x)   = 1.234567880000</text>
  <line x1="60" y1="145" x2="400" y2="145" stroke="#333" stroke-width="1.5" />
  <text x="60" y="175" font-size="16" font-family="monospace" fill="#dc2626" font-weight="bold">diff   = 0.000000010123</text>

  <rect x="200" y="60" width="200" height="20" fill="none" stroke="#16a34a" stroke-width="2" />
  <text x="300" y="55" text-anchor="middle" font-size="12" fill="#16a34a">matching digits (lost)</text>

  <rect x="400" y="60" width="90" height="20" fill="none" stroke="#dc2626" stroke-width="2" />
  <text x="445" y="200" text-anchor="middle" font-size="12" fill="#dc2626">only these digits survive —</text>
  <text x="445" y="218" text-anchor="middle" font-size="12" fill="#dc2626">precision is dominated by</text>
  <text x="445" y="236" text-anchor="middle" font-size="12" fill="#dc2626">representation error, not signal</text>
</svg>

**Key Points**
- The relative error of the difference can be much larger than the relative error of the original inputs.
- This directly limits how small $h$ can be made in finite difference approximations before round-off error overwhelms the signal — the origin of the truncation-vs-round-off trade-off discussed in numerical differentiation.
- Also occurs in other ML contexts: computing variance as $E[X^2] - (E[X])^2$ is a classic example of a formula prone to catastrophic cancellation, especially when variance is small relative to the mean.

### Vanishing and Exploding Gradients as a Numerical Stability Issue

While vanishing/exploding gradients are often introduced as a consequence of the chain rule across many layers, they also have a floating-point dimension.

$$\frac{\partial L}{\partial x_0} = \prod_{i=1}^{n} \frac{\partial x_i}{\partial x_{i-1}}$$

**Key Points**
- If each factor in the product is consistently less than 1, the product shrinks geometrically and can underflow to exactly zero in floating-point representation once it falls below the smallest representable normal number.
- If each factor is consistently greater than 1, the product grows geometrically and can overflow to `inf`.
- Once a value underflows to zero or overflows to infinity, subsequent gradient information for earlier layers is entirely lost (zero) or corrupted (`inf`/`NaN`), not just numerically imprecise.
- This is distinct from, but compounds, the analytical vanishing/exploding gradient problem caused by activation function derivatives and weight initialization.

### NaN and Inf Propagation

Once a `NaN` (Not a Number) or `Inf` value appears in a computation graph, it typically propagates through nearly all downstream operations.

**Key Points**
- Common sources: division by zero, $\log(0)$ or $\log(\text{negative})$, $0/0$, overflow in exponentials (e.g., unstabilized softmax), and square roots of negative numbers.
- `NaN` is "contagious" — almost any arithmetic operation involving `NaN` produces `NaN`, making it easy to detect but hard to trace back to its origin without careful debugging (e.g., gradient hooks or anomaly detection tools).
- [Unverified] Some ML frameworks provide built-in anomaly detection modes (e.g., "detect NaN" or autograd anomaly detection) that halt execution at the operation that first produced the invalid value, which is generally more useful for debugging than observing where `NaN` eventually surfaces.

### Mitigation Strategies

**Log-sum-exp trick.** Used to stabilize computations involving sums of exponentials, such as softmax and cross-entropy loss:

$$\log \sum_i e^{x_i} = m + \log \sum_i e^{x_i - m}, \quad m = \max_i x_i$$

Subtracting the maximum before exponentiating prevents overflow, since the largest exponent becomes $e^0 = 1$ rather than a potentially huge value.

**Key Points**
- This identity is mathematically exact — it does not change the result, only the numerical path used to compute it.
- Widely used internally in softmax and cross-entropy implementations in ML frameworks.

**Other common mitigation approaches:**
- Adding a small epsilon constant inside denominators or logarithms (e.g., $\log(x + \epsilon)$) to avoid exact-zero inputs, though this technique introduces a small bias and the choice of $\epsilon$ involves a trade-off between stability and accuracy.
- Gradient clipping, which bounds the norm or values of gradients to prevent explosion during backpropagation, though it does not address the underlying cause of instability.
- Using normalized or centered formulas for statistical quantities (e.g., computing variance via a numerically stable two-pass or Welford's online algorithm rather than the naive $E[X^2] - (E[X])^2$ formula).
- Mixed-precision training, which uses lower precision (e.g., float16/bfloat16) for speed while maintaining a float32 master copy of weights and using loss scaling to prevent gradient underflow. [Inference] This approach generally reduces but does not fully eliminate floating-point stability concerns, since lower-precision formats have a narrower representable range and coarser rounding.
- Choosing numerically stable algebraic reformulations of a formula (e.g., preferring $\frac{1}{1+e^{-x}}$ computed via a stable sigmoid implementation rather than a naive direct evaluation that can overflow for large negative $x$).

### Conditioning and Stability

Two related but distinct concepts describe how errors behave in a computation:

**Key Points**
- **Conditioning** is a property of the mathematical problem itself — a well-conditioned problem has outputs that are insensitive to small perturbations in inputs; an ill-conditioned problem amplifies input errors regardless of the algorithm used.
- **Stability** is a property of the algorithm used to solve a problem — a stable algorithm does not introduce unnecessary additional error beyond what the problem's conditioning already implies.
- A well-conditioned problem can still yield inaccurate results if solved with a numerically unstable algorithm, and a poorly conditioned problem may yield unreliable results even with a stable algorithm.
- [Inference] In deep learning, poor weight initialization or extreme input feature scales can contribute to ill-conditioned optimization landscapes, which is part of the motivation for input normalization and careful initialization schemes.

### Practical Implications for ML Practitioners

- When debugging `NaN` losses, checking for unstabilized exponentials, division by near-zero denominators, and learning rates that are too large is a reasonable starting point.
- Gradient checking (via finite differences) should be interpreted with awareness that both the analytical and numerical gradients are subject to floating-point error, so small relative errors are expected even for correct implementations.
- [Speculation] As models and training pipelines increasingly use reduced-precision formats for efficiency, floating-point stability considerations are likely to become more prominent in day-to-day ML engineering rather than a niche numerical-methods concern.

**Related Topics**
- Automatic differentiation: forward mode vs. reverse mode
- Softmax and cross-entropy: derivation and numerical stabilization
- Gradient clipping and exploding gradient mitigation
- Mixed-precision and low-precision training
- Weight initialization strategies (Xavier/Glorot, He initialization)
- Condition numbers and the Hessian in optimization landscapes