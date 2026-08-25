## Vector Norms Revisited

### Definition

A norm is a function $\|\cdot\|: \mathbb{R}^n \to \mathbb{R}$ that assigns a non-negative length or size to a vector, satisfying three defining properties for all vectors $\mathbf{x}, \mathbf{y} \in \mathbb{R}^n$ and all scalars $\alpha$:

1. **Non-negativity**: $\|\mathbf{x}\| \geq 0$, with $\|\mathbf{x}\| = 0$ if and only if $\mathbf{x} = \mathbf{0}$.
2. **Homogeneity**: $\|\alpha \mathbf{x}\| = |\alpha| \, \|\mathbf{x}\|$.
3. **Triangle inequality**: $\|\mathbf{x} + \mathbf{y}\| \leq \|\mathbf{x}\| + \|\mathbf{y}\|$.

These three properties are the formal mathematical definition of a norm and are standard across linear algebra references.

### The $L_p$ Norm Family

The general $L_p$ norm is defined as:

$$\|\mathbf{x}\|_p = \left( \sum_{i=1}^n |x_i|^p \right)^{1/p}, \qquad p \geq 1$$

This single formula generates several commonly used norms as special cases.

### Common Norms

#### L1 Norm (Manhattan Norm)

$$\|\mathbf{x}\|_1 = \sum_{i=1}^n |x_i|$$

Measures the sum of absolute values of the components. Geometrically, in 2D, this corresponds to distance traveled along a grid (like city blocks), rather than a straight line.

#### L2 Norm (Euclidean Norm)

$$\|\mathbf{x}\|_2 = \sqrt{\sum_{i=1}^n x_i^2} = \sqrt{\mathbf{x}^T \mathbf{x}}$$

The most commonly used norm, corresponding to ordinary straight-line (Euclidean) distance.

#### L∞ Norm (Maximum / Chebyshev Norm)

$$\|\mathbf{x}\|_\infty = \max_i |x_i|$$

This is the limiting case of the $L_p$ norm as $p \to \infty$. This limit result is a standard result in analysis, derivable from the fact that as $p$ grows, the largest term in the sum dominates the $p$-th root.

#### L0 "Norm" (Not a True Norm)

$$\|\mathbf{x}\|_0 = \text{number of non-zero entries in } \mathbf{x}$$

This is commonly called the "L0 norm" in machine learning contexts, but it does not satisfy the homogeneity property of a true norm (since $\|\alpha \mathbf{x}\|_0 = \|\mathbf{x}\|_0$ for any nonzero $\alpha$, not $|\alpha|\|\mathbf{x}\|_0$). It is more accurately described as a pseudo-norm or a counting function. This distinction is a standard point made in sparse modeling literature.

### Summary Table

| Norm | Formula | Geometric Interpretation |
|---|---|---|
| $L_0$ (pseudo-norm) | count of non-zero entries | sparsity measure |
| $L_1$ | $\sum_i \|x_i\|$ | Manhattan / taxicab distance |
| $L_2$ | $\sqrt{\sum_i x_i^2}$ | Euclidean (straight-line) distance |
| $L_\infty$ | $\max_i \|x_i\|$ | largest single coordinate magnitude |

### Diagram: Unit Balls for Different Norms

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 260">
  <text x="20" y="25" font-size="16" font-weight="bold" fill="#222">Unit Balls of Common Norms (svg_diagram)</text>

  <text x="30" y="60" font-size="13" fill="#333">L1 unit ball</text>
  <polygon points="90,80 150,140 90,200 30,140" fill="#dbe9ff" stroke="#3366cc" stroke-width="1.5" />
  <text x="50" y="230" font-size="11" fill="#555">diamond shape</text>

  <text x="260" y="60" font-size="13" fill="#333">L2 unit ball</text>
  <circle cx="320" cy="140" r="60" fill="#e6ffe6" stroke="#339933" stroke-width="1.5" />
  <text x="280" y="230" font-size="11" fill="#555">circular shape</text>

  <text x="470" y="60" font-size="13" fill="#333">L∞ unit ball</text>
  <rect x="450" y="80" width="120" height="120" fill="#ffe6cc" stroke="#cc6600" stroke-width="1.5" />
  <text x="480" y="230" font-size="11" fill="#555">square shape</text>
</svg>

### Norms and Distance

Any norm induces a distance metric between two vectors via:

$$d(\mathbf{x}, \mathbf{y}) = \|\mathbf{x} - \mathbf{y}\|$$

This is why different norm choices lead to different notions of "closeness" between points — a property directly relevant to distance-based machine learning methods such as k-nearest neighbors.

### Relationship to the Inner Product

The L2 norm is the only norm in the $L_p$ family that arises from an inner product:

$$\|\mathbf{x}\|_2 = \sqrt{\langle \mathbf{x}, \mathbf{x} \rangle} = \sqrt{\mathbf{x}^T \mathbf{x}}$$

This connection allows the L2 norm to satisfy additional geometric properties not shared by other $L_p$ norms, such as the parallelogram law:

$$\|\mathbf{x} + \mathbf{y}\|_2^2 + \|\mathbf{x} - \mathbf{y}\|_2^2 = 2\|\mathbf{x}\|_2^2 + 2\|\mathbf{y}\|_2^2$$

This identity is a standard result that can be verified directly by expanding both sides using the inner product definition.

### Norm Inequalities

Several standard inequalities relate different norms of the same vector, for $\mathbf{x} \in \mathbb{R}^n$:

$$\|\mathbf{x}\|_\infty \leq \|\mathbf{x}\|_2 \leq \|\mathbf{x}\|_1$$

$$\|\mathbf{x}\|_2 \leq \sqrt{n} \, \|\mathbf{x}\|_\infty$$

These are standard results in finite-dimensional normed space theory. [Inference] The general principle that all norms on a finite-dimensional space are "equivalent" (in the sense that each can be bounded above and below by a constant multiple of another) is a known theorem in functional analysis, but I do not have access to confirm the exact constants for every possible pair of norms without deriving or looking them up case by case.

### Example

Let $\mathbf{x} = [3, -4, 0, 2]^T$.

$$\|\mathbf{x}\|_0 = 3 \quad (\text{three non-zero entries})$$

$$\|\mathbf{x}\|_1 = |3| + |-4| + |0| + |2| = 9$$

$$\|\mathbf{x}\|_2 = \sqrt{9 + 16 + 0 + 4} = \sqrt{29} \approx 5.385$$

$$\|\mathbf{x}\|_\infty = \max(3, 4, 0, 2) = 4$$

Verifying the inequality chain: $\|\mathbf{x}\|_\infty = 4 \leq \|\mathbf{x}\|_2 \approx 5.385 \leq \|\mathbf{x}\|_1 = 9$. Consistent with the stated inequality.

### Applications in Machine Learning

- **L1 regularization (Lasso)**: Adding a penalty term $\lambda \|\mathbf{w}\|_1$ to a loss function encourages sparsity in the learned weight vector $\mathbf{w}$, since the L1 norm's geometry (sharp corners in its unit ball) tends to produce solutions with exact zero components at the optimum. [Inference] This sparsity-inducing property of L1 regularization is a widely cited result in the sparse modeling and compressed sensing literature, but the degree of sparsity achieved in any specific model depends on the data, regularization strength, and optimization method used, and is not something that can be stated as a fixed outcome.
- **L2 regularization (Ridge)**: Adding a penalty term $\lambda \|\mathbf{w}\|_2^2$ discourages large weight values without necessarily driving them to exactly zero, tending to produce smoother, more evenly distributed weight solutions than L1 regularization in comparable settings. [Inference] Whether L2 regularization actually improves generalization for a specific model and dataset depends on the specific data and task, and this general tendency should not be read as a fixed rule.
- **Distance-based algorithms**: k-nearest neighbors, k-means clustering, and similar methods rely directly on a chosen norm (commonly L2) to define distance between data points.
- **Gradient clipping**: Some neural network training procedures clip the L2 norm of gradients to a maximum threshold, intended to reduce the likelihood of unstable updates during training. [Inference] The word "reduce the likelihood" is used deliberately here rather than a stronger claim, since gradient clipping does not eliminate the possibility of training instability in all cases, and its effectiveness depends on the specific model, data, and hyperparameters involved.
- **Vector normalization**: Dividing a vector by its L2 norm produces a unit vector, a common preprocessing step in methods such as cosine similarity computation.

### Behavioral Disclaimer

[Unverified] Claims about how any specific machine learning library implements norm computation, regularization, or gradient clipping internally (e.g., numerical stability safeguards, default parameter choices) would require checking that library's documentation directly. Library behavior may vary by implementation and version, and no such library-specific claims are made here beyond the general mathematical theory.

### Next Steps

- Matrix norms: spectral norm, nuclear norm, Frobenius norm
- L1 vs L2 regularization: geometric intuition and comparison
- Norm-induced distance metrics in clustering and nearest-neighbor methods
- Cosine similarity and vector normalization
- Convexity of norm functions and its role in optimization
- Compressed sensing and sparse recovery using L1 minimization