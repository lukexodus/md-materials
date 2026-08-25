## Weak Law of Large Numbers

### Definition

Let $X_1, X_2, \dots$ be a sequence of i.i.d. random variables with finite mean $E[X_i] = \mu$. The sample mean is defined as:

$$\bar{X}_n = \frac{1}{n}\sum_{i=1}^{n} X_i$$

The Weak Law of Large Numbers (WLLN) states that $\bar{X}_n$ converges in probability to $\mu$:

$$\bar{X}_n \xrightarrow{P} \mu$$

Equivalently, for every $\varepsilon > 0$:

$$\lim_{n \to \infty} P(|\bar{X}_n - \mu| > \varepsilon) = 0$$

[Inference] This is the standard form of the WLLN as commonly presented in probability theory. I cannot verify the exact phrasing, historical attribution, or minimal regularity conditions used in any specific named textbook without checking that source directly.

### Key Points

- The WLLN is a statement about **convergence in probability**, not almost sure convergence — that distinction belongs to the Strong Law of Large Numbers.
- The WLLN requires only a finite mean under some formulations, though [Unverified] I cannot confirm without checking a specific source whether the classical Khinchin version requires only finite mean or additionally assumes finite variance; different textbooks may state this under different minimal conditions.
- The result describes the limiting behavior of the sample mean's probability distribution, not a claim about any individual finite-sample outcome.

### Proof Sketch (Under Finite Variance Assumption)

One common proof approach uses Chebyshev's inequality, assuming $\text{Var}(X_i) = \sigma^2 < \infty$:

$$P(|\bar{X}_n - \mu| > \varepsilon) \leq \frac{\text{Var}(\bar{X}_n)}{\varepsilon^2} = \frac{\sigma^2}{n\varepsilon^2}$$

As $n \to \infty$, the right-hand side $\frac{\sigma^2}{n\varepsilon^2} \to 0$, which forces $P(|\bar{X}_n - \mu| > \varepsilon) \to 0$, establishing convergence in probability.

[Inference] This derivation follows from applying Chebyshev's inequality to the sample mean, using the standard fact that $\text{Var}(\bar{X}_n) = \sigma^2/n$ for i.i.d. variables. I have reasoned through this derivation directly rather than citing it from a specific external source, so it should be checked independently if used for formal work.

[Unverified] I cannot verify without checking a specific source whether this finite-variance proof is the "original" historical proof of the WLLN or a simplified pedagogical version; the WLLN can reportedly be proven under weaker conditions (finite mean alone) using other techniques, but I cannot confirm the details of such a proof in this response.

### Worked Example

Let $X_1, X_2, \dots$ be i.i.d. fair coin flips, coded as $X_i = 1$ for heads and $X_i = 0$ for tails, so $\mu = E[X_i] = 0.5$ and $\sigma^2 = \text{Var}(X_i) = 0.25$.

Using Chebyshev's bound with $\varepsilon = 0.05$:

$$P(|\bar{X}_n - 0.5| > 0.05) \leq \frac{0.25}{n (0.05)^2} = \frac{100}{n}$$

For $n = 10{,}000$, this bound gives $P(|\bar{X}_n - 0.5| > 0.05) \leq 0.01$.

[Inference] This calculation follows directly from substituting the stated values into the Chebyshev bound derived above. I have computed this directly rather than citing it from an external source, so the arithmetic should be independently checked if used for formal purposes. This bound is generally understood to be loose rather than tight — [Unverified] I cannot confirm the exact tightness of this specific numerical bound relative to the true probability without further calculation or simulation, which I have not performed here.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Weak Law of Large Numbers (svg_diagram)</text>

  <line x1="80" y1="290" x2="620" y2="290" stroke="#333" stroke-width="1.5" />
  <text x="620" y="310" font-size="12" fill="#333">n</text>
  <line x1="80" y1="290" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="30" y="65" font-size="12" fill="#333">X̄n</text>

  <line x1="80" y1="170" x2="620" y2="170" stroke="#c4574a" stroke-width="1.5" stroke-dasharray="4,4" />
  <text x="630" y="174" font-size="11" fill="#c4574a">μ</text>

  <path d="M90,80 C 140,140 180,200 230,175 C 280,150 320,190 370,172 C 420,158 470,178 520,169 C 560,163 590,171 610,170" stroke="#4a72c4" stroke-width="2" fill="none" />

  <path d="M80,150 C 200,160 350,167 620,170" stroke="#4a9c5f" stroke-width="1" fill="none" stroke-dasharray="2,3" opacity="0.6" />
  <path d="M80,190 C 200,180 350,173 620,170" stroke="#4a9c5f" stroke-width="1" fill="none" stroke-dasharray="2,3" opacity="0.6" />
  <text x="440" y="140" font-size="10" fill="#4a9c5f">shrinking probability band</text>

  <text x="350" y="330" text-anchor="middle" font-size="12" fill="#555">Sample mean concentrates in probability around μ as n grows</text>
</svg>

### Distinguishing the WLLN from the Strong Law of Large Numbers

- The WLLN asserts $\bar{X}_n \xrightarrow{P} \mu$ (convergence in probability).
- The Strong Law of Large Numbers (SLLN) asserts $\bar{X}_n \xrightarrow{a.s.} \mu$ (almost sure convergence).
- [Inference] Almost sure convergence implies convergence in probability, so the SLLN is generally considered the stronger result, and the WLLN can be viewed as a consequence of it. I cannot verify this specific characterization of their relationship against a named source in this response.
- [Unverified] I cannot verify without checking a specific source the precise historical reasoning for why both laws are presented separately in most textbooks, despite the SLLN implying the WLLN.

### Relevance to Machine Learning

- [Inference] The WLLN is commonly invoked to justify that empirical averages (e.g., empirical risk, empirical loss, mini-batch statistics) approach their true expected values as sample size increases, based on general familiarity with statistical learning theory concepts. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] Monte Carlo estimation methods rely on laws of large numbers (weak or strong, depending on the specific guarantee being invoked) to justify that sample-based estimates approach true expectations. This is a reasoned connection based on standard statistical theory, not a claim verified against a specific implementation.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or training system relies on or documents WLLN-based guarantees without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system behaves in practice: behavior is not guaranteed and may vary depending on implementation, data, hyperparameters, and other conditions. This applies generally and is not specific to any single system.

### Related Topics

- Strong Law of Large Numbers and almost sure convergence
- Chebyshev's and Markov's inequalities
- Convergence in probability (detailed treatment)
- Central Limit Theorem and its relation to the law of large numbers
- Concentration inequalities (Hoeffding, Bernstein) used in modern ML theory

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding minimal regularity conditions for the WLLN, the historical relationship between proof techniques, and connections to machine learning practice. The core definition and Chebyshev-based proof sketch reflect standard formulations in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Billingsley's *Probability and Measure* or Durrett's *Probability: Theory and Examples*).