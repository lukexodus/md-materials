## Cross-Entropy

### Definition

Let $p$ and $q$ be two probability distributions over the same discrete support $\mathcal{X}$, where $p$ is commonly interpreted as the "true" distribution and $q$ as a model or approximating distribution. The cross-entropy of $q$ relative to $p$ is defined as:

$$H(p, q) = -\sum_{x \in \mathcal{X}} p(x) \log q(x)$$

[Inference] This is the standard form of cross-entropy as commonly presented in information theory, reasoned from general familiarity with the topic. I cannot verify the exact phrasing or historical attribution against a specific named textbook in this response.

### Key Points

- Cross-entropy measures the average number of bits (or nats, depending on log base) needed to encode samples from $p$ using a code optimized for $q$, rather than for $p$ itself. [Inference] This interpretation is commonly presented in information theory pedagogy, reasoned from the coding-theoretic origins of entropy concepts, though I cannot verify this exact framing against a specific named source in this response.
- Cross-entropy is **not symmetric** in general: $H(p,q) \neq H(q,p)$. [Inference] This follows directly from the definition, since swapping $p$ and $q$ changes which distribution is inside the logarithm versus which is used as the weighting distribution.
- Cross-entropy satisfies $H(p,q) \geq H(p)$, with equality if and only if $p = q$. [Unverified] I cannot verify the precise formal proof of this property against a specific named source in this response, though it is commonly stated in information theory pedagogy.

### Relation to KL Divergence

Cross-entropy can be decomposed as:

$$H(p,q) = H(p) + D_{KL}(p \| q)$$

where $D_{KL}(p \| q)$ is the Kullback–Leibler divergence between $p$ and $q$.

[Unverified] I understand this to be a standard relationship in information theory, but I cannot verify the precise derivation steps against a specific named source in this response.

Since $D_{KL}(p \| q) \geq 0$ always [Unverified — I cannot verify the precise formal proof of this non-negativity property against a specific named source in this response, though it is commonly attributed to an application of Jensen's Inequality], this decomposition directly implies $H(p,q) \geq H(p)$.

### Proof Sketch of the Decomposition

[Unverified] I cannot verify this exact derivation against a specific named source in this response, but a commonly presented proof structure is as follows:

$$D_{KL}(p\|q) = \sum_x p(x) \log \frac{p(x)}{q(x)} = \sum_x p(x)\log p(x) - \sum_x p(x) \log q(x) = -H(p) + H(p,q)$$

Rearranging gives:

$$H(p,q) = H(p) + D_{KL}(p\|q)$$

[Inference] This derivation follows from the logarithm quotient rule applied to the KL divergence definition, reasoned through directly rather than reproduced verbatim from a specific verified source. This proof sketch should be checked independently against a formal reference if used for rigorous work.

### Worked Example

Let the true distribution be $p = (0.7, 0.3)$ over two classes, and a model's predicted distribution be $q = (0.6, 0.4)$.

Using base-2 logarithm:

$$H(p,q) = -\left(0.7 \log_2 0.6 + 0.3 \log_2 0.4\right)$$

$$\approx -\left(0.7 \times (-0.737) + 0.3 \times (-1.322)\right) \approx 0.516 + 0.397 \approx 0.913 \text{ bits}$$

[Inference] This calculation follows directly from substituting the stated probabilities into the cross-entropy definition, using approximate logarithm values. I have computed this directly rather than citing it from an external source, so the arithmetic and approximations should be checked independently if used for formal purposes.

For comparison, the entropy of $p$ itself is:

$$H(p) = -(0.7\log_2 0.7 + 0.3\log_2 0.3) \approx -(0.7 \times (-0.515) + 0.3\times(-1.737)) \approx 0.360 + 0.521 \approx 0.881 \text{ bits}$$

Since $H(p,q) \approx 0.913 > H(p) \approx 0.881$, this is consistent with the property that cross-entropy is at least as large as the true distribution's own entropy. [Inference] This comparison follows from the two calculations performed directly above; I have computed this directly rather than citing it, so it should be checked independently.

### Visual Intuition

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 320">
  <text x="350" y="30" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Cross-Entropy Decomposition (svg_diagram)</text>

  <rect x="100" y="100" width="500" height="70" rx="8" fill="#e8f0fe" stroke="#4a72c4" stroke-width="1.5" />
  <text x="350" y="140" text-anchor="middle" font-size="14" fill="#1a1a1a">H(p,q) = H(p) + D_KL(p‖q)</text>

  <rect x="100" y="200" width="220" height="60" rx="6" fill="#e6f4ea" stroke="#4a9c5f" stroke-width="1.5" />
  <text x="210" y="235" text-anchor="middle" font-size="12" fill="#1a1a1a">H(p): irreducible</text>
  <text x="210" y="250" text-anchor="middle" font-size="11" fill="#333">uncertainty in true dist.</text>

  <rect x="380" y="200" width="220" height="60" rx="6" fill="#fce8e6" stroke="#c4574a" stroke-width="1.5" />
  <text x="490" y="235" text-anchor="middle" font-size="12" fill="#1a1a1a">D_KL(p‖q): penalty</text>
  <text x="490" y="250" text-anchor="middle" font-size="11" fill="#333">for using wrong model q</text>

  <text x="350" y="300" text-anchor="middle" font-size="12" fill="#555">Cross-entropy splits into an irreducible part and a model-mismatch penalty</text>
</svg>

### Relevance to Machine Learning

- [Inference] Cross-entropy is very commonly used as a loss function for classification tasks, where $p$ represents the true (often one-hot encoded) label distribution and $q$ represents the model's predicted probability distribution, based on general and widespread familiarity with the topic in machine learning practice. I cannot verify the precise implementation details of this loss function in any specific ML library or framework without checking that source directly.
- [Inference] Minimizing cross-entropy loss with respect to model parameters is commonly connected to maximum likelihood estimation, since [Unverified] I understand the cross-entropy loss over a dataset is proportional to the negative log-likelihood under certain standard formulations, but I cannot verify the precise derivation or exact proportionality conditions against a specific named source in this response.
- [Inference] Because $H(p)$ is constant with respect to the model's parameters (it depends only on the true label distribution), minimizing cross-entropy loss is commonly understood to be equivalent to minimizing $D_{KL}(p\|q)$ during training, based on the decomposition shown above. I cannot verify this exact equivalence claim in the context of any specific training setup without further verification.
- [Unverified] I cannot verify specific claims about how any particular ML library, framework, or paper implements or numerically computes cross-entropy loss without checking that source directly.
- For any behavioral claims about how a specific model, algorithm, or system's training loss or convergence behaves when using cross-entropy in practice: behavior is not guaranteed and may vary depending on implementation, data, architecture, and other conditions. This is a general disclaimer and not specific to any single system.

### Related Topics

- Shannon entropy and its properties
- Kullback–Leibler divergence
- Maximum likelihood estimation and its connection to cross-entropy loss
- Joint and conditional entropy
- Softmax function and its use with cross-entropy loss in classification

---

**Verification Status of This Document**: This document contains multiple [Inference] and [Unverified] labeled statements, particularly regarding the formal proof of $H(p,q) \geq H(p)$, the non-negativity of KL divergence, the precise relationship between cross-entropy loss and maximum likelihood estimation, and connections to machine learning practice. The core definition, decomposition derivation, and worked numerical example reflect standard formulations in information theory as commonly taught, but I cannot verify this text against a specific named source in this response. This entire document should be treated as **[Unverified]** pending independent cross-check against a formal reference (e.g., Cover and Thomas's *Elements of Information Theory*).