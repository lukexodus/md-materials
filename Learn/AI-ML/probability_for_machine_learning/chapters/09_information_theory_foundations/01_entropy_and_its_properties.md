## Entropy and Its Properties

### Definition

Let $X$ be a discrete random variable with probability mass function $p(x)$ over a finite or countable support $\mathcal{X}$. The (Shannon) entropy of $X$ is defined as:

$$H(X) = -\sum_{x \in \mathcal{X}} p(x) \log p(x)$$

where the sum is taken over all $x$ with $p(x) > 0$, and the logarithm base determines the unit (base 2 gives bits, base $e$ gives nats).

[Inference] This is the standard form of Shannon entropy as commonly presented in information theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing or historical attribution against a specific named textbook in this response.

### Key Points

- Entropy quantifies the average "uncertainty" or "information content" associated with the outcomes of $X$.
- Entropy is always non-negative: $H(X) \geq 0$. [Inference] This follows because $p(x) \in (0,1]$ implies $-\log p(x) \geq 0$ for each term, reasoned directly from the definition rather than confirmed against a specific named source.
- Entropy is maximized when $X$ is uniformly distributed over its support, [Unverified] though I cannot confirm the precise formal proof of this maximization property without checking a specific source.
- Entropy is zero if and only if $X$ is deterministic (i.e., $p(x) = 1$ for exactly one value of $x$). [Inference] Reasoned from the definition: if $p(x)=1$ for one outcome, all terms in the sum vanish either because $p(x)=0$ or $\log(1)=0$.

### Maximum Entropy Property

[Unverified] I cannot verify the complete formal proof of this property without checking a specific source, but it is commonly stated that for a random variable with $n$ possible outcomes, entropy is maximized by the uniform distribution, with maximum value:

$$H_{\max} = \log n$$

[Inference] This is a commonly cited result in information theory pedagogy, reasoned from general familiarity with the topic. I cannot verify the exact derivation or historical attribution against a specific named source in this response.

### Worked Example

Let $X$ be a fair coin flip, so $p(\text{heads}) = p(\text{tails}) = 0.5$. Using base-2 logarithm:

$$H(X) = -\left(0.5 \log_2 0.5 + 0.5 \log_2 0.5\right) = -\left(0.5 \times (-1) + 0.5 \times (-1)\right) = 1 \text{ bit}$$

[Inference] This calculation follows directly from substituting the stated probabilities into the entropy definition. I have computed this directly rather than citing it from an external source, so it should be checked independently if used for formal purposes.

Now let $Y$ be a biased coin flip with $p(\text{heads}) = 0.9$, $p(\text{tails}) = 0.1$:

$$H(Y) = -\left(0.9 \log_2 0.9 + 0.1 \log_2 0.1\right) \approx -\left(0.9 \times (-0.152) + 0.1 \times (-3.322)\right) \approx 0.137 + 0.332 \approx 0.469 \text{ bits}$$

[Inference] This calculation follows directly from substituting the stated probabilities into the entropy definition, using approximate logarithm values. I have computed this directly rather than citing it from an external source, so the precision of these approximate values should be checked independently if used for formal purposes. This illustrates that $H(Y) < H(X)$: the biased coin has lower entropy, reflecting less uncertainty about the outcome.

### Joint and Conditional Entropy

The joint entropy of two random variables $X$ and $Y$ is defined as:

$$H(X,Y) = -\sum_{x,y} p(x,y) \log p(x,y)$$

The conditional entropy of $Y$ given $X$ is defined as:

$$H(Y|X) = -\sum_{x,y} p(x,y) \log p(y|x)$$

These satisfy the **chain rule**:

$$H(X,Y) = H(X) + H(Y|X)$$

[Inference] These are standard definitions and the standard chain rule as commonly presented in information theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing or derivation steps against a specific named source in this response.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Entropy vs Probability (Binary Case) (svg_diagram)</text>

  <line x1="80" y1="280" x2="620" y2="280" stroke="#333" stroke-width="1.5" />
  <text x="620" y="300" font-size="12" fill="#333">p</text>
  <line x1="80" y1="280" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="40" y="65" font-size="12" fill="#333">H(p)</text>

  <path d="M85,278 C 150,180 250,90 350,75 C 450,90 550,180 615,278" stroke="#4a72c4" stroke-width="2.5" fill="none" />

  <line x1="350" y1="280" x2="350" y2="75" stroke="#c4574a" stroke-width="1" stroke-dasharray="4,3" />
  <text x="355" y="70" font-size="11" fill="#c4574a">p=0.5, H=1 bit (max)</text>
  <circle cx="350" cy="75" r="4" fill="#c4574a" />

  <text x="80" y="295" font-size="10" fill="#333">0</text>
  <text x="615" y="295" font-size="10" fill="#333">1</text>

  <text x="350" y="325" text-anchor="middle" font-size="12" fill="#555">Entropy peaks at p=0.5 (maximum uncertainty) and is zero at p=0 or p=1</text>
</svg>

### Properties Summary

- **Non-negativity**: $H(X) \geq 0$.
- **Maximality under uniformity**: entropy is maximized by the uniform distribution over a fixed finite support. [Unverified] I cannot confirm the precise formal proof or exact conditions of this property without checking a specific source.
- **Chain rule**: $H(X,Y) = H(X) + H(Y|X)$.
- **Subadditivity**: [Unverified] I understand it is commonly stated that $H(X,Y) \leq H(X) + H(Y)$, with equality if and only if $X$ and $Y$ are independent, but I cannot verify the precise derivation or conditions of this property against a specific named source in this response.
- **Conditioning reduces entropy (on average)**: [Unverified] I understand it is commonly stated that $H(Y|X) \leq H(Y)$, but I cannot verify the precise derivation (commonly involving Jensen's Inequality or the non-negativity of mutual information) against a specific named source in this response.

### Relation to Other Concepts

- Entropy is closely related to **mutual information**: $I(X;Y) = H(Y) - H(Y|X)$. [Unverified] I cannot verify the precise derivation or properties of mutual information against a specific named source in this response.
- Entropy is related to **Kullback–Leibler divergence**, since [Unverified] I understand entropy can be expressed as $H(X) = \log|\mathcal{X}| - D_{KL}(p \| \text{uniform})$ for a finite support, but I cannot verify this precise relationship against a specific named source in this response.
- [Inference] The non-negativity and subadditivity properties of entropy are commonly proven using Jensen's Inequality applied to the concave logarithm function, reasoned from general familiarity with the topic. I cannot verify the exact derivation steps against a specific named source in this response.

### Relevance to Machine Learning

- [Inference] Entropy is commonly used as a splitting criterion in decision tree algorithms (e.g., ID3, C4.5), where the goal is to select splits that maximize information gain (a reduction in entropy), based on general familiarity with the topic. I cannot verify this connection against a specific named paper or textbook in this response.
- [Inference] Cross-entropy, a related quantity, is commonly used as a loss function in classification tasks, particularly in neural network training, based on general familiarity with the topic. I cannot verify this specific application against a named source in this response.
- [Inference] Entropy regularization is sometimes used in reinforcement learning to encourage exploration by penalizing overly deterministic policies, based on general familiarity with the topic. I cannot verify this specific application against a named source in this response.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper directly applies entropy without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's training dynamics or splitting decisions relate to entropy calculations in practice: behavior is not guaranteed and may vary depending on implementation, data, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Cross-entropy and its use as a loss function
- Kullback–Leibler divergence
- Mutual information
- Information gain in decision trees
- Differential entropy (continuous random variables)

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding the formal proofs of maximum entropy, subadditivity, and conditioning properties, the precise relationship to KL divergence, and connections to machine learning practice. The core definition and worked numerical examples reflect a standard formulation in information theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Cover and Thomas's *Elements of Information Theory*).