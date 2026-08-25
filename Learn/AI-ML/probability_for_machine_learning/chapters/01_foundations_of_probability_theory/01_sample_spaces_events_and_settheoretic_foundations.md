## Sample Spaces, Events, and Set-Theoretic Foundations

### Sample Space Definition

A sample space, denoted $\Omega$, is the set of all possible outcomes of a random experiment. Each element $\omega \in \Omega$ represents one possible outcome. The sample space can be:

- **Discrete finite**: A fixed, countable number of outcomes, e.g., $\Omega = \{1, 2, 3, 4, 5, 6\}$ for a die roll.
- **Discrete countably infinite**: e.g., $\Omega = \{0, 1, 2, 3, \dots\}$ for the number of trials until success.
- **Continuous (uncountable)**: e.g., $\Omega = \mathbb{R}$ or $\Omega = [0, 1]$ for measurements like time or sensor readings.

In machine learning contexts, sample spaces model the space of possible data instances, labels, latent variables, or model parameters, depending on the formulation.

### Events as Sets

An event $A$ is a subset of the sample space: $A \subseteq \Omega$. An event is said to "occur" if the realized outcome $\omega$ belongs to $A$.

- The **empty set** $\emptyset$ represents the impossible event.
- $\Omega$ itself represents the certain event.
- A **simple event** (or elementary event) contains exactly one outcome, $\{\omega\}$.
- A **compound event** contains more than one outcome.

**Example**: For a die roll, $\Omega = \{1,2,3,4,5,6\}$. The event "outcome is even" is $A = \{2,4,6\}$.

### Set Operations on Events

Standard set-theoretic operations define relationships between events:

- **Union** $A \cup B$: event that $A$ or $B$ (or both) occurs.
- **Intersection** $A \cap B$: event that both $A$ and $B$ occur.
- **Complement** $A^c = \Omega \setminus A$: event that $A$ does not occur.
- **Difference** $A \setminus B = A \cap B^c$: outcomes in $A$ but not in $B$.
- **Symmetric difference** $A \triangle B = (A \setminus B) \cup (B \setminus A)$.

Two events $A$ and $B$ are **mutually exclusive (disjoint)** if $A \cap B = \emptyset$ — they cannot both occur simultaneously.

A collection of events $\{A_1, A_2, \dots, A_n\}$ forms a **partition** of $\Omega$ if:

$$
A_i \cap A_j = \emptyset \text{ for } i \neq j, \quad \bigcup_{i=1}^{n} A_i = \Omega
$$

Partitions are foundational for the law of total probability, covered in a later module.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 320">
<title>Set operations on events (svg_diagram)</title>
<rect x="0" y="0" width="600" height="320" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Set Operations on Events (svg_diagram)</text>


<g>
<text x="90" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Union A ∪ B</text>
<circle cx="75" cy="100" r="40" fill="#a3c9f9" fill-opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
<circle cx="115" cy="100" r="40" fill="#f9a3a3" fill-opacity="0.6" stroke="#c0392b" stroke-width="2" />
<text x="55" y="105" font-size="12" font-family="sans-serif">A</text>
<text x="135" y="105" font-size="12" font-family="sans-serif">B</text>
</g>


<g>
<text x="290" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Intersection A ∩ B</text>
<circle cx="275" cy="100" r="40" fill="none" stroke="#2b6cb0" stroke-width="2" />
<circle cx="315" cy="100" r="40" fill="none" stroke="#c0392b" stroke-width="2" />
<clipPath id="clipInt">
<circle cx="275" cy="100" r="40" />
</clipPath>
<circle cx="315" cy="100" r="40" fill="#9b59b6" fill-opacity="0.6" clip-path="url(#clipInt)" />
<text x="255" y="105" font-size="12" font-family="sans-serif">A</text>
<text x="335" y="105" font-size="12" font-family="sans-serif">B</text>
</g>


<g>
<text x="490" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Complement A^c</text>
<rect x="450" y="65" width="90" height="70" fill="#f0f0f0" stroke="#333333" stroke-width="2" />
<circle cx="480" cy="100" r="25" fill="#a3c9f9" fill-opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
<text x="475" y="105" font-size="11" font-family="sans-serif">A</text>
<text x="505" y="120" font-size="10" font-family="sans-serif">Ω \ A</text>
</g>


<g>
<text x="90" y="200" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Disjoint (Mutually Exclusive)</text>
<circle cx="60" cy="250" r="30" fill="#a3c9f9" fill-opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
<circle cx="140" cy="250" r="30" fill="#f9a3a3" fill-opacity="0.6" stroke="#c0392b" stroke-width="2" />
<text x="52" y="255" font-size="12" font-family="sans-serif">A</text>
<text x="132" y="255" font-size="12" font-family="sans-serif">B</text>
</g>


<g>
<text x="420" y="200" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Partition of Ω</text>
<rect x="360" y="220" width="180" height="70" fill="#f0f0f0" stroke="#333333" stroke-width="2" />
<line x1="420" y1="220" x2="420" y2="290" stroke="#333333" stroke-width="1.5" />
<line x1="480" y1="220" x2="480" y2="290" stroke="#333333" stroke-width="1.5" />
<text x="388" y="260" font-size="11" font-family="sans-serif">A1</text>
<text x="448" y="260" font-size="11" font-family="sans-serif">A2</text>
<text x="508" y="260" font-size="11" font-family="sans-serif">A3</text>
</g>
</svg>

### Algebraic Properties (Laws of Set Theory)

These properties hold for all events $A, B, C \subseteq \Omega$ and underpin manipulation of probabilistic expressions:

- **Commutativity**: $A \cup B = B \cup A$, $A \cap B = B \cap A$
- **Associativity**: $(A \cup B) \cup C = A \cup (B \cup C)$
- **Distributivity**: $A \cap (B \cup C) = (A \cap B) \cup (A \cap C)$
- **De Morgan's Laws**:

$$
(A \cup B)^c = A^c \cap B^c, \qquad (A \cap B)^c = A^c \cup B^c
$$

De Morgan's laws are frequently used when converting between "at least one event occurs" and "all events fail to occur" formulations, which is common when deriving complementary probabilities.

### σ-Algebras (Event Spaces)

For rigorous probability theory, especially over infinite or continuous sample spaces, not every subset of $\Omega$ can necessarily be assigned a probability in a mathematically consistent way. This motivates restricting the collection of "measurable" events to a **σ-algebra** (also called a σ-field) $\mathcal{F}$, a collection of subsets of $\Omega$ satisfying:

1. $\Omega \in \mathcal{F}$
2. If $A \in \mathcal{F}$, then $A^c \in \mathcal{F}$ (closed under complementation)
3. If $A_1, A_2, \dots \in \mathcal{F}$, then $\bigcup_{i=1}^{\infty} A_i \in \mathcal{F}$ (closed under countable unions)

From these axioms, closure under countable intersections and $\emptyset \in \mathcal{F}$ follow.

The triple $(\Omega, \mathcal{F}, P)$, where $P$ is a probability measure defined on $\mathcal{F}$, is called a **probability space**. [Unverified] The exact measure-theoretic treatment (Borel σ-algebras, Lebesgue measure) is typically only made explicit in more mathematically rigorous ML texts (e.g., statistical learning theory); many applied ML resources work informally with events without stating the underlying σ-algebra.

For discrete, finite sample spaces, $\mathcal{F}$ is commonly taken to be the full power set $2^{\Omega}$, since all subsets are measurable and no pathological cases arise.

### Relevance to Machine Learning

- **Random variables** (covered in a later module) are formally defined as measurable functions from $(\Omega, \mathcal{F})$ to another measurable space, which relies directly on the σ-algebra structure introduced here.
- **Feature spaces and label spaces** in supervised learning can be modeled as sample spaces, with events corresponding to regions of interest (e.g., "the predicted class is correct").
- **Hypothesis spaces** in PAC learning theory are sometimes treated as sample spaces over which events (such as "a hypothesis has generalization error below $\epsilon$") are defined.
- Set operations (union, intersection, complement) directly correspond to logical combinations of conditions used when computing probabilities of compound events, such as joint or complementary event probabilities in later probability rules.

### Worked Example

Consider a binary classification setting where $\Omega$ represents all possible (input, true label, predicted label) triples for a dataset. Define:

- $A$ = event that the true label is positive
- $B$ = event that the predicted label is positive

Then:
- $A \cap B$ = true positives
- $A \cap B^c$ = false negatives
- $A^c \cap B$ = false positives
- $A^c \cap B^c$ = true negatives

This partitions $\Omega$ into four disjoint events whose union is $\Omega$, directly mirroring the confusion matrix structure used throughout ML evaluation. [Inference] This framing is a natural and commonly implicit way confusion matrix categories are described in set-theoretic terms, though the confusion matrix itself is typically presented directly as a table without explicit reference to sample spaces in most applied ML material.

### Common Pitfalls

- Confusing an **outcome** ($\omega \in \Omega$) with an **event** ($A \subseteq \Omega$) — a single outcome is not itself an event unless treated as a singleton set.
- Assuming all subsets of an infinite $\Omega$ are automatically valid events; this fails in continuous settings without a defined σ-algebra.
- Treating $A \cup B$ and $A + B$ interchangeably outside of probability computations — union is a set operation, not arithmetic addition, though this distinction becomes important once probability values are assigned (addition rule, covered later).

**Related Topics**
- Axioms of Probability (Kolmogorov's axioms) and probability measures
- Conditional probability and independence
- Random variables and measurable functions
- Discrete vs. continuous probability distributions
- The addition rule and inclusion-exclusion principle
- Law of total probability and partitions of the sample space
- Borel σ-algebras and measure-theoretic probability foundations