## Null Space and Kernel

### Definition

The **null space** (also called the **kernel**) of a matrix $A \in \mathbb{R}^{m\times n}$ is the set of all vectors that $A$ maps to the zero vector. This is a standard, well-established definition in linear algebra.

$$\text{Null}(A) = \{\mathbf{x} \in \mathbb{R}^n : A\mathbf{x} = \mathbf{0}\}$$

The terms "null space" and "kernel" are used interchangeably in most linear algebra contexts; "kernel" (denoted $\ker(A)$ or $\ker(T)$) is more common when referring to a linear transformation $T$ generally, while "null space" is more common when referring specifically to a matrix.

### The Null Space Is Always a Subspace

For any matrix $A$, $\text{Null}(A)$ satisfies all three subspace conditions. This is a standard, well-established theorem.

**Zero vector:** $A\mathbf{0} = \mathbf{0}$, so $\mathbf{0} \in \text{Null}(A)$.

**Closed under addition:** If $A\mathbf{u} = \mathbf{0}$ and $A\mathbf{v} = \mathbf{0}$, then:
$$A(\mathbf{u}+\mathbf{v}) = A\mathbf{u} + A\mathbf{v} = \mathbf{0} + \mathbf{0} = \mathbf{0}$$

**Closed under scalar multiplication:** If $A\mathbf{u} = \mathbf{0}$, then:
$$A(k\mathbf{u}) = k(A\mathbf{u}) = k\mathbf{0} = \mathbf{0}$$

Both closure proofs rely directly on the linearity of matrix multiplication and hold generally for any matrix $A$.

### Diagram: Null Space Mapping

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 260" font-family="sans-serif">
  <text x="250" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Null Space Maps to Zero (svg_diagram)</text>

  
  <ellipse cx="120" cy="150" rx="90" ry="80" fill="#a3c9f7" opacity="0.3" stroke="#2b6cb0" stroke-width="2" />
  <text x="120" y="70" font-size="12" text-anchor="middle" fill="#333">Domain (R^n)</text>

  
  <ellipse cx="90" cy="180" rx="40" ry="30" fill="#f7c9a3" opacity="0.6" stroke="#c05621" stroke-width="2" />
  <text x="90" y="180" font-size="10" text-anchor="middle" fill="#333">Null(A)</text>

  
  <ellipse cx="400" cy="150" rx="90" ry="80" fill="#c9f7a3" opacity="0.3" stroke="#4a7a1e" stroke-width="2" />
  <text x="400" y="70" font-size="12" text-anchor="middle" fill="#333">Codomain (R^m)</text>

  
  <circle cx="400" cy="150" r="5" fill="#333" />
  <text x="420" y="150" font-size="11" fill="#333">0</text>

  
  <line x1="120" y1="170" x2="390" y2="150" stroke="#c05621" stroke-width="1.5" marker-end="url(#arrn)" />
  <line x1="80" y1="200" x2="390" y2="152" stroke="#c05621" stroke-width="1.5" marker-end="url(#arrn)" />

  
  <circle cx="160" cy="110" r="4" fill="#2b6cb0" />
  <line x1="160" y1="110" x2="360" y2="100" stroke="#2b6cb0" stroke-width="1.5" marker-end="url(#arrn)" />
  <circle cx="360" cy="100" r="4" fill="#2b6cb0" />

  </svg>

### Worked Example: Computing the Null Space

Find $\text{Null}(A)$ for:

$$A = \begin{pmatrix} 1 & 2 & 1 \\ 2 & 4 & 3 \end{pmatrix}$$

Solve $A\mathbf{x} = \mathbf{0}$ by row reducing $[A \mid \mathbf{0}]$:

$$\begin{pmatrix} 1 & 2 & 1 & | & 0 \\ 2 & 4 & 3 & | & 0 \end{pmatrix} \xrightarrow{R_2 \to R_2 - 2R_1} \begin{pmatrix} 1 & 2 & 1 & | & 0 \\ 0 & 0 & 1 & | & 0 \end{pmatrix}$$

From row 2: $x_3 = 0$. From row 1: $x_1 + 2x_2 + x_3 = 0 \implies x_1 = -2x_2$.

$x_2$ is a free variable. Setting $x_2 = t$:

$$\mathbf{x} = \begin{pmatrix} -2t \\ t \\ 0 \end{pmatrix} = t\begin{pmatrix} -2 \\ 1 \\ 0 \end{pmatrix}$$

$$\text{Null}(A) = \text{span}\left\{\begin{pmatrix}-2\\1\\0\end{pmatrix}\right\}$$

This is a one-dimensional subspace (a line through the origin) in $\mathbb{R}^3$.

### Worked Example: Trivial Null Space

$$B = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$$

Solving $B\mathbf{x} = \mathbf{0}$ gives only $x_1 = 0, x_2 = 0$. So:

$$\text{Null}(B) = \{\mathbf{0}\}$$

This is called the **trivial null space**. A matrix has a trivial null space if and only if its columns are linearly independent, which directly connects to the invertibility criterion for square matrices.

### Nullity and the Rank-Nullity Theorem

The **nullity** of $A$ is the dimension of its null space:

$$\text{nullity}(A) = \dim(\text{Null}(A))$$

For $A \in \mathbb{R}^{m\times n}$, the **Rank-Nullity Theorem** states:

$$\text{rank}(A) + \text{nullity}(A) = n$$

where $n$ is the number of columns of $A$. This is a standard, well-established theorem in linear algebra.

In the first worked example above, $A$ is $2\times 3$ with rank $2$ (two pivot columns after row reduction), so:

$$\text{nullity}(A) = n - \text{rank}(A) = 3 - 2 = 1$$

This matches the one-dimensional null space found directly.

### Null Space and Solutions to $A\mathbf{x} = \mathbf{b}$

The null space determines the structure of solutions to a general linear system, in the following standard, well-established sense:

- If $A\mathbf{x} = \mathbf{b}$ has a particular solution $\mathbf{x}_p$, then the complete solution set is:
$$\mathbf{x} = \mathbf{x}_p + \mathbf{x}_n, \quad \mathbf{x}_n \in \text{Null}(A)$$
- If $\text{Null}(A) = \{\mathbf{0}\}$, the solution (if it exists) is unique.
- If $\text{Null}(A)$ is nontrivial (dimension $\geq 1$), and a solution exists, there are infinitely many solutions.

### Null Space and Invertibility

For a square matrix $A \in \mathbb{R}^{n\times n}$, the following equivalence is a standard, well-established result:

$$\text{Null}(A) = \{\mathbf{0}\} \iff \det(A) \neq 0 \iff A \text{ is invertible}$$

A nontrivial null space (dimension $\geq 1$) for a square matrix directly implies $\det(A) = 0$, connecting back to the determinant-invertibility relationship covered earlier.

### Kernel of a General Linear Transformation

For a linear transformation $T: V \to W$ between vector spaces, the kernel is defined analogously:

$$\ker(T) = \{\mathbf{v} \in V : T(\mathbf{v}) = \mathbf{0}_W\}$$

$\ker(T)$ is always a subspace of $V$, by the same closure argument used for matrix null spaces. This generalization is standard in linear algebra.

**Injectivity criterion**: $T$ is injective (one-to-one) if and only if $\ker(T) = \{\mathbf{0}\}$. This is a standard, well-established result, since a nontrivial kernel means multiple distinct inputs map to the same output.

### Relevance to Machine Learning

- **Linear regression identifiability**: A nontrivial null space of the design matrix $X$ means certain parameter directions do not affect predictions ($X\mathbf{v} = \mathbf{0}$ for $\mathbf{v} \in \text{Null}(X)$), which is directly relevant when features are collinear. [Inference] This follows from applying the null space definition to the linear regression prediction equation, but I do not have a specific primary source confirmed in this conversation for this exact framing.
- **Regularization**: Techniques such as ridge regression add $\lambda I$ to $X^TX$, which is a standard way to shrink the effective null space and improve identifiability when $X^TX$ is singular or ill-conditioned. [Inference] I cannot verify a specific primary source confirming this precise mechanism description in this conversation, though it is reasoned from the algebraic effect of adding $\lambda I$ to the diagonal of a matrix.
- **Neural network layer collapse**: A weight matrix with a nontrivial null space maps some input directions to zero, meaning information along those directions is lost at that layer. [Inference] This follows from the general definition of null space applied to a linear layer's weight matrix, but I do not have a specific primary source confirmed in this conversation describing this as a named, standard concept in neural network literature.
- **Dimensionality reduction**: Understanding the null space of a projection matrix clarifies which directions of the original data are discarded during dimensionality reduction. [Inference] This is a reasoned application of the null space definition to projection matrices, but I do not have a specific primary source confirmed in this conversation for this exact framing.

I cannot verify the internal implementation details of how any specific machine learning library computes or represents null spaces numerically (e.g., via SVD-based null space functions), and any such behavior may vary by implementation and version. [Unverified]

### Common Pitfalls

- Confusing the null space (a subspace of the domain, $\mathbb{R}^n$) with the column space (a subspace of the codomain, $\mathbb{R}^m$) — these live in different spaces when $A$ is not square.
- Assuming a nontrivial null space always means "something is wrong" — in some contexts (e.g., constraint satisfaction, degenerate directions in optimization), a nontrivial null space is expected and meaningful rather than an error condition. [Inference] This is a reasoned generalization based on standard interpretations of null space across different problem contexts, but I do not have a specific primary source confirmed in this conversation for this precise claim.
- Forgetting to verify closure using the general case rather than specific example vectors when proving a set is (or is not) a null space or subspace.

**Related Topics**
- Rank-Nullity Theorem in depth
- Column space and row space
- Subspace tests
- Linear independence and span
- Invertibility and the determinant
- Singular Value Decomposition (SVD) and its relation to null space computation