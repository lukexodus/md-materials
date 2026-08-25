## AdaBoost

### Overview

AdaBoost (Adaptive Boosting) is one of the earliest and most influential boosting algorithms, introduced by Freund and Schapire. It builds a strong classifier by combining multiple weak learners in sequence, where each successive learner is trained to focus more heavily on the instances that previous learners misclassified. The "adaptive" part of the name refers to this dynamic reweighting: the algorithm adapts to the errors of its own prior iterations.

AdaBoost was originally formulated for binary classification and has since been extended to multi-class and regression variants.

### Core Algorithm

The algorithm proceeds through the following steps for a binary classification problem with labels $y_i \in \{-1, +1\}$:

1. Initialize equal weights for all $n$ training instances:

$$w_i^{(1)} = \frac{1}{n}, \quad i = 1, \ldots, n$$

2. For each iteration $t = 1$ to $T$:
   - Train a weak learner $h_t(x)$ on the training data using weights $w_i^{(t)}$.
   - Compute the weighted error rate:

$$\epsilon_t = \sum_{i=1}^{n} w_i^{(t)} \cdot \mathbb{1}(h_t(x_i) \neq y_i)$$

   - Compute the learner's contribution weight (its "say" in the final vote):

$$\alpha_t = \frac{1}{2} \ln\left(\frac{1 - \epsilon_t}{\epsilon_t}\right)$$

   - Update instance weights:

$$w_i^{(t+1)} = w_i^{(t)} \cdot \exp\left(-\alpha_t \cdot y_i \cdot h_t(x_i)\right)$$

   - Normalize weights so they sum to 1.

3. Output the final strong classifier:

$$H(x) = \text{sign}\left(\sum_{t=1}^{T} \alpha_t h_t(x)\right)$$

### AdaBoost Training Loop (svg_diagram)

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 760 400" font-family="sans-serif">
  <text x="380" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a2e">AdaBoost Training Loop (svg_diagram)</text>

  <rect x="30" y="60" width="180" height="55" rx="8" fill="#e3f2fd" stroke="#1565c0" stroke-width="1.5" />
  <text x="120" y="90" text-anchor="middle" font-size="12" fill="#0d47a1" font-weight="bold">Init equal weights w_i = 1/n</text>

  <rect x="290" y="60" width="180" height="55" rx="8" fill="#fff3e0" stroke="#e65100" stroke-width="1.5" />
  <text x="380" y="90" text-anchor="middle" font-size="12" fill="#e65100" font-weight="bold">Train weak learner h_t</text>

  <rect x="550" y="60" width="180" height="55" rx="8" fill="#e8f5e9" stroke="#2e7d32" stroke-width="1.5" />
  <text x="640" y="85" text-anchor="middle" font-size="12" fill="#1b5e20" font-weight="bold">Compute error ε_t</text>
  <text x="640" y="102" text-anchor="middle" font-size="10.5" fill="#1b5e20">weighted misclassification</text>

  <line x1="210" y1="87" x2="290" y2="87" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />
  <line x1="470" y1="87" x2="550" y2="87" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />

  <rect x="550" y="170" width="180" height="55" rx="8" fill="#f3e5f5" stroke="#6a1b9a" stroke-width="1.5" />
  <text x="640" y="195" text-anchor="middle" font-size="12" fill="#4a148c" font-weight="bold">Compute α_t</text>
  <text x="640" y="212" text-anchor="middle" font-size="10.5" fill="#4a148c">learner's vote weight</text>

  <line x1="640" y1="115" x2="640" y2="170" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />

  <rect x="290" y="170" width="180" height="55" rx="8" fill="#ffebee" stroke="#c62828" stroke-width="1.5" />
  <text x="380" y="195" text-anchor="middle" font-size="12" fill="#b71c1c" font-weight="bold">Update instance weights</text>
  <text x="380" y="212" text-anchor="middle" font-size="10.5" fill="#b71c1c">misclassified ↑, correct ↓</text>

  <line x1="550" y1="197" x2="470" y2="197" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />

  <rect x="30" y="170" width="180" height="55" rx="8" fill="#e0f2f1" stroke="#00695c" stroke-width="1.5" />
  <text x="120" y="195" text-anchor="middle" font-size="12" fill="#004d40" font-weight="bold">Normalize weights</text>
  <text x="120" y="212" text-anchor="middle" font-size="10.5" fill="#004d40">sum to 1</text>

  <line x1="290" y1="197" x2="210" y2="197" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />

  <path d="M120,170 C120,140 250,90 290,90" stroke="#555" stroke-width="1.5" stroke-dasharray="4,3" fill="none" marker-end="url(#arrowA)" />
  <text x="150" y="130" font-size="10" fill="#333" font-style="italic">repeat for t = 1..T</text>

  <rect x="290" y="290" width="180" height="60" rx="8" fill="#fce4ec" stroke="#ad1457" stroke-width="1.5" />
  <text x="380" y="315" text-anchor="middle" font-size="12" fill="#880e4f" font-weight="bold">Final Classifier H(x)</text>
  <text x="380" y="332" text-anchor="middle" font-size="10.5" fill="#880e4f">sign(Σ α_t h_t(x))</text>

  <line x1="120" y1="225" x2="330" y2="290" stroke="#555" stroke-width="1.5" marker-end="url(#arrowA)" />

  </svg>

### Interpreting the Alpha Weight

The value of $\alpha_t$ is directly determined by how well learner $t$ performed relative to random guessing:

- If $\epsilon_t \to 0$ (near-perfect learner), $\alpha_t \to +\infty$, giving that learner enormous influence.
- If $\epsilon_t = 0.5$ (no better than random guessing on a binary task), $\alpha_t = 0$, and the learner contributes nothing to the final vote.
- If $\epsilon_t > 0.5$ (worse than random guessing), $\alpha_t$ becomes negative, effectively inverting that learner's predictions in the final vote.

#### Worked Numerical Example

Suppose a weak learner achieves a weighted error rate of $\epsilon_t = 0.3$:

$$\alpha_t = \frac{1}{2} \ln\left(\frac{1 - 0.3}{0.3}\right) = \frac{1}{2} \ln(2.333) \approx 0.423$$

Compare this to a stronger learner with $\epsilon_t = 0.1$:

$$\alpha_t = \frac{1}{2} \ln\left(\frac{0.9}{0.1}\right) = \frac{1}{2} \ln(9) \approx 1.099$$

The learner with lower error receives roughly 2.6 times more voting weight in this comparison, illustrating how AdaBoost weights learners in proportion to their demonstrated accuracy on the weighted training set.

### Instance Reweighting Behavior

The exponential term in the weight update, $\exp(-\alpha_t \cdot y_i \cdot h_t(x_i))$, behaves differently depending on whether an instance was classified correctly:

- **Correct classification** ($y_i = h_t(x_i)$): the exponent is negative, so the weight is multiplied by a factor less than 1, decreasing its influence going forward.
- **Misclassification** ($y_i \neq h_t(x_i)$): the exponent is positive, so the weight is multiplied by a factor greater than 1, increasing its influence in the next round.

This creates the characteristic AdaBoost behavior of forcing subsequent weak learners to concentrate on the hardest, most persistently misclassified instances.

### Weight Evolution Across Rounds

```mermaid
flowchart LR
    R1["Round 1: all weights equal"] --> R2["Round 2: misclassified instances upweighted"]
    R2 --> R3["Round 3: previously hard instances get more focus"]
    R3 --> R4["Round T: final weighted combination"]
```

### Choice of Weak Learner

AdaBoost is most commonly implemented using decision stumps (decision trees restricted to a single split) as the weak learner, though it is not restricted to this choice. Any classifier that performs slightly better than random guessing on weighted data can serve as a base learner, including shallow decision trees of depth greater than one, or even simple linear classifiers.

[Inference] Decision stumps are popular in AdaBoost implementations partly because they are computationally cheap to train at each of many boosting rounds, but the specific choice of base learner and its effect on performance is dataset-dependent, and I do not have access to a controlled comparison to cite for this general tendency.

### Exponential Loss Interpretation

AdaBoost can be shown to be equivalent to fitting an additive model that minimizes exponential loss:

$$L(y, F(x)) = \exp(-y \cdot F(x))$$

Where $F(x) = \sum_{t=1}^{T} \alpha_t h_t(x)$ is the cumulative weighted sum of weak learners. Viewed this way, AdaBoost is a special case of the broader gradient boosting framework, using exponential loss specifically rather than other loss functions such as log loss or squared error.

### Multi-Class Extensions

Several extensions adapt AdaBoost beyond binary classification:

- **SAMME (Stagewise Additive Modeling using a Multi-class Exponential loss function)**: Extends AdaBoost to multi-class problems by modifying the weight update and alpha computation to account for the number of classes $K$:

$$\alpha_t = \ln\left(\frac{1 - \epsilon_t}{\epsilon_t}\right) + \ln(K - 1)$$

- **SAMME.R**: A variant of SAMME that uses predicted class probabilities rather than hard class labels, which [Inference] can lead to different convergence behavior compared to SAMME, though I do not have access to a specific benchmark to confirm the magnitude or consistency of this difference across datasets.

### Strengths

- **Simple to implement and understand**: The core algorithm involves only reweighting and a weighted vote, without complex gradient computations.
- **Few hyperparameters**: Primarily just the number of estimators $T$ and the choice of weak learner, making it comparatively easy to configure relative to gradient boosting variants with many regularization parameters.
- **Versatile base learners**: Can work with a variety of weak learner types, not restricted to decision trees.
- **Theoretical guarantees on training error**: Under certain conditions, AdaBoost's training error can be shown to decrease exponentially with the number of rounds. [Unverified] I do not have access to a specific source confirming that this theoretical bound holds precisely across all practical datasets and weak learner choices, so this should be treated as a property of the algorithm under its original theoretical assumptions rather than a universal empirical guarantee.

### Weaknesses

- **Sensitive to noisy data and outliers**: Since misclassified instances are given exponentially increasing weight, mislabeled data points or outliers can dominate later training rounds, potentially degrading the ensemble's performance.
- **Sequential dependency**: Each round depends on the outcome of the previous round, which limits parallelization across boosting iterations (though training of a single weak learner within a round may still be parallelized depending on implementation).
- **Performance depends on weak learner quality**: If the base learner is too weak or too strong, results can be affected; extremely weak learners may require many rounds to converge, while very strong learners can lead to less effective boosting dynamics.
- **Less robust than gradient boosting variants in some settings**: [Inference] Modern gradient boosting implementations (e.g., XGBoost, LightGBM) are often reported to outperform standard AdaBoost on many structured/tabular tasks, but I do not have access to a specific controlled benchmark to confirm the extent or consistency of this difference across problem domains.

### AdaBoost vs. Gradient Boosting

| Aspect | AdaBoost | Gradient Boosting |
|---|---|---|
| Focus mechanism | Reweights misclassified instances | Fits new learner to residual/gradient of loss |
| Loss function | Exponential loss (implicitly) | Any differentiable loss function |
| Learner combination | Weighted vote via $\alpha_t$ | Additive sum scaled by learning rate |
| Sensitivity to outliers | Higher, due to exponential weighting | Depends on loss function chosen |
| Typical base learner | Decision stumps | Shallow decision trees (deeper than stumps) |

### Common Applications

- Face detection systems, historically notable for use in the Viola-Jones object detection framework
- Text classification tasks with weak, simple base classifiers
- Any binary classification task where a simple, interpretable ensemble is preferred over more complex boosting variants

**Related Topics**
- Gradient Boosting as the generalization of AdaBoost to arbitrary loss functions
- Decision stumps and shallow decision trees as weak learners
- Exponential loss and its relationship to other classification loss functions
- Bagging and Random Forests as an alternative ensemble strategy
- SAMME and SAMME.R for multi-class boosting
- Viola-Jones object detection as a historical application of AdaBoost
- Ensemble model interpretability techniques