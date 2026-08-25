## Axioms of Probability

### Kolmogorov's Axioms

A probability measure $P$ is a function that assigns to each event $A$ in a σ-algebra $\mathcal{F}$ over sample space $\Omega$ a real number $P(A)$, subject to three axioms formalized by Andrey Kolmogorov.

**Axiom 1 — Non-negativity**

$$P(A) \geq 0 \quad \text{for all } A \in \mathcal{F}$$

**Axiom 2 — Normalization**

$$P(\Omega) = 1$$

**Axiom 3 — Countable Additivity**

For any countable sequence of pairwise disjoint events $A_1, A_2, A_3, \ldots$ (i.e., $A_i \cap A_j = \emptyset$ for $i \neq j$):

$$P\left(\bigcup_{i=1}^{\infty} A_i\right) = \sum_{i=1}^{\infty} P(A_i)$$

[Unverified] This formulation is standard in measure-theoretic treatments of probability and is widely attributed to Kolmogorov's 1933 monograph. The exact original notation and phrasing have not been checked against a primary source in this conversation, so the historical attribution should be verified independently if needed for citation purposes.

### Derived Properties (Theorems from the Axioms)

The following properties are logically derivable from the three axioms above.

**Probability of the empty set**

$$P(\emptyset) = 0$$

[Inference] This follows from Axiom 3 by treating $\emptyset$ as a disjoint union with itself, combined with Axiom 2; a full derivation is a standard exercise in introductory probability texts but is not reproduced step-by-step here.

**Complement rule**

$$P(A^c) = 1 - P(A)$$

**Monotonicity**

$$\text{If } A \subseteq B, \text{ then } P(A) \leq P(B)$$

**Bounded range**

$$0 \leq P(A) \leq 1 \quad \text{for all } A \in \mathcal{F}$$

**Inclusion-Exclusion (for two events)**

$$P(A \cup B) = P(A) + P(B) - P(A \cap B)$$

**Inclusion-Exclusion (general, three events)**

$$P(A \cup B \cup C) = P(A) + P(B) + P(C) - P(A \cap B) - P(A \cap C) - P(B \cap C) + P(A \cap B \cap C)$$

**Finite additivity (special case of Axiom 3)**

If $A_1, \ldots, A_n$ are pairwise disjoint:

$$P\left(\bigcup_{i=1}^{n} A_i\right) = \sum_{i=1}^{n} P(A_i)$$

### Visualizing Inclusion-Exclusion (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Inclusion-Exclusion Principle (svg_diagram)</text>

  <rect x="40" y="50" width="560" height="230" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="55" y="72" font-size="14" fill="#333" font-style="italic">Ω</text>

  <circle cx="260" cy="180" r="100" fill="#4a90d9" fill-opacity="0.35" stroke="#2c5f8a" stroke-width="2" />
  <circle cx="380" cy="180" r="100" fill="#e07a3f" fill-opacity="0.35" stroke="#a8531f" stroke-width="2" />

  <text x="195" y="130" font-size="15" fill="#123a5c" font-weight="bold">P(A)</text>
  <text x="435" y="130" font-size="15" fill="#7a3610" font-weight="bold">P(B)</text>
  <text x="300" y="185" font-size="13" fill="#1a1a1a" text-anchor="middle">P(A∩B)</text>

  <text x="320" y="305" font-size="14" fill="#1a1a1a" text-anchor="middle">P(A∪B) = P(A) + P(B) - P(A∩B)</text>
</svg>

### Worked Example

**Example**

A fair six-sided die is rolled once. $\Omega = \{1,2,3,4,5,6\}$, and each outcome is assumed equally likely, so $P(\{i\}) = \tfrac{1}{6}$ for each $i$.

Define:
- $A$ = "roll is even" $= \{2,4,6\}$, so $P(A) = \tfrac{3}{6} = 0.5$
- $B$ = "roll is greater than 3" $= \{4,5,6\}$, so $P(B) = \tfrac{3}{6} = 0.5$
- $A \cap B = \{4,6\}$, so $P(A \cap B) = \tfrac{2}{6} = \tfrac{1}{3}$

Applying inclusion-exclusion:

$$P(A \cup B) = 0.5 + 0.5 - \tfrac{1}{3} = \tfrac{2}{3}$$

Verification by direct enumeration: $A \cup B = \{2,4,5,6\}$, so $P(A \cup B) = \tfrac{4}{6} = \tfrac{2}{3}$. This matches, consistent with the axioms as applied here.

### Relevance to Machine Learning

- **Loss and risk functions**: Expected risk in statistical learning theory is defined as an integral (expectation) with respect to a probability measure satisfying these axioms over the joint data distribution $P(X,Y)$.
- **Probabilistic classifiers**: Output layers such as softmax are constructed so that outputs satisfy $P(\Omega) = 1$ and non-negativity over the class label space, mirroring Axioms 1 and 2. [Inference] This design choice is generally understood as enforcing a valid probability distribution over class labels, though the softmax function itself is a modeling choice and does not by itself guarantee that the resulting values are a calibrated or "true" probability in a statistical sense — that is a separate, empirically evaluated property. Behavior of any specific model's calibration is not guaranteed and can vary by architecture, training data, and task.
- **Bayesian inference**: Prior, likelihood, and posterior distributions used in Bayesian ML methods must each individually satisfy Kolmogorov's axioms to be valid probability distributions.

### Common Pitfalls

- Treating the axioms as merely computational rules rather than the formal foundation that determines which functions qualify as valid probability measures at all.
- Applying finite additivity (a special case) in settings requiring countable additivity, particularly relevant in continuous or infinite sample spaces.
- Assuming inclusion-exclusion for two events generalizes trivially without alternating signs for three or more events — the general formula requires alternating addition and subtraction across all intersection levels.

I cannot verify the exact original wording or page-level citation of Kolmogorov's 1933 formulation; the axioms as stated reflect the standard modern presentation found across probability textbooks, not a direct quotation from a primary source.

**Related Topics**
- Conditional Probability and Bayes' Theorem
- Independence of Events
- Random Variables and Probability Distributions
- Discrete vs. Continuous Probability Measures
- Law of Total Probability
- Measure Theory Foundations (σ-algebras, Borel sets)