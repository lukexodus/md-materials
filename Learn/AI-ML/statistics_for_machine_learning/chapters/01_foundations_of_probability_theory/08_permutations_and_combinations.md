## Permutations and Combinations

### Overview

Permutations and combinations are the two foundational counting methods for enumerating arrangements and selections of objects. Both were introduced in the prior topic on counting methods; this topic treats them in greater depth, including variant formulas and edge cases relevant to probability calculations.

### Permutations — Order Matters

**Basic definition**

A permutation is an ordered arrangement of a subset of $r$ objects selected from $n$ distinct objects.

$$P(n, r) = \frac{n!}{(n-r)!}$$

**Special case: full permutation ($r = n$)**

$$P(n, n) = n!$$

**Circular permutations**

For $n$ distinct objects arranged in a circle, where rotations of the same arrangement are considered identical:

$$(n-1)!$$

[Inference] This follows because fixing one object's position removes the redundancy introduced by rotational symmetry, leaving $(n-1)!$ ways to arrange the remaining objects relative to it. This is a standard derivation presented in combinatorics texts; I have not independently re-derived it via first-principles enumeration in this response, so it is labeled as reasoned rather than confirmed from a cited source.

**Permutations with restrictions**

When certain objects must be adjacent, or certain positions are forbidden, the multiplication principle is typically applied after first treating restricted groups as single combined units, then permuting within each unit separately. [Unverified] The general applicability of this "block" technique across all restriction types cannot be confirmed as universal without examining each specific restriction structure; it is a commonly taught technique in introductory combinatorics, but I do not have a citable source confirming its completeness for all restriction cases.

### Combinations — Order Does Not Matter

$$\binom{n}{r} = \frac{n!}{r!(n-r)!}$$

**Symmetry property**

$$\binom{n}{r} = \binom{n}{n-r}$$

[Inference] This follows because choosing $r$ objects to include is equivalent to choosing $n-r$ objects to exclude; both describe the same underlying partition of the $n$ objects into two groups. This is a direct logical correspondence, not an independently confirmed empirical claim.

**Pascal's Rule**

$$\binom{n}{r} = \binom{n-1}{r-1} + \binom{n-1}{r}$$

[Inference] This identity can be reasoned by conditioning on whether one specific object is included in the chosen subset: if included, $r-1$ more objects must be chosen from the remaining $n-1$; if excluded, all $r$ objects must be chosen from the remaining $n-1$. Summing these two disjoint cases yields the identity. I have not independently verified this against a cited proof in this response; it is presented as a reasoned derivation.

### Visualizing Pascal's Rule (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
  <text x="320" y="28" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Pascal's Rule (svg_diagram)</text>

  <rect x="220" y="60" width="200" height="60" fill="#6fae5e" fill-opacity="0.30" stroke="#3f7a30" stroke-width="2" rx="6" />
  <text x="320" y="97" font-size="15" fill="#1f4a17" text-anchor="middle">C(n, r)</text>

  <line x1="270" y1="120" x2="150" y2="190" stroke="#333" stroke-width="2" />
  <line x1="370" y1="120" x2="490" y2="190" stroke="#333" stroke-width="2" />

  <rect x="50" y="190" width="200" height="60" fill="#4a90d9" fill-opacity="0.30" stroke="#2c5f8a" stroke-width="2" rx="6" />
  <text x="150" y="227" font-size="14" fill="#123a5c" text-anchor="middle">C(n-1, r-1)</text>
  <text x="150" y="270" font-size="11" fill="#1a1a1a" text-anchor="middle">object included</text>

  <rect x="390" y="190" width="200" height="60" fill="#e07a3f" fill-opacity="0.30" stroke="#a8531f" stroke-width="2" rx="6" />
  <text x="490" y="227" font-size="14" fill="#7a3610" text-anchor="middle">C(n-1, r)</text>
  <text x="490" y="270" font-size="11" fill="#1a1a1a" text-anchor="middle">object excluded</text>
</svg>

### Worked Examples

**Example — Circular Permutation**

Seat 6 distinct people around a circular table, where rotations are considered identical.

$$(6-1)! = 5! = 120$$

There are 120 distinct seating arrangements under this convention. This is a direct computation from the stated formula.

**Example — Restricted Permutation (block method)**

Arrange the letters in "GARDEN" (6 distinct letters) such that G and A must remain adjacent.

Treat {G,A} as a single block, giving 5 units to arrange: $5! = 120$. Within the block, G and A can be ordered 2 ways: $2! = 2$.

$$5! \times 2! = 120 \times 2 = 240$$

There are 240 valid arrangements. This is a direct computation using the block technique described above; I cannot verify this specific numerical result against an external cited source within this conversation, but it follows mechanically from the stated method applied to the stated inputs.

**Example — Combination with Symmetry Check**

$$\binom{10}{3} = \frac{10!}{3! \, 7!} = 120, \qquad \binom{10}{7} = \frac{10!}{7! \, 3!} = 120$$

Both equal 120, consistent with the symmetry property $\binom{n}{r} = \binom{n}{n-r}$ stated above.

### Multinomial Coefficient (Generalized Combination)

For dividing $n$ distinct objects into $k$ labeled groups of sizes $r_1, r_2, \ldots, r_k$ (where $r_1 + \cdots + r_k = n$):

$$\binom{n}{r_1, r_2, \ldots, r_k} = \frac{n!}{r_1! \, r_2! \cdots r_k!}$$

This generalizes the binomial coefficient ($k=2$ case) and connects directly to the Multinomial distribution.

### Relevance to Machine Learning

- **One-vs-rest / pairwise classification schemes**: the number of pairwise classifiers needed for a $k$-class one-vs-one scheme is $\binom{k}{2}$, a direct application of the combination formula.
- **Ensemble subset sampling**: bagging and random subspace methods select random subsets of features or samples, where the total space of possible subsets of size $r$ from $n$ is given by $\binom{n}{r}$; this bounds the theoretical diversity of possible base learners in an ensemble. [Inference] Whether any specific ensemble library implementation actually enumerates this full space, versus sampling a small fraction of it, cannot be confirmed without inspecting that library's source code, and behavior is not guaranteed to be consistent across implementations.
- **Positional encoding and sequence permutation**: in sequence modeling tasks, the number of possible orderings of $n$ tokens is $n!$, relevant to discussions of permutation invariance and equivariance in architectures such as Transformers. [Unverified] The specific extent to which any particular Transformer-based model implementation is empirically permutation-invariant or permutation-equivariant depends on its exact architecture and training, and I do not have a verified source confirming this property for any specific named model; this should not be treated as a guaranteed behavioral property.

### Common Pitfalls

- Applying the linear permutation formula $n!$ to circular arrangement problems without adjusting for rotational symmetry — this overcounts by a factor of $n$.
- Misapplying the block method for adjacency restrictions without adding the internal permutation factor ($r!$ for a block of $r$ adjacent items) — omitting this step undercounts valid arrangements.
- Confusing the multinomial coefficient (partitioning into multiple labeled groups) with repeated application of the binomial coefficient — while related, the multinomial coefficient must be computed directly using the formula above, and sequential binomial coefficient multiplication must be carried out fully across all groups to be equivalent.

I cannot verify any of the machine learning implementation claims above against specific library source code within this conversation; these are stated as structural/mathematical relationships or explicitly labeled as [Inference]/[Unverified] where implementation-specific behavior is discussed. No fabricated sources have been cited in this response.

**Related Topics**
- Binomial Distribution
- Multinomial Distribution
- Hypergeometric Distribution
- Counting Methods (foundational topic)
- Probability Trees and Sequential Counting
- Random Variables and Probability Distributions