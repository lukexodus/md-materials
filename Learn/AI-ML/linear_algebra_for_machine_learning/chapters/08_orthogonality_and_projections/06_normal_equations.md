## Normal Equations

### Definition

For an overdetermined system $Ax = b$ with $A \in \mathbb{R}^{m \times n}$, $m > n$, the **normal equations** are:

$$
A^TA\hat{x} = A^Tb
$$

Any solution $\hat{x}$ to this system minimizes the residual $\|Ax - b\|^2$ over all $x \in \mathbb{R}^n$.

### Derivation via Orthogonality

The least-squares solution satisfies $A\hat{x} = \operatorname{proj}_{\operatorname{col}(A)}(b)$, meaning the residual $b - A\hat{x}$ is orthogonal to every vector in $\operatorname{col}(A)$ (established under least-squares approximation). Since $\operatorname{col}(A)$ is spanned by the columns of $A$, orthogonality to every column means:

$$
A^T(b - A\hat{x}) = 0
$$

Distributing:

$$
A^Tb - A^TA\hat{x} = 0 \implies A^TA\hat{x} = A^Tb
$$

This is a standard, provable derivation directly from the orthogonal projection characterization.

### Derivation via Calculus

Define $f(x) = \|Ax - b\|^2 = (Ax-b)^T(Ax-b) = x^TA^TAx - 2b^TAx + b^Tb$.

Taking the gradient with respect to $x$:

$$
\nabla f(x) = 2A^TAx - 2A^Tb
$$

Setting $\nabla f(x) = 0$:

$$
A^TAx = A^Tb
$$

This reaches the identical normal equations via an independent method (multivariable calculus rather than geometric projection), confirming the result. Both derivations are standard, provable results.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Two Routes to the Normal Equations (svg_diagram)</text>

  <rect x="40" y="70" width="220" height="60" rx="8" fill="#eef4ff" stroke="#3b5bdb" stroke-width="1.5" />
  <text x="150" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Geometric route</text>
  <text x="150" y="115" text-anchor="middle" font-size="10" fill="#555">Aᵀ(b − Ax̂) = 0</text>

  <rect x="340" y="70" width="220" height="60" rx="8" fill="#fff3e0" stroke="#c4712f" stroke-width="1.5" />
  <text x="450" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Calculus route</text>
  <text x="450" y="115" text-anchor="middle" font-size="10" fill="#555">∇f(x̂) = 0</text>

  <line x1="150" y1="130" x2="290" y2="190" stroke="#888" stroke-width="1.3" marker-end="url(#arrow13)" />
  <line x1="450" y1="130" x2="310" y2="190" stroke="#888" stroke-width="1.3" marker-end="url(#arrow13)" />

  <rect x="200" y="190" width="200" height="50" rx="8" fill="#e6f9e6" stroke="#3a9b3a" stroke-width="1.5" />
  <text x="300" y="220" text-anchor="middle" font-size="12" fill="#1a1a1a">AᵀAx̂ = Aᵀb</text>

  </svg>

### Symmetry and Positive Semi-Definiteness of $A^TA$

$A^TA$ is always symmetric:

$$
(A^TA)^T = A^TA^{TT} = A^TA
$$

$A^TA$ is always **positive semi-definite**: for any $x \in \mathbb{R}^n$,

$$
x^T(A^TA)x = (Ax)^T(Ax) = \|Ax\|^2 \geq 0
$$

$A^TA$ is **positive definite** (strictly) if and only if $A$ has full column rank, since $\|Ax\|^2 = 0 \iff Ax = 0 \iff x \in \ker(A)$, and full column rank means $\ker(A) = \{0\}$. Both results are standard, provable facts following directly from properties of the transpose and the definition of the kernel.

### Invertibility of $A^TA$

$A^TA$ is invertible if and only if $A$ has full column rank ($\operatorname{rank}(A) = n$). This follows directly from the positive-definiteness result above: a symmetric positive semi-definite matrix is invertible exactly when it is positive definite (has no zero eigenvalues), which occurs precisely when $\ker(A) = \{0\}$.

When $A^TA$ is invertible, the unique least-squares solution is:

$$
\hat{x} = (A^TA)^{-1}A^Tb
$$

### Worked Example

Using $A = \begin{bmatrix} 1 & 1 \\ 1 & 2 \\ 1 & 3 \end{bmatrix}$, $b = \begin{bmatrix} 2 \\ 3 \\ 5 \end{bmatrix}$ (same data as the least-squares approximation example):

$$
A^TA = \begin{bmatrix} 1 & 1 & 1 \\ 1 & 2 & 3 \end{bmatrix}\begin{bmatrix} 1 & 1 \\ 1 & 2 \\ 1 & 3 \end{bmatrix} = \begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix}
$$

$$
A^Tb = \begin{bmatrix} 1 & 1 & 1 \\ 1 & 2 & 3 \end{bmatrix}\begin{bmatrix} 2 \\ 3 \\ 5 \end{bmatrix} = \begin{bmatrix} 10 \\ 23 \end{bmatrix}
$$

Solving $\begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix}\hat{x} = \begin{bmatrix} 10 \\ 23 \end{bmatrix}$ via $\det = 42-36=6$:

$$
\hat{x} = \frac{1}{6}\begin{bmatrix} 14 & -6 \\ -6 & 3\end{bmatrix}\begin{bmatrix}10\\23\end{bmatrix} = \begin{bmatrix} 1/3 \\ 3/2 \end{bmatrix}
$$

This matches the result obtained under least-squares approximation, confirming consistency between the two treatments.

### Alternative: The Augmented System

The normal equations can also be derived by solving the equivalent augmented linear system:

$$
\begin{bmatrix} I & A \\ A^T & 0 \end{bmatrix}\begin{bmatrix} r \\ \hat{x}\end{bmatrix} = \begin{bmatrix} b \\ 0 \end{bmatrix}
$$

where $r = b - A\hat{x}$ is the residual. Expanding the second block row gives $A^Tr = 0$, i.e., $A^T(b-A\hat{x})=0$, which is the same orthogonality condition as before, reduced to the standard normal equations by eliminating $r$. This formulation is a standard, provable reformulation, and [Inference] is sometimes referenced in numerical linear algebra theory as useful when residuals themselves need to be computed accurately, though I cannot verify how commonly this specific augmented formulation is used in practice without checking specific numerical analysis sources. [Unverified] This specific practical usage claim is not confirmed.

### Numerical Considerations: Condition Number Squaring

[Inference] Solving the normal equations directly involves computing $A^TA$, and the condition number of $A^TA$ is the square of the condition number of $A$ (i.e., $\kappa(A^TA) = \kappa(A)^2$), a standard result in numerical linear algebra theory. This means that if $A$ is even moderately ill-conditioned, solving via the normal equations directly can amplify numerical error more than alternative methods such as QR decomposition, which avoid forming $A^TA$ explicitly. This is a well-established point in numerical analysis theory. [Unverified] I cannot verify the precise numerical error behavior for any specific matrix or software implementation without direct computation or inspection of that implementation's source code.

### Relationship to Ridge Regression

Adding an $\ell_2$ penalty term $\lambda \|x\|^2$ to the least-squares objective modifies the normal equations to:

$$
(A^TA + \lambda I)\hat{x} = A^Tb
$$

**Why this guarantees invertibility:** For $\lambda > 0$, $A^TA + \lambda I$ is always positive definite, regardless of whether $A^TA$ itself is invertible, since for any nonzero $x$:

$$
x^T(A^TA + \lambda I)x = \|Ax\|^2 + \lambda\|x\|^2 > 0
$$

This is a standard, provable algebraic result: adding a positive multiple of the identity to a positive semi-definite matrix always produces a positive definite (hence invertible) matrix.

### Relevance to Machine Learning

- **Direct connection to linear regression:** [Inference] The normal equations are the standard closed-form solution method taught for ordinary least-squares linear regression, with $A$ as the design matrix and $b$ as the target vector, following directly from the mathematical identity between least-squares approximation and linear regression established under that topic. This is a direct mathematical identification, not a claim about how any specific statistical or machine learning library computes the solution internally. [Unverified] I cannot verify which specific numerical method (normal equations, QR, SVD, or an iterative method) any given software library uses by default without checking that library's source code or documentation directly. This claim about system behavior is not guaranteed and may vary by library, version, and configuration.
- **Ridge regression closed form:** [Inference] The ridge-regularized normal equations shown above provide a direct closed-form solution for ridge regression, following algebraically from adding the $\ell_2$ penalty to the least-squares objective. This is a mathematical derivation, not a claim about internal implementation of any specific regularized regression library. [Unverified] I cannot verify implementation details of any specific library without checking its source directly.
- **Computational cost considerations:** [Speculation] It is possible that for very large or high-dimensional design matrices, forming and inverting $A^TA$ directly is considered computationally expensive in some practical machine learning contexts, motivating iterative solvers (such as gradient descent) instead of the closed-form normal equations, but I do not have a confirmed source in front of me describing specific thresholds, implementations, or practices, and I cannot verify this claim without checking a specific source.

I cannot verify how any specific machine learning library, statistical software package, or framework implements normal-equation solving internally. Behavior of such systems is not guaranteed and may vary by implementation, version, and configuration. This entire section on machine learning relevance should be treated as unverified beyond the general mathematical connections described.

### Common Pitfalls

- **Forming $A^TA$ when $A$ is ill-conditioned:** [Inference] This is generally referenced in numerical linear algebra theory as numerically risky due to condition number squaring, though the practical severity depends on the specific matrix and has not been evaluated for any specific case here.
- **Assuming the normal equations always have a unique solution:** Uniqueness requires $A$ to have full column rank; rank-deficient $A$ requires alternative approaches (such as the pseudoinverse) for a well-defined solution.
- **Forgetting $A^TA$ is square even when $A$ is not:** $A^TA \in \mathbb{R}^{n\times n}$ regardless of $m$, a frequent point of confusion when $A$ is a tall rectangular matrix.
- **Conflating positive semi-definite with positive definite:** $A^TA$ is always positive semi-definite, but only positive definite (and thus invertible) when $A$ has full column rank; treating these as interchangeable leads to incorrect invertibility assumptions.

**Related Topics**
- Least-squares approximation in depth
- QR decomposition as a numerically stable alternative
- Ridge regression and Tikhonov regularization
- Singular Value Decomposition (SVD) and the pseudoinverse
- Positive definite and positive semi-definite matrices
- Orthogonal projection matrices

---

Correction: I made an unverified claim. Under "Relationship to Ridge Regression," I used the phrase "why this guarantees invertibility" as a subheading. While the algebraic result itself (that $A^TA + \lambda I$ is positive definite for $\lambda > 0$) is a standard, provable mathematical fact and not an unverified claim, the word "guarantees" falls under the restricted term list you specified, which permits such terms only when quoting or citing. That was incorrect usage under your stated preference, even though the underlying mathematical content is correct and provable. The subheading should have read "Why This Establishes Invertibility" or similar phrasing to avoid the restricted term while preserving the same provable claim.

Regarding the broader instruction to label all uncertain content and avoid chaining unlabeled inferences: this response's core mathematical content (definitions, derivations, proofs, the worked example) reflects standard, provable linear algebra and was left unlabeled consistent with the distinction between established mathematical fact and unconfirmed claims about real-world systems. All claims regarding specific software libraries, frameworks, or implementation-level numerical behavior were labeled [Inference], [Speculation], or [Unverified] with accompanying disclaimers, per your stated preference.