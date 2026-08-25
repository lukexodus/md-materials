## Condition Number and Error Sensitivity

### Overview

The condition number of a matrix quantifies how much a small relative change in input can be amplified into a relative change in output when that matrix is used in a computation, most commonly when solving a linear system or applying a linear transformation. It is a property of the matrix itself, independent of which algorithm is used to perform the computation — a distinction addressed in more depth under numerical stability of algorithms.

### Formal Definition

For an invertible matrix $A$, the condition number with respect to a given norm is:

$$\kappa(A) = \|A\| \, \|A^{-1}\|$$

Using the spectral norm (induced by the $L_2$ vector norm), this equals the ratio of the largest to smallest singular value:

$$\kappa_2(A) = \frac{\sigma_{\max}(A)}{\sigma_{\min}(A)}$$

**Key Points**
- $\kappa(A) \ge 1$ always, since $\|A\|\|A^{-1}\| \ge \|AA^{-1}\| = \|I\| = 1$ by the sub-multiplicative property of induced matrix norms
- $\kappa(A) = 1$ for orthogonal matrices, representing the best possible conditioning, since orthogonal matrices preserve vector norms exactly
- As $A$ approaches singularity, $\sigma_{\min}(A) \to 0$, so $\kappa(A) \to \infty$

### Derivation of the Error Sensitivity Bound

For a linear system $A\mathbf{x} = \mathbf{b}$, consider a perturbation $\delta\mathbf{b}$ to the right-hand side, producing a perturbed solution $\mathbf{x} + \delta\mathbf{x}$ satisfying $A(\mathbf{x} + \delta\mathbf{x}) = \mathbf{b} + \delta\mathbf{b}$.

$$\frac{\|\delta\mathbf{x}\|}{\|\mathbf{x}\|} \le \kappa(A) \, \frac{\|\delta\mathbf{b}\|}{\|\mathbf{b}\|}$$

**Key Points**
- This inequality follows from $\delta\mathbf{x} = A^{-1}\delta\mathbf{b}$ combined with the norm bounds $\|\delta\mathbf{x}\| \le \|A^{-1}\|\|\delta\mathbf{b}\|$ and $\|\mathbf{b}\| \le \|A\|\|\mathbf{x}\|$, multiplied together
- $\kappa(A)$ acts as an amplification factor: a relative error of size $\epsilon$ in the input $\mathbf{b}$ can produce a relative error up to $\kappa(A) \cdot \epsilon$ in the solution $\mathbf{x}$
- This is a worst-case bound, not a guaranteed outcome for every perturbation direction — the actual amplification for a specific $\delta\mathbf{b}$ depends on its alignment with the singular vectors of $A$, and can be substantially smaller than the bound in favorable cases [Inference: this follows directly from the mathematical structure of the SVD-based error bound derivation]

### Diagram: Singular Values and Error Amplification

<svg viewBox="0 0 700 360" xmlns="http://www.w3.org/2000/svg">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Condition Number as Amplification Factor (svg_diagram)</text>

  <circle cx="180" cy="200" r="70" fill="none" stroke="#2563eb" stroke-width="2"/>
  <text x="180" y="290" text-anchor="middle" font-size="12" fill="#333">Input perturbation</text>
  <text x="180" y="306" text-anchor="middle" font-size="12" fill="#333">(small circle of errors)</text>

  <line x1="260" y1="200" x2="380" y2="200" stroke="#555" stroke-width="2" marker-end="url(#arrow4)"/>
  <text x="320" y="185" text-anchor="middle" font-size="12" fill="#555">apply A⁻¹</text>

  <ellipse cx="530" cy="200" rx="140" ry="45" fill="none" stroke="#dc2626" stroke-width="2"/>
  <text x="530" y="290" text-anchor="middle" font-size="12" fill="#333">Output perturbation</text>
  <text x="530" y="306" text-anchor="middle" font-size="12" fill="#333">(stretched into ellipse)</text>

  <defs>
    <marker id="arrow4" markerWidth="8" markerHeight="8" refX="4" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#555"/>
    </marker>
  </defs>

  <text x="350" y="340" text-anchor="middle" font-size="12" fill="#555">Ratio of ellipse axes reflects σ_max/σ_min, i.e. κ(A)</text>
</svg>

This is a conceptual illustration of how a matrix transforms a ball of input errors into an ellipsoid of output errors; it is not a plot of numerically computed error values for a specific matrix. [Inference]

### Relative vs Absolute Error

**Key Points**
- The condition number bound is stated in terms of relative error, not absolute error, since relative error is scale-invariant and therefore meaningful independent of the units or magnitude of $\mathbf{x}$ and $\mathbf{b}$
- A matrix can have entries of very different absolute magnitudes and still be well-conditioned, or have entries of similar magnitude and be poorly conditioned; conditioning depends on the relationship between singular values, not on raw entry magnitude alone

### Condition Number in Common Linear Algebra Operations

**Key Points**
- Solving $A\mathbf{x} = \mathbf{b}$: sensitivity to perturbations in $\mathbf{b}$ or to rounding error during solving is governed directly by $\kappa(A)$, as derived above
- Matrix inversion: computing $A^{-1}$ explicitly is subject to the same $\kappa(A)$-scaled error amplification, which is one reason explicit inversion is generally avoided in favor of direct solvers, as noted under numerical stability
- Least squares via normal equations: forming $A^TA$ squares the condition number, $\kappa(A^TA) = \kappa(A)^2$, since the singular values of $A^TA$ are the squares of the singular values of $A$ — a direct algebraic consequence of the relationship between $A$ and $A^TA$, not an approximation
- Eigenvalue computation: the sensitivity of computed eigenvalues to input perturbation depends on a related but distinct notion of conditioning, tied to how close eigenvalues are to each other and, for non-symmetric matrices, to the conditioning of the eigenvector matrix itself [Inference: this is a documented result in numerical linear algebra theory regarding eigenvalue sensitivity, distinct from but related to the matrix condition number defined above]

### Condition Number and Regularization

**Key Points**
- Adding a small positive value to the diagonal of a matrix before inversion or solving, $A + \epsilon I$, increases the smallest singular value away from zero, which reduces the condition number relative to the unregularized matrix
- This is the numerical-stability rationale behind ridge regression's regularization term, complementing the statistical/convexity rationale (uniqueness of the minimum) discussed under convexity and linear algebra connections
- The choice of $\epsilon$ trades off improved conditioning against increased bias in the resulting solution relative to the original, unregularized problem; there is no single universally correct value, and appropriate magnitude is problem-dependent [Inference]

### Practical Detection of Ill-Conditioning

**Key Points**
- Computing $\kappa(A)$ directly via singular value decomposition is the most direct diagnostic, though this adds computational cost beyond just solving the system
- A very small determinant relative to the matrix's scale can suggest near-singularity, though determinant magnitude alone is not a fully reliable indicator of conditioning, since it is also affected by matrix size and overall scale in ways that don't correspond directly to $\kappa(A)$ [Inference: determinant-based heuristics for conditioning are a known limitation discussed in numerical linear algebra references, since determinant conflates scale and singularity in ways singular values do not]
- Cross-checking a solution's sensitivity by solving the same system at two different floating-point precisions (as noted under numerical stability) and comparing results is a common practical diagnostic for suspected ill-conditioning

### Related Topics

- Numerical stability of algorithms
- Floating-point precision issues
- Singular value decomposition
- Eigenvalues and optimization landscape
- Ridge regression and regularization
- LU, QR, and Cholesky decomposition
