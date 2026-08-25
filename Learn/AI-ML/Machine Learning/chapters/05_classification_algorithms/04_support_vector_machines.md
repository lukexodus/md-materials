## Support Vector Machines

### Core Concept

A support vector machine (SVM) is a supervised learning algorithm that finds the optimal separating boundary — called a hyperplane — between classes by maximizing the margin between the closest points of each class. These closest points are called **support vectors**, and they alone determine the position and orientation of the decision boundary.

The central idea: among infinitely many hyperplanes that could separate two classes, SVM selects the one with the largest distance to the nearest data point of any class. This margin-maximization principle gives SVMs strong generalization properties compared to arbitrary linear separators.

### Geometric Intuition

For a binary classification problem in $n$-dimensional space, a hyperplane is defined as:

$$w \cdot x + b = 0$$

where $w$ is the weight vector (normal to the hyperplane) and $b$ is the bias term. Points are classified based on which side of the hyperplane they fall:

$$f(x) = \text{sign}(w \cdot x + b)$$

The margin is the perpendicular distance from the hyperplane to the nearest point of either class. For a correctly classified point, the margin distance is:

$$\text{margin} = \frac{|w \cdot x + b|}{\|w\|}$$

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 500 320">
  <text x="250" y="20" font-size="13" text-anchor="middle" fill="#333">Maximum Margin Hyperplane (svg_diagram)</text>
  <line x1="50" y1="280" x2="450" y2="280" stroke="#999" stroke-width="1" />
  <line x1="50" y1="280" x2="50" y2="40" stroke="#999" stroke-width="1" />
  <line x1="80" y1="260" x2="420" y2="80" stroke="#1a73e8" stroke-width="2.5" />
  <line x1="60" y1="230" x2="400" y2="50" stroke="#1a73e8" stroke-width="1" stroke-dasharray="6,4" />
  <line x1="100" y1="290" x2="440" y2="110" stroke="#1a73e8" stroke-width="1" stroke-dasharray="6,4" />
  <circle cx="150" cy="210" r="7" fill="#e94235" />
  <circle cx="200" cy="190" r="7" fill="#e94235" />
  <circle cx="120" cy="240" r="7" fill="#e94235" />
  <circle cx="180" cy="150" r="7" fill="#e94235" />
  <circle cx="90" cy="180" r="7" fill="#e94235" />
  <circle cx="300" cy="150" r="7" fill="#34a853" stroke="#1a1a1a" stroke-width="2" />
  <circle cx="350" cy="130" r="7" fill="#34a853" />
  <circle cx="380" cy="180" r="7" fill="#34a853" />
  <circle cx="330" cy="200" r="7" fill="#34a853" />
  <circle cx="410" cy="150" r="7" fill="#34a853" />
  <circle cx="200" cy="190" r="9" fill="none" stroke="#1a1a1a" stroke-width="2" />
  <text x="250" y="300" font-size="11" fill="#555" text-anchor="middle">Decision hyperplane (solid) with margin boundaries (dashed)</text>
  <text x="150" y="130" font-size="11" fill="#e94235">Class A</text>
  <text x="380" y="110" font-size="11" fill="#34a853">Class B</text>
  <text x="215" y="185" font-size="10" fill="#1a1a1a">support vector</text>
</svg>

### The Optimization Problem

SVM training is formulated as a constrained optimization problem. The **hard-margin** formulation (assuming linearly separable data) seeks to minimize:

$$\min_{w,b} \frac{1}{2}\|w\|^2$$

subject to the constraint that every point is correctly classified with margin at least 1:

$$y_i(w \cdot x_i + b) \geq 1 \quad \text{for all } i$$

Here $y_i \in \{-1, +1\}$ represents the class label. Minimizing $\|w\|^2$ is mathematically equivalent to maximizing the margin $\frac{2}{\|w\|}$.

### Soft Margin: Handling Non-Separable Data

Real-world data is rarely perfectly separable. The **soft-margin SVM** introduces slack variables $\xi_i \geq 0$ that allow some points to violate the margin, penalized by a regularization parameter $C$:

$$\min_{w,b,\xi} \frac{1}{2}\|w\|^2 + C\sum_{i=1}^{n}\xi_i$$

subject to:

$$y_i(w \cdot x_i + b) \geq 1 - \xi_i, \quad \xi_i \geq 0$$

The parameter $C$ controls the tradeoff between margin width and classification error:

- **Large $C$**: narrower margin, fewer misclassifications tolerated, higher risk of overfitting
- **Small $C$**: wider margin, more misclassifications tolerated, higher bias but better generalization

[Inference] The optimal value of $C$ is dataset-dependent and is typically selected through cross-validation rather than derived analytically, since no closed-form solution exists for the ideal tradeoff point.

### The Kernel Trick

When classes are not linearly separable in the original feature space, SVMs use kernel functions to implicitly map data into a higher-dimensional space where linear separation becomes possible — without explicitly computing the transformation.

The kernel function computes the dot product in the transformed space directly:

$$K(x_i, x_j) = \phi(x_i) \cdot \phi(x_j)$$

Common kernel functions:

**Linear kernel**
$$K(x_i, x_j) = x_i \cdot x_j$$
Equivalent to no transformation; used when data is already linearly separable.

**Polynomial kernel**
$$K(x_i, x_j) = (x_i \cdot x_j + c)^d$$
Captures interactions between features up to degree $d$.

**Radial Basis Function (RBF) / Gaussian kernel**
$$K(x_i, x_j) = \exp\left(-\gamma \|x_i - x_j\|^2\right)$$
Maps into an infinite-dimensional space; $\gamma$ controls the influence radius of each training point.

**Sigmoid kernel**
$$K(x_i, x_j) = \tanh(\alpha \, x_i \cdot x_j + c)$$
Behaves similarly to a two-layer neural network activation in certain parameter regimes.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 550 260">
  <text x="275" y="20" font-size="13" text-anchor="middle" fill="#333">Kernel Trick: Non-Linear to Linear Separation (svg_diagram)</text>
  <ellipse cx="140" cy="140" rx="100" ry="80" fill="none" stroke="#999" stroke-width="1" />
  <circle cx="140" cy="140" r="6" fill="#e94235" />
  <circle cx="160" cy="120" r="6" fill="#e94235" />
  <circle cx="120" cy="160" r="6" fill="#e94235" />
  <circle cx="150" cy="160" r="6" fill="#e94235" />
  <circle cx="130" cy="115" r="6" fill="#e94235" />
  <circle cx="90" cy="90" r="6" fill="#34a853" />
  <circle cx="190" cy="90" r="6" fill="#34a853" />
  <circle cx="90" cy="190" r="6" fill="#34a853" />
  <circle cx="190" cy="190" r="6" fill="#34a853" />
  <circle cx="70" cy="140" r="6" fill="#34a853" />
  <text x="140" y="235" font-size="11" text-anchor="middle" fill="#555">Original space (not linearly separable)</text>
  <path d="M270 140 L320 140" stroke="#333" stroke-width="2" marker-end="url(#arrow)" />
  <text x="295" y="125" font-size="10" text-anchor="middle" fill="#333">φ(x)</text>
  <rect x="350" y="60" width="160" height="150" fill="none" stroke="#999" stroke-width="1" />
  <line x1="360" y1="180" x2="500" y2="90" stroke="#1a73e8" stroke-width="2.5" />
  <circle cx="380" cy="190" r="6" fill="#e94235" />
  <circle cx="400" cy="195" r="6" fill="#e94235" />
  <circle cx="420" cy="185" r="6" fill="#e94235" />
  <circle cx="440" cy="190" r="6" fill="#e94235" />
  <circle cx="460" cy="180" r="6" fill="#e94235" />
  <circle cx="390" cy="120" r="6" fill="#34a853" />
  <circle cx="420" cy="100" r="6" fill="#34a853" />
  <circle cx="450" cy="110" r="6" fill="#34a853" />
  <circle cx="470" cy="90" r="6" fill="#34a853" />
  <circle cx="490" cy="120" r="6" fill="#34a853" />
  <text x="430" y="235" font-size="11" text-anchor="middle" fill="#555">Transformed space (linearly separable)</text>
</svg>

### Multi-Class Classification

SVMs are inherently binary classifiers. For multi-class problems, two common decomposition strategies are used:

**One-vs-Rest (OvR)**
Trains $k$ classifiers for $k$ classes, each distinguishing one class from all others combined. The classifier with the highest confidence score determines the predicted class.

**One-vs-One (OvO)**
Trains $\binom{k}{2}$ classifiers, one for every pair of classes. The final prediction is determined by majority vote across all pairwise classifiers.

[Unverified] Which strategy performs better in practice depends on the dataset, class imbalance, and implementation; no universal ranking between OvR and OvO holds across all cases.

### The Decision Function

Once trained, classification of a new point $x$ uses only the support vectors, not the full training set:

$$f(x) = \text{sign}\left(\sum_{i \in SV} \alpha_i y_i K(x_i, x) + b\right)$$

where $\alpha_i$ are the Lagrange multipliers learned during optimization, and $SV$ denotes the set of support vector indices. Points with $\alpha_i = 0$ do not influence the decision boundary at all — this is why SVMs can be memory-efficient at inference time relative to the size of the training set.

### Hyperparameter Sensitivity

| Hyperparameter | Effect | Typical tuning approach |
|---|---|---|
| $C$ | Controls margin/error tradeoff | Grid search or random search with cross-validation |
| $\gamma$ (RBF) | Controls influence radius of each point | Grid search jointly with $C$ |
| Kernel choice | Determines shape of decision boundary | Selected based on data structure and validation performance |
| Degree $d$ (polynomial) | Controls complexity of polynomial boundary | Usually kept low (2–3) to avoid overfitting |

[Inference] High $\gamma$ values in the RBF kernel tend to produce tightly fit boundaries around individual points, which is commonly associated with overfitting, though the exact threshold is data-dependent and not fixed across problems.

### Advantages

- Effective in high-dimensional spaces, including cases where the number of dimensions exceeds the number of samples
- Memory-efficient at prediction time since only support vectors are retained
- Versatile through different kernel choices, allowing adaptation to varied decision boundary shapes
- Robust to overfitting in high-dimensional space when the margin is well-regularized

### Limitations

- Training time complexity is commonly cited as between $O(n^2)$ and $O(n^3)$ with respect to the number of samples $n$, depending on the solver and implementation. [Unverified] Exact scaling varies by library, solver algorithm (e.g., SMO vs. interior point methods), and data sparsity.
- Does not directly provide probability estimates; probabilistic outputs require an additional calibration step (e.g., Platt scaling)
- Performance is sensitive to feature scaling — unscaled features can distort the margin calculation
- Choice of kernel and hyperparameters requires careful tuning; poor choices can degrade performance substantially

### Practical Preprocessing Considerations

Because the margin calculation depends on distances in feature space, SVMs are sensitive to the scale of input features. Standard practice includes:

- Standardizing features to zero mean and unit variance, or scaling to a fixed range such as $[0, 1]$
- Applying the same scaling transformation fitted on training data to test data, to avoid data leakage

### Worked Example: Conceptual Walkthrough

Consider a dataset with two features and two classes that are not linearly separable in their raw form (e.g., one class forms a ring around the other). Applying an RBF kernel implicitly projects the data into a space where a hyperplane can separate the classes. The decision boundary in the original 2D space then appears as a closed curve rather than a straight line, even though the underlying optimization is still solving for a linear hyperplane in the transformed space.

### Related Topics

- Kernel methods and Mercer's theorem
- Support Vector Regression (SVR)
- Sequential Minimal Optimization (SMO) algorithm
- Platt scaling for probability calibration
- Comparison: SVM vs. logistic regression vs. decision trees
- Dual formulation and Lagrangian optimization in SVM training
- Feature scaling techniques (standardization vs. normalization)