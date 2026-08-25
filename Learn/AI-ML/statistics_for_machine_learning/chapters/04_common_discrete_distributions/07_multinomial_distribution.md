## Multinomial Distribution (svg_diagram)

### Definition

The multinomial distribution generalizes the binomial distribution to experiments with more than two possible outcomes per trial. It models the probability of counts across $k$ categories over $n$ independent trials, where each trial results in exactly one of the $k$ categories.

A random vector $\mathbf{X} = (X_1, X_2, \dots, X_k)$ follows a multinomial distribution if it represents the counts of outcomes falling into each of $k$ categories across $n$ independent trials, where each trial has a fixed set of category probabilities $p_1, p_2, \dots, p_k$ that sum to 1.

### Probability Mass Function

$$P(X_1 = x_1, X_2 = x_2, \dots, X_k = x_k) = \frac{n!}{x_1! \, x_2! \cdots x_k!} \, p_1^{x_1} p_2^{x_2} \cdots p_k^{x_k}$$

where:

- $n$ = total number of trials
- $x_i$ = number of occurrences of category $i$, with $\sum_{i=1}^{k} x_i = n$
- $p_i$ = probability of category $i$ on a single trial, with $\sum_{i=1}^{k} p_i = 1$

### Parameters

- $n$: number of trials (positive integer)
- $\mathbf{p} = (p_1, \dots, p_k)$: probability vector, each $p_i \in [0,1]$, summing to 1
- $k$: number of categories

### Key Points

- The multinomial distribution reduces to the binomial distribution when $k = 2$.
- Each $X_i$ marginally follows a binomial distribution: $X_i \sim \text{Binomial}(n, p_i)$.
- The counts are not independent of each other, since they are constrained by $\sum x_i = n$.
- Trials are assumed independent and identically distributed. [Inference] Deviation from this assumption (e.g., correlated trials) would affect the validity of the model, though the exact impact depends on the nature of the correlation. [Unverified] for any specific dataset without direct testing.

### Mean, Variance, and Covariance

For each component $X_i$:

$$E[X_i] = n p_i$$



$$\text{Var}(X_i) = n p_i (1 - p_i)$$

For the covariance between two components $X_i$ and $X_j$ ($i \neq j$):

$$\text{Cov}(X_i, X_j) = -n p_i p_j$$

The negative covariance reflects the constraint that if one category's count increases, others must decrease to keep the total fixed at $n$.

### Example

Suppose a die is rolled $n = 12$ times. Each face (1 through 6) has probability $p_i = 1/6$. The probability of observing each face exactly twice ($x_1 = x_2 = \dots = x_6 = 2$) is:

$$P(\mathbf{X} = (2,2,2,2,2,2)) = \frac{12!}{2!\,2!\,2!\,2!\,2!\,2!} \left(\frac{1}{6}\right)^{12}$$

Calculating the multinomial coefficient:

$$\frac{12!}{(2!)^6} = \frac{479001600}{64} = 7484400$$



$$P = 7484400 \times \left(\frac{1}{6}\right)^{12} \approx 7484400 \times 4.594 \times 10^{-10} \approx 0.00344$$

So there is approximately a 0.344% chance of this exact outcome. [Inference] This calculation follows directly from the formula given standard die assumptions (fair, independent rolls); it has not been separately verified via simulation in this response.

### Relationship to Categorical Distribution

A single trial from a multinomial experiment (i.e., $n = 1$) is called a categorical distribution. The multinomial distribution can be viewed as the sum of $n$ independent categorical trials, with the resulting vector representing aggregated category counts.

### Applications in Machine Learning

- **Naive Bayes classifiers**: The multinomial Naive Bayes variant models word counts in text classification tasks, assuming word occurrences follow a multinomial distribution conditioned on class labels. [Unverified] Effectiveness varies by dataset and is not guaranteed across all text classification problems.
- **Multiclass classification loss functions**: The categorical cross-entropy loss function used in softmax-based classifiers is derived from the likelihood of the multinomial (or categorical) distribution.
- **Topic modeling**: Models such as Latent Dirichlet Allocation (LDA) use multinomial distributions to represent word distributions per topic and topic distributions per document.
- **Sampling and simulation**: Multinomial sampling is used in bootstrap methods and in generating synthetic categorical data for testing models.

### Relationship to Softmax Function

In multiclass classification, the softmax function converts raw model outputs (logits) into a probability vector $\mathbf{p} = (p_1, \dots, p_k)$ that sums to 1. This vector defines the parameters of a categorical (single-trial multinomial) distribution over class labels, which is then used with cross-entropy loss during training.

$$p_i = \frac{e^{z_i}}{\sum_{j=1}^{k} e^{z_j}}$$

where $z_i$ is the logit for class $i$.

### Diagram: Multinomial Trial Structure

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380" font-family="sans-serif">
<text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#222">Multinomial Trial Structure (svg_diagram)</text>
<rect x="30" y="60" width="140" height="50" rx="6" fill="#e8f0fe" stroke="#4a76d4" />
<text x="100" y="90" text-anchor="middle" font-size="13" fill="#222">n Independent Trials</text>
<line x1="170" y1="85" x2="230" y2="85" stroke="#555" stroke-width="2" marker-end="url(#arrow)" />
<rect x="230" y="60" width="160" height="50" rx="6" fill="#fef3e0" stroke="#d48a3a" />
<text x="310" y="82" text-anchor="middle" font-size="12" fill="#222">Each trial has k</text>
<text x="310" y="98" text-anchor="middle" font-size="12" fill="#222">possible outcomes</text>
<line x1="390" y1="85" x2="450" y2="85" stroke="#555" stroke-width="2" marker-end="url(#arrow)" />
<rect x="450" y="60" width="200" height="50" rx="6" fill="#e6f7ec" stroke="#3a9e5f" />
<text x="550" y="82" text-anchor="middle" font-size="12" fill="#222">Category probabilities</text>
<text x="550" y="98" text-anchor="middle" font-size="12" fill="#222">p1, p2, ..., pk (sum = 1)</text>
<line x1="100" y1="110" x2="100" y2="150" stroke="#555" stroke-width="2" marker-end="url(#arrow)" />
<line x1="550" y1="110" x2="550" y2="150" stroke="#555" stroke-width="2" marker-end="url(#arrow)" />
<rect x="150" y="160" width="400" height="60" rx="6" fill="#f3e8fd" stroke="#8a4fd4" />
<text x="350" y="185" text-anchor="middle" font-size="13" fill="#222">Counts X1, X2, ..., Xk</text>
<text x="350" y="203" text-anchor="middle" font-size="12" fill="#222">where X1 + X2 + ... + Xk = n</text>
<line x1="350" y1="220" x2="350" y2="260" stroke="#555" stroke-width="2" marker-end="url(#arrow)" />
<rect x="180" y="270" width="340" height="70" rx="6" fill="#fde8ec" stroke="#d43a5a" />
<text x="350" y="295" text-anchor="middle" font-size="13" fill="#222">P(X1=x1,...,Xk=xk) =</text>
<text x="350" y="315" text-anchor="middle" font-size="12" fill="#222">[n! / (x1!...xk!)] p1^x1 ... pk^xk</text>
</svg>

### Estimation of Parameters

Given observed count data, the maximum likelihood estimate (MLE) for each $p_i$ is:

$$\hat{p}_i = \frac{x_i}{n}$$

This is the sample proportion for each category. [Inference] This estimator is unbiased under the standard multinomial model assumptions; performance under model misspecification is not addressed here.

In Bayesian settings, the Dirichlet distribution is commonly used as a conjugate prior for the multinomial parameters $\mathbf{p}$, since the Dirichlet-multinomial pairing yields a closed-form posterior update. [Unverified] Whether this conjugacy is "commonly used" in a specific practitioner's workflow is not something this response can confirm without a citable source.

### Common Pitfalls

- **Confusing multinomial with multivariate**: The multinomial distribution deals with counts of categorical outcomes, not with a joint distribution over continuous variables (e.g., multivariate normal).
- **Ignoring the sum constraint**: Because $\sum x_i = n$, the covariance matrix of a multinomial vector is singular; this affects downstream statistical procedures that assume full-rank covariance.
- **Small sample sizes**: With few trials relative to $k$, sample proportions $\hat{p}_i$ may be poor estimates of true probabilities. [Inference] based on general statistical estimation theory regarding variance and sample size.

### Related Topics

- Categorical distribution
- Binomial distribution
- Dirichlet distribution (as conjugate prior)
- Multinomial Naive Bayes classifier
- Softmax function and cross-entropy loss
- Latent Dirichlet Allocation (LDA)
- Chi-square goodness-of-fit test (uses multinomial assumptions)
- Maximum likelihood estimation for categorical data