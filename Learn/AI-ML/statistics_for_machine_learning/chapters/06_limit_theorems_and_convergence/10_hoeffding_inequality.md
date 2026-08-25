## Hoeffding Inequality

### Definition

Hoeffding's inequality provides an exponential upper bound on the probability that the sum (or average) of independent, bounded random variables deviates from its expected value by more than a specified amount.

For independent random variables $X_1, X_2, \ldots, X_n$ such that each $X_i$ is almost surely bounded, $X_i \in [a_i, b_i]$, let $S_n = \sum_{i=1}^n X_i$. Then for any $\epsilon > 0$:

$$P(|S_n - E[S_n]| \geq \epsilon) \leq 2\exp\left(-\frac{2\epsilon^2}{\sum_{i=1}^n (b_i - a_i)^2}\right)$$

For the sample mean $\bar{X} = \frac{1}{n}S_n$, the equivalent form is:

$$P(|\bar{X} - E[\bar{X}]| \geq \epsilon) \leq 2\exp\left(-\frac{2n^2\epsilon^2}{\sum_{i=1}^n (b_i - a_i)^2}\right)$$

When all variables share the same range width, $b_i - a_i = c$ for all $i$, this simplifies to:

$$P(|\bar{X} - E[\bar{X}]| \geq \epsilon) \leq 2\exp\left(-\frac{2n\epsilon^2}{c^2}\right)$$

### Key Points

- Requires independence of the random variables and almost-sure boundedness within known intervals — no assumption about the specific distribution shape is needed beyond these two conditions.
- The bound decays exponentially in $n$ and in $\epsilon^2$, in contrast to Chebyshev's inequality, whose bound decays only polynomially ($1/\epsilon^2$) and does not tighten with $n$ in the same direct way unless variance scaling is applied separately.
- It is a member of the Chernoff-bound family, derived using the moment-generating function technique combined with a specific bound on the MGF of bounded random variables (Hoeffding's lemma).
- The bound depends only on the range of each variable ($b_i - a_i$), not on the variance. [Inference] This means Hoeffding's bound can be loose relative to Bernstein-type bounds when the true variance is much smaller than what the range alone would suggest, though I do not have a source quantifying this gap in general terms — it depends on the specific distribution.
- One-sided versions exist, bounding only $P(S_n - E[S_n] \geq \epsilon)$ or $P(S_n - E[S_n] \leq -\epsilon)$ individually, each with a bound of half the two-sided value.

### Hoeffding's Lemma (Building Block)

Hoeffding's inequality relies on a supporting result, Hoeffding's lemma, which bounds the moment-generating function of a bounded, zero-mean random variable.

If $X$ is a random variable with $E[X] = 0$ and $X \in [a, b]$ almost surely, then for all $t \in \mathbb{R}$:

$$E[e^{tX}] \leq \exp\left(\frac{t^2(b-a)^2}{8}\right)$$

This lemma is what introduces the $(b-a)^2$ term into the final inequality and is the key technical step distinguishing Hoeffding's inequality from a generic Chernoff bound.

### Derivation (Sketch)

The derivation follows the standard Chernoff bound technique, applied to bounded variables:

1. Apply Markov's inequality to $e^{t(S_n - E[S_n])}$ for $t > 0$:



   $$P(S_n - E[S_n] \geq \epsilon) \leq e^{-t\epsilon} \, E\left[e^{t(S_n - E[S_n])}\right]$$
2. By independence, the expectation of the product factors into a product of expectations:



   $$E\left[e^{t(S_n - E[S_n])}\right] = \prod_{i=1}^n E\left[e^{t(X_i - E[X_i])}\right]$$
3. Apply Hoeffding's lemma to each factor, since each $X_i - E[X_i]$ is zero-mean and bounded in an interval of width $b_i - a_i$:



   $$E\left[e^{t(X_i - E[X_i])}\right] \leq \exp\left(\frac{t^2(b_i-a_i)^2}{8}\right)$$
4. Combining these:



   $$P(S_n - E[S_n] \geq \epsilon) \leq \exp\left(-t\epsilon + \frac{t^2}{8}\sum_{i=1}^n (b_i-a_i)^2\right)$$
5. Minimizing the right-hand side over $t > 0$ (by setting the derivative to zero) yields the optimal $t^* = \frac{4\epsilon}{\sum(b_i-a_i)^2}$, which produces the one-sided bound:



   $$P(S_n - E[S_n] \geq \epsilon) \leq \exp\left(-\frac{2\epsilon^2}{\sum_{i=1}^n (b_i-a_i)^2}\right)$$
6. Applying the same argument to $-(S_n - E[S_n])$ and combining both tails via a union bound gives the factor of 2 in the two-sided inequality.

### Worked Example

Suppose $n = 50$ independent coin flips are modeled as $X_i \in \{0, 1\}$ (so $a_i = 0$, $b_i = 1$ for all $i$), with unknown true bias $p$. Let $\bar{X}$ be the sample proportion of heads.

**Question:** Bound the probability that the sample proportion deviates from the true mean by 0.15 or more.

Here $c = b_i - a_i = 1$, $n = 50$, $\epsilon = 0.15$:

$$P(|\bar{X} - p| \geq 0.15) \leq 2\exp\left(-\frac{2(50)(0.15)^2}{1}\right) = 2\exp(-2.25) \approx 2(0.1054) \approx 0.2108$$

**Interpretation:** With 50 samples, there is an upper bound of approximately 21.1% probability that the observed proportion deviates from the true bias by 0.15 or more. This is a worst-case bound applicable regardless of the true value of $p$, since Hoeffding's inequality does not require knowledge of the distribution beyond boundedness.

**Comparison at larger $n$:** If $n = 500$ instead, holding $\epsilon = 0.15$ fixed:

$$P(|\bar{X} - p| \geq 0.15) \leq 2\exp\left(-\frac{2(500)(0.15)^2}{1}\right) = 2\exp(-22.5) \approx 3.4 \times 10^{-10}$$

This illustrates the exponential sensitivity to sample size $n$: increasing $n$ tenfold drives the bound down by many orders of magnitude, a pattern distinct from Chebyshev-type polynomial bounds.

### Use in Machine Learning

- **PAC learning generalization bounds**: Hoeffding's inequality is a standard tool for bounding the difference between empirical risk (training error) and true risk (expected error) for a fixed hypothesis, when the loss function is bounded (e.g., 0-1 loss).
- **Sample complexity analysis**: Used to derive how many samples $n$ are needed so that empirical estimates fall within $\epsilon$ of the true value with a specified confidence level $1 - \delta$.
- **Cross-validation and model evaluation**: [Inference] Provides a theoretical basis for understanding how test-set accuracy estimates relate to true generalization performance, though I do not have a source confirming how directly this bound is applied in standard cross-validation reporting practices versus used only as background theory.
- **Multi-armed bandit algorithms**: Used in constructing confidence bounds for reward estimates in algorithms such as UCB (Upper Confidence Bound), where bounded rewards allow direct application of Hoeffding-style concentration.
- **A/B testing and statistical significance**: [Inference] Can provide distribution-free bounds on how much an observed conversion-rate difference might deviate from the true difference, though I cannot confirm without a specific source how commonly Hoeffding's inequality specifically (versus other statistical tests) is used in industry A/B testing pipelines.

### Comparison Table

| Inequality | Requires | Decay Rate | Uses Variance? |
| --- | --- | --- | --- |
| Chebyshev | Finite mean, variance | Polynomial ($1/\epsilon^2$) | Yes |
| Hoeffding | Bounded RVs, independence | Exponential ($e^{-c n\epsilon^2}$) | No (range only) |
| Bernstein | Bounded RVs, independence, known variance | Exponential, tighter when variance is small | Yes |

### Visualization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 720 400" font-family="Arial, sans-serif">
<text x="360" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Hoeffding Bound: Effect of Sample Size n (svg_diagram)</text>

<line x1="80" y1="340" x2="670" y2="340" stroke="#333" stroke-width="2" />
<line x1="80" y1="340" x2="80" y2="60" stroke="#333" stroke-width="2" />
<text x="380" y="365" text-anchor="middle" font-size="13" fill="#333">Sample size (n)</text>
<text x="35" y="200" text-anchor="middle" font-size="13" fill="#333" transform="rotate(-90 35 200)">Upper bound on P(|X̄-μ|≥ε)</text>

<line x1="200" y1="340" x2="200" y2="60" stroke="#eee" stroke-width="1" />
<line x1="320" y1="340" x2="320" y2="60" stroke="#eee" stroke-width="1" />
<line x1="440" y1="340" x2="440" y2="60" stroke="#eee" stroke-width="1" />
<line x1="560" y1="340" x2="560" y2="60" stroke="#eee" stroke-width="1" />
<line x1="670" y1="340" x2="670" y2="60" stroke="#eee" stroke-width="1" />

<text x="200" y="356" text-anchor="middle" font-size="11" fill="#333">50</text>

<text x="320" y="356" text-anchor="middle" font-size="11" fill="#333">150</text>

<text x="440" y="356" text-anchor="middle" font-size="11" fill="#333">300</text>

<text x="560" y="356" text-anchor="middle" font-size="11" fill="#333">450</text>

<text x="670" y="356" text-anchor="middle" font-size="11" fill="#333">600</text>



<text x="70" y="340" text-anchor="end" font-size="11" fill="#333">0.0</text>

<text x="70" y="256" text-anchor="end" font-size="11" fill="#333">0.25</text>

<text x="70" y="172" text-anchor="end" font-size="11" fill="#333">0.5</text>

<text x="70" y="88" text-anchor="end" font-size="11" fill="#333">0.75</text>



<path d="M 130 90 Q 170 220 200 280 Q 250 325 320 337 Q 400 339.7 500 340 L 670 340" fill="none" stroke="`#2980b9`" stroke-width="3" />

<text x="130" y="80" font-size="11" fill="#666">n=25: bound≈0.65</text>

<text x="210" y="270" font-size="11" fill="#666">n=50: bound≈0.21</text>

<text x="330" y="330" font-size="11" fill="#666">n=150: bound≈0.001</text>

</svg>

### Limitations

- **Independence requirement**: Standard Hoeffding's inequality requires independent random variables. Dependent data (e.g., time series, Markov chains) requires modified versions, such as Hoeffding-type bounds for martingales (Azuma-Hoeffding inequality).
- **Boundedness requirement**: Cannot be applied to unbounded random variables without truncation or a different technique (e.g., sub-Gaussian or sub-exponential concentration bounds for unbounded but light-tailed variables).
- **Ignores variance**: Because it only uses the range $(b_i - a_i)$, Hoeffding's bound does not become tighter when the true variance is low. [Inference] In such low-variance cases, Bernstein's inequality (which incorporates variance) would generally produce a tighter bound, though the precise improvement depends on the specific variance-to-range ratio in a given problem and I do not have a general formula to cite for the typical size of this improvement across use cases.
- **Bound is worst-case**: Hoeffding's inequality is agnostic to the true underlying distribution within the stated bounds, so it is calibrated to the worst-case distribution consistent with the given range — actual concentration may be substantially better for specific distributions. I cannot state how much better without specifying the actual distribution.

> Correction: An earlier response in this conversation referred to Hoeffding's inequality as producing bounds that are "tight" in an unqualified sense when compared to Chebyshev's inequality. That characterization did not clearly distinguish "tighter than Chebyshev in typical cases" from a general claim of absolute tightness. This response instead specifies that Hoeffding's inequality is tighter *when boundedness holds and variance is not much smaller than the range would suggest*; whether it is the tightest available bound in a given situation depends on what additional structure (e.g., known variance) is available, and no inequality in this family is described here as guaranteeing exact or optimal tightness in all cases.

### Next Steps

- Hoeffding's lemma — full derivation
- Bernstein inequality — incorporating variance for tighter bounds
- Azuma-Hoeffding inequality for martingales and dependent sequences
- Sub-Gaussian random variables and concentration
- PAC learning framework — formal sample complexity derivations
- Upper Confidence Bound (UCB) algorithms in multi-armed bandits
- Union bound and uniform convergence over hypothesis classes