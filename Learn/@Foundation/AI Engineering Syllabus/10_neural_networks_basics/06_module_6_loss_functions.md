## Module 6: Loss Functions


### 6.1 Fundamentals

- Role in optimization
- Relationship to task objectives
- Differentiability requirements
- Convexity properties

### 6.2 Regression Loss Functions

- Mean Squared Error (MSE)
    - L2 loss formulation
    - Sensitivity to outliers
    - Gaussian assumption
- Mean Absolute Error (MAE)
    - L1 loss formulation
    - Robustness to outliers
    - Gradient characteristics
- Huber Loss
    - Combines MSE and MAE
    - Quadratic to linear transition
    - Delta parameter tuning
- Log-Cosh Loss
- Quantile Loss

### 6.3 Binary Classification Loss Functions

- Binary Cross-Entropy (Log Loss)
    - Probabilistic interpretation
    - Relationship to maximum likelihood
    - Numerical stability considerations
- Hinge Loss
    - Support Vector Machine connection
    - Margin-based formulation
- Focal Loss
    - Addressing class imbalance
    - Hard example mining
    - Focusing parameter

### 6.4 Multi-class Classification Loss Functions

- Categorical Cross-Entropy
    - Softmax output pairing
    - One-hot encoding requirement
    - Multi-class extension
- Sparse Categorical Cross-Entropy
    - Integer label format
    - Memory efficiency
- Kullback-Leibler Divergence
    - Distribution matching
    - Information theory perspective

### 6.5 Specialized Loss Functions

- Contrastive Loss
    - Siamese networks
    - Distance metric learning
- Triplet Loss
    - Anchor-positive-negative triplets
    - Margin parameter
    - Mining strategies
- Center Loss
    - Intra-class compactness
    - Feature discrimination

### 6.6 Multi-task and Auxiliary Losses

- Weighted loss combinations
- Task balancing strategies
- Auxiliary supervision
- Loss term scheduling

### 6.7 Regularization through Loss

- L1 regularization (Lasso)
- L2 regularization (Ridge, weight decay)
- Elastic Net
- Regularization coefficient selection

### 6.8 Custom Loss Design

- Domain-specific objectives
- Differentiability maintenance
- Numerical stability
- Gradient behavior analysis

---

