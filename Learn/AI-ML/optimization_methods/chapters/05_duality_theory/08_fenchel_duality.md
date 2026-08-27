## Fenchel Duality

### Overview

Fenchel duality provides a general framework for constructing dual optimization problems using the convex conjugate function. Unlike Lagrangian duality, which is built around constraint multipliers, Fenchel duality is built around a pairing of two convex functions coupled through a linear map. It generalizes Lagrangian duality and specializes to it under standard reformulations, making it one of the two central lenses (alongside Lagrangian duality) through which convex duality is studied.

### The Convex Conjugate (Recap)

For a function $f: \mathbb{R}^n \to \mathbb{R} \cup \{+\infty\}$, the convex conjugate (Fenchel conjugate) is

$$f^*(y) = \sup_{x \in \mathbb{R}^n} \left\{ \langle y, x \rangle - f(x) \right\}$$

$f^*$ is always convex (as a pointwise supremum of affine functions in $y$), regardless of whether $f$ itself is convex. This property is what allows Fenchel duality to be stated cleanly even when working with nonconvex primal formulations, though the strongest duality results require convexity.

### Primal Problem Setup

Consider two functions $f: \mathbb{R}^n \to \mathbb{R} \cup \{+\infty\}$ and $g: \mathbb{R}^m \to \mathbb{R} \cup \{+\infty\}$, and a linear map $A: \mathbb{R}^n \to \mathbb{R}^m$. Define the primal problem:

$$p^* = \inf_{x \in \mathbb{R}^n} \left\{ f(x) + g(Ax) \right\}$$

This template is deliberately general. Many standard convex problems — regularized least squares, support vector machines, basis pursuit — can be cast in this $f(x) + g(Ax)$ form, with $f$ often playing the role of a regularizer and $g$ the role of a data-fidelity or loss term (or vice versa).

### The Fenchel Dual Problem

The Fenchel dual is constructed by conjugating both $f$ and $g$:

$$d^* = \sup_{y \in \mathbb{R}^m} \left\{ -f^*(-A^T y) - g^*(y) \right\}$$

Here $f^*$ and $g^*$ are the convex conjugates of $f$ and $g$ respectively, and $A^T$ is the adjoint (transpose) of $A$. The dual variable $y$ lives in the same space as the output of $Ax$, i.e., $\mathbb{R}^m$.

**[Confirmed]** This construction always satisfies weak duality:

$$p^* \geq d^*$$

**Derivation of weak duality.** For any $x \in \mathbb{R}^n$ and $y \in \mathbb{R}^m$, the definition of the conjugate gives

$$f^*(-A^Ty) \geq \langle -A^Ty, x \rangle - f(x) = -\langle y, Ax \rangle - f(x)$$



$$g^*(y) \geq \langle y, Ax \rangle - g(Ax)$$

Adding these two inequalities:

$$f^*(-A^Ty) + g^*(y) \geq -f(x) - g(Ax)$$

Rearranging:

$$f(x) + g(Ax) \geq -f^*(-A^Ty) - g^*(y)$$

Since this holds for every $x$ and every $y$, taking the infimum over $x$ on the left and the supremum over $y$ on the right preserves the inequality, giving $p^* \geq d^*$.

### Strong Duality Conditions

**[Confirmed]** Strong duality ($p^* = d^*$) holds under a constraint qualification, most commonly a Slater-type condition:

- $f$ and $g$ are convex, lower semicontinuous, proper functions.
- There exists a point $x_0$ such that $f(x_0) < \infty$, $g(Ax_0) < \infty$, and $g$ is continuous at $Ax_0$ (or more generally, $0 \in \text{int}(\text{dom}(g) - A \cdot \text{dom}(f))$).

Under these conditions, the dual supremum is attained (assuming $d^* > -\infty$), and $p^* = d^*$.

**[Inference]** In finite dimensions this qualification is often easy to verify because continuity of $g$ at a point is implied by finiteness of $g$ in a neighborhood of that point, when $g$ is convex; the precise regularity conditions needed can differ slightly across texts (e.g., Rockafellar vs. Bauschke–Combettes), so the exact hypothesis set should be checked against the source being used.

### Optimality Conditions

At a primal-dual optimal pair $(x^*, y^*)$ satisfying strong duality, the following are equivalent, each capturing the same optimality from a different angle:

$$f(x^*) + g(Ax^*) = -f^*(-A^Ty^*) - g^*(y^*)$$

This equality condition unpacks into two conjugate subdifferential (Fenchel-Young equality) conditions:

$$-A^T y^* \in \partial f(x^*) \quad \Longleftrightarrow \quad x^* \in \partial f^*(-A^T y^*)$$



$$y^* \in \partial g(Ax^*) \quad \Longleftrightarrow \quad Ax^* \in \partial g^*(y^*)$$

**Key Points**

- The first condition ties the primal variable's subgradient to the dual variable transported through $A^T$.
- The second condition ties the dual variable's subgradient to the primal variable transported through $A$.
- Together, these replace the KKT stationarity, complementary slackness, and feasibility conditions found in Lagrangian duality — Fenchel duality folds all of that structure into two subdifferential inclusions.

### Relationship to Lagrangian Duality

**[Confirmed]** Fenchel duality and Lagrangian duality coincide for a broad class of problems. Consider the standard constrained problem:

$$\min_x f(x) \quad \text{s.t.} \quad Ax = b$$

This can be rewritten in Fenchel form by setting $g(z) = \iota_{\{b\}}(z)$, the indicator function of the singleton $\{b\}$ (zero at $z = b$, $+\infty$ elsewhere). Then $f(x) + g(Ax)$ equals $f(x)$ when $Ax = b$ and $+\infty$ otherwise, exactly recovering the constrained problem.

The conjugate of an indicator of a point is a linear functional:

$$g^*(y) = \sup_z \{\langle y, z \rangle - \iota_{\{b\}}(z)\} = \langle y, b \rangle$$

Substituting into the Fenchel dual gives

$$d^* = \sup_y \left\{ -f^*(-A^Ty) - \langle y, b \rangle \right\}$$

which, after a sign flip on the dual variable, matches the Lagrangian dual of the same problem obtained via $\inf_x \{f(x) + \lambda^T(Ax - b)\}$. This equivalence is why some texts present Lagrangian duality as a special case of Fenchel duality restricted to indicator-function constraint encodings, while others present them as parallel frameworks.

### Worked Example: Regularized Least Squares

Consider the Lasso-type problem:

$$\min_x \ \frac{1}{2}\|Ax - b\|_2^2 + \lambda \|x\|_1$$

Cast this into Fenchel form with $g(z) = \frac{1}{2}\|z - b\|_2^2$ acting on $z = Ax$, and $f(x) = \lambda \|x\|_1$.

**Conjugate of $g$:** For $g(z) = \frac{1}{2}\|z-b\|_2^2$, complete the supremum:

$$g^*(y) = \sup_z \left\{ \langle y, z \rangle - \tfrac{1}{2}\|z-b\|_2^2 \right\}$$

Setting the gradient in $z$ to zero: $y - (z - b) = 0 \Rightarrow z = y + b$. Substituting back:

$$g^*(y) = \langle y, b \rangle + \tfrac{1}{2}\|y\|_2^2$$

**Conjugate of $f$:** For $f(x) = \lambda\|x\|_1$, the conjugate is the indicator of the $\ell_\infty$ ball of radius $\lambda$:

$$f^*(v) = \iota_{\{\|v\|_\infty \leq \lambda\}}(v)$$

**[Confirmed]** This is a standard conjugate pair: the conjugate of a norm scaled by $\lambda$ is the indicator of the dual-norm ball of radius $\lambda$, and the $\ell_\infty$ norm is dual to the $\ell_1$ norm.

**Assembling the dual:**

$$d^* = \sup_y \left\{ -\iota_{\{\|{-A^Ty}\|_\infty \leq \lambda\}}(-A^Ty) - \langle y, b \rangle - \tfrac{1}{2}\|y\|_2^2 \right\}$$

Which simplifies to a constrained quadratic:

$$d^* = \sup_{y} \left\{ -\langle y, b \rangle - \tfrac{1}{2}\|y\|_2^2 \right\} \quad \text{s.t.} \quad \|A^Ty\|_\infty \leq \lambda$$

**Output**

The dual of the Lasso problem is a Euclidean projection-flavored quadratic program over a box-constrained (via $A^T y$) feasible region, rather than the original nonsmooth $\ell_1$-penalized least squares problem. This dual is smooth and strongly concave in $y$, which is often more tractable numerically than the nonsmooth primal, especially when $n \gg m$ or when the primal has many more variables than the dual.

### Geometric Interpretation

Fenchel duality has a clean geometric reading in terms of the epigraphs of $f$ and $-g \circ A$ (or, in the one-dimensional coupling picture, the gap between a convex function and a concave function). The primal minimizes the vertical gap between the graph of $-g(Ax)$ and the graph of $f(x)$; the dual searches over hyperplanes (indexed by $y$) that separate these two epigraphs as tightly as possible. Strong duality holds precisely when these two epigraphs can be separated by a hyperplane touching both, i.e., when there is no "duality gap" between the best affine minorant/majorant construction and the true infimum.

Below is a diagram of this primal-dual relationship:

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 420">
\<style\>
.lbl { font-family: sans-serif; font-size: 14px; fill: #1a1a1a; }
.lbl-sm { font-family: sans-serif; font-size: 12px; fill: #444; }
.title { font-family: sans-serif; font-size: 16px; font-weight: bold; fill: #1a1a1a; }
\</style\>
<text x="350" y="28" text-anchor="middle" class="title">Fenchel Duality Structure (svg_diagram)</text>

<rect x="40" y="60" width="270" height="150" rx="8" fill="#eaf2fb" stroke="#3b6ea5" stroke-width="1.5" />
<text x="175" y="85" text-anchor="middle" class="lbl" font-weight="bold">Primal Problem</text>
<text x="175" y="115" text-anchor="middle" class="lbl-sm">p* = inf_x { f(x) + g(Ax) }</text>
<text x="175" y="140" text-anchor="middle" class="lbl-sm">f, g convex functions</text>
<text x="175" y="160" text-anchor="middle" class="lbl-sm">A: linear coupling map</text>
<text x="175" y="185" text-anchor="middle" class="lbl-sm">Variable: x in R^n</text>

<rect x="390" y="60" width="270" height="150" rx="8" fill="#fbeaea" stroke="#a53b3b" stroke-width="1.5" />
<text x="525" y="85" text-anchor="middle" class="lbl" font-weight="bold">Dual Problem</text>
<text x="525" y="115" text-anchor="middle" class="lbl-sm">d* = sup_y { -f*(-A^T y) - g*(y) }</text>
<text x="525" y="140" text-anchor="middle" class="lbl-sm">f*, g* convex conjugates</text>
<text x="525" y="160" text-anchor="middle" class="lbl-sm">A^T: adjoint map</text>
<text x="525" y="185" text-anchor="middle" class="lbl-sm">Variable: y in R^m</text>

<line x1="310" y1="135" x2="390" y2="135" stroke="#333" stroke-width="1.5" marker-end="url(#arrow)" />
<line x1="390" y1="150" x2="310" y2="150" stroke="#333" stroke-width="1.5" marker-end="url(#arrow2)" />
<text x="350" y="120" text-anchor="middle" class="lbl-sm">conjugate</text>
<text x="350" y="168" text-anchor="middle" class="lbl-sm">p* ≥ d*</text>
<rect x="40" y="250" width="620" height="130" rx="8" fill="#f2f2f2" stroke="#666" stroke-width="1.5" />
<text x="350" y="275" text-anchor="middle" class="lbl" font-weight="bold">Strong Duality: Optimality Conditions at (x*, y*)</text>
<text x="350" y="305" text-anchor="middle" class="lbl-sm">-A^T y* ∈ ∂f(x*) ⟺ x* ∈ ∂f*(-A^T y*)</text>
<text x="350" y="330" text-anchor="middle" class="lbl-sm">y* ∈ ∂g(Ax*) ⟺ Ax* ∈ ∂g*(y*)</text>
<text x="350" y="360" text-anchor="middle" class="lbl-sm">Holds when p* = d* (constraint qualification satisfied)</text>
</svg>

### Special Cases

- **Norm-regularized regression**: covered in the worked example above, generalizes to any $\ell_p$-type penalty via dual norms.
- **Constrained convex optimization**: recovers Lagrangian duality by encoding constraints as indicator functions, as shown above.
- **Support vector machines**: the hinge-loss SVM dual is a direct instance of Fenchel duality with $f$ as an $\ell_2$ regularizer and $g$ as a sum of hinge losses.
- **Total variation denoising**: image-processing formulations frequently use Fenchel duality (via the dual of the TV seminorm) to derive efficient primal-dual algorithms such as Chambolle-Pock.

### Algorithmic Relevance

**[Inference]** The main practical reason Fenchel duality matters beyond its theoretical elegance is that it underlies a family of primal-dual first-order algorithms (e.g., the Chambolle-Pock algorithm, ADMM in some derivations, and primal-dual hybrid gradient methods). These methods alternate between updates on $x$ using $f$ (or its proximal operator) and updates on $y$ using $g^*$ (or its proximal operator), exploiting the fact that proximal operators of a function and its conjugate are related by the Moreau decomposition:

$$x = \text{prox}_{\tau f}(x) + \tau \, \text{prox}_{f^*/\tau}(x/\tau)$$

This identity means that whichever of $f$ or $f^*$ is easier to compute a proximal step for, the other's proximal step is obtainable essentially for free, which is a major reason Fenchel-dual formulations are favored in large-scale nonsmooth optimization.

### Conclusion

Fenchel duality reframes optimization duality around conjugate functions and a linear coupling operator rather than around explicit constraint multipliers. It subsumes Lagrangian duality as a special case, provides clean subdifferential-based optimality conditions, and is the structural backbone of many modern primal-dual optimization algorithms. Its geometric reading — separating hyperplanes between epigraphs — offers an intuition complementary to the multiplier-based view of Lagrangian duality.

**Related Topics**

- Lagrangian duality and KKT conditions (cross-reference / prerequisite)
- Moreau decomposition and proximal operators
- Chambolle-Pock primal-dual algorithm
- Dual norms and their role in conjugate computation
- Strong duality via Slater's condition (general convex programs)
- Fenchel-Rockafellar theorem (measure-theoretic and infinite-dimensional extensions)
- Biconjugation and the Fenchel-Moreau theorem ($f^{**} = f$ for closed convex $f$)
- Applications to total variation denoising and image reconstruction