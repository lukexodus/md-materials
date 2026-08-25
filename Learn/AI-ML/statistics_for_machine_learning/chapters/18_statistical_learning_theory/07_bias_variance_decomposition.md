## Bias-Variance Decomposition

### Definition

The bias-variance decomposition is a mathematical framework that decomposes the expected prediction error of a statistical learning model into three additive components: bias, variance, and irreducible error. It applies to models trained under squared error loss and provides a way to analyze why a model generalizes well or poorly.

### Formal Decomposition

For a target variable $y = f(x) + \epsilon$, where $\epsilon$ is noise with mean zero and variance $\sigma^2$, and a model prediction $\hat{f}(x)$ trained on a random training set, the expected squared error at a point $x$ decomposes as:

$$\mathbb{E}[(y - \hat{f}(x))^2] = \text{Bias}[\hat{f}(x)]^2 + \text{Var}[\hat{f}(x)] + \sigma^2$$

where:

$$\text{Bias}[\hat{f}(x)] = \mathbb{E}[\hat{f}(x)] - f(x)$$



$$\text{Var}[\hat{f}(x)] = \mathbb{E}\left[\left(\hat{f}(x) - \mathbb{E}[\hat{f}(x)]\right)^2\right]$$

The expectation $\mathbb{E}[\hat{f}(x)]$ is taken over the distribution of possible training sets of a fixed size, treating the model's prediction as a random variable that depends on which training set happened to be sampled.

### Component Definitions

**Bias** measures the systematic error introduced by approximating a real-world problem, which may be arbitrarily complex, with a simplified model. High bias indicates the model's average prediction, over many possible training sets, is far from the true function $f(x)$. This is characteristic of underfitting.

**Variance** measures how much the model's predictions fluctuate across different training sets drawn from the same distribution. High variance indicates the model is highly sensitive to the specific data it was trained on. This is characteristic of overfitting.

**Irreducible error** ($\sigma^2$) is the noise inherent in the data-generating process itself. [Inference] This component is generally treated as a lower bound on achievable error for any model, since it does not depend on model choice, though this framing depends on the assumption that $\epsilon$ is truly independent of $x$ and cannot be modeled — an assumption that may not hold for all real-world data-generating processes.

### Derivation Sketch

Starting from the expected squared error at a fixed point $x$, with $y = f(x) + \epsilon$:

$$\mathbb{E}[(y - \hat{f}(x))^2] = \mathbb{E}[(f(x) + \epsilon - \hat{f}(x))^2]$$

Adding and subtracting $\mathbb{E}[\hat{f}(x)]$ inside the square, then expanding, separates the expression into the squared bias term, the variance term, and $\mathbb{E}[\epsilon^2] = \sigma^2$, with cross-terms vanishing under the assumptions that $\epsilon$ has mean zero and is independent of $\hat{f}(x)$.

### Visualizing the Tradeoff

===MERMAID_DIAGRAM===

graph LR

A["Model Complexity (svg_diagram)"] --> B["Low Complexity"]

A --> C["High Complexity"]

B --> D["High Bias<br/>Low Variance<br/>Underfitting"]

C --> E["Low Bias<br/>High Variance<br/>Overfitting"]

D --> F["Total Error"]

E --> F

F --> G["Optimal Complexity<br/>Minimizes Total Error"]

style G fill:#2d5,stroke:#333

### The Tradeoff

As model complexity increases (e.g., higher-degree polynomials, deeper trees, more parameters), bias tends to decrease because the model can represent more complex functions. Variance tends to increase because the model becomes more sensitive to fluctuations in the specific training sample. Total expected error, being the sum of squared bias, variance, and irreducible error, often exhibits a U-shaped curve as a function of model complexity, with a minimum at some intermediate complexity level.

[Inference] This U-shape is the typical textbook depiction, but it is not a universal property of every model class or dataset. Its actual shape depends on the specific hypothesis space, dataset, and complexity measure used, so it should not be treated as a fixed law that applies identically to every learning scenario.

### Example

Consider fitting polynomial regression models of increasing degree to noisy data generated from a quadratic function $f(x) = x^2$:

- A degree-1 (linear) model cannot represent the curvature — high bias, low variance across different training samples.
- A degree-2 (quadratic) model matches the true functional form — low bias, low variance, if the true relationship is genuinely quadratic.
- A degree-15 model can fit training noise precisely — near-zero bias on training data, but high variance, since small changes in training data produce large changes in the fitted curve.

**Example**

```python
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline

np.random.seed(0)
x_true = np.linspace(-3, 3, 30)
y_true = x_true ** 2

n_trials = 100
degree = 15
predictions = []

for _ in range(n_trials):
    noise = np.random.normal(0, 3, size=x_true.shape)
    y_train = y_true + noise
    model = make_pipeline(PolynomialFeatures(degree), LinearRegression())
    model.fit(x_true.reshape(-1, 1), y_train)
    predictions.append(model.predict(x_true.reshape(-1, 1)))

predictions = np.array(predictions)
mean_prediction = predictions.mean(axis=0)
bias_squared = (mean_prediction - y_true) ** 2
variance = predictions.var(axis=0)
```

**Output**

This produces, at each point along `x_true`, an estimate of squared bias (how far the average prediction across trials is from the true function) and variance (how much predictions spread out across trials). [Inference] For a degree-15 polynomial fit to a genuinely quadratic function with noise, the variance term is expected to be substantially larger than in the degree-2 case, based on the general principle that higher-capacity models are more sensitive to training-sample fluctuations. This is a reasoned expectation from the decomposition's structure, not a guaranteed numerical outcome, since actual values depend on noise level, sample size, and regularization. I cannot verify the exact numerical values this code would produce without executing it against a specific random seed and environment.

### Relationship to Overfitting and Underfitting

| Regime | Bias | Variance | Training Error | Test Error |
| --- | --- | --- | --- | --- |
| Underfitting | High | Low | High | High |
| Well-fit | Moderate/Low | Moderate/Low | Low | Low |
| Overfitting | Low | High | Very Low | High |

### Connection to Regularization

Regularization techniques (L1/L2 penalties, dropout, early stopping, pruning) generally work by intentionally increasing bias in exchange for reduced variance. [Inference] This tradeoff is the commonly cited theoretical justification for regularization, though the degree to which it improves generalization on a specific dataset depends on the regularization strength and the true underlying data structure, and is not something that can be assumed to hold in all cases without empirical validation.

$$\hat{f}_{\text{ridge}} = \arg\min_f \sum_i (y_i - f(x_i))^2 + \lambda \|f\|^2$$

As $\lambda$ increases, bias tends to increase and variance tends to decrease. The optimal $\lambda$ is typically selected via cross-validation rather than derived analytically, since the true bias and variance are not directly observable from a single dataset.

### Connection to Ensemble Methods

- **Bagging** (e.g., Random Forests) primarily targets variance reduction by averaging predictions across models trained on bootstrap-resampled data, under the assumption that averaging many high-variance, low-bias models reduces overall variance without substantially increasing bias.
- **Boosting** (e.g., Gradient Boosting, AdaBoost) primarily targets bias reduction by sequentially fitting models to residual errors of prior models.

[Unverified] Whether a specific ensemble method reduces variance or bias more effectively for a specific dataset cannot be determined analytically without empirical testing, since the interaction between base learner design, data structure, and ensembling strategy affects outcomes in ways not fully captured by the general bagging/boosting framing.

### Limitations of the Decomposition

- The classical decomposition assumes squared error loss; it does not directly apply to other loss functions (e.g., 0-1 loss for classification) without modification. Bias-variance decompositions for classification exist but take different mathematical forms and are less standardized across the literature.
- The decomposition treats the training set as the sole source of randomness in $\hat{f}(x)$; it does not account for randomness from stochastic optimization (e.g., SGD initialization, minibatch order) unless that randomness is explicitly folded into the expectation.
- [Speculation] The relationship between bias-variance tradeoff and modern overparameterized deep learning models (where test error can decrease even as model capacity grows far beyond the interpolation threshold, sometimes called "double descent") suggests the classical U-shaped tradeoff may not hold uniformly across all model classes, particularly heavily overparameterized ones. This connection to double descent phenomena is an active area of research, and its theoretical implications are not fully settled, so it is marked as speculation rather than established fact.

### Conclusion

The bias-variance decomposition provides a formal accounting of prediction error into components attributable to model simplification (bias), model sensitivity to training data (variance), and inherent data noise (irreducible error). It offers a conceptual and mathematical basis for understanding why increasing model complexity does not monotonically improve generalization, and why techniques like regularization and ensembling are structured the way they are. Its classical form applies most directly to squared-error regression settings, and extensions or exceptions apply in other contexts.

**Related Topics**

- Overfitting and Underfitting
- Regularization (L1/L2, Ridge, Lasso)
- Cross-Validation Techniques
- Ensemble Methods: Bagging vs. Boosting
- Double Descent Phenomenon
- No Free Lunch Theorem
- Model Capacity and VC Dimension
- Learning Curves and Diagnostic Plots
- Loss Functions and Their Decompositions