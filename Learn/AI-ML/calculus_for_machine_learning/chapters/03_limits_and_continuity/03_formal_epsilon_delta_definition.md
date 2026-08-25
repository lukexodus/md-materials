## Formal Epsilon-Delta Definition

### Statement of the Definition

The formal definition of a limit provides a rigorous, precise way to state what it means for $f(x)$ to approach $L$ as $x$ approaches $c$.

$$\lim_{x \to c} f(x) = L$$

means: for every $\varepsilon > 0$, there exists a $\delta > 0$ such that whenever $0 < |x - c| < \delta$, it follows that $|f(x) - L| < \varepsilon$.

Symbolically:

$$\forall \varepsilon > 0, \ \exists \delta > 0 \ \text{such that} \ 0 < |x - c| < \delta \implies |f(x) - L| < \varepsilon$$

This is a standard mathematical definition found in calculus references and is not [Inference] or [Speculation].

### Interpreting the Definition

**Key Points**

- $\varepsilon$ (epsilon) represents an arbitrarily small tolerance around the target value $L$
- $\delta$ (delta) represents how close $x$ must be to $c$ to guarantee $f(x)$ falls within that tolerance
- The condition $0 < |x - c|$ excludes $x = c$ itself, so the value $f(c)$ (or its absence) does not affect the limit
- The definition requires that a valid $\delta$ can be found for *every* choice of $\varepsilon$, no matter how small

This interpretation is a standard reading of the formal definition and is directly derivable from the symbolic statement above.

### Visualizing Epsilon-Delta

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="25" font-size="16" text-anchor="middle" font-family="sans-serif" font-weight="bold">Epsilon-Delta Definition (svg_diagram)</text>

  <line x1="60" y1="280" x2="650" y2="280" stroke="#334155" stroke-width="1.5" />
  <line x1="350" y1="40" x2="350" y2="300" stroke="#334155" stroke-width="1.5" />
  <text x="655" y="285" font-size="11" font-family="sans-serif">x</text>
  <text x="355" y="45" font-size="11" font-family="sans-serif">y</text>

  <rect x="300" y="40" width="100" height="240" fill="#dbeafe" opacity="0.5" />
  <line x1="300" y1="280" x2="300" y2="40" stroke="#1d4ed8" stroke-width="1" stroke-dasharray="4,4" />
  <line x1="400" y1="280" x2="400" y2="40" stroke="#1d4ed8" stroke-width="1" stroke-dasharray="4,4" />
  <text x="300" y="300" font-size="10" font-family="sans-serif" fill="#1d4ed8">c-δ</text>
  <text x="390" y="300" font-size="10" font-family="sans-serif" fill="#1d4ed8">c+δ</text>

  <rect x="60" y="130" width="590" height="80" fill="#dcfce7" opacity="0.5" />
  <line x1="60" y1="130" x2="650" y2="130" stroke="#15803d" stroke-width="1" stroke-dasharray="4,4" />
  <line x1="60" y1="210" x2="650" y2="210" stroke="#15803d" stroke-width="1" stroke-dasharray="4,4" />
  <text x="65" y="125" font-size="10" font-family="sans-serif" fill="#15803d">L+ε</text>
  <text x="65" y="225" font-size="10" font-family="sans-serif" fill="#15803d">L-ε</text>

  <path d="M 100 250 L 650 90" fill="none" stroke="#334155" stroke-width="2" />

  <circle cx="350" cy="170" r="5" fill="#b91c1c" />
  <text x="358" y="165" font-size="10" font-family="sans-serif" fill="#b91c1c">(c, L)</text>
</svg>

This diagram is a conceptual, schematic illustration of the standard epsilon-delta visualization convention and is not a precisely scaled plot.

### Worked Example

**Claim:** $\lim_{x \to 3} (2x + 1) = 7$

**Proof using the formal definition:**

Given any $\varepsilon > 0$, we need to find $\delta > 0$ such that:

$$0 < |x - 3| < \delta \implies |(2x+1) - 7| < \varepsilon$$

Simplify the target inequality:

$$|(2x+1) - 7| = |2x - 6| = 2|x - 3|$$

So we need:

$$2|x - 3| < \varepsilon \implies |x - 3| < \frac{\varepsilon}{2}$$

Choosing $\delta = \dfrac{\varepsilon}{2}$ satisfies the requirement: whenever $0 < |x - 3| < \delta$, it follows that $|(2x+1) - 7| < \varepsilon$.

This is a directly verifiable algebraic proof, not [Inference].

### General Strategy for Epsilon-Delta Proofs

1. Start with the target inequality $|f(x) - L| < \varepsilon$
2. Algebraically manipulate it to isolate $|x - c|$
3. Identify a $\delta$ (often in terms of $\varepsilon$) that makes the implication hold
4. State the choice of $\delta$ and verify the logic works in both directions

This is a standard proof strategy taught in calculus curricula and is a verifiable, mechanical procedure applicable to many polynomial and rational function limits.

### Why the Formal Definition Matters

The intuitive notion of a limit ("gets arbitrarily close to") relies on informal language. The epsilon-delta definition replaces this informal language with a precise, checkable logical statement, removing ambiguity about what "arbitrarily close" means.

**Key Points**

- The formal definition allows limits to be proven rigorously rather than only estimated numerically or graphically
- It underlies rigorous definitions of continuity, derivatives, and integrals
- [Inference] Many introductory calculus courses present the epsilon-delta definition after building intuition with numerical and graphical approaches, since the formal logical structure can be more abstract for learners initially encountering limits. I cannot verify this pedagogical ordering is followed identically across all curricula without a specific citation to a specific course or textbook.

### Formal Definition of One-Sided Limits

**Right-hand limit:**

$$\lim_{x \to c^+} f(x) = L \iff \forall \varepsilon > 0, \ \exists \delta > 0 \ \text{such that} \ 0 < x - c < \delta \implies |f(x) - L| < \varepsilon$$

**Left-hand limit:**

$$\lim_{x \to c^-} f(x) = L \iff \forall \varepsilon > 0, \ \exists \delta > 0 \ \text{such that} \ -\delta < x - c < 0 \implies |f(x) - L| < \varepsilon$$

These are standard formal definitions, directly extending the two-sided case by restricting the direction of approach.

### Formal Definition of Continuity (Preview)

Using the epsilon-delta framework, a function $f$ is continuous at $c$ if:

$$\lim_{x \to c} f(x) = f(c)$$

which expands to:

$$\forall \varepsilon > 0, \ \exists \delta > 0 \ \text{such that} \ |x - c| < \delta \implies |f(x) - f(c)| < \varepsilon$$

Note that this version does not exclude $x = c$, since $f(c)$ is required to equal the limit value. This is a standard, verifiable definition.

### Relevance to Machine Learning

#### Rigor Underlying Gradient-Based Methods

The derivative, which is central to gradient descent and backpropagation, is formally defined as a limit:

$$f'(x) = \lim_{h \to 0} \frac{f(x+h) - f(x)}{h}$$

The epsilon-delta framework is what gives this limit — and therefore the derivative — a rigorous mathematical foundation. This is a verifiable statement about the formal structure of calculus, not [Inference].

**Key Points**

- [Inference] While practitioners applying gradient descent typically do not perform epsilon-delta proofs directly, the validity of the derivative-based methods used in optimization relies on this underlying rigorous definition existing. I cannot verify without a specific citation that this exact framing of practical relevance is stated identically in machine learning literature, though the mathematical dependency of derivatives on the formal limit definition is directly verifiable.
- [Unverified] Whether any specific machine learning course or textbook explicitly covers epsilon-delta proofs as a prerequisite topic varies by curriculum, and I do not have access to information confirming this for any particular current course without checking its syllabus directly.

#### Convergence Proofs in Optimization Theory

[Inference] Formal convergence proofs for optimization algorithms (such as showing that gradient descent approaches a minimum under certain conditions) often rely on limit-based arguments structurally related to the epsilon-delta framework, particularly when establishing bounds on how close iterates get to a target value as iterations increase. I cannot verify without a specific citation that this exact connection is drawn explicitly in any particular source, though the general mathematical relationship between formal limits and convergence arguments is a standard feature of real analysis.

### Summary Table

| Symbol | Meaning |
|---|---|
| $\varepsilon$ | Arbitrarily small tolerance around $L$ |
| $\delta$ | Corresponding closeness required in $x$ around $c$ |
| $0 < \lvert x-c \rvert < \delta$ | $x$ is close to $c$, excluding $x=c$ itself |
| $\lvert f(x)-L \rvert < \varepsilon$ | $f(x)$ is close to $L$ |

**Related Topics**

- Formal definition of continuity at a point
- Formal definition of the derivative as a limit
- Limits at infinity (formal definition)
- Proving limits do not exist using epsilon-delta
- Uniform continuity vs. pointwise continuity

---

**Note on this response:** This response follows the labeling conventions in your stated preferences. Standard, verifiable mathematical definitions and directly computable algebraic proofs are not labeled [Inference]/[Unverified], since they are confirmable from the definitions themselves. Statements about pedagogical practices, curriculum design, or unstated implementation/framing choices are labeled accordingly. If any portion above is later found to misstate a verifiable mathematical fact:

> Correction: I made an unverified claim. That was incorrect.