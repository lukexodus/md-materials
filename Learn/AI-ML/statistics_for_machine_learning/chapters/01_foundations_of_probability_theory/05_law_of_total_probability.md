## Law of Total Probability

### Definition

If $B_1, B_2, \ldots, B_n$ form a **partition** of the sample space $\Omega$ — meaning the events are pairwise disjoint ($B_i \cap B_j = \emptyset$ for $i \neq j$) and exhaustive ($\bigcup_{i=1}^n B_i = \Omega$), with $P(B_i) > 0$ for each $i$ — then for any event $A$:

$$P(A) = \sum_{i=1}^{n} P(A \cap B_i) = \sum_{i=1}^{n} P(A \mid B_i) \cdot P(B_i)$$

[Inference] This follows from decomposing $A$ into disjoint pieces $A \cap B_1, A \cap B_2, \ldots, A \cap B_n$ (since the $B_i$ partition $\Omega$, their intersections with $A$ partition $A$ itself), then applying finite additivity (Axiom 3 of Kolmogorov's axioms) followed by the multiplication rule to each term. This is a step-by-step algebraic derivation from previously stated axioms and definitions, not an independently confirmed empirical result.

### Extension to Countably Infinite Partitions

If $\{B_i\}_{i=1}^{\infty}$ is a countably infinite partition of $\Omega$ with $P(B_i) > 0$:

$$P(A) = \sum_{i=1}^{\infty} P(A \mid B_i) \cdot P(B_i)$$

[Unverified] This infinite-sum extension relies on countable additivity holding in the same manner as the finite case. I have not independently re-derived the convergence conditions for this infinite sum here, so this extension is presented as a standard generalization rather than a verified derivation.

### Visualizing the Partition (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Law of Total Probability (svg_diagram)</text>

  <rect x="40" y="55" width="560" height="240" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="55" y="78" font-size="13" fill="#333" font-style="italic">Ω partitioned into B₁, B₂, B₃</text>

  <rect x="60" y="100" width="170" height="170" fill="#4a90d9" fill-opacity="0.30" stroke="#2c5f8a" stroke-width="2" />
  <text x="130" y="120" font-size="13" fill="#123a5c" text-anchor="middle">B₁</text>

  <rect x="230" y="100" width="170" height="170" fill="#e07a3f" fill-opacity="0.30" stroke="#a8531f" stroke-width="2" />
  <text x="315" y="120" font-size="13" fill="#7a3610" text-anchor="middle">B₂</text>

  <rect x="400" y="100" width="170" height="170" fill="#6fae5e" fill-opacity="0.30" stroke="#3f7a30" stroke-width="2" />
  <text x="485" y="120" font-size="13" fill="#1f4a17" text-anchor="middle">B₃</text>

  <ellipse cx="315" cy="200" rx="230" ry="55" fill="#c9c9c9" fill-opacity="0.5" stroke="#555" stroke-width="2" />
  <text x="315" y="205" font-size="14" fill="#1a1a1a" text-anchor="middle" font-weight="bold">A</text>

  <text x="320" y="320" font-size="13" fill="#1a1a1a" text-anchor="middle">P(A) = P(A∩B₁) + P(A∩B₂) + P(A∩B₃)</text>
</svg>

### Worked Example

**Example**

A factory has three machines producing the same part:

- Machine $B_1$ produces 30% of parts: $P(B_1) = 0.30$
- Machine $B_2$ produces 45% of parts: $P(B_2) = 0.45$
- Machine $B_3$ produces 25% of parts: $P(B_3) = 0.25$

These form a partition since every part comes from exactly one machine: $0.30 + 0.45 + 0.25 = 1.00$.

Defect rates per machine (event $A$ = "part is defective"):

- $P(A \mid B_1) = 0.02$
- $P(A \mid B_2) = 0.01$
- $P(A \mid B_3) = 0.04$

Applying the law of total probability:

$$P(A) = (0.02)(0.30) + (0.01)(0.45) + (0.04)(0.25)$$

$$P(A) = 0.006 + 0.0045 + 0.010 = 0.0205$$

The overall probability that a randomly selected part is defective is $0.0205$, or $2.05\%$. This is a direct computation from the stated inputs; it depends entirely on the assumed defect rates and production shares given above, which are illustrative figures for this example rather than data drawn from a real, cited source.

### Special Case: Binary Partition

A common special case uses $B$ and $B^c$ (a trivial partition of $\Omega$ into two disjoint, exhaustive events):

$$P(A) = P(A \mid B) \cdot P(B) + P(A \mid B^c) \cdot P(B^c)$$

This form appears frequently as an intermediate step in Bayes' Theorem derivations.

### Relationship to Bayes' Theorem

The law of total probability is commonly used to compute the denominator in Bayes' Theorem:

$$P(B_i \mid A) = \frac{P(A \mid B_i) \cdot P(B_i)}{\sum_{j=1}^{n} P(A \mid B_j) \cdot P(B_j)} = \frac{P(A \mid B_i) \cdot P(B_i)}{P(A)}$$

[Inference] This connection follows directly from substituting the law of total probability expression for $P(A)$ into the definition of conditional probability applied to $P(B_i \mid A)$. The full derivation and interpretation of Bayes' Theorem itself is deferred to a dedicated topic and is not re-derived in full here.

### Relevance to Machine Learning

- **Marginalization in probabilistic models**: computing a marginal probability $P(A)$ by summing over a latent or conditioning variable is a direct application of this law, used extensively in mixture models and latent variable models such as Gaussian Mixture Models.
- **Class-conditional models**: in generative classifiers, the overall probability of observing feature vector $x$ is computed as $P(x) = \sum_{k} P(x \mid y=k) P(y=k)$, summing over all class labels $k$ — a direct instance of this law applied to a partition formed by the class labels.
- **Expectation-Maximization (EM) algorithm**: [Inference] the E-step in EM-based methods involves computing posterior probabilities over latent variables, which relies on marginalizing joint probabilities using a construction analogous to the law of total probability. This is a structural description of how the computation is typically framed in standard treatments of EM; the specific implementation details can vary across algorithm variants and are not guaranteed to follow this exact pattern in every implementation.

### Common Pitfalls

- Using a collection of events $B_i$ that are not actually disjoint or not actually exhaustive — the law as stated requires a true partition; violating either condition invalidates the summation.
- Forgetting to verify $P(B_i) > 0$ for each term — conditional probability $P(A \mid B_i)$ is undefined when $P(B_i) = 0$.
- Confusing this law with Bayes' Theorem itself — the law of total probability computes $P(A)$ (a marginal), while Bayes' Theorem computes $P(B_i \mid A)$ (a posterior); the former is typically used as a component within the latter.

This response contains labeled [Inference] and [Unverified] statements as noted inline for steps not directly re-derived or independently confirmed in this conversation; the worked example uses illustrative figures rather than cited real-world data.

**Related Topics**
- Bayes' Theorem (full derivation and interpretation)
- Conditional Probability
- Independence and Conditional Independence
- Marginal and Joint Distributions
- Mixture Models and Latent Variables
- Expectation-Maximization Algorithm