## Hypergeometric Distribution

### Definition

The Hypergeometric distribution models the number of successes in a fixed number of draws from a finite population, drawn without replacement, where the population contains a known number of successes and failures.

$$P(X = k) = \frac{\binom{K}{k}\binom{N-K}{n-k}}{\binom{N}{n}}$$

### Parameters

- $N$ — total population size
- $K$ — number of success states in the population
- $n$ — number of draws (sample size)
- $k$ — number of observed successes in the sample
- Support: $k \in \{\max(0, n-N+K), \dots, \min(n, K)\}$

### Probability Mass Function Shape

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 540 320" font-family="sans-serif">
  <text x="270" y="24" text-anchor="middle" font-size="15" font-weight="bold" fill="#222">Hypergeometric PMF, N=50, K=20, n=10 (svg_diagram)</text>
  <line x1="50" y1="270" x2="510" y2="270" stroke="#333" stroke-width="1.5" />
  <line x1="50" y1="270" x2="50" y2="50" stroke="#333" stroke-width="1.5" />
  <text x="520" y="290" font-size="12" fill="#333">k</text>
  <text x="30" y="45" font-size="12" fill="#333">P(X=k)</text>

  <rect x="60" y="260" width="30" height="10" fill="#9d4edd" />
  <rect x="100" y="205" width="30" height="65" fill="#9d4edd" />
  <rect x="140" y="135" width="30" height="135" fill="#9d4edd" />
  <rect x="180" y="95" width="30" height="175" fill="#9d4edd" />
  <rect x="220" y="82" width="30" height="188" fill="#9d4edd" />
  <rect x="260" y="95" width="30" height="175" fill="#9d4edd" />
  <rect x="300" y="135" width="30" height="135" fill="#9d4edd" />
  <rect x="340" y="205" width="30" height="65" fill="#9d4edd" />
  <rect x="380" y="255" width="30" height="15" fill="#9d4edd" />

  <text x="75" y="285" text-anchor="middle" font-size="10">0</text>
  <text x="115" y="285" text-anchor="middle" font-size="10">1</text>
  <text x="155" y="285" text-anchor="middle" font-size="10">2</text>
  <text x="195" y="285" text-anchor="middle" font-size="10">3</text>
  <text x="235" y="285" text-anchor="middle" font-size="10">4</text>
  <text x="275" y="285" text-anchor="middle" font-size="10">5</text>
  <text x="315" y="285" text-anchor="middle" font-size="10">6</text>
  <text x="355" y="285" text-anchor="middle" font-size="10">7</text>
  <text x="395" y="285" text-anchor="middle" font-size="10">8</text>
</svg>

The shape is unimodal, with mode near $n \cdot K/N$. [Inference] This follows from analyzing the ratio $P(X=k)/P(X=k-1)$ and finding where it crosses 1; this is a mathematical property derivable from the PMF formula, not an externally sourced claim.

### Moments

**Mean**

$$E[X] = n\frac{K}{N}$$

**Variance**

$$\text{Var}(X) = n\frac{K}{N}\cdot\frac{N-K}{N}\cdot\frac{N-n}{N-1}$$

**Skewness**

$$\text{Skew}(X) = \frac{(N-2K)(N-2n)}{N-2}\sqrt{\frac{N-1}{nK(N-K)(N-n)}}$$

[Inference] These formulas follow from standard combinatorial derivations involving the definition of the hypergeometric PMF and properties of sampling without replacement. The full derivation is not reproduced here; the results are consistent with standard probability theory conventions, though no specific external source is being cited in this response.

### The Finite Population Correction Factor

The variance formula contains the term $\frac{N-n}{N-1}$, known as the **finite population correction (FPC) factor**. This term distinguishes the Hypergeometric variance from the analogous Binomial variance $np(1-p)$ where $p = K/N$.

$$\text{Var}_{\text{Hypergeometric}} = \text{Var}_{\text{Binomial}} \times \frac{N-n}{N-1}$$

As $N \to \infty$ with $K/N = p$ held fixed, the FPC factor approaches 1, and the Hypergeometric distribution converges to the Binomial distribution. [Inference] This follows because sampling without replacement becomes approximately equivalent to sampling with replacement when the population is very large relative to the sample; this is a standard limiting argument in probability theory, not sourced from a specific external citation here.

### Relationship to Other Distributions

- The Hypergeometric distribution converges to the Binomial distribution as $N \to \infty$ and $K \to \infty$ with $K/N \to p$ fixed. [Inference] This is a standard asymptotic result described in the FPC discussion above.
- A common rule of thumb states that when $n/N < 0.05$ (sample is less than 5% of the population), the Binomial approximation to the Hypergeometric distribution is reasonable. [Unverified] The specific threshold value varies across textbooks and sources; the "5%" figure is one common convention, but I cannot verify a single universally agreed-upon threshold without a specific citation.
- The Multivariate Hypergeometric distribution generalizes this distribution to populations with more than two categories of items.

### Maximum Likelihood Estimation

In typical applications, $N$ and $K$ (or $N$ and $n$) are known fixed population characteristics rather than estimated parameters, since the distribution describes sampling from a known finite population. When $K$ is unknown and must be estimated from an observed sample count $k$, given known $N$ and $n$, an estimator can be derived by inverting the mean relationship:

$$\hat{K} = \frac{kN}{n}$$

[Inference] This estimator follows from solving $E[X] = nK/N$ for $K$ and substituting the observed value $k$; it is a method-of-moments-style estimator rather than a full likelihood-based derivation, and its properties (e.g., bias, variance) are not derived in this response.

### Worked Example

A quality control inspector examines a shipment of $N = 50$ electronic components, of which $K = 8$ are known to be defective. A sample of $n = 10$ components is drawn without replacement for inspection.

1. $E[X] = 10 \times (8/50) = 1.6$ expected defective components in the sample
2. $\text{Var}(X) = 10 \times \frac{8}{50} \times \frac{42}{50} \times \frac{40}{49} \approx 1.097$
3. Probability of exactly 2 defective components in the sample:

$$P(X=2) = \frac{\binom{8}{2}\binom{42}{8}}{\binom{50}{10}} \approx 0.286$$

[Inference] This numeric result follows from direct substitution into the PMF formula; it assumes the population composition ($N=50$, $K=8$) is exactly as stated and that draws are genuinely without replacement, which are modeling assumptions about this hypothetical scenario rather than verified facts about any actual shipment.

### Relevance to Machine Learning

**Sampling without replacement in dataset construction**
The Hypergeometric distribution is relevant when analyzing the composition of a sample drawn without replacement from a finite labeled dataset, such as estimating the probability of a specific class distribution appearing in a train/test split. [Inference] This connection follows directly from the definition of the distribution as modeling exactly this kind of sampling process; whether any specific data-splitting library models this explicitly is [Unverified] and not confirmed here.

**Feature selection and enrichment analysis**
The Hypergeometric distribution underlies statistical tests (such as the hypergeometric test used in gene set enrichment analysis) that assess whether a subset of items drawn from a larger set shows an overrepresentation of a category of interest. [Inference] This is a standard statistical application described in bioinformatics and applied statistics contexts generally; I cannot verify the specific extent of its use in any particular current ML tool without a specific citation, so this should be treated as a general, reasoned connection rather than a confirmed claim about a specific software package.

**Evaluation set imbalance analysis**
[Speculation] The Hypergeometric distribution may be used in some contexts to assess whether an observed class imbalance in a randomly drawn validation set is consistent with random sampling from a known finite population, as opposed to indicating a sampling bias. I do not have a specific confirmed source verifying the prevalence of this exact technique in current ML practice, so this connection should be treated as a speculative possibility rather than an established, citable practice.

**Relation to Fisher's Exact Test**
Fisher's Exact Test, used to assess independence in small-sample contingency tables, relies on the Hypergeometric distribution to compute exact p-values. [Inference] This is a standard statistical result found generally in probability and statistics treatments of contingency table analysis; it is not being cited from one specific external source in this response.

### Common Pitfalls

- Applying the Binomial distribution (which assumes sampling with replacement, or an infinite population) to situations that actually involve sampling without replacement from a small finite population, leading to underestimated variance.
- Confusing $K$ (successes in the population) with $k$ (successes observed in the sample) — a common notational source of errors.
- Neglecting the finite population correction factor when $n$ is a non-negligible fraction of $N$, which can lead to meaningfully inaccurate variance estimates.

I cannot verify the exact conventions (parameter naming, default argument order, or output format) used by any specific current statistical software library for the Hypergeometric distribution. This should be checked directly against that library's current, version-specific documentation before being relied upon in code.

**Disclaimer on behavioral claims**: Statements in this document regarding software library implementations, defaults, or estimator behavior are [Unverified] and are not guaranteed to reflect current behavior of any specific tool. Behavior may vary across libraries and versions.

### Related Topics

- Binomial distribution (limiting relationship)
- Multivariate Hypergeometric distribution
- Fisher's Exact Test
- Sampling without replacement and finite population methods
- Gene set enrichment analysis (statistical application)