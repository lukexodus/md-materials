## Sample Spaces and Events

### Definition of a Sample Space

A sample space, denoted $\Omega$ or $S$, is the set of all possible outcomes of a random experiment. Every conceivable result of the experiment must be represented exactly once as an element of this set.

$$\Omega = \{\omega_1, \omega_2, \omega_3, \ldots\}$$

Each $\omega_i$ is called an **outcome** or **sample point**. A sample space can be:

- **Discrete (finite)** — e.g., a coin toss: $\Omega = \{H, T\}$
- **Discrete (countably infinite)** — e.g., number of trials until first success: $\Omega = \{1, 2, 3, \ldots\}$
- **Continuous (uncountable)** — e.g., time until a sensor failure: $\Omega = [0, \infty)$

### Definition of an Event

An event is any subset of the sample space, $A \subseteq \Omega$. An event is said to **occur** if the actual outcome of the experiment is an element of that subset.

- The **certain event** is $\Omega$ itself (something in the sample space always happens).
- The **impossible event** is the empty set $\emptyset$.
- A **simple (elementary) event** contains exactly one outcome, $\{\omega_i\}$.
- A **compound event** contains more than one outcome.

### Set-Theoretic Operations on Events

Since events are sets, standard set operations define relationships between them:

| Operation | Notation | Meaning |
|---|---|---|
| Union | $A \cup B$ | $A$ or $B$ (or both) occurs |
| Intersection | $A \cap B$ | Both $A$ and $B$ occur |
| Complement | $A^c$ or $\bar{A}$ | $A$ does not occur |
| Difference | $A \setminus B$ | $A$ occurs, $B$ does not |
| Subset | $A \subseteq B$ | If $A$ occurs, $B$ must occur |

Two events $A$ and $B$ are **mutually exclusive (disjoint)** if $A \cap B = \emptyset$ — they cannot both occur in a single trial.

A collection of events $\{A_1, A_2, \ldots, A_n\}$ forms a **partition** of $\Omega$ if:

$$A_1 \cup A_2 \cup \cdots \cup A_n = \Omega \quad \text{and} \quad A_i \cap A_j = \emptyset \text{ for all } i \neq j$$

### Visualizing Relationships (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360">
  <text x="320" y="28" text-anchor="middle" font-size="18" font-weight="bold" fill="#1a1a1a">Sample Space and Events (svg_diagram)</text>

  <rect x="40" y="50" width="560" height="270" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="55" y="72" font-size="14" fill="#333" font-style="italic">Ω (Sample Space)</text>

  <circle cx="260" cy="210" r="110" fill="#4a90d9" fill-opacity="0.35" stroke="#2c5f8a" stroke-width="2" />
  <text x="185" y="140" font-size="16" fill="#123a5c" font-weight="bold">A</text>

  <circle cx="380" cy="210" r="110" fill="#e07a3f" fill-opacity="0.35" stroke="#a8531f" stroke-width="2" />
  <text x="440" y="140" font-size="16" fill="#7a3610" font-weight="bold">B</text>

  <text x="320" y="215" font-size="13" fill="#1a1a1a" text-anchor="middle">A ∩ B</text>

  <circle cx="180" cy="300" r="3" fill="#123a5c" />
  <text x="188" y="304" font-size="12" fill="#123a5c">ω₁</text>

  <circle cx="320" cy="150" r="3" fill="#1a1a1a" />
  <text x="328" y="154" font-size="12" fill="#1a1a1a">ω₂</text>

  <circle cx="460" cy="300" r="3" fill="#7a3610" />
  <text x="468" y="304" font-size="12" fill="#7a3610">ω₃</text>

  <circle cx="80" cy="90" r="3" fill="#1a1a1a" />
  <text x="88" y="94" font-size="12" fill="#1a1a1a">ω₄ (outside A, B)</text>
</svg>

### Algebra of Events (σ-algebra)

For probability to be well-defined, the collection of events $\mathcal{F}$ (a subset of the power set of $\Omega$) must satisfy the properties of a **σ-algebra**:

1. $\Omega \in \mathcal{F}$
2. If $A \in \mathcal{F}$, then $A^c \in \mathcal{F}$ (closed under complement)
3. If $A_1, A_2, \ldots \in \mathcal{F}$, then $\bigcup_{i=1}^{\infty} A_i \in \mathcal{F}$ (closed under countable unions)

[Inference] For finite or countable sample spaces, $\mathcal{F}$ is typically taken to be the full power set of $\Omega$, since every subset can be assigned a probability without contradiction. For uncountable sample spaces (e.g., $\Omega = \mathbb{R}$), the full power set is generally not used because it leads to non-measurable sets; a restricted σ-algebra such as the Borel σ-algebra is used instead. This is a standard construction in measure-theoretic probability. [Unverified: the exact pathological constructions, such as Vitali sets, are a measure theory detail not reproduced here and should be checked against a primary reference such as Billingsley's *Probability and Measure* if needed for rigor.]

### Worked Example

**Example**

Experiment: Roll a fair six-sided die once.

$$\Omega = \{1, 2, 3, 4, 5, 6\}$$

Define events:
- $A$ = "roll is even" $= \{2, 4, 6\}$
- $B$ = "roll is greater than 3" $= \{4, 5, 6\}$

Then:

$$A \cup B = \{2, 4, 5, 6\}, \quad A \cap B = \{4, 6\}, \quad A^c = \{1, 3, 5\}$$

$A$ and $B$ are **not** mutually exclusive, since $A \cap B \neq \emptyset$.

A partition of $\Omega$ using outcome parity: $\{1,3,5\}$ (odd) and $\{2,4,6\}$ (even) — disjoint and exhaustive.

### Relevance to Machine Learning

- **Feature spaces as sample spaces**: In classification, the input space $\mathcal{X}$ and label space $\mathcal{Y}$ can be modeled as sample spaces over which joint distributions $P(X, Y)$ are defined.
- **Event-based reasoning in evaluation metrics**: Concepts like true positive, false positive, etc., are events defined over the sample space of (prediction, ground truth) pairs.
- **Hypothesis spaces**: [Inference] In some theoretical ML frameworks (e.g., PAC learning), the space of hypotheses can be treated analogously to a sample space when reasoning about probabilistic guarantees over generalization error, though this is a distinct construct from the sample space of data outcomes and the analogy should not be over-extended.

### Common Pitfalls

- Confusing an **outcome** (element of $\Omega$) with an **event** (subset of $\Omega$) — a single outcome $\{\omega\}$ is technically an event (a simple event), but $\omega$ alone is not.
- Assuming all subsets of a continuous sample space are valid events without a defined σ-algebra — this does not hold in general measure-theoretic treatments.
- Treating mutually exclusive and independent as equivalent — these are distinct concepts; mutual exclusivity is a set-theoretic property, while independence is a probabilistic one (covered in a later topic).

**Related Topics**
- Axioms of Probability (Kolmogorov's axioms)
- Conditional Probability and Independence
- Random Variables and Probability Distributions
- Measure-Theoretic Foundations of Probability (σ-algebras, Borel sets)
- Counting Methods (Combinatorics) for Discrete Sample Spaces
- Joint, Marginal, and Conditional Distributions in ML Contexts