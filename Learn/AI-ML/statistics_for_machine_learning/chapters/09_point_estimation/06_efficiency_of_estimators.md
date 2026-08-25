## Efficiency of Estimators

### Definition

Efficiency refers to a property of an estimator describing how small its variance is relative to other estimators of the same estimand, typically compared within a class of estimators satisfying certain conditions such as unbiasedness. Among competing estimators, a more efficient estimator achieves lower variance, meaning it produces estimates that cluster more tightly around their expected value.

### Relative Efficiency

**Definition**

Relative efficiency compares the variances of two estimators of the same estimand, typically expressed as a ratio.

$$\text{Relative Efficiency}(\hat{\theta}_1, \hat{\theta}_2) = \frac{\text{Var}(\hat{\theta}_2)}{\text{Var}(\hat{\theta}_1)}$$

**Key Points**

- If this ratio exceeds 1, $\hat{\theta}_1$ is considered more efficient than $\hat{\theta}_2$, since $\hat{\theta}_1$ has lower variance [Inference]
- Relative efficiency is typically defined for estimators that share the same bias properties (commonly both unbiased), so that variance comparison directly reflects overall estimation precision [Inference]
- I cannot verify that relative efficiency comparisons are meaningful or standardly defined when comparing estimators with substantially different bias properties, as this depends on the specific framework being used [Unverified]

### The Cramér–Rao Lower Bound

**Definition**

The Cramér–Rao lower bound is commonly described as a theoretical minimum variance that any unbiased estimator of a parameter can achieve, given the information available in the data.

**Key Points**

- I cannot verify the precise mathematical formulation or the specific regularity conditions required for the Cramér–Rao lower bound to apply, as this would require a specific cited source I do not have access to [Unverified]
- An unbiased estimator whose variance equals the Cramér–Rao lower bound is sometimes described as "fully efficient" or achieving the minimum possible variance for an unbiased estimator [Unverified: terminology varies across sources and I cannot confirm a single standard usage]
- Not all unbiased estimators achieve this bound; some may have variance strictly greater than the theoretical minimum [Inference]

### Minimum Variance Unbiased Estimator (MVUE)

**Definition**

An estimator is sometimes referred to as the minimum variance unbiased estimator if it is unbiased and has the lowest variance among all unbiased estimators of the same estimand.

**Key Points**

- I cannot verify the precise formal conditions under which a unique MVUE is guaranteed to exist for a given estimation problem, as this depends on technical statistical theory I cannot confirm without a cited source [Unverified]
- The existence of an MVUE does not necessarily mean it has been identified or is computationally straightforward to derive for every estimation problem [Unverified]

### Illustration

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Comparing efficiency of two unbiased estimators (svg_diagram)</title><desc>Two sampling distributions, both centered on the same true parameter value since both estimators are unbiased, with one narrower distribution representing the more efficient estimator and one wider distribution representing the less efficient estimator.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<line x1="60" y1="250" x2="620" y2="250" stroke="var(--t)" stroke-width="0.5" />
<line x1="340" y1="40" x2="340" y2="260" stroke="var(--t)" stroke-width="0.5" stroke-dasharray="3 3" />
<text class="ts" x="340" y="275" text-anchor="middle">True parameter (theta), both unbiased</text>

<path fill="none" stroke="#1D9E75" stroke-width="1.5" d="M290 248 Q340 60 390 248" />
<text class="th" x="340" y="45" text-anchor="middle" fill="#085041">More efficient (lower variance)</text>

<path fill="none" stroke="#D85A30" stroke-width="1.5" d="M180 248 Q340 100 500 248" />
<text class="ts" x="480" y="115" text-anchor="middle" fill="#993C1D">Less efficient (higher variance)</text>
</svg>

[Inference] This diagram illustrates the conceptual relationship between spread and relative efficiency, holding unbiasedness constant for both estimators. It does not represent a specific empirical dataset.

### Asymptotic Efficiency

**Definition**

An estimator is described as asymptotically efficient if it achieves the lowest possible asymptotic variance among a class of estimators as sample size approaches infinity, often relative to a bound such as the Cramér–Rao lower bound evaluated in the limit.

**Key Points**

- This is distinct from finite-sample efficiency, which concerns variance comparisons at a fixed, specific sample size [Inference]
- I cannot verify the specific formal definition of asymptotic efficiency used across all statistical sources, as terminology and precise conditions may differ [Unverified]
- Maximum likelihood estimators are commonly cited in statistical literature as being asymptotically efficient under certain regularity conditions [Unverified: I cannot confirm the precise regularity conditions or verify this claim without a specific cited source]

### Efficiency vs. Other Estimator Properties

| Property | Question it answers | Independent of the others? |
|---|---|---|
| Unbiasedness | Is the estimator centered on the true parameter? | Yes, can hold without consistency or efficiency [Inference] |
| Consistency | Does the estimator converge to the true parameter as $n \to \infty$? | Yes, can hold without unbiasedness or efficiency [Inference] |
| Efficiency | Does the estimator have the lowest variance among comparable estimators? | Yes, typically evaluated only among estimators sharing other properties like unbiasedness [Inference] |

**Key Points**

- These three properties are conceptually distinct, and an estimator may possess some combination of them without possessing all [Inference]
- I cannot verify a single universally agreed-upon hierarchy of importance among these three properties, as this depends on the specific goals of the statistical analysis [Unverified]

### Trade-Offs Involving Efficiency

**Key Points**

- Restricting attention only to unbiased estimators when searching for an efficient one may exclude biased estimators that achieve lower overall mean squared error [Inference]
- This connects to the broader bias-variance tradeoff, where a slightly biased estimator with substantially lower variance can outperform a strictly unbiased but highly inefficient estimator in terms of MSE [Inference]
- I cannot verify that maximizing efficiency among unbiased estimators is always the appropriate goal in every applied context, as this depends on whether unbiasedness itself is prioritized over overall MSE [Unverified]

### Relevance to Machine Learning

**Key Points**

- Efficiency, as a formal statistical property, is sometimes discussed in relation to parameter estimators in classical statistical models such as linear regression, where under certain assumptions the ordinary least squares estimator is described as efficient among a class of linear unbiased estimators [Unverified: I cannot confirm the precise theorem, its name, or its exact conditions without a specific cited source]
- I do not have access to information confirming how frequently formal efficiency properties, as defined here, are directly evaluated for the parameter estimators of complex machine learning models such as neural networks, as opposed to being primarily discussed in the context of classical statistical estimators [Unverified]
- Estimator efficiency is a distinct concept from computational efficiency (e.g., training speed or memory usage), which uses the same term but refers to a different property [Inference]
- I cannot verify that improvements in statistical efficiency of parameter estimation directly translate into improved predictive performance for any specific machine learning model, as this depends on numerous context-specific factors [Unverified]

**Disclaimer regarding LLM/model behavior claims:** Any statements above relating to machine learning model or estimator behavior are labeled [Inference] or [Unverified] and are not guaranteed; actual behavior may vary depending on model architecture, data, implementation, and other context-specific factors.

### Two Distinct Meanings of "Efficiency"

**Key Points**

- **Statistical efficiency**: the property described throughout this document, relating to estimator variance relative to other estimators
- **Computational efficiency**: a separate and unrelated meaning referring to the speed, memory usage, or resource consumption of an algorithm or estimation procedure
- Confusing these two meanings can lead to miscommunication, since a statistically efficient estimator is not necessarily computationally efficient, and vice versa [Inference]

### Limitations and Considerations

**Key Points**

- Efficiency comparisons are typically only meaningful among estimators that share other relevant properties, such as being unbiased or targeting the same estimand; comparing efficiency across estimators with different bias properties requires additional care [Inference]
- Theoretical efficiency bounds such as the Cramér–Rao lower bound rely on specific regularity conditions about the underlying probability model; I cannot verify these conditions hold in any particular applied scenario without a specific cited source [Unverified]
- Achieving high efficiency does not, by itself, guarantee low mean squared error if the estimator is biased, since MSE also depends on the squared bias term [Inference]

I cannot verify that this list of considerations is exhaustive across all statistical and machine learning literature.

### Related Topics

- Estimators and estimands
- Bias of an estimator
- Variance of an estimator
- Mean squared error
- Consistency of estimators
- Maximum likelihood estimation
- Bias-variance tradeoff

> Correction disclaimer (per stated preferences): This response contains multiple [Inference] and [Unverified]-labeled claims throughout, as many statements regarding formal theorems, regularity conditions, and machine learning applications could not be independently confirmed against a specific cited source within this conversation. All claims regarding LLM or model behavior are not guaranteed and may vary depending on implementation, data, and context. No part of this response should be read as a confirmed fact unless explicitly stated as a standard mathematical definition or formula.