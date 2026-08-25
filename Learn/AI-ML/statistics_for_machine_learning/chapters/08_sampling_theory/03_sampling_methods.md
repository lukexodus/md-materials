## Sampling Methods

### Definition

Sampling is the process of selecting a subset of individuals or observations (a sample) from a larger population, with the goal of making inferences about that population without examining every member of it. In machine learning, sampling methods determine how training data is collected, how datasets are split, and how models are evaluated.

### Why Sampling Matters in Machine Learning

- Full population data is often unavailable, expensive, or impractical to collect
- Sampling enables tractable computation on large datasets
- The quality of a sample directly affects model bias, variance, and generalization
- Poor sampling can introduce systematic errors that no downstream algorithm can correct [Inference]

### Core Terminology

- **Population**: The complete set of items or individuals of interest
- **Sample**: A subset drawn from the population
- **Sampling Frame**: A list or representation of the population from which the sample is drawn
- **Sampling Unit**: A single member of the population eligible for selection
- **Sampling Error**: The difference between a sample statistic and the true population parameter, arising because a sample is not the full population

### Categories of Sampling Methods

Sampling methods broadly fall into two categories: probability sampling and non-probability sampling.

### Probability Sampling Methods

In probability sampling, every member of the population has a known, non-zero chance of being selected. This property allows for the calculation of sampling error and supports statistically valid inference.

#### Simple Random Sampling (SRS)

**Definition**

Every individual in the population has an equal and independent probability of being selected. Selection is typically performed using random number generators or lottery-style methods.

**Key Points**

- Requires a complete and accurate sampling frame
- Free from selection bias when properly executed
- Can be inefficient for large or geographically dispersed populations
- Serves as the theoretical baseline against which other methods are compared

**Example**

Selecting 500 customer records at random from a database of 50,000 customers using a uniform random number generator, where each customer has exactly a $500/50000 = 0.01$ probability of selection.

#### Systematic Sampling

**Definition**

Individuals are selected at regular intervals from an ordered list, starting from a randomly chosen point. The interval, denoted $k$, is calculated as:

$$k = \frac{N}{n}$$

where $N$ is the population size and $n$ is the desired sample size.

**Key Points**

- Easier to implement than SRS, especially with physical or ordered lists
- Can introduce bias if the list has a hidden periodic pattern that aligns with the sampling interval
- Approximates SRS reasonably well when no such periodicity exists [Inference]

**Example**

From a list of 10,000 transaction records, selecting every 20th record after a random start between 1 and 20, yielding a sample of 500.

#### Stratified Sampling

**Definition**

The population is divided into distinct, non-overlapping subgroups (strata) based on a shared characteristic, and random samples are drawn independently from each stratum, either proportionally or equally.

**Key Points**

- Reduces sampling variance compared to SRS when strata are internally homogeneous [Inference]
- Requires prior knowledge of population characteristics to define strata
- Two main allocation approaches: proportional allocation (sample size per stratum matches population proportion) and equal allocation (same sample size per stratum regardless of population proportion)
- Commonly used in ML to preserve class distribution in classification datasets during train/test splits

**Example**

A dataset with class imbalance (90% negative, 10% positive labels) is split into training and test sets such that both sets maintain the same 90/10 ratio, rather than risking a skewed split from plain random sampling.

#### Cluster Sampling

**Definition**

The population is divided into clusters (often based on natural or geographic groupings), a random subset of clusters is selected, and either all members within chosen clusters are sampled (one-stage) or a further sample is drawn within them (two-stage).

**Key Points**

- More cost-effective than SRS when the population is spread across wide areas
- Tends to have higher sampling error than stratified sampling because clusters are often internally homogeneous but differ from each other [Inference]
- Useful when a full sampling frame of individuals is unavailable but a frame of clusters is

**Example**

To survey user satisfaction across a company's regional offices, 10 offices are randomly selected out of 100, and all employees within those 10 offices are surveyed.

#### Multistage Sampling

**Definition**

A combination of two or more sampling methods applied in sequence, typically involving cluster sampling at higher stages followed by random or stratified sampling within selected clusters.

**Key Points**

- Balances cost efficiency with representativeness
- Common in large-scale surveys and national statistics programs
- Increases complexity in variance estimation compared to single-stage methods [Inference]

### Non-Probability Sampling Methods

In non-probability sampling, not every member of the population has a known or equal chance of selection. These methods are often faster and cheaper but carry higher risk of bias and typically do not support formal statistical inference to the population. [Unverified: applicability may vary by specific use case]

#### Convenience Sampling

**Definition**

Samples are drawn from whatever population members are most readily accessible.

**Key Points**

- Fast and inexpensive
- High risk of selection bias since accessibility often correlates with other characteristics
- Common in early-stage or exploratory ML data collection, though results generalize poorly [Inference]

#### Voluntary Response Sampling

**Definition**

Individuals self-select into the sample by choosing to participate.

**Key Points**

- Prone to strong bias because motivated individuals (often with extreme opinions or experiences) are overrepresented
- Common in online reviews, surveys, and app feedback data used as ML training sources

#### Judgmental (Purposive) Sampling

**Definition**

A researcher or domain expert selects sample members deliberately based on their judgment of what is representative or informative.

**Key Points**

- Relies heavily on the expertise and lack of bias of the person selecting the sample
- Useful in qualitative research or when studying rare, specific phenomena
- Not suitable for generalizable statistical inference [Unverified: depends on context and validation approach]

#### Snowball Sampling

**Definition**

Existing sample members recruit or identify future subjects from among their acquaintances, useful for reaching hard-to-access populations.

**Key Points**

- Effective for studying hidden or hard-to-reach populations (e.g., rare disease patients, niche communities)
- Introduces network-based bias since samples cluster around initial seed members
- Sample composition is heavily influenced by the starting points chosen [Inference]

#### Quota Sampling

**Definition**

The researcher ensures the sample matches the population on certain characteristics (quotas) but selects individuals within each quota non-randomly, often via convenience.

**Key Points**

- Superficially resembles stratified sampling but lacks random selection within groups
- Faster and cheaper than stratified sampling but subject to selector bias within quotas

### Comparison of Sampling Methods

| Method | Probability-Based | Bias Risk | Typical Use in ML |
| --- | --- | --- | --- |
| Simple Random | Yes | Low | Baseline dataset creation |
| Systematic | Yes | Low–Moderate (periodicity risk) | Large ordered datasets |
| Stratified | Yes | Low | Class-imbalanced classification splits |
| Cluster | Yes | Moderate | Geographically or organizationally grouped data |
| Multistage | Yes | Moderate | Large-scale, hierarchical data collection |
| Convenience | No | High | Exploratory/prototype data collection |
| Voluntary Response | No | High | User-submitted feedback datasets |
| Judgmental | No | Moderate–High | Expert-curated niche datasets |
| Snowball | No | High | Hard-to-reach population studies |
| Quota | No | Moderate | Quick market or survey-style data |

<svg width="100%" viewBox="0 0 680 400" role="img"><title>Sampling methods taxonomy (svg_diagram)</title><desc>A structural diagram showing sampling methods divided into probability-based and non-probability-based categories, each containing their respective methods.</desc>

<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="c-gray">

<rect x="240" y="20" width="200" height="44" rx="8" stroke-width="0.5" />

<text class="th" x="340" y="42" text-anchor="middle" dominant-baseline="central">Sampling methods (svg_diagram)</text>

</g>

<line x1="300" y1="64" x2="180" y2="100" class="arr" marker-end="url(#arrow)" />

<line x1="380" y1="64" x2="500" y2="100" class="arr" marker-end="url(#arrow)" />

<g class="c-teal">

<rect x="40" y="100" width="280" height="40" rx="10" stroke-width="0.5" />

<text class="th" x="180" y="120" text-anchor="middle" dominant-baseline="central">Probability sampling</text>

</g>

<g class="c-coral">

<rect x="360" y="100" width="280" height="40" rx="10" stroke-width="0.5" />

<text class="th" x="500" y="120" text-anchor="middle" dominant-baseline="central">Non-probability sampling</text>

</g>

<g class="c-teal">

<rect x="40" y="160" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="105" y="182" text-anchor="middle" dominant-baseline="central">Simple random</text>

<rect x="190" y="160" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="255" y="182" text-anchor="middle" dominant-baseline="central">Systematic</text>

<rect x="40" y="216" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="105" y="238" text-anchor="middle" dominant-baseline="central">Stratified</text>

<rect x="190" y="216" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="255" y="238" text-anchor="middle" dominant-baseline="central">Cluster</text>

<rect x="115" y="272" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="180" y="294" text-anchor="middle" dominant-baseline="central">Multistage</text>

</g>

<g class="c-coral">

<rect x="360" y="160" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="425" y="182" text-anchor="middle" dominant-baseline="central">Convenience</text>

<rect x="510" y="160" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="575" y="182" text-anchor="middle" dominant-baseline="central">Voluntary response</text>

<rect x="360" y="216" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="425" y="238" text-anchor="middle" dominant-baseline="central">Judgmental</text>

<rect x="510" y="216" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="575" y="238" text-anchor="middle" dominant-baseline="central">Snowball</text>

<rect x="435" y="272" width="130" height="44" rx="6" stroke-width="0.5" />

<text class="ts" x="500" y="294" text-anchor="middle" dominant-baseline="central">Quota</text>

</g>

</svg>

### Sampling Bias

**Definition**

Sampling bias occurs when the method of sample selection systematically favors certain outcomes or population members over others, causing the sample to misrepresent the population.

**Common Sources**

- **Selection bias**: Non-random exclusion of certain population segments
- **Undercoverage**: The sampling frame fails to include parts of the target population
- **Non-response bias**: Selected individuals fail to participate, and non-participants differ systematically from participants
- **Survivorship bias**: Only "surviving" or successful cases are observed, excluding failures from the sample

**Relevance to Machine Learning**

Sampling bias in training data can propagate into model behavior. A model trained on a biased sample may perform well on the sampled distribution but generalize poorly to the true population distribution. [Inference] This is closely related to the concept of dataset shift or distribution shift in ML literature.

### Sample Size Considerations

**Key Points**

- Larger samples generally reduce sampling error but do not correct for bias introduced by a flawed sampling method [Inference]
- The relationship between sample size and standard error follows:

$$SE = \frac{\sigma}{\sqrt{n}}$$

where $\sigma$ is the population standard deviation and $n$ is the sample size

- Increasing $n$ fourfold only halves the standard error, reflecting diminishing returns
- Sample size determination should account for desired confidence level, margin of error, and expected population variance

### Sampling in Machine Learning Workflows

**Key Points**

- **Train/test/validation splits** are themselves a sampling exercise; how they are performed affects evaluation reliability
- **Stratified splits** are standard practice for classification tasks with imbalanced classes
- **Cross-validation** repeatedly resamples the dataset into different train/test partitions to obtain more robust performance estimates
- **Bootstrap sampling** (sampling with replacement) is used in bagging ensemble methods such as Random Forests
- **Mini-batch sampling** during stochastic gradient descent involves randomly sampling subsets of training data at each iteration
- Poor sampling during data collection (e.g., convenience-sampled web-scraped data) can introduce bias that model architecture cannot correct [Inference]

### Related Topics

- Sampling distributions and the Central Limit Theorem
- Bootstrap resampling methods
- Cross-validation techniques (k-fold, leave-one-out, stratified k-fold)
- Bias-variance tradeoff
- Dataset shift and distribution shift
- Confidence intervals and margin of error
- Power analysis and sample size determination
- Imbalanced dataset handling techniques (SMOTE, undersampling, oversampling)