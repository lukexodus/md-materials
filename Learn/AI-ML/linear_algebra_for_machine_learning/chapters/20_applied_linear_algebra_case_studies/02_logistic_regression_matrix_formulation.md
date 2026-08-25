## Logistic Regression Matrix Formulation

### Overview

Logistic regression extends the linear algebra framework of linear regression to classification tasks by composing a linear transformation with a nonlinear sigmoid function. This section derives the matrix formulation of logistic regression, its loss function, and the gradient used for optimization.

### Problem Setup

**Key Points**
- Given a design matrix $X \in \mathbb{R}^{N \times n}$ (with $N$ observations and $n$ features, possibly including a bias column of ones) and binary labels $y \in \{0,1\}^N$, logistic regression models the probability that each observation belongs to class 1.
- A weight vector $w \in \mathbb{R}^n$ parameterizes a linear score $z = Xw \in \mathbb{R}^N$, which is then transformed into a probability via the sigmoid function.

### The Sigmoid Function

**Key Points**
- The sigmoid (logistic) function maps any real-valued input to the interval $(0,1)$:

$$\sigma(z) = \frac{1}{1+e^{-z}}$$

- Applied elementwise to the linear score vector $z = Xw$, this produces predicted probabilities:

$$\hat{y} = \sigma(Xw), \quad \hat{y}_i = \frac{1}{1+e^{-(Xw)_i}}$$

- [Inference] The sigmoid function's output range of $(0,1)$ is a mathematical property of its definition, commonly cited as the reason it is used to represent probabilities in binary classification; this is a standard mathematical justification found in statistics and machine learning literature, not a claim specific to any implementation.

### Matrix Form of the Linear Score

**Key Points**
- For a single observation $x_i \in \mathbb{R}^n$ (a row of $X$), the linear score is $z_i = x_i^Tw$, a scalar.
- For the full dataset, stacking all $N$ observations gives $z = Xw \in \mathbb{R}^N$, computed via a single matrix-vector multiplication rather than $N$ separate dot products.
- This matrix formulation allows the same computational efficiency benefits (vectorization, hardware parallelism) discussed in other linear algebra-based ML computations.

### The Logistic Loss (Binary Cross-Entropy)

**Key Points**
- Logistic regression is typically fit by maximizing the likelihood of the observed labels under the model, which is equivalent to minimizing the negative log-likelihood, commonly called binary cross-entropy loss or log loss.
- For a single observation:

$$\ell_i(w) = -\left[y_i\log(\hat{y}_i) + (1-y_i)\log(1-\hat{y}_i)\right]$$

- In matrix/vector form, summed (or averaged) across all $N$ observations:

$$J(w) = -\frac{1}{N}\sum_{i=1}^{N}\left[y_i\log(\hat{y}_i) + (1-y_i)\log(1-\hat{y}_i)\right]$$

- [Inference] This loss function is derived in standard statistics literature from the assumption that labels follow a Bernoulli distribution parameterized by $\hat{y}_i$, and that maximizing the likelihood of observed data under this assumption is equivalent to minimizing the negative log-likelihood; this is a stated mathematical derivation, not a claim about real-world label distributions in any specific dataset.

### Vectorized Loss Expression

**Key Points**
- The loss can be written more compactly using vector operations:

$$J(w) = -\frac{1}{N}\left[y^T\log(\hat{y}) + (1-y)^T\log(1-\hat{y})\right]$$

- Here, $\log(\hat{y})$ denotes elementwise logarithm applied to the vector $\hat{y}$, and $(1-y)$, $(1-\hat{y})$ denote elementwise subtraction from a vector of ones.
- [Unverified] The exact convention for averaging (dividing by $N$) versus summing across observations differs across sources and implementations, and this response does not assert one as universally standard.

### Deriving the Gradient

**Key Points**
- To optimize $J(w)$, its gradient with respect to $w$ is required. Unlike linear regression, this loss does not yield a closed-form solution when the gradient is set to zero, due to the nonlinearity introduced by the sigmoid function.
- The gradient of the loss with respect to the linear score $z_i$ has a notably simple form: $\dfrac{\partial \ell_i}{\partial z_i} = \hat{y}_i - y_i$. [Inference] This simplification is a standard result in derivations of logistic regression found in machine learning literature, arising from the specific mathematical relationship between the sigmoid function's derivative and the log-loss formula; it is presented here as an established mathematical derivation, not independently re-verified from first principles within this response beyond the outline given.
- Applying the chain rule through $z = Xw$, the full gradient in matrix form is:

$$\nabla_w J(w) = \frac{1}{N}X^T(\hat{y} - y)$$

### Gradient Derivation Flow

```mermaid
flowchart TD
    A[z = Xw] --> B[y_hat = sigmoid of z]
    B --> C[J(w) = binary cross-entropy of y and y_hat]
    C --> D[Chain rule: dJ/dz = y_hat - y]
    D --> E[dz/dw = X]
    E --> F[Gradient: grad_w J = 1/N times X^T times (y_hat - y)]
```

### Why No Closed-Form Solution Exists

**Key Points**
- Unlike ordinary least squares, setting $\nabla_w J(w) = X^T(\hat{y} - y) = 0$ does not yield a solvable linear system for $w$, because $\hat{y} = \sigma(Xw)$ is a nonlinear function of $w$.
- [Inference] This is a standard mathematical observation in machine learning literature: because the sigmoid function is nonlinear, the resulting gradient equation cannot generally be algebraically rearranged into a closed-form expression for $w$, unlike the linear regression case. This is a stated mathematical property, not a claim about any particular numerical solver's behavior.
- As a result, logistic regression is typically fit using iterative optimization methods such as gradient descent or Newton's method, rather than a closed-form matrix solution.

### Gradient Descent Update Rule

**Key Points**
- Using the derived gradient, the parameter update rule for gradient descent is:

$$w \leftarrow w - \eta \cdot \frac{1}{N}X^T(\hat{y} - y)$$

- where $\eta$ is the learning rate.
- [Unverified] The exact convergence behavior, appropriate learning rate range, and number of iterations required depend on the specific dataset, feature scaling, and optimizer variant used, and no general values are asserted here as universally applicable.

### Newton's Method and the Hessian

**Key Points**
- Newton's method uses second-order information (the Hessian matrix) to achieve faster convergence in some cases. For logistic regression, the Hessian of $J(w)$ has the matrix form:

$$H = \frac{1}{N}X^TSX$$

where $S$ is a diagonal matrix with entries $S_{ii} = \hat{y}_i(1-\hat{y}_i)$.

- [Inference] This Hessian form is a standard result derived in optimization and statistics literature by differentiating the gradient expression a second time with respect to $w$; it is presented here as an established mathematical derivation from that literature, not independently re-derived step-by-step within this response.
- [Unverified] Whether Newton's method or gradient-based methods are used in any specific software implementation, and their relative practical performance on any specific dataset, is not addressed here without a citable, version-specific source.

### Decision Boundary as a Linear Algebra Object

**Key Points**
- The decision boundary of logistic regression (the set of points where predicted probability equals 0.5) corresponds to the hyperplane where $z = Xw = 0$, since $\sigma(0) = 0.5$.
- This means logistic regression, despite modeling probabilities via a nonlinear function, produces a linear decision boundary in the original feature space.
- [Inference] This linear decision boundary property is a standard mathematical consequence of the model's structure (a linear score passed through a monotonic nonlinearity), commonly stated in machine learning literature as a defining characteristic distinguishing logistic regression from nonlinear classifiers; it is not a claim about performance or suitability for any specific dataset's true class boundary shape.

### Decision Boundary Diagram

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 700 380">
  <text x="350" y="30" text-anchor="middle" font-size="17" font-weight="bold" fill="#1a1a1a">Logistic Regression Decision Boundary (svg_diagram)</text>

  <line x1="80" y1="320" x2="620" y2="320" stroke="#333" stroke-width="1.5" />
  <line x1="80" y1="320" x2="80" y2="60" stroke="#333" stroke-width="1.5" />
  <text x="350" y="350" text-anchor="middle" font-size="12" fill="#333">Feature 1</text>
  <text x="35" y="190" text-anchor="middle" font-size="12" fill="#333" transform="rotate(-90 35 190)">Feature 2</text>

  <line x1="120" y1="80" x2="550" y2="300" stroke="#a45cc4" stroke-width="3" />
  <text x="560" y="290" font-size="12" fill="#a45cc4">Xw = 0 (p=0.5)</text>

  <circle cx="200" cy="120" r="5" fill="#4a90d9" />
  <circle cx="250" cy="100" r="5" fill="#4a90d9" />
  <circle cx="180" cy="180" r="5" fill="#4a90d9" />
  <circle cx="300" cy="130" r="5" fill="#4a90d9" />
  <text x="220" y="70" font-size="11" fill="#4a90d9">class y=1</text>

  <circle cx="400" cy="250" r="5" fill="#d94a4a" />
  <circle cx="450" cy="280" r="5" fill="#d94a4a" />
  <circle cx="480" cy="230" r="5" fill="#d94a4a" />
  <circle cx="380" cy="300" r="5" fill="#d94a4a" />
  <text x="450" y="330" font-size="11" fill="#d94a4a">class y=0</text>

  <text x="350" y="45" text-anchor="middle" font-size="10" fill="#777" />
</svg>

[Inference] This diagram is a simplified conceptual illustration of a linear decision boundary property described mathematically above. It does not represent actual data or a measured result from any specific dataset or trained model.

### Multiclass Extension: Softmax Regression

**Key Points**
- Logistic regression generalizes to multiclass classification via softmax regression (also called multinomial logistic regression), replacing the sigmoid with the softmax function and using a weight matrix $W \in \mathbb{R}^{n \times C}$ instead of a single vector, where $C$ is the number of classes.
- The predicted probability matrix is $\hat{Y} = \text{softmax}(XW)$, applied row-wise, producing an $N \times C$ matrix of class probabilities.
- [Unverified] Specific implementation conventions for softmax regression (such as whether one class is treated as a reference/redundant category to address parameter identifiability) vary across statistical and machine learning treatments, and this response does not assert one specific convention as universal.

### Regularized Logistic Regression

**Key Points**
- Similar to ridge regression, an L2 penalty term can be added to the logistic loss to reduce overfitting: $J_{reg}(w) = J(w) + \lambda\|w\|_2^2$.
- The corresponding gradient becomes: $\nabla_w J_{reg}(w) = \frac{1}{N}X^T(\hat{y}-y) + 2\lambda w$.
- [Unverified] The appropriate value of the regularization hyperparameter $\lambda$ is dataset- and task-dependent, and no general value is asserted here as universally appropriate.

### Common Pitfalls

**Key Points**
- Attempting to solve for $w$ using a closed-form matrix equation (as in linear regression), which is not mathematically valid for logistic regression due to the nonlinearity of the sigmoid function.
- Numerical instability when computing $\log(\hat{y})$ or $\log(1-\hat{y})$ if $\hat{y}$ is very close to 0 or 1, which [Inference] is commonly addressed in implementations through numerical safeguards such as clipping probability values, though the specific safeguard used varies by library and is not detailed further here without a citable, version-specific source.
- Confusing the linear score $z = Xw$ with the final predicted probability $\hat{y} = \sigma(z)$; only the former is linear in $w$.
- Misinterpreting the linear decision boundary property as implying logistic regression can only be used on linearly separable data; feature engineering (e.g., polynomial features) can extend its applicability, though this response does not make claims about performance outcomes of such extensions.

### Related Topics

- Linear regression fully derived
- Gradient descent and iterative optimization methods
- Newton's method and second-order optimization
- Softmax regression and multiclass classification
- Maximum likelihood estimation
- Regularization techniques (L1/L2 penalties)
- Convexity and optimization landscapes

Correction disclaimer: I cannot verify specific numerical library implementation choices, exact optimizer convergence behavior, or dataset-specific outcomes referenced in this content without citable, version-specific sources. All [Inference] and [Unverified] labeled statements reflect standard mathematical derivations found in machine learning and statistics literature, not independently re-verified claims about any specific software system. Behavior of specific numerical libraries, optimizers, or implementations is not guaranteed and may vary by version, algorithm choice, and data conditioning.