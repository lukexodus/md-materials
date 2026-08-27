## Moreau Envelope and Smoothing Techniques

### Motivation and Background

The Moreau envelope is the analytical object that makes precise something implicit in every proximal-operator-based method covered so far: the proximal operator of $f$ is exactly the minimizer of a smoothed surrogate of $f$, and that surrogate — the Moreau envelope — is itself continuously differentiable even when $f$ is not. This topic develops the Moreau envelope as a smoothing technique in its own right, distinct from but foundational to the proximal point algorithm, proximal gradient methods, and bundle methods already covered, and connects it to a broader family of smoothing techniques for nonsmooth convex optimization.

### Definition and Basic Properties

**Key Points**

For closed, proper, convex $f: \mathbb{R}^n \to \mathbb{R}\cup\{+\infty\}$ and parameter $\lambda > 0$, the **Moreau envelope** (or Moreau-Yosida regularization) of $f$ is:

$$M_\lambda f(v) = \min_x \left( f(x) + \frac{1}{2\lambda}\|x-v\|_2^2 \right)$$

- This is precisely the **optimal value** of the minimization problem that defines the proximal operator: $\text{prox}_{\lambda f}(v)$ is the **minimizer**, while $M_\lambda f(v)$ is the corresponding **minimum value**. The two objects are companions — one is the argmin, the other the min — of the exact same optimization problem introduced in the general proximal operator discussion.
- **Everywhere finite and continuous**: $M_\lambda f$ is finite-valued and continuous on all of $\mathbb{R}^n$, even when the domain of $f$ itself is a strict subset of $\mathbb{R}^n$ (e.g., $f$ an indicator function) — the quadratic penalty term ensures the minimization is always well-posed everywhere, regardless of $f$'s own domain restrictions.
- **Continuous differentiability**: $M_\lambda f$ is continuously differentiable everywhere, **even when $f$ itself is nonsmooth**, with gradient given by



  $$\nabla M_\lambda f(v) = \frac{1}{\lambda}\left(v - \text{prox}_{\lambda f}(v)\right)$$

  This is the single most important property of the Moreau envelope: it converts a possibly nonsmooth, non-differentiable function $f$ into an everywhere-differentiable function $M_\lambda f$ whose gradient is computable directly from the proximal operator of $f$ — no separate differentiation of $f$ is needed or possible at points where $f$ itself lacks a derivative.
- **Lipschitz gradient**: The gradient $\nabla M_\lambda f$ is Lipschitz continuous with constant $1/\lambda$ — so $M_\lambda f$ is not merely differentiable but has the specific smoothness property (Lipschitz gradient) that unlocks standard gradient-descent-type convergence theory, with the Lipschitz constant directly and simply controlled by the single parameter $\lambda$.

### Same Minimizers, Same Optimal Value

**Key Points**

- $M_\lambda f$ and $f$ share exactly the same set of minimizers and the same optimal value: $\arg\min_x f(x) = \arg\min_v M_\lambda f(v)$ and $\min_x f(x) = \min_v M_\lambda f(v)$, for every $\lambda > 0$. This follows directly from the fixed-point property of the proximal operator (established in the general proximal operator properties) applied to the envelope's defining minimization.
- This equivalence is what makes the Moreau envelope a genuine **smoothing technique** rather than merely an approximation: minimizing the everywhere-differentiable $M_\lambda f$ via smooth optimization methods (e.g., ordinary gradient descent) yields **exactly** the same solution as minimizing the original nonsmooth $f$ — there is no approximation error introduced by this reformulation, in contrast to many other smoothing techniques (discussed below) that trade a smoothing parameter for a controlled but nonzero approximation error.
- **Gradient descent on the Moreau envelope equals the proximal point algorithm**: Applying ordinary gradient descent with step size $\lambda$ to $M_\lambda f$ gives $v^{k+1} = v^k - \lambda \nabla M_\lambda f(v^k) = v^k - (v^k - \text{prox}_{\lambda f}(v^k)) = \text{prox}_{\lambda f}(v^k)$ — exactly the proximal point algorithm update from the preceding topic. This identity is the precise sense in which the proximal point algorithm **is** gradient descent, just applied to the Moreau envelope rather than to $f$ directly, unifying the two topics as different views of the same underlying iteration.

### Interpretation as Infimal Convolution

**Key Points**

- The Moreau envelope can equivalently be written as the **infimal convolution** of $f$ with a scaled squared norm: $M_\lambda f = f \, \square \, \left(\frac{1}{2\lambda}\|\cdot\|_2^2\right)$, where $(g \,\square\, h)(v) = \min_x \left(g(x) + h(v-x)\right)$ is the infimal convolution operator.
- Infimal convolution with a quadratic has a smoothing effect analogous to how ordinary convolution with a smooth kernel smooths a function in signal processing — the quadratic "kernel" here is what forces $M_\lambda f$'s differentiability, and the parameter $\lambda$ plays a role directly analogous to a kernel bandwidth: larger $\lambda$ produces heavier smoothing (a Moreau envelope that is a looser approximation of $f$'s local geometry) while smaller $\lambda$ produces lighter smoothing that stays closer to $f$'s original shape (with $M_\lambda f \to f$ pointwise as $\lambda \to 0^+$, under standard regularity conditions on $f$).

### Worked Example: Moreau Envelope of the Absolute Value

**Example**

For $f(x) = |x|$ (the scalar case, revisited from the subgradient methods topic where $\partial f(0) = [-1,1]$), the proximal operator is soft-thresholding: $\text{prox}_{\lambda f}(v) = \text{sign}(v)\max(|v|-\lambda, 0)$ (a special case of the closed-form catalogue from the general proximal operator topic). The Moreau envelope works out to the closed form:

$$M_\lambda f(v) =
\begin{cases}
\frac{1}{2\lambda}v^2 & |v| \le \lambda \\
|v| - \frac{\lambda}{2} & |v| > \lambda
\end{cases}$$

This is precisely the **Huber loss** (with transition point at $\lambda$) — a function that behaves quadratically near the origin (where $|x|$ has its non-differentiable kink) and linearly (matching $|x|$'s own slope) away from the origin. This closed-form example makes the general smoothing behavior concrete: the Moreau envelope replaces the sharp kink of $|x|$ at $0$ with a smooth quadratic "rounding" of width controlled by $\lambda$, while leaving the function unchanged (up to a constant shift) far from the kink — exactly the local-smoothing, global-preservation behavior described abstractly above.

### Moreau Envelope Smoothing Illustration

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 400">
<text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Moreau Envelope of |x|: Huber-Type Smoothing (svg_diagram)</text>
<line x1="60" y1="340" x2="580" y2="340" stroke="#555" stroke-width="1.5" />
<line x1="320" y1="340" x2="320" y2="60" stroke="#555" stroke-width="1.5" />
<text x="580" y="360" font-size="12" fill="#555">x</text>
<text x="300" y="60" font-size="12" fill="#555">f(x)</text>

<polyline points="120,80 320,300 520,80" fill="none" stroke="#2563eb" stroke-width="2.5" />
<text x="130" y="95" font-size="13" fill="#2563eb">f(x) = |x|</text>

<path d="M 120,90 L 260,270 Q 320,320 380,270 L 520,90" fill="none" stroke="#dc2626" stroke-width="2.5" stroke-dasharray="0" />
<text x="380" y="110" font-size="13" fill="#dc2626">M_lambda f(x)</text>

<text x="150" y="380" font-size="12" fill="#444">Kink at x=0 replaced by a smooth quadratic region of width ~lambda; linear parts match away from 0.</text>

</svg>

### Broader Family of Smoothing Techniques

**Key Points**

While the Moreau envelope achieves smoothing with **no change to the minimizer or optimal value**, other smoothing techniques for nonsmooth convex optimization introduce a **controlled approximation error**, trading exactness for other advantages (e.g., a simpler closed form, or compatibility with specific structured functions like a max of finitely many linear functions):

- **Nesterov smoothing (via conjugate/dual representation)**: For $f(x) = \max_{u \in Q} \langle Ax, u\rangle - \phi(u)$, a common form for functions expressible as the maximum of linear functions over a compact set $Q$ (e.g., piecewise-linear functions, dual norms), adding a strongly convex regularizer $\mu \, d(u)$ to the inner maximization yields a smoothed surrogate $f_\mu(x) = \max_{u\in Q}\left(\langle Ax,u\rangle - \phi(u) - \mu\, d(u)\right)$ that is differentiable with Lipschitz gradient constant proportional to $1/\mu, directly analogous to the Moreau envelope's $1/\lambda
   Lipschitz constant, but derived via the conjugate/dual representation rather than the primal infimal-convolution construction.
- **Approximation-accuracy trade-off**: Unlike the Moreau envelope, Nesterov-style dual smoothing generally introduces an explicit, controllable gap between $f_\mu$ and $f$ (e.g., $f(x) \le f_\mu(x) + \mu D$ for a constant $D$ related to the diameter of $Q$), so the smoothing parameter $\mu$ must be tuned against a target accuracy — smaller $\mu$ gives a tighter approximation to $f$ but a larger (worse) Lipschitz gradient constant, a direct trade-off exploited in Nesterov's optimal smoothing-based algorithms for structured nonsmooth convex problems, which combine this smoothing with accelerated gradient methods (the same acceleration machinery covered for FISTA) applied to the smoothed surrogate $f_\mu$ to achieve improved rates on problems with this specific max-of-linear-functions structure. [Inference: whether a specific nonsmooth problem is amenable to this dual/max-representation smoothing depends on whether it naturally admits the required saddle-point/max-of-linear-functions structure.]
- **Log-sum-exp / softmax smoothing**: For $f(x) = \max_i (a_i^Tx + b_i)$ (a max of finitely many affine functions), the log-sum-exp function $f_\mu(x) = \mu \log\left(\sum_i \exp\left(\frac{a_i^Tx+b_i}{\mu}\right)\right)$ provides a simple, everywhere-differentiable smooth approximation with an explicit, easily bounded approximation gap $0 \le f_\mu(x) - f(x) \le \mu \log(m)$ (for $m$ the number of affine pieces), again trading smoothing parameter $\mu$ against approximation tightness in a similar spirit to Nesterov smoothing, but with a simpler closed form specific to the finite-max case.

### Comparison of Smoothing Approaches

| Property | Moreau Envelope | Nesterov Dual Smoothing | Log-Sum-Exp Smoothing |
| --- | --- | --- | --- |
| Applicable function class | Any closed, proper, convex $f$ | $f$ expressible as max of linear functions over compact $Q$ | $f$ = max of finitely many affine functions |
| Preserves exact minimizer/optimal value | Yes, exactly, for any $\lambda>0$ | No — introduces controlled approximation gap | No — introduces controlled approximation gap |
| Gradient computation | Via proximal operator: $(v-\text{prox}_{\lambda f}(v))/\lambda$ | Via solving the regularized inner maximization | Closed form (softmax-weighted average of $a_i$) |
| Lipschitz constant of smoothed gradient | $1/\lambda$ | $O(1/\mu)$, constant depends on regularizer $d(u)$ | $O(1/\mu)$ (depends on max affine coefficient norms) |
| Typical use | Foundation for proximal point algorithm; general-purpose | Structured nonsmooth problems (e.g., certain saddle-point / LP-representable problems) | Piecewise-linear objectives, max-type penalties |

### Practical Considerations

- Because the Moreau envelope shares minimizers exactly with $f$, it is the natural choice whenever the proximal operator of $f$ is already tractable (the same tractability condition that makes proximal gradient and proximal point methods practical) — in that setting there is no reason to trade away exactness for one of the approximate smoothing techniques.
- Nesterov-style dual smoothing and log-sum-exp smoothing become attractive specifically when $f$ has the required max-of-linear-functions structure but its proximal operator is not directly tractable, or when the resulting smoothed problem's structure (e.g., compatibility with accelerated gradient methods at a chosen fixed smoothing parameter) offers an implementation advantage over an exact but harder-to-compute proximal step. [Inference: whether this trade-off favors approximate smoothing over an exact (but costlier) proximal evaluation is problem-specific.]
- Tuning the smoothing parameter in approximation-based methods ($\mu$ in both Nesterov and log-sum-exp smoothing) requires balancing the approximation gap against the resulting Lipschitz constant, typically by setting $\mu$ as a function of the total iteration budget to balance both error sources — an analogous tuning problem to choosing $\lambda_k$ in the proximal point algorithm's linear-convergence trade-off, but here trading off approximation bias rather than subproblem-solve cost. [Inference: the specific optimal tuning schedule depends on the target accuracy and the particular smoothing technique's error/Lipschitz-constant relationship.]

### Related Topics

- Proximal operator computation and properties
- Proximal point algorithms and their identity with gradient descent on the Moreau envelope
- Nesterov smoothing for structured nonsmooth convex optimization
- Accelerated gradient methods applied to smoothed surrogates
- Infimal convolution and convex analysis foundations
- Huber loss and robust regression formulations
- Dual/conjugate function representations of nonsmooth convex functions
- Bundle methods as an alternative response to nonsmoothness