## Limit Laws and Algebraic Techniques

### Overview

Limit laws provide the formal rules for evaluating limits of combined functions (sums, products, quotients, compositions) once the limits of the individual pieces are known. Algebraic techniques — factoring, rationalizing, simplifying — extend this toolkit to indeterminate forms where direct substitution fails. In machine learning, these techniques underpin the derivation of gradients, the analysis of activation function behavior at boundary points, and the justification of numerical stability tricks used in loss functions.

### Prerequisites

- Basic limit notation and intuition ($\lim_{x \to a} f(x) = L$)
- Function composition and algebraic manipulation (factoring, rationalizing)
- Piecewise and rational functions

### The Formal Limit Laws

Assume $\lim_{x \to a} f(x) = L$ and $\lim_{x \to a} g(x) = M$, where $L$ and $M$ are finite real numbers. Then:

**Sum/Difference Law**
$$\lim_{x \to a} \left[ f(x) \pm g(x) \right] = L \pm M$$

**Constant Multiple Law**
$$\lim_{x \to a} \left[ c \cdot f(x) \right] = c \cdot L$$

**Product Law**
$$\lim_{x \to a} \left[ f(x) \cdot g(x) \right] = L \cdot M$$

**Quotient Law** (requires $M \neq 0$)
$$\lim_{x \to a} \frac{f(x)}{g(x)} = \frac{L}{M}$$

**Power Law**
$$\lim_{x \to a} \left[ f(x) \right]^n = L^n$$

**Root Law** (requires $L \geq 0$ when $n$ is even)
$$\lim_{x \to a} \sqrt[n]{f(x)} = \sqrt[n]{L}$$

**Composition Law** (requires $g$ continuous at $L$)
$$\lim_{x \to a} g(f(x)) = g(L)$$

These laws are provable from the epsilon-delta definition of a limit. That derivation is standard in real analysis textbooks; this section treats the laws as established results rather than re-deriving them.

### Direct Substitution

For polynomial, rational (where the denominator is nonzero), and most elementary functions, the limit at a point equal to the function's value there:

$$\lim_{x \to a} f(x) = f(a)$$

**Example**

$$\lim_{x \to 2} (3x^2 - 5x + 1) = 3(2)^2 - 5(2) + 1 = 12 - 10 + 1 = 3$$

Direct substitution works because polynomials are continuous everywhere — a fact formally justified using the sum, product, and constant multiple laws applied repeatedly.

### Indeterminate Forms

Direct substitution sometimes produces expressions like $\frac{0}{0}$, $\frac{\infty}{\infty}$, $\infty - \infty$, or $0 \cdot \infty$. These are called **indeterminate forms** — they do not by themselves reveal the limit's value, and algebraic manipulation is needed to resolve them.

The $\frac{0}{0}$ form is the most common in introductory calculus and typically signals that $(x - a)$ is a common factor in both numerator and denominator.

### Technique 1: Factoring

When substitution gives $\frac{0}{0}$, factor the numerator and/or denominator to cancel the problematic term.

**Example**

$$\lim_{x \to 3} \frac{x^2 - 9}{x - 3}$$

Direct substitution gives $\frac{0}{0}$. Factoring the numerator:

$$\lim_{x \to 3} \frac{(x-3)(x+3)}{x - 3} = \lim_{x \to 3} (x + 3) = 6$$

The cancellation is valid because the limit considers values of $x$ near $3$ but not equal to $3$, where $x - 3 \neq 0$.

### Technique 2: Rationalizing

When a limit expression contains a square root that produces $\frac{0}{0}$, multiply by the conjugate to eliminate the radical.

**Example**

$$\lim_{x \to 0} \frac{\sqrt{x + 4} - 2}{x}$$

Multiply numerator and denominator by the conjugate $\sqrt{x+4} + 2$:

$$\lim_{x \to 0} \frac{(\sqrt{x+4} - 2)(\sqrt{x+4}+2)}{x(\sqrt{x+4}+2)} = \lim_{x \to 0} \frac{(x + 4) - 4}{x(\sqrt{x+4}+2)} = \lim_{x \to 0} \frac{x}{x(\sqrt{x+4}+2)}$$

$$= \lim_{x \to 0} \frac{1}{\sqrt{x+4}+2} = \frac{1}{4}$$

### Technique 3: Combining Fractions

When a limit expression involves the sum or difference of rational terms, combine them over a common denominator before simplifying.

**Example**

$$\lim_{x \to 0} \frac{1}{x}\left(\frac{1}{x+1} - 1\right)$$

Combine the inner fraction:

$$\lim_{x \to 0} \frac{1}{x} \cdot \frac{1 - (x+1)}{x+1} = \lim_{x \to 0} \frac{1}{x} \cdot \frac{-x}{x+1} = \lim_{x \to 0} \frac{-1}{x+1} = -1$$

### Technique 4: Simplifying Complex Fractions

For expressions with nested fractions, multiply through by the least common denominator to clear all inner fractions before evaluating.

### One-Sided Limits and Algebraic Techniques

Some functions require checking left-hand and right-hand limits separately, particularly piecewise functions or expressions with absolute values.

**Example**

$$\lim_{x \to 0} \frac{|x|}{x}$$

From the right ($x \to 0^+$): $\frac{x}{x} = 1$
From the left ($x \to 0^-$): $\frac{-x}{x} = -1$

Since the one-sided limits disagree, $\lim_{x \to 0} \frac{|x|}{x}$ does not exist.

### The Squeeze Theorem

When direct algebraic manipulation is impractical, bounding the function between two other functions with known, equal limits can resolve the limit.

If $g(x) \leq f(x) \leq h(x)$ for all $x$ near $a$ (except possibly at $a$), and:

$$\lim_{x \to a} g(x) = \lim_{x \to a} h(x) = L$$

then:

$$\lim_{x \to a} f(x) = L$$

This is the standard technique for proving $\lim_{x \to 0} \frac{\sin x}{x} = 1$, a limit that appears frequently when deriving trigonometric derivatives.

### Visualizing the Squeeze Theorem

<svg viewBox="0 0 600 360" xmlns="http://www.w3.org/2000/svg">
  <text x="300" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Squeeze Theorem (svg_diagram)</text>
  
  <line x1="60" y1="300" x2="560" y2="300" stroke="#333" stroke-width="1.5"/>
  <line x1="300" y1="60" x2="300" y2="320" stroke="#333" stroke-width="1.5"/>
  <text x="565" y="304" font-size="12" fill="#333">x</text>
  <text x="290" y="55" font-size="12" fill="#333">y</text>

  <path d="M 100 90 Q 300 250 500 90" stroke="#c0392b" stroke-width="2" fill="none"/>
  <text x="500" y="80" font-size="12" fill="#c0392b">h(x)</text>

  <path d="M 100 280 Q 300 200 500 280" stroke="#2980b9" stroke-width="2" fill="none"/>
  <text x="500" y="295" font-size="12" fill="#2980b9">g(x)</text>

  <path d="M 100 220 Q 300 230 500 220" stroke="#27ae60" stroke-width="2.5" fill="none"/>
  <text x="500" y="215" font-size="12" fill="#27ae60">f(x)</text>

  <circle cx="300" cy="228" r="4" fill="#1a1a1a"/>
  <text x="310" y="220" font-size="12" fill="#1a1a1a">L</text>
  <line x1="300" y1="300" x2="300" y2="228" stroke="#999" stroke-width="1" stroke-dasharray="3,3"/>
  <text x="290" y="318" font-size="12" fill="#333">a</text>
</svg>

### Limits Involving Infinity

For rational functions as $x \to \infty$, divide numerator and denominator by the highest power of $x$ present in the denominator.

**Example**

$$\lim_{x \to \infty} \frac{3x^2 + 2x - 1}{5x^2 - x + 4}$$

Divide every term by $x^2$:

$$\lim_{x \to \infty} \frac{3 + \frac{2}{x} - \frac{1}{x^2}}{5 - \frac{1}{x} + \frac{4}{x^2}} = \frac{3 + 0 - 0}{5 - 0 + 0} = \frac{3}{5}$$

This technique directly parallels the analysis of how activation functions like sigmoid and softmax behave as inputs grow large, since both involve ratios that stabilize at infinity.

### Relevance to Machine Learning

**Key Points**

- Gradient derivations rely on limit laws to justify that derivative rules (product rule, quotient rule, chain rule) hold in general — these rules are themselves consequences of applying limit laws to the difference quotient.
- Numerical stability techniques in ML (e.g., the log-sum-exp trick used in softmax computation) are conceptually related to the algebraic manipulation used to resolve indeterminate forms, since both aim to avoid computing $\frac{0}{0}$ or $\frac{\infty}{\infty}$-like instabilities in floating-point arithmetic. [Inference] The precise numerical behavior depends on implementation and hardware, so specific stability guarantees should not be assumed without testing.
- Activation functions such as sigmoid, tanh, and softmax are analyzed for asymptotic behavior using the same infinite-limit division technique shown above.
- The squeeze theorem's logical structure (bounding an unknown quantity between two known ones) parallels bounding arguments used in convergence proofs for optimization algorithms, though the specific proofs differ substantially in complexity. [Inference]

### Worked Example: Full Algebraic Resolution

$$\lim_{x \to 4} \frac{\sqrt{x} - 2}{x - 4}$$

Direct substitution: $\frac{0}{0}$, indeterminate.

Rationalize using conjugate $\sqrt{x} + 2$:

$$\lim_{x \to 4} \frac{(\sqrt{x}-2)(\sqrt{x}+2)}{(x-4)(\sqrt{x}+2)} = \lim_{x \to 4} \frac{x - 4}{(x-4)(\sqrt{x}+2)} = \lim_{x \to 4} \frac{1}{\sqrt{x}+2} = \frac{1}{4}$$

This particular limit is structurally identical to the definition of the derivative of $\sqrt{x}$ at $x = 4$, foreshadowing the connection between limits and differentiation covered in the next topic.

### Common Pitfalls

- Canceling terms before confirming they are valid factors (not just visually similar terms)
- Applying the quotient law when the denominator's limit is zero, which is not permitted directly and requires a different technique
- Assuming a limit exists because the function is defined at that point — continuity must be separately verified, not assumed
- Treating indeterminate forms like $\frac{0}{0}$ as automatically equal to $0$ or $1$ rather than recognizing they require further work

### Next Steps

- The formal epsilon-delta definition of a limit
- Continuity: formal definition and types of discontinuities
- The Intermediate Value Theorem and its applications
- Limits at infinity and horizontal/vertical asymptotes
- Introduction to derivatives via the limit definition
- L'Hôpital's Rule for indeterminate forms (typically introduced after derivatives)
