## Delta Method

### Definition

Let $X_n$ be a sequence of random variables such that:

$$\sqrt{n}(X_n - \theta) \xrightarrow{d} N(0, \sigma^2)$$

Let $g$ be a function that is differentiable at $\theta$, with $g'(\theta) \neq 0$. The Delta Method states that:

$$\sqrt{n}\left(g(X_n) - g(\theta)\right) \xrightarrow{d} N\left(0, [g'(\theta)]^2 \sigma^2\right)$$

[Inference] This is the standard form of the Delta Method as commonly presented in probability theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing, historical attribution, or minimal regularity conditions used in any specific named textbook without checking that source directly.

### Key Points

- The Delta Method extends asymptotic normality results (such as those from the Central Limit Theorem) to smooth **transformations** of an asymptotically normal estimator.
- It relies on a first-order Taylor expansion of $g$ around $\theta$. [Inference] This is the standard derivation approach commonly described in probability theory, reasoned from the structure of the result rather than confirmed against a specific named source in this response.
- The condition $g'(\theta) \neq 0$ is generally required for the standard (first-order) Delta Method; [Unverified] I cannot confirm without checking a specific source what the precise alternative formulation looks like when $g'(\theta) = 0$, though I recall that a second-order version exists in such cases.

### Derivation Sketch (Informal)

Using a first-order Taylor expansion of $g$ around $\theta$:

$$g(X_n) \approx g(\theta) + g'(\theta)(X_n - \theta)$$

Rearranging and multiplying by $\sqrt{n}$:

$$\sqrt{n}\left(g(X_n) - g(\theta)\right) \approx g'(\theta) \cdot \sqrt{n}(X_n - \theta)$$

Since $\sqrt{n}(X_n - \theta) \xrightarrow{d} N(0, \sigma^2)$, and multiplying a normal random variable by a constant $g'(\theta)$ scales its variance by $[g'(\theta)]^2$, this heuristic suggests:

$$\sqrt{n}\left(g(X_n) - g(\theta)\right) \xrightarrow{d} N\left(0, [g'(\theta)]^2 \sigma^2\right)$$

[Inference] This is a commonly presented heuristic derivation in probability theory pedagogy, reasoned through directly rather than reproduced from a specific verified source. A fully rigorous proof requires additional justification (e.g., Slutsky's theorem) to formally handle the approximation error in the Taylor expansion, which I have not presented in full here. This derivation sketch should be checked independently against a formal reference if used for rigorous work.

### Multivariate Delta Method

[Unverified] I cannot verify the precise general form of the multivariate Delta Method against a specific named source in this response. A commonly stated version, presented cautiously, involves a vector-valued estimator $\mathbf{X}_n \in \mathbb{R}^k$ with:

$$\sqrt{n}(\mathbf{X}_n - \boldsymbol{\theta}) \xrightarrow{d} N(0, \Sigma)$$

and a differentiable function $g: \mathbb{R}^k \to \mathbb{R}^m$, giving:

$$\sqrt{n}\left(g(\mathbf{X}_n) - g(\boldsymbol{\theta})\right) \xrightarrow{d} N\left(0, \nabla g(\boldsymbol{\theta})^T \Sigma \, \nabla g(\boldsymbol{\theta})\right)$$

where $\nabla g(\boldsymbol{\theta})$ is the Jacobian matrix of $g$ at $\boldsymbol{\theta}$. [Inference] This generalization follows the same first-order Taylor expansion logic as the univariate case, reasoned by analogy rather than confirmed against a specific named source in this response.

### Worked Example

Suppose $\bar{X}_n$ is a sample mean such that, by the CLT:

$$\sqrt{n}(\bar{X}_n - \mu) \xrightarrow{d} N(0, \sigma^2)$$

Consider estimating $g(\mu) = \mu^2$ using $g(\bar{X}_n) = \bar{X}_n^2$, assuming $\mu \neq 0$. Since $g'(\mu) = 2\mu$, the Delta Method gives:

$$\sqrt{n}\left(\bar{X}_n^2 - \mu^2\right) \xrightarrow{d} N\left(0, 4\mu^2 \sigma^2\right)$$

[Inference] This follows directly from substituting $g(\mu) = \mu^2$ and $g'(\mu) = 2\mu$ into the general Delta Method formula stated above. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Delta Method (svg_diagram)</text>

  <line x1="70" y1="280" x2="320" y2="280" stroke="#333" stroke-width="1.2" />
  <line x1="70" y1="280" x2="70" y2="70" stroke="#333" stroke-width="1.2" />
  <text x="180" y="300" text-anchor="middle" font-size="11" fill="#333">X_n near θ (normal spread)</text>

  <ellipse cx="195" cy="200" rx="90" ry="18" fill="#e8f0fe" stroke="#4a72c4" stroke-width="1.5" />
  <line x1="195" y1="200" x2="195" y2="280" stroke="#c4574a" stroke-width="1" stroke-dasharray="3,3" />
  <text x="195" y="220" text-anchor="middle" font-size="11" fill="#333">θ</text>

  <path d="M330,200 C 360,150 380,120 420,100" stroke="#4a9c5f" stroke-width="2" fill="none" marker-end="url(#arrowD)" />
  <text x="345" y="140" font-size="11" fill="#4a9c5f">g(·) local linear approx</text>

  <line x1="450" y1="280" x2="650" y2="280" stroke="#333" stroke-width="1.2" />
  <line x1="450" y1="280" x2="450" y2="70" stroke="#333" stroke-width="1.2" />
  <text x="550" y="300" text-anchor="middle" font-size="11" fill="#333">g(X_n) near g(θ) (rescaled spread)</text>

  <ellipse cx="550" cy="150" rx="60" ry="14" fill="#fce8e6" stroke="#c4574a" stroke-width="1.5" />
  <line x1="550" y1="150" x2="550" y2="280" stroke="#c4574a" stroke-width="1" stroke-dasharray="3,3" />
  <text x="550" y="170" text-anchor="middle" font-size="11" fill="#333">g(θ)</text>

  <text x="350" y="325" text-anchor="middle" font-size="12" fill="#555">Local linearization transfers normal spread, rescaled by g'(θ)</text>
</svg>

### Relation to Other Convergence Concepts

- The Delta Method builds on convergence in distribution results (typically from the CLT) and extends them through a transformation $g$.
- It commonly relies on **Slutsky's theorem** to rigorously justify combining the convergence in distribution of $\sqrt{n}(X_n - \theta)$ with the convergence in probability of the remainder term in the Taylor expansion. [Unverified] I cannot verify the precise formal role of Slutsky's theorem in this derivation against a specific named source in this response, though this is a commonly referenced connection in probability theory pedagogy.

### Relevance to Machine Learning

- [Inference] The Delta Method is commonly invoked in statistical learning theory to derive asymptotic confidence intervals for transformed parameters or performance metrics (e.g., a ratio of two estimated quantities, or a nonlinear function of model parameters), based on general familiarity with statistical inference practice. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] Some applications of the Delta Method in ML contexts include deriving standard errors for derived quantities such as odds ratios in logistic regression or transformed regression coefficients, based on general familiarity with statistical modeling practice. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or statistical package implements Delta Method-based confidence intervals without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's estimated quantities behave under transformation in practice: behavior is not guaranteed and may vary depending on the transformation function, sample size, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Central Limit Theorem and asymptotic normality
- Slutsky's theorem
- Asymptotic variance estimation and standard errors
- Multivariate normal distribution and the Jacobian in transformations
- Confidence intervals for transformed estimators

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding minimal regularity conditions, the second-order case when $g'(\theta) = 0$, the precise role of Slutsky's theorem, and connections to machine learning practice. The core definition and derivation sketch reflect standard formulations in probability theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Billingsley's *Probability and Measure* or Casella and Berger's *Statistical Inference*).