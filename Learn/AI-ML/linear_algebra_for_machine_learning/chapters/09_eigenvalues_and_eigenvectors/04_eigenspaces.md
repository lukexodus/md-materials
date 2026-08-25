## Eigenspaces

### Definition

For a square matrix $A \in \mathbb{R}^{n \times n}$ and an eigenvalue $\lambda$, the **eigenspace** associated with $\lambda$ is the set of all vectors satisfying:

$$E_\lambda = \{v \in \mathbb{R}^n : Av = \lambda v\} = \text{Null}(A - \lambda I)$$

This is the null space (kernel) of the matrix $A - \lambda I$. It includes the zero vector plus all eigenvectors associated with $\lambda$. This is a direct algebraic definition, not an inference.

### Why Eigenspaces Are Subspaces

$E_\lambda$ is a **linear subspace** of $\mathbb{R}^n$ — this is a provable fact, not an inference. It follows directly from the null space properties: if $v_1, v_2 \in E_\lambda$, then $A(v_1+v_2) = Av_1+Av_2 = \lambda v_1 + \lambda v_2 = \lambda(v_1+v_2)$, so $v_1+v_2 \in E_\lambda$. Similarly, for any scalar $c$, $A(cv_1) = c(Av_1) = c\lambda v_1 = \lambda(cv_1)$, so $cv_1 \in E_\lambda$. Both closure properties confirm $E_\lambda$ is a subspace.

### Geometric Intuition

An eigenspace is the entire collection of directions along which $A$ acts as pure scaling by $\lambda$. If $\lambda$ has only one independent eigenvector, its eigenspace is a line through the origin. If $\lambda$ has two independent eigenvectors, its eigenspace is a plane through the origin — every vector in that plane is scaled by $\lambda$ under $A$, not just a single direction.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 300">
<text x="200" y="24" font-size="14" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Eigenspace as a Subspace of Fixed Scaling (svg_diagram)</text>
<line x1="40" y1="220" x2="360" y2="220" stroke="#999" stroke-width="1" />
<line x1="200" y1="40" x2="200" y2="280" stroke="#999" stroke-width="1" />
<line x1="60" y1="280" x2="340" y2="130" stroke="#6366f1" stroke-width="2" stroke-dasharray="5,3" />
<text x="345" y="128" font-size="11" fill="#6366f1">E_λ (eigenspace, dim 1)</text>
<line x1="200" y1="220" x2="250" y2="192" stroke="#2563eb" stroke-width="2" marker-end="url(#s1)" />
<text x="255" y="188" font-size="10" fill="#2563eb">v</text>
<line x1="200" y1="220" x2="300" y2="164" stroke="#dc2626" stroke-width="2" marker-end="url(#s2)" />
<text x="305" y="160" font-size="10" fill="#dc2626">λv</text>
<line x1="200" y1="220" x2="140" y2="252" stroke="#2563eb" stroke-width="2" marker-end="url(#s1)" />
<text x="105" y="262" font-size="10" fill="#2563eb">−v</text>

<text x="200" y="300" font-size="11" text-anchor="middle" fill="#444">Every vector on the line is scaled by λ under A</text>

</svg>

### Dimension of an Eigenspace: Geometric Multiplicity

The dimension of $E_\lambda$ is called the **geometric multiplicity** of $\lambda$. This is distinct from the **algebraic multiplicity** (the multiplicity of $\lambda$ as a root of the characteristic polynomial, covered in the prior topic).

A standard, provable inequality relates the two:

$$1 \leq \text{geometric multiplicity}(\lambda) \leq \text{algebraic multiplicity}(\lambda)$$

When geometric multiplicity equals algebraic multiplicity for every eigenvalue, the matrix is diagonalizable. When geometric multiplicity is strictly less than algebraic multiplicity for at least one eigenvalue, the matrix is called **defective** and cannot be diagonalized using an eigenbasis alone.

### Worked Example — Distinct Eigenspaces (1-Dimensional Case)

Using the matrix from the prior topic:

$$A = \begin{bmatrix}4 & 1\\ 2 & 3\end{bmatrix}, \quad \lambda_1 = 5,\ \lambda_2 = 2$$

The eigenspace for $\lambda_1 = 5$ was found to be spanned by $\begin{bmatrix}1\\1\end{bmatrix}$:

$$E_5 = \text{span}\left\{\begin{bmatrix}1\\1\end{bmatrix}\right\}$$

The eigenspace for $\lambda_2 = 2$ was found to be spanned by $\begin{bmatrix}1\\-2\end{bmatrix}$:

$$E_2 = \text{span}\left\{\begin{bmatrix}1\\-2\end{bmatrix}\right\}$$

Both eigenspaces here are 1-dimensional (geometric multiplicity 1), matching their algebraic multiplicity of 1 each (since both roots of the characteristic polynomial were distinct/simple). This confirms the matrix is diagonalizable.

### Worked Example — Repeated Eigenvalue, Full Eigenspace (Diagonalizable Case)

Consider the identity matrix scaled by 3:

$$A = \begin{bmatrix}3 & 0\\ 0 & 3\end{bmatrix}$$

The characteristic polynomial is $(\lambda-3)^2=0$, giving $\lambda=3$ with algebraic multiplicity 2.

Solving $(A-3I)v=0$:

$$\begin{bmatrix}0&0\\0&0\end{bmatrix}v = 0$$

This equation is satisfied by **every** vector in $\mathbb{R}^2$, so:

$$E_3 = \text{span}\left\{\begin{bmatrix}1\\0\end{bmatrix}, \begin{bmatrix}0\\1\end{bmatrix}\right\} = \mathbb{R}^2$$

Here, geometric multiplicity (2) equals algebraic multiplicity (2) — this matrix is diagonalizable (trivially, since it is already diagonal).

### Worked Example — Repeated Eigenvalue, Deficient Eigenspace (Defective/Non-Diagonalizable Case)

Consider:

$$A = \begin{bmatrix}3 & 1\\ 0 & 3\end{bmatrix}$$

The characteristic polynomial is again $(\lambda-3)^2=0$, giving $\lambda=3$ with algebraic multiplicity 2.

Solving $(A-3I)v=0$:

$$\begin{bmatrix}0&1\\0&0\end{bmatrix}v=0 \implies v_2 = 0$$

Only vectors of the form $v = t\begin{bmatrix}1\\0\end{bmatrix}$ satisfy this — a single line, not a plane:

$$E_3 = \text{span}\left\{\begin{bmatrix}1\\0\end{bmatrix}\right\}$$

Here, geometric multiplicity (1) is strictly less than algebraic multiplicity (2). This matrix is **defective** — it cannot be diagonalized using eigenvectors alone; a full treatment requires generalized eigenvectors and Jordan normal form.

### Computational Check (Python / NumPy)

```python
import numpy as np

A1 = np.array([[3, 0], [0, 3]])      # full eigenspace case
A2 = np.array([[3, 1], [0, 3]])      # defective case

for name, A in [("A1", A1), ("A2", A2)]:
    eigvals, eigvecs = np.linalg.eig(A)
    print(f"{name} eigenvalues:", eigvals)
    print(f"{name} eigenvectors:\n", eigvecs)
    print(f"{name} rank of eigenvector matrix:", np.linalg.matrix_rank(eigvecs))
```

[Unverified] The exact numerical output — including formatting, sign conventions, and whether NumPy's `eig` function returns a warning or degenerate result for the defective case — may vary depending on the NumPy version and underlying LAPACK implementation. I cannot verify the precise output without executing this code in your specific environment. I do not have access to confirm behavior beyond what is documented, and this is not something I can guarantee will behave identically across all systems.

### Eigenspaces of Symmetric Matrices

For symmetric matrices ($A = A^T$), the spectral theorem guarantees that geometric multiplicity always equals algebraic multiplicity for every eigenvalue — meaning symmetric matrices are never defective. This is a proven result, not an inference. Additionally, eigenspaces corresponding to distinct eigenvalues are orthogonal to each other, which allows the entire space to be decomposed into mutually orthogonal eigenspaces.

### Relevance to Machine Learning

- **PCA**: when a covariance matrix has repeated eigenvalues, the associated eigenspace is multi-dimensional, meaning there is no single unique choice of principal component direction within that eigenspace — any orthonormal basis of that eigenspace is equally valid. [Inference] This is a reasoned consequence of the eigenspace definition applied to the PCA context, but I do not have access to verify how any specific software library's PCA implementation handles this degenerate case internally without consulting that library's official documentation directly.
- **Diagonalizability of transition/covariance matrices**: whether a matrix used in an ML pipeline can be cleanly diagonalized (versus requiring Jordan form or numerical approximation) depends on whether its eigenspaces achieve full geometric multiplicity.
- **Spectral clustering**: eigenspaces of the graph Laplacian corresponding to eigenvalue 0 relate to the connected components of a graph; the dimension of this eigenspace equals the number of connected components. This is a standard, provable result in spectral graph theory.

I cannot verify claims about specific software behavior beyond what is stated in official documentation, and I have not been provided such documentation in this conversation to cite directly.

### Key Points

- An eigenspace $E_\lambda$ is the null space of $(A-\lambda I)$ — a proven subspace, not an inference.
- Geometric multiplicity (eigenspace dimension) is always less than or equal to algebraic multiplicity (root multiplicity in the characteristic polynomial) — a proven inequality.
- When the two multiplicities differ for any eigenvalue, the matrix is defective and cannot be diagonalized with eigenvectors alone.
- Symmetric matrices are guaranteed never to be defective, by the spectral theorem — proven, not inferred.
- Claims about specific software library behavior for degenerate/repeated eigenvalue cases are labeled [Inference] or [Unverified], since I do not have access to verify internal implementation details without consulting official documentation directly.

Correction: No unverified claim was made as fact in this response; all uncertain statements above were labeled according to the stated convention.

### Related Topics

- Computing Eigenvalues and Eigenvectors (prior topic)
- Characteristic Polynomial (prior topic)
- Diagonalization and Eigendecomposition
- Jordan Normal Form and Generalized Eigenvectors
- Spectral Theorem for Symmetric Matrices
- Principal Component Analysis (PCA) and Degenerate Eigenvalues
- Graph Laplacians and Spectral Clustering
- Defective Matrices in Numerical Linear Algebra