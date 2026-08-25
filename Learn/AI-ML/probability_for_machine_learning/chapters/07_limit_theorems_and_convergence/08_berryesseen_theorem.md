## Berry–Esseen Theorem

### Definition

Let $X_1, X_2, \dots$ be i.i.d. random variables with finite mean $E[X_i] = \mu$, finite variance $\text{Var}(X_i) = \sigma^2 > 0$, and finite third absolute moment $E[|X_i - \mu|^3] = \rho < \infty$. Let $F_n$ denote the CDF of the standardized sum:

$$Z_n = \frac{\sum_{i=1}^{n} X_i - n\mu}{\sigma \sqrt{n}}$$

and let $\Phi$ denote the standard normal CDF. The Berry–Esseen theorem states that there exists a constant $C$ such that:

$$\sup_x |F_n(x) - \Phi(x)| \leq \frac{C \rho}{\sigma^3 \sqrt{n}}$$

[Inference] This is the standard form of the Berry–Esseen theorem as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing, historical attribution, or precise statement against a specific named textbook in this response.

### Key Points

- The theorem provides a **rate of convergence** for the Central Limit Theorem, rather than merely asserting convergence in distribution as $n \to \infty$.
- The bound decays at rate $O(1/\sqrt{n})$. [Inference] This follows directly from the algebraic form of the bound stated above, reasoned rather than independently confirmed against a named source.
- The constant $C$ is universal (does not depend on the distribution of $X_i$), but I cannot verify its exact known numerical value or tightest currently established bound without checking a specific source.

### The Constant $C$

[Unverified] I cannot verify the precise historical progression or current best-known value of the constant $C$ without checking a formal, up-to-date source. I recall that research has proposed successively smaller upper bounds for $C$ over time (originally attributed in part to work by Berry and Esseen in the 1940s, with later refinements by other researchers), but I cannot confirm specific numerical values, exact attributions, or the current tightest known bound in this response without citation verification.

[Speculation] It is possible that the exact current best-known constant has continued to be refined in academic literature beyond what I can confirm here; I do not have access to verify the most recent state of this research area.

### Interpretation

- For any fixed sample size $n$, the theorem gives an explicit upper bound on how far the CDF of the standardized sum can be from the standard normal CDF, in the worst case over all $x$.
- Larger third absolute moment $\rho$ (indicating a more skewed or heavy-tailed underlying distribution) results in a looser (larger) bound, [Inference] reasoned directly from the bound's algebraic form, since $\rho$ appears in the numerator.
- Larger $\sigma^3$ in the denominator tightens the bound, [Inference] also reasoned directly from the algebraic structure of the inequality.

### Worked Example (Illustrative Calculation Only)

Let $X_1, X_2, \dots$ be i.i.d. fair coin flips coded as $X_i = 1$ (heads) or $X_i = 0$ (tails), so:

$$\mu = 0.5, \quad \sigma^2 = 0.25, \quad \sigma = 0.5$$

The third absolute central moment for this Bernoulli case is:

$$\rho = E[|X_i - 0.5|^3] = 0.5 \cdot (0.5)^3 + 0.5 \cdot (0.5)^3 = 0.125$$

[Inference] This calculation follows from direct substitution into the definition of the third absolute central moment for a symmetric two-point distribution. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

Using a commonly cited (but [Unverified]) value of $C \approx 0.4748$ [Unverified — I cannot confirm this specific numerical constant against a current authoritative source in this response], the bound for $n = 100$ would be approximately:

$$\sup_x |F_n(x) - \Phi(x)| \leq \frac{0.4748 \times 0.125}{(0.5)^3 \sqrt{100}} \approx \frac{0.0594}{1.25} \approx 0.0475$$

[Inference] This arithmetic follows from substituting the stated values into the Berry–Esseen bound formula above. Since the constant $C$ used is itself [Unverified], this entire numerical result should be treated as illustrative only, not as a confirmed, citable figure.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Berry–Esseen Bound (svg_diagram)</text>

  <line x1="80" y1="280" x2="620" y2="280" stroke="#333" stroke-width="1.5" />
  <text x="620" y="300" font-size="12" fill="#333">x</text>
  <line x1="80" y1="280" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="40" y="65" font-size="12" fill="#333">CDF</text>

  <path d="M100,270 C 200,250 280,120 350,80 C 420,120 500,250 600,270" stroke="#c4574a" stroke-width="2.5" fill="none" />
  <text x="560" y="90" font-size="11" fill="#c4574a">Φ(x) (normal)</text>

  <path d="M100,272 C 200,255 280,130 350,88 C 420,128 500,255 600,272" stroke="#4a72c4" stroke-width="1.8" fill="none" stroke-dasharray="5,3" />
  <text x="560" y="115" font-size="11" fill="#4a72c4">Fn(x) (actual)</text>

  <line x1="350" y1="80" x2="350" y2="88" stroke="#4a9c5f" stroke-width="3" />
  <text x="360" y="70" font-size="11" fill="#4a9c5f">max gap ≤ Cρ/(σ³√n)</text>

  <text x="350" y="325" text-anchor="middle" font-size="12" fill="#555">Bound caps the worst-case distance between actual and normal CDF at finite n</text>
</svg>

### Relation to the Central Limit Theorem

- The CLT establishes that $F_n(x) \to \Phi(x)$ as $n \to \infty$, but says nothing about the **rate** of this convergence.
- The Berry–Esseen theorem quantifies that rate, giving a non-asymptotic (finite-$n$) guarantee on the approximation quality.
- [Inference] This relationship is a commonly stated motivation for the Berry–Esseen theorem in probability theory pedagogy, reasoned from comparing the two theorems' statements; I cannot verify this exact framing against a specific named source in this response.

### Relevance to Machine Learning

- [Inference] The Berry–Esseen theorem is sometimes invoked in statistical learning theory to justify finite-sample approximation guarantees for normal-approximation-based confidence intervals, rather than relying solely on asymptotic (large-$n$) CLT statements, based on general familiarity with statistical theory. I cannot verify this connection against a specific named paper in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or statistical package uses Berry–Esseen-type bounds without checking that source directly.
- [Speculation] It is possible that Berry–Esseen-type bounds are referenced in some theoretical analyses of bootstrap methods or high-dimensional statistics, but I do not have confirmed information about specific instances to cite here.
- For any behavioral claims about how a specific model, algorithm, or system's finite-sample behavior compares to its asymptotic approximation: behavior is not guaranteed and may vary depending on the underlying distribution, sample size, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Central Limit Theorem (detailed treatment)
- Convergence in distribution
- Edgeworth expansions (higher-order refinements to normal approximation)
- Concentration inequalities (Hoeffding, Bernstein) as alternative finite-sample tools
- Bootstrap methods and their theoretical justification

---

**Verification Status of This Document**: This document contains multiple [Inference], [Unverified], and [Speculation] labeled statements, particularly regarding the historical attribution and current best-known value of the constant $C$, the precision of the worked numerical example, and connections to machine learning practice. The core structural form of the Berry–Esseen inequality reflects a standard formulation in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal, current reference.