## Conditional Probability

### Definition

Conditional probability quantifies the probability of an event occurring given that another event is known to have occurred. For events $A$ and $B$ with $P(B) > 0$:

$$P(A \mid B) = \frac{P(A \cap B)}{P(B)}$$

This reads as "the probability of $A$ given $B$." The condition $P(B) > 0$ is required because division by zero is undefined; conditional probability is not defined when conditioning on a zero-probability event under this formula.

### Rearranging: The Multiplication Rule

From the definition above, the joint probability of two events can be expressed as:

$$P(A \cap B) = P(A \mid B) \cdot P(B) = P(B \mid A) \cdot P(A)$$

This generalizes to $n$ events via the **chain rule of probability**:

$$P(A_1 \cap A_2 \cap \cdots \cap A_n) = P(A_1) \cdot P(A_2 \mid A_1) \cdot P(A_3 \mid A_1 \cap A_2) \cdots P(A_n \mid A_1 \cap \cdots \cap A_{n-1})$$

[Inference] This chain rule form is a direct algebraic consequence of repeated application of the definition of conditional probability. Each factorization step follows from the same single definition applied iteratively; it is not a separate axiom.

### Visualizing Conditional Probability (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Conditional Probability P(A|B) (svg_diagram)</text>

  <rect x="40" y="50" width="560" height="230" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="55" y="72" font-size="14" fill="#333" font-style="italic">Ω</text>

  <circle cx="260" cy="180" r="100" fill="#4a90d9" fill-opacity="0.25" stroke="#2c5f8a" stroke-width="2" />
  <circle cx="380" cy="180" r="100" fill="#e07a3f" fill-opacity="0.55" stroke="#a8531f" stroke-width="2" />

  <text x="190" y="130" font-size="15" fill="#123a5c" font-weight="bold">A</text>
  <text x="440" y="130" font-size="15" fill="#7a3610" font-weight="bold">B</text>
  <text x="300" y="185" font-size="12" fill="#1a1a1a" text-anchor="middle">A∩B</text>

  <text x="320" y="305" font-size="13" fill="#1a1a1a" text-anchor="middle">Restrict attention to B (dark region); ask what fraction is also A∩B</text>
</svg>

### Worked Example

**Example**

A standard deck of 52 cards. Draw one card.

- $A$ = "card is a King" — 4 Kings, so $P(A) = \tfrac{4}{52}$
- $B$ = "card is a face card" (Jack, Queen, King) — 12 face cards, so $P(B) = \tfrac{12}{52}$
- $A \cap B$ = "card is a King and a face card" = "card is a King" (since all Kings are face cards) = $\{4 \text{ Kings}\}$, so $P(A \cap B) = \tfrac{4}{52}$

$$P(A \mid B) = \frac{P(A \cap B)}{P(B)} = \frac{4/52}{12/52} = \frac{4}{12} = \frac{1}{3}$$

Interpretation: given that the drawn card is a face card, there is a $\tfrac{1}{3}$ probability it is specifically a King. This can be verified directly: among the 12 face cards, exactly 4 are Kings, so $\tfrac{4}{12} = \tfrac{1}{3}$, consistent with the formula result.

### Independence in Terms of Conditional Probability

Events $A$ and $B$ are **independent** if and only if:

$$P(A \mid B) = P(A) \quad \text{(equivalently, } P(B \mid A) = P(B)\text{, when defined)}$$

which is algebraically equivalent to:

$$P(A \cap B) = P(A) \cdot P(B)$$

[Inference] This equivalence follows from substituting $P(A \mid B) = P(A)$ into the definition of conditional probability and rearranging; it is a direct algebraic consequence, not an independently verified empirical claim. Independence is a distinct concept from mutual exclusivity — I cannot verify a general claim that these two concepts are commonly confused in practice without a survey or source to cite, so that framing is omitted here as unconfirmed.

### The Law of Total Probability (Preview)

If $B_1, B_2, \ldots, B_n$ form a partition of $\Omega$ (pairwise disjoint, exhaustive), then for any event $A$:

$$P(A) = \sum_{i=1}^{n} P(A \mid B_i) \cdot P(B_i)$$

[Unverified] The full derivation and worked treatment of this law, along with its role in Bayes' Theorem, is deferred to a dedicated topic; this statement is presented here only as a preview of an upcoming derivation and has not been independently re-derived step-by-step in this response.

### Relevance to Machine Learning

- **Naive Bayes classifiers** directly apply conditional probability and the chain rule to estimate $P(\text{class} \mid \text{features})$ from $P(\text{features} \mid \text{class})$ and $P(\text{class})$.
- **Sequence models** (e.g., autoregressive language models) factorize the joint probability of a sequence using the chain rule: $P(w_1, \ldots, w_n) = \prod_{i=1}^{n} P(w_i \mid w_1, \ldots, w_{i-1})$. [Inference] This factorization is a standard mathematical property of the chain rule applied to token sequences; it describes how the joint distribution is decomposed, not a claim about any specific model's internal implementation or accuracy of these estimates.
- **Conditional probability in evaluation metrics**: precision is $P(\text{actual positive} \mid \text{predicted positive})$, and recall is $P(\text{predicted positive} \mid \text{actual positive})$ — both are conditional probabilities defined over the joint distribution of predictions and ground truth.

### Common Pitfalls

- Confusing $P(A \mid B)$ with $P(B \mid A)$ — these are generally not equal; conflating them is sometimes referred to as the "prosecutor's fallacy" in applied contexts, though I cannot verify the origin or precise scope of that terminology without a citable source.
- Applying the conditional probability formula when $P(B) = 0$ — this is undefined under the standard definition given above.
- Assuming independence without verification — $P(A \cap B) = P(A)P(B)$ must be checked or assumed explicitly; it does not hold generically for arbitrary events.

This response contains labeled [Inference] and [Unverified] statements as noted inline; portions not labeled reflect standard mathematical derivations from the stated axioms and definitions.

**Related Topics**
- Bayes' Theorem
- Law of Total Probability (full derivation)
- Independence and Conditional Independence
- Naive Bayes Classifiers (applied ML context)
- Joint, Marginal, and Conditional Distributions
- Markov Chains and Sequential Dependence