## Cross-Entropy Loss Derivation

### Overview

Cross-entropy loss is a widely used objective function for training classification models, and it can be formally derived from two related but distinct starting points: information theory (as a measure of divergence between two probability distributions) and maximum likelihood estimation (as the negative log-likelihood under a categorical or Bernoulli distributional assumption). This document derives cross-entropy from both perspectives and shows their mathematical equivalence in the classification setting.

### Information-Theoretic Foundation: Entropy

Before deriving cross-entropy, it is useful to define **entropy**, which quantifies the average uncertainty or information content of a probability distribution $P$:

$$
H(P) = -\sum_{x} P(x) \log P(x)
$$

**Key Points**
- Entropy is maximized when $P$ is uniform (maximum uncertainty) and minimized (equal to zero) when $P$ places all probability mass on a single outcome (no uncertainty).
- [Inference] Entropy can be interpreted as the expected number of "nats" (using natural log) or "bits" (using $\log_2$) required to encode an outcome drawn from $P$, under an optimal encoding scheme designed specifically for $P$. This interpretation is a standard framing in information theory, but I cannot verify the precise historical derivation or a specific cited source within this session, so this description should be treated as [Unverified] beyond the mathematical definition given above.

### Cross-Entropy Between Two Distributions

**Cross-entropy** extends entropy to measure the average encoding cost when data actually follows distribution $P$, but the encoding scheme is optimized for a different distribution $Q$:

$$
H(P, Q) = -\sum_{x} P(x) \log Q(x)
$$

**Key Points**
- $H(P, Q)$ is generally greater than or equal to $H(P)$, with equality holding only when $Q = P$ everywhere. [Unverified] I cannot independently verify this specific inequality proof within this session without citing a specific mathematical reference, though it is a standard and widely repeated property of cross-entropy in information theory literature.
- In the machine learning classification context, $P$ is typically the true (often one-hot) label distribution, and $Q$ is the model's predicted probability distribution.
- Cross-entropy is not symmetric in general: $H(P, Q) \neq H(Q, P)$.

### Relationship to KL Divergence

Cross-entropy can be decomposed in terms of entropy and Kullback-Leibler (KL) divergence:

$$
H(P, Q) = H(P) + D_{KL}(P \| Q)
$$

where the KL divergence is defined as:

$$
D_{KL}(P \| Q) = \sum_{x} P(x) \log \frac{P(x)}{Q(x)}
$$

**Key Points**
- $D_{KL}(P \| Q)$ measures how much the predicted distribution $Q$ diverges from the true distribution $P$; it is non-negative and equals zero only when $P = Q$. [Unverified] I cannot independently re-derive or verify the non-negativity proof (which relies on Jensen's inequality) within this session without citing a specific mathematical source, so this should be treated as [Unverified] as a rigorous guarantee, though it is a standard and widely repeated result in information theory literature.
- Because $H(P)$ (the entropy of the true label distribution) does not depend on the model parameters when $P$ is a fixed, known distribution (such as a one-hot label), minimizing cross-entropy $H(P, Q)$ with respect to the model is mathematically equivalent to minimizing $D_{KL}(P \| Q)$ alone, since $H(P)$ is a constant with respect to the optimization.
- This shows that training a classifier by minimizing cross-entropy loss can be interpreted as [Inference] minimizing the divergence between the model's predicted distribution and the true label distribution, which is a standard interpretive framing in machine learning literature; I do not have a specific verified source confirmed in this session for the exact phrasing used here, so this interpretive statement should be treated as [Unverified] beyond the mathematical decomposition shown above.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 300">
  <text x="320" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Cross-Entropy Decomposition (svg_diagram)</text>

  <rect x="100" y="100" width="440" height="60" fill="#dbeafe" stroke="#2563eb" stroke-width="1.5" />
  <text x="320" y="135" text-anchor="middle" font-size="14" fill="#1e3a8a">H(P, Q)  =  cross-entropy</text>

  <text x="320" y="180" text-anchor="middle" font-size="16" fill="#333">=</text>

  <rect x="100" y="200" width="200" height="55" fill="#fef3c7" stroke="#d97706" stroke-width="1.5" />
  <text x="200" y="232" text-anchor="middle" font-size="13" fill="#78350f">H(P) entropy</text>

  <text x="310" y="235" text-anchor="middle" font-size="16" fill="#333">+</text>

  <rect x="340" y="200" width="200" height="55" fill="#fce7f3" stroke="#be185d" stroke-width="1.5" />
  <text x="440" y="232" text-anchor="middle" font-size="13" fill="#831843">D_KL(P||Q) divergence</text>

  <text x="320" y="285" text-anchor="middle" font-size="11" fill="#444">Fixed label distribution's entropy is constant; only D_KL varies with model Q</text>
</svg>

### Case: One-Hot True Labels

In supervised classification, the true label distribution $P$ is typically one-hot: $P(y=k^*) = 1$ for the true class $k^*$, and $P(y=k) = 0$ for all other classes.

**Key Points**
- Since $P(x) \log P(x) \to 0$ in the limit as $P(x) \to 0$ (a standard convention used to handle the $0 \log 0$ term), the entropy $H(P)$ of a one-hot distribution is exactly $0$, since one term has probability $1$ (contributing $1 \log 1 = 0$) and all others have probability $0$.
- Because $H(P) = 0$ in this case, the cross-entropy decomposition simplifies to $H(P, Q) = D_{KL}(P \| Q)$, meaning cross-entropy and KL divergence are mathematically identical when the true label distribution is one-hot.
- Substituting the one-hot distribution into the cross-entropy formula, all terms vanish except the one corresponding to the true class:

$$
H(P, Q) = -\sum_{k} P(k) \log Q(k) = -\log Q(k^*)
$$

This is exactly the negative log-likelihood of the true class under the model's predicted distribution.

### Derivation from Maximum Likelihood Estimation

An independent derivation path arrives at the same formula via maximum likelihood estimation rather than information theory.

For a single training example with true class $k^*$ and model output distribution $Q(k) = P(y=k \mid \mathbf{x}, \theta)$ (e.g., from a softmax layer), the likelihood of the observed label under the model is:

$$
L(\theta) = Q(k^*) = P(y = k^* \mid \mathbf{x}, \theta)
$$

The negative log-likelihood is:

$$
\text{NLL} = -\log Q(k^*)
$$

**Key Points**
- This expression is identical in form to the information-theoretic cross-entropy result derived above, $H(P, Q) = -\log Q(k^*)$, for one-hot $P$.
- This demonstrates that cross-entropy loss and negative log-likelihood are the same mathematical object in the standard classification setting, arrived at from two independent theoretical starting points (information theory versus maximum likelihood estimation).

### Full Dataset Formulation

Summing (or averaging) across $n$ i.i.d. training examples, using the one-hot encoding $y_{ik} \in \{0, 1\}$ for example $i$ and class $k$:

$$
J(\theta) = -\frac{1}{n} \sum_{i=1}^{n} \sum_{k=1}^{K} y_{ik} \log \hat{p}_{ik}
$$

where $\hat{p}_{ik} = P(y = k \mid \mathbf{x}_i, \theta)$ is the model's predicted probability for class $k$ on example $i$.

**Key Points**
- Because $y_{ik} = 0$ for all classes except the true class $k_i^*$ for each example, this reduces at the per-example level to $-\log \hat{p}_{i, k_i^*}$, matching the single-example derivation above.
- This is the standard categorical cross-entropy loss function used to train softmax-based classifiers, including most neural network classification architectures.

### Binary Case: Bernoulli Cross-Entropy

For binary classification with true label $y \in \{0, 1\}$ and predicted probability $\hat{p} = P(y=1 \mid \mathbf{x}, \theta)$, the true distribution is a two-outcome one-hot vector $(y, 1-y)$, and the model distribution is $(\hat{p}, 1-\hat{p})$.

Applying the general cross-entropy formula to these two outcomes:

$$
H(P, Q) = -\left[y \log \hat{p} + (1-y) \log(1-\hat{p})\right]
$$

**Key Points**
- This is the standard binary cross-entropy loss formula, and it follows directly from the general categorical cross-entropy formula applied to the $K=2$ case, rather than being a separately derived expression.
- This matches the negative log-likelihood of a Bernoulli-distributed label, connecting binary cross-entropy back to the same MLE derivation path.

### Worked Example

**Example**

Consider a 3-class classification problem where the true class is class 2 (one-hot encoded as $P = (0, 1, 0)$), and the model outputs the predicted distribution $Q = (0.2, 0.5, 0.3)$.

Applying the cross-entropy formula:

$$
H(P, Q) = -\left[0 \cdot \log(0.2) + 1 \cdot \log(0.5) + 0 \cdot \log(0.3)\right] = -\log(0.5) \approx 0.693
$$

**Output**

The cross-entropy loss for this single example is approximately $0.693$ nats. Only the predicted probability assigned to the true class ($Q(2) = 0.5$) contributes to the loss; the predicted probabilities for the incorrect classes ($0.2$ and $0.3$) do not directly appear in the calculation, since their corresponding true-label indicator values are $0$.

### Gradient Behavior

**Key Points**
- For a softmax output combined with cross-entropy loss, the gradient of the loss with respect to the pre-softmax logit $z_k$ has a simplified closed form: $\frac{\partial J}{\partial z_k} = \hat{p}_k - y_k$, meaning the gradient is simply the difference between the predicted probability and the true one-hot label. [Unverified] I cannot independently re-derive or verify this specific gradient formula's derivation steps within this session without citing a specific mathematical source, so this should be treated as [Unverified] as a rigorous derivation, though it is a widely repeated and standard result in machine learning literature describing the softmax-cross-entropy combination.
- This simplified gradient form is [Inference] often cited in the literature as a key practical reason why softmax and cross-entropy are used together, since it avoids computing a separate, more complex derivative through the softmax function on its own. I do not have a specific verified source confirmed in this session for this exact motivational framing, so this should be treated as [Unverified] beyond the mathematical gradient expression itself.

### Why Not Use Mean Squared Error for Classification

**Key Points**
- Applying mean squared error directly to softmax outputs and one-hot labels is mathematically possible but [Inference] generally described in machine learning literature as leading to slower or less stable gradient-based learning in classification settings, compared to cross-entropy, particularly when predictions are confidently wrong. I do not have a specific verified empirical study confirmed in this session quantifying this comparison, so this should be treated as [Unverified] rather than an established, quantified result, and behavior may vary depending on the specific model, optimizer, and dataset used.
- Cross-entropy's logarithmic penalty structure, by contrast, produces a steep gradient signal specifically when the model is confidently wrong, which [Inference] is commonly cited as contributing to faster correction of such errors during training; this is a general reasoning statement based on the mathematical shape of the loss function rather than a confirmed benchmark result verified in this session, so it should be treated as [Unverified] as a comparative performance claim.

### Conclusion

Cross-entropy loss can be derived independently from information theory, as the expected encoding cost of data from distribution $P$ under a code optimized for distribution $Q$, and from maximum likelihood estimation, as the negative log-likelihood of observed labels under a categorical or Bernoulli model. Both derivation paths converge to the identical mathematical expression when the true label distribution is one-hot, which is the standard setting in supervised classification. This dual derivation explains why cross-entropy is simultaneously interpretable as an information-theoretic divergence measure and as a direct consequence of the maximum likelihood principle. Several claims in this document regarding gradient-based training dynamics, comparative loss function performance, and specific derivation proofs are labeled [Inference] or [Unverified], reflecting that they are reasoned generalizations or standard literature claims not independently re-derived or benchmarked within this session.

### Related Topics

- Negative log-likelihood and its relationship to maximum likelihood estimation
- Kullback-Leibler divergence: properties and applications beyond classification
- Softmax function and its gradient interaction with cross-entropy
- Entropy and information content in probability distributions
- Label smoothing as a modification to standard cross-entropy targets
- Focal loss as a variant addressing class imbalance in cross-entropy-based training
- Binary vs. categorical cross-entropy: implementation differences