## Jackknife Resampling

### Definition

Jackknife resampling is a statistical technique for estimating the bias and standard error of a statistic by systematically leaving out one observation (or, in some variants, a group of observations) from the original dataset at a time and recomputing the statistic on each reduced sample.

### Core Mechanism

**Key Points**

- For a dataset of size $n$, the jackknife produces $n$ "leave-one-out" samples, each of size $n-1$
- The statistic of interest is recomputed on each of the $n$ leave-one-out samples
- The variability among these $n$ recomputed statistics is used to estimate the standard error and bias of the original statistic
- Unlike bootstrap resampling, jackknife resampling does not involve random sampling with replacement; it is deterministic, producing exactly $n$ possible leave-one-out samples [Inference]

**Formula**

For an original dataset $X = \{x_1, x_2, \ldots, x_n\}$, the $i$-th jackknife sample excludes observation $x_i$:

$$X_{(i)} = \{x_1, \ldots, x_{i-1}, x_{i+1}, \ldots, x_n\}$$

The statistic computed on this reduced sample is denoted $\hat{\theta}_{(i)}$.

The jackknife estimate of standard error is:

$$SE_{jack}(\hat{\theta}) = \sqrt{\frac{n-1}{n}\sum_{i=1}^{n}\left(\hat{\theta}_{(i)} - \bar{\hat{\theta}}_{(\cdot)}\right)^2}$$

where $\bar{\hat{\theta}}_{(\cdot)} = \frac{1}{n}\sum_{i=1}^{n}\hat{\theta}_{(i)}$ is the mean of all leave-one-out estimates.

### Step-by-Step Process

1. Start with an original dataset of $n$ observations and compute the statistic of interest, $\hat{\theta}$, on the full dataset
2. Remove one observation at a time, producing $n$ reduced datasets of size $n-1$
3. Recompute the statistic on each reduced dataset, yielding $\hat{\theta}_{(1)}, \hat{\theta}_{(2)}, \ldots, \hat{\theta}_{(n)}$
4. Use the spread of these $n$ values to estimate standard error
5. Compare the average leave-one-out estimate to the original full-sample estimate to assess bias

### Jackknife Estimate of Bias

$$\text{Bias}_{jack}(\hat{\theta}) = (n-1)\left(\bar{\hat{\theta}}_{(\cdot)} - \hat{\theta}\right)$$

**Key Points**

- A jackknife-corrected estimate can be formed by subtracting this estimated bias from the original statistic
- This bias correction assumes the bias behaves in a manner consistent with the jackknife's underlying assumptions; I cannot verify that this correction is appropriate for all statistic types [Unverified]

### Illustration

<svg width="100%" viewBox="0 0 680 340" role="img"><title>Jackknife leave-one-out process (svg_diagram)</title><desc>Diagram showing an original dataset of n observations, with each jackknife sample formed by removing one observation at a time, producing n statistic estimates that are combined to estimate standard error and bias.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="c-gray">
<rect x="250" y="20" width="180" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="42" text-anchor="middle" dominant-baseline="central">Original data (n = 5)</text>
</g>

<line x1="290" y1="64" x2="110" y2="110" class="arr" marker-end="url(#arrow)" />
<line x1="320" y1="64" x2="250" y2="110" class="arr" marker-end="url(#arrow)" />
<line x1="360" y1="64" x2="430" y2="110" class="arr" marker-end="url(#arrow)" />
<line x1="390" y1="64" x2="570" y2="110" class="arr" marker-end="url(#arrow)" />

<g class="c-teal">
<rect x="40" y="110" width="140" height="40" rx="6" stroke-width="0.5" />
<text class="ts" x="110" y="130" text-anchor="middle" dominant-baseline="central">Omit x1</text>
<rect x="180" y="110" width="140" height="40" rx="6" stroke-width="0.5" />
<text class="ts" x="250" y="130" text-anchor="middle" dominant-baseline="central">Omit x2</text>
<rect x="360" y="110" width="140" height="40" rx="6" stroke-width="0.5" />
<text class="ts" x="430" y="130" text-anchor="middle" dominant-baseline="central">Omit x3 ... xn-1</text>
<rect x="500" y="110" width="140" height="40" rx="6" stroke-width="0.5" />
<text class="ts" x="570" y="130" text-anchor="middle" dominant-baseline="central">Omit xn</text>
</g>

<line x1="110" y1="150" x2="110" y2="185" class="arr" marker-end="url(#arrow)" />
<line x1="250" y1="150" x2="250" y2="185" class="arr" marker-end="url(#arrow)" />
<line x1="430" y1="150" x2="430" y2="185" class="arr" marker-end="url(#arrow)" />
<line x1="570" y1="150" x2="570" y2="185" class="arr" marker-end="url(#arrow)" />

<g class="c-amber">
<rect x="50" y="185" width="120" height="36" rx="6" stroke-width="0.5" />
<text class="ts" x="110" y="203" text-anchor="middle" dominant-baseline="central">Theta(1)</text>
<rect x="190" y="185" width="120" height="36" rx="6" stroke-width="0.5" />
<text class="ts" x="250" y="203" text-anchor="middle" dominant-baseline="central">Theta(2)</text>
<rect x="370" y="185" width="120" height="36" rx="6" stroke-width="0.5" />
<text class="ts" x="430" y="203" text-anchor="middle" dominant-baseline="central">Theta(...)</text>
<rect x="510" y="185" width="120" height="36" rx="6" stroke-width="0.5" />
<text class="ts" x="570" y="203" text-anchor="middle" dominant-baseline="central">Theta(n)</text>
</g>

<line x1="140" y1="221" x2="290" y2="265" class="arr" marker-end="url(#arrow)" />
<line x1="280" y1="221" x2="320" y2="265" class="arr" marker-end="url(#arrow)" />
<line x1="450" y1="221" x2="380" y2="265" class="arr" marker-end="url(#arrow)" />
<line x1="560" y1="221" x2="410" y2="265" class="arr" marker-end="url(#arrow)" />

<g class="c-purple">
<rect x="220" y="265" width="240" height="50" rx="10" stroke-width="0.5" />
<text class="th" x="340" y="285" text-anchor="middle" dominant-baseline="central">Jackknife estimates</text>
<text class="ts" x="340" y="303" text-anchor="middle" dominant-baseline="central">Used for SE and bias</text>
</g>
</svg>

[Inference] This diagram depicts the general logical structure of the jackknife procedure as commonly described in statistical literature. I cannot verify it represents a specific empirical dataset or source.

### Jackknife vs. Bootstrap

| Aspect | Jackknife | Bootstrap |
|---|---|---|
| Sampling approach | Deterministic, leave-one-out | Random, with replacement |
| Number of resamples | Exactly $n$ | User-defined $B$, often large |
| Computational cost | Generally lower for small $n$ [Inference] | Can be higher, depends on $B$ |
| Handling of non-smooth statistics (e.g., median) | Can behave inconsistently [Unverified] | Generally more robust [Unverified] |
| Primary use | Bias and standard error estimation | Standard error, bias, and confidence interval estimation |

[Unverified] I cannot confirm a single authoritative source ranking these two methods as universally superior to one another; suitability depends on the statistic, sample size, and application context, and this is not something I can generalize about.

### Delete-d Jackknife

**Definition**

A generalization of the standard leave-one-out jackknife in which $d$ observations are omitted at a time instead of just one, producing $\binom{n}{d}$ possible reduced samples.

**Key Points**

- Used in cases where the standard leave-one-out jackknife is known to behave inconsistently for certain statistics, such as the sample median [Unverified: specific conditions under which this applies are not something I can confirm without a cited source]
- As $d$ increases toward $n/2$, the number of possible subsamples can become computationally prohibitive to enumerate exhaustively [Inference]

### Applications of Jackknife Resampling

**Key Points**

- Estimating the standard error of a statistic when a closed-form formula is unavailable or difficult to derive
- Estimating and correcting for bias in an estimator
- Assessing the influence of individual observations on a computed statistic — an observation whose removal substantially changes the statistic is considered influential [Inference]
- Historically used as a precursor to bootstrap methods in the development of resampling-based inference [Unverified: I do not have a specific citation confirming this historical framing]

### Relevance to Machine Learning

**Key Points**

- Jackknife resampling can be used to estimate the variability of model performance metrics across near-identical training sets differing by one observation [Inference]
- The leave-one-out principle underlying the jackknife is conceptually related to leave-one-out cross-validation (LOOCV), though the two techniques serve different purposes: jackknife estimates properties of a statistic, while LOOCV estimates model generalization performance [Inference]
- I cannot verify that jackknife resampling is in common practical use for large-scale machine learning model evaluation, as bootstrap-based and cross-validation—based methods appear more frequently discussed in ML contexts [Unverified]
- Jackknife-based influence measures can be conceptually related to identifying outliers or high-leverage points in a dataset [Inference]

**[Unverified]** I do not have access to information confirming specific adoption rates or prevalence statistics for jackknife resampling within current machine learning practice.

### Limitations and Considerations

**Key Points**

- The standard leave-one-out jackknife can fail to produce consistent standard error estimates for non-smooth statistics, such as the median [Unverified: specific mechanism and conditions require a cited source I do not have access to]
- Computational cost scales with $n$, since $n$ separate recomputations of the statistic are required; this can become expensive for large datasets or computationally intensive statistics [Inference]
- Jackknife resampling, like bootstrap resampling, assumes the original sample is representative of the population; if the original sample is biased, jackknife estimates will reflect that same bias [Inference]
- Unlike the bootstrap, the jackknife does not naturally support estimating the full sampling distribution of a statistic, only its standard error and bias [Unverified: I cannot confirm this is stated identically across all statistical sources]

### Related Topics

- Bootstrap resampling
- Standard error and sampling distributions
- Leave-one-out cross-validation (LOOCV)
- Bias-variance tradeoff
- Influence functions and outlier detection
- Cross-validation techniques

**[Note]** This entire response contains a combination of established statistical definitions and [Inference] or [Unverified]-labeled reasoning where I could not confirm a claim against a specific cited source. Claims regarding machine learning practice, adoption, or behavior are not guaranteed and may vary depending on context, implementation, and field-specific conventions.