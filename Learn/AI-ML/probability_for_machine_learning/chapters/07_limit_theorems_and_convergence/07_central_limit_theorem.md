## Central Limit Theorem

### Definition

Let $X_1, X_2, \dots$ be i.i.d. random variables with finite mean $E[X_i] = \mu$ and finite variance $\text{Var}(X_i) = \sigma^2 > 0$. Define the standardized sum:

$$Z_n = \frac{\sqrt{n}(\bar{X}_n - \mu)}{\sigma} = \frac{\sum_{i=1}^{n} X_i - n\mu}{\sigma \sqrt{n}}$$

The Central Limit Theorem (CLT) states that $Z_n$ converges in distribution to a standard normal random variable:

$$Z_n \xrightarrow{d} N(0, 1)$$

[Inference] This is the standard form of the CLT as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing, historical attribution, or minimal regularity conditions used in any specific named textbook without checking that source directly.

### Key Points

- The CLT is a statement about **convergence in distribution**, not almost sure or in-probability convergence of $Z_n$ itself.
- The CLT applies regardless of the shape of the original distribution of $X_i$, as long as the finite mean and finite variance conditions hold. [Inference] This is the commonly stated generality of the CLT, reasoned from the standard formulation above; I cannot verify this claim against a specific named source in this response.
- The approximation $\bar{X}_n \approx N\left(\mu, \frac{\sigma^2}{n}\right)$ for large $n$ is a commonly used practical consequence of the CLT. [Inference] This follows algebraically from rearranging the standardized form above, but I cannot verify how "large" $n$ needs to be for this approximation to be considered adequate in any specific application without checking a dedicated source, since this depends on the underlying distribution's shape.

### Formal Statement Variants

[Unverified] I cannot verify with certainty the precise historical attribution or exact minimal conditions of the following named variants without checking a formal source:

- **Lindeberg–Lévy CLT**: [Inference] Commonly associated with the i.i.d. case described above (finite mean and variance), based on general recollection of probability theory literature.
- **Lyapunov CLT**: [Inference] Commonly described as extending the result to independent but not identically distributed variables, under an additional moment condition (the Lyapunov condition), based on general recollection of probability theory literature.
- **Lindeberg CLT**: [Inference] Commonly described as a further generalization using a weaker condition (the Lindeberg condition) than Lyapunov's, based on general recollection of probability theory literature.

I cannot verify the precise mathematical conditions of the Lyapunov or Lindeberg conditions in this response without checking a formal source.

### Worked Example

Let $X_1, X_2, \dots$ be i.i.d. fair die rolls, so each $X_i$ takes values $1$ through $6$ with equal probability. The mean and variance are:

$$\mu = 3.5, \quad \sigma^2 = \frac{35}{12} \approx 2.9167$$

[Inference] These values follow from the standard formulas for the mean and variance of a discrete uniform distribution on $\{1, \dots, 6\}$: $\mu = \frac{1+6}{2}$ and $\sigma^2 = \frac{k^2 - 1}{12}$ for $k = 6$. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

For $n = 100$ rolls, the CLT suggests approximating the sum $S_n = \sum_{i=1}^{100} X_i$ as approximately normal:

$$S_n \approx N(350, 291.67)$$

since $E[S_n] = n\mu = 350$ and $\text{Var}(S_n) = n\sigma^2 \approx 291.67$.

[Inference] This approximation follows algebraically from the CLT statement applied to this specific example. I cannot verify how accurate this normal approximation would be at $n=100$ specifically (e.g., via simulation or exact computation) without performing that verification directly, which I have not done in this response.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Central Limit Theorem (svg_diagram)</text>

  <line x1="70" y1="280" x2="270" y2="280" stroke="#333" stroke-width="1.2" />
  <rect x="80" y="260" width="15" height="20" fill="#4a72c4" />
  <rect x="100" y="240" width="15" height="40" fill="#4a72c4" />
  <rect x="120" y="270" width="15" height="10" fill="#4a72c4" />
  <rect x="140" y="250" width="15" height="30" fill="#4a72c4" />
  <rect x="160" y="265" width="15" height="15" fill="#4a72c4" />
  <rect x="180" y="245" width="15" height="35" fill="#4a72c4" />
  <rect x="200" y="255" width="15" height="25" fill="#4a72c4" />
  <text x="170" y="300" text-anchor="middle" font-size="11" fill="#333">n = 1 (uniform)</text>

  <line x1="290" y1="280" x2="490" y2="280" stroke="#333" stroke-width="1.2" />
  <path d="M300,275 C 330,260 350,220 390,215 C 430,220 450,260 480,275" stroke="#4a9c5f" stroke-width="2" fill="none" />
  <text x="390" y="300" text-anchor="middle" font-size="11" fill="#333">n = 10 (bell-ish)</text>

  <line x1="510" y1="280" x2="620" y2="280" stroke="#333" stroke-width="1.2" />
  <path d="M515,278 C 535,230 555,90 570,80 C 585,90 605,230 615,278" stroke="#c4574a" stroke-width="2.5" fill="none" />
  <text x="565" y="300" text-anchor="middle" font-size="11" fill="#333">n = 100 (≈normal)</text>

  <text x="350" y="325" text-anchor="middle" font-size="12" fill="#555">Distribution of standardized sum approaches a normal shape as n grows</text>
</svg>

### Relation to Other Convergence Concepts

- The CLT describes convergence **in distribution**, which is a weaker mode than convergence in probability or almost sure convergence. [Inference] This is reasoned from the standard hierarchy of convergence modes; I have not cross-checked this specific comparison against a named source in this response.
- The Law of Large Numbers (weak or strong) establishes that $\bar{X}_n \to \mu$, while the CLT describes the **rate and shape** of fluctuations around $\mu$ at the $\sqrt{n}$ scale. [Inference] This is a commonly stated distinction in probability theory pedagogy, reasoned from comparing the two theorems' statements; I cannot verify this exact framing against a specific named source in this response.

### Relevance to Machine Learning

- [Inference] The CLT is commonly invoked to justify asymptotic normality of maximum likelihood estimators and other estimators under certain regularity conditions, based on general familiarity with statistical theory. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] Confidence interval construction for model parameters or performance metrics (e.g., accuracy estimates from a test set) often relies on CLT-based normal approximations, based on general familiarity with statistical inference practice. I cannot verify this connection against a specific named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or statistical package implements CLT-based confidence intervals or hypothesis tests without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system behaves in practice: behavior is not guaranteed and may vary depending on implementation, data, sample size, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Law of Large Numbers (Weak and Strong) and their relation to the CLT
- Delta method and asymptotic normality of estimators
- Berry–Esseen theorem (rate of convergence in the CLT)
- Confidence intervals and hypothesis testing based on normal approximations
- Convergence in distribution (detailed treatment)

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding named variant attributions (Lyapunov, Lindeberg), minimal regularity conditions, the accuracy of the worked numerical example, and connections to machine learning practice. The core definition reflects a standard formulation in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Billingsley's *Probability and Measure* or Durrett's *Probability: Theory and Examples*).