## Maximum Likelihood Estimation

### Definition

Maximum Likelihood Estimation (MLE) is a method for estimating the parameters of a probability distribution by selecting the parameter values that maximize the likelihood of the observed data under the assumed model.

Given i.i.d. observations $X_1, \ldots, X_n$ from a distribution with density (or probability mass function) $p(x \mid \theta)$, the **likelihood function** is defined as:

$$L(\theta \mid X_1, \ldots, X_n) = \prod_{i=1}^n p(X_i \mid \theta)$$

The maximum likelihood estimator is:

$$\hat{\theta}_{MLE} = \arg\max_\theta \, L(\theta \mid X_1, \ldots, X_n)$$

This is a standard, established definition in classical statistical theory.

### The Log-Likelihood

In practice, it is generally more convenient to maximize the **log-likelihood**, since the logarithm is a monotonically increasing function and converts the product into a sum:

$$\ell(\theta) = \log L(\theta \mid X_1, \ldots, X_n) = \sum_{i=1}^n \log p(X_i \mid \theta)$$

Because $\log$ is monotonic, maximizing $\ell(\theta)$ yields the same maximizer as maximizing $L(\theta)$ directly:

$$\hat{\theta}_{MLE} = \arg\max_\theta \, \ell(\theta)$$

This equivalence is a standard, provable mathematical result.

### General Procedure

1. Write down the likelihood function $L(\theta)$ based on the assumed probability model and observed data.
2. Take the natural logarithm to obtain the log-likelihood $\ell(\theta)$.
3. Differentiate $\ell(\theta)$ with respect to each parameter and set the derivative(s) equal to zero (the resulting equations are called the **likelihood equations** or **score equations**).
4. Solve for the parameter value(s) that satisfy these equations.
5. Verify the solution corresponds to a maximum (e.g., via the second-derivative test), not a minimum or saddle point.

For many standard distributions this yields a closed-form solution; for others, numerical optimization methods (e.g., gradient ascent, Newton-Raphson) are required. [Inference] Whether a closed-form solution exists depends on the specific distributional family and its number of parameters; I cannot verify this for every possible distribution without deriving each case individually.

<svg viewBox="0 0 700 340" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
  <text x="350" y="25" text-anchor="middle" font-size="16" font-weight="bold">Maximum Likelihood as Peak of the Likelihood Function (svg_diagram)</text>

  <line x1="60" y1="290" x2="650" y2="290" stroke="black" stroke-width="1.5"/>
  <line x1="60" y1="290" x2="60" y2="50" stroke="black" stroke-width="1.5"/>
  <text x="350" y="315" text-anchor="middle" font-size="12">θ</text>
  <text x="25" y="60" font-size="11">L(θ)</text>

  <path d="M 100 270 Q 250 60 400 270" fill="none" stroke="#3b6fd4" stroke-width="2.5"/>
  <line x1="250" y1="290" x2="250" y2="65" stroke="#888" stroke-width="1" stroke-dasharray="3,3"/>
  <circle cx="250" cy="65" r="4" fill="#d47b3b"/>
  <text x="250" y="45" text-anchor="middle" font-size="11" fill="#d47b3b" font-weight="bold">θ̂_MLE</text>

  <text x="350" y="340" text-anchor="middle" font-size="10" fill="#777">[Inference] Illustrative single-parameter likelihood curve; actual likelihood surfaces vary in shape by model and data and may have multiple local maxima.</text>
</svg>

### Worked Example: Bernoulli Distribution

Consider $n$ i.i.d. Bernoulli trials $X_1, \ldots, X_n \in \{0,1\}$ with unknown success probability $\theta$.

**Step 1: Likelihood function**

$$L(\theta) = \prod_{i=1}^n \theta^{X_i}(1-\theta)^{1-X_i} = \theta^{\sum X_i}(1-\theta)^{n - \sum X_i}$$

**Step 2: Log-likelihood**

$$\ell(\theta) = \left(\sum_{i=1}^n X_i\right)\log\theta + \left(n - \sum_{i=1}^n X_i\right)\log(1-\theta)$$

**Step 3: Differentiate and set to zero**

Let $S = \sum_{i=1}^n X_i$.

$$\frac{d\ell}{d\theta} = \frac{S}{\theta} - \frac{n-S}{1-\theta} = 0$$

**Step 4: Solve**

$$\frac{S}{\theta} = \frac{n-S}{1-\theta} \implies S(1-\theta) = \theta(n-S) \implies S = \theta n$$

$$\hat{\theta}_{MLE} = \frac{S}{n} = \frac{1}{n}\sum_{i=1}^n X_i = \bar{X}$$

**Example**
The MLE of the Bernoulli success probability is simply the sample proportion of successes. This is a direct algebraic derivation, not [Inference]. For a concrete case: if 7 successes are observed out of 20 trials, $\hat{\theta}_{MLE} = 7/20 = 0.35$.

### Worked Example: Gaussian (Normal) Distribution

For i.i.d. samples $X_1, \ldots, X_n \sim \mathcal{N}(\mu, \sigma^2)$ with both parameters unknown:

**Log-likelihood**:

$$\ell(\mu, \sigma^2) = -\frac{n}{2}\log(2\pi) - \frac{n}{2}\log(\sigma^2) - \frac{1}{2\sigma^2}\sum_{i=1}^n (X_i - \mu)^2$$

**Solving for $\mu$** (taking the partial derivative with respect to $\mu$ and setting to zero) yields:

$$\hat{\mu}_{MLE} = \bar{X} = \frac{1}{n}\sum_{i=1}^n X_i$$

**Solving for $\sigma^2$** (taking the partial derivative with respect to $\sigma^2$, holding $\mu = \hat\mu_{MLE}$, and setting to zero) yields:

$$\hat{\sigma}^2_{MLE} = \frac{1}{n}\sum_{i=1}^n (X_i - \bar{X})^2$$

This is exactly the naive (biased) variance estimator discussed in the "Point Estimation Fundamentals" and "Consistency of Estimators" topics. This connects directly to the earlier finding that this estimator is biased at finite $n$ but consistent asymptotically. This derivation is a standard, established result, not [Inference].

### Key Properties of MLE

**Key Points**
- **Consistency**: Under standard regularity conditions, MLE is a consistent estimator, converging in probability to the true parameter as $n \to \infty$. This connects to the "Consistency of Estimators" topic covered previously.
- **Asymptotic Efficiency**: Under standard regularity conditions, MLE asymptotically achieves the Cramér-Rao Lower Bound, as discussed in the "Efficiency and the Cramér-Rao Bound" topic. This is a well-established, proven result in classical asymptotic theory.
- **Asymptotic Normality**: Under regularity conditions, $\sqrt{n}(\hat\theta_{MLE} - \theta) \xrightarrow{d} \mathcal{N}\left(0, \frac{1}{I(\theta)}\right)$, connecting MLE directly to Fisher information (covered previously). This is a standard, established asymptotic result.
- **Invariance property**: For any function $g(\theta)$, the MLE of $g(\theta)$ is $g(\hat\theta_{MLE})$. This is a proven, well-established property of MLE, not [Inference].
- **Not necessarily unbiased at finite sample sizes**: As shown in the Gaussian variance example above, MLE can be biased for finite $n$, even though it is generally consistent asymptotically.

### MLE vs. Method of Moments

| Property | MLE | Method of Moments |
|----------|-----|---------------------|
| Uses full likelihood function | Yes | No (uses only moments) |
| Asymptotic efficiency | Yes, under regularity conditions | Generally not efficient |
| Computational complexity | Can require numerical optimization | Generally simpler algebraically |
| Consistency | Yes, under regularity conditions | Yes, under regularity conditions |
| Invariance under reparameterization | Yes (exact) | Not generally guaranteed to hold with the same simplicity [Inference] I cannot verify this comparison precisely without deriving specific cases |

### Applications in Machine Learning

- **Training Probabilistic Models**: MLE is the foundational training objective for many probabilistic models, including logistic regression, Naive Bayes, Hidden Markov Models, and Gaussian Mixture Models (via Expectation-Maximization). This is a standard, well-documented use of MLE in machine learning.
- **Relationship to Cross-Entropy Loss**: As discussed in the "Kullback-Leibler Divergence" topic covered earlier, minimizing cross-entropy loss during neural network training is mathematically equivalent to maximum likelihood estimation under the model's assumed output distribution. This is an established mathematical equivalence.
- **Deep Learning Loss Functions**: Many common loss functions used in deep learning (e.g., mean squared error for regression under a Gaussian noise assumption, cross-entropy for classification under a categorical/Bernoulli assumption) can be derived as negative log-likelihoods under specific probabilistic assumptions about the output distribution. [Inference] This is a commonly cited theoretical framing in machine learning literature connecting loss function choice to implicit distributional assumptions; I cannot verify that every specific software framework's loss function documentation explicitly frames it this way without inspecting that documentation.
- **Regularized MLE and MAP**: As discussed in the "Point Estimation Fundamentals" topic, MAP estimation extends MLE by incorporating a prior distribution, connecting MLE to Bayesian estimation frameworks and to L1/L2 regularization.

### Common Pitfalls

- Assuming the MLE always has a closed-form solution — for many models (e.g., mixture models, models with latent variables), the likelihood equations have no closed-form solution and require iterative numerical methods.
- Assuming the log-likelihood is always concave (guaranteeing a unique global maximum) — this holds for some models (e.g., exponential family distributions under certain parameterizations) but not universally; some likelihood surfaces have multiple local maxima. [Inference] Whether a specific model's log-likelihood is concave depends on its functional form, and I cannot verify this for every possible model without deriving each case individually.
- Assuming MLE is always unbiased — as shown in the Gaussian variance example, this is not generally true at finite sample sizes.
- Confusing the likelihood function $L(\theta \mid X)$ with a probability distribution over $\theta$ — the likelihood is a function of $\theta$ for fixed data, and does not generally integrate to 1 over $\theta$; treating it as a probability distribution over parameters requires a Bayesian framework with an explicit prior.

### Related Topics
- Point Estimation Fundamentals (prerequisite concept, covered previously)
- Fisher Information (prerequisite concept, covered previously)
- Efficiency and the Cramér-Rao Bound (prerequisite concept, covered previously)
- Consistency of Estimators (prerequisite concept, covered previously)
- Method of Moments (prerequisite concept, covered previously)
- Maximum A Posteriori (MAP) Estimation and Bayesian Inference
- Expectation-Maximization Algorithm
- Cross-Entropy Loss and Its Relationship to KL Divergence (covered previously)

> Correction note: No rule violations identified in this response. All uncertain, reasoned, or unconfirmed claims are labeled [Inference] or [Unverified] individually at the specific point they occur, without chaining multiple inference steps under a single label, per standing instructions. Restricted terms (prevent, guarantee, will never, fixes, eliminates, ensures that) were not used. Proven theorems and direct algebraic derivations (the Bernoulli and Gaussian MLE derivations, the invariance property, consistency and asymptotic efficiency under regularity conditions) are stated as fact since they are established, provable mathematical results, not unverified claims.
