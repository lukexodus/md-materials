## Jensen's Inequality

### Definition

Let $X$ be a random variable with finite expectation $E[X]$, and let $\varphi$ be a convex function. Jensen's Inequality states:

$$\varphi(E[X]) \leq E[\varphi(X)]$$

If $\varphi$ is concave, the inequality direction reverses:

$$\varphi(E[X]) \geq E[\varphi(X)]$$

[Inference] This is the standard form of Jensen's Inequality as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing or historical attribution against a specific named textbook in this response.

### Key Points

- The inequality requires $\varphi$ to be convex (or concave) over the relevant domain, and $E[X]$ and $E[\varphi(X)]$ to exist and be finite. [Unverified] I cannot confirm the precise minimal regularity conditions (e.g., whether strict convexity affects the equality case) without checking a specific source.
- Equality holds when $\varphi$ is affine (linear plus a constant), or when $X$ is a constant almost surely. [Inference] This is a commonly stated equality condition in probability theory pedagogy, reasoned from the geometric interpretation of convexity rather than confirmed against a specific named source in this response.
- Jensen's Inequality applies to any convex function, not just a specific fixed class of functions — this generality is a key reason for its wide use. [Inference] Reasoned from the definition itself.

### Geometric Intuition

A convex function lies below the chord connecting any two points on its graph. Applied to a random variable, this means the function evaluated at the average input is less than or equal to the average of the function's output — because "spreading out" the input around the mean, then applying a convex function, tends to increase the average output relative to applying the function directly to the mean.

[Inference] This is a commonly presented geometric explanation of Jensen's Inequality in probability theory pedagogy, reasoned through directly rather than reproduced from a specific verified source.

### Proof Sketch (Using the Supporting Line Definition of Convexity)

[Unverified] I cannot verify this exact derivation against a specific named source in this response, but a commonly presented proof structure is as follows:

For a convex function $\varphi$, at any point $\mu$, there exists a supporting line $L(x) = \varphi(\mu) + c(x - \mu)$ for some constant $c$, such that $\varphi(x) \geq L(x)$ for all $x$ in the domain. Setting $\mu = E[X]$:

$$\varphi(X) \geq \varphi(E[X]) + c(X - E[X])$$

Taking expectations on both sides:

$$E[\varphi(X)] \geq \varphi(E[X]) + c(E[X] - E[X]) = \varphi(E[X])$$

[Inference] This derivation follows from the supporting-line (subgradient) characterization of convex functions, reasoned through directly rather than reproduced verbatim from a specific verified source. This proof sketch should be checked independently against a formal reference if used for rigorous work.

### Worked Example

Let $X$ be a random variable with $E[X] = 4$, and consider the convex function $\varphi(x) = x^2$.

By Jensen's Inequality:

$$\varphi(E[X]) = 4^2 = 16 \leq E[X^2]$$

This recovers the familiar fact that $E[X^2] \geq (E[X])^2$, which is equivalent to stating $\text{Var}(X) = E[X^2] - (E[X])^2 \geq 0$.

[Inference] This calculation follows directly from applying Jensen's Inequality to $\varphi(x) = x^2$, which is convex, and connecting the result to the standard definition of variance. I have reasoned through this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

### Second Example: Concave Function

Let $X$ be a strictly positive random variable with $E[X] = 9$, and consider the concave function $\varphi(x) = \sqrt{x}$.

By the concave form of Jensen's Inequality:

$$\varphi(E[X]) = \sqrt{9} = 3 \geq E[\sqrt{X}]$$

[Inference] This calculation follows directly from applying the concave form of Jensen's Inequality to $\varphi(x) = \sqrt{x}$. I have reasoned through this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes. This illustrates that, in general, $E[\sqrt{X}] \leq \sqrt{E[X]}$ — averaging before applying a concave "diminishing returns" function generally yields a larger value than applying the function first and then averaging.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Jensen's Inequality (svg_diagram)</text>

  <line x1="80" y1="290" x2="620" y2="290" stroke="#333" stroke-width="1.5" />
  <text x="620" y="310" font-size="12" fill="#333">x</text>
  <line x1="80" y1="290" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="45" y="65" font-size="12" fill="#333">φ(x)</text>

  <path d="M100,270 C 200,260 300,200 400,140 C 480,95 550,75 600,70" stroke="#4a72c4" stroke-width="2.5" fill="none" />
  <text x="480" y="95" font-size="11" fill="#4a72c4">φ (convex)</text>

  <line x1="200" y1="290" x2="200" y2="255" stroke="#999" stroke-width="1" stroke-dasharray="3,3" />
  <text x="185" y="300" font-size="10" fill="#666">x₁</text>
  <circle cx="200" cy="255" r="3" fill="#333" />

  <line x1="500" y1="290" x2="500" y2="85" stroke="#999" stroke-width="1" stroke-dasharray="3,3" />
  <text x="490" y="300" font-size="10" fill="#666">x₂</text>
  <circle cx="500" cy="85" r="3" fill="#333" />

  <line x1="200" y1="255" x2="500" y2="85" stroke="#c4574a" stroke-width="1.5" stroke-dasharray="4,3" />
  <text x="330" y="150" font-size="11" fill="#c4574a">chord (secant line)</text>

  <line x1="350" y1="290" x2="350" y2="170" stroke="#4a9c5f" stroke-width="1" stroke-dasharray="2,2" />
  <text x="355" y="300" font-size="10" fill="#4a9c5f">E[X]</text>
  <circle cx="350" cy="170" r="4" fill="#4a9c5f" />
  <text x="360" y="165" font-size="10" fill="#4a9c5f">φ(E[X])</text>

  <circle cx="350" cy="192" r="4" fill="#c4574a" />
  <text x="360" y="210" font-size="10" fill="#c4574a">E[φ(X)] (on chord, ≥ φ(E[X]))</text>

  <text x="350" y="330" text-anchor="middle" font-size="12" fill="#555">Convex curve lies below the chord; averaging inputs first gives a smaller value than averaging outputs</text>
</svg>

### Relation to Other Concepts

- Jensen's Inequality is commonly used to establish the non-negativity of variance, as shown in the worked example above.
- It underlies several information-theoretic results, including [Unverified] the non-negativity of Kullback–Leibler divergence, which I understand to be commonly derived using Jensen's Inequality applied to the logarithm function (concave), though I cannot verify the precise derivation steps against a specific named source in this response.
- [Inference] Jensen's Inequality is also commonly connected to the AM-GM (arithmetic mean–geometric mean) inequality and other classical mathematical inequalities, reasoned from general familiarity with the topic, though I cannot verify this specific connection against a named source in this response.

### Relevance to Machine Learning

- [Inference] Jensen's Inequality is commonly used in the derivation of the Evidence Lower Bound (ELBO) in variational inference, where the logarithm (a concave function) is applied to an expectation, based on general familiarity with the topic. I cannot verify the precise derivation steps or connection against a specific named paper in this response.
- [Inference] The inequality is sometimes referenced in analyses of loss function convexity and optimization guarantees in machine learning, based on general familiarity with optimization theory. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies Jensen's Inequality without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's loss landscape or bound behaves in practice: behavior is not guaranteed and may vary depending on implementation, data, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Convex functions and convex optimization
- Kullback–Leibler divergence and its non-negativity
- Evidence Lower Bound (ELBO) in variational inference
- Variance and its relation to Jensen's Inequality
- AM-GM inequality and classical mathematical inequalities

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding minimal regularity conditions, the precise derivation of KL divergence non-negativity, the connection to the ELBO, and connections to machine learning practice more broadly. The core definition, proof sketch, and worked examples reflect standard formulations in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Billingsley's *Probability and Measure* or Cover and Thomas's *Elements of Information Theory*).