## Sampling Bias

### Definition

Sampling bias occurs when a sample is collected in a way that systematically favors certain members of a population over others, causing the sample to misrepresent the population it is intended to reflect. This is distinct from random sampling error, which arises from chance variation and diminishes as sample size increases; sampling bias does not diminish with larger sample sizes. [Inference]

### Why Sampling Bias Matters in Machine Learning

- A model trained on a biased sample can learn patterns that reflect the bias rather than the true underlying population distribution [Inference]
- Increasing training data volume does not correct for sampling bias, since the bias is structural rather than a matter of sample size [Inference]
- Sampling bias is closely related to, but not identical to, the broader concept of dataset shift or distribution shift discussed in ML literature

### Common Sources of Sampling Bias

#### Selection Bias

**Definition**

Occurs when the method used to select samples systematically excludes or under-represents certain segments of the population.

**Example**

A model trained only on customer data from users who completed a purchase, excluding those who abandoned their cart, may misrepresent the full population of site visitors.

#### Undercoverage Bias

**Definition**

Occurs when the sampling frame itself fails to include parts of the target population, so those individuals have zero probability of being selected regardless of the sampling method used.

**Example**

A dataset built from smartphone app usage logs will systematically exclude individuals without smartphone access, which may correlate with age, income, or geography. [Inference]

#### Non-Response Bias

**Definition**

Occurs when selected individuals or units do not participate or provide data, and those who do not respond differ systematically from those who do.

**Example**

A survey-based dataset on job satisfaction may over-represent employees with strong opinions (either very satisfied or very dissatisfied), since those with neutral views may be less likely to respond. [Inference]

#### Survivorship Bias

**Definition**

Occurs when only "surviving" or successful cases are observed or retained in the sample, while failed or excluded cases are omitted, leading to an overly optimistic or skewed view.

**Example**

Analyzing only currently active user accounts to model engagement patterns, while excluding churned users, may bias the model toward behaviors of retained users only.

#### Volunteer (Self-Selection) Bias

**Definition**

Occurs when individuals choose whether to be part of the sample themselves, often correlating participation with the trait being measured.

**Example**

Product review datasets tend to be dominated by customers with strongly positive or strongly negative experiences, since neutral customers are less likely to leave a review. [Inference]

#### Temporal (Time-Based) Bias

**Definition**

Occurs when data is collected during a limited or unrepresentative time window, causing the sample to reflect conditions specific to that period rather than general patterns.

**Example**

A dataset of retail transactions collected only during a holiday sales period may not represent typical year-round purchasing behavior. [Inference]

#### Exclusion Bias

**Definition**

Occurs when specific groups are deliberately or inadvertently removed from the dataset during preprocessing, such as through overly aggressive filtering or deduplication.

**Example**

Removing all records with missing fields might disproportionately exclude a particular subgroup if that subgroup has systematically different data collection patterns. [Inference]

### Detecting Sampling Bias

**Key Points**

- Comparing sample demographic or feature distributions against known population statistics, when such statistics are available and reliable
- Examining data collection methodology for structural exclusion points
- Monitoring model performance across subgroups to check for disparities that may indicate biased training data [Inference]
- I cannot verify which specific statistical tests are considered universally standard for bias detection, as this varies by field and context

### Consequences in Machine Learning Systems

**Key Points**

- Reduced generalization performance on populations underrepresented in training data [Inference]
- Potential for models to perform inequitably across demographic or categorical subgroups if bias correlates with sensitive attributes [Inference]
- Evaluation metrics computed on a similarly biased test set may fail to reveal the problem, since both training and test data share the same bias [Inference]
- I do not have access to information confirming the precise magnitude of performance degradation caused by any specific bias type, as this depends heavily on context and cannot be generalized

### Illustration

<svg width="100%" viewBox="0 0 680 340" role="img"><title>How sampling bias distorts population representation (svg_diagram)</title><desc>Diagram showing a true population with mixed composition, contrasted with a biased sample that overrepresents one subgroup due to a selection filter.</desc>

<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="c-gray">
<rect x="40" y="40" width="240" height="200" rx="14" stroke-width="0.5" />
<text class="th" x="160" y="66" text-anchor="middle" dominant-baseline="central">True population (svg_diagram)</text>
</g>
<circle cx="90" cy="110" r="10" fill="#378ADD" />
<circle cx="130" cy="100" r="10" fill="#D85A30" />
<circle cx="170" cy="120" r="10" fill="#378ADD" />
<circle cx="210" cy="105" r="10" fill="#D85A30" />
<circle cx="90" cy="150" r="10" fill="#D85A30" />
<circle cx="130" cy="160" r="10" fill="#378ADD" />
<circle cx="170" cy="145" r="10" fill="#D85A30" />
<circle cx="210" cy="155" r="10" fill="#378ADD" />
<circle cx="130" cy="200" r="10" fill="#378ADD" />
<circle cx="180" cy="195" r="10" fill="#D85A30" />
<text class="ts" x="160" y="225" text-anchor="middle">Roughly balanced groups</text>
<line x1="280" y1="140" x2="400" y2="140" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="340" y="125" text-anchor="middle">Selection filter</text>
<g class="c-gray">
<rect x="400" y="40" width="240" height="200" rx="14" stroke-width="0.5" />
<text class="th" x="520" y="66" text-anchor="middle" dominant-baseline="central">Collected sample (svg_diagram)</text>
</g>
<circle cx="450" cy="110" r="10" fill="#378ADD" />
<circle cx="490" cy="100" r="10" fill="#378ADD" />
<circle cx="530" cy="120" r="10" fill="#378ADD" />
<circle cx="570" cy="105" r="10" fill="#378ADD" />
<circle cx="450" cy="150" r="10" fill="#378ADD" />
<circle cx="490" cy="160" r="10" fill="#378ADD" />
<circle cx="530" cy="145" r="10" fill="#D85A30" />
<circle cx="570" cy="155" r="10" fill="#378ADD" />
<circle cx="490" cy="200" r="10" fill="#378ADD" />
<circle cx="540" cy="195" r="10" fill="#378ADD" />
<text class="ts" x="520" y="225" text-anchor="middle">One group overrepresented</text>

<text class="ts" x="360" y="280" text-anchor="middle">Blue and coral represent two subgroups in the population</text>

</svg>

**[Inference]** The diagram illustrates a conceptual mechanism (filtering skewing group proportions) rather than a specific empirical dataset or study.

### Mitigation Approaches

**Key Points**

- Using probability-based sampling methods (e.g., stratified sampling) where feasible to better preserve population proportions
- Auditing data collection pipelines for structural exclusion points
- Comparing sample statistics against known, reliable population benchmarks where available
- Applying reweighting or resampling techniques (e.g., oversampling underrepresented groups) as a possible corrective step [Inference]
- I cannot verify that any specific mitigation technique fully corrects for sampling bias in all cases; effectiveness is context-dependent and not something I can generalize about

### Distinction from Related Concepts

| Concept | Core Difference from Sampling Bias |
| --- | --- |
| Sampling error | Random, chance-based deviation; decreases with larger sample size |
| Sampling bias | Systematic, structural distortion; does not decrease with larger sample size [Inference] |
| Measurement bias | Arises from how variables are measured, not how the sample was selected |
| Confirmation bias | A cognitive bias in interpretation, not a property of the data collection process |

**[Unverified]** I do not have access to a single authoritative source confirming that this table represents an exhaustive or universally standardized taxonomy of bias-related terms; terminology can vary across statistics, ML, and social science literature.

### Related Topics

- Sampling methods (probability vs. non-probability sampling)
- Dataset shift and distribution shift
- Fairness and bias in machine learning models
- Stratified sampling and resampling techniques (SMOTE, oversampling, undersampling)
- Confounding variables and measurement bias
- Bias-variance tradeoff

**[Note on this response]** This entire response contains a mix of established statistical definitions and [Inference]-labeled reasoning about their implications for machine learning. Where I could not verify a claim against a specific confirmed source, I have labeled it accordingly per your stated preferences.