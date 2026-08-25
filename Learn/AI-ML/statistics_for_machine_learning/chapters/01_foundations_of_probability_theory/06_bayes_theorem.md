## Bayes' Theorem

### Statement

For events $A$ and $B$ with $P(A) > 0$ and $P(B) > 0$:

$$P(A \mid B) = \frac{P(B \mid A) \cdot P(A)}{P(B)}$$

Each term has a standard name:

- $P(A \mid B)$ — the **posterior** probability of $A$ given evidence $B$
- $P(B \mid A)$ — the **likelihood** of observing $B$ given $A$
- $P(A)$ — the **prior** probability of $A$
- $P(B)$ — the **marginal likelihood** (or evidence)

[Inference] This identity follows directly from the definition of conditional probability applied symmetrically: $P(A \cap B) = P(A \mid B) P(B)$ and $P(A \cap B) = P(B \mid A) P(A)$. Setting these two expressions equal and solving for $P(A \mid B)$ produces the stated formula. This is a step-by-step algebraic derivation from the previously stated definition of conditional probability, not an independently confirmed empirical result.

### Expanded Form Using the Law of Total Probability

When $A$ is one of a partition $A_1, A_2, \ldots, A_n$ of $\Omega$:

$$P(A_i \mid B) = \frac{P(B \mid A_i) \cdot P(A_i)}{\sum_{j=1}^{n} P(B \mid A_j) \cdot P(A_j)}$$

[Inference] This form follows by substituting the law of total probability expression for $P(B)$ into the denominator of the basic statement above. This is an algebraic substitution of a previously stated result, not a separately verified claim.

### Visualizing the Update (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="28" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Bayes' Theorem: Belief Update (svg_diagram)</text>

  <rect x="50" y="60" width="180" height="90" fill="#4a90d9" fill-opacity="0.30" stroke="#2c5f8a" stroke-width="2" rx="6" />
  <text x="140" y="95" font-size="14" fill="#123a5c" text-anchor="middle" font-weight="bold">Prior</text>
  <text x="140" y="118" font-size="13" fill="#123a5c" text-anchor="middle">P(A)</text>

  <rect x="50" y="190" width="180" height="90" fill="#e07a3f" fill-opacity="0.30" stroke="#a8531f" stroke-width="2" rx="6" />
  <text x="140" y="225" font-size="14" fill="#7a3610" text-anchor="middle" font-weight="bold">Likelihood</text>
  <text x="140" y="248" font-size="13" fill="#7a3610" text-anchor="middle">P(B|A)</text>

  <line x1="230" y1="105" x2="380" y2="170" stroke="#333" stroke-width="2" marker-end="url(#arrow1)" />
  <line x1="230" y1="235" x2="380" y2="170" stroke="#333" stroke-width="2" marker-end="url(#arrow1)" />

  <rect x="400" y="130" width="190" height="90" fill="#6fae5e" fill-opacity="0.30" stroke="#3f7a30" stroke-width="2" rx="6" />
  <text x="495" y="165" font-size="14" fill="#1f4a17" text-anchor="middle" font-weight="bold">Posterior</text>
  <text x="495" y="188" font-size="13" fill="#1f4a17" text-anchor="middle">P(A|B)</text>

  <text x="320" y="300" font-size="12" fill="#1a1a1a" text-anchor="middle">Combined via P(B) (marginal likelihood) in the denominator</text>
</svg>

### Worked Example

**Example**

A medical test for a disease has the following properties:

- Disease prevalence in the population: $P(D) = 0.01$
- Test sensitivity (true positive rate): $P(+\mid D) = 0.95$
- Test false positive rate: $P(+ \mid D^c) = 0.05$

Find $P(D \mid +)$ — the probability a person has the disease given a positive test result.

First, compute $P(+)$ using the law of total probability:

$$P(+) = P(+ \mid D) P(D) + P(+ \mid D^c) P(D^c)$$

$$P(+) = (0.95)(0.01) + (0.05)(0.99) = 0.0095 + 0.0495 = 0.059$$

Now apply Bayes' Theorem:

$$P(D \mid +) = \frac{P(+ \mid D) \cdot P(D)}{P(+)} = \frac{(0.95)(0.01)}{0.059} = \frac{0.0095}{0.059} \approx 0.161$$

Despite a 95% sensitive test, the probability the person actually has the disease given a positive result is approximately $16.1\%$. This result is a direct computation from the stated inputs, which are illustrative figures for this worked example and not data drawn from a specific cited real-world study; it is not a general claim about any specific real disease or test.

### Odds Form of Bayes' Theorem

Bayes' Theorem can be rewritten using odds, which is sometimes computationally convenient:

$$\frac{P(A \mid B)}{P(A^c \mid B)} = \frac{P(B \mid A)}{P(B \mid A^c)} \cdot \frac{P(A)}{P(A^c)}$$

This states: posterior odds = likelihood ratio × prior odds. [Inference] This form follows from writing Bayes' Theorem separately for $P(A \mid B)$ and $P(A^c \mid B)$ and dividing the two expressions, which cancels the shared $P(B)$ denominator term. This is an algebraic rearrangement of the basic statement, not a separately confirmed result.

### Sequential (Iterative) Bayesian Updating

When multiple independent pieces of evidence $B_1, B_2, \ldots$ arrive, the posterior after observing $B_1$ can serve as the prior for incorporating $B_2$:

$$P(A \mid B_1, B_2) \propto P(B_2 \mid A) \cdot P(B_1 \mid A) \cdot P(A)$$

[Unverified] This proportional relationship assumes conditional independence of $B_1$ and $B_2$ given $A$. Whether this conditional independence assumption holds in any specific real-world sequential-updating scenario cannot be verified without inspecting that scenario directly; this is a standard simplifying assumption used in sequential Bayesian updating, not a property confirmed to hold universally.

### Relevance to Machine Learning

- **Naive Bayes classifiers** apply Bayes' Theorem directly, computing $P(y \mid x_1, \ldots, x_n) \propto P(x_1, \ldots, x_n \mid y) P(y)$, combined with the conditional independence assumption covered in the independence topic.
- **Bayesian inference for model parameters**: in Bayesian machine learning, Bayes' Theorem is used to update a prior distribution over parameters $\theta$ into a posterior given observed data $D$: $P(\theta \mid D) \propto P(D \mid \theta) P(\theta)$.
- **Bayesian optimization** and **Bayesian neural networks** rely on this same posterior-updating structure. [Inference] The extent to which any specific software implementation of these methods faithfully computes an exact posterior (versus an approximation, such as via variational inference or MCMC sampling) varies by method and implementation; behavior of any particular library or model is not guaranteed and should be checked against that library's own documentation rather than assumed from the general theorem alone.

### Common Pitfalls

- **Base rate neglect**: ignoring the prior $P(A)$ and focusing only on the likelihood $P(B \mid A)$ — as shown in the worked example, a highly sensitive test can still yield a low posterior probability when the prior (prevalence) is low.
- Confusing $P(A \mid B)$ with $P(B \mid A)$ — these are related by Bayes' Theorem but are not equal in general; this is the same confusion noted under conditional probability.
- Applying Bayes' Theorem with an incorrectly specified or unjustified prior — the posterior is sensitive to the choice of prior, particularly when the amount of evidence is small. I cannot verify a general quantitative claim about "how much" evidence is needed to overcome a poor prior without specifying a concrete model, so no such quantitative claim is made here.

This response contains labeled [Inference] and [Unverified] statements as noted inline for steps derived algebraically from prior definitions or reliant on assumptions not independently verified in this conversation. The worked example uses illustrative numerical figures and is not drawn from a specific cited real-world source.

**Related Topics**
- Law of Total Probability (foundational for the denominator)
- Naive Bayes Classifiers (applied ML context)
- Bayesian Parameter Estimation and Priors
- Maximum a Posteriori (MAP) vs. Maximum Likelihood Estimation (MLE)
- Bayesian Networks and Graphical Models
- Variational Inference and MCMC Sampling