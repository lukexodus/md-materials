## Softmax and Probabilistic Classification

### Overview

Softmax regression, also called multinomial logistic regression, generalizes binary logistic regression to classification problems with more than two mutually exclusive classes. The softmax function converts a vector of real-valued scores into a probability distribution over discrete classes, ensuring the outputs are non-negative and sum to one. This makes softmax the standard mechanism for probabilistic multiclass classification, including as the output layer of many neural network classifiers.

### The Softmax Function

Given a vector of raw scores (logits) $\mathbf{z} = (z_1, z_2, \ldots, z_K)$ for $K$ classes, the softmax function computes:

$$
P(y = k \mid \mathbf{x}) = \text{softmax}(\mathbf{z})_k = \frac{e^{z_k}}{\sum_{j=1}^{K} e^{z_j}}
$$

where $z_k = \mathbf{w}_k^\top \mathbf{x} + b_k$ is the linear score associated with class $k$, computed using a class-specific weight vector $\mathbf{w}_k$ and bias $b_k$.

**Key Points**
- The exponentiation ensures all outputs are strictly positive, and the normalization by the sum ensures the outputs form a valid probability distribution: $\sum_{k=1}^{K} P(y=k \mid \mathbf{x}) = 1$.
- Softmax is a direct generalization of the sigmoid function used in binary logistic regression; applying softmax with $K=2$ classes reduces to a form equivalent to the sigmoid, with class 2's score expressible relative to class 1's.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 340">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Softmax: Logits to Probability Distribution (svg_diagram)</text>

  <rect x="80" y="80" width="60" height="180" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="110" y="70" text-anchor="middle" font-size="12" fill="#333">z₁=2.0</text>

  <rect x="180" y="150" width="60" height="110" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="210" y="140" text-anchor="middle" font-size="12" fill="#333">z₂=1.0</text>

  <rect x="280" y="200" width="60" height="60" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="310" y="190" text-anchor="middle" font-size="12" fill="#333">z₃=0.1</text>

  <text x="380" y="180" font-size="20" fill="#555">→</text>
  <text x="380" y="200" font-size="11" fill="#555">softmax</text>

  <rect x="440" y="90" width="60" height="170" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
  <text x="470" y="80" text-anchor="middle" font-size="12" fill="#333">p₁≈0.63</text>

  <rect x="500" y="170" width="60" height="90" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
  <text x="530" y="160" text-anchor="middle" font-size="12" fill="#333">p₂≈0.23</text>

  <rect x="560" y="230" width="30" height="30" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
  <text x="575" y="220" text-anchor="middle" font-size="11" fill="#333">p₃≈0.09</text>

  <line x1="80" y1="260" x2="600" y2="260" stroke="#333" stroke-width="1" />

  <text x="320" y="300" text-anchor="middle" font-size="12" fill="#444">Raw logits (unbounded) become a normalized probability distribution</text>
  <text x="320" y="318" text-anchor="middle" font-size="11" fill="#666">p₁ + p₂ + p₃ = 1.0</text>
</svg>

### Probabilistic Interpretation

**Key Points**
- The output $P(y = k \mid \mathbf{x})$ is modeled as a **Categorical distribution** (a generalization of the Bernoulli distribution to more than two outcomes) over the $K$ classes, parameterized by the softmax outputs.
- The probability mass function of the categorical distribution over the one-hot encoded label $\mathbf{y}$ can be written as:

$$
P(\mathbf{y} \mid \mathbf{x}) = \prod_{k=1}^{K} p_k^{y_k}
$$

where $y_k = 1$ if the true class is $k$ and $0$ otherwise, and $p_k = P(y=k \mid \mathbf{x})$.

- This is [Inference] structurally analogous to how the Bernoulli PMF $p^y(1-p)^{1-y}$ compactly represents binary logistic regression's two cases; I am reasoning this by direct analogy to the binary case rather than citing a specific verified source for this exact generalization statement, so this specific framing should be treated as [Unverified] beyond the general mathematical structure, which follows directly from the definition of the categorical distribution.

### Maximum Likelihood and Cross-Entropy Loss

Given a dataset of $n$ i.i.d. observations, the log-likelihood is:

$$
\ell(\theta) = \sum_{i=1}^{n} \sum_{k=1}^{K} y_{ik} \log p_{ik}
$$

Maximizing this log-likelihood is equivalent to minimizing the negative log-likelihood, which corresponds to the standard **categorical cross-entropy loss**:

$$
J(\theta) = -\frac{1}{n} \sum_{i=1}^{n} \sum_{k=1}^{K} y_{ik} \log p_{ik}
$$

**Key Points**
- Because $\mathbf{y}_i$ is one-hot encoded, this sum simplifies at the level of each training example to just $-\log p_{i,k^*}$, where $k^*$ is the true class index for example $i$.
- As with binary logistic regression, this shows that cross-entropy loss for multiclass classification is [Inference] derived directly from maximum likelihood estimation under a categorical distribution assumption, rather than being an arbitrarily chosen loss function; this is a standard derivation presented in machine learning literature, but I have not verified the exact presentation of any specific textbook in this session, so the general derivation logic should be treated as [Inference] while any claim about a specific source's exact wording would be [Unverified].

### Numerical Stability: The Log-Sum-Exp Trick

**Key Points**
- Direct computation of $e^{z_k}$ for large $z_k$ values can cause floating-point overflow; direct computation of the softmax denominator can also suffer from related numerical issues.
- A standard mitigation is to subtract the maximum logit value before exponentiating:

$$
\text{softmax}(\mathbf{z})_k = \frac{e^{z_k - \max_j z_j}}{\sum_{j=1}^{K} e^{z_j - \max_j z_j}}
$$

- This adjustment does not change the mathematical result, since the subtracted constant cancels in the ratio, but it is [Inference] widely described in numerical computing literature as improving numerical stability in floating-point implementations; I cannot verify the exact numerical behavior of any specific software library without checking its documentation directly, so any claim about a particular implementation's stability should be treated as [Unverified] and behavior is not guaranteed to be identical across all libraries or hardware.

### Softmax Temperature

A temperature parameter $T$ can be introduced to control the sharpness of the resulting probability distribution:

$$
P(y=k \mid \mathbf{x}) = \frac{e^{z_k / T}}{\sum_{j=1}^{K} e^{z_j / T}}
$$

**Key Points**
- As $T \to 0$, the distribution approaches a one-hot vector concentrated on the highest-scoring class, approximating a hard $\arg\max$ decision.
- As $T \to \infty$, the distribution approaches a uniform distribution over all classes, regardless of the input logits.
- Temperature scaling is [Inference] commonly used in applications such as knowledge distillation and calibration adjustment, based on general patterns described in machine learning literature; I do not have a specific verified source confirmed in this session for any particular application's exact implementation details, so specific claims about individual systems using this technique should be treated as [Unverified] without a citation being checked.

### Decision Rule

Once probabilities are computed, the predicted class under a standard decision rule is the one with highest probability:

$$
\hat{y} = \arg\max_{k} P(y = k \mid \mathbf{x})
$$

**Key Points**
- Because softmax is monotonic in the logits (higher $z_k$ always corresponds to higher $p_k$), this decision rule is mathematically equivalent to simply selecting $\arg\max_k z_k$ directly on the raw logits, without needing to compute the softmax normalization at inference time if only the hard label is required.
- The full probability vector remains useful when calibrated confidence estimates or ranked alternatives (e.g., top-k predictions) are needed, rather than only the single most likely class.

### Worked Example

**Example**

Consider a 3-class classification problem with logits $\mathbf{z} = (2.0, 1.0, 0.1)$ for a given input.

Step 1 — Exponentiate each logit:

$$
e^{2.0} \approx 7.389, \quad e^{1.0} \approx 2.718, \quad e^{0.1} \approx 1.105
$$

Step 2 — Sum the exponentials:

$$
\sum_j e^{z_j} \approx 7.389 + 2.718 + 1.105 = 11.212
$$

Step 3 — Normalize each term:

$$
p_1 = \frac{7.389}{11.212} \approx 0.659, \quad p_2 = \frac{2.718}{11.212} \approx 0.242, \quad p_3 = \frac{1.105}{11.212} \approx 0.099
$$

**Output**

The resulting probability distribution is approximately $(0.659, 0.242, 0.099)$, summing to $1.0$. Under the standard $\arg\max$ decision rule, the predicted class is class 1, with an estimated probability of approximately $65.9\%$.

### Relationship to Binary Logistic Regression

**Key Points**
- Binary logistic regression can be viewed as a special case of softmax regression with $K=2$ classes, where one class's logit is fixed at zero (an identifiability constraint) and the other varies, recovering the sigmoid function algebraically.
- Softmax regression, like binary logistic regression, assumes a linear relationship between input features and the class logits; if this linearity assumption does not hold, [Inference] the resulting probability estimates may be systematically miscalibrated, based on general reasoning about model misspecification rather than a specific verified empirical study, so this claim should be treated as [Inference] rather than an established quantitative result.

### One-vs-Rest as an Alternative

**Key Points**
- An alternative approach to multiclass classification using binary logistic regression is **One-vs-Rest (OvR)**, where a separate binary classifier is trained for each class against all others, and predictions are made by comparing the resulting scores.
- Softmax regression differs from OvR in that it jointly models all classes through a single normalized probability distribution, rather than combining independently trained binary decisions; [Inference] this is generally described in machine learning literature as producing better-calibrated multiclass probability estimates compared to naively combining independent OvR classifier outputs, but I do not have a specific verified benchmark confirmed in this session to support this claim quantitatively, so this should be treated as [Unverified] beyond the structural/mathematical distinction described.

### Class Imbalance Considerations

**Key Points**
- When class frequencies are highly imbalanced, the maximum likelihood estimate under softmax can be biased toward predicting majority classes with higher confidence.
- Common mitigations include class-weighted loss functions, resampling techniques, or adjusting decision thresholds post-hoc; [Inference] the relative effectiveness of these mitigations is described as being dataset-dependent in applied machine learning literature, and I do not have a specific verified study confirmed in this session to quantify their comparative effectiveness, so this should be treated as [Unverified] without a specific cited benchmark.

### Conclusion

Softmax provides the standard probabilistic mechanism for multiclass classification by converting real-valued logits into a normalized categorical probability distribution. Its derivation follows the same maximum-likelihood logic as binary logistic regression, generalized from the Bernoulli to the categorical distribution, and it produces the categorical cross-entropy loss used to train the majority of modern multiclass classifiers, including neural network output layers. Practical use requires attention to numerical stability, temperature calibration where relevant, and awareness of class imbalance effects, all of which are implementation- and dataset-dependent considerations.

### Related Topics

- Categorical distribution and its relationship to the Bernoulli and Multinoulli distributions
- Cross-entropy and Kullback-Leibler divergence in classification loss functions
- Temperature scaling for neural network probability calibration
- One-vs-Rest and One-vs-One multiclass strategies compared to softmax regression
- Numerical stability techniques in deep learning implementations (log-sum-exp, log-softmax)
- Neural network output layers and the softmax activation function
- Label smoothing as a regularization technique for softmax-based classifiers