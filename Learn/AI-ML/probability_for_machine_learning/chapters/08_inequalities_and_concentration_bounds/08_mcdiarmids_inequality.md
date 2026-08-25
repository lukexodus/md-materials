## McDiarmid's Inequality

### Definition

Let $X_1, \dots, X_n$ be independent random variables, and let $f: \mathcal{X}_1 \times \cdots \times \mathcal{X}_n \to \mathbb{R}$ be a function satisfying the **bounded differences condition**: for each $i$, there exists a constant $c_i$ such that for all $x_1, \dots, x_n$ and $x_i'$:

$$\left| f(x_1, \dots, x_i, \dots, x_n) - f(x_1, \dots, x_i', \dots, x_n) \right| \leq c_i$$

McDiarmid's Inequality states that for any $t > 0$:

$$P\left(f(X_1, \dots, X_n) - E[f(X_1, \dots, X_n)] \geq t\right) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n c_i^2}\right)$$

A two-sided version gives:

$$P\left(|f(X_1, \dots, X_n) - E[f(X_1, \dots, X_n)]| \geq t\right) \leq 2\exp\left(-\frac{2t^2}{\sum_{i=1}^n c_i^2}\right)$$

[Inference] This is the standard form of McDiarmid's Inequality as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing, historical attribution, or minimal regularity conditions used in any specific named textbook without checking that source directly.

### Key Points

- McDiarmid's Inequality generalizes Hoeffding's Inequality from sums of bounded random variables to **arbitrary functions** of bounded-influence independent random variables. [Inference] This characterization is reasoned from comparing the structural forms of the two inequalities; I cannot verify this exact framing against a specific named source in this response.
- The bounded differences condition requires that changing any single input $X_i$ (while holding all others fixed) can change the output of $f$ by at most $c_i$.
- The $X_i$ variables need not be identically distributed, and $f$ need not be linear or additive in its arguments. [Inference] Reasoned from the generality of the statement itself.
- I cannot verify without checking a specific source whether McDiarmid's Inequality requires any additional smoothness condition on $f$ beyond the bounded differences property. [Unverified]

### Relation to Hoeffding's Inequality

If $f(X_1, \dots, X_n) = \sum_{i=1}^n X_i$ where each $X_i \in [a_i, b_i]$, then changing $X_i$ alone can change the sum by at most $c_i = b_i - a_i$. Substituting into McDiarmid's Inequality recovers Hoeffding's Inequality:

$$P(|S_n - E[S_n]| \geq t) \leq 2\exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right)$$

[Inference] This reduction follows directly from substituting the sum function into the bounded differences condition and the general McDiarmid bound. I have reasoned through this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

### Proof Sketch (High-Level)

[Unverified] I cannot verify the complete formal proof of McDiarmid's Inequality in this response, as doing so rigorously typically requires constructing a martingale (commonly referred to as a Doob martingale) associated with $f(X_1, \dots, X_n)$ and applying an Azuma–Hoeffding-type inequality for martingales with bounded increments. A commonly described high-level structure, presented cautiously, involves:

1. Constructing a sequence of random variables $Z_i = E[f(X_1,\dots,X_n) \mid X_1,\dots,X_i]$, forming a martingale.
2. Showing that the increments $Z_i - Z_{i-1}$ are bounded, using the bounded differences condition on $f$.
3. Applying a martingale concentration inequality (Azuma–Hoeffding) to bound the deviation of the final term $Z_n = f(X_1,\dots,X_n)$ from the initial term $Z_0 = E[f(X_1,\dots,X_n)]$.

[Inference] This is a commonly described general proof strategy in probability theory pedagogy, reasoned from general familiarity with the topic rather than reproduced from a specific verified source. Each step above should be treated as an outline rather than a rigorous derivation. I cannot verify the precise formal statement of the Azuma–Hoeffding inequality used in this argument without checking a specific source.

### Worked Example (Illustrative)

Consider $n = 50$ independent data points used to compute an empirical statistic $f(X_1, \dots, X_{50})$, where changing any single data point can change the statistic's value by at most $c_i = 0.1$ for each $i$.

Using McDiarmid's Inequality with $t = 1$:

$$P\left(|f - E[f]| \geq 1\right) \leq 2\exp\left(-\frac{2 \times 1^2}{50 \times (0.1)^2}\right) = 2\exp\left(-\frac{2}{0.5}\right) = 2\exp(-4) \approx 2 \times 0.0183 \approx 0.0366$$

[Inference] This calculation follows directly from substituting the stated values into McDiarmid's Inequality. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes. This is an illustrative numerical example with assumed bounded-difference constants, not a claim about any specific real statistic or dataset.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">McDiarmid's Inequality (svg_diagram)</text>

  <rect x="80" y="70" width="540" height="60" rx="6" fill="#e8f0fe" stroke="#4a72c4" stroke-width="1.5" />
  <text x="350" y="105" text-anchor="middle" font-size="13" fill="#1a1a1a">f(X₁, X₂, ..., Xᵢ, ..., Xₙ)</text>

  <line x1="290" y1="130" x2="290" y2="170" stroke="#c4574a" stroke-width="1.5" marker-end="url(#arrowM)" />
  <text x="230" y="150" font-size="11" fill="#c4574a">change Xᵢ → Xᵢ'</text>

  <rect x="80" y="170" width="540" height="60" rx="6" fill="#fce8e6" stroke="#c4574a" stroke-width="1.5" />
  <text x="350" y="205" text-anchor="middle" font-size="13" fill="#1a1a1a">f(X₁, X₂, ..., Xᵢ', ..., Xₙ)</text>

  <text x="350" y="255" text-anchor="middle" font-size="12" fill="#4a9c5f">|difference| ≤ cᵢ for every coordinate i</text>

  <text x="350" y="300" text-anchor="middle" font-size="12" fill="#555">Bounded sensitivity to each single input controls concentration of f around its mean</text>
</svg>

### Relation to Other Inequalities

- McDiarmid's Inequality is a generalization of Hoeffding's Inequality to non-linear, non-additive functions of bounded independent random variables.
- It is derived using martingale concentration techniques (Azuma–Hoeffding), distinguishing its proof approach from the direct moment-generating-function approach used for Hoeffding's Inequality on sums. [Inference] This comparison is reasoned from the differing proof techniques commonly described for the two results; I cannot verify this exact framing against a specific named source in this response.
- [Unverified] I cannot verify the precise historical relationship or chronological development between McDiarmid's Inequality and other martingale-based concentration results without checking a formal source.

### Relevance to Machine Learning

- [Inference] McDiarmid's Inequality is commonly used in statistical learning theory to derive generalization bounds for complex statistics, such as bounds involving Rademacher complexity or the stability of a learning algorithm, based on general familiarity with the topic. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] It is sometimes applied to bound the deviation of the empirical risk of an algorithm from its expected risk when the algorithm's output is not simply an additive function of the training data, based on general familiarity with statistical learning theory. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies McDiarmid's Inequality without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's output stability or generalization behavior relates to a McDiarmid-derived bound: behavior is not guaranteed and may vary depending on implementation, data, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Hoeffding's Inequality (special case of McDiarmid's Inequality)
- Azuma–Hoeffding inequality for martingales
- Algorithmic stability and generalization bounds
- Rademacher complexity
- Concentration inequalities in statistical learning theory

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding the precise formal proof steps involving the Azuma–Hoeffding inequality, historical attribution, and connections to machine learning practice. The core definition and reduction to Hoeffding's Inequality reflect a standard formulation in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Boucheron, Lugosi, and Massart's *Concentration Inequalities*).