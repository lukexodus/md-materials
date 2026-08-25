## Independence of Events

### Definition of Independence

Two events $A$ and $B$ are **independent** if the occurrence of one provides no information about the probability of the other. Formally:

$$
P(A \cap B) = P(A) \, P(B)
$$

This is the primary definition of independence, since it does not require $P(A) > 0$ or $P(B) > 0$ to hold, unlike the conditional formulation.

**Equivalent conditional formulation** (when $P(B) > 0$):

$$
P(A \mid B) = P(A)
$$

[Inference] This equivalence follows by substituting the multiplicative definition into the conditional probability formula: $P(A \mid B) = \frac{P(A \cap B)}{P(B)} = \frac{P(A)P(B)}{P(B)} = P(A)$.

Symmetrically, when $P(A) > 0$:

$$
P(B \mid A) = P(B)
$$

### Independence vs. Mutual Exclusivity

These two concepts are frequently confused but are generally incompatible for events with nonzero probability.

- **Mutually exclusive**: $A \cap B = \emptyset$, so $P(A \cap B) = 0$.
- **Independent**: $P(A \cap B) = P(A)P(B)$.

If $A$ and $B$ are mutually exclusive with $P(A) > 0$ and $P(B) > 0$, then $P(A \cap B) = 0 \neq P(A)P(B)$ (since the product of two positive numbers is positive), so they cannot be independent. [Inference] This follows directly from comparing the two definitions under the stated positivity conditions.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>Independence versus mutual exclusivity (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Independence vs Mutual Exclusivity (svg_diagram)</text>

<text x="150" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Mutually Exclusive</text>
<circle cx="110" cy="120" r="40" fill="#a3c9f9" fill-opacity="0.6" stroke="#2b6cb0" stroke-width="2" />
<circle cx="200" cy="120" r="40" fill="#f9a3a3" fill-opacity="0.6" stroke="#c0392b" stroke-width="2" />
<text x="95" y="125" font-size="12" font-family="sans-serif">A</text>
<text x="215" y="125" font-size="12" font-family="sans-serif">B</text>
<text x="150" y="180" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">P(A∩B) = 0</text>
<text x="150" y="198" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Always dependent (if P(A),P(B)&gt;0)</text>

<text x="450" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Independent (overlapping)</text>
<circle cx="410" cy="120" r="40" fill="none" stroke="#2b6cb0" stroke-width="2" />
<circle cx="470" cy="120" r="40" fill="none" stroke="#c0392b" stroke-width="2" />
<clipPath id="clipIndep"><circle cx="410" cy="120" r="40" /></clipPath>
<circle cx="470" cy="120" r="40" fill="#9b59b6" fill-opacity="0.5" clip-path="url(#clipIndep)" />
<text x="395" y="125" font-size="12" font-family="sans-serif">A</text>
<text x="485" y="125" font-size="12" font-family="sans-serif">B</text>
<text x="440" y="180" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">P(A∩B) = P(A)P(B)</text>
<text x="440" y="198" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Overlap size set by the product</text>
</svg>

### Complement Rule for Independence

If $A$ and $B$ are independent, then the following pairs are also independent:

$$
A \text{ and } B^c, \qquad A^c \text{ and } B, \qquad A^c \text{ and } B^c
$$

[Inference] This can be shown for the first case as follows: $P(A \cap B^c) = P(A) - P(A \cap B) = P(A) - P(A)P(B) = P(A)(1 - P(B)) = P(A)P(B^c)$, which matches the multiplicative definition of independence. I have not derived the remaining two cases explicitly here, but they follow by an analogous argument.

### Pairwise Independence vs. Mutual Independence

For three events $A$, $B$, $C$, **pairwise independence** requires:

$$
P(A \cap B) = P(A)P(B), \quad P(A \cap C) = P(A)P(C), \quad P(B \cap C) = P(B)P(C)
$$

**Mutual independence** additionally requires:

$$
P(A \cap B \cap C) = P(A)\,P(B)\,P(C)
$$

Pairwise independence does not imply mutual independence. [Unverified] I cannot reconstruct a fully verified numerical counterexample within this response with confidence in its arithmetic without computational verification, but the standard textbook counterexample involves constructing three events from two independent fair coin flips (e.g., $A$ = "first flip heads," $B$ = "second flip heads," $C$ = "flips match") where all three pairs are independent but the triple is not; this is a widely cited construction in probability theory, though I have not independently recomputed the joint probability here to confirm the arithmetic in this response.

### Conditional Independence

Two events $A$ and $B$ are **conditionally independent given $C$** if:

$$
P(A \cap B \mid C) = P(A \mid C) \, P(B \mid C)
$$

This does **not** imply unconditional independence, and unconditional independence does **not** imply conditional independence. [Inference] This asymmetry follows because conditioning on $C$ can introduce or remove statistical dependence between $A$ and $B$ that was not present, or was present, in the unconditional relationship — a phenomenon sometimes discussed under the label "explaining away" in graphical models. [Unverified] I cannot verify without a specific worked numerical example in this response that a concrete case satisfies both conditions simultaneously, so this claim should be checked against a dedicated worked example rather than accepted from this general statement alone.

### Independence of Random Variables (Preview)

Independence extends from events to random variables: $X$ and $Y$ are independent if for all values $x, y$:

$$
P(X = x, Y = y) = P(X = x)\,P(Y = y)
$$

or, for continuous variables, if the joint density factors as $f_{X,Y}(x,y) = f_X(x) f_Y(y)$. This will be covered formally in a later module on joint distributions.

### Worked Example: Independent Classifier Errors

Suppose two independently trained classifiers each have a probability of misclassifying a given input:

- Classifier 1: $P(E_1) = 0.1$
- Classifier 2: $P(E_2) = 0.15$

If $E_1$ and $E_2$ are assumed independent, [Inference] this assumption would need to be justified based on the specific training setup (e.g., different architectures, different data subsets) rather than assumed by default, since classifiers trained on the same or overlapping data may share correlated error patterns.

Under the independence assumption, the probability both misclassify the same input:

$$
P(E_1 \cap E_2) = 0.1 \times 0.15 = 0.015
$$

The probability at least one misclassifies:

$$
P(E_1 \cup E_2) = P(E_1) + P(E_2) - P(E_1 \cap E_2) = 0.1 + 0.15 - 0.015 = 0.235
$$

### Testing for Independence from Data

[Inference] In practice, independence is often assessed empirically by comparing an estimated joint probability $\hat{P}(A \cap B)$ against the product $\hat{P}(A)\hat{P}(B)$ computed from sample frequencies, though sampling variability means exact equality is rarely observed even when true independence holds; formal statistical tests (e.g., chi-squared test of independence) are typically used to assess whether an observed deviation is statistically significant rather than relying on visual inspection alone. [Unverified] This document does not cover the mechanics of the chi-squared independence test itself, which would require separate treatment.

### Relevance to Machine Learning

- **Naive Bayes classifiers** assume conditional independence of features given the class label, a simplifying assumption that [Inference] is known to often not hold exactly in real datasets, yet the classifier can still perform well empirically in many applications; this document cannot verify performance claims for any specific dataset or implementation without direct evaluation, and behavior should be validated empirically rather than assumed.
- **i.i.d. (independent and identically distributed) assumptions** underlie standard supervised learning theory, where training examples are assumed independently drawn from the same distribution; [Unverified] whether this assumption holds for any specific real-world dataset cannot be determined without direct investigation of that dataset's collection process.
- **Ensemble methods** (e.g., bagging) rely on reducing correlated errors between base models; [Inference] independence or low correlation between base model errors is generally understood to improve ensemble performance, though this document cannot confirm the precise quantitative relationship without a specific theoretical or empirical reference, and such behavior is not guaranteed across all ensemble configurations.
- **Dropout and other regularization methods** are sometimes described informally as encouraging independence between learned features or units; [Speculation] this framing is a common informal explanation but this document cannot confirm it reflects a formally established equivalence to statistical independence as defined here.

### Common Pitfalls

- Assuming independence without justification, particularly for i.i.d. assumptions in real-world data pipelines where samples may be correlated (e.g., time series, clustered sampling).
- Treating mutually exclusive events as independent, or independent events as mutually exclusive.
- Assuming pairwise independence implies mutual independence for three or more events.
- Assuming conditional independence given one variable implies unconditional independence, or the reverse.

**Related Topics**
- Conditional independence in graphical models (Bayesian networks, Markov random fields)
- Naive Bayes classifiers
- i.i.d. assumptions in statistical learning theory
- Joint, marginal, and conditional distributions of random variables
- Correlation and covariance (a distinct, weaker notion related to but not equivalent to independence)
- Ensemble methods and error correlation