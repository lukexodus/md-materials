## Fisher Information

### Definition

Fisher information is a measure of the amount of information that an observable random variable carries about an unknown parameter $\theta$ upon which its probability distribution depends. It quantifies how sharply peaked the likelihood function is around the true parameter value — a more sharply peaked likelihood indicates greater precision in estimating $\theta$ from the data.

$$I(\theta) = E\left[\left(\frac{\partial}{\partial \theta}\log f(X \mid \theta)\right)^2\right]$$

where $f(X \mid \theta)$ is the probability density (or mass) function of the data given the parameter $\theta$.

### Alternative Formula

**Key Points**

- Under certain regularity conditions, Fisher information can also be expressed using the second derivative of the log-likelihood:

$$I(\theta) = -E\left[\frac{\partial^2}{\partial \theta^2}\log f(X \mid \theta)\right]$$

- I cannot verify the precise regularity conditions required for this alternative formula to be equivalent to the first, as this would require a specific cited source I do not have access to [Unverified]
- This second-derivative form is sometimes interpreted as measuring the average curvature of the log-likelihood function at $\theta$ — a sharper (more negative) curvature corresponds to higher Fisher information [Inference]

### Interpretation

**Key Points**

- Higher Fisher information indicates that the data provides more precise information about the parameter, corresponding to a sharply peaked likelihood function [Inference]
- Lower Fisher information indicates the likelihood function is flatter, meaning many different parameter values are nearly equally consistent with the observed data [Inference]
- I cannot verify a single universal intuitive description of Fisher information that applies identically across all distributions, as its behavior depends on the specific functional form of $f(X \mid \theta)$ [Unverified]

### Fisher Information for a Sample

**Key Points**

- For $n$ independent and identically distributed observations, the total Fisher information is the sum of the Fisher information from each individual observation:

$$I_n(\theta) = n \cdot I_1(\theta)$$

where $I_1(\theta)$ is the Fisher information contributed by a single observation.

- This additive property reflects the idea that more observations generally provide more cumulative information about the parameter [Inference]

### Relationship to the Cramér–Rao Lower Bound

**Key Points**

- Fisher information is commonly cited in statistical literature as the key quantity in the Cramér–Rao lower bound, which describes a theoretical minimum variance achievable by an unbiased estimator:

$$\text{Var}(\hat{\theta}) \geq \frac{1}{I_n(\theta)}$$

- I cannot verify the precise regularity conditions required for this inequality to hold, as this would require a specific cited source I do not have access to [Unverified]
- Under this relationship, higher Fisher information corresponds to a lower theoretical bound on achievable variance, meaning more informative data allows for potentially more precise (lower-variance) unbiased estimators [Inference]

### Illustration

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Fisher information as the curvature of the log-likelihood function (svg_diagram)</title><desc>Chart comparing two log-likelihood curves as functions of a candidate parameter value, one sharply peaked corresponding to high Fisher information, and one broadly peaked corresponding to low Fisher information.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<line x1="60" y1="250" x2="620" y2="250" stroke="var(--t)" stroke-width="0.5" />
<text class="ts" x="620" y="270" text-anchor="end">Candidate parameter value (theta)</text>
<line x1="60" y1="250" x2="60" y2="50" stroke="var(--t)" stroke-width="0.5" />
<text class="ts" x="45" y="50" text-anchor="end">Log-likelihood</text>

<path fill="none" stroke="#D85A30" stroke-width="1.5" d="M120 235 Q340 55 560 235" />
<text class="th" x="340" y="40" text-anchor="middle" fill="#993C1D">High Fisher information (sharp peak) (svg_diagram)</text>

<path fill="none" stroke="#378ADD" stroke-width="1.5" d="M90 235 Q340 140 590 235" />
<text class="ts" x="480" y="160" text-anchor="middle" fill="#0C447C">Low Fisher information (flat peak)</text>

<line x1="340" y1="250" x2="340" y2="55" stroke="var(--t)" stroke-width="0.5" stroke-dasharray="3 3" />
</svg>

[Inference] This diagram illustrates the conceptual relationship between likelihood curvature and Fisher information magnitude. It does not represent a specific empirical dataset or computed likelihood function.

### Fisher Information Matrix (Multi-Parameter Case)

**Definition**

When more than one parameter is being estimated simultaneously, Fisher information generalizes to a matrix, known as the Fisher information matrix, with entries corresponding to second partial derivatives (or products of first partial derivatives) of the log-likelihood with respect to each pair of parameters.

$$[I(\boldsymbol{\theta})]_{jk} = -E\left[\frac{\partial^2}{\partial \theta_j \partial \theta_k}\log f(X \mid \boldsymbol{\theta})\right]$$

**Key Points**

- I cannot verify the precise formal conditions under which this matrix formulation is valid without a specific cited source [Unverified]
- The inverse of the Fisher information matrix is commonly cited as providing an approximate covariance matrix for the maximum likelihood estimator in the multi-parameter case, under certain asymptotic conditions [Unverified: I cannot confirm the precise regularity conditions without a cited source]

### Fisher Information and Maximum Likelihood Estimation

**Key Points**

- Fisher information is commonly connected in statistical literature to the asymptotic variance of maximum likelihood estimators, with MLEs described as asymptotically achieving variance equal to the inverse of the Fisher information as $n \to \infty$ [Unverified: I cannot confirm the precise formal statement or regularity conditions without a specific cited source]
- This connection is sometimes used to justify why MLEs are described as asymptotically efficient in statistical literature [Unverified: I cannot confirm this characterization without a specific cited source]
- I cannot verify that this asymptotic relationship provides an accurate approximation of estimator variance at any specific finite sample size, as this depends on the distribution and sample size involved [Unverified]

### Observed vs. Expected Fisher Information

**Definition**

**Expected Fisher information** refers to the Fisher information as defined above, computed as an expectation over the distribution of the data. **Observed Fisher information** refers to the negative second derivative of the log-likelihood evaluated directly at the observed data and at the MLE, without taking an expectation.

**Key Points**

- I cannot verify the precise formal distinction, computational differences, or comparative advantages between these two quantities without a specific cited source [Unverified]
- Observed Fisher information is sometimes used in practice as a computationally convenient substitute for expected Fisher information, particularly when the expectation is difficult to compute analytically [Unverified: I cannot confirm how commonly this substitution is made in current statistical practice]

### Relevance to Machine Learning

**Key Points**

- Fisher information is discussed in some statistical and machine learning literature in connection with the natural gradient method, an alternative to standard gradient descent that uses the Fisher information matrix to rescale parameter updates [Unverified: I cannot confirm the precise formulation or comparative performance claims without a specific cited source]
- Fisher information is discussed in some literature in connection with certain approaches to model comparison and information-theoretic criteria [Unverified: I do not have access to information confirming the specific mechanisms or extent of this connection]
- I do not have access to information confirming how frequently Fisher information, as a formal quantity, is directly computed or relied upon in mainstream applied machine learning workflows, as opposed to being primarily a theoretical or specialized consideration [Unverified]
- Some literature discusses Fisher information in relation to certain approaches to continual learning, such as methods that attempt to identify which model parameters are most important to preserve when learning new tasks [Unverified: I cannot confirm the specific mechanisms, named methods, or their effectiveness without a specific cited source]

**Disclaimer regarding LLM/model behavior claims:** Any statements above relating to machine learning applications, algorithms, or model behavior are labeled [Unverified] and are not guaranteed; actual behavior may vary depending on model architecture, implementation, data characteristics, and other context-specific factors. I cannot verify the effectiveness, prevalence, or specific technical details of any named method without a specific cited source.

### Limitations and Considerations

**Key Points**

- Fisher information relies on specific regularity conditions regarding the differentiability and support of the probability distribution involved; I cannot verify these conditions hold in any particular applied scenario without a specific cited source [Unverified]
- Computing Fisher information analytically requires a known, differentiable likelihood function; for complex models, this may not be tractable in closed form, potentially requiring numerical approximation [Inference]
- I cannot verify that Fisher information provides a complete or sufficient characterization of estimation precision in all cases, as this depends on the specific estimator, distribution, and sample size involved [Unverified]

I cannot verify that this list of considerations is exhaustive across all statistical and machine learning literature.

### Related Topics

- Maximum likelihood estimation
- Cramér–Rao lower bound
- Efficiency of estimators
- Variance of an estimator
- Confidence intervals
- Natural gradient methods

> Correction disclaimer (per stated preferences): This response contains multiple [Inference] and [Unverified]-labeled claims throughout, as many statements regarding formal regularity conditions, asymptotic theorems, and machine learning applications could not be independently confirmed against a specific cited source within this conversation. All claims regarding LLM or model behavior are not guaranteed and may vary depending on implementation, data, and context. No part of this response should be read as a confirmed fact unless explicitly stated as a standard mathematical definition or formula.