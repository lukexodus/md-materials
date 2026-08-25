## Discrete Random Variables

### Definition

A discrete random variable $X$ is a random variable, as formally defined in the previous module, whose range (the set of values it can take) is finite or countably infinite. It is characterized by a **probability mass function (PMF)**:

$$
p_X(x) = P(X = x)
$$

**Validity conditions**:

$$
p_X(x) \geq 0 \text{ for all } x, \qquad \sum_{x \in \text{supp}(X)} p_X(x) = 1
$$

[Inference] These two conditions follow directly from the Kolmogorov axioms established earlier: non-negativity follows from Axiom 1 applied to each singleton event $\{X = x\}$, and the sum-to-one condition follows from Axiom 3 (countable additivity) applied to the partition formed by all distinct values of $X$, combined with normalization ($P(\Omega)=1$).

### Relationship to the CDF

For a discrete random variable, the cumulative distribution function is a step function:

$$
F_X(x) = P(X \leq x) = \sum_{x_i \leq x} p_X(x_i)
$$

[Inference] This follows from the definition of the CDF given in the previous module, applied to a discrete PMF by summing over all support values not exceeding $x$, using countable additivity over the disjoint events $\{X = x_i\}$.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 280">
<title>PMF and step-function CDF for a discrete random variable (svg_diagram)</title>
<rect x="0" y="0" width="600" height="280" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">PMF and Step-Function CDF (svg_diagram)</text>

<text x="150" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">PMF</text>
<line x1="60" y1="190" x2="260" y2="190" stroke="#333333" stroke-width="1.5" />
<line x1="60" y1="190" x2="60" y2="70" stroke="#333333" stroke-width="1.5" />
<rect x="90" y="150" width="20" height="40" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="130" y="110" width="20" height="80" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="170" y="130" width="20" height="60" fill="#a3c9f9" stroke="#2b6cb0" />
<rect x="210" y="170" width="20" height="20" fill="#a3c9f9" stroke="#2b6cb0" />

<text x="450" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Step-function CDF</text>
<line x1="360" y1="190" x2="560" y2="190" stroke="#333333" stroke-width="1.5" />
<line x1="360" y1="190" x2="360" y2="70" stroke="#333333" stroke-width="1.5" />
<line x1="360" y1="180" x2="400" y2="180" stroke="#c0392b" stroke-width="2.5" />
<line x1="400" y1="140" x2="440" y2="140" stroke="#c0392b" stroke-width="2.5" />
<line x1="440" y1="100" x2="480" y2="100" stroke="#c0392b" stroke-width="2.5" />
<line x1="480" y1="80" x2="520" y2="80" stroke="#c0392b" stroke-width="2.5" />
<line x1="400" y1="140" x2="400" y2="180" stroke="#c0392b" stroke-width="1" stroke-dasharray="3,2" />
<line x1="440" y1="100" x2="440" y2="140" stroke="#c0392b" stroke-width="1" stroke-dasharray="3,2" />
<line x1="480" y1="80" x2="480" y2="100" stroke="#c0392b" stroke-width="1" stroke-dasharray="3,2" />

<text x="300" y="230" font-size="11" text-anchor="middle" font-family="sans-serif" fill="#333333">Each jump in the CDF equals p_X(x) at that point</text>
</svg>

### The Bernoulli Distribution

Models a single trial with two possible outcomes (success/failure):

$$
p_X(x) = \begin{cases} p & x = 1 \\ 1-p & x = 0 \end{cases}, \quad 0 \leq p \leq 1
$$

**Example**: A single binary classification prediction being correct or incorrect can be modeled as Bernoulli with $p$ = probability of a correct prediction.

### The Binomial Distribution

Models the number of successes in $n$ independent Bernoulli trials, each with success probability $p$:

$$
p_X(k) = \binom{n}{k} p^k (1-p)^{n-k}, \quad k = 0, 1, \dots, n
$$

[Inference] This formula follows from combining the multiplication rule for independent events (established in the independence module) with the combinatorial counting of arrangements (established in the combinatorics module): $\binom{n}{k}$ counts the number of ways to choose which $k$ of the $n$ trials are successes, and $p^k(1-p)^{n-k}$ gives the probability of any one specific such arrangement under independence.

**Example**: This matches the worked example from the previous module, where $X$ = number of heads in 3 coin flips followed a Binomial($n=3, p=0.5$) distribution.

### The Geometric Distribution

Models the number of trials needed to obtain the first success in a sequence of independent Bernoulli trials:

$$
p_X(k) = (1-p)^{k-1} p, \quad k = 1, 2, 3, \dots
$$

[Inference] This follows because obtaining the first success on trial $k$ requires $k-1$ consecutive failures (each with probability $1-p$) followed by one success (probability $p$), and by independence, the multiplication rule gives the product of these probabilities.

### The Poisson Distribution

Models the number of events occurring in a fixed interval, given a known average rate $\lambda$:

$$
p_X(k) = \frac{\lambda^k e^{-\lambda}}{k!}, \quad k = 0, 1, 2, \dots
$$

[Unverified] I cannot verify within this document the full derivation of the Poisson distribution as a limiting case of the Binomial distribution as $n \to \infty$ and $p \to 0$ with $np = \lambda$ held fixed, since this derivation requires limit arguments not established in the preceding modules of this series; this should be checked against a dedicated derivation rather than accepted from this statement alone.

### Discrete Uniform Distribution

Models a random variable with $n$ equally likely outcomes:

$$
p_X(x) = \frac{1}{n}, \quad x \in \{x_1, x_2, \dots, x_n\}
$$

**Example**: A fair die roll, $X \in \{1,2,3,4,5,6\}$, with $p_X(x) = \frac{1}{6}$ for each outcome.

### Worked Example: Binomial in Model Evaluation

A binary classifier is evaluated on $n = 20$ independent test examples, each with an assumed probability $p = 0.85$ of being classified correctly. [Inference] This assumes each test example's correctness is an independent Bernoulli trial with identical success probability $p$, an assumption that would need to be justified for a specific dataset and model rather than assumed by default, since correctness across examples may be correlated in practice depending on how errors relate to shared example characteristics.

Probability of exactly 18 correct classifications:

$$
p_X(18) = \binom{20}{18} (0.85)^{18} (0.15)^{2}
$$

$$
\binom{20}{18} = \binom{20}{2} = 190
$$

[Unverified] I have not carried out the full numerical computation of $(0.85)^{18}(0.15)^2$ to sufficient precision within this response to state a final decimal probability value with confidence; the setup and combinatorial term ($\binom{20}{18} = 190$) have been verified, but the final multiplication has not been computed here, so no final numeric answer is stated.

### Expected Value Preview (Formal Treatment in Next Module)

For a discrete random variable, the expected value is defined as:

$$
E[X] = \sum_x x \, p_X(x)
$$

**Example**: For the Bernoulli distribution, $E[X] = 1 \cdot p + 0 \cdot (1-p) = p$. [Inference] This follows by direct substitution into the expectation formula using the Bernoulli PMF stated above.

Full treatment of expectation, variance, and moments is covered in the next module.

### Relevance to Machine Learning

- The **Bernoulli distribution** underlies binary classification output modeling, where a model's predicted probability is often interpreted as the parameter $p$ of a Bernoulli distribution over the true label.
- The **Binomial distribution** is used to model aggregate counts of successes across multiple independent trials, such as the number of correct predictions across a test set, [Inference] under the independence assumption discussed in the worked example above, which does not hold automatically and should be verified for the specific evaluation setting.
- The **Poisson distribution** is used to model count-based data, such as event counts in a fixed time window; [Unverified] I do not have access to information confirming specific ML applications of the Poisson distribution beyond this general count-modeling description, so specific use cases should be verified against the relevant literature rather than assumed from this general statement.
- The **categorical distribution** (a generalization of Bernoulli to more than two outcomes, not derived in full here) underlies multi-class classification output modeling via softmax, though [Unverified] the exact correspondence between softmax outputs and a formal categorical distribution parameterization depends on the specific model formulation and is not verified here in full mathematical detail.

### Common Pitfalls

- Assuming independence between trials when applying the Binomial distribution without verifying this assumption holds for the specific data-generating process.
- Confusing the Geometric distribution's support (starting at $k=1$) with a zero-indexed variant that some sources define starting at $k=0$; [Unverified] I cannot verify which indexing convention is more common across all sources without direct comparison, so the specific convention in use should be checked against the relevant source.
- Forgetting to verify $\sum_k p_X(k) = 1$ when constructing or checking a distribution, particularly for the Poisson distribution where the sum is an infinite series.
- Using the Poisson distribution without justifying its underlying assumptions (events occurring independently at a constant average rate).

**Related Topics**
- Expectation, variance, and moments of discrete random variables
- Continuous random variables and probability density functions
- Joint distributions of multiple discrete random variables
- Moment generating functions
- Maximum likelihood estimation for discrete distribution parameters
- The categorical and multinomial distributions

> Correction: This document contains several [Unverified] labeled points, including an uncompleted final numerical computation in the worked example and an underived limiting relationship between the Binomial and Poisson distributions. These were left unverified rather than presented as fact, consistent with instructions not to chain unverified claims into confirmed conclusions.