## Pure Loss Functions


Pure loss functions are mathematical functions that compute the discrepancy between predicted and actual values without side effects, maintaining referential transparency and determinism. They take predictions and ground truth labels as inputs and return a scalar loss value, enabling gradient computation through automatic differentiation.

**Mathematical Properties:**

Pure loss functions satisfy mathematical purity—given identical inputs, they always produce identical outputs regardless of when or how many times they're called. They contain no hidden state, perform no I/O operations, and don't modify their inputs. This purity guarantees that gradient calculations remain consistent and reproducible across training runs.

**Common Pure Loss Functions:**

**Mean Squared Error (MSE)** - Computes the average squared difference between predictions and targets. Defined as `L(y, ŷ) = (1/n) Σ(yᵢ - ŷᵢ)²`. Heavily penalizes large errors due to squaring, making it sensitive to outliers.

**Cross-Entropy Loss** - Measures the divergence between predicted probability distributions and true distributions. For binary classification: `L(y, ŷ) = -[y log(ŷ) + (1-y) log(1-ŷ)]`. For multi-class: `L(y, ŷ) = -Σ yᵢ log(ŷᵢ)`. The negative log-likelihood interpretation makes it the standard choice for classification tasks.

**Huber Loss** - Combines MSE and Mean Absolute Error, using squared error for small differences and absolute error for large differences. Defined piecewise with a delta threshold parameter. More robust to outliers than pure MSE while maintaining differentiability.

**Hinge Loss** - Used for maximum-margin classification, particularly in SVMs. `L(y, ŷ) = max(0, 1 - y·ŷ)` where y ∈ {-1, 1}. Penalizes predictions on the wrong side of the decision boundary or too close to it.

**Composability:**

Pure loss functions compose naturally through function composition and arithmetic operations. Weighted combinations like `L_total = α·L₁ + β·L₂` create multi-objective losses. Regularization terms compose additively: `L_regularized = L_data + λ·L_penalty`. This composability emerges directly from mathematical purity—composed pure functions remain pure.

**Implementation Patterns:**

```python
# Pure loss function - no side effects, deterministic
def mse_loss(y_true, y_pred):
    return np.mean((y_true - y_pred) ** 2)

# Composed loss with regularization
def regularized_loss(y_true, y_pred, weights, lambda_reg):
    data_loss = mse_loss(y_true, y_pred)
    l2_penalty = np.sum(weights ** 2)
    return data_loss + lambda_reg * l2_penalty

# Higher-order function creating specialized losses
def create_weighted_loss(base_loss, weights):
    return lambda y_true, y_pred: np.sum(weights * base_loss(y_true, y_pred))
```

**Gradient Flow:**

Purity enables automatic differentiation frameworks to construct computational graphs deterministically. Each evaluation of a pure loss function produces the same graph structure, allowing backpropagation to compute consistent gradients. Non-pure functions with hidden state or randomness would produce non-deterministic gradients, destabilizing training.

**Testing and Verification:**

Pure loss functions are inherently testable through property-based testing. Symmetry properties (e.g., `L(y, ŷ) = L(ŷ, y)` for MSE), non-negativity (`L ≥ 0`), and zero-loss for perfect predictions (`L(y, y) = 0`) can be verified exhaustively. Gradient correctness can be validated via numerical differentiation since pure functions guarantee consistent behavior.

