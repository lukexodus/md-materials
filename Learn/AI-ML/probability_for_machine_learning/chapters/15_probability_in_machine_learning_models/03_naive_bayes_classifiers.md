## Naive Bayes Classifiers

### Overview

Naive Bayes is a family of generative probabilistic classifiers based on applying Bayes' theorem with a strong (and typically unrealistic) assumption: that all features are conditionally independent given the class label. Despite this simplifying assumption, Naive Bayes classifiers are widely used as baselines and in applications such as text classification, spam filtering, and document categorization due to their computational efficiency and reasonable performance on many practical tasks. [Inference] The claim of "reasonable performance on many practical tasks" reflects common characterizations in machine learning literature, but actual performance depends heavily on dataset characteristics and is not a fixed guarantee.

### Bayes' Theorem Foundation

The classifier is built directly on Bayes' theorem:

$$
P(y \mid \mathbf{x}) = \frac{P(\mathbf{x} \mid y) \, P(y)}{P(\mathbf{x})}
$$

where:
- $P(y \mid \mathbf{x})$ is the **posterior probability** of class $y$ given features $\mathbf{x}$
- $P(\mathbf{x} \mid y)$ is the **likelihood** of observing features $\mathbf{x}$ given class $y$
- $P(y)$ is the **prior probability** of class $y$
- $P(\mathbf{x})$ is the **evidence**, a normalizing constant

**Key Points**
- Naive Bayes is a **generative** model: it models how the data is generated within each class ($P(\mathbf{x} \mid y)$) rather than directly modeling the decision boundary.
- Since $P(\mathbf{x})$ does not depend on $y$, classification decisions only require comparing $P(\mathbf{x} \mid y) P(y)$ across classes.

### The Naive Independence Assumption

For a feature vector $\mathbf{x} = (x_1, x_2, \ldots, x_n)$, the "naive" assumption states that features are conditionally independent given the class:

$$
P(\mathbf{x} \mid y) = P(x_1, x_2, \ldots, x_n \mid y) = \prod_{i=1}^{n} P(x_i \mid y)
$$

This transforms an otherwise intractable joint distribution estimation problem into $n$ separate, simpler univariate estimation problems.

**Key Points**
- This assumption is almost never exactly true in real-world data, since features often exhibit some degree of correlation.
- [Inference] The classifier can still perform well even when the independence assumption is violated, because classification only requires the correct class to have the highest posterior score, not perfectly calibrated probability values. This is a commonly cited explanation in machine learning literature, but it is not a proven guarantee for any specific dataset.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Naive Bayes Generative Structure (svg_diagram)</text>

  <circle cx="320" cy="90" r="35" fill="#dbeafe" stroke="#2563eb" stroke-width="2" />
  <text x="320" y="95" text-anchor="middle" font-size="14" fill="#1e3a8a">y</text>

  <circle cx="120" cy="230" r="35" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="120" y="235" text-anchor="middle" font-size="13" fill="#78350f">x₁</text>

  <circle cx="260" cy="230" r="35" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="260" y="235" text-anchor="middle" font-size="13" fill="#78350f">x₂</text>

  <circle cx="400" cy="230" r="35" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="400" y="235" text-anchor="middle" font-size="13" fill="#78350f">x₃</text>

  <circle cx="540" cy="230" r="35" fill="#fef3c7" stroke="#d97706" stroke-width="2" />
  <text x="540" y="235" text-anchor="middle" font-size="13" fill="#78350f">xₙ</text>

  <line x1="300" y1="115" x2="140" y2="200" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="315" y1="123" x2="270" y2="198" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="335" y1="120" x2="390" y2="198" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />
  <line x1="350" y1="112" x2="520" y2="200" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)" />

  <text x="320" y="290" text-anchor="middle" font-size="12" fill="#444">Class y generates each feature independently:</text>
  <text x="320" y="310" text-anchor="middle" font-size="12" fill="#444">no edges exist between x₁...xₙ (the "naive" assumption)</text>
</svg>

### Classification Rule (MAP Decision)

Given the independence assumption, the predicted class is the one maximizing the posterior:

$$
\hat{y} = \arg\max_{y} \; P(y) \prod_{i=1}^{n} P(x_i \mid y)
$$

For numerical stability (avoiding underflow from multiplying many small probabilities), this is typically computed in log-space:

$$
\hat{y} = \arg\max_{y} \; \left[ \log P(y) + \sum_{i=1}^{n} \log P(x_i \mid y) \right]
$$

**Key Points**
- This is a **Maximum A Posteriori (MAP)** decision rule, selecting the class with the highest posterior probability rather than computing the full normalized posterior.
- Log-space computation is a standard numerical technique to prevent floating-point underflow when many small probabilities are multiplied together.

### Variants by Feature Distribution Assumption

The likelihood term $P(x_i \mid y)$ requires an assumed distribution for each feature type. Different variants of Naive Bayes correspond to different distributional assumptions.

#### Gaussian Naive Bayes

Used for continuous features, assuming each feature follows a normal distribution within each class:

$$
P(x_i \mid y) = \frac{1}{\sqrt{2\pi\sigma_y^2}} \exp\left(-\frac{(x_i - \mu_y)^2}{2\sigma_y^2}\right)
$$

where $\mu_y$ and $\sigma_y^2$ are the mean and variance of feature $x_i$ estimated from training samples belonging to class $y$.

#### Multinomial Naive Bayes

Commonly used for discrete count data, such as word frequencies in text classification:

$$
P(\mathbf{x} \mid y) = \frac{(\sum_i x_i)!}{\prod_i x_i!} \prod_{i=1}^{n} P(x_i \mid y)^{x_i}
$$

In practice, the factorial normalization term is often omitted during classification since it does not depend on $y$ and cancels out in the argmax comparison.

#### Bernoulli Naive Bayes

Used for binary/boolean features (e.g., word presence/absence rather than frequency):

$$
P(x_i \mid y) = p_{iy}^{x_i} (1 - p_{iy})^{1 - x_i}
$$

where $p_{iy}$ is the probability that feature $i$ is present given class $y$.

**Key Points**
- The choice of variant should match the nature of the input features; using a mismatched variant (e.g., Multinomial on continuous data without discretization) [Inference] generally degrades performance, though the degree of degradation depends on the specific dataset and is not something that can be stated as a fixed rule without testing.

### Parameter Estimation via Maximum Likelihood

For each variant, parameters (means, variances, class-conditional probabilities) are typically estimated using maximum likelihood estimation from training data frequency counts.

For discrete features (e.g., Multinomial Naive Bayes on word counts), the raw MLE estimate is:

$$
P(x_i \mid y) = \frac{\text{count}(x_i, y)}{\sum_{i'} \text{count}(x_{i'}, y)}
$$

**Key Points**
- A significant problem arises when a feature value never appears with a given class in the training data: the resulting probability estimate is exactly zero, which forces the entire product in the classification rule to zero regardless of other evidence.

### Laplace (Additive) Smoothing

To address the zero-probability problem, Laplace smoothing (a form of additive smoothing) is commonly applied:

$$
P(x_i \mid y) = \frac{\text{count}(x_i, y) + \alpha}{\sum_{i'} \text{count}(x_{i'}, y) + \alpha \cdot k}
$$

where $\alpha$ is the smoothing parameter (commonly $\alpha = 1$ for standard Laplace smoothing) and $k$ is the number of possible values the feature can take.

**Key Points**
- Smoothing reflects a Bayesian interpretation: it corresponds to placing a Dirichlet prior over the categorical parameters and reporting the posterior mean rather than the raw MLE.
- The choice of $\alpha$ is a hyperparameter that trades off between trusting the observed data and regularizing toward a uniform distribution.

### Worked Example

**Example**

Consider a simplified spam classifier using Bernoulli Naive Bayes with two features: presence of the word "free" ($x_1$) and presence of the word "winner" ($x_2$).

Suppose from training data:
- $P(\text{spam}) = 0.4$, $P(\text{not spam}) = 0.6$
- $P(x_1 = 1 \mid \text{spam}) = 0.7$, $P(x_1 = 1 \mid \text{not spam}) = 0.1$
- $P(x_2 = 1 \mid \text{spam}) = 0.6$, $P(x_2 = 1 \mid \text{not spam}) = 0.05$

For a new message containing both "free" and "winner" ($x_1 = 1, x_2 = 1$):

$$
\text{Score(spam)} = 0.4 \times 0.7 \times 0.6 = 0.168
$$

$$
\text{Score(not spam)} = 0.6 \times 0.1 \times 0.05 = 0.003
$$

**Output**

Since $0.168 > 0.003$, the message is classified as spam. Normalizing (dividing each score by their sum, $0.171$) gives an approximate posterior probability of $P(\text{spam} \mid \mathbf{x}) \approx 0.982$.

### Advantages

**Key Points**
- Computationally efficient: both training (frequency counting) and inference (a single pass through features) scale linearly with the number of features and samples.
- Requires relatively little training data to estimate parameters compared to more complex models, since it estimates $n$ univariate distributions rather than a joint distribution.
- Handles high-dimensional feature spaces (e.g., bag-of-words text representations with thousands of features) reasonably well in practice for classification purposes, though [Inference] this characterization is a general pattern reported across applied literature rather than a mathematically guaranteed property.
- Naturally supports multiclass classification without modification, unlike some models (e.g., standard logistic regression) that require extension (e.g., softmax or one-vs-rest).

### Limitations

**Key Points**
- The independence assumption is frequently violated in real data, which can lead to miscalibrated probability estimates even when the classification decision itself remains correct.
- Continuous feature modeling in Gaussian Naive Bayes assumes normality, which may not hold for all features; violations can degrade estimate quality. [Inference] The extent of degradation is data-dependent and not something this response can quantify without a specific benchmark being cited.
- Zero-frequency problems require smoothing; without it, the model can fail catastrophically on unseen feature combinations.
- The model tends to produce overconfident posterior probabilities (close to 0 or 1) because of the independence assumption artificially amplifying joint likelihood estimates when correlated features are all present.

### Relationship to Logistic Regression

**Key Points**
- Naive Bayes (generative) and logistic regression (discriminative) both produce a classifier based on $P(y \mid \mathbf{x})$, but derive it differently: Naive Bayes derives it via Bayes' theorem from class-conditional distributions, while logistic regression models it directly.
- [Inference] Under specific conditions — including features conditionally independent given the class and class-conditional distributions belonging to certain exponential family forms (e.g., Gaussian with shared variance, or the Bernoulli/Multinomial assumptions used in Naive Bayes for discrete data) — Naive Bayes and logistic regression can be shown to share the same functional form for $P(y \mid \mathbf{x})$, differing mainly in how parameters are estimated (joint likelihood vs. conditional likelihood). This is a theoretical result referenced in some statistical learning literature; I cannot verify the exact scope of conditions without a specific citation being checked in this session, so this should be treated as [Unverified] beyond the general shape of the claim.
- [Inference] Generative classifiers such as Naive Bayes are sometimes described as converging faster with less data, while discriminative classifiers such as logistic regression are sometimes described as achieving lower asymptotic error with sufficient data. This is a commonly cited comparison in machine learning coursework, but I do not have access to a specific study to verify this as a general claim, so it remains [Unverified] as a universal rule.

### Conclusion

Naive Bayes classifiers apply Bayes' theorem under a conditional independence assumption to convert an intractable joint density estimation problem into a set of tractable univariate estimation problems. Despite the assumption rarely holding exactly, the classifier remains a practically useful baseline due to its computational efficiency, low data requirements, and reasonable classification accuracy on many tasks. [Inference] This overall characterization reflects general patterns described in machine learning literature rather than a claim verified against a specific benchmark in this session.

### Related Topics

- Multinomial and Bernoulli Naive Bayes implementation details for text classification
- Laplace smoothing and its Bayesian interpretation via Dirichlet priors
- Generative vs. discriminative models: broader theoretical comparison
- Gaussian Naive Bayes vs. Linear Discriminant Analysis (LDA)
- Feature independence testing and correlation diagnostics
- Calibration of Naive Bayes posterior probabilities
- Semi-naive Bayes methods that relax the independence assumption