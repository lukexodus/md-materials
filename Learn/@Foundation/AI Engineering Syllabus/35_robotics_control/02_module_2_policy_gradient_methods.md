## Module 2: Policy Gradient Methods


### 2.1 Policy Gradient Fundamentals

- Direct policy optimization
- Policy parameterization
    - Neural network policies
    - Gaussian policies for continuous actions
    - Softmax policies for discrete actions
- Policy gradient theorem
    - Derivation and intuition
    - Score function estimator
    - Log-derivative trick

### 2.2 REINFORCE Algorithm

- Monte Carlo policy gradient
- Baseline subtraction
    - Variance reduction
    - Bias-variance trade-off
- Implementation considerations
- Advantage estimation

### 2.3 Natural Policy Gradients

- Fisher information matrix
- Natural gradient direction
- Computational considerations
- Relationship to trust regions

### 2.4 Trust Region Policy Optimization (TRPO)

- Trust region concept
- KL divergence constraint
- Conjugate gradient optimization
- Line search procedures
- Monotonic improvement guarantee
- Computational complexity

### 2.5 Proximal Policy Optimization (PPO)

- Clipped surrogate objective
- PPO vs TRPO comparison
- Adaptive KL penalty
- Implementation efficiency
- Hyperparameter sensitivity
- PPO variants
    - PPO-Clip
    - PPO-Penalty
- Practical tuning strategies

### 2.6 Advanced Policy Gradient Techniques

- Generalized Advantage Estimation (GAE)
    - λ-returns
    - Bias-variance control
- Importance sampling corrections
- Off-policy policy gradients
- Deterministic policy gradients (DPG)
    - Continuous action spaces
    - Gradient computation

### 2.7 Entropy Regularization

- Exploration encouragement
- Temperature parameters
- Soft policy optimization
- Maximum entropy RL framework

---

