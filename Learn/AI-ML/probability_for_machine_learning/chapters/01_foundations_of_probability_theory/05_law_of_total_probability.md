## Law of Total Probability

### Partitions as the Foundation

Recall from the earlier module on set-theoretic foundations that a collection of events $\{B_1, B_2, \dots, B_n\}$ forms a **partition** of the sample space $\Omega$ if the events are pairwise disjoint and their union covers $\Omega$:

$$
B_i \cap B_j = \emptyset \text{ for } i \neq j, \qquad \bigcup_{i=1}^{n} B_i = \Omega, \qquad P(B_i) > 0 \text{ for all } i
$$

The law of total probability uses such a partition to decompose the probability of any event $A$ into a weighted sum over the partition.

### Statement of the Law

Given a partition $\{B_1, \dots, B_n\}$ of $\Omega$, for any event $A$:

$$
P(A) = \sum_{i=1}^{n} P(A \mid B_i) \, P(B_i)
$$

[Inference] This follows from decomposing $A$ into disjoint pieces $A \cap B_1, A \cap B_2, \dots, A \cap B_n$, since the $B_i$ partition $\Omega$; applying countable additivity (from Kolmogorov's axioms) gives $P(A) = \sum_i P(A \cap B_i)$, and each term $P(A \cap B_i)$ equals $P(A \mid B_i)P(B_i)$ by the multiplication rule.

For the special case of a binary partition $\{B, B^c\}$:

$$
P(A) = P(A \mid B) \, P(B) + P(A \mid B^c) \, P(B^c)
$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 300">
<title>Law of total probability via partition (svg_diagram)</title>
<rect x="0" y="0" width="600" height="300" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Law of Total Probability (svg_diagram)</text>

<rect x="60" y="50" width="480" height="170" fill="#f5f5f5" stroke="#333333" stroke-width="2" />
<text x="75" y="68" font-size="12" font-family="sans-serif" fill="#111111">Ω</text>

<line x1="180" y1="50" x2="180" y2="220" stroke="#333333" stroke-width="1.5" />
<line x1="320" y1="50" x2="320" y2="220" stroke="#333333" stroke-width="1.5" />
<line x1="430" y1="50" x2="430" y2="220" stroke="#333333" stroke-width="1.5" />

<text x="120" y="80" font-size="12" font-family="sans-serif" fill="#111111">B1</text>
<text x="245" y="80" font-size="12" font-family="sans-serif" fill="#111111">B2</text>
<text x="370" y="80" font-size="12" font-family="sans-serif" fill="#111111">B3</text>
<text x="480" y="80" font-size="12" font-family="sans-serif" fill="#111111">B4</text>

<ellipse cx="300" cy="140" rx="150" ry="45" fill="#a3c9f9" fill-opacity="0.45" stroke="#2b6cb0" stroke-width="2" />
<text x="300" y="145" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">A</text>

<text x="300" y="250" font-size="13" text-anchor="middle" font-family="monospace" fill="#111111">P(A) = Σ P(A|Bi) P(Bi)</text>
<text x="300" y="270" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">A is split across the partition into disjoint pieces A∩Bi</text>
</svg>

### Worked Example: Manufacturing Defect Rates

A dataset originates from three data collection sites with the following properties:

- Site 1: $P(B_1) = 0.5$, defect rate $P(A \mid B_1) = 0.02$
- Site 2: $P(B_2) = 0.3$, defect rate $P(A \mid B_2) = 0.05$
- Site 3: $P(B_3) = 0.2$, defect rate $P(A \mid B_3) = 0.10$

Overall probability that a randomly selected item is defective:

$$
P(A) = (0.02)(0.5) + (0.05)(0.3) + (0.10)(0.2) = 0.01 + 0.015 + 0.02 = 0.045
$$

So $P(A) = 0.045$, meaning 4.5% of items across all sites are expected to be defective, [Inference] under the assumption that the stated per-site rates and site proportions are exact and that no other sites contribute to the dataset.

### Extended Form: Conditioning on a Third Event

The law of total probability generalizes to conditional settings. Given a partition $\{B_1, \dots, B_n\}$ and an additional event $C$:

$$
P(A \mid C) = \sum_{i=1}^{n} P(A \mid B_i, C) \, P(B_i \mid C)
$$

[Inference] This follows by applying the standard law of total probability within the restricted sample space defined by conditioning on $C$, treating $P(\cdot \mid C)$ as a valid probability measure in its own right, a property established in the earlier module on conditional probability.

### Relation to Marginalization

In problems involving random variables (covered formally in a later module), the law of total probability corresponds to **marginalization** over a discrete random variable $Y$ with outcomes $y_1, \dots, y_k$:

$$
P(A) = \sum_{j=1}^{k} P(A \mid Y = y_j) \, P(Y = y_j)
$$

For continuous variables, the analogous operation replaces the sum with an integral:

$$
P(A) = \int_{-\infty}^{\infty} P(A \mid Y = y) \, f_Y(y) \, dy
$$

where $f_Y(y)$ is the probability density function of $Y$. [Inference] This continuous form follows by treating the density $f_Y(y)\,dy$ as the probability mass of an infinitesimal partition element, extending the discrete sum to an integral in the limit; the formal justification for this limiting argument relies on measure-theoretic probability, which is only partially covered in this module series.

### Mixture Models as an Application

A common ML application of the law of total probability is the **mixture model**, where an observation is assumed to be generated by first selecting a component $Z \in \{1, \dots, K\}$ (e.g., a Gaussian component in a Gaussian Mixture Model) and then sampling from the corresponding component distribution. The marginal probability (or density) of an observation $x$ is:

$$
P(x) = \sum_{k=1}^{K} P(x \mid Z = k) \, P(Z = k)
$$

[Inference] This mixture formulation is a direct instance of the law of total probability applied to the latent component variable $Z$, since $Z$'s possible values form a partition of the outcome space for the latent assignment. [Unverified] Whether every specific mixture-model implementation in practice frames its likelihood computation explicitly in these terms cannot be confirmed here, as implementation details vary by library and codebase; behavior should be verified against the specific implementation in use rather than assumed from this general formulation.

### Worked Example: Naive Bayes Preview

In a spam classification setting, let $Y \in \{\text{spam}, \text{not spam}\}$ and $A$ = "email contains the word 'free'." The law of total probability gives:

$$
P(A) = P(A \mid Y = \text{spam}) P(Y = \text{spam}) + P(A \mid Y = \text{not spam}) P(Y = \text{not spam})
$$

This decomposition is a necessary intermediate step when applying Bayes' theorem to compute $P(Y = \text{spam} \mid A)$, since Bayes' theorem (covered in the next module) requires $P(A)$ in its denominator, and the law of total probability is the standard method for obtaining it when only conditional probabilities $P(A \mid Y)$ are known.

### Relevance to Machine Learning

- **Marginal likelihood computation** in generative models (e.g., Gaussian Mixture Models, Hidden Markov Models) relies directly on this law to sum or integrate out latent variables.
- **Bayes' theorem**, covered next, requires the law of total probability to compute its denominator (the marginal probability of the evidence) when that value is not given directly.
- **Ensemble methods** can [Speculation] loosely be interpreted through a similar decomposition, where overall prediction probability is expressed as a weighted combination over sub-model outputs, though this document cannot confirm that ensemble methods are formally derived from or presented as an application of the law of total probability in standard ML literature; this framing should be treated as an analogy rather than an established equivalence.

### Common Pitfalls

- Using a set of conditioning events that do not actually form a valid partition (overlapping events, or events that do not cover $\Omega$), which invalidates the decomposition.
- Forgetting to weight each conditional probability by $P(B_i)$, effectively averaging conditional probabilities incorrectly (unweighted instead of weighted).
- Confusing the law of total probability (which computes $P(A)$) with Bayes' theorem (which computes $P(B_i \mid A)$) — the two are related but serve different purposes.
- In continuous settings, applying the discrete sum form instead of the integral form when the conditioning variable is continuous.

**Related Topics**
- Bayes' theorem and posterior probability computation
- Marginal distributions and marginalization over random variables
- Mixture models (e.g., Gaussian Mixture Models)
- Hidden Markov Models and latent variable marginalization
- Naive Bayes classifiers
- Conditional independence assumptions