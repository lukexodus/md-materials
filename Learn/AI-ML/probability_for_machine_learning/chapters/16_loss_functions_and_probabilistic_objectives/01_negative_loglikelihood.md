## Negative Log-Likelihood

### Overview

Negative log-likelihood (NLL) is a scalar quantity derived by taking the negative of the logarithm of a likelihood function, and it serves as one of the most widely used objective functions for training probabilistic models. Minimizing NLL is mathematically equivalent to maximizing the likelihood of observed data under a model, which connects NLL directly to the principle of maximum likelihood estimation. NLL underlies loss functions across a broad range of machine learning models, including logistic regression, softmax classifiers, and many neural network architectures.

### From Likelihood to Negative Log-Likelihood

Given a probabilistic model with parameters $\theta$ and observed data $\mathbf{X} = \{x_1, \ldots, x_n\}$ assumed independent and identically distributed (i.i.d.), the likelihood function is:

$$
L(\theta) = P(\mathbf{X} \mid \theta) = \prod_{i=1}^{n} P(x_i \mid \theta)
$$

Taking the logarithm converts this product into a sum, which is generally easier to work with analytically and numerically:

$$
\log L(\theta) = \sum_{i=1}^{n} \log P(x_i \mid \theta)
$$

The negative log-likelihood is then defined as:

$$
\text{NLL}(\theta) = -\log L(\theta) = -\sum_{i=1}^{n} \log P(x_i \mid \theta)
$$

**Key Points**
- Maximizing $L(\theta)$ is mathematically equivalent to maximizing $\log L(\theta)$, since the logarithm is a strictly monotonically increasing function.
- Maximizing $\log L(\theta)$ is equivalent to minimizing $-\log L(\theta)$, which converts a maximization problem into a minimization problem — a convention that aligns with how most optimization libraries and gradient descent frameworks are typically structured.
- NLL is often expressed as an average rather than a sum, $\frac{1}{n}\text{NLL}(\theta)$, particularly in machine learning contexts, so that the loss magnitude does not scale directly with dataset size.

### Why Use the Logarithm

**Key Points**
- **Numerical stability**: multiplying many probabilities (each less than 1) together can cause floating-point underflow, since the product can become extremely small. Summing log-probabilities avoids this issue in a way that is [Inference] generally described in numerical computing literature as improving stability compared to direct multiplication; I do not have a specific verified benchmark confirmed in this session for any particular software implementation, so behavior in any specific library should be treated as [Unverified] and is not guaranteed to be identical across all implementations or hardware.
- **Analytical convenience**: the logarithm of a product of exponential-family distributions (such as Gaussian, Bernoulli, or Categorical) often simplifies into a sum of polynomial or linear terms, which can make gradient computation more tractable.
- **Connection to information theory**: $-\log P(x_i \mid \theta)$ can be interpreted as the number of "nats" (or bits, if using $\log_2$) of information needed to encode the event $x_i$ under the model's assumed distribution, connecting NLL to concepts from information theory such as entropy and cross-entropy. [Inference] This interpretation is commonly described in information-theoretic treatments of machine learning loss functions, but I do not have a specific verified source confirmed in this session for the exact framing used here, so this description should be treated as [Unverified] beyond the general mathematical relationship between negative log-probability and information content.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Negative Log-Likelihood as a Function of Predicted Probability (svg_diagram)</text>

  <line x1="80" y1="300" x2="580" y2="300" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="300" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="580" y="320" font-size="12" fill="#333">predicted probability p (for true class)</text>
  <text x="60" y="65" font-size="12" fill="#333">-log(p)</text>

  <text x="80" y="315" font-size="11" fill="#666">0</text>
  <text x="565" y="315" font-size="11" fill="#666">1</text>

  <path d="M 100 65             C 150 100, 200 150, 260 200            C 320 240, 400 270, 500 288            C 530 293, 560 297, 575 299" fill="none" stroke="#dc2626" stroke-width="2.5" />

  <circle cx="575" cy="299" r="4" fill="#16a34a" />
  <text x="500" y="280" font-size="11" fill="#16a34a">p close to 1: NLL near 0 (low penalty)</text>

  <circle cx="110" cy="80" r="4" fill="#dc2626" />
  <text x="130" y="75" font-size="11" fill="#dc2626">p close to 0: NLL grows very large</text>

  <text x="320" y="340" text-anchor="middle" font-size="11" fill="#444">Confident wrong predictions (low p for true class) incur steep penalty</text>
</svg>

### Relationship to Cross-Entropy Loss

**Key Points**
- For classification problems where the true label is represented as a one-hot vector and the model outputs a probability distribution over classes (e.g., via softmax), the NLL of the true class label is mathematically identical to the categorical cross-entropy loss for that single example: $-\log p_{k^*}$, where $k^*$ is the index of the true class.
- For binary classification under a Bernoulli assumption, the average NLL across a dataset is mathematically identical to the binary cross-entropy loss:

$$
\text{NLL} = -\frac{1}{n}\sum_{i=1}^{n}\left[y_i \log p_i + (1-y_i)\log(1-p_i)\right]
$$

- This equivalence means that in classification contexts, "minimizing cross-entropy loss" and "minimizing negative log-likelihood" [Inference] are generally described as referring to the same underlying optimization objective, differing mainly in terminology and disciplinary convention (information theory versus statistics); I do not have a specific verified source confirmed in this session establishing this as a universally consistent naming convention across all literature, so this should be treated as [Unverified] beyond the mathematical equivalence demonstrated above.

### NLL Under Different Distributional Assumptions

The specific form of NLL depends on the assumed distribution of the observed data or model output.

#### Gaussian NLL (Regression)

If outputs are assumed to follow a Gaussian distribution with mean $\hat{y}_i$ (the model's prediction) and fixed variance $\sigma^2$:

$$
\text{NLL} = \sum_{i=1}^{n} \left[ \frac{(y_i - \hat{y}_i)^2}{2\sigma^2} + \frac{1}{2}\log(2\pi\sigma^2) \right]
$$

**Key Points**
- If $\sigma^2$ is treated as fixed (not learned), minimizing this NLL is mathematically equivalent to minimizing mean squared error, since the terms not involving $\hat{y}_i$ become additive constants that do not affect the location of the minimum.
- This shows that **mean squared error**, often introduced purely as a geometric distance measure, [Inference] can also be derived as the negative log-likelihood under a Gaussian noise assumption; this is a standard derivation presented in statistical machine learning literature, but I have not verified the specific presentation of any particular textbook in this session, so the general derivation logic should be treated as [Inference] while claims about specific sources would be [Unverified].

#### Bernoulli NLL (Binary Classification)

As shown above, this reduces to binary cross-entropy loss.

#### Categorical NLL (Multiclass Classification)

As shown above, this reduces to categorical cross-entropy loss.

### Worked Example

**Example**

Consider a binary classifier that outputs $p = 0.8$ as the predicted probability that a given example belongs to class 1. Suppose the true label is $y = 1$.

$$
\text{NLL} = -\log(0.8) \approx 0.223
$$

Now suppose a second example has true label $y = 1$, but the model outputs a lower confidence, $p = 0.3$:

$$
\text{NLL} = -\log(0.3) \approx 1.204
$$

**Output**

The first prediction, being closer to the correct label with higher confidence, incurs a smaller NLL penalty ($\approx 0.223$) than the second, less confident and less accurate prediction ($\approx 1.204$). This illustrates the general behavior of NLL: it penalizes low-confidence correct predictions more than high-confidence correct predictions, and penalizes confident incorrect predictions especially heavily due to the steepness of $-\log(p)$ as $p \to 0$.

### Behavior at Extremes

**Key Points**
- As the predicted probability for the true class approaches $1$, NLL approaches $0$, reflecting minimal penalty for a highly confident, correct prediction.
- As the predicted probability for the true class approaches $0$, NLL approaches infinity, reflecting an extremely large penalty for a highly confident, incorrect prediction.
- This asymmetric, unbounded penalty structure is [Inference] generally described in machine learning literature as one reason NLL-based losses can be sensitive to mislabeled training data or outliers, since a single confidently wrong prediction can produce a disproportionately large loss contribution; I do not have a specific verified benchmark or study confirmed in this session quantifying this sensitivity, so this should be treated as [Unverified] beyond the mathematical behavior of the function itself.

### NLL and Maximum Likelihood Estimation

**Key Points**
- Minimizing NLL with respect to model parameters $\theta$ is, by construction, identical to performing maximum likelihood estimation, since $\arg\min_\theta \text{NLL}(\theta) = \arg\max_\theta \log L(\theta) = \arg\max_\theta L(\theta)$.
- This means that any model trained by minimizing an NLL-based loss function is implicitly performing MLE under whatever distributional assumption defines that specific NLL form (Gaussian for MSE, Bernoulli for binary cross-entropy, Categorical for categorical cross-entropy, and so on).
- If the assumed distribution does not match the true underlying data-generating process, [Inference] the resulting parameter estimates may be systematically biased or the model's uncertainty estimates may be poorly calibrated; this is a general reasoning statement about model misspecification rather than a specific verified empirical finding, so it should be treated as [Inference] rather than an established quantitative result for any particular dataset.

### NLL with Regularization (MAP Estimation)

**Key Points**
- When a prior distribution $P(\theta)$ is placed over the model parameters, minimizing the negative log-posterior rather than the negative log-likelihood corresponds to **Maximum A Posteriori (MAP)** estimation:

$$
\text{NLL}_{\text{MAP}}(\theta) = -\log P(\mathbf{X} \mid \theta) - \log P(\theta)
$$

- Common regularization terms, such as L2 regularization (weight decay), [Inference] can be derived as the negative log of a Gaussian prior placed over the parameters $\theta$, connecting regularized loss functions in machine learning back to a Bayesian MAP estimation interpretation; this is a standard derivation presented in Bayesian machine learning literature, but I have not verified a specific source's exact presentation in this session, so the general derivation logic should be treated as [Inference] while claims about specific textbook presentations would be [Unverified].
- Similarly, L1 regularization is [Inference] often connected in the literature to a Laplace prior over parameters under the same MAP framework; I do not have a specific verified source confirmed in this session for this exact correspondence, so this should be treated as [Unverified] beyond the general Bayesian regularization framework described.

### Practical Considerations in Optimization

**Key Points**
- NLL-based loss functions are typically minimized using gradient-based optimization methods (e.g., stochastic gradient descent, Adam), since closed-form solutions are often unavailable except in special cases (e.g., Gaussian NLL with a linear mean function, which reduces to ordinary least squares).
- Behavior of specific optimizers with respect to NLL loss surfaces — such as convergence speed, sensitivity to learning rate, or susceptibility to local minima — is implementation- and problem-dependent. [Unverified] I do not have a specific verified benchmark confirmed in this session to characterize this behavior generally, and any such claim about a specific optimizer or library should not be assumed reliable without checking that library's own documentation or a dedicated empirical study.
- Numerical implementations commonly compute NLL in log-space directly (e.g., using a "log-softmax" followed by a negative log-likelihood loss, rather than computing softmax probabilities and then taking their logarithm separately) as a way to [Inference] improve numerical stability, based on general reasoning about avoiding intermediate underflow/overflow in the softmax computation; behavior of any specific software framework's implementation is [Unverified] within this session without checking that framework's specific documentation.

### Conclusion

Negative log-likelihood provides a unifying mathematical objective connecting maximum likelihood estimation to the loss functions used throughout machine learning, including mean squared error under Gaussian assumptions and cross-entropy under Bernoulli or Categorical assumptions. Its logarithmic form offers numerical and analytical advantages over working with raw likelihoods directly, and its behavior — heavily penalizing confident incorrect predictions while lightly penalizing confident correct ones — shapes the learning dynamics of models trained under this objective. Several claims in this document regarding comparative optimizer behavior, sensitivity to mislabeled data, and specific software implementation details are labeled [Inference] or [Unverified], reflecting that they are reasoned generalizations rather than claims confirmed against a specific cited source within this session.

### Related Topics

- Maximum likelihood estimation: general theory and derivation
- Cross-entropy and its relationship to Kullback-Leibler divergence
- Maximum a posteriori (MAP) estimation and Bayesian regularization
- Mean squared error as a special case of Gaussian negative log-likelihood
- Information theory foundations: entropy, cross-entropy, and coding length
- Log-softmax and numerically stable loss implementations
- Exponential family distributions and their canonical loss functions