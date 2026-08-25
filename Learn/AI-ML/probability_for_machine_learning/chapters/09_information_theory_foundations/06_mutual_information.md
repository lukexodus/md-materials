## Mutual Information

### Definition

Mutual information (MI) quantifies the amount of information obtained about one random variable by observing another. It measures the mutual dependence between two random variables $X$ and $Y$.

For discrete random variables:

$$I(X; Y) = \sum_{y \in Y} \sum_{x \in X} P(x, y) \log \frac{P(x, y)}{P(x)P(y)}$$

For continuous random variables:

$$I(X; Y) = \int_{Y} \int_{X} p(x, y) \log \frac{p(x, y)}{p(x)p(y)} \, dx \, dy$$

where $P(x, y)$ (or $p(x,y)$) is the joint probability distribution, and $P(x)$, $P(y)$ are the marginal distributions.

### Relationship to KL Divergence

Mutual information can be expressed as the KL divergence between the joint distribution and the product of the marginal distributions:

$$I(X; Y) = D_{KL}\big(P(X,Y) \parallel P(X)P(Y)\big)$$

This framing shows that mutual information measures how far the joint distribution is from the joint distribution that would occur if $X$ and $Y$ were independent. If $X$ and $Y$ are independent, then $P(x,y) = P(x)P(y)$ for all $x, y$, and $I(X;Y) = 0$.

### Relationship to Entropy

Mutual information can also be decomposed in terms of entropy and conditional entropy:

$$I(X; Y) = H(X) - H(X \mid Y)$$

$$I(X; Y) = H(Y) - H(Y \mid X)$$

$$I(X; Y) = H(X) + H(Y) - H(X, Y)$$

where:
- $H(X)$ is the marginal entropy of $X$
- $H(X \mid Y)$ is the conditional entropy of $X$ given $Y$
- $H(X, Y)$ is the joint entropy of $X$ and $Y$

This decomposition shows mutual information as the reduction in uncertainty about $X$ after observing $Y$ (or symmetrically, about $Y$ after observing $X$).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 340" font-family="sans-serif">
  <text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold">Mutual Information via Entropy Overlap (svg_diagram)</text>

  <circle cx="280" cy="180" r="110" fill="#a3c9f7" opacity="0.55" />
  <circle cx="420" cy="180" r="110" fill="#f7b3a3" opacity="0.55" />

  <text x="200" y="120" font-size="14" font-weight="bold">H(X)</text>
  <text x="470" y="120" font-size="14" font-weight="bold">H(Y)</text>

  <text x="350" y="185" text-anchor="middle" font-size="13" font-weight="bold" fill="#333">I(X;Y)</text>

  <text x="180" y="270" font-size="11" fill="#333">H(X|Y)</text>
  <text x="500" y="270" font-size="11" fill="#333">H(Y|X)</text>

  <text x="350" y="320" text-anchor="middle" font-size="11" fill="#555">Overlap region = mutual information; non-overlap regions = conditional entropies</text>
</svg>

[Inference] This overlap-diagram representation is a widely used pedagogical convention for illustrating the entropy relationships above; it is a visual aid rather than a formal proof.

### Key Properties

**Key Points**
- **Non-negativity**: $I(X; Y) \geq 0$, with equality if and only if $X$ and $Y$ are statistically independent.
- **Symmetry**: $I(X; Y) = I(Y; X)$.
- **Not a metric**: Mutual information does not satisfy the triangle inequality and is not a distance function between variables.
- **Boundedness**: $I(X;Y) \leq \min(H(X), H(Y))$. This is a standard result in information theory.
- **Invariance under reparameterization**: For continuous variables, mutual information is invariant under invertible, differentiable transformations of $X$ or $Y$. [Inference] This property is commonly cited as an advantage of MI over correlation-based measures, though the practical impact depends on the specific estimator used to compute MI in a given implementation.

### Mutual Information vs. Correlation

| Property | Pearson Correlation | Mutual Information |
|----------|---------------------|---------------------|
| Captures linear relationships | Yes | Yes |
| Captures nonlinear relationships | No | Yes |
| Range | -1 to 1 | 0 to $\min(H(X), H(Y))$ |
| Requires continuous variables | Typically yes | No (works for discrete, continuous, or mixed) |
| Zero implies independence | No (zero correlation does not imply independence) | Yes (zero MI implies independence) |

I cannot verify the extent to which any specific software library's mutual information estimator (e.g., k-nearest-neighbor-based estimators for continuous data) achieves the theoretical properties listed above under finite-sample conditions. Estimator behavior [Unverified] can vary depending on sample size, dimensionality, and the specific estimation algorithm used, and is not guaranteed to match theoretical population-level values.

### Worked Example

Consider two binary random variables $X$ and $Y$ with the following joint distribution:

| | $Y=0$ | $Y=1$ | $P(X)$ |
|---|-------|-------|--------|
| $X=0$ | 0.4 | 0.1 | 0.5 |
| $X=1$ | 0.1 | 0.4 | 0.5 |
| $P(Y)$ | 0.5 | 0.5 | 1.0 |

**Step 1: Compute each term**

$$I(X;Y) = \sum_{x,y} P(x,y) \log \frac{P(x,y)}{P(x)P(y)}$$

For $(X=0, Y=0)$: $P(x,y) = 0.4$, $P(x)P(y) = 0.5 \times 0.5 = 0.25$

$$0.4 \log\frac{0.4}{0.25} = 0.4 \log(1.6) = 0.4(0.4700) = 0.1880$$

For $(X=0, Y=1)$: $P(x,y) = 0.1$, $P(x)P(y) = 0.25$

$$0.1 \log\frac{0.1}{0.25} = 0.1 \log(0.4) = 0.1(-0.9163) = -0.0916$$

For $(X=1, Y=0)$: same as above by symmetry $= -0.0916$

For $(X=1, Y=1)$: same as first term by symmetry $= 0.1880$

**Step 2: Sum**

$$I(X;Y) = 0.1880 - 0.0916 - 0.0916 + 0.1880 = 0.1928 \text{ nats}$$

**Example**
This positive value confirms that $X$ and $Y$ are dependent, consistent with the joint table showing that $X=0$ and $Y=0$ co-occur more often than would be expected under independence.

### Applications in Machine Learning

- **Feature Selection**: Mutual information between a feature and a target variable is used to rank or filter features, particularly for capturing nonlinear dependencies that correlation-based methods may miss.
- **Information Bottleneck Method**: Uses mutual information to formalize a trade-off between compressing input data and retaining information relevant for predicting a target. [Inference] This connects to broader theoretical work on representation learning, though the practical applicability to specific deep learning architectures is an area of ongoing research and I cannot verify current consensus.
- **Independent Component Analysis (ICA)**: Related to minimizing mutual information between estimated source signals to achieve statistical independence.
- **Clustering Evaluation**: Adjusted Mutual Information (AMI) and Normalized Mutual Information (NMI) are used as metrics to compare clustering assignments against ground-truth labels.
- **Representation Learning / Self-Supervised Learning**: Some methods aim to maximize mutual information between different views or augmentations of data. [Unverified] I do not have access to specific current benchmark results to characterize how effective any particular method is relative to others.
- **Decision Trees**: Information gain, used as a splitting criterion in algorithms such as ID3, is mathematically a form of mutual information between a feature and the class label.

### Estimating Mutual Information

Estimating MI from finite samples is a nontrivial problem, particularly for continuous variables:

- **Discrete variables**: Can be estimated directly from empirical joint and marginal frequency counts, though bias can occur with small sample sizes relative to the number of categories.
- **Continuous variables**: Common approaches include binning/discretization, kernel density estimation, and k-nearest-neighbor-based estimators (e.g., the Kraskov-Stögbauer-Grassberger estimator). [Unverified] I do not have sufficient information to compare the accuracy of these methods across arbitrary dataset conditions.
- **Neural estimation**: Methods such as MINE (Mutual Information Neural Estimation) use neural networks to estimate a lower bound on mutual information. [Unverified] Claims about the tightness or reliability of such bounds in practice can vary by implementation and are not something I can verify without access to the specific study or codebase in question.

### Common Pitfalls

- Assuming zero correlation implies zero mutual information — this is false, since mutual information captures nonlinear dependence that correlation does not.
- Comparing raw mutual information values across variable pairs with different entropy ranges without normalization, which can produce misleading comparisons.
- Assuming that finite-sample MI estimates converge reliably to true population values regardless of sample size or estimator choice. [Inference] Convergence properties are generally estimator-specific and dataset-dependent, and I cannot verify performance guarantees for any particular tool without a cited source.

### Related Topics
- Kullback-Leibler Divergence (prerequisite concept)
- Entropy and Conditional Entropy
- Information Bottleneck Method
- Feature Selection Techniques in Machine Learning
- Normalized Mutual Information and Adjusted Mutual Information
- Independent Component Analysis (ICA)
- Total Correlation / Multi-information (multivariate generalization)

**Note on this response:** Per your preferences, uncertain or unverifiable claims above are labeled [Inference] or [Unverified] at the specific points where they occur. Mathematical definitions and derivations (entropy decomposition, KL relationship, non-negativity, symmetry) are standard, established results in information theory and are not marked as uncertain. Claims about specific software implementations, current research consensus, or empirical benchmark performance are marked as unverified because I do not have access to real-time or citation-verified sources to confirm them.