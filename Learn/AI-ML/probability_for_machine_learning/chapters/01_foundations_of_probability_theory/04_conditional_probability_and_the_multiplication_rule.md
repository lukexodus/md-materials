## Conditional Probability and the Multiplication Rule

### Definition of Conditional Probability

The conditional probability of event $A$ given that event $B$ has occurred is defined as:

$$
P(A \mid B) = \frac{P(A \cap B)}{P(B)}, \quad \text{provided } P(B) > 0
$$

This represents the probability of $A$ occurring, restricted to the outcomes where $B$ is already known to have occurred. Conditioning on $B$ effectively shrinks the sample space from $\Omega$ to $B$.

**Example**: In a dataset of patients, let $A$ = "has disease" and $B$ = "tests positive." If $P(A \cap B) = 0.08$ and $P(B) = 0.10$, then:

$$
P(A \mid B) = \frac{0.08}{0.10} = 0.8
$$

### Why Conditioning Restricts the Sample Space

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280">
<title>Conditioning restricts the sample space (svg_diagram)</title>
<rect x="0" y="0" width="600" height="280" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Conditioning Restricts the Sample Space (svg_diagram)</text>

<rect x="60" y="50" width="480" height="180" fill="#f5f5f5" stroke="#333333" stroke-width="2" />
<text x="80" y="70" font-size="12" font-family="sans-serif" fill="#111111">Ω</text>

<circle cx="230" cy="150" r="80" fill="#a3c9f9" fill-opacity="0.5" stroke="#2b6cb0" stroke-width="2" />
<circle cx="330" cy="150" r="80" fill="#f9a3a3" fill-opacity="0.5" stroke="#c0392b" stroke-width="2" />

<text x="180" y="110" font-size="13" font-family="sans-serif" fill="#111111">A</text>
<text x="390" y="110" font-size="13" font-family="sans-serif" fill="#111111">B</text>
<text x="270" y="155" font-size="11" font-family="sans-serif" fill="#111111">A∩B</text>

<text x="300" y="250" font-size="13" text-anchor="middle" font-family="monospace" fill="#111111">P(A|B) = P(A∩B) / P(B)</text>
<text x="300" y="268" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">New sample space becomes B instead of Ω</text>
</svg>

### The Multiplication Rule

Rearranging the definition of conditional probability gives the **multiplication rule** (also called the chain rule for two events):

$$
P(A \cap B) = P(A \mid B) \, P(B) = P(B \mid A) \, P(A)
$$

[Inference] This follows directly by algebraic rearrangement of the conditional probability definition; it is not an independent axiom but a restated form of the definition.

**Example**: An email is spam with probability $P(B) = 0.4$. Given that an email is spam, the probability it contains the word "free" is $P(A \mid B) = 0.6$. The probability that an email is both spam and contains "free":

$$
P(A \cap B) = 0.6 \times 0.4 = 0.24
$$

### General Chain Rule (Multiple Events)

For $n$ events $A_1, A_2, \dots, A_n$:

$$
P(A_1 \cap A_2 \cap \cdots \cap A_n) = P(A_1) \, P(A_2 \mid A_1) \, P(A_3 \mid A_1 \cap A_2) \cdots P(A_n \mid A_1 \cap \cdots \cap A_{n-1})
$$

[Inference] This generalizes the two-event multiplication rule by repeated application: at each step, the joint probability of the events considered so far is multiplied by the conditional probability of the next event given all preceding ones.

This chain rule decomposition is the basis for factorizing joint probability distributions in probabilistic graphical models and autoregressive sequence models, where a joint distribution over a sequence $x_1, \dots, x_n$ is written as:

$$
P(x_1, \dots, x_n) = P(x_1) \prod_{i=2}^{n} P(x_i \mid x_1, \dots, x_{i-1})
$$

[Unverified] I cannot verify the specific implementation details of every autoregressive model architecture that uses this factorization, since implementations vary; the factorization itself is a standard probability identity, not a claim about any specific system's behavior.

### Properties of Conditional Probability

Conditional probability $P(\cdot \mid B)$ satisfies the Kolmogorov axioms with respect to the restricted sample space $B$:

- $P(A \mid B) \geq 0$
- $P(\Omega \mid B) = 1$
- Countable additivity holds for disjoint events conditioned on $B$

[Inference] This follows because $P(\cdot \mid B)$ is itself a valid probability measure defined on the restricted space $B$, so it inherits the same axiomatic structure described in the earlier module on Kolmogorov's axioms.

**Complement rule under conditioning**:

$$
P(A^c \mid B) = 1 - P(A \mid B)
$$

### Order of Conditioning Matters

$P(A \mid B) \neq P(B \mid A)$ in general. Confusing these two quantities is known as the **conditional probability fallacy** or, in specific applied contexts, the **prosecutor's fallacy**.

**Example**: $P(\text{test positive} \mid \text{has disease})$ (test sensitivity) is generally not equal to $P(\text{has disease} \mid \text{test positive})$ (positive predictive value). These differ substantially when the base rate of the disease is low, a distinction formalized later via Bayes' theorem.

### Independence Revisited via Conditioning

Two events $A$ and $B$ are **independent** if and only if:

$$
P(A \mid B) = P(A), \quad \text{provided } P(B) > 0
$$

[Inference] This is equivalent to the multiplicative definition $P(A \cap B) = P(A)P(B)$, since substituting $P(A \cap B) = P(A)P(B)$ into the conditional probability definition yields $P(A \mid B) = P(A)$ directly.

Independence means that knowing $B$ occurred provides no information that changes the probability of $A$. This is distinct from **mutual exclusivity**: disjoint events with nonzero probability are always dependent, since $P(A \mid B) = 0 \neq P(A)$ whenever $A \cap B = \emptyset$ and $P(A) > 0$.

### Worked Example: Sequential Sampling Without Replacement

A dataset contains 10 items: 6 labeled "positive," 4 labeled "negative." Two items are drawn sequentially without replacement.

$P(\text{1st positive}) = \frac{6}{10}$

$P(\text{2nd positive} \mid \text{1st positive}) = \frac{5}{9}$

Using the multiplication rule:

$$
P(\text{both positive}) = \frac{6}{10} \times \frac{5}{9} = \frac{30}{90} = \frac{1}{3}
$$

This illustrates how conditioning updates probabilities as information accumulates during sequential sampling, distinct from sampling with replacement where conditional probabilities would remain unchanged.

### Relevance to Machine Learning

- The **chain rule of probability** is the mathematical basis for autoregressive models (e.g., language models predicting the next token conditioned on previous tokens), though this document cannot verify architecture-specific implementation claims for any particular system. [Unverified]
- **Conditional probability** underlies the definition of discriminative models, which directly model $P(y \mid x)$ rather than the joint distribution $P(x, y)$.
- **Naive Bayes classifiers** rely on conditional independence assumptions, covered in a later module, which simplify computation of $P(x_1, \dots, x_n \mid y)$.
- Confusing $P(A\mid B)$ with $P(B\mid A)$ is a documented reasoning error relevant to interpreting classifier metrics such as precision (a form of $P(y=1 \mid \hat{y}=1)$) versus recall (a form of $P(\hat{y}=1 \mid y=1)$).

### Common Pitfalls

- Dividing by $P(B) = 0$, which leaves conditional probability undefined.
- Assuming $P(A \mid B) = P(B \mid A)$ without justification.
- Treating mutually exclusive events as independent, or vice versa — these are distinct and generally incompatible properties for events with nonzero probability.
- Applying the chain rule while forgetting that later conditioning terms must include **all** preceding events, not just the immediately prior one.

**Related Topics**
- Bayes' theorem and its derivation from the multiplication rule
- Independence and conditional independence
- Law of total probability
- Naive Bayes classifiers
- Precision, recall, and confusion matrix probabilities
- Autoregressive factorization in sequence models