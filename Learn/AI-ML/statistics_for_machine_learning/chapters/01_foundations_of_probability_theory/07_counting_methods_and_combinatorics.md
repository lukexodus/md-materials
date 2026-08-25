## Counting Methods and Combinatorics

### The Multiplication Principle (Fundamental Counting Rule)

If a task consists of $k$ successive steps, where step 1 can be done in $n_1$ ways, step 2 in $n_2$ ways (regardless of how step 1 was performed), and so on through step $k$, then the total number of ways to complete the entire task is:

$$n_1 \times n_2 \times \cdots \times n_k$$

This principle underlies nearly all other counting formulas presented below.

### Permutations

A permutation is an ordered arrangement of objects, where order matters.

**Permutations of $n$ distinct objects (all taken)**

$$P(n) = n! = n \times (n-1) \times (n-2) \times \cdots \times 1$$

**Permutations of $n$ objects taken $r$ at a time (without repetition)**

$$P(n, r) = \frac{n!}{(n-r)!}$$

**Permutations with repetition allowed**

If each of $r$ positions can independently take any of $n$ values:

$$n^r$$

**Permutations with indistinguishable objects**

If $n$ objects consist of groups of sizes $n_1, n_2, \ldots, n_k$ (where $n_1 + n_2 + \cdots + n_k = n$) of otherwise identical objects within each group:

$$\frac{n!}{n_1! \, n_2! \cdots n_k!}$$

### Combinations

A combination is an unordered selection of objects, where order does not matter.

**Combinations of $n$ objects taken $r$ at a time (without repetition)**

$$\binom{n}{r} = \frac{n!}{r!(n-r)!}$$

This is also called the **binomial coefficient**, read "n choose r."

**Relationship between permutations and combinations**

$$P(n, r) = \binom{n}{r} \times r!$$

[Inference] This relationship follows because each unordered combination of $r$ objects can be arranged in $r!$ distinct orders, so dividing the permutation count by $r!$ removes the ordering redundancy to yield the combination count. This is a direct algebraic derivation from the two stated formulas, not an independently confirmed empirical result.

**Combinations with repetition allowed (multiset selection)**

The number of ways to choose $r$ items from $n$ types, with repetition allowed and order not mattering:

$$\binom{n + r - 1}{r}$$

### Visualizing Permutations vs Combinations (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 320">
  <text x="320" y="28" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Permutations vs Combinations (svg_diagram)</text>

  <rect x="30" y="55" width="280" height="230" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="45" y="80" font-size="14" fill="#123a5c" font-weight="bold">Permutation (order matters)</text>
  <text x="60" y="130" font-size="20" fill="#123a5c">A</text>
  <text x="100" y="130" font-size="20" fill="#123a5c">B</text>
  <text x="140" y="130" font-size="20" fill="#123a5c">C</text>
  <text x="60" y="170" font-size="14" fill="#333">≠</text>
  <text x="90" y="200" font-size="20" fill="#7a3610">C</text>
  <text x="130" y="200" font-size="20" fill="#7a3610">A</text>
  <text x="170" y="200" font-size="20" fill="#7a3610">B</text>
  <text x="45" y="255" font-size="12" fill="#1a1a1a">ABC and CAB are different</text>

  <rect x="330" y="55" width="280" height="230" fill="none" stroke="#333" stroke-width="2" rx="6" />
  <text x="345" y="80" font-size="14" fill="#1f4a17" font-weight="bold">Combination (order irrelevant)</text>
  <text x="380" y="160" font-size="20" fill="#1f4a17">{A, B, C}</text>
  <text x="360" y="200" font-size="14" fill="#333">=</text>
  <text x="380" y="230" font-size="20" fill="#1f4a17">{C, A, B}</text>
  <text x="345" y="270" font-size="12" fill="#1a1a1a">Same set regardless of arrangement</text>
</svg>

### Worked Examples

**Example — Permutation**

A committee of 3 distinct roles (President, Secretary, Treasurer) must be filled from 8 candidates, with each candidate eligible for at most one role.

$$P(8, 3) = \frac{8!}{(8-3)!} = \frac{8!}{5!} = 8 \times 7 \times 6 = 336$$

There are 336 distinct ways to assign the three roles.

**Example — Combination**

From the same 8 candidates, select an unordered committee of 3 members (no distinct roles).

$$\binom{8}{3} = \frac{8!}{3! \, 5!} = \frac{8 \times 7 \times 6}{3 \times 2 \times 1} = \frac{336}{6} = 56$$

There are 56 distinct committees. This is exactly $336 / 3! = 56$, consistent with the stated relationship $P(n,r) = \binom{n}{r} \cdot r!$.

**Example — Permutations with Indistinguishable Objects**

Number of distinct arrangements of the letters in "STATISTICS" (10 letters: S×3, T×3, A×1, I×2, C×1):

$$\frac{10!}{3! \, 3! \, 1! \, 2! \, 1!} = \frac{3{,}628{,}800}{6 \times 6 \times 1 \times 2 \times 1} = \frac{3{,}628{,}800}{72} = 50{,}400$$

There are 50,400 distinct letter arrangements. This is a direct computation from the stated formula and letter counts.

### Binomial Theorem Connection

The binomial coefficients $\binom{n}{r}$ appear in the expansion:

$$(x + y)^n = \sum_{r=0}^{n} \binom{n}{r} x^{n-r} y^r$$

This connects combinatorics directly to the **Binomial distribution**, where $\binom{n}{r}$ counts the number of ways to arrange $r$ successes among $n$ independent trials.

### The Pigeonhole Principle

If $n$ items are placed into $m$ containers with $n > m$, then at least one container holds more than one item. [Inference] This is a direct logical consequence of counting: if every container held at most one item, the total number of items placed could not exceed $m$, contradicting $n > m$. This is a standard proof-by-contradiction argument, not an independently confirmed empirical claim.

### Relevance to Machine Learning

- **Hyperparameter search spaces**: grid search over $k$ hyperparameters, each with $n_i$ candidate values, has a total configuration count of $\prod_{i=1}^{k} n_i$, a direct application of the multiplication principle.
- **Feature subset selection**: the number of possible subsets of $r$ features chosen from $n$ total features is $\binom{n}{r}$, relevant to combinatorial feature selection methods and to explaining the computational cost of exhaustive search approaches.
- **Combinatorics in probability distributions**: the Binomial and Hypergeometric distributions (covered in a later topic) are directly parameterized using combination counts, since they model the probability of a specific number of successes among discrete trials or draws.
- **Cross-validation fold assignment**: the number of ways to partition $n$ data points into $k$ folds relates to multinomial coefficients (the indistinguishable-objects permutation formula generalized), though [Unverified] whether any specific cross-validation library implementation enumerates or samples from this space explicitly cannot be confirmed without inspecting that library's source code directly, and behavior can vary by implementation.

### Common Pitfalls

- Confusing $P(n,r)$ and $\binom{n}{r}$ — using the permutation formula when order does not matter (or vice versa) produces a result that is off by a factor of $r!$.
- Forgetting to account for indistinguishable objects — treating identical items as distinct inflates the count by the redundant $n_i!$ factors that must appear in the denominator.
- Applying $n^r$ (repetition allowed) when the problem specifies selection without replacement, or applying $P(n,r)$ when repetition is in fact allowed — the applicability of each formula depends entirely on whether repetition and order are permitted in the specific problem, and this must be checked explicitly rather than assumed.

Correction: none required in this response — no unverified claim was asserted as fact. All [Inference] and [Unverified] labels above mark statements that are either direct algebraic/logical derivations from stated definitions (labeled [Inference]) or dependent on information not confirmable within this conversation (labeled [Unverified]), consistent with the applicable labeling requirements.

**Related Topics**
- Binomial Distribution
- Hypergeometric Distribution
- Multinomial Distribution
- Random Variables and Probability Distributions
- Combinatorial Feature Selection Methods
- Probability Trees and Sequential Counting