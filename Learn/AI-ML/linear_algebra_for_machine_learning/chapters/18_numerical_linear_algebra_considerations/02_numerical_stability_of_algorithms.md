## Numerical Stability of Algorithms

### Overview

Numerical stability describes how sensitive an algorithm's output is to small errors — from floating-point rounding, input perturbation, or approximation — introduced during computation. An algorithm can be applied to a well-posed mathematical problem and still produce inaccurate results if the algorithm itself amplifies small errors, making stability a property of the algorithm as distinct from the conditioning of the underlying problem.

### Stability vs Conditioning: A Key Distinction

**Key Points**
- Conditioning is a property of the problem itself: a well-conditioned problem produces small output changes for small input changes, while an ill-conditioned problem amplifies them, regardless of which algorithm is used to solve it
- Stability is a property of the algorithm: a stable algorithm does not introduce significant additional error beyond what the problem's conditioning already implies, whereas an unstable algorithm can produce large errors even on a well-conditioned problem
- These two properties are independent: a well-conditioned problem can be solved inaccurately by an unstable algorithm, and an ill-conditioned problem will produce unreliable results even with a stable algorithm, since no algorithm can undo the sensitivity inherent to the problem itself

### Forward Error and Backward Error

**Key Points**
- Forward error measures the difference between the computed result and the true mathematical result
- Backward error measures the smallest perturbation to the *input* that would make the computed result the exact answer to that perturbed input
- An algorithm is called backward stable if its backward error is small (on the order of machine precision), a standard definition used in numerical analysis to evaluate algorithms independent of the specific problem's conditioning [Inference: this is the standard formal definition used in numerical analysis literature; classifying a specific real-world implementation as backward stable requires a formal analysis of that implementation, not an assumption]
- Backward stability, combined with problem conditioning, bounds the forward error: a backward-stable algorithm on a well-conditioned problem yields small forward error, while the same algorithm on an ill-conditioned problem can still yield large forward error

### Diagram: Stability and Conditioning as Independent Axes

<svg viewBox="0 0 700 380" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Algorithm Stability vs Problem Conditioning (svg_diagram)</text>

  <line x1="100" y1="320" x2="620" y2="320" stroke="#333" stroke-width="2"/>
  <line x1="100" y1="320" x2="100" y2="60" stroke="#333" stroke-width="2"/>
  <text x="360" y="355" text-anchor="middle" font-size="13" fill="#333">Problem Conditioning (well → ill)</text>
  <text x="45" y="190" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 45 190)">Algorithm Stability (stable → unstable)</text>

  <rect x="120" y="80" width="220" height="120" fill="#bbf7d0" fill-opacity="0.6"/>
  <text x="230" y="140" text-anchor="middle" font-size="13" fill="#166534">Small error</text>
  <text x="230" y="158" text-anchor="middle" font-size="12" fill="#166534">(best case)</text>

  <rect x="380" y="80" width="220" height="120" fill="#fef08a" fill-opacity="0.6"/>
  <text x="490" y="140" text-anchor="middle" font-size="13" fill="#854d0e">Error from</text>
  <text x="490" y="158" text-anchor="middle" font-size="12" fill="#854d0e">problem itself</text>

  <rect x="120" y="200" width="220" height="120" fill="#fecaca" fill-opacity="0.6"/>
  <text x="230" y="260" text-anchor="middle" font-size="13" fill="#991b1b">Error from</text>
  <text x="230" y="278" text-anchor="middle" font-size="12" fill="#991b1b">algorithm itself</text>

  <rect x="380" y="200" width="220" height="120" fill="#fca5a5" fill-opacity="0.7"/>
  <text x="490" y="260" text-anchor="middle" font-size="13" fill="#7f1d1d">Compounded</text>
  <text x="490" y="278" text-anchor="middle" font-size="12" fill="#7f1d1d">large error</text>
</svg>

This is a conceptual illustration of how the two error sources combine, not a plot generated from measured error values on a specific problem. [Inference]

### Common Sources of Instability in Linear Algebra Algorithms

**Key Points**
- Dividing by small pivot values during Gaussian elimination can amplify rounding error; partial pivoting (reordering rows to use the largest available pivot) is a standard technique to reduce this effect, and is well documented as improving stability relative to naive elimination without pivoting [Inference: partial pivoting's stability benefit relative to no pivoting is an established result in numerical linear algebra]
- Computing $A^TA$ explicitly (for example, in the normal equations approach to least squares) squares the condition number of $A$, since $\kappa(A^TA) = \kappa(A)^2$, making this approach less numerically stable than methods that avoid forming $A^TA$ directly, such as QR decomposition or SVD-based solvers [Inference: the condition-number-squaring relationship follows directly from the mathematical definition of condition number applied to $A^TA$]
- Classical Gram-Schmidt orthogonalization, as noted under floating-point precision issues, loses orthogonality due to accumulated rounding error more readily than modified Gram-Schmidt or Householder-based QR methods

### Stable Algorithm Design Patterns

#### Avoiding Explicit Matrix Inversion

**Key Points**
- Solving $A\mathbf{x} = \mathbf{b}$ by explicitly computing $A^{-1}$ and then multiplying, $\mathbf{x} = A^{-1}\mathbf{b}$, is generally less numerically stable and more computationally expensive than solving the linear system directly via factorization methods (e.g., LU or QR decomposition) [Inference: this is a widely documented recommendation in numerical linear algebra practice; the magnitude of stability improvement varies with the specific matrix and algorithm used]
- This is a common source of unnecessary numerical error in ML code that computes matrix inverses directly rather than using dedicated linear-system solvers

#### Log-Space Computation

**Key Points**
- Computing products of many small probabilities directly can cause numerical underflow, since the product can become smaller than the smallest representable floating-point value
- Performing the equivalent computation in log-space, summing log-probabilities instead of multiplying probabilities, avoids this underflow, since addition does not shrink magnitudes toward zero the way repeated multiplication of values less than 1 does
- The log-sum-exp trick, $\log\sum_i e^{x_i} = m + \log\sum_i e^{x_i - m}$ where $m = \max_i x_i$, is used to compute this operation stably by preventing overflow in the exponential terms, a standard technique used in softmax and cross-entropy loss implementations [Inference: this is a well-established, widely documented numerical technique in ML implementations]

#### Numerically Stable Variance and Statistics

**Key Points**
- As noted under floating-point precision issues, computing variance via the naive two-pass formula $E[x^2] - (E[x])^2$ is prone to catastrophic cancellation when variance is small relative to the mean
- Welford's online algorithm computes a running variance incrementally without this subtraction pattern, and is a standard reference example of a numerically stable statistical algorithm in numerical computing literature

### Stability in Iterative Algorithms

**Key Points**
- Iterative methods (e.g., conjugate gradient, power iteration for eigenvalues) can accumulate rounding error across many iterations, though many standard iterative methods include implicit or explicit error-correction properties that limit unbounded error growth under typical conditions [Inference: the degree of error accumulation and self-correction depends on the specific algorithm, its stopping criteria, and the conditioning of the problem being solved, and is not uniform across all iterative methods]
- Power iteration for finding the dominant eigenvector can converge slowly or become numerically unstable when the two largest eigenvalues are close in magnitude, since the convergence rate of power iteration depends on the ratio between the largest and second-largest eigenvalues [Inference: this dependency is a standard, well-established property of the power iteration algorithm's convergence analysis]

### Stability Considerations in Deep Learning

**Key Points**
- Vanishing and exploding gradients in deep networks are, in part, a numerical stability phenomenon related to repeated multiplication of Jacobian matrices during backpropagation through many layers, where eigenvalues (or singular values) of these Jacobians less than 1 or greater than 1 compound multiplicatively across layers [Inference: this characterization reflects a standard explanation given in deep learning literature for vanishing/exploding gradient phenomena; the precise numerical behavior in any specific network depends on its architecture, initialization, and activation functions, and is not fully determined by this mechanism alone]
- Techniques such as gradient clipping, careful weight initialization (e.g., Xavier/Glorot, He initialization), batch normalization, and residual connections have each been proposed and empirically studied as ways to mitigate these numerical stability issues in deep network training [Unverified as a universal outcome — these techniques are documented as commonly used and are supported by both theoretical motivation and empirical results in specific studies, but their effectiveness varies across architectures, datasets, and training regimes and is not guaranteed in every case]

### Testing and Diagnosing Numerical Stability

**Key Points**
- Comparing results across different floating-point precisions (e.g., float32 vs float64) on the same computation is a practical diagnostic: large discrepancies suggest the computation may be numerically unstable at lower precision
- Perturbing inputs slightly and observing the resulting change in output relative to the expected sensitivity from the problem's condition number can help distinguish algorithm instability from inherent problem ill-conditioning
- Established numerical libraries (e.g., LAPACK-based routines) generally implement algorithms with documented stability properties, which is a common reason to prefer them over custom-written implementations of standard linear algebra operations for ML applications [Inference: this reflects general, widely-cited guidance in numerical computing practice; it does not guarantee every function in every such library is stable for every conceivable input]

### Related Topics

- Floating-point precision issues
- Condition number and its role in optimization
- QR decomposition and orthogonalization methods
- Eigendecomposition and power iteration
- Vanishing and exploding gradients in deep learning
- LU and Cholesky decomposition for solving linear systems
