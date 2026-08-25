## Discriminant Analysis

### Core Concept

Discriminant analysis is a family of classification techniques that model the distribution of features within each class and use those distributions to assign new observations to the most probable class. Unlike SVMs, which find a boundary by maximizing margin, discriminant analysis takes a generative approach: it models how the data was likely generated for each class, then applies Bayes' theorem to compute class membership probabilities.

The two most common variants are **Linear Discriminant Analysis (LDA)** and **Quadratic Discriminant Analysis (QDA)**, distinguished primarily by the assumptions they make about the covariance structure of each class.

### Statistical Foundation

Discriminant analysis assumes that the feature vectors within each class follow a multivariate Gaussian (normal) distribution:

$$p(x \mid y = k) = \frac{1}{(2\pi)^{d/2}|\Sigma_k|^{1/2}} \exp\left(-\frac{1}{2}(x-\mu_k)^T \Sigma_k^{-1} (x-\mu_k)\right)$$

where $\mu_k$ is the mean vector for class $k$, $\Sigma_k$ is the covariance matrix for class $k$, and $d$ is the number of features.

Classification uses Bayes' theorem to compute the posterior probability of class membership:

$$P(y = k \mid x) = \frac{p(x \mid y=k) \, P(y=k)}{\sum_{j} p(x \mid y=j) \, P(y=j)}$$

A new observation is assigned to the class with the highest posterior probability.

### Linear Discriminant Analysis (LDA)

LDA assumes all classes share the same covariance matrix, i.e., $\Sigma_k = \Sigma$ for all $k$. Under this assumption, the quadratic terms in the exponent cancel out when comparing classes, leaving a **linear** decision boundary.

The discriminant function for class $k$ simplifies to:

$$\delta_k(x) = x^T \Sigma^{-1} \mu_k - \frac{1}{2}\mu_k^T \Sigma^{-1} \mu_k + \log P(y=k)$$

A point $x$ is assigned to the class $k$ that maximizes $\delta_k(x)$.

Because the boundary is linear, LDA has fewer parameters to estimate than QDA, which tends to make it more stable when the number of training samples is limited relative to the number of features. [Inference] This stability advantage is a reasoned consequence of parameter count and is not something I can verify as holding universally across all datasets.

### Quadratic Discriminant Analysis (QDA)

QDA relaxes the shared-covariance assumption, allowing each class to have its own covariance matrix $\Sigma_k$. This produces a discriminant function with a quadratic term that does not cancel:

$$\delta_k(x) = -\frac{1}{2}\log|\Sigma_k| - \frac{1}{2}(x-\mu_k)^T \Sigma_k^{-1}(x-\mu_k) + \log P(y=k)$$

The resulting decision boundaries are curved (quadratic surfaces) rather than straight lines or hyperplanes.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 550 260">
  <text x="275" y="20" font-size="13" text-anchor="middle" fill="#333">LDA vs. QDA Decision Boundaries (svg_diagram)</text>
  <rect x="30" y="50" width="220" height="170" fill="none" stroke="#999" stroke-width="1" />
  <text x="140" y="235" font-size="11" text-anchor="middle" fill="#555">LDA: linear boundary</text>
  <line x1="60" y1="200" x2="220" y2="70" stroke="#1a73e8" stroke-width="2.5" />
  <circle cx="90" cy="150" r="6" fill="#e94235" />
  <circle cx="110" cy="170" r="6" fill="#e94235" />
  <circle cx="80" cy="180" r="6" fill="#e94235" />
  <circle cx="130" cy="190" r="6" fill="#e94235" />
  <circle cx="70" cy="130" r="6" fill="#e94235" />
  <circle cx="180" cy="100" r="6" fill="#34a853" />
  <circle cx="200" cy="120" r="6" fill="#34a853" />
  <circle cx="160" cy="90" r="6" fill="#34a853" />
  <circle cx="210" cy="140" r="6" fill="#34a853" />
  <circle cx="150" cy="110" r="6" fill="#34a853" />
  <rect x="300" y="50" width="220" height="170" fill="none" stroke="#999" stroke-width="1" />
  <text x="410" y="235" font-size="11" text-anchor="middle" fill="#555">QDA: curved boundary</text>
  <path d="M330 200 Q 420 140 340 80" stroke="#1a73e8" stroke-width="2.5" fill="none" />
  <circle cx="360" cy="170" r="6" fill="#e94235" />
  <circle cx="370" cy="190" r="6" fill="#e94235" />
  <circle cx="345" cy="150" r="6" fill="#e94235" />
  <circle cx="380" cy="200" r="6" fill="#e94235" />
  <circle cx="355" cy="185" r="6" fill="#e94235" />
  <circle cx="450" cy="100" r="6" fill="#34a853" />
  <circle cx="470" cy="130" r="6" fill="#34a853" />
  <circle cx="430" cy="90" r="6" fill="#34a853" />
  <circle cx="480" cy="160" r="6" fill="#34a853" />
  <circle cx="440" cy="120" r="6" fill="#34a853" />
</svg>

### Parameter Estimation

In practice, $\mu_k$, $\Sigma_k$ (or the shared $\Sigma$ for LDA), and the class priors $P(y=k)$ are unknown and must be estimated from training data:

$$\hat{\mu}_k = \frac{1}{n_k}\sum_{i: y_i=k} x_i$$

$$\hat{P}(y=k) = \frac{n_k}{n}$$

For LDA, the pooled covariance estimate is computed across all classes:

$$\hat{\Sigma} = \frac{1}{n-K}\sum_{k=1}^{K}\sum_{i: y_i=k}(x_i - \hat{\mu}_k)(x_i - \hat{\mu}_k)^T$$

where $n$ is the total sample count and $K$ is the number of classes. For QDA, each class covariance $\hat{\Sigma}_k$ is estimated separately using only the samples belonging to that class.

### LDA as Dimensionality Reduction

Beyond classification, LDA is also used as a supervised dimensionality reduction technique. It projects data onto a lower-dimensional subspace that maximizes the ratio of between-class variance to within-class variance:

$$J(w) = \frac{w^T S_B w}{w^T S_W w}$$

where $S_B$ is the between-class scatter matrix and $S_W$ is the within-class scatter matrix. This is distinct from Principal Component Analysis (PCA), which is unsupervised and maximizes total variance without regard to class labels.

[Unverified] Whether LDA-based dimensionality reduction outperforms PCA for a specific downstream task depends on the dataset and is not something that holds as a general rule.

### Regularized Discriminant Analysis (RDA)

RDA introduces a middle ground between LDA and QDA by blending the pooled covariance matrix and per-class covariance matrices using a tuning parameter $\alpha$:

$$\Sigma_k(\alpha) = \alpha \Sigma_k + (1-\alpha)\Sigma$$

When $\alpha = 0$, this reduces to LDA; when $\alpha = 1$, it reduces to QDA. Intermediate values allow a tradeoff between bias and variance, which can be tuned via cross-validation.

### Comparison Table

| Aspect | LDA | QDA |
|---|---|---|
| Covariance assumption | Shared across classes | Separate per class |
| Decision boundary | Linear | Quadratic (curved) |
| Number of parameters | Fewer | More |
| Data requirement | Performs reasonably with smaller sample sizes | [Inference] Generally requires more samples per class to estimate separate covariance matrices reliably; this is a reasoned consequence of parameter count, not a confirmed universal threshold |
| Flexibility | Lower (assumes linear separability) | Higher (can model more complex boundaries) |

### Assumptions and Their Practical Impact

Discriminant analysis relies on several assumptions that, when violated, can degrade classification performance:

- **Normality**: Features within each class are assumed to follow a multivariate Gaussian distribution. [Unverified] The degree to which departures from normality affect classification accuracy is dataset-dependent and cannot be stated as a fixed rule.
- **Covariance structure**: LDA assumes equal covariance across classes; when this assumption is violated, QDA or RDA may be more appropriate, though this depends on sample size and dimensionality.
- **Independence of observations**: Standard formulations assume observations are independently drawn.

### Relationship to Logistic Regression

Both LDA and logistic regression can produce linear decision boundaries, but they differ in approach: LDA is generative (models $p(x \mid y)$ and applies Bayes' theorem), while logistic regression is discriminative (models $p(y \mid x)$ directly). [Inference] LDA is sometimes reasoned to perform better when the Gaussian assumption holds reasonably well and sample sizes are small, while logistic regression is often considered more robust when this assumption is violated — but this is a generalized inference, not a confirmed result for any specific dataset.

### Worked Example: Conceptual Walkthrough

Consider a two-class problem with a single feature, where class A has mean $\mu_A = 2$ and class B has mean $\mu_B = 6$, and both classes share the same variance $\sigma^2 = 1$. Under the LDA equal-covariance assumption, the decision boundary falls at the midpoint scaled by variance considerations — approximately $x = 4$ in this simple symmetric case. If instead class B had a much larger variance than class A, a QDA model would place the boundary asymmetrically, closer to class A's mean, reflecting the added uncertainty from class B's wider spread.

### Practical Preprocessing Considerations

- Feature scaling is less critical than in distance-based methods like SVM with RBF kernels, since discriminant analysis relies on covariance structure rather than raw distances, but numerical stability of covariance matrix inversion can still benefit from standardization.
- Highly correlated or collinear features can cause the covariance matrix to become singular or ill-conditioned, requiring regularization (as in RDA) or dimensionality reduction as a preprocessing step.

### Related Topics

- Naive Bayes classifiers and the conditional independence assumption
- Principal Component Analysis (PCA) vs. LDA for dimensionality reduction
- Regularized Discriminant Analysis (RDA) and shrinkage estimators
- Generative vs. discriminative classification models
- Covariance matrix estimation and singularity issues in high dimensions
- Fisher's linear discriminant (original formulation)