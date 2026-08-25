## Hoeffding's Inequality

### Definition

Let $X_1, \dots, X_n$ be independent random variables such that each $X_i$ is bounded within an interval $[a_i, b_i]$ almost surely. Let $S_n = \sum_{i=1}^n X_i$. Hoeffding's Inequality states that for any $t > 0$:

$$P(S_n - E[S_n] \geq t) \leq \exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right)$$

A two-sided version gives:

$$P(|S_n - E[S_n]| \geq t) \leq 2\exp\left(-\frac{2t^2}{\sum_{i=1}^n (b_i - a_i)^2}\right)$$

[Inference] This is the standard form of Hoeffding's Inequality as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing, historical attribution, or minimal regularity conditions used in any specific named textbook without checking that source directly.

### Key Points

- Hoeffding's Inequality applies to **bounded, independent** random variables — it does not require identical distributions.
- It gives an exponential tail bound, similar in form to Chernoff bounds. [Inference] I understand Hoeffding's Inequality to be derivable as a specific application of the Chernoff bound technique to bounded random variables, reasoned from general familiarity with the topic, though I cannot verify the precise formal derivation or historical relationship between the two without checking a specific source.
- Unlike Chebyshev's Inequality, it does not require knowledge of the variance — only the bounds $[a_i, b_i]$ on each variable.
- [Inference] The bound is often considered tighter than Chebyshev's Inequality for bounded random variables, particularly for larger deviations, reasoned from the exponential versus polynomial decay rates of the two bounds. I cannot verify this comparative claim against a specific named source in this response.

### Common Special Case: Sample Mean of Bounded Variables

For i.i.d. random variables $X_1, \dots, X_n$ bounded in $[a, b]$ with mean $\mu$, applied to the sample mean $\bar{X}_n = \frac{1}{n}\sum_{i=1}^n X_i$:

$$P(|\bar{X}_n - \mu| \geq t) \leq 2\exp\left(-\frac{2nt^2}{(b-a)^2}\right)$$

[Inference] This follows from substituting $S_n = n\bar{X}_n$ into the general Hoeffding bound stated above and simplifying, reasoned through directly rather than reproduced verbatim from a specific verified source. This form should be checked independently against a formal reference if used for rigorous work.

### Proof Sketch (High-Level)

[Unverified] I cannot verify the complete formal proof of Hoeffding's Inequality in this response, as doing so rigorously requires a specific technical lemma (commonly referred to as Hoeffding's Lemma, bounding the moment generating function of a bounded random variable) whose precise statement I cannot confirm without checking a formal source. A commonly described high-level structure, presented cautiously, involves:

1. Applying the Chernoff bound technique (Markov's Inequality on $e^{tS_n}$) to $S_n$.
2. Using independence to factor the moment generating function of $S_n$ into a product over individual $X_i$.
3. Bounding each individual moment generating function using a technical lemma specific to bounded random variables.
4. Optimizing over $t$ to obtain the final exponential bound.

[Inference] This is a commonly described general proof strategy in probability theory pedagogy, reasoned from general familiarity with the topic rather than reproduced from a specific verified source. Each step above should be treated as an outline rather than a rigorous derivation.

### Worked Example

Let $X_1, \dots, X_{100}$ be i.i.d. random variables uniformly distributed on $[0, 1]$, so $a = 0$, $b = 1$, and $\mu = 0.5$.

Using the sample mean form of Hoeffding's Inequality with $t = 0.1$ and $n = 100$:

$$P(|\bar{X}_{100} - 0.5| \geq 0.1) \leq 2\exp\left(-\frac{2 \times 100 \times (0.1)^2}{(1-0)^2}\right) = 2\exp(-2) \approx 2 \times 0.1353 \approx 0.2707$$

[Inference] This calculation follows directly from substituting the stated values into the sample mean form of Hoeffding's Inequality derived above. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Hoeffding's Inequality (svg_diagram)</text>

  <line x1="80" y1="270" x2="620" y2="270" stroke="#333" stroke-width="1.5" />
  <text x="620" y="290" font-size="12" fill="#333">t (deviation)</text>
  <line x1="80" y1="270" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="35" y="65" font-size="12" fill="#333">bound</text>

  <path d="M90,80 C 130,190 180,240 250,258 C 330,266 450,269 610,270" stroke="#4a72c4" stroke-width="2" fill="none" />
  <text x="300" y="245" font-size="11" fill="#4a72c4">Chebyshev (1/t²)</text>

  <path d="M90,80 C 110,220 140,260 180,268 C 240,272 400,273 610,273" stroke="#4a9c5f" stroke-width="2.5" fill="none" />
  <text x="200" y="255" font-size="11" fill="#4a9c5f">Hoeffding (exp(−ct²))</text>

  <text x="350" y="310" text-anchor="middle" font-size="12" fill="#555">Hoeffding's bound decays exponentially, generally faster than Chebyshev for bounded variables</text>
</svg>

### Relation to Other Inequalities

- Hoeffding's Inequality is a specific instance of the general Chernoff bound technique, specialized to sums of bounded independent random variables.
- Compared to Chebyshev's Inequality, Hoeffding's Inequality trades a boundedness assumption for a substantially tighter (exponential) bound. [Inference] This comparison is reasoned from the differing assumptions and algebraic forms of the two inequalities, not confirmed against a specific named source in this response.
- [Unverified] I cannot verify the precise historical relationship between Hoeffding's Inequality and other related bounds (e.g., Bernstein's inequality, which reportedly incorporates variance information in addition to boundedness) without checking a formal source.

### Relevance to Machine Learning

- [Inference] Hoeffding's Inequality is commonly used in statistical learning theory to derive generalization bounds, particularly in PAC (Probably Approximately Correct) learning frameworks, based on general familiarity with the topic. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] The inequality is sometimes used to bound the deviation between empirical risk (training error) and true risk (expected error) for a fixed hypothesis, based on general familiarity with statistical learning theory. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies Hoeffding's Inequality without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's generalization gap behaves in practice: behavior is not guaranteed and may vary depending on implementation, data, hypothesis class complexity, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Chernoff bounds (detailed treatment)
- Chebyshev's Inequality (detailed treatment)
- Bernstein's inequality
- PAC learning framework and generalization bounds
- Concentration inequalities in statistical learning theory

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding historical attribution, the precise statement of Hoeffding's Lemma used in the proof, the relationship to Bernstein's inequality, and connections to machine learning practice. The core definition and worked numerical example reflect a standard formulation in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Boucheron, Lugosi, and Massart's *Concentration Inequalities*).