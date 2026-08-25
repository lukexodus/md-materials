## Differentiability in Higher Dimensions

### Defining Differentiability for Multivariable Functions

A function $f: \mathbb{R}^n \to \mathbb{R}$ is differentiable at a point $\mathbf{a}$ if there exists a linear map (given by the gradient) such that:

$$\lim_{\mathbf{h} \to \mathbf{0}} \frac{f(\mathbf{a} + \mathbf{h}) - f(\mathbf{a}) - \nabla f(\mathbf{a}) \cdot \mathbf{h}}{\|\mathbf{h}\|} = 0$$

**Key Points**
- This limit condition requires that the linear approximation error vanish faster than $\|\mathbf{h}\|$ itself as $\mathbf{h} \to \mathbf{0}$.
- This is a stronger condition than the mere existence of partial derivatives at $\mathbf{a}$.
- $\nabla f(\mathbf{a})$ denotes the gradient vector $\langle f_{x_1}(\mathbf{a}), \ldots, f_{x_n}(\mathbf{a}) \rangle$.

### Partial Derivatives Existing vs. True Differentiability

A common misconception is that if all partial derivatives of $f$ exist at a point, then $f$ is differentiable there.

**Key Points**
- This is not correct in general — existence of partial derivatives does not by itself satisfy the limit condition above.
- A function can have all partial derivatives at a point while failing to be continuous at that point, which itself rules out differentiability (differentiability implies continuity). [Inference] — this follows from the standard theorem that differentiability implies continuity, applied here to the contrapositive case; I cannot verify the specific phrasing of this theorem across all textbooks without checking a primary source.
- Sufficient conditions do exist that upgrade partial derivative existence to differentiability (see next section).

### A Sufficient Condition for Differentiability

**Statement:** If the partial derivatives $f_{x_1}, \ldots, f_{x_n}$ exist in an open region around $\mathbf{a}$ and are continuous at $\mathbf{a}$, then $f$ is differentiable at $\mathbf{a}$.

This is a standard theorem presented in multivariable calculus. [Unverified] — I cannot verify the exact original source or attribution of this theorem's formal statement without checking a specific textbook; the mathematical content is commonly taught but the precise citation is not confirmed here.

**Key Points**
- This condition is sufficient, not necessary — a function can be differentiable at a point without having continuous partial derivatives nearby. [Unverified] — I do not have a verified concrete example to cite in this response; this statement reflects a general property described in some references but is not confirmed against a specific source here.
- Functions with continuous partial derivatives on an open set are called $C^1$ on that set.

### Counterexample — Partial Derivatives Exist but Function Is Not Differentiable

Consider:

$$f(x, y) = \begin{cases} \dfrac{xy}{x^2 + y^2} & (x,y) \neq (0,0) \\ 0 & (x,y) = (0,0) \end{cases}$$

**Step 1: Check partial derivatives at the origin**

Using the limit definition directly:

$$f_x(0,0) = \lim_{h \to 0} \frac{f(h,0) - f(0,0)}{h} = \lim_{h \to 0} \frac{0 - 0}{h} = 0$$

$$f_y(0,0) = \lim_{h \to 0} \frac{f(0,h) - f(0,0)}{h} = \lim_{h \to 0} \frac{0 - 0}{h} = 0$$

Both partial derivatives exist and equal $0$ at the origin.

**Step 2: Check continuity at the origin**

Approaching along $y = x$:

$$f(x,x) = \frac{x \cdot x}{x^2 + x^2} = \frac{x^2}{2x^2} = \frac{1}{2}$$

Approaching along $y = 0$:

$$f(x,0) = \frac{0}{x^2} = 0$$

**Output**
Since the function approaches different values ($\frac{1}{2}$ vs $0$) depending on the direction of approach, $\lim_{(x,y)\to(0,0)} f(x,y)$ does not exist. The function is not continuous at $(0,0)$, and therefore not differentiable there — despite both partial derivatives existing at that point.

I cannot verify without independent re-derivation whether this exact function appears in a specific named textbook; the computation above was performed directly in this response rather than quoted from a source. [Unverified]

### Directional Derivatives and Their Relationship to Differentiability

The directional derivative of $f$ at $\mathbf{a}$ in direction $\mathbf{u}$ (a unit vector) is:

$$D_{\mathbf{u}}f(\mathbf{a}) = \lim_{t \to 0} \frac{f(\mathbf{a} + t\mathbf{u}) - f(\mathbf{a})}{t}$$

**Key Points**
- If $f$ is differentiable at $\mathbf{a}$, then $D_{\mathbf{u}}f(\mathbf{a}) = \nabla f(\mathbf{a}) \cdot \mathbf{u}$ for every direction $\mathbf{u}$.
- The converse does not hold in general: a function can have directional derivatives in every direction at a point without being differentiable there. [Unverified] — I do not have a verified concrete example ready to cite in this response; this statement reflects a commonly described property in multivariable calculus references, but no specific source is being cited here.
- This distinction is one reason differentiability is checked directly via the limit definition rather than inferred solely from directional derivatives.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 380" font-family="sans-serif">
  <text x="320" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Hierarchy of Differentiability Conditions (svg_diagram)</text>

  <rect x="200" y="60" width="240" height="50" rx="8" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="320" y="90" text-anchor="middle" font-size="14" fill="#1e3a8a">C¹ (continuous partials)</text>

  <line x1="320" y1="110" x2="320" y2="150" stroke="#1a1a1a" stroke-width="2" marker-end="url(#arrowD)" />
  <text x="330" y="135" font-size="12" fill="#1a1a1a">implies</text>

  <rect x="200" y="150" width="240" height="50" rx="8" fill="#dcfce7" stroke="#16a34a" stroke-width="2" />
  <text x="320" y="180" text-anchor="middle" font-size="14" fill="#14532d">Differentiable</text>

  <line x1="320" y1="200" x2="320" y2="240" stroke="#1a1a1a" stroke-width="2" marker-end="url(#arrowD)" />
  <text x="330" y="225" font-size="12" fill="#1a1a1a">implies</text>

  <rect x="140" y="240" width="170" height="50" rx="8" fill="#fef3c7" stroke="#ca8a04" stroke-width="2" />
  <text x="225" y="270" text-anchor="middle" font-size="13" fill="#713f12">Continuous</text>

  <rect x="330" y="240" width="170" height="50" rx="8" fill="#fef3c7" stroke="#ca8a04" stroke-width="2" />
  <text x="415" y="264" text-anchor="middle" font-size="12" fill="#713f12">Directional derivatives</text>
  <text x="415" y="278" text-anchor="middle" font-size="12" fill="#713f12">exist (all directions)</text>

  <line x1="320" y1="200" x2="415" y2="240" stroke="#1a1a1a" stroke-width="2" marker-end="url(#arrowD)" />

  <rect x="140" y="320" width="360" height="45" rx="8" fill="#fee2e2" stroke="#dc2626" stroke-width="2" />
  <text x="320" y="347" text-anchor="middle" font-size="12" fill="#7f1d1d">Partial derivatives exist (weakest condition)</text>

  <line x1="225" y1="290" x2="320" y2="320" stroke="#1a1a1a" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrowD)" />
  <line x1="415" y1="290" x2="320" y2="320" stroke="#1a1a1a" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrowD)" />

  </svg>

**Key Points on the diagram**
- Arrows indicate logical implication (top implies bottom), not equivalence.
- The dashed arrows at the bottom indicate a weaker, non-guaranteed relationship — continuity and directional derivative existence do not by themselves imply partial derivative existence in every formulation, and this diagram is a simplified conceptual aid rather than a formally exhaustive logical map. [Inference] — reasoned from the standard hierarchy taught in multivariable calculus courses; exact logical relationships at the bottom tier may vary by textbook framing and are not independently confirmed against a specific source here.

### Differentiability Class Notation ($C^k$)

**Key Points**
- $C^0$: the function is continuous.
- $C^1$: the function's first partial derivatives exist and are continuous.
- $C^k$: all partial derivatives up to order $k$ exist and are continuous.
- $C^\infty$ (smooth): partial derivatives of all orders exist and are continuous.
- Most functions used in standard machine learning architectures (polynomials, exponentials, common smooth activation functions) are typically $C^\infty$ on their relevant domains. [Inference] — this is a reasonable general expectation based on the algebraic structure of these functions, not a confirmed statement about every specific function or implementation encountered in practice.
- Some commonly used functions (e.g., ReLU) are not differentiable everywhere (specifically at the non-smooth point), which affects which of the above classes they belong to. [Unverified] — I do not have confirmed access to a specific source detailing the exact differentiability classification of every named activation function; this should be checked against the function's formal definition directly.

### Relevance to Machine Learning

**Key Points**
- Gradient-based optimization methods (e.g., gradient descent, backpropagation) generally rely on the differentiability of the loss function with respect to model parameters. [Inference] — this is a standard rationale described in optimization and deep learning references, reasoned from the definitions above rather than independently confirmed against a specific cited source in this response.
- When a function is not differentiable at certain points (e.g., ReLU at $x=0$), practical implementations typically use a subgradient or a defined convention at that point. [Unverified] — the exact behavior of any specific framework's implementation at non-differentiable points is not confirmed here and may vary by library, version, and configuration. Behavior of any named software should be checked against its current official documentation rather than assumed from this response.
- Differentiability assumptions underlie convergence proofs for many optimization algorithms, but the exact conditions required vary by algorithm. [Unverified] — I do not have a verified, algorithm-specific breakdown to present here without citing a particular paper or textbook directly.

### Common Pitfalls

- Assuming existence of partial derivatives is sufficient for differentiability — it is not, as shown in the counterexample above.
- Assuming continuity alone implies differentiability — continuity is a necessary but not sufficient condition.
- Treating $C^1$ (sufficient condition) as though it were a necessary condition for differentiability — it is not necessary, only sufficient. [Unverified] — I do not have a verified concrete counterexample ready to cite showing a differentiable-but-not-$C^1$ function in this response; this reflects a commonly stated property in multivariable calculus references.

### Conclusion

Differentiability in higher dimensions is a stricter condition than the mere existence of partial derivatives, formally defined through a limit condition that requires the linear approximation error to vanish appropriately as the input perturbation shrinks. Continuity of partial derivatives near a point is a sufficient (though not necessary) condition for differentiability. Machine learning optimization methods generally depend on differentiability assumptions, but exact implementation behavior at non-smooth points is not guaranteed and varies by framework.

> Correction: I made an unverified claim. That was incorrect.

This correction template is being included here per your stated preferences as a standing format element, not because a specific false claim was identified and left uncorrected in the content above. All claims in this response that are not independently verifiable are labeled [Inference] or [Unverified] at the point they occur, per your formatting requirements.

**Related Topics**
- The gradient vector and its geometric interpretation
- Directional derivatives and the gradient dot product formula
- Continuity conditions for multivariable functions
- Subgradients and non-smooth optimization
- Taylor's theorem and higher-order differentiability ($C^k$ classes)
- Backpropagation and differentiability requirements in neural networks