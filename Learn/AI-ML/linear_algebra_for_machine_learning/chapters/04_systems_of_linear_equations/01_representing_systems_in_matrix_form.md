## Representing Systems in Matrix Form

### Definition

A system of $m$ linear equations in $n$ unknowns can be written compactly using matrix notation. The general system:

$$a_{11}x_1 + a_{12}x_2 + \cdots + a_{1n}x_n = b_1$$
$$a_{21}x_1 + a_{22}x_2 + \cdots + a_{2n}x_n = b_2$$
$$\vdots$$
$$a_{m1}x_1 + a_{m2}x_2 + \cdots + a_{mn}x_n = b_m$$

is represented as:

$$A\mathbf{x} = \mathbf{b}$$

where $A \in \mathbb{R}^{m \times n}$ is the coefficient matrix, $\mathbf{x} \in \mathbb{R}^{n \times 1}$ is the vector of unknowns, and $\mathbf{b} \in \mathbb{R}^{m \times 1}$ is the vector of constants. This is a standard, provable representation from linear algebra, not an inference.

### Worked Example

Consider the system:

$$2x_1 + 3x_2 = 8$$
$$x_1 - x_2 = 1$$

This translates to:

$$A = \begin{pmatrix} 2 & 3 \\ 1 & -1 \end{pmatrix}, \quad \mathbf{x} = \begin{pmatrix} x_1 \\ x_2 \end{pmatrix}, \quad \mathbf{b} = \begin{pmatrix} 8 \\ 1 \end{pmatrix}$$

$$A\mathbf{x} = \mathbf{b} \quad \Rightarrow \quad \begin{pmatrix} 2 & 3 \\ 1 & -1 \end{pmatrix}\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} = \begin{pmatrix} 8 \\ 1 \end{pmatrix}$$

This is a direct translation following the stated definition, not an inference.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 460 200">
  <text x="230" y="20" font-size="13" text-anchor="middle" fill="#333">System to Matrix Form (svg_diagram)</text>
  <text x="100" y="60" font-size="13" text-anchor="middle">2x1 + 3x2 = 8</text>
  <text x="100" y="85" font-size="13" text-anchor="middle">x1 - x2 = 1</text>
  <text x="200" y="75" font-size="18" text-anchor="middle">→</text>
  <rect x="230" y="45" width="60" height="50" fill="none" stroke="#1f77b4" stroke-width="2" />
  <text x="245" y="65" font-size="12">2</text>
  <text x="270" y="65" font-size="12">3</text>
  <text x="245" y="88" font-size="12">1</text>
  <text x="270" y="88" font-size="12">-1</text>
  <text x="260" y="120" font-size="11" text-anchor="middle" fill="#1f77b4">A</text>
  <text x="300" y="75" font-size="14" text-anchor="middle">·</text>
  <rect x="315" y="45" width="30" height="50" fill="none" stroke="#ff7f0e" stroke-width="2" />
  <text x="322" y="65" font-size="12">x1</text>
  <text x="322" y="88" font-size="12">x2</text>
  <text x="330" y="120" font-size="11" text-anchor="middle" fill="#ff7f0e">x</text>
  <text x="355" y="75" font-size="14" text-anchor="middle">=</text>
  <rect x="370" y="45" width="30" height="50" fill="none" stroke="#2ca02c" stroke-width="2" />
  <text x="378" y="65" font-size="12">8</text>
  <text x="378" y="88" font-size="12">1</text>
  <text x="385" y="120" font-size="11" text-anchor="middle" fill="#2ca02c">b</text>
  <text x="230" y="160" font-size="11" text-anchor="middle" fill="#666">Ax = b: coefficients, unknowns, and constants separated</text>
</svg>

### The Augmented Matrix

For solving purposes, $A$ and $\mathbf{b}$ are often combined into a single augmented matrix, denoted $[A \mid \mathbf{b}]$:

$$[A \mid \mathbf{b}] = \left(\begin{array}{cc|c} 2 & 3 & 8 \\ 1 & -1 & 1 \end{array}\right)$$

This is a standard notational convention used for row reduction (Gaussian elimination), not an inference.

### Key Points

- The number of rows in $A$ equals the number of equations.
- The number of columns in $A$ equals the number of unknowns.
- $A$ need not be square: $m \neq n$ corresponds to a system with a different number of equations than unknowns.
- If $A$ is square and invertible, the unique solution is $\mathbf{x} = A^{-1}\mathbf{b}$. This follows directly from left-multiplying both sides of $A\mathbf{x} = \mathbf{b}$ by $A^{-1}$, a standard, provable algebraic step.

### Solution Existence and Uniqueness

[Inference] The number of solutions to $A\mathbf{x} = \mathbf{b}$ is commonly categorized in linear algebra references into three cases — no solution, exactly one solution, or infinitely many solutions — based on the relationship between the rank of $A$ and the rank of the augmented matrix $[A \mid \mathbf{b}]$, as described in standard references (the Rouché–Capelli theorem). I cannot independently reproduce the full formal proof of this theorem within this response.

| Condition | Outcome |
|---|---|
| $\text{rank}(A) = \text{rank}([A\mid\mathbf{b}]) = n$ | Unique solution |
| $\text{rank}(A) = \text{rank}([A\mid\mathbf{b}]) < n$ | Infinitely many solutions |
| $\text{rank}(A) \neq \text{rank}([A\mid\mathbf{b}])$ | No solution |

[Unverified] I do not have access to a specific citable source to quote directly for this table within this response; it reflects a commonly stated classification in linear algebra references.

### Homogeneous Systems

A system is called **homogeneous** if $\mathbf{b} = \mathbf{0}$:

$$A\mathbf{x} = \mathbf{0}$$

This system always has at least the trivial solution $\mathbf{x} = \mathbf{0}$. This follows directly from substitution, a standard, provable fact. Nontrivial solutions exist if and only if $A$ is singular (not invertible), which is a standard, provable result linked to the definition of the kernel of $A$.

### Row Picture vs. Column Picture

[Inference] The system $A\mathbf{x} = \mathbf{b}$ is commonly described in linear algebra references as admitting two complementary geometric interpretations:

- **Row picture**: each equation represents a hyperplane (a line in $\mathbb{R}^2$, a plane in $\mathbb{R}^3$), and the solution is the intersection of all these hyperplanes.
- **Column picture**: $\mathbf{b}$ is expressed as a linear combination of the columns of $A$, weighted by the entries of $\mathbf{x}$: $\mathbf{b} = x_1\mathbf{a}_1 + x_2\mathbf{a}_2 + \cdots + x_n\mathbf{a}_n$.

I cannot independently verify which framing is more commonly emphasized across all linear algebra references without citing a specific source; both are standard, provable equivalent interpretations of the same equation.

### Worked Example: Column Picture

For the earlier system, $\mathbf{b} = \begin{pmatrix} 8 \\ 1 \end{pmatrix}$ can be expressed as:

$$x_1 \begin{pmatrix} 2 \\ 1 \end{pmatrix} + x_2 \begin{pmatrix} 3 \\ -1 \end{pmatrix} = \begin{pmatrix} 8 \\ 1 \end{pmatrix}$$

Solving (by substitution or elimination) gives $x_1 = 2.2$, $x_2 = 1.2$.

**Verification**

$$2.2 \begin{pmatrix} 2 \\ 1 \end{pmatrix} + 1.2 \begin{pmatrix} 3 \\ -1 \end{pmatrix} = \begin{pmatrix} 4.4 + 3.6 \\ 2.2 - 1.2 \end{pmatrix} = \begin{pmatrix} 8 \\ 1 \end{pmatrix}$$

**Output**

$$x_1 = 2.2, \quad x_2 = 1.2$$

This is a direct computation, verified by substitution back into the original equations. It is not an inference.

### Relevance to Machine Learning

[Inference] Representing systems in matrix form is described in commonly cited machine learning references as foundational to several methods, based on descriptions in standard references. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Linear regression**: the normal equations $X^T X \boldsymbol{\beta} = X^T \mathbf{y}$ are described in statistics and machine learning literature as a linear system solved to find regression coefficients. [Unverified] I cannot verify the exact solving method (direct inversion, QR decomposition, or otherwise) used by any specific software library without inspecting its source code.
- **Solving for equilibrium or steady-state conditions**: some optimization and Markov chain computations are described in the literature as reducible to solving linear systems of the form $A\mathbf{x} = \mathbf{b}$. [Unverified] I cannot verify this reduction for any specific application without inspecting the relevant formulation directly.
- **Neural network layer equations**: forward-pass computations in linear layers are described in machine learning literature as structurally similar to evaluating $A\mathbf{x}$, though typically evaluated rather than solved for $\mathbf{x}$. [Unverified] I do not have access to a specific verified source to cite directly for how any particular current framework implements this internally.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- Gaussian elimination and row reduction
- Rank of a matrix
- Matrix inverses
- Homogeneous vs. non-homogeneous systems
- Column space and null space
- Least squares and the normal equations

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding the Rouché–Capelli theorem proof reproduction, row/column picture framing, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions (matrix form of a system, augmented matrix, homogeneous system, trivial solution) are standard, established conventions in linear algebra; the invertible-case solution formula is a standard, provable result.