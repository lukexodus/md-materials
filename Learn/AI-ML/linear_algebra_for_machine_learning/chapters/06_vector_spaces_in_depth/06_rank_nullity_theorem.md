## Rank-Nullity Theorem

### Statement

For a matrix $A \in \mathbb{R}^{m\times n}$, the Rank-Nullity Theorem states:

$$\text{rank}(A) + \text{nullity}(A) = n$$

where $n$ is the number of columns of $A$ (the dimension of the domain), $\text{rank}(A) = \dim(\text{Col}(A))$, and $\text{nullity}(A) = \dim(\text{Null}(A))$. This is a standard, well-established theorem in linear algebra.

### Intuition

Every dimension of the domain $\mathbb{R}^n$ is accounted for in one of two ways under the linear transformation defined by $A$: it either contributes to a direction that gets mapped to something nonzero (captured by the rank), or it gets collapsed to zero (captured by the nullity). Together, these two counts must sum to the full dimension of the domain.

### Diagram: Domain Dimension Split

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480 260" font-family="sans-serif">
  <text x="240" y="22" font-size="14" font-weight="bold" text-anchor="middle" fill="#222">Rank-Nullity Split of the Domain (svg_diagram)</text>

  <ellipse cx="240" cy="150" rx="180" ry="90" fill="#e2e8f0" opacity="0.4" stroke="#333" stroke-width="2" />
  <text x="240" y="55" font-size="12" text-anchor="middle" fill="#333">R^n (Domain), dimension n</text>

  <ellipse cx="170" cy="150" rx="90" ry="70" fill="#a3c9f7" opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
  <text x="170" y="145" font-size="11" text-anchor="middle" fill="#333">Row Space</text>
  <text x="170" y="162" font-size="11" text-anchor="middle" fill="#333">dim = rank(A)</text>

  <ellipse cx="330" cy="150" rx="90" ry="70" fill="#f7c9a3" opacity="0.6" stroke="#c05621" stroke-width="2" />
  <text x="330" y="145" font-size="11" text-anchor="middle" fill="#333">Null Space</text>
  <text x="330" y="162" font-size="11" text-anchor="middle" fill="#333">dim = nullity(A)</text>

  <text x="240" y="230" font-size="12" text-anchor="middle" fill="#333" font-weight="bold">rank(A) + nullity(A) = n</text>
</svg>

### Proof Sketch

This is a standard proof outline found in linear algebra references. Let $\{\mathbf{v}_1, \dots, \mathbf{v}_k\}$ be a basis for $\text{Null}(A)$, where $k = \text{nullity}(A)$. Extend this to a basis of the full domain $\mathbb{R}^n$ by adding vectors $\{\mathbf{v}_{k+1}, \dots, \mathbf{v}_n\}$.

It can be shown that $\{A\mathbf{v}_{k+1}, \dots, A\mathbf{v}_n\}$ forms a basis for $\text{Col}(A)$, since:

- These vectors span $\text{Col}(A)$, because any $A\mathbf{x}$ can be written in terms of the full basis, and the null space basis vectors contribute zero.
- These vectors are linearly independent, because any nontrivial linear combination equal to zero would place a nonzero combination of $\mathbf{v}_{k+1}, \dots, \mathbf{v}_n$ into the null space, contradicting the basis extension being linearly independent from $\{\mathbf{v}_1,\dots,\mathbf{v}_k\}$.

This gives $\dim(\text{Col}(A)) = n - k$, i.e., $\text{rank}(A) = n - \text{nullity}(A)$, which rearranges to the stated theorem.

### Worked Example

$$A = \begin{pmatrix} 1 & 2 & 1 \\ 2 & 4 & 3 \end{pmatrix}$$

From the null space computation shown in an earlier response, row reduction gives:

$$\begin{pmatrix} 1 & 2 & 1 \\ 0 & 0 & 1 \end{pmatrix}$$

Two pivot columns (columns 1 and 3) means $\text{rank}(A) = 2$. The number of columns is $n = 3$.

$$\text{nullity}(A) = n - \text{rank}(A) = 3 - 2 = 1$$

This matches the one-dimensional null space found directly in that example: $\text{Null}(A) = \text{span}\{(-2,1,0)\}$.

### Worked Example: Square Invertible Matrix

$$B = \begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}$$

$\text{rank}(B) = 2$ (both columns are pivot columns), $n = 2$:

$$\text{nullity}(B) = 2 - 2 = 0$$

This matches the trivial null space $\{\mathbf{0}\}$ found earlier, consistent with $B$ being invertible.

### Special Cases

**Full column rank** ($\text{rank}(A) = n$): $\text{nullity}(A) = 0$, meaning $\text{Null}(A) = \{\mathbf{0}\}$, and the columns of $A$ are linearly independent.

**Rank-deficient** ($\text{rank}(A) < n$): $\text{nullity}(A) > 0$, meaning $\text{Null}(A)$ is nontrivial, and the columns of $A$ are linearly dependent.

**Square invertible matrix** ($m = n$, $\text{rank}(A) = n$): $\text{nullity}(A) = 0$, consistent with the standard determinant-invertibility relationship covered earlier ($\det(A) \neq 0 \iff \text{Null}(A) = \{\mathbf{0}\}$).

### Relationship to Injectivity and Surjectivity

For the linear transformation $T(\mathbf{x}) = A\mathbf{x}$ with $A \in \mathbb{R}^{m\times n}$, the Rank-Nullity Theorem connects directly to these standard, well-established properties:

- $T$ is **injective** (one-to-one) $\iff \text{nullity}(A) = 0 \iff \text{rank}(A) = n$
- $T$ is **surjective** (onto $\mathbb{R}^m$) $\iff \text{rank}(A) = m$
- $T$ is **bijective** $\iff \text{rank}(A) = m = n$, which requires $A$ to be square and invertible

If $n > m$ (more columns than rows), $\text{rank}(A) \leq m < n$ necessarily, so $\text{nullity}(A) \geq n - m > 0$ — the transformation cannot be injective. This is a direct consequence of the theorem, not an independent claim.

### Common Confusion: Which Dimension Is Used

The Rank-Nullity Theorem uses $n$ (number of columns / domain dimension), not $m$ (number of rows / codomain dimension). A frequent error is to write $\text{rank}(A) + \text{nullity}(A) = m$, which is incorrect in general — this equality only coincidentally holds when $A$ is square ($m = n$).

### Relevance to Machine Learning

- **Feature redundancy diagnosis**: In a design matrix $X \in \mathbb{R}^{m\times n}$ (samples × features), if $\text{rank}(X) < n$, the Rank-Nullity Theorem confirms a nontrivial null space exists, meaning some linear combinations of features are redundant and certain regression coefficient directions are not uniquely determined. [Inference] This follows directly from applying the theorem to a standard design matrix, but I do not have a specific primary source confirmed in this conversation for this exact framing.
- **Overparameterized models**: When a neural network layer or linear model has more parameters than independent constraints from the data, the Rank-Nullity Theorem provides a way to count the dimension of the space of solutions that fit the data equally well. [Inference] This is a reasoned extension of the theorem to overparameterized settings; I do not have a specific primary source confirmed in this conversation for this precise claim, and I cannot verify that this framing is used with this exact terminology in mainstream ML literature.
- **PCA and dimensionality reduction**: The rank of a data or covariance matrix, as governed by the Rank-Nullity relationship, determines the effective number of informative directions available for dimensionality reduction. [Inference] This is a reasoned connection based on the standard definitions of rank and nullity; I do not have a specific primary source confirmed in this conversation describing this connection in these exact terms.

I cannot verify the internal implementation details of how any specific machine learning library computes rank or nullity numerically (e.g., via SVD-based rank estimation with numerical tolerances), and any such behavior may vary by implementation, version, and numerical precision. This is not guaranteed to be consistent across systems. [Unverified]

### Common Pitfalls

- Confusing $n$ (columns) with $m$ (rows) in the formula — the theorem always sums to the number of columns, not rows.
- Assuming rank alone determines injectivity or surjectivity without checking it against both $m$ and $n$ — injectivity requires $\text{rank}(A) = n$, surjectivity requires $\text{rank}(A) = m$, and these are generally different conditions unless $A$ is square.
- Applying the theorem to non-linear transformations — the Rank-Nullity Theorem is specific to linear transformations and matrices; it does not directly apply to nonlinear maps without linearization (e.g., via a Jacobian).

**Related Topics**
- Column space and range
- Null space and kernel
- Row space and the four fundamental subspaces
- Injective, surjective, and bijective linear transformations
- Determinant and invertibility relationship
- Singular Value Decomposition (SVD) and numerical rank estimation