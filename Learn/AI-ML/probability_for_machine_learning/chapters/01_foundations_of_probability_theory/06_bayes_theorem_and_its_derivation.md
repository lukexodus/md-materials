## Bayes' Theorem and Its Derivation

### Derivation from the Multiplication Rule

From the earlier module on conditional probability, the multiplication rule states:

$$
P(A \cap B) = P(A \mid B) \, P(B) = P(B \mid A) \, P(A)
$$

[Inference] Setting the two right-hand expressions equal to each other, since both equal $P(A \cap B)$:

$$
P(A \mid B) \, P(B) = P(B \mid A) \, P(A)
$$

[Inference] Dividing both sides by $P(B)$, provided $P(B) > 0$, isolates $P(A \mid B)$ and yields **Bayes' theorem**:

$$
P(A \mid B) = \frac{P(B \mid A) \, P(A)}{P(B)}
$$

### Terminology

$$
\underbrace{P(A \mid B)}_{\text{posterior}} = \frac{\overbrace{P(B \mid A)}^{\text{likelihood}} \; \overbrace{P(A)}^{\text{prior}}}{\underbrace{P(B)}_{\text{evidence}}}
$$

- **Prior** $P(A)$: the probability of $A$ before observing $B$.
- **Likelihood** $P(B \mid A)$: the probability of observing $B$ given that $A$ is true.
- **Posterior** $P(A \mid B)$: the updated probability of $A$ after observing $B$.
- **Evidence** $P(B)$: the total (marginal) probability of observing $B$, regardless of $A$.

### Computing the Evidence via the Law of Total Probability

When $P(B)$ is not given directly, it is computed using the law of total probability from the preceding module, applied to the partition $\{A, A^c\}$:

$$
P(B) = P(B \mid A) \, P(A) + P(B \mid A^c) \, P(A^c)
$$

Substituting this into Bayes' theorem gives the expanded form:

$$
P(A \mid B) = \frac{P(B \mid A) \, P(A)}{P(B \mid A) \, P(A) + P(B \mid A^c) \, P(A^c)}
$$

### Generalized Form Over a Partition

For a partition $\{A_1, A_2, \dots, A_n\}$ of $\Omega$, Bayes' theorem for a specific $A_k$ given evidence $B$:

$$
P(A_k \mid B) = \frac{P(B \mid A_k) \, P(A_k)}{\sum_{i=1}^{n} P(B \mid A_i) \, P(A_i)}
$$

[Inference] This follows by substituting the law of total probability's partition-based expansion of $P(B)$ into the denominator of the two-event form of Bayes' theorem.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 320">
<title>Bayes theorem structure (svg_diagram)</title>
<rect x="0" y="0" width="600" height="320" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Bayes' Theorem Structure (svg_diagram)</text>

<rect x="150" y="55" width="300" height="50" fill="#a3c9f9" fill-opacity="0.5" stroke="#2b6cb0" stroke-width="2" />
<text x="300" y="85" font-size="14" text-anchor="middle" font-family="sans-serif" fill="#111111">Prior: P(A)</text>

<text x="300" y="125" font-size="20" text-anchor="middle" font-family="sans-serif" fill="#111111">×</text>

<rect x="150" y="140" width="300" height="50" fill="#f9a3a3" fill-opacity="0.5" stroke="#c0392b" stroke-width="2" />
<text x="300" y="170" font-size="14" text-anchor="middle" font-family="sans-serif" fill="#111111">Likelihood: P(B|A)</text>

<text x="300" y="210" font-size="20" text-anchor="middle" font-family="sans-serif" fill="#111111">÷</text>

<rect x="150" y="225" width="300" height="50" fill="#f0d9a3" fill-opacity="0.6" stroke="#b8860b" stroke-width="2" />
<text x="300" y="255" font-size="14" text-anchor="middle" font-family="sans-serif" fill="#111111">Evidence: P(B)</text>

<text x="300" y="300" font-size="14" text-anchor="middle" font-family="sans-serif" fill="#111111">= Posterior: P(A|B)</text>
</svg>

### Worked Example: Medical Testing

Given:
- $P(A) = 0.01$ (disease prevalence, prior)
- $P(B \mid A) = 0.95$ (test sensitivity, likelihood)
- $P(B \mid A^c) = 0.05$ (false positive rate)

Compute $P(A^c) = 1 - 0.01 = 0.99$.

Compute the evidence:

$$
P(B) = (0.95)(0.01) + (0.05)(0.99) = 0.0095 + 0.0495 = 0.059
$$

Apply Bayes' theorem:

$$
P(A \mid B) = \frac{0.0095}{0.059} \approx 0.161
$$

So despite a 95% sensitive test, the posterior probability of actually having the disease given a positive result is approximately 16.1%. [Inference] This low posterior relative to the seemingly high sensitivity follows directly from the low prior prevalence combined with a nonzero false-positive rate, illustrating that sensitivity alone is not sufficient to interpret a positive test result.

### Odds Form of Bayes' Theorem

Bayes' theorem can be rewritten using odds rather than probabilities. The **odds** of event $A$ are defined as $\frac{P(A)}{P(A^c)}$. The odds form is:

$$
\frac{P(A \mid B)}{P(A^c \mid B)} = \frac{P(B \mid A)}{P(B \mid A^c)} \times \frac{P(A)}{P(A^c)}
$$

[Inference] This follows by writing Bayes' theorem separately for $P(A \mid B)$ and $P(A^c \mid B)$ and dividing the two expressions, which cancels the shared denominator $P(B)$.

The ratio $\frac{P(B \mid A)}{P(B \mid A^c)}$ is called the **likelihood ratio** (or Bayes factor), and this form is often computationally convenient since it avoids explicitly computing $P(B)$.

### Sequential Bayesian Updating

When multiple independent pieces of evidence $B_1, B_2, \dots, B_n$ are observed sequentially, the posterior after observing $B_1$ becomes the prior for incorporating $B_2$:

$$
P(A \mid B_1, B_2) \propto P(B_2 \mid A) \, P(A \mid B_1)
$$

[Inference] This follows from applying Bayes' theorem again with $B_1$ already conditioned upon, under the assumption that $B_2$ is conditionally independent of $B_1$ given $A$; this conditional independence assumption does not hold automatically and must be justified for the specific problem at hand.

This sequential updating structure is the conceptual basis for Bayesian inference in online learning settings, where a model's belief about parameters is updated incrementally as new data arrives.

### Relevance to Machine Learning

- **Naive Bayes classifiers** (covered in a later module) apply Bayes' theorem directly, combined with a conditional independence assumption across features, to compute $P(y \mid x_1, \dots, x_n)$.
- **Bayesian inference** in general uses this theorem to update a prior distribution over model parameters into a posterior distribution after observing data: $P(\theta \mid D) \propto P(D \mid \theta) P(\theta)$.
- **Bayesian model selection** uses the evidence term $P(B)$ (also called the marginal likelihood) to compare competing models.
- [Unverified] Whether a specific deployed ML system uses exact Bayesian updating versus an approximation (e.g., variational inference, MCMC sampling) cannot be determined without inspecting that system's implementation directly; this document describes the underlying mathematical identity only, not the behavior of any particular software system, and such behavior is not guaranteed to follow this idealized form.

### Common Pitfalls

- Confusing $P(A \mid B)$ with $P(B \mid A)$, the same base-rate-related error introduced in the conditional probability module.
- Neglecting the prior entirely and reasoning only from the likelihood, sometimes called "base rate neglect" — illustrated in the medical testing example, where a high-sensitivity test still produces a low posterior under a low prior.
- Assuming conditional independence between successive pieces of evidence in sequential updating without verifying it holds for the specific problem.
- Applying Bayes' theorem with an incorrectly specified partition when using the generalized multi-event form, which invalidates the denominator computation.

**Related Topics**
- Naive Bayes classifiers and conditional independence assumptions
- Bayesian parameter estimation and posterior distributions
- Prior and posterior distributions in Bayesian inference
- Maximum a posteriori (MAP) estimation
- Likelihood functions and maximum likelihood estimation
- Bayesian model comparison and marginal likelihood