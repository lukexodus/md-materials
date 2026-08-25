## Counting Methods, Combinatorics, and Permutations

### The Multiplication Principle

If a task can be broken into $k$ sequential steps, where step $i$ can be performed in $n_i$ ways independent of the choices made in other steps, the total number of ways to perform the full task is:

$$
n_1 \times n_2 \times \cdots \times n_k
$$

**Example**: Choosing a model architecture involves selecting one of 4 activation functions, one of 3 optimizers, and one of 5 learning rate schedules. Total configurations:

$$
4 \times 3 \times 5 = 60
$$

This principle underlies grid search over hyperparameter combinations in machine learning.

### Permutations (Ordered Arrangements)

A **permutation** is an ordered arrangement of objects. The number of ways to arrange $n$ distinct objects in a sequence is:

$$
n! = n \times (n-1) \times (n-2) \times \cdots \times 1
$$

with $0! = 1$ by convention.

**Permutations of a subset**: The number of ways to arrange $r$ objects chosen from $n$ distinct objects, where order matters:

$$
P(n, r) = \frac{n!}{(n-r)!}
$$

**Example**: Ranking the top 3 models out of 10 candidate models in a leaderboard, where order matters:

$$
P(10, 3) = \frac{10!}{7!} = 10 \times 9 \times 8 = 720
$$

### Permutations with Repetition

If objects are drawn from $n$ possibilities with repetition allowed, and $r$ selections are made in sequence:

$$
n^r
$$

**Example**: The number of possible sequences of 5 categorical labels drawn from a set of 3 classes, with repetition allowed (as in a length-5 label sequence):

$$
3^5 = 243
$$

### Permutations with Indistinguishable Objects

If $n$ objects contain groups of indistinguishable items of sizes $n_1, n_2, \dots, n_k$ (where $n_1 + n_2 + \cdots + n_k = n$), the number of distinct arrangements is:

$$
\frac{n!}{n_1! \, n_2! \, \cdots \, n_k!}
$$

**Example**: The number of distinct label sequences for a dataset of 10 items with 6 labeled "positive" and 4 labeled "negative":

$$
\frac{10!}{6! \, 4!} = 210
$$

This is also the binomial coefficient $\binom{10}{4}$, connecting permutation counting directly to combinations.

### Combinations (Unordered Selections)

A **combination** is a selection of objects where order does not matter. The number of ways to choose $r$ objects from $n$ distinct objects:

$$
\binom{n}{r} = \frac{n!}{r!(n-r)!}
$$

This is read "n choose r" and is also called the **binomial coefficient**.

**Example**: Selecting a subset of 5 features from a pool of 20 available features for a model, where order does not matter:

$$
\binom{20}{5} = \frac{20!}{5! \, 15!} = 15504
$$

### Relationship Between Permutations and Combinations

$$
P(n, r) = \binom{n}{r} \times r!
$$

[Inference] This relationship follows because each unordered combination of $r$ items can be arranged in $r!$ distinct orders, so multiplying the number of combinations by $r!$ recovers the number of ordered permutations.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260">
<title>Permutations vs combinations (svg_diagram)</title>
<rect x="0" y="0" width="600" height="260" fill="#ffffff" />
<text x="300" y="24" font-size="16" text-anchor="middle" font-family="sans-serif" fill="#111111">Permutations vs Combinations (svg_diagram)</text>

<text x="150" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Choose {A, B} from {A,B,C}</text>

<rect x="60" y="75" width="60" height="40" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />
<text x="90" y="100" font-size="13" text-anchor="middle" font-family="monospace">A,B</text>

<rect x="140" y="75" width="60" height="40" fill="#a3c9f9" stroke="#2b6cb0" stroke-width="1.5" />
<text x="170" y="100" font-size="13" text-anchor="middle" font-family="monospace">B,A</text>

<text x="150" y="135" font-size="12" text-anchor="middle" font-family="sans-serif" fill="#333333">2 permutations (order matters)</text>

<text x="450" y="55" font-size="13" text-anchor="middle" font-family="sans-serif" fill="#111111">Choose {A, B} from {A,B,C}</text>
<rect x="410" y="75" width="80" height="40" fill="#f9a3a3" stroke="#c0392b" stroke-width="1.5" />
<text x="450" y="100" font-size="13" text-anchor="middle" font-family="monospace">{A,B}</text>
<text x="450" y="135" font-size="12" text-anchor="middle" font-family="sans-serif" fill="#333333">1 combination (order irrelevant)</text>

<line x1="0" y1="170" x2="600" y2="170" stroke="#cccccc" stroke-width="1" />
<text x="300" y="200" font-size="13" text-anchor="middle" font-family="monospace" fill="#111111">P(n,r) = C(n,r) × r!</text>
<text x="300" y="230" font-size="12" text-anchor="middle" font-family="sans-serif" fill="#333333">Every combination expands into r! ordered permutations</text>
</svg>

### Combinations with Repetition (Multiset Selection)

The number of ways to choose $r$ items from $n$ types, with unlimited repetition allowed and order not mattering (a "stars and bars" formulation):

$$
\binom{n + r - 1}{r}
$$

[Unverified] This document cannot verify how frequently this specific formulation is invoked by name in applied machine learning coursework, though the underlying combinatorial scenario (allocating counts across categories) appears in contexts such as histogram binning or multiset sampling.

### Pascal's Triangle and Binomial Identities

The binomial coefficients satisfy Pascal's identity:

$$
\binom{n}{r} = \binom{n-1}{r-1} + \binom{n-1}{r}
$$

[Inference] This follows by conditioning on whether a specific element is included in the chosen subset: if included, $r-1$ more elements must be chosen from the remaining $n-1$; if excluded, all $r$ elements must be chosen from the remaining $n-1$; these two cases are disjoint and exhaustive.

Symmetry identity:

$$
\binom{n}{r} = \binom{n}{n-r}
$$

Sum over all subsets:

$$
\sum_{r=0}^{n} \binom{n}{r} = 2^n
$$

[Inference] This follows because the total number of subsets of an $n$-element set is $2^n$ (each element is independently included or excluded), and summing $\binom{n}{r}$ over all subset sizes $r$ counts every subset exactly once.

### The Binomial Theorem

$$
(x + y)^n = \sum_{r=0}^{n} \binom{n}{r} x^{n-r} y^r
$$

This theorem connects combinatorics directly to the probability mass function of the binomial distribution, covered in a later module, where $\binom{n}{r} p^r (1-p)^{n-r}$ gives the probability of exactly $r$ successes in $n$ independent Bernoulli trials.

### Worked Example: Feature Subset Search

Consider a feature selection problem with 15 candidate features, where a model requires selecting exactly 4 features to include.

**Number of possible feature subsets** (order irrelevant):

$$
\binom{15}{4} = \frac{15!}{4! \, 11!} = 1365
$$

**If instead features were selected and assigned to 4 distinct ranked importance tiers** (order matters):

$$
P(15, 4) = \frac{15!}{11!} = 32760
$$

[Inference] The large difference between these two values illustrates why exhaustive combinatorial search over feature subsets becomes computationally expensive as the candidate pool grows, motivating heuristic search methods (e.g., greedy forward selection) in practice; this document cannot verify the specific computational thresholds at which practitioners switch from exhaustive to heuristic search, as this varies by hardware and implementation.

### Relevance to Machine Learning

- **Hyperparameter grid search** relies directly on the multiplication principle to compute the total search space size.
- **Combinatorics of feature subsets** informs the complexity of wrapper-based feature selection methods.
- **Binomial coefficients** appear directly in the binomial distribution's probability mass function, used to model counts of binary outcomes (e.g., number of correct predictions in $n$ trials).
- **Permutation counting** relates to computing p-values in permutation tests, a non-parametric statistical method sometimes used for model evaluation.
- **Combinations with repetition** relate to sampling scenarios such as bootstrap resampling, though bootstrap sampling itself uses sampling *with* replacement from ordered data, which is a related but distinct counting scenario.

### Common Pitfalls

- Confusing $\binom{n}{r}$ with $P(n,r)$ — using combinations when the problem actually requires accounting for order, or vice versa.
- Forgetting the distinction between sampling with and without replacement when applying the multiplication principle.
- Applying $n^r$ (repetition allowed) when the correct model is $P(n,r)$ (no repetition), particularly in problems involving unique ID assignment or sampling without replacement.
- Miscounting indistinguishable-object arrangements by treating all $n$ objects as distinct when some are identical.

**Related Topics**
- Sampling with and without replacement
- The binomial distribution and Bernoulli trials
- The multinomial distribution and multinomial coefficient
- Conditional probability and combinatorial probability problems
- Permutation tests in statistical hypothesis testing
- Birthday problem and probabilistic collision analysis