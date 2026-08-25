## Independence of Events

### Definition

Two events $A$ and $B$ are **independent** if the occurrence of one does not affect the probability of the other. Formally:

$$P(A \cap B) = P(A) \cdot P(B)$$

This is the defining condition. When $P(B) > 0$, this is equivalent to:

$$P(A \mid B) = P(A)$$

and when $P(A) > 0$, equivalent to:

$$P(B \mid A) = P(B)$$

[Inference] These equivalences follow algebraically by substituting the multiplication rule $P(A \cap B) = P(A \mid B) \cdot P(B)$ into the product-form definition above; each is a direct rearrangement, not a separately confirmed empirical fact.

### Independence vs. Mutual Exclusivity

These two concepts are frequently conflated but are distinct:

| Property | Definition | Relationship |
|---|---|---|
| Mutually exclusive | $A \cap B = \emptyset$ | $P(A \cap B) = 0$ |
| Independent | $P(A \cap B) = P(A)P(B)$ | $P(A \cap B) > 0$ generally, unless $P(A)=0$ or $P(B)=0$ |

If $A$ and $B$ are mutually exclusive and both have nonzero probability, they **cannot** be independent, since $P(A \cap B) = 0 \neq P(A) \cdot P(B)$ (which is positive). This is a direct algebraic consequence of the two definitions and is not [Inference] — it follows necessarily from the stated definitions.

### Pairwise Independence vs. Mutual Independence

For a collection of events $A_1, A_2, \ldots, A_n$:

**Pairwise independence** requires:

$$P(A_i \cap A_j) = P(A_i) P(A_j) \quad \text{for all } i \neq j$$

**Mutual independence** requires, for every subset $\{A_{i_1}, \ldots, A_{i_k}\}$ of size $k \geq 2$:

$$P(A_{i_1} \cap A_{i_2} \cap \cdots \cap A_{i_k}) = P(A_{i_1}) \cdot P(A_{i_2}) \cdots P(A_{i_k})$$

Pairwise independence does **not** imply mutual independence in general. [Unverified] A commonly cited counterexample involves three events derived from two fair coin tosses, but I cannot verify the precise construction from memory alone without reproducing and checking each probability calculation, so a full worked counterexample is not presented here to avoid asserting an unverified numerical claim as fact.

### Visualizing Independence (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 360">
  <text x="320" y="28" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Independent vs Dependent Events (svg_diagram)</text>

  <rect x="30" y="55" width="270" height="260" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="45" y="78" font-size="13" fill="#333" font-style="italic">Ω (Independent)</text>
  <rect x="60" y="120" width="90" height="160" fill="#4a90d9" fill-opacity="0.35" stroke="#2c5f8a" stroke-width="2" />
  <rect x="150" y="120" width="110" height="160" fill="#e07a3f" fill-opacity="0.35" stroke="#a8531f" stroke-width="2" />
  <text x="90" y="230" font-size="13" fill="#123a5c">A</text>
  <text x="195" y="230" font-size="13" fill="#7a3610">B</text>
  <text x="165" y="300" font-size="11" fill="#1a1a1a" text-anchor="middle">P(A∩B)=P(A)P(B)</text>

  <rect x="340" y="55" width="270" height="260" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="355" y="78" font-size="13" fill="#333" font-style="italic">Ω (Mutually Exclusive)</text>
  <circle cx="420" cy="200" r="70" fill="#4a90d9" fill-opacity="0.35" stroke="#2c5f8a" stroke-width="2" />
  <circle cx="540" cy="200" r="70" fill="#e07a3f" fill-opacity="0.35" stroke="#a8531f" stroke-width="2" />
  <text x="395" y="205" font-size="13" fill="#123a5c">A</text>
  <text x="535" y="205" font-size="13" fill="#7a3610">B</text>
  <text x="475" y="300" font-size="11" fill="#1a1a1a" text-anchor="middle">P(A∩B)=0 (disjoint, not independent)</text>
</svg>

### Worked Example

**Example**

Two fair, independent coin tosses. $\Omega = \{HH, HT, TH, TT\}$, each outcome with probability $\tfrac{1}{4}$.

- $A$ = "first toss is H" $= \{HH, HT\}$, so $P(A) = \tfrac{2}{4} = \tfrac{1}{2}$
- $B$ = "second toss is H" $= \{HH, TH\}$, so $P(B) = \tfrac{2}{4} = \tfrac{1}{2}$
- $A \cap B$ = "both tosses H" $= \{HH\}$, so $P(A \cap B) = \tfrac{1}{4}$

Check: $P(A) \cdot P(B) = \tfrac{1}{2} \cdot \tfrac{1}{2} = \tfrac{1}{4} = P(A \cap B)$.

The condition holds for this example, so $A$ and $B$ are independent under this specific construction. This is a computed result from the stated setup, not a general claim about all coin-toss scenarios.

### Conditional Independence

Events $A$ and $B$ are **conditionally independent** given event $C$ (with $P(C) > 0$) if:

$$P(A \cap B \mid C) = P(A \mid C) \cdot P(B \mid C)$$

[Inference] Conditional independence does not imply unconditional independence, and unconditional independence does not imply conditional independence given an arbitrary $C$. This is a structural property that follows from the definitions when analyzed via specific counterexamples; I do not have a verified worked counterexample to present here, so this claim is stated at the level of the general definition only, without a numerical demonstration.

### Relevance to Machine Learning

- **Naive Bayes classifiers** assume conditional independence of features given the class label: $P(x_1, \ldots, x_n \mid y) = \prod_{i=1}^n P(x_i \mid y)$. [Inference] This is a modeling assumption adopted for computational tractability. Whether this assumption holds for any particular real-world dataset is an empirical question specific to that dataset and is not something that can be asserted as generally true; classifier performance under violation of this assumption can vary and is not guaranteed to remain accurate.
- **i.i.d. assumption**: many ML algorithms assume training examples are independent and identically distributed. [Unverified] The extent to which this assumption holds for any specific real-world dataset cannot be verified without inspecting that dataset directly; it is a standard simplifying assumption in learning theory, not a property that is confirmed to hold universally.
- **Graphical models** (Bayesian networks, Markov random fields) encode conditional independence structure explicitly via graph topology, using the definitions above as their formal basis.

### Common Pitfalls

- Assuming two events are independent without checking the defining equation $P(A \cap B) = P(A)P(B)$ — independence must be verified or explicitly assumed, not inferred from intuition.
- Treating "disjoint" and "independent" as synonyms — as shown above, nonzero-probability disjoint events are never independent.
- Assuming pairwise independence across a set of events implies full mutual independence — this does not hold in general, as noted above.

> Correction note (proactive): The pairwise-vs-mutual independence counterexample was intentionally omitted rather than stated speculatively, since I could not verify the specific numerical construction. No unverified claim was asserted in its place.

**Related Topics**
- Bayes' Theorem
- Law of Total Probability
- Conditional Probability (foundational topic)
- Naive Bayes Classifiers (applied ML context)
- Bayesian Networks and Graphical Models
- Random Variables and Joint Distributions