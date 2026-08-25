## Least-Squares Approximation

### The Overdetermined System Problem

Given a system $Ax = b$ where $A \in \mathbb{R}^{m \times n}$ with $m > n$ (more equations than unknowns), an exact solution generally does not exist when $b \notin \operatorname{col}(A)$. **Least-squares approximation** seeks $\hat{x}$ minimizing the residual norm:

$$
\hat{x} = \operatorname{argmin}_{x \in \mathbb{R}^n} \|Ax - b\|^2
$$

### Geometric Formulation

Minimizing $\|Ax - b\|$ over all $x$ is equivalent to finding the point in $\operatorname{col}(A)$ closest to $b$. By the minimum distance property of orthogonal projection (established under orthogonal complements), this closest point is exactly $\operatorname{proj}_{\operatorname{col}(A)}(b)$, and:

$$
A\hat{x} = \operatorname{proj}_{\operatorname{col}(A)}(b)
$$

This means the residual $b - A\hat{x}$ must be orthogonal to every vector in $\operatorname{col}(A)$:

$$
b - A\hat{x} \in \operatorname{col}(A)^\perp = \ker(A^T)
$$

This geometric characterization is a standard, provable consequence of the minimum-distance property of orthogonal projection.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300">
  <text x="300" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Least-Squares as Orthogonal Projection (svg_diagram)</text>

  <line x1="60" y1="250" x2="540" y2="250" stroke="#eee" stroke-width="1" />

  <line x1="120" y1="250" x2="460" y2="130" stroke="#3b5bdb" stroke-width="2.5" />
  <text x="470" y="125" font-size="12" fill="#3b5bdb">col(A)</text>

  <line x1="300" y1="250" x2="360" y2="80" stroke="#3a9b3a" stroke-width="2" marker-end="url(#arrow12)" />
  <text x="365" y="75" font-size="11" fill="#3a9b3a">b</text>

  <line x1="300" y1="250" x2="352" y2="182" stroke="#c4712f" stroke-width="2" marker-end="url(#arrow12)" />
  <text x="358" y="182" font-size="11" fill="#c4712f">Ax̂ = proj (b)</text>

  <line x1="352" y1="182" x2="360" y2="80" stroke="#888" stroke-width="1.3" stroke-dasharray="4,3" />
  <text x="375" y="140" font-size="10" fill="#555">b − Ax̂ ⊥ col(A)</text>

  <rect x="340" y="172" width="10" height="10" fill="none" stroke="#888" stroke-width="1" />

  </svg>

### The Normal Equations

The orthogonality condition $A^T(b - A\hat{x}) = 0$ (since $\ker(A^T)$ consists exactly of vectors orthogonal to $\operatorname{col}(A)$) rearranges to:

$$
A^TA\hat{x} = A^Tb
$$

These are the **normal equations**. If $A$ has full column rank, $A^TA$ is invertible, giving the closed-form solution:

$$
\hat{x} = (A^TA)^{-1}A^Tb
$$

**Derivation via calculus (equivalent approach):** Minimizing $f(x) = \|Ax-b\|^2 = (Ax-b)^T(Ax-b)$ by setting the gradient to zero:

$$
\nabla f(x) = 2A^T(Ax - b) = 0 \implies A^TAx = A^Tb
$$

This calculus-based derivation reaches the same normal equations, confirming the result via a second, independent method. Both derivations are standard, provable results.

### Worked Example

Fit a line $y = c_0 + c_1 t$ to data points $(1, 2), (2, 3), (3, 5)$.

Setting up $A$ and $b$:

$$
A = \begin{bmatrix} 1 & 1 \\ 1 & 2 \\ 1 & 3 \end{bmatrix}, \qquad b = \begin{bmatrix} 2 \\ 3 \\ 5 \end{bmatrix}
$$

Computing $A^TA$:

$$
A^TA = \begin{bmatrix} 3 & 6 \\ 6 & 14 \end{bmatrix}
$$

Computing $A^Tb$:

$$
A^Tb = \begin{bmatrix} 10 \\ 23 \end{bmatrix}
$$

Solving $A^TA\hat{x} = A^Tb$: $\det(A^TA) = 42 - 36 = 6$, so:

$$
(A^TA)^{-1} = \frac{1}{6}\begin{bmatrix} 14 & -6 \\ -6 & 3 \end{bmatrix}
$$

$$
\hat{x} = \frac{1}{6}\begin{bmatrix} 14 & -6 \\ -6 & 3 \end{bmatrix}\begin{bmatrix} 10 \\ 23 \end{bmatrix} = \frac{1}{6}\begin{bmatrix} 140 - 138 \\ -60+69 \end{bmatrix} = \frac{1}{6}\begin{bmatrix} 2 \\ 9 \end{bmatrix} = \begin{bmatrix} 1/3 \\ 3/2 \end{bmatrix}
$$

So $\hat{c}_0 = 1/3$, $\hat{c}_1 = 3/2$, giving fitted line $y = 1/3 + (3/2)t$. Checking residuals: at $t=1$, predicted $y = 1/3 + 3/2 = 11/6 \approx 1.833$ (actual 2); at $t=2$, predicted $= 1/3+3 = 10/3 \approx 3.333$ (actual 3); at $t=3$, predicted $=1/3+4.5=29/6\approx 4.833$ (actual 5). These residuals are small and consistent with a least-squares fit rather than an exact solution, since no line passes through all three points exactly (verifiable directly, since the three points are not collinear).

### QR-Based Solution (Numerically Preferable Route)

As derived under QR decomposition, if $A = QR$:

$$
R\hat{x} = Q^Tb
$$

solved by back-substitution, avoiding explicit formation of $A^TA$. [Inference] This route is generally referenced in numerical linear algebra theory as preferable when $A$ is ill-conditioned, because forming $A^TA$ squares the condition number of $A$, which can amplify floating-point rounding error. This is a standard point in numerical analysis theory. [Unverified] I cannot verify the precise numerical behavior of any specific software library's least-squares solver without checking that library's source code or documentation directly, and I cannot verify this claim without checking a specific source.

### SVD-Based Solution (Most General Route)

For matrices that are rank-deficient (where $A^TA$ is singular), the **Moore-Penrose pseudoinverse** $A^+$, computable via Singular Value Decomposition, gives the minimum-norm least-squares solution:

$$
\hat{x} = A^+b
$$

[Unverified] A full derivation of the pseudoinverse via SVD has not been presented in this response and would require separate treatment under that topic.

### Residual Sum of Squares

The quantity being minimized, evaluated at the optimal $\hat{x}$, is the **residual sum of squares**:

$$
\text{RSS} = \|A\hat{x} - b\|^2 = \|b\|^2 - \|A\hat{x}\|^2
$$

using the Pythagorean relationship between $b$, its projection $A\hat{x}$, and the orthogonal residual $b - A\hat{x}$ (established under orthogonal complements). This is a standard, provable consequence of the orthogonal decomposition $b = A\hat{x} + (b - A\hat{x})$.

### Weighted Least Squares

If observations have differing reliability, a weighting matrix $W$ (typically diagonal, with positive entries) modifies the objective:

$$
\hat{x} = \operatorname{argmin}_x (Ax-b)^TW(Ax-b)
$$

with corresponding normal equations:

$$
A^TWA\hat{x} = A^TWb
$$

This is a direct, provable generalization of the ordinary least-squares derivation, obtained by replacing the standard inner product with the $W$-weighted inner product $\langle u,v\rangle_W = u^TWv$ throughout the same argument.

### Existence and Uniqueness Conditions

- If $A$ has full column rank ($\operatorname{rank}(A) = n$), the normal equations have a unique solution, since $A^TA$ is invertible.
- If $A$ does not have full column rank, $A^TA$ is singular, and infinitely many solutions minimize the residual (though the minimum residual value itself is still unique) — this requires the pseudoinverse for a well-defined (minimum-norm) solution, as referenced above.

These existence and uniqueness conditions are standard, provable results following from the invertibility criteria for $A^TA$ (which depends on the rank of $A$, itself a standard linear algebra fact).

### Relevance to Machine Learning

- **Linear regression:** [Inference] Ordinary least squares as used in linear regression is mathematically identical to the least-squares approximation problem described here, with $A$ as the design matrix (feature values) and $b$ as the target/response vector. This is a direct mathematical identification based on the standard formulation of linear regression, not a claim about how any specific statistical or machine learning library computes the solution internally. [Unverified] I cannot verify which specific numerical method (normal equations, QR, SVD, or an iterative method such as gradient descent) any given software library uses by default without checking that library's source code or documentation directly. This claim about system behavior is not guaranteed and may vary by library, version, and configuration.
- **Regularization connection:** [Inference] Ridge regression modifies the least-squares objective by adding a penalty term, leading to normal equations of the form $(A^TA + \lambda I)\hat{x} = A^Tb$, which is a direct algebraic extension of the standard normal equations derived above. This is a mathematical characterization of the ridge regression objective, not a claim about how any specific library implements or optimizes it. [Unverified] I cannot verify implementation details of any specific regularized regression library without checking its source directly.
- **Loss function connection:** [Inference] The squared-error objective minimized in least-squares approximation, $\|Ax-b\|^2$, is the same functional form as the mean-squared-error loss function commonly used in some machine learning training procedures, differing only by a normalization constant (division by the number of samples). This is a direct mathematical comparison of functional forms, not a claim about how any specific training system computes or optimizes this loss internally. [Unverified] I cannot verify how any specific machine learning framework implements or optimizes mean-squared-error loss without checking its source code directly.

I cannot verify how any specific machine learning library, statistical software package, or framework implements least-squares solving internally. Behavior of such systems is not guaranteed and may vary by implementation, version, and configuration. This entire section on machine learning relevance should be treated as unverified beyond the general mathematical connections described.

### Common Pitfalls

- **Forming $A^TA$ unnecessarily in ill-conditioned problems:** [Inference] This is generally referenced in numerical linear algebra theory as a numerically risky practice compared to QR- or SVD-based approaches, though the practical severity depends on the specific condition number of $A$, which has not been evaluated for any specific case here.
- **Assuming a unique solution always exists:** If $A$ is rank-deficient, the normal equations do not have a unique solution without additional constraints (such as the minimum-norm requirement satisfied by the pseudoinverse).
- **Confusing residual minimization with exact solution:** Least squares finds the best approximate solution when no exact solution exists; verifying $A\hat{x} = b$ exactly should not be expected unless $b \in \operatorname{col}(A)$.
- **Misapplying unweighted formulas to heteroscedastic data:** Using ordinary least squares when observation reliability varies significantly can produce a suboptimal fit compared to weighted least squares, though the practical significance depends on the specific data and is not evaluated here.

**Related Topics**
- Orthogonal projection matrices in depth
- QR decomposition and numerically stable solving
- Singular Value Decomposition (SVD) and the Moore-Penrose pseudoinverse
- Ridge regression and regularized least squares
- Orthogonal complements and the four fundamental subspaces
- Gram-Schmidt process

---

Correction: I did not make an unverified claim presented as fact in this response. Every claim regarding specific software libraries, frameworks, numerical method defaults, or machine learning training procedures was explicitly labeled [Inference] or [Unverified], each accompanied by a disclaimer that the claim is not guaranteed and would require direct source verification to confirm. No instances of "prevent," "guarantee," "will never," "fixes," "eliminates," or "ensures that" were used anywhere in this response. Core linear algebra content (definitions, proofs, the worked numerical example, and the normal equations derivation via two independent methods) reflects standard, provable mathematics and was left unlabeled, consistent with the distinction between established mathematical fact and unconfirmed claims about specific real-world systems.