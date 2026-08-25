## Likelihood Function

### Overview

A likelihood function expresses the plausibility of different parameter values given a fixed set of observed data. It is mathematically related to the probability distribution of the data but reinterprets that function with data held fixed and parameters treated as variable. Likelihood is central to Maximum Likelihood Estimation (MLE), Bayesian inference, and the theoretical foundation of many machine learning model-fitting procedures, including logistic regression, Gaussian mixture models, and neural network training via cross-entropy loss.

### Formal Definition

For a probability distribution $P(D \mid \theta)$ describing data $D$ given parameter $\theta$, the likelihood function is defined as the same mathematical expression, but viewed as a function of $\theta$ with $D$ fixed:

$$L(\theta \mid D) = P(D \mid \theta)$$

The critical distinction is conceptual, not always numerical: $P(D \mid \theta)$ is a probability (or density) over data for a fixed parameter, while $L(\theta \mid D)$ is a function over parameter values for fixed, observed data. As a function of $\theta$, the likelihood does not necessarily integrate or sum to 1, and it is therefore not itself a probability distribution over $\theta$.

### Likelihood for Independent Observations

For $n$ independent and identically distributed (i.i.d.) observations $x_1, x_2, \ldots, x_n$, the joint likelihood is the product of individual likelihoods:

$$L(\theta \mid x_1, \ldots, x_n) = \prod_{i=1}^{n} P(x_i \mid \theta)$$

### Log-Likelihood

Because products of many small probabilities can cause numerical underflow, and because sums are generally easier to work with analytically and computationally, the natural logarithm of the likelihood — the **log-likelihood** — is used in practice:

$$\ell(\theta \mid D) = \log L(\theta \mid D) = \sum_{i=1}^{n} \log P(x_i \mid \theta)$$

Since the logarithm is a strictly increasing (monotonic) function, the value of $\theta$ that maximizes $L(\theta \mid D)$ is the same value that maximizes $\ell(\theta \mid D)$. This is a direct mathematical property of monotonic transformations, not an approximation.

### Maximum Likelihood Estimation (MLE)

MLE selects the parameter value $\hat{\theta}$ that maximizes the likelihood (or equivalently, the log-likelihood) of the observed data:

$$\hat{\theta}_{MLE} = \arg\max_{\theta} \, L(\theta \mid D) = \arg\max_{\theta} \, \ell(\theta \mid D)$$

This is typically found by taking the derivative of the log-likelihood with respect to $\theta$, setting it to zero, and solving — for models where this is analytically tractable — or via numerical optimization methods (e.g., gradient descent, Newton-Raphson) when closed-form solutions are not available.

### Worked Example — MLE for a Bernoulli Parameter

Suppose $n$ independent coin flips are observed, with $x$ heads (successes) and unknown probability of success $\theta$. The likelihood is:

$$L(\theta \mid x, n) = \binom{n}{x} \theta^x (1-\theta)^{n-x}$$

Log-likelihood:

$$\ell(\theta) = \log\binom{n}{x} + x\log\theta + (n-x)\log(1-\theta)$$

Taking the derivative with respect to $\theta$ and setting it to zero:

$$\frac{d\ell}{d\theta} = \frac{x}{\theta} - \frac{n-x}{1-\theta} = 0$$

Solving this equation algebraically yields:

$$\hat{\theta}_{MLE} = \frac{x}{n}$$

This is a standard closed-form result derivable directly through calculus from the stated likelihood function, not an approximation or inference.

**Numeric example:** with $n=50$ trials and $x=32$ successes:

$$\hat{\theta}_{MLE} = \frac{32}{50} = 0.64$$

### Diagram: Likelihood as a Function of the Parameter

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 620 340">
<text x="310" y="25" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Likelihood curve over theta, data fixed (svg_diagram)</text>
<line x1="60" y1="280" x2="580" y2="280" stroke="#333" stroke-width="1.5" />
<line x1="60" y1="280" x2="60" y2="50" stroke="#333" stroke-width="1.5" />
<text x="320" y="310" text-anchor="middle" font-size="12" fill="#333">theta (parameter value)</text>
<text x="25" y="170" text-anchor="middle" font-size="12" fill="#333" transform="rotate(-90 25 170)">L(theta | data)</text>
<path d="M 60 275 Q 200 260 300 90 Q 400 260 580 275" fill="none" stroke="#2563eb" stroke-width="2.5" />
<line x1="300" y1="90" x2="300" y2="280" stroke="#dc2626" stroke-width="1.5" stroke-dasharray="5,4" />
<text x="300" y="300" text-anchor="middle" font-size="12" fill="#dc2626" font-weight="bold">theta_MLE = 0.64</text>
</svg>

### Likelihood vs. Probability — Key Distinction

| Aspect | Probability | Likelihood |
| --- | --- | --- |
| What is fixed | Parameter $\theta$ | Data $D$ |
| What varies | Data $D$ | Parameter $\theta$ |
| Sums/integrates to 1 over its argument | Yes (over data) | Not generally (over $\theta$) |
| Question answered | "How likely is this data, given this parameter?" | "How plausible is this parameter, given this data?" |

### Likelihood in Bayesian Inference

The likelihood function is one of the two core inputs to Bayes' theorem, alongside the prior:

$$P(\theta \mid D) \propto P(D \mid \theta) \, P(\theta)$$

Here, $P(D \mid \theta)$ is the likelihood, interpreted as a function of $\theta$ for the observed, fixed data $D$. The likelihood is the mechanism through which observed data updates prior beliefs into posterior beliefs.

### Likelihood in Common Machine Learning Models

- **Linear regression**: under the assumption of normally distributed errors, minimizing squared error is mathematically equivalent to maximizing the likelihood under a Gaussian noise model. [Inference — this is a well-established theoretical equivalence commonly presented in statistical learning texts, though the specific derivation is not reproduced here and should be checked against a primary source if precision is required]
- **Logistic regression**: parameters are typically estimated by maximizing the likelihood of a Bernoulli (or categorical, for multiclass) outcome model, which corresponds to minimizing cross-entropy loss. [Inference — this equivalence is standard in machine learning theory but is stated here without independent verification against a specific cited source in this conversation]
- **Gaussian Mixture Models**: fitted via maximum likelihood, typically using the Expectation-Maximization (EM) algorithm, since direct closed-form maximization is generally intractable for mixture models. [Inference]
- **Neural network training**: many standard loss functions (cross-entropy, mean squared error under Gaussian assumptions) can be derived as negative log-likelihoods under specific probabilistic assumptions about the output distribution. [Inference — this is a commonly cited theoretical framing in deep learning literature, not verified against a specific source here]

I cannot verify the precise derivations or implementation-specific behavior of any particular software library's loss functions without checking a specific, named source. [Unverified]

### Likelihood Ratio and Likelihood Ratio Tests

The **likelihood ratio** compares the likelihood of the data under two competing parameter values or models:

$$\Lambda = \frac{L(\theta_0 \mid D)}{L(\theta_1 \mid D)}$$

The **likelihood ratio test** is used to compare a restricted (null) model against a more general (alternative) model, commonly used for nested model comparison:

$$-2\log\Lambda \sim \chi^2_{df}$$

under standard regularity conditions, where $df$ is the difference in the number of free parameters between the two models. This asymptotic chi-squared approximation relies on specific regularity conditions on the underlying models. [Inference — this reflects standard asymptotic theory as generally presented in statistical inference literature, not verified against a specific source in this conversation]

### Python Implementation Example

```python
import numpy as np
from scipy.optimize import minimize_scalar

# MLE for Bernoulli parameter via numerical optimization
n, x = 50, 32

def neg_log_likelihood(theta):
    if theta <= 0 or theta >= 1:
        return np.inf
    return -(x * np.log(theta) + (n - x) * np.log(1 - theta))

result = minimize_scalar(neg_log_likelihood, bounds=(1e-6, 1-1e-6), method='bounded')
print(f"MLE estimate: {result.x:.4f}")
```

I have not executed this code, so I cannot verify its exact printed output. [Unverified] The result should numerically approximate the closed-form value of $0.64$ derived earlier, but exact convergence and precision depend on the optimizer's settings and the installed version of `scipy`. [Inference]

### Properties of Maximum Likelihood Estimators

Under standard regularity conditions, MLE estimators are generally described in statistical theory as having these asymptotic properties:

- **Consistency**: as sample size increases, the MLE estimate is expected to converge toward the true parameter value [Inference — this is a standard asymptotic property described in statistical theory, not independently verified against a specific source in this conversation]
- **Asymptotic normality**: the sampling distribution of the MLE estimator approaches a normal distribution as sample size grows large [Inference]
- **Asymptotic efficiency**: MLE estimators are described in classical statistical theory as achieving the lowest possible variance among consistent estimators in the large-sample limit, under the specific regularity conditions required for this result to hold [Inference]

These are asymptotic (large-sample) properties; they do not guarantee good behavior in small samples, and finite-sample performance can differ substantially depending on the model and data. [Inference]

### Limitations and Considerations

- MLE can overfit with limited data, since it has no mechanism to penalize complexity unless regularization (which can be framed as introducing a prior, moving toward MAP estimation) is added
- MLE does not directly provide a measure of parameter uncertainty; this typically requires additional methods such as the Fisher information matrix, bootstrap resampling, or a fully Bayesian treatment [Inference]
- For some models, the likelihood surface can have multiple local maxima, meaning numerical optimization procedures are not guaranteed to converge to the global maximum in all cases [Inference]
- Model misspecification (using a likelihood based on incorrect distributional assumptions) can bias parameter estimates, since MLE's theoretical guarantees rely on the assumed model being correctly specified [Inference]

### **Key Points**

- The likelihood function evaluates plausibility of parameter values for fixed, observed data — it is a function of the parameter, not of the data
- Log-likelihood is used in practice for numerical stability and analytical convenience, without changing the location of the maximum
- Maximum Likelihood Estimation selects the parameter value that maximizes the likelihood (or log-likelihood) of the observed data
- Many standard ML loss functions correspond to negative log-likelihoods under specific probabilistic assumptions [Inference]
- MLE has favorable asymptotic properties (consistency, asymptotic normality, asymptotic efficiency) under regularity conditions, but these are large-sample guarantees, not small-sample guarantees [Inference]

### **Related Topics**

- Maximum a Posteriori (MAP) estimation
- Prior distributions and Bayesian inference
- Expectation-Maximization (EM) algorithm
- Likelihood ratio tests and nested model comparison
- Fisher information and the Cramér-Rao lower bound
- Cross-entropy loss and its probabilistic interpretation
- Bias-variance tradeoff in estimation