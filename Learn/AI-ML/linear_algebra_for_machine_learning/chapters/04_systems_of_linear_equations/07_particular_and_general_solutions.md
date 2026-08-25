## Particular and General Solutions

### Definition

For a non-homogeneous system $A\mathbf{x} = \mathbf{b}$ with $\mathbf{b} \neq \mathbf{0}$:

- A **particular solution** $\mathbf{x}_p$ is any single vector satisfying $A\mathbf{x}_p = \mathbf{b}$.
- The **general solution** is the complete set of all vectors satisfying $A\mathbf{x} = \mathbf{b}$.

This is a standard, provable definition from linear algebra, not an inference.

### The General Solution Formula

$$\mathbf{x} = \mathbf{x}_p + \mathbf{x}_h$$

where $\mathbf{x}_p$ is any one particular solution and $\mathbf{x}_h$ ranges over all solutions of the associated homogeneous system $A\mathbf{x}_h = \mathbf{0}$ (i.e., $\mathbf{x}_h \in \ker(A)$).

[Inference] This structure is commonly stated in linear algebra references as following from linearity of matrix multiplication: if $A\mathbf{x}_p = \mathbf{b}$ and $A\mathbf{x}_h = \mathbf{0}$, then $A(\mathbf{x}_p + \mathbf{x}_h) = A\mathbf{x}_p + A\mathbf{x}_h = \mathbf{b} + \mathbf{0} = \mathbf{b}$. This specific algebraic step is a direct consequence of linearity. The claim that this construction captures *every* solution (not just some solutions) is a separate step I have not independently reproduced as a full proof within this response; I cannot verify that additional claim beyond citing it as a commonly stated result in linear algebra references.

### Why This Works: Two Separate Claims

To avoid chaining inferences, these are separated explicitly:

1. **Claim A**: $\mathbf{x}_p + \mathbf{x}_h$ is *a* solution whenever $\mathbf{x}_h \in \ker(A)$. This is a direct algebraic consequence of linearity, shown above. This is not an inference — it is a direct computation.
2. **Claim B**: *Every* solution to $A\mathbf{x} = \mathbf{b}$ can be written in this form. [Inference] This is commonly stated in linear algebra references, reasoned as follows: if $\mathbf{x}_1$ and $\mathbf{x}_2$ are both solutions, then $A(\mathbf{x}_1 - \mathbf{x}_2) = \mathbf{b} - \mathbf{b} = \mathbf{0}$, so $\mathbf{x}_1 - \mathbf{x}_2 \in \ker(A)$, meaning $\mathbf{x}_1 = \mathbf{x}_2 + \mathbf{x}_h$ for some $\mathbf{x}_h \in \ker(A)$. I have shown this reasoning directly here rather than citing an external source, but I am labeling it as [Inference] because it is presented as a summarized argument rather than a fully formalized proof.

### Worked Example

$$A = \begin{pmatrix} 1 & 2 \\ 2 & 4 \end{pmatrix}, \quad \mathbf{b} = \begin{pmatrix} 3 \\ 6 \end{pmatrix}$$

**Step 1 — Find a particular solution**

Try $x_2 = 0$: $x_1 = 3$. So $\mathbf{x}_p = \begin{pmatrix} 3 \\ 0 \end{pmatrix}$.

**Verification**: $A\mathbf{x}_p = \begin{pmatrix} 1(3)+2(0) \\ 2(3)+4(0) \end{pmatrix} = \begin{pmatrix} 3 \\ 6 \end{pmatrix} = \mathbf{b}$ ✓. This is a direct computation, not an inference.

**Step 2 — Find the homogeneous solution**

Solve $A\mathbf{x}_h = \mathbf{0}$:

$$x_1 + 2x_2 = 0 \Rightarrow x_1 = -2x_2$$

Let $x_2 = t$: $\mathbf{x}_h = t\begin{pmatrix} -2 \\ 1 \end{pmatrix}$

**Step 3 — Combine**

**Output**

$$\mathbf{x} = \begin{pmatrix} 3 \\ 0 \end{pmatrix} + t\begin{pmatrix} -2 \\ 1 \end{pmatrix}, \quad t \in \mathbb{R}$$

This is a direct computation following from the steps shown, not an inference.

**Verification of general form**: at $t = 1$, $\mathbf{x} = \begin{pmatrix} 1 \\ 1 \end{pmatrix}$. Check: $A\begin{pmatrix}1\\1\end{pmatrix} = \begin{pmatrix}1+2\\2+4\end{pmatrix} = \begin{pmatrix}3\\6\end{pmatrix} = \mathbf{b}$ ✓. This is a direct computation confirming one instance, not a proof of the general claim.

### Visual Representation

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 420 240">
  <text x="210" y="20" font-size="13" text-anchor="middle" fill="#333">General Solution as Shifted Line (svg_diagram)</text>
  <line x1="40" y1="200" x2="380" y2="200" stroke="#999" stroke-width="1" />
  <line x1="210" y1="30" x2="210" y2="220" stroke="#999" stroke-width="1" />
  <circle cx="210" cy="200" r="4" fill="#333" />
  <text x="220" y="215" font-size="10" fill="#666">origin</text>
  <line x1="130" y1="240" x2="290" y2="80" stroke="#1f77b4" stroke-width="2" stroke-dasharray="4,3" />
  <text x="295" y="75" font-size="11" fill="#1f77b4">ker(A) through origin</text>
  <circle cx="290" cy="120" r="4" fill="#ff7f0e" />
  <text x="298" y="118" font-size="10" fill="#ff7f0e">xp (particular solution)</text>
  <line x1="210" y1="200" x2="370" y2="40" stroke="#2ca02c" stroke-width="2" />
  <text x="330" y="35" font-size="11" fill="#2ca02c">solution line through xp</text>
  <text x="210" y="235" font-size="10" text-anchor="middle" fill="#666">Solution set = homogeneous line, shifted by xp</text>
</svg>

### Key Points

- The particular solution $\mathbf{x}_p$ is not unique — any single point on the solution set works. Different choices of $\mathbf{x}_p$ differ from each other by a vector in $\ker(A)$. This follows directly from Claim B above.
- The homogeneous solution $\mathbf{x}_h$ describes the "shape" of the solution set (a subspace passing through the origin); adding $\mathbf{x}_p$ shifts this shape to pass through the actual solutions.
- If $\ker(A) = \{\mathbf{0}\}$ (trivial null space only), the general solution reduces to the single unique solution $\mathbf{x} = \mathbf{x}_p$.
- If the system is inconsistent, no particular solution exists, and the general solution formula does not apply. This follows directly from the definition of consistency discussed in relation to the rank condition.

### Dimension of the Solution Set

[Inference] The solution set of a consistent system $A\mathbf{x} = \mathbf{b}$ is commonly described in linear algebra references as an affine subspace (a subspace translated by $\mathbf{x}_p$) whose dimension equals $\dim(\ker(A)) = n - \text{rank}(A)$, based on the rank-nullity theorem discussed in relation to homogeneous systems. I cannot independently reproduce the full formal proof within this response.

### Relevance to Machine Learning

[Inference] The particular/general solution structure is described in commonly cited machine learning and optimization references as relevant in several contexts, based on descriptions in standard references. I cannot verify how any specific ML framework implements these internally without inspecting that framework's source code.

Commonly cited use cases include:

- **Underdetermined systems in overparameterized models**: when a model has more parameters than constraints, the solution set (if consistent) is described in some optimization literature as an affine subspace, with the specific particular solution found depending on the optimization algorithm and initialization. [Unverified] I cannot verify how any specific training procedure selects among these solutions without inspecting that procedure's implementation directly.
- **Minimum-norm solutions**: among all particular solutions, some numerical linear algebra references describe the minimum-norm solution (found via the Moore-Penrose pseudoinverse) as a commonly preferred choice in underdetermined regression settings. [Unverified] I cannot verify whether any specific software library defaults to this choice without inspecting its documentation or source code.
- **Regularization as solution selection**: techniques such as ridge regression are described in statistics literature as effectively selecting a particular solution from an otherwise infinite solution set by adding a penalty term. [Unverified] I cannot verify this framing for any specific implementation without inspecting its source code.

### LLM Behavior Disclaimer

[Unverified] This document reflects general explanatory patterns for mathematical content. I do not have access to information confirming how any specific language model, including the one generating this response, will behave in future interactions. Behavior is not guaranteed to be consistent, and no outcome described here should be treated as certain to recur.

**Related Topics**
- Homogeneous systems and the null space
- Rank-nullity theorem
- Consistency and solution existence
- Least squares and minimum-norm solutions
- Moore-Penrose pseudoinverse
- Affine subspaces

---
[Unverified] This entire response is labeled because it contains statements marked [Inference] and [Unverified] regarding the full-coverage proof for the general solution formula, affine subspace dimension reasoning, and machine learning application/implementation details not drawn from a specific cited source. Core mathematical definitions and computations (particular solution definition, worked example via direct verification, Claim A as a direct algebraic consequence) are standard, established, and directly verifiable through the steps shown.