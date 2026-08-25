## Mean Value Theorem

### Definition

The Mean Value Theorem (MVT) states that for a function $f$ continuous on the closed interval $[a, b]$ and differentiable on the open interval $(a, b)$, there exists at least one point $c \in (a, b)$ such that:

$$f'(c) = \frac{f(b) - f(a)}{b - a}$$

This means the instantaneous rate of change at $c$ equals the average rate of change over $[a, b]$.

### Core Principle

**Hypotheses (required conditions):**
1. $f$ is continuous on the closed interval $[a, b]$.
2. $f$ is differentiable on the open interval $(a, b)$.

**Conclusion:**
There exists at least one $c \in (a, b)$ where the tangent line slope at $c$ equals the secant line slope connecting $(a, f(a))$ and $(b, f(b))$.

[Unverified] Whether a given function satisfies both hypotheses cannot be determined without direct inspection of that specific function; the theorem's guarantee applies only when both conditions hold.

### Relationship to Rolle's Theorem

Rolle's Theorem is a special case of the Mean Value Theorem where $f(a) = f(b)$. In that case:

$$f'(c) = \frac{f(b) - f(a)}{b - a} = \frac{0}{b-a} = 0$$

So Rolle's Theorem concludes there exists $c \in (a,b)$ where $f'(c) = 0$.

### Procedure

1. **Verify continuity** of $f$ on $[a, b]$.
2. **Verify differentiability** of $f$ on $(a, b)$.
3. **Compute the average rate of change:** $\dfrac{f(b) - f(a)}{b - a}$.
4. **Find $f'(x)$** and set it equal to the average rate of change.
5. **Solve for $c$**, confirming that $c$ lies within the open interval $(a, b)$.

### Mean Value Theorem Diagram (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" font-size="16" font-weight="bold" text-anchor="middle" fill="#1a1a1a">Mean Value Theorem: Tangent Parallel to Secant (svg_diagram)</text>

  <line x1="60" y1="270" x2="640" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="60" y1="270" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="640" y="290" font-size="12" fill="#555">x</text>
  <text x="45" y="50" font-size="12" fill="#555">y</text>

  <path d="M 120 240 C 220 60, 380 60, 560 150" fill="none" stroke="#1a4fa3" stroke-width="3" />

  <circle cx="120" cy="240" r="6" fill="#1a1a1a" />
  <circle cx="560" cy="150" r="6" fill="#1a1a1a" />
  <text x="120" y="260" font-size="13" text-anchor="middle" fill="#1a1a1a">a</text>
  <text x="560" y="175" font-size="13" text-anchor="middle" fill="#1a1a1a">b</text>

  <line x1="120" y1="240" x2="560" y2="150" stroke="#b30000" stroke-width="2" stroke-dasharray="6,4" />
  <text x="450" y="175" font-size="13" fill="#b30000">Secant line</text>

  <circle cx="330" cy="100" r="6" fill="#0a6b0a" />
  <text x="330" y="85" font-size="13" text-anchor="middle" fill="#0a6b0a">c</text>

  <line x1="220" y1="140" x2="440" y2="60" stroke="#0a6b0a" stroke-width="2" />
  <text x="440" y="50" font-size="13" fill="#0a6b0a">Tangent at c</text>
</svg>

### Worked Example

Let $f(x) = x^3 - x$ on $[0, 2]$.

**Step 1 — Continuity and differentiability:**

$f(x) = x^3 - x$ is a polynomial, so it is continuous on $[0, 2]$ and differentiable on $(0, 2)$. Both MVT hypotheses are satisfied.

**Step 2 — Average rate of change:**

$$f(0) = 0, \quad f(2) = 8 - 2 = 6$$
$$\frac{f(2) - f(0)}{2 - 0} = \frac{6 - 0}{2} = 3$$

**Step 3 — Find $f'(x)$:**

$$f'(x) = 3x^2 - 1$$

**Step 4 — Solve $f'(c) = 3$:**

$$3c^2 - 1 = 3 \implies 3c^2 = 4 \implies c^2 = \frac{4}{3} \implies c = \pm\frac{2}{\sqrt{3}}$$

**Step 5 — Confirm $c \in (0, 2)$:**

$$c = \frac{2}{\sqrt{3}} \approx 1.1547$$

This value lies within $(0, 2)$, so it satisfies the theorem. The negative root is rejected since it lies outside the interval.

### Geometric Interpretation

The theorem guarantees that somewhere between $a$ and $b$, the curve has a tangent line parallel to the secant line connecting the endpoints $(a, f(a))$ and $(b, f(b))$. This is a property that follows directly from the stated hypotheses; no exceptions exist within the scope of the theorem as formally stated, since it is a proven mathematical result under the given conditions.

### Relevance to Machine Learning

[Inference] The Mean Value Theorem underlies some theoretical justifications used in optimization theory, including bounding how much a function's value can change given bounds on its derivative (gradient).

- [Inference] In convergence proofs for gradient-based optimization methods, MVT-style reasoning (or its multivariable generalization) is sometimes used to relate changes in a loss function to gradient magnitude between two points.
- [Unverified] Whether a specific convergence proof in a specific ML paper or textbook explicitly invokes the Mean Value Theorem by name cannot be confirmed without direct access to that source; I do not have access to verify specific citations here.
- [Speculation] MVT-based reasoning may loosely relate to Lipschitz continuity assumptions used in some optimization convergence analyses, where a bound on the derivative is used to bound function value changes. This connection is not confirmed and should not be treated as an established citation.

### Limitations

- The theorem only guarantees **existence** of at least one $c$; it does not identify how many such points exist or provide a method to find all of them beyond direct solving.
- If either hypothesis (continuity on $[a,b]$ or differentiability on $(a,b)$) fails, the conclusion is not guaranteed to hold. [Inference] Counterexamples exist for functions violating these conditions, such as functions with corners or discontinuities, but this response does not verify every possible counterexample.
- [Unverified] This response does not verify the theorem's behavior for functions defined piecewise or with non-standard domains beyond the general statement provided.

### Key Points

- MVT requires continuity on $[a,b]$ and differentiability on $(a,b)$.
- It concludes that some point $c$ has instantaneous rate of change equal to the average rate of change over the interval.
- Rolle's Theorem is the special case where $f(a) = f(b)$.
- [Inference] MVT-style reasoning has conceptual relevance to optimization convergence theory in machine learning, though this response cannot confirm specific citations or implementations without direct source access.

**Related Topics**
- Rolle's Theorem
- L'Hôpital's Rule (uses MVT/Cauchy MVT in its proof)
- Taylor's theorem with remainder
- Lipschitz continuity and its role in optimization theory
- Convexity and its relationship to derivative bounds
- Fundamental theorem of calculus