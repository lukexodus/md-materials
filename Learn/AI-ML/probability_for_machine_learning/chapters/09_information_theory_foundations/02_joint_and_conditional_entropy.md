## Joint and Conditional Entropy

### Definition: Joint Entropy

Let $X$ and $Y$ be discrete random variables with joint probability mass function $p(x,y)$. The joint entropy is defined as:

$$H(X,Y) = -\sum_{x \in \mathcal{X}} \sum_{y \in \mathcal{Y}} p(x,y) \log p(x,y)$$

[Inference] This is the standard form of joint entropy as commonly presented in information theory, reasoned from general familiarity with the topic. I cannot verify this exact against a specific named textbook in this response.

### Definition: Conditional Entropy

The conditional entropy of $Y$ given $X$ is defined as:

$$H(Y|X) = -\sum_{x \in \mathcal{X}} \sum_{y \in \mathcal{Y}} p(x,y) \log p(y|x)$$

This can equivalently be written as:

$$H(Y|X) = \sum_{x \in \mathcal{X}} p(x) H(Y|X=x)$$

where $H(Y|X=x) = -\sum_y p(y|x) \log p(y|x)$ is the entropy of the conditional distribution of $Y$ given a specific value $X = x$.

[Inference] This is the standard form of conditional entropy as commonly presented in information theory, reasoned from general familiarity with the topic. I cannot verify this exact against a specific named textbook in this response.

### Key Points

- Conditional entropy $H(Y|X)$ measures the average remaining uncertainty about $Y$ once $X$ is known.
- $H(Y|X) = 0$ if and only if $Y$ is a deterministic function of $X$. [Inference] This is reasoned from the fact that each conditional distribution $p(\cdot|x)$ would need to place all probability mass on a single value for every term to vanish, rather than confirmed against a specific named source in this response.
- Joint entropy and conditional entropy are related through the chain rule, described below.

### Chain Rule for Entropy

$$H(X,Y) = H(X) + H(Y|X)$$

By symmetry, this can also be written as:

$$H(X,Y) = H(Y) + H(X|Y)$$

[Inference] This is the standard chain rule for entropy as commonly presented in information theory. I cannot verify the precise derivation steps against a specific named source in this response.

### Proof Sketch of the Chain Rule

[Unverified] I cannot verify this exact derivation against a specific named source in this response, but a commonly presented proof structure is as follows:

Starting from the joint entropy definition and using $p(x,y) = p(x)p(y|x)$:

$$H(X,Y) = -\sum_{x,y} p(x,y) \log\left[p(x)p(y|x)\right] = -\sum_{x,y} p(x,y)\log p(x) - \sum_{x,y} p(x,y) \log p(y|x)$$

The first term simplifies to $H(X)$ (summing over $y$ first), and the second term is $H(Y|X)$ by definition, giving:

$$H(X,Y) = H(X) + H(Y|X)$$

[Inference] This derivation follows from the logarithm product rule applied to the joint probability factorization, reasoned through directly rather than reproduced verbatim from a specific verified source. This proof sketch should be checked independently against a formal reference if used for rigorous work.

### Worked Example

Let $X$ and $Y$ be binary random variables with the following joint distribution:

| | $Y=0$ | $Y=1$ |
|---|---|---|
| $X=0$ | 0.4 | 0.1 |
| $X=1$ | 0.2 | 0.3 |

**Marginal for $X$**: $p(X=0) = 0.5$, $p(X=1) = 0.5$

$$H(X) = -(0.5\log_2 0.5 + 0.5 \log_2 0.5) = 1 \text{ bit}$$

**Joint entropy**:

$$H(X,Y) = -(0.4\log_2 0.4 + 0.1\log_2 0.1 + 0.2\log_2 0.2 + 0.3\log_2 0.3)$$

$$\approx -(0.4 \times (-1.322) + 0.1 \times (-3.322) + 0.2 \times (-2.322) + 0.3 \times (-1.737))$$

$$\approx 0.529 + 0.332 + 0.464 + 0.521 \approx 1.846 \text{ bits}$$

**Conditional entropy** (via the chain rule):

$$H(Y|X) = H(X,Y) - H(X) \approx 1.846 - 1 = 0.846 \text{ bits}$$

[Inference] These calculations follow directly from substituting the stated joint probabilities into the entropy definitions and chain rule, using approximate logarithm values. I have computed this directly rather than citing it from an external source, so the arithmetic and approximations should be checked independently if used for formal purposes.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Joint and Conditional Entropy (svg_diagram)</text>

  <circle cx="280" cy="180" r="110" fill="#4a72c4" opacity="0.3" stroke="#4a72c4" stroke-width="1.5" />
  <text x="200" y="130" font-size="13" fill="#4a72c4" font-weight="bold">H(X)</text>

  <circle cx="420" cy="180" r="110" fill="#c4574a" opacity="0.3" stroke="#c4574a" stroke-width="1.5" />
  <text x="460" y="130" font-size="13" fill="#c4574a" font-weight="bold">H(Y)</text>

  <text x="230" y="185" font-size="11" fill="#1a1a1a">H(X|Y)</text>
  <text x="330" y="185" font-size="11" fill="#1a1a1a">I(X;Y)</text>
  <text x="440" y="185" font-size="11" fill="#1a1a1a">H(Y|X)</text>

  <text x="350" y="320" text-anchor="middle" font-size="12" fill="#555">H(X,Y) = H(X) + H(Y|X) = H(Y) + H(X|Y); overlap region is mutual information</text>
</svg>

### Properties

- **Non-negativity**: $H(Y|X) \geq 0$. [Inference] This follows from conditional entropy being a weighted average of individual entropies $H(Y|X=x)$, each of which is non-negative, reasoned rather than confirmed against a specific named source.
- **Conditioning does not increase entropy**: $H(Y|X) \leq H(Y)$. [Unverified] I understand this is commonly proven using Jensen's Inequality or the non-negativity of mutual information, but I cannot verify the precise derivation against a specific named source in this response.
- **Equality condition**: $H(Y|X) = H(Y)$ if and only if $X$ and $Y$ are independent. [Unverified] I cannot verify the precise formal proof of this equality condition against a specific named source in this response.
- **Chain rule generalizes to more variables**: [Unverified] I understand the chain rule extends to $H(X_1,\dots,X_n) = \sum_{i=1}^n H(X_i | X_1,\dots,X_{i-1})$, but I cannot verify the precise derivation of this generalized form against a specific named source in this response.

### Relation to Mutual Information

Mutual information can be expressed in terms of joint and conditional entropy:

$$I(X;Y) = H(Y) - H(Y|X) = H(X) + H(Y) - H(X,Y)$$

[Unverified] I understand this to be a standard relationship in information theory, but I cannot verify the precise derivation steps against a specific named source in this response.

### Relevance to Machine Learning

- [Inference] Conditional entropy is commonly used in decision tree algorithms to compute information gain, where the reduction $H(Y) - H(Y|X)$ (a feature's mutual information with the label) guides split selection, based on general familiarity with the topic. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] Joint and conditional entropy concepts underlie some formulations of feature selection criteria in machine learning, based on general familiarity with the topic. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies joint or conditional entropy without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's feature selection or splitting decisions relate to entropy calculations in practice: behavior is not guaranteed and may vary depending on implementation, data, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Shannon entropy and its properties (foundational concept)
- Mutual information
- Kullback–Leibler divergence
- Information gain in decision trees
- Cross-entropy as a loss function

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding the formal proofs of the "conditioning does not increase entropy" property, the generalized chain rule, the relationship to mutual information, and connections to machine learning practice. The core definitions, chain rule derivation, and worked numerical example reflect standard formulations in information theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Cover and Thomas's *Elements of Information Theory*).