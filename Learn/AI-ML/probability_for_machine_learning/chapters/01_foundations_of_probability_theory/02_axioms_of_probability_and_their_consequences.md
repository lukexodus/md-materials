## Axioms of Probability and Their Consequences

### Kolmogorov's Axioms

Given a probability space $(\Omega, \mathcal{F}, P)$, a probability measure $P: \mathcal{F} \to \mathbb{R}$ must satisfy three axioms, formalized by Andrey Kolmogorov:

**Axiom 1 (Non-negativity)**:

$$
P(A) \geq 0 \quad \text{for all } A \in \mathcal{F}
$$

**Axiom 2 (Normalization)**:

$$
P(\Omega) = 1
$$

**Axiom 3 (Countable Additivity)**: For any countable collection of pairwise disjoint events $A_1, A_2, A_3, \dots \in \mathcal{F}$ (i.e., $A_i \cap A_j = \emptyset$ for $i \neq j$):

$$
P\left(\bigcup_{i=1}^{\infty} A_i\right) = \sum_{i=1}^{\infty} P(A_i)
$$

These three axioms are the complete formal foundation from which all other probability rules are derived. [Unverified] Whether every applied ML text explicitly traces its probability rules back to these three axioms, versus stating rules like the addition or complement rule as given, is not something this document can confirm across sources.

### Immediate Consequences

The following results follow directly from the axioms via proof, not as separate assumptions.

**Probability of the empty set**:

$$
P(\emptyset) = 0
$$

[Inference] This follows because $\emptyset$ and $\Omega$ are disjoint and their union is $\Omega$; applying Axiom 3 gives $P(\Omega) = P(\Omega) + P(\emptyset)$, which forces $P(\emptyset) = 0$.

**Complement rule**: For any event $A$,

$$
P(A^c) = 1 - P(A)
$$

[Inference] This follows because $A$ and $A^c$ are disjoint and $A \cup A^c = \Omega$, so by Axiom 3, $P(A) + P(A^c) = P(\Omega) = 1$.

**Monotonicity**: If $A \subseteq B$, then

$$
P(A) \leq P(B)
$$

[Inference] This follows by decomposing $B = A \cup (B \setminus A)$, a disjoint union, giving $P(B) = P(A) + P(B \setminus A)$; since $P(B \setminus A) \geq 0$ by Axiom 1, $P(B) \geq P(A)$.

**Bounded range**: For any event $A$,

$$
0 \leq P(A) \leq 1
$$

[Inference] This follows from combining non-negativity (Axiom 1) with monotonicity, since $A \subseteq \Omega$ and $P(\Omega) = 1$.

### Finite Additivity (Special Case)

For a finite collection of pairwise disjoint events $A_1, \dots, A_n$:

$$
P\left(\bigcup_{i=1}^{n} A_i\right) = \sum_{i=1}^{n} P(A_i)
$$

[Inference] This is a special case of countable additivity (Axiom 3) obtained by setting $A_i = \emptyset$ for all indices beyond $n$, since $P(\emptyset) = 0$ does not affect the sum.

### Inclusion-Exclusion Principle (Addition Rule)

For two events that are not necessarily disjoint:

$$
P(A \cup B) = P(A) + P(B) - P(A \cap B)
$$

[Inference] This follows by decomposing $A \cup B$ into three disjoint parts — $A \cap B^c$, $A \cap B$, $B \cap A^c$ — applying Axiom 3 to sum their probabilities, and observing that $P(A) = P(A \cap B^c) + P(A \cap B)$ and $P(B) = P(B \cap A^c) + P(A \cap B)$, so the $P(A \cap B)$ term is subtracted once to avoid double-counting.

For three events, the generalized inclusion-exclusion form is:

$$
P(A \cup B \cup C) = P(A) + P(B) + P(C) - P(A \cap B) - P(A \cap C) - P(B \cap C) + P(A \cap B \cap C)
$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300">
<title>Inclusion-exclusion for two events (svg_diagram)</title>
<rect x="0" y="0" width="600" height="300" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Inclusion-Exclusion Principle (svg_diagram)</text>

<circle cx="230" cy="150" r="80" fill="#a3c9f9" fill-opacity="0.55" stroke="#2b6cb0" stroke-width="2" />
<circle cx="330" cy="150" r="80" fill="#f9a3a3" fill-opacity="0.55" stroke="#c0392b" stroke-width="2" />

<text x="180" y="110" font-size="13" font-family="sans-serif" fill="#111111">A</text>
<text x="390" y="110" font-size="13" font-family="sans-serif" fill="#111111">B</text>
<text x="270" y="155" font-size="12" font-family="sans-serif" fill="#111111">A ∩ B</text>

<text x="300" y="260" font-size="14" text-anchor="middle" font-family="monospace" fill="#111111">P(A∪B) = P(A) + P(B) − P(A∩B)</text>
</svg>

### Bonferroni Inequality (Union Bound)

For any finite collection of events $A_1, \dots, A_n$ (not necessarily disjoint):

$$
P\left(\bigcup_{i=1}^{n} A_i\right) \leq \sum_{i=1}^{n} P(A_i)
$$

[Inference] This follows from inclusion-exclusion, since the subtracted intersection terms are non-negative, meaning the pairwise-disjoint sum always upper-bounds the true union probability.

This inequality, often called the **union bound**, is used extensively in machine learning theory — for example, in PAC learning generalization bounds, where it upper-bounds the probability that at least one hypothesis in a finite hypothesis class has poor performance.

### Continuity of Probability Measures

For an increasing sequence of events $A_1 \subseteq A_2 \subseteq A_3 \subseteq \dots$:

$$
P\left(\lim_{n \to \infty} A_n\right) = \lim_{n \to \infty} P(A_n)
$$

[Unverified] This continuity property is a standard theorem in measure-theoretic probability texts, but this document cannot verify which specific applied ML sources rely on it explicitly, since it is more commonly invoked in theoretical statistics or convergence proofs than in typical ML coursework.

### Worked Example

Let $\Omega$ represent a dataset of emails, with:
- $A$ = event that an email contains the word "free" ($P(A) = 0.3$)
- $B$ = event that an email is spam ($P(B) = 0.4$)
- $P(A \cap B) = 0.25$

Using the addition rule:

$$
P(A \cup B) = 0.3 + 0.4 - 0.25 = 0.45
$$

So the probability that an email either contains "free" or is spam (or both) is $0.45$.

Using the complement rule, the probability that an email is **not** spam:

$$
P(B^c) = 1 - 0.4 = 0.6
$$

### Relevance to Machine Learning

- The **union bound** derived from these axioms underlies generalization error bounds in statistical learning theory (e.g., PAC learning, VC-dimension based bounds).
- The **complement rule** is used routinely when computing probabilities of "at least one" events, such as the probability of at least one false positive across multiple independent classifier trials.
- **Normalization** ($P(\Omega) = 1$) directly corresponds to the requirement that predicted probability distributions (e.g., softmax outputs) sum to 1 over the label space.
- [Inference] The requirement that probabilities be non-negative and bounded between 0 and 1 is a likely reason activation functions like softmax and sigmoid are designed to output values in $[0,1]$ when probabilistic interpretation is intended, though this document cannot confirm this was the explicit historical motivation in every case.

### Common Pitfalls

- Applying the simple addition rule $P(A \cup B) = P(A) + P(B)$ without checking disjointness, which overcounts $P(A \cap B)$.
- Assuming finite additivity extends automatically to uncountable unions — the axioms only guarantee countable additivity, not additivity over arbitrary (uncountable) collections.
- Treating the union bound as a tight estimate rather than an upper bound; it can be loose when events overlap significantly.

**Related Topics**
- Conditional probability and Bayes' theorem
- Independence of events
- Law of total probability
- Random variables and probability distributions
- PAC learning bounds and the union bound in generalization theory
- Measure-theoretic probability (Borel sets, Lebesgue measure)